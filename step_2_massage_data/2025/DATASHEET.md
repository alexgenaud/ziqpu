# Datasheet: 2025 hourly vectors & observations (validation corpus)

**Purpose**: high-resolution modern reference year, used to validate sparser
or locally-computed data (the planned Skyfield/DE441 pipeline must reproduce
these before being trusted for ±5000 years).

## Files and semantics

Data files live outside git in `untracked/data/2025/` (see
`untracked/README.md`); this directory keeps the datasheet and manifest.

**`helio_*.json`** — Sun-body-centered (`CENTER=500@10`, *not* the solar-system
barycenter) geometric vectors (`VEC_CORR=NONE`), ICRF axes, ecliptic plane,
km & km/s, hourly for 2025. Fields: `jdtdb` (**TDB** — canonical project
timescale), `date` (TDB calendar label, decoration), `x,y,z`.
Bodies: 199, 299, 399, 499, 599, 699.

**`geo_*.json`** — same but geocentric (`CENTER=500@399`); bodies 10, 199, 299,
301, 499, 599, 699.

**`observe_*.json`** — from OBSERVER queries (`QUANTITIES=9`), geocentric.
Fields kept by the parser: `date` (**UT**, minute resolution), `apmag`.
Surface brightness was discarded at parse time.

Raw Horizons responses are preserved on branch **`origin/hourly2025`**
(commit a699d1d, 2025-09-20, under `step_1_collect_nasa_jpl_data/2025/`,
~2.3 MB per body). Their headers confirm: `Date__(UT)`, ephemeris DE441,
step 60 minutes. Alternatively regenerate with
`step_1_collect_data/run_get_vectors_from_jpl_horizons.sh`, then
`step_2_massage_data/run_json_from_step_1_data.sh`.

## Known issues (verified 2026-07-21)

- `helio_499jupiter.json` and `helio_499saturn.json` are **stale misnamed
  duplicates** (md5-identical to `helio_599jupiter.json` /
  `helio_699saturn.json`) left over from a fixed naming bug. The generator
  never writes these names. Safe to delete; kept pending owner's decision.
  The real Mars file is `helio_499mars.json`.
- `observe_10sun.json` holds only 365 **daily** rows (others: 8760 hourly).
  Resolved 2026-07-21: the raw Sun file on `origin/hourly2025` IS hourly and
  parses cleanly, so this JSON was generated from an older daily-step fetch —
  regenerate it from the branch's raw file.
- `observe_*` files are insufficient for crescent-visibility work: no
  illuminated fraction (QUANTITIES 10), elongation (23), phase angle (24), or
  topocentric altitude (4). QUANTITIES=9 is magnitude + surface brightness
  only (gotcha G22).
- Parser uses fixed CSV column positions (gotcha G21) — works for these files,
  fragile in general.

## Integrity

`MANIFEST.sha256` in this directory (includes the two stale duplicates as
shipped).
