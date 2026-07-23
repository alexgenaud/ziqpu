# Step 2 — Massage raw data into clean JSON

Parsers from raw Horizons responses to JSON keyed on `jdtdb`.

- `run_parse_jpl_horizons_vectors.py` — `$$SOE…$$EOE` CSV →
  `{jdtdb, date, x, y, z}`.
- `run_parse_jpl_horizons_observations.py` — observer CSV → `{date, apmag}`.
  Known limitation: fixed column indices (gotcha G21) and keeps magnitude only
  (gotcha G22).
- `run_json_from_step_1_data.sh` — drives both over all bodies.

Output: [`2025/`](2025/DATASHEET.md) — see its datasheet for semantics,
timescales, and known issues (including two stale duplicate files).
