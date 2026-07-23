# JPL Horizons Cookbook

Hard-won operational knowledge for the Horizons API
(`https://ssd.jpl.nasa.gov/api/horizons.api`). Everything here was learned by
collision (see [GOTCHAS.md](GOTCHAS.md)) or verified live on 2026-07-21.

## Parameters we use

| param        | values we use                | notes |
|--------------|------------------------------|-------|
| `COMMAND`    | 10 Sun, 199 Mercury, 299 Venus, 399 Earth, 301 Moon, 499 Mars, 599 Jupiter, 699 Saturn | body centers |
| `CENTER`     | `500@10` Sun-center, `500@399` geocenter, `coord@399` + `SITE_COORD` topocentric | `@0` would be the solar-system barycenter — a *different point* than `@10` (up to ~2 solar radii) |
| `EPHEM_TYPE` | `VECTORS` or `OBSERVER`      | vectors → JDTDB; observer → UT dates **unless** `TIME_TYPE=TT` |
| `TIME_TYPE`  | `TT`                         | **verified working**; use for all new observer collections |
| `QUANTITIES` | see table below              | observer only |
| `REF_SYSTEM` | `ICRF` (≡ `J2000` to ~17 mas) | |
| `REF_PLANE`  | `ECLIPTIC`                   | observer QUANTITIES=31 is ecliptic **of date** |
| `VEC_CORR`   | `NONE` (geometric)           | vectors only |
| `OUT_UNITS`  | `KM-S`                       | vectors only |
| `STEP_SIZE`  | `'1 d'`, `'1 h'`, `'1 m'`, or bare integer N = divide interval into N steps | **no seconds unit**; sub-second via interval division |
| `TIME_DIGITS`| `FRACSEC`                    | fractional-second output |
| `CSV_FORMAT` | `YES`                        | see parsing notes |

Topocentric Babylon: `CENTER='coord@399'&COORD_TYPE=GEODETIC&SITE_COORD='44.42,32.54,0'`
(east longitude, latitude, km altitude). Required for crescent-visibility work
(lunar parallax ~1°, gotcha G15).

### OBSERVER quantities actually needed

| # | contents |
|---|----------|
| 1 | astrometric RA/Dec |
| 2 | apparent RA/Dec |
| 4 | apparent azimuth/elevation (topocentric visibility!) |
| 9 | visual magnitude + surface brightness (NOT illumination/phase) |
| 10 | illuminated fraction |
| 20 | range, range-rate |
| 23 | sun-observer-target elongation |
| 24 | sun-target-observer phase angle |
| 31 | observer ecliptic longitude/latitude (of date) |

Crescent work: `QUANTITIES='4,10,23,24'` topocentric. Equinox work: `31`
geocentric.

## Date input/output

- Input years: `747BC`, `1BC`, `333AD`, `2025`. No year 0, no signed years.
- Output years: `b0747`, `0001`, `2025`. Mapping to astronomical numbering in
  [CALENDARS.md](CALENDARS.md).
- Calendar is Julian ≤ 1582-Oct-04, Gregorian ≥ 1582-Oct-15, including in
  ISO-looking output.
- JD input works: `START_TIME='JD 77798.5'` — output is calendar strings anyway.
- Quote values with URL-encoded quotes: `%27...%27`.

## Output handling

- Response is JSON-wrapped text with literal `\n`: unwrap with
  `sed 's/\\n/\n/g'` (or request `format=text`).
- Data lives between `$$SOE` and `$$EOE`. **Keep the header above `$$SOE`** —
  it states time system, ephemeris (DE441), target, center (gotcha G24).
- CSV rows in observer tables include solar/lunar-presence flag columns
  (empty, `*`, `C`, `N`, `A`, `m`) after the date. Parse by header names, not
  positions (gotcha G21).
- Output limit is on the order of 90,000 lines per query.
- Sun's longitude wraps 360→0 at the March equinox: solve on unwrapped values
  (gotcha G20).

## Verified reference queries (2026-07-21)

Label of a known JD (year-numbering anchor; returns `b0001-Jan-01 00:00`):

    curl 'https://ssd.jpl.nasa.gov/api/horizons.api?COMMAND=10&CENTER=500@399&MAKE_EPHEM=YES&EPHEM_TYPE=OBSERVER&QUANTITIES=31&REF_SYSTEM=ICRF&REF_PLANE=ECLIPTIC&CSV_FORMAT=YES&START_TIME=%27JD%201721057.5%27&STOP_TIME=%27JD%201721058.5%27&STEP_SIZE=%271%20d%27'

2025 March equinox in TT (crossing 09:02–09:03, i.e. ~09:02:39 TT
= 09:01:30 UT + ΔT 69.2 s):

    curl '...same...&TIME_TYPE=TT&START_TIME=%272025-03-20%2009:00%27&STOP_TIME=%272025-03-20%2009:05%27&STEP_SIZE=%271%20m%27'

4500 BC March equinox in TT (crossing Apr 28 06–07 h TT vs Apr 26 19:59:17 UT
⇒ Horizons ΔT(−4499) ≈ 34.97 h):

    curl '...same...&TIME_TYPE=TT&START_TIME=%274500BC-04-26%27&STOP_TIME=%274500BC-04-29%27&STEP_SIZE=%271%20h%27'

## Alternative: compute locally from the same ephemeris

Horizons is an interface to DE441, not the source of truth. The `skyfield`
Python library loads the same DE441 kernel (±13,000 years) and reproduces
positions to levels far below every uncertainty in this project, with built-in
event root-finding, native TDB, topocentric sites, and no rate limits. Plan:
local Skyfield pipeline as primary, Horizons as independent cross-check
(the pristine 2025 hourly set is the validation corpus). Note Skyfield's
UT1/ΔT model for ancient epochs is configurable — set it explicitly and record
which model was used (layer 2 discipline, [TIMESCALES.md](TIMESCALES.md)).
