# Equinoxes and Solstices

As of 24 Sept after the equinox, 3 Tishrei before the harvest moon, 2025

## Summary

Equinoxes and solstices are defined by the Sun’s apparent geocentric ecliptic longitude
crossing cardinal points: 0° (vernal equinox), 90° (summer solstice),
180° (autumnal equinox), and 270° (winter solstice).

## Method

Query JPL Horizons ephemeris system for the Sun’s apparent ecliptic longitude as
seen from Earth’s center.

Utilize Horizons’ corrections for light-time delay, stellar aberration, and
gravitational deflection to obtain accurate apparent positions.

Working in the J2000 reference frame but applying the true ecliptic of date,
which accounts for Earth’s precession and nutation.

Refine time sampling around each solar longitude crossing to pinpoint
the exact date and time of equinoxes and solstices.

Handle date notation differences and limitations in Horizons (no year zero,
BC/AD suffixes, Julian date input) to extend the dataset from 4800 BCE to 2100 CE.

Cleaning and standardizing output data for analysis.

## JPL Horizons Parameters

    COMMAND 10 (Sun center)
    CENTER 500@399 (Earth geocenter)
    EPHEM_TYPE OBSERVER (apparent positions as seen from observer)
    QUANTITIES 31 (apparent ecliptic longitude and latitude)
    REF_SYSTEM J2000 (International Celestial Reference Frame)
    REF_PLANE ECLIPTIC (use true ecliptic of date)
    START_TIME / STOP_TIME ISO-like dates or Julian Day numbers (JD)
    STEP_SIZE Variable: '1 d', '1 h', '1 m', or fractional minutes; no 1 s step allowed, so half-second resolution done via interpolation or narrower windows

## Date Handling

- Input year format examples: 747BC, 1BC, 1AD, 2025
- Output year format examples: b0747, b0001, 0001, 2025
- No year 0: 1BC (b0001) is immediately followed by 1AD (0001)

- Input year format: ISO dates with spaces and sometimes TLA months such as Apr are accepted
- Output year format: ISO dates with spaces and TLA month such as 2025-Mar-21 12:34:56.5000

## Possible Improvements

- Automate sub-second interpolation: After coarse searches, use polynomial fits or
  numerical root-finding on longitude vs. time to find exact crossing times more
  precisely than the Horizons step size allows.
- Use longer or higher-resolution ephemerides (e.g., DE440 or later) if supported by
  Horizons for improved long-term accuracy.
- Incorporate terrestrial time (TT) and convert to Universal Time (UT1) with modern
  Earth rotation models to improve precision in civil time conversions.
- For ancient dates, consider complementary models or corrections for Earth orientation
  and precession/nutation uncertainties.
- Cross-validate results with independent ephemeris tools or historical astronomical
  records for critical epochs.

## Earlier notes

I intend to provide the precise dates and geocentric solar ecliptic longitudes corresponding
to the equinoxes and solstices (i.e., solar longitudes of 0°, 90°, 180°, and 270°)
over a wide historical timespan using NSA JPL Horizons observation data.
I've parsed patchy data sets from 4800 BCE through 2100 CE.

The angle extracted is the apparent geocentric ecliptic longitude (ObsEcLon) of the
Sun center as seen from Earth's center, corrected for light-time, stellar aberration,
and gravitational deflection — all inherent in the observer ephemeris from Horizons.
The ecliptic longitude is measured in the J2000 reference frame
(exactly equivalent to ICRF in practice) but refers to the
true ecliptic of date (i.e., includes nutation and precession corrections). This
angle is used to define the true equinoxes and solstices, based on when the
apparent longitude of the Sun crosses the cardinal points (0°, 90°, 180°, and
270°).

Querying JPL Horizons for equinoxes and solstices for all years from 1000 through 2100
was straight forward. I looped
through all years, narrowing in by day, hour, minute, second. The queries can be
looped with the following but will require some manual patching:

    for X in $(seq 1000 2100); do bash run_get_eqx_sol.sh $X; done > modern.txt

