# Data collection

As of 21 Sep (end of Elul) 2025

## Classical planet vectors

I've collected vector and observational data from JPL Horizons for heliocentric and geocentric presentation.

These are high precision hourly positions of the classical planets for every hour of 2025.
These will be used to test more sparse and less precise data for presentation.

It is assumed that daily Planet angles with 3 decimal degrees or 5 decimal radians should be sufficient to estimate all positions at any second and display smooth animations over thousands of pixels (8K).

I've collected vector positions (x, y, z) for Mercury, Venus, Earth, Mars, Jupiter, Saturn with the center of the Sun as origin (heliocentric) from JPL Horizons.

    COMMAND:    (199 Mercury, 299 Venus, 399 Earth, 499 Mars, 599 Jupiter, 699 Saturn)
    CENTER:     500@10 (center of the Sun as origin, heliocentric)
    TABLE_TYPE: VECTORS
    STEP_SIZE:  1 h (as `%271%20h%27`)
    REF_SYSTEM: ICRF
    REF_PLANE:  ECLIPTIC
    OUT_UNITS:  KM-S
    VEC_CORR:   NONE

I've collected vector positions (x, y, z) and observations for the Sun, Mercury, Venus, Moon, Mars, Jupiter, Saturn with the center of the Earth as origin (geocentric).
The JPL Horizons params for geocentric vectors are similar to heliocentric vectors above except for:

    COMMAND:    (301 Moon and all Planets as before except Earth)
    CENTER:     500@10 (center of the Earth as origin, geocentric)

The observations require the following params:

    EPHEM_TYPE: OBSERVER
    QUANTITIES: 9 (Right ascension, declination, range, etc)

Horizons outputs vectors using the TDB (Barycentric Dynamical Time) internally.

## Equinoxes and Solstices

To determine the precise dates and geocentric solar ecliptic longitudes corresponding
to the equinoxes and solstices (i.e., solar longitudes of 0°, 90°, 180°, and 270°) over
a wide historical timespan, specifically JD 0, 1 BCE (astronomical year 0), AD 1, and
every year from 1000 through 2100 CE, using NASA JPL Horizons data.

To determine the dates and apparent geocentric solar ecliptic longitudes of
equinoxes and solstices (corresponding to 0°, 90°, 180°, and 270°) for round
epochs (JD 0, 1 BCE, AD 1) and for all years from 1000 to 2100 CE, using data
from NASA JPL Horizons.

The angle extracted is the apparent geocentric ecliptic longitude (ObsEcLon) of the
Sun center as seen from Earth's center, corrected for light-time, stellar aberration,
and gravitational deflection — all inherent in the observer ephemeris from Horizons.
The ecliptic longitude is measured in the J2000 reference frame but refers to the
true ecliptic of date (i.e., includes nutation and precession corrections). This angle
is used to define the true equinoxes and solstices, based on when the apparent
longitude of the Sun crosses the cardinal points (0°, 90°, 180°, and 270°).

Queried JPL Horizons for equinoxes and solstices for all year 1000-2100. I looped
through all years, narrowing in by day, hour, minute, second. The queries can be
looped with the following but will require some manual patching:

    for X in $(seq 1000 2100); do
        bash run_get_eqx_sol.sh $X;
     done > eqx_sol/1000-2100.txt

I sparsely sampled some years before 1000 with vague precision.
All JPL Horizons calls had the following parameters in common:

    CENTER:     500@399 (geocentric, from Earth center)
    COMMAND:    10 (object Sun center)
    EPHEM_TYPE: OBSERVER
    QUANTITIES: 31 (apparent ecl. long, lat. of the Sun)
    REF_SYSTEM: J2000 (ICRF made no difference over 6000 years)
    REF_PLANE:  ECLIPTIC

### For the years 1000 through 2100

For the years 1000 through 2100, I queried JPL Horizons daily.
Then narrowed hourly, between minutes, down to half seconds data where
ecliptic longitude were 359.9-0.1, 89.9-90.1, 179.9-180.1, 269.9-270.1.

Example query:

    "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START} %27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

