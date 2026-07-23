# untracked/ — data and binaries that live OUTSIDE git

Everything under this directory except this README is deliberately not
tracked (`.gitignore`: `/untracked/*`). This is the one obvious home for
bulk data, binary assets, and archives; git holds code, docs, datasheets,
and manifests only. See the "Repository policy" section of the root README.

## Contents

- `archives/` — compressed snapshots with SHA-256 sums (`ARCHIVES.sha256`):
  - `ziqpu-stash-251222.tar.zst` — full tree of the retired `stash-251222`
    branch (correlations spreadsheet, raw AD 2101–5000 & 3999–2000 BC
    equinox harvests, Z_AGAIN retry scratch, notes, logo source).
  - `ziqpu-hourly2025.tar.zst` — full tree of the retired `hourly2025`
    branch (raw 2025 hourly Horizons responses; headers prove UT, DE441).
  - `ziqpu-bulk-data-20260721.tar.zst` — the eqx_sol text files and 2025
    JSON files as untracked from main.
- `data/eqx_sol/` — working copies: equinoxes/solstices 5000 BC – AD 5000
  (**UT**, legacy year labels — read
  `step_1_collect_data/eqx_sol/DATASHEET.md` first).
- `data/2025/` — working copies: 2025 hourly vector/observer JSONs (TDB;
  see `step_2_massage_data/2025/DATASHEET.md`; includes two stale
  `helio_499{jupiter,saturn}.json` duplicates kept pending deletion).
- `logo/` — `ziqpu.xcf` (GIMP source) and `monroe2022/` (paper PDF and
  tablet images the logo derives from; kept out of the public repo also
  for copyright prudence — see `logo/README.md` for the citation).
- `correlations/weeks-from-JD0.ods` — the weeks-since-JD-0 historical
  correlation spreadsheet (53 MB), extracted from the stash archive.

## Recovery / regeneration

Verify integrity: `cd archives && shasum -a 256 -c ARCHIVES.sha256`.
Restore an archive: `zstd -dc <file>.tar.zst | tar -x`.
Full pre-cleanup git history is pinned locally by tags `archive/*`
(deliberately never pushed). Dataset regeneration is documented in each
dataset's DATASHEET.md.
