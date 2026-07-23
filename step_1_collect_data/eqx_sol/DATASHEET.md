# Datasheet: eqx_sol — Equinoxes & Solstices, 5000 BC – AD 5000

**Status**: legacy/reference. Timestamps are **UT**, not TT/TDB — see
"Time scale" below. Retained both as a usable UT-flavored dataset and because
its difference against a future TT re-collection *is* Horizons' ΔT curve.

## Files

Data files live outside git in `untracked/data/eqx_sol/` (see
`untracked/README.md`); this directory keeps the datasheet and manifest.

- `eqx-sol-b5000-b0001.txt` — 5000 BC … 1 BC (astronomical −4999 … 0)
- `eqx-sol-c0001-5000.txt` — AD 1 … AD 5000
- `MANIFEST.sha256` — integrity checksums (here, tracked)
- Coverage: complete; 8 lines/year (2 bracket lines × 4 cardinal events).

## What each line is

    -4500-04-26 19:59:16.500, 359.9999984, -0.0000724

columns: date-time, apparent geocentric ecliptic longitude of the Sun (deg,
**of date**), apparent ecliptic latitude (deg). Lines come in **bracket
pairs**: the last sample below a cardinal longitude (0°/90°/180°/270°) and the
first above it, 0.5 s apart. The event lies between them — interpolate; never
cite one line as "the" event time.

## Conventions in THIS dataset (differ from project standard!)

- **Year labels**: `-NNNN` means **NNNN BC** (produced by rewriting Horizons'
  `bNNNN`). This is NOT astronomical numbering: the line above is 4500 BC
  = astronomical **−4499**. Off-by-one guaranteed if fed to standard tools
  as-is. (Gotcha G2.)
- **Time scale**: **UT** (Horizons OBSERVER default), i.e. Earth-rotation time
  with Horizons' ΔT model baked in. Offset from TT: +69.2 s at 2025, ~+35 h at
  4500 BC (both measured 2026-07-21; gotcha G7). Sub-second *precision* is
  bracket precision within the model; historical *accuracy* is minutes (1000
  BC) to hours (5000 BC) — see [docs/PRECISION.md](../../docs/PRECISION.md).
- **Calendar**: Julian ≤ 1582-Oct-04, Gregorian after; BC-era dates drift
  seasonally (March equinox on Julian "Apr 26" at 4500 BC; December solstice
  in January before ~1300 BC).

## Provenance

- Source: JPL Horizons API, `COMMAND=10, CENTER=500@399, EPHEM_TYPE=OBSERVER,
  QUANTITIES=31, REF_SYSTEM=ICRF/J2000, REF_PLANE=ECLIPTIC` (ephemeris DE441).
- Method: per-year progressive refinement (daily → hourly → minute →
  sub-second interval division) by `../run_get_eqx_sol.sh`, with
  `../run_get_sol_bc.sh` for the year-straddling solstices of 1330–1075 BC;
  collected in overnight batches, 2025.
- Cleanup applied: `\n` unwrap, `b` → `-` year rewrite, month names → numbers,
  sort/uniq. Raw response headers were not retained (gotcha G24 — don't repeat).

## Known issues

- The two conventions above are the dataset's chief hazards; both are by-design
  legacy, documented here rather than rewritten, to keep bytes matching the
  MANIFEST.
- A `sed 360.0000000 → 359.9999999` patch was applied during collection to
  handle longitude wrap (gotcha G20); at most it perturbs a bracket edge by
  one step.

## Superseding plan

Re-collect (or compute via Skyfield/DE441) with `TIME_TYPE=TT`, astronomical
year labels, JD keys, and interpolated event instants with stated σ. Then this
dataset minus the new one = Horizons ΔT over 10 millennia, a derived product
worth publishing on its own.
