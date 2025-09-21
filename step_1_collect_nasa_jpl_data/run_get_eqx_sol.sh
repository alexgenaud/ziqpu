#!/bin/bash

# Check if argument is a 4-digit number
if [[ "$1" =~ ^[0-9]{4}$ ]]; then
  YEAR="$1"
else
  YEAR="$(date +%Y)"
fi

START="${YEAR}-01-01"
STOP="${YEAR}-12-31"
STEP="1 d"

wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* 35[89]" | grep -B1 "${YEAR}-.* [01]\..*," | grep -A1 "${YEAR}-.* 35[89]" >q_mar.txt
sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* 8[89]" | grep -B1 "${YEAR}-.* 9[01]\..*," | grep -A1 "${YEAR}-.* 8[89]" >q_jun.txt
sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* 17[89]" | grep -B1 "${YEAR}-.* 18[01]\..*," | grep -A1 "${YEAR}-.* 17[89]" >q_sep.txt
sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* 26[89]" | grep -B1 "${YEAR}-.* 27[01]\..*," | grep -A1 "${YEAR}-.* 26[89]" >q_dec.txt

for x in "mar:359:  0" "jun: 89: 90" "sep:179:180" "dec:269:270"; do
  month=$(echo "$x" | cut -d':' -f1)
  FILE="q_$month.txt"
  P=$(echo "$x" | cut -d':' -f2)
  N=$(echo "$x" | cut -d':' -f3)

  # cat $FILE
  START=$(head -1 $FILE | sed "s/^.*\(${YEAR}-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1 00:00/")
  STOP=$(tail -1 $FILE | sed "s/^.*\(${YEAR}-[JFMASOND][a-z][a-z]-[0-3][0-9]\).*/\1 13:00/")
  STEP="1 h"
  # echo "START=$START STOP=$STOP STEP=$STEP"
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* ${P}\.9" | grep -B1 "${YEAR}-.* ${N}\.0" | grep -A1 "${YEAR}-.* ${P}\.9" >$FILE

  # cat $FILE
  START=$(head -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]\).*/\1:00/")
  STOP=$(tail -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]\).*/\1:30/")
  STEP="1 m"
  # echo "START=$START STOP=$STOP STEP=$STEP"
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* ${P}\.99" | grep -B1 "${YEAR}-.* ${N}\.00" | grep -A1 "${YEAR}-.* ${P}\.99" >$FILE

  # cat $FILE
  START=$(head -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]\).*/\1:00/")
  STOP=$(tail -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]\).*/\1:30/")
  STEP="90"
  # echo "START=$START STOP=$STOP STEP=$STEP"
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* ${P}\.999" | grep -B1 "${YEAR}-.* ${N}\.000" | grep -A1 "${YEAR}-.* ${P}\.999" >$FILE

  # cat $FILE
  START=$(head -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/\1/")
  STOP=$(tail -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/\1/")
  STEP="2"
  # echo "START=$START STOP=$STOP STEP=$STEP"
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX | grep -A1 "${YEAR}-.* ${P}\.999" | grep -B1 "${YEAR}-.* ${N}\.000" | grep -A1 "${YEAR}-.* ${P}\.999" >$FILE

  cat $FILE
  # START=$(head -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/\1/")
  # STOP=$(tail -1 $FILE | sed "s/^.*\(${YEAR}-[JFMAJSOND][a-z][a-z]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]*\).*/\1/")
  # echo "START=$START STOP=$STOP DONE"
  echo

done
rm XXX
