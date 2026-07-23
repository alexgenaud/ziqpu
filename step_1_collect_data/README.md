# Step 1 — Collect data from JPL Horizons

Scripts that harvest raw ephemeris data. All Horizons parameters, quirks, and
verified example queries: [docs/HORIZONS.md](../docs/HORIZONS.md). Traps:
[docs/GOTCHAS.md](../docs/GOTCHAS.md).

## Scripts (retained as working reference)

- `run_get_vectors_from_jpl_horizons.sh` — hourly helio (`500@10`) and geo
  (`500@399`) vectors + observer magnitudes for Sun, Moon, and classical
  planets, for 2025. Output → `2025/` raw text (regenerable).
- `run_get_eqx_sol.sh <year>` — progressive refinement (day → hour → minute →
  sub-second interval division) of the four cardinal solar-longitude crossings
  for one year. Accepts `4BC`, `b0004`, `5AD`, `0005`, `2025`.
- `run_get_sol_bc.sh <year>` — special-case December solstice harvester for
  1330–1075 BC, when the solstice fell in the *next* Julian year (gotcha G4).

## Datasets

- [`eqx_sol/`](eqx_sol/DATASHEET.md) — equinoxes & solstices, 5000 BC–AD 5000,
  complete. **UT timestamps, legacy `-N` = "N BC" year labels** — read the
  datasheet before touching.
- `2025/` — raw vector/observer responses (regenerable; absent from this copy).

## For new collections

Add `TIME_TYPE=TT` (verified) to observer queries, keep raw response headers,
and record every run in the dataset's DATASHEET + MANIFEST. Longer term the
primary source moves to a local Skyfield/DE441 pipeline with Horizons as
cross-check.
