#!/bin/bash

parse_year() {
  local raw="$1"
  IYEAR=""
  NYEAR=""

  # Default to current year if none provided
  if [[ -z "$raw" ]]; then
    raw=$(date +%Y)
  fi

  # Normalize input to uppercase
  raw=$(echo "$raw" | tr '[:lower:]' '[:upper:]')

  # Match input like: 4BC
  if [[ "$raw" =~ ^([0-9]+)BC$ ]]; then
    local n="${BASH_REMATCH[1]}"
    IYEAR="${n}BC" # example n=1505, IYEAR=1505BC
    local next=$((n - 1))
    NYEAR="${next}BC" # example NYEAR=1504BC
    return 0

  # Match input like: b0004
  elif [[ "$raw" =~ ^[B-]([0-9]{4})$ ]]; then
    local n="${BASH_REMATCH[1]}"
    local num=$(echo "$n" | sed 's/^0*//') # Remove leading zeros
    IYEAR="${num}BC"
    local next=$((num - 1))
    NYEAR="${next}BC"
    return 0

  # Match input like: 5AD
  elif [[ "$raw" =~ ^([0-9]+)AD$ ]]; then
    local n="${BASH_REMATCH[1]}"
    IYEAR="${n}AD"
    local next=$((n + 1))
    NYEAR="${next}AD"
    return 0

  # Match 4-digit CE years like 0005 or 2025
  elif [[ "$raw" =~ ^[0-9]{4}$ ]]; then
    local n=$(echo "$raw" | sed 's/^0*//') # remove leading zeros
    IYEAR="${n}"
    local next=$((n + 1))
    NYEAR="${next}"
    return 0
  fi

  echo "❌ Invalid year input: '$raw'" >&2
  return 1
}

parse_year "$1"
if [[ $? -ne 0 ]]; then
  echo "Usage: $0 <year> (e.g., 4BC, b0004, 5AD, 0005, 2025)" >&2
  exit 1
fi

# Whether REF_SYSTEM is ICRF or J2000 does not seem to change the results
URL="https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&QUANTITIES=31&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES&"

# Regex to match Horizons return year
RYEAR='[b-]*[0-9][0-9][0-9][0-9]'

START="${IYEAR}-12-30"
STOP="${NYEAR}-01-02"
STEP="1 d"
# echo "DATES $START $STOP $STEP"

# echo "${URL}START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27"
wget -q -O YYY "${URL}START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27"
sed 's/\\n/\n/g' YYY | sed s:360.0000000,:359.9999999,:g >XXX

grep -A1 "${RYEAR}-.* 26[89]\..*,.*," XXX | grep -B1 "${RYEAR}-.* 27[01]\..*,.*," >q_dec.txt

FILE="q_dec.txt"
P=269
N=270

START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$START"
START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/${IYEAR}\2 00:00/")

STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$STOP"
STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/${IYEAR}\2 13:00/")

STEP="1 h"
# echo
# echo 1 start $FILE
# cat $FILE
# echo 1 $START TO $STOP STEP=$STEP

wget -q -O YYY "${URL}START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27"
sed 's/\\n/\n/g' YYY | sed s:360.0000000,:359.9999999,:g >XXX
grep -A1 "${RYEAR}-.* ${P}\.9" XXX | grep -B1 "${RYEAR}-.* ${N}\.0" | grep -A1 "${RYEAR}-.* ${P}\.9" >$FILE

START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$START"
START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]\).*/$IYEAR\2:00/")

STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$STOP"
STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]\).*/$IYEAR\2:30/")
STEP="1 m"
# echo
# echo 2 start $FILE
# cat $FILE
# echo 2 $START TO $STOP STEP=$STEP

wget -q -O YYY "${URL}START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27"
sed 's/\\n/\n/g' YYY | sed s:360.0000000,:359.9999999,:g >XXX
grep -A1 "${RYEAR}-.* ${P}\.99" XXX | grep -B1 "${RYEAR}-.* ${N}\.00" | grep -A1 "${RYEAR}-.* ${P}\.99" >$FILE

START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$START"
START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]\).*/$IYEAR\2:00/")

STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$STOP"
STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]\).*/$IYEAR\2:30/")

STEP="90"
# echo
# echo 3 start $FILE
# cat $FILE
# echo 3 START=$START TO STOP=$STOP STEP=$STEP

wget -q -O YYY "${URL}START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27"
sed 's/\\n/\n/g' YYY | sed s:360.0000000,:359.9999999,:g >XXX
grep -A1 "${RYEAR}-.* ${P}\.999" XXX | grep -B1 "${RYEAR}-.* ${N}\.000" | grep -A1 "${RYEAR}-.* ${P}\.999" >$FILE

START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$START"
START=$(head -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/$IYEAR\2/")

STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1/")
parse_year "$STOP"
STOP=$(tail -1 $FILE | sed "s/^\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/$IYEAR\2/")
STEP="2"
# echo
# echo 4 start $FILE
# cat $FILE
# echo 4 START=$START TO STOP=$STOP STEP=$STEP

wget -q -O YYY "${URL}START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27"
sed 's/\\n/\n/g' YYY | sed s:360.0000000,:359.9999999,:g >XXX
grep -A1 "${RYEAR}-.* ${P}\.999" XXX | grep -B1 "${RYEAR}-.* ${N}\.000" | grep -A1 "${RYEAR}-.* ${P}\.999" >$FILE

cat $FILE
# START=$(head -1 $FILE | sed "s/^.*\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/$IYEAR\1/")
# STOP=$(tail -1 $FILE | sed "s/^.*\($RYEAR\)\(-[JFMASOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/$IYEAR\1/")
# echo "START=$START STOP=$STOP DONE"
echo

rm XXX YYY q_dec.txt