After figuring out how to input earlier years, I ran the following separately:

    for X in $(seq 1 999); do bash run_get_eqx_sol.sh ${X}AD; done > ad.txt

Horizons has no year 0 and expects input years before 0 with a "`BC`" suffix yet
returns the same years with a "`b`" prefix. For years between 0 and 1000, an "`AD`"
suffix can be used yet the same years are returned as four digit 0 padded years.

    for X in $(seq 999 1); do bash run_get_eqx_sol.sh ${X}BC; done > bc.txt

It is also possible to query Horizons with JD day numbers but Horizons
returns ISO-like dates anyway. The gist of all params are as follows:

    CENTER:     500@399 (geocentric, from Earth center)
    COMMAND:    10 (object Sun center)
    EPHEM_TYPE: OBSERVER
    QUANTITIES: 31 (apparent ecl. long, lat. of the Sun)
    REF_SYSTEM: J2000 (ICRF made no difference over 6000 years)
    REF_PLANE:  ECLIPTIC

The December solstice was in January before the 14th century BC.
Solstices straddling two Julian years threw a wrench in my scripts.
I thus wrote a specific solstice gathering script for
1330 BC to 1075 BC.

    for X in $(seq 1330 1075); do bash run_get_sol_bc.sh ${X}BC; done > bc.txt

Thus far we've collected:

       4730 - 4000 BC
       1999 - 0001 BC
    AD 0001 - 2100

## Data cleanup

    cat DATA.txt | sed -e "s:^  *::" -e "s:^b:-:" -e "s:, , ::" -e "s:,$::" \
    -e 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' \
    | sort | uniq > x && mv x DATA.txt

Or possibly 'sort -n' for BC dates -5000 -4999 ... -0001

## Overnight run on a Mac laptop

    caffeinate -i bash -c 'for X in $(seq 4730 -1 4721); do bash run_get_eqx_sol.sh "${X}BC"; done' > bc.txt 2> err.txt &

## For the years 1000 through 2100

For the years 1000 through 2100, I queried JPL Horizons daily.
Then narrowed hourly, between minutes, down to half seconds data where
ecliptic longitude were 359.9-0.1, 89.9-90.1, 179.9-180.1, 269.9-270.1.

Example query:

    "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27${START} %27&STOP_TIME=%27${STOP}%27&STEP_SIZE=%27${STEP}%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

