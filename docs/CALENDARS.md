# Calendars and Year Numbering

## The convention: astronomical years, Julian Day keys

All machine-readable data in ziqpu uses **astronomical year numbering** and is
keyed on **Julian Date (TDB)**. Calendar strings are human decoration.

Astronomical numbering is BC/AD counting with a year 0 inserted:

    ... −2 = 3 BC,  −1 = 2 BC,  0 = 1 BC,  1 = AD 1,  2 = AD 2 ...

so a BC year converts as: astronomical = −(BC − 1). 747 BC = −746.
This is what ISO 8601, JPL's date/JD converter, Skyfield, and astropy all use.
In prose, give both: "747 BC (−746)".

## What — and when — was 1 BC?

1 BC is the year immediately before AD 1 (there is no year zero in historical
counting). In our coordinate system it is **astronomical year 0**, running in
the proleptic Julian calendar from JD 1721057.5 (Jan 1, 00:00) to JD 1721423.5
— 366 days: year 0 is divisible by 4, so it is a leap year, which is also why
the no-year-zero and signed conventions have *different leap years* in the BC
range (another reason never to mix them). Verified against Horizons: JD
1721057.5 returns the label `b0001-Jan-01 00:00`.

Two caveats that keep this honest:

- That definition is *proleptic* Julian. Historically, Rome applied leap years
  erratically between 45 BC and AD 8, and no Julian calendar existed before
  45 BC. Our dates are coordinates, not lived Roman dates.
- In the proleptic *Gregorian* calendar the same instants get labels a few days
  different (2 days at AD 1, growing into the past). We do not use proleptic
  Gregorian anywhere.

## Horizons' labels

| meaning   | Horizons input | Horizons output | astronomical |
|-----------|---------------|-----------------|--------------|
| 747 BC    | `747BC`       | `b0747`         | −746         |
| 1 BC      | `1BC`         | `b0001`         | 0            |
| AD 333    | `333AD`       | `0333`          | 333          |
| AD 2025   | `2025`        | `2025`          | 2025         |

Legacy warning: the eqx_sol data files carry `-NNNN` labels produced by
replacing `b` with `-`, so their `-4500` means 4500 BC = astronomical −4499.
See gotcha G2 and the eqx_sol DATASHEET.

## Julian vs Gregorian

Horizons (and this project) use the historical mixed calendar: **Julian through
1582-Oct-04, Gregorian from 1582-Oct-15** (the ten skipped days are the reform
itself). Everything BC is Julian. Because the Julian year (365.25 d) exceeds
the tropical year by ~11 min, seasonal events drift ~1 day per 128 years
against Julian dates — the 4500 BC March equinox falls on Julian "April 26",
and before ~1300 BC the December solstice lands in January (gotcha G4).

## Julian Day numbers

JD 0.0 = noon, Jan 1, 4713 BC (−4712) proleptic Julian. The JD is a continuous
count of days; a JD in TDB is a continuous count of exactly-86400-SI-second
days, immune to every calendar and rotation issue above. Useful anchors:

| instant                              | JD          |
|--------------------------------------|-------------|
| −4712 Jan 1 12:00 (epoch)            | 0.0         |
| 0 (1 BC) Jan 1 00:00                 | 1721057.5   |
| 1 (AD 1) Jan 1 00:00                 | 1721423.5   |
| 2000 Jan 1 12:00 TT (J2000.0)        | 2451545.0   |

The integer JDN (a JD at noon) names a whole day; for the Babylonian calendar
layer, a calendar day will be keyed by the JDN of the local evening (sunset)
that begins it, since Babylonian days run sunset-to-sunset.

Raw-data format guidance: two-part JD (integer day + fraction) is compact *and*
greppable by day; calendar-date columns may be kept alongside for convenience
but are never authoritative.
