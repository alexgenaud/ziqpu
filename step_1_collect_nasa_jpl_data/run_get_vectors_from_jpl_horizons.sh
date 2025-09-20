# Collect heliocentric (Sun centered 500@10)
# vectors (x, y, z) in ICRF reference frame (approximately J2000)
# on the ECLIPTIC plane

START="2025-01-01"
STOP="2026-01-01"
STEP="1 h"

# Vectors centered on the Sun (10)
CENTER="500@10"

# PLANET (aka COMMAND):
# 199 Mercury, 299 Venus, 399 Earth, 499 Mars, 599 Jupiter, 699 Saturn
echo "Collect helio vectors for Planets (neither Sun nor Moon) hourly..."
for PLANET in 199 299 399 499 599 699; do
  echo "... $PLANET ..."
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&TABLE_TYPE=VECTORS&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&OUT_UNITS=KM-S&VEC_CORR=NONE&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX >2025/helio_${PLANET}_hourly.txt
  rm XXX
done

# Lunar vectors centered on the Earth (399)
CENTER="500@399"

# PLANET (aka COMMAND) 301 = Moon
# PLANET=301
# wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&TABLE_TYPE=VECTORS&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&OUT_UNITS=KM-S&VEC_CORR=NONE&CSV_FORMAT=YES"
# sed 's/\\n/\n/g' XXX > 2025/geo_${PLANET}_hourly.txt
# rm XXX

# Get all (but Earth) geocentric vectors for testing
echo "Collect geocentric vectors for Planets and Moon (not Earth) hourly..."
for PLANET in 10 199 299 301 499 599 699; do
  echo "... $PLANET ..."
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&TABLE_TYPE=VECTORS&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&OUT_UNITS=KM-S&VEC_CORR=NONE&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX >2025/geo_${PLANET}_hourly.txt
  rm XXX
done

# Get all (but Earth) geocentric observations (such as ap. mag. and phase)
echo "Collect observations for Planets and Moon (not Earth) hourly..."
for PLANET in 10 199 299 301 499 599 699; do
  echo "... $PLANET ..."
  wget -q -O XXX "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=${PLANET}&CENTER=${CENTER}&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START}%27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=9&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"
  sed 's/\\n/\n/g' XXX >2025/observe_${PLANET}_hourly.txt
  rm XXX
done

echo Done

#
# Consider QUANTITIES=1,9 or QUANTITIES=4,9 to get more info like:
#
# QUANTITIES  Data included
#     1           RA, DEC, range
#     4           AZ/EL, airmass, range
#     9           Mag, illumination, phase angle