Where:

    `%27` is a single quote (') url encoded.
    $START and $STOP are ISO dates (or for example '2025-Jan-01' to potentially '2025-Dec-31 23:59:59.9999').
    $STEP are '1 d', '1 h', '1 m', or interval divisions '60' as '1 s' is not allowed.

## For the years 9999 BC through AD 999

JPL Horizons accepts `1AD`, `333AD` years and returns `0001`, and `0333` respectively.
There is no year 0 nor negative (astronomical) years.
Horizons accepts `1BC` and `4713BC` and returns `b0001` and `b4713` respectively.

## Julian day numbers

JPL Horizons can be queried with JD START and STOP times but the results
tend to be semi-ISO dates anyway.

Example query:

    "https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&START_TIME=%27JD%200%27&STOP_TIME=%27JD%20999%27&STEP_SIZE=%271%20d%27&QUANTITIES=31&REF_SYSTEM=J2000&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES"

Where:

    Values and formats are similar to earlier more precise queries.
    $START and $STOP are both Julian dates such as 'JD 0' (as `%27JD%200%27`).
    $STEP_SIZE was only at daily precision '1 d' (as `%271%20d%27`).

## Concerns

These are unresolved questions, limitations, or sources of ambiguity when working with
historical ephemeris data from JPL Horizons:

- Uncertainty about timescales in early epochs:
  It is not immediately clear if results are in UTC, TT, or TDB, especially for ancient
  dates. This is critical when sub-second accuracy is needed — e.g., equinoxes near
  midnight UTC.

- Calendar system transition:
  JPL Horizons internally switches after 1582-10-04 from the Julian calendar to the
  Gregorian calendar on 1582-10-15, following the historical calendar reform. Dates
  before this are Julian, even if formatted like ISO (e.g., 1582-Oct-04 is Julian,
  1582-Oct-15 is Gregorian). This can introduce confusion when comparing to civil or
  proleptic Gregorian calendars.

- Uncertainty in ΔT:
  The further back in time one goes, the more uncertain the value of ΔT (difference
  between Terrestrial Time and Universal Time), which can introduce errors on the order
  of minutes or more in epochs earlier than ~500 CE. JPL incorporates ΔT estimates, but
  these are model-based for ancient dates.

## Notes

These are confirmed behaviors and technical details of JPL Horizons as relevant to
solar longitude queries:

- Time scale behavior:

Output timestamps (ISO-like) are in UTC by default.
Internal ephemeris calculations use TDB (Barycentric Dynamical Time).
Julian Date (JDTDB) values in output are in TDB.
We may request times in TDB, TT, or other systems by using the TIME_ZONE parameter.
I need to sort out the date input or consistent conversion between JD and ISO-like
dates.

- Ephemeris model:

Horizons uses the DE440/441 planetary ephemeris, which provides high-precision
positions over ±13,000 years. However, uncertainty increases with historical depth —
particularly due to ΔT, long-term planetary perturbations, and precession/nutation
modeling.

- Apparent solar longitude:

ObsEcLon includes corrections for light-time, stellar aberration, gravitational
deflection, nutation, and precession — making it suitable for precise equinox/solstice
determination as seen from Earth.

## Discussion of tropical year

### Northward (ancient April/March) equinox

Using above collected data and converting dates:

    https://ssd.jpl.nasa.gov/tools/jdc/#/cd

    Calendar Date/Time: -4499-01-01 00:00:00 submitted
    Calendar Date/Time: -4499--1 00:00:00 Tuesday
    Julian Day Number: 77798.5

    Calendar Date/Time: -0499-01-01 00:00:00 submitted
    Calendar Date/Time: -499--1 00:00:00 Thursday
    Julian Day Number: 1538798.5

Which are exactly (365 x 4000 + 1000 leap) days apart, thus demonstrating
that both JPL Horizons and the JPL date/JD conversion tool use Julian dates
(probably before 1580). These are not UTC but rather TT (or TDB) continuous
count of exactly 86400 SI second days.

Comparing the Northward (April/March) equinox over 4000 years is more interesting:

    4500 BC -4499-04-26 19:59:16.65, 0, -0.0000724 = JD 77914.3328316
            Friday, rounding up to nearest second (:17) 77914.3328356

    0500 BC -499-03-26 18:38:51.71, 0, -0.0000762 = JD 1538883.2769874
         Thursday, rounding up to nearest second (:52) 1538883.2769907

with a difference of 1460968.9441558 Julian days. Dividing by 4000 years gives
us an average northward equinox tropical year of 365.2422360389 days
(365 days, 5 hours, 48 minutes, 49.2 seconds).

Whether this is TT or TDB adjusted is not clear but
the +/- 0.00016 SI second difference is negligible
for our linear math. The difference does not
accumulate but rather oscilates around 0 +/1 2 ms.

On the other hand, UTC adds or subtracts an SI second every few years to keep
the day synchronized with the average solar noon as seen from Earth. We can
predict the tendency in a human lifetime but over millenia the uncertainty is
greater than the known predictable deviation.

We can be certain that ancient days were shorter and future days will be longer.
Each day was 86399 seconds before 5000 BC and will be more than 86401 seconds
after AD 5000.

We believe solar noon (12:00 UTC) was 08:00 TT/TDB in 5000 BC.
Solar noon was (10:00 TT/TDB) in AD 1.
Solar noon was exactly (12:00:00.0000 TT) on 1 January 1972
but then we immediately added a leap second in June and December 1972
and half a minute in the many years since then.
We really don't know about the future.
Perhaps solar noon will be 15:00 or 23:00 or "the next calendar day" in AD 5000.
