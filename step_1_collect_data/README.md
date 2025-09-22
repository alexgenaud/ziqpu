# Data collection

Collected classical planet vectors, equinoxes, and solstices

## Precision

[Detailed discussion of precision](README_PRECISION.md)

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

We gather precise data on the timing and solar positions of equinoxes and solstices.
These are key points in the year when the Sun crosses specific angles along the
ecliptic (0°, 90°, 180°, and 270°). This data spans a huge historical range, from
5000 BCE through 5000 CE (currently patchy), by querying the JPL Horizons system.

We pull the apparent ecliptic longitude of the Sun as seen from the Earth's center,
taking into account real-world effects like light travel time, aberration, and
gravitational bending of light. The longitude is measured relative to a fixed celestial
reference system (J2000, although ICRF is effectively equivalent at our precision) but
corrected for the Earth's changing orientation (nutation and precession) so it
represents the "true" solar position at the time.

We automate the data retrieval for all years with increasingly fine time steps—from
daily down to half second (around the moments when the Sun’s longitude approaches those
key angles), thereby zeroing in on exact equinox and solstice times.
For ancient and early historic years (-9999 through -1 BC and AD 1 through 999),
we adapted the queries to handle the quirks of how Horizons deals with BC/AD notation
and the lack of an astronomical year zero, sometimes relying on Julian day numbers
and daily resolution.

Finally, we automatically and manually cleanup of the raw data files, including
standardizing date formats and fixing quirks in how years before AD 1 were labeled.

Link: Detailed discussion of [equinoxes and solstice](README_EQUINOX.md) data collection.
