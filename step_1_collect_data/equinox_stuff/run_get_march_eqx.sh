YEAR="2025"
START="${YEAR}-03-18"
STOP="${YEAR}-03-22"
STEP="1 h"

wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

sed 's/\\n/\n/g' XXX | grep -A2 "${YEAR}-.* 359\.9" | grep -B1 "${YEAR}-.* 0\.0" | grep -A2 "${YEAR}-.* 359\.9" >eqx_march_hourly.txt

START="${YEAR}-Mar-20 09:00"
STOP="${YEAR}-Mar-20 10:00"
STEP="1 m"

wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

sed 's/\\n/\n/g' XXX | grep -A2 "${YEAR}-.* 359\.99" | grep -B1 "${YEAR}-.* 0\.00" | grep -A2 "${YEAR}-.* 359\.99" >eqx_march_minute.txt

START="${YEAR}-Mar-20 09:01"
STOP="${YEAR}-Mar-20 09:02"
STEP="60"

wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

sed 's/\\n/\n/g' XXX | grep -A2 "${YEAR}-.* 359\.999" | grep -B1 "${YEAR}-.* 0\.000" | grep -A2 "${YEAR}-.* 359\.999" >eqx_march_second.txt

rm XXX
