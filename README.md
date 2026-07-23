# Ziqpu — Ecliptic Ephemeris

![Ziqpu logo](logo/ziqpu.png "Ziqpu - Ecliptic Ephemeris logo")

*Ziqpu stars were the culminating stars Babylonian astronomers used to tell
time at night. This project is a modern ephemeris backbone for the same sky.*

## Goal

Highly accurate geocentric positions and naked-eye observability of the
classical planets, Sun, and Moon, across thousands of years past and future —
enough to reconstruct an **ideal Babylonian luni-solar calendar** (months
beginning at first evening crescent, computed for Babylon) and compare it
against the **actual recorded calendar** from cuneiform sources, where weather
and human practice made real month-starts deviate from the astronomical ideal.
Along the way: equinoxes and solstices, lunar phases, eclipses, sunrise/sunset,
elongations, and crescent-visibility estimates, forming a celestial backbone
against which historical chronology can be correlated.

## Conventions (declared once, used everywhere)

- **Time**: stored in **TDB** (Julian Date, `jdtdb`); TT ≈ TDB at our
  precision. UT/local time is *derived* via an explicit ΔT model at
  presentation; UTC never stored. → [docs/TIMESCALES.md](docs/TIMESCALES.md)
- **Years**: astronomical numbering (1 BC = year 0; 747 BC = −746); Julian Day
  is the primary key; calendar strings are decoration.
  → [docs/CALENDARS.md](docs/CALENDARS.md)
- **Calendar**: Julian through 1582-Oct-04, Gregorian from 1582-Oct-15.
- **Frames**: vectors in ICRF, ecliptic plane; seasonal/zodiacal longitudes on
  the ecliptic **of date**; centers named by Horizons code (`500@10` Sun
  body center, `500@399` geocenter); visibility work is topocentric Babylon
  (32.54° N, 44.42° E).
- **Precision**: full model precision stored; every historical claim published
  with its ΔT uncertainty. → [docs/PRECISION.md](docs/PRECISION.md)

## Pipeline

1. **[step_1_collect_data](step_1_collect_data/)** — harvest from JPL Horizons
   (shell + curl/wget). Query cookbook: [docs/HORIZONS.md](docs/HORIZONS.md).
2. **[step_2_massage_data](step_2_massage_data/)** — parse raw responses into
   clean JSON keyed on `jdtdb`.
3. *(planned)* **step_3** — events and calendar: phases, crossings, eclipses,
   sunset/sunrise, crescent visibility (Yallop/Odeh criteria), ideal-vs-actual
   Babylonian months. Primary computation moving to a local Skyfield/DE441
   pipeline with Horizons as cross-check.

## Data inventory

| dataset | coverage | timescale | status |
|---------|----------|-----------|--------|
| `step_1_collect_data/eqx_sol/` | equinoxes & solstices, 5000 BC – AD 5000, complete | **UT** (legacy) | keep; superseded-in-place by future TT collection ([datasheet](step_1_collect_data/eqx_sol/DATASHEET.md)) |
| `step_2_massage_data/2025/helio_*, geo_*` | hourly vectors, 2025 | **TDB** | canonical; validation corpus ([datasheet](step_2_massage_data/2025/DATASHEET.md)) |
| `step_2_massage_data/2025/observe_*` | hourly magnitudes, 2025 | UT labels | partial; lacks crescent quantities |

Each dataset directory carries a `DATASHEET.md` (what the data actually is)
and a `MANIFEST.sha256` (integrity).

**Repository policy**: code, docs, datasheets, and manifests are committed;
bulk data and binary assets are not — they live under `untracked/` (only its
README is tracked; see [untracked/README.md](untracked/README.md)), are
regenerable from the scripts plus the provenance in each datasheet, and are
archived compressed with checksums in `untracked/archives/`.

## Documentation

- **[docs/GOTCHAS.md](docs/GOTCHAS.md)** — every trap, numbered G1–G33:
  BC year numbering, UT vs TT, calendar switches, body centers vs barycenters,
  geometric vs apparent positions, stars and the sidereal frame, Horizons API
  quirks. Read this first.
- [docs/TIMESCALES.md](docs/TIMESCALES.md) · [docs/CALENDARS.md](docs/CALENDARS.md)
  · [docs/PRECISION.md](docs/PRECISION.md) · [docs/HORIZONS.md](docs/HORIZONS.md)
  · [docs/SIDEREAL.md](docs/SIDEREAL.md) — the fixed-star zodiac and the
  82-lunarpada specification
- [docs/notebook/](docs/notebook/) — the original lab notes, preserved
  verbatim, including conclusions later corrected.
- [Logo adapted from Monroe, M. Willis, 2022](logo/README.md)

## License

See [LICENSE](LICENSE) and, for the discerning, [LIMERICK](LIMERICK).