Where:

    `%27` is a single quote (') url encoded.
    $START and $STOP are ISO dates (or for example '2025-Jan-01' to potentially '2025-Dec-31 23:59:59.9999').
    $STEP are '1 d', '1 h', '1 m', or interval divisions '60' as '1 s' is not allowed.

### Around non-extant year 0, b0001 (1 BC) to 00001 (AD 1)

It seems as though JPL Horizons does not accept ISO-like dates before the year 1000 but
does accept JD (Julian day numbers). Yet, JPL Horizons does return ISO-like dates less
than 1000, including b4713 (4713 BC).

As of 21 Sep (end of Elul) 2025, I queried several numerically interesting years
(JD 0, 1 BC, and AD 1) but with only daily precision (not hourly and certainly not
to the second). I manually found the solar quarters around 0°, 90°, 180°, and 270°
Sun-Earth ecliptic longitude.

Example query:

    "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27JD%200%27&STOP_TIME=%27JD%20999%27&STEP_SIZE=%271%20d%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

Where:

    Values and formats are similar to earlier more precise queries.
    $START and $STOP are both Julian dates such as 'JD 0' (as `%27JD%200%27`).
    $STEP_SIZE was only at daily precision '1 d' (as `%271%20d%27`).

### Concerns

These are unresolved questions, limitations, or sources of ambiguity when working with historical ephemeris data from JPL Horizons:

- Precision before AD 1000 is limited:
  Horizons returns data for years earlier than 1000 CE (including BCE) but differences in input and output date formats makes it difficult to narrow time resolution (for daily to sub-seconds).

- Ambiguity in time representation:
  It's not always clear which time standard applies to date strings. Horizons allows input in Julian Day (JD) or in ISO-like calendar dates, including BCE years (formatted like b0001). However, ISO-like timestamps may look like UTC but correspond to different internal scales.

- Uncertainty about timescales in early epochs:
  It is not immediately clear if results are in UTC, TT, or TDB, especially for ancient dates. This is critical when sub-second accuracy is needed — e.g., equinoxes near midnight UTC.

- Calendar system transition:
  JPL Horizons internally switches from the Julian calendar to the Gregorian calendar on 1582-10-15, following the historical calendar reform. Dates before this are Julian, even if formatted like ISO (e.g., 1582-Oct-04 is Julian, 1582-Oct-15 is Gregorian). This can introduce confusion when comparing to civil or proleptic Gregorian calendars.

- Uncertainty in ΔT:
  The further back in time one goes, the more uncertain the value of ΔT (difference between Terrestrial Time and Universal Time), which can introduce errors on the order of minutes or more in epochs earlier than ~500 CE. JPL incorporates ΔT estimates, but these are model-based for ancient dates.

### Notes

These are confirmed behaviors and technical details of JPL Horizons as relevant to solar longitude queries:

- Time scale behavior:

Output timestamps (ISO-like) are in UTC by default.
Internal ephemeris calculations use TDB (Barycentric Dynamical Time).
Julian Date (JDTDB) values in output are in TDB.
We may request times in TDB, TT, or other systems by using the TIME_ZONE parameter.
I need to sort out the date input or consistent conversion between JD and ISO-like dates.

- Ephemeris model:

Horizons uses the DE440/441 planetary ephemeris, which provides high-precision positions over ±13,000 years. However, uncertainty increases with historical depth — particularly due to ΔT, long-term planetary perturbations, and precession/nutation modeling.

- Apparent solar longitude:

ObsEcLon includes corrections for light-time, stellar aberration, gravitational deflection, nutation, and precession — making it suitable for precise equinox/solstice determination as seen from Earth.

### Data cleanup

    X=eqx-sol-b0001-0001.txt; cat $X |  sed -e "s:^  *::" \
    -e "s:Jan:01:" -e "s:Feb:02:" -e "s:Mar:03:" -e "s:Apr:04:" \
    -e "s:May:05:" -e "s:Jun:06:" -e "s:Jul:07:" -e "s:Aug:08:" \
    -e "s:Sep:09:" -e "s:Oct:10:" -e "s:Nov:11:" -e "s:Dec:12:" \
    -e "s:, , ,:,:" -e "s:,$::" > x && mv x $X
