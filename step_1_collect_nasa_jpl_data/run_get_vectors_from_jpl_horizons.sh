# Collect heliocentric (Sun centered 500@10)
# vectors (x, y, z) in ICRF reference frame (approximately J2000)
# on the ECLIPTIC plane

START="1999-12-31"
STOP="2000-01-02"
STEP="1 h"

# Vectors centered on the Sun (10)
CENTER="500@10"

# PLANET (aka COMMAND):
# 199 Mercury, 299 Venus, 399 Earth, 499 Mars, 599 Jupiter, 699 Saturn
for PLANET in 199 299 399 499 599 699; do
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&TABLE_TYPE=VECTORS&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&OUT_UNITS=KM-S&VEC_CORR=NONE&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX >helio_${PLANET}_hourly.txt
  rm XXX
done

# Lunar vectors centered on the Earth (399)
CENTER="500@399"

# PLANET (aka COMMAND) 301 = Moon
# PLANET=301
# wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&TABLE_TYPE=VECTORS&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&OUT_UNITS=KM-S&VEC_CORR=NONE&CSV_FORMAT=YES"
# sed 's/\\n/\n/g' XXX > geo_${PLANET}_hourly.txt
# rm XXX

# Get all (but Earth) geocentric vectors for testing
for PLANET in 10 199 299 301 499 599 699; do
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&TABLE_TYPE=VECTORS&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&OUT_UNITS=KM-S&VEC_CORR=NONE&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX >geo_${PLANET}_hourly.txt
  rm XXX
done

# Get all (but Earth) geocentric observations (such as ap. mag. and phase)
for PLANET in 10 199 299 301 499 599 699; do
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=9&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX >observe_${PLANET}_hourly.txt
  rm XXX
done

exit

wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&
EPHEM_TYPE=OBSERVER&
START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&
QUANTITIES=9&
REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&
CSV_FORMAT=YES"

wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&
TABLE_TYPE=VECTORS&
START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&
REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&
OUT_UNITS=KM-S&VEC_CORR=NONE&
CSV_FORMAT=YES"

New query contains
EPHEM_TYPE=OBSERVER &
QUANTITIES=9 &

but does not contain:

OUT_UNITS=KM-S &
VEC_CORR=NONE &
