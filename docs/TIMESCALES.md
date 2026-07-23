# Time Scales

How ziqpu handles time: one uniform scale for storage and dynamics, everything
human-facing derived from it, explicitly, at the edge.

## The three-layer architecture

**Layer 1 — storage and dynamics: TDB.**
Barycentric Dynamical Time, the independent variable of the JPL ephemerides.
Uniform SI seconds, no leap seconds, no Earth wobble, never revised. All
canonical data is keyed on Julian Date in TDB (JDTDB). TT (Terrestrial Time)
differs from TDB by < 2 ms periodic relativistic terms; we treat TT ≈ TDB and
say so only here.

**Layer 2 — Earth rotation: UT1, via an explicit ΔT model.**
UT1 tracks the actual rotation angle of the Earth — irregular, slowing on
average, known precisely only where observations exist. The bridge is
ΔT = TT − UT1. Ancient ΔT comes from historical eclipse records (Stephenson,
Morrison & Hohenkerk 2016 is the standard model); it carries an uncertainty
that grows into the past, and it *improves as scholarship improves* — which is
exactly why it must never be baked into stored data. Layer 2 is a named model
applied at read time.

**Layer 3 — local phenomena: Babylon.**
Sunrise, sunset, moonset, crescent altitude at a site (Babylon: 32.54° N,
44.42° E). These are functions evaluated from layers 1+2 (topocentric
geometry), not a timescale. The Babylonian day runs sunset-to-sunset; the
calendar's day key is "the day whose evening begins it", computed from actual
sunset moments.

UTC exists only at the very edge of layer 3, for modern dates: UT1 rounded to
whole SI seconds by leap seconds (1972 onward, see below). We never store it.

## ΔT: measured anchor points

ΔT = TT − UT, **positive in the deep past and the projected future**, minimum
near the 19th century. Values marked *(measured)* were obtained 2026-07-21 by
querying the same event from Horizons in UT and in TT (`TIME_TYPE=TT`):

| Epoch    | ΔT (approx)        | day-time offset      |
|----------|--------------------|----------------------|
| 5000 BC  | ~41 h (extrapol.)  | date differs by ~2 d |
| 4500 BC  | **34.97 h** *(measured)* | date differs by 2 d |
| 2000 BC  | ~13 h              | half a day           |
| 1000 BC  | ~7 h               |                      |
| AD 1     | ~2.9 h             |                      |
| AD 1000  | ~26 min            |                      |
| AD 2025  | **69.2 s** *(measured)* |                 |
| AD 3000  | ~1–2 h (extrapol., very uncertain) |      |
| AD 5000  | ~5–10 h (extrapol., very uncertain) |     |

Uncertainty in ΔT: seconds today, minutes around AD 1000, tens of minutes to
an hour by 2000 BC, hours by 5000 BC. Future values are pure extrapolation.

Do not confuse accumulated ΔT (hours) with the length-of-day excess
(milliseconds): the day lengthens ~+1.7–2.3 ms per century; a day in 5000 BC
lasted ~86400 − 0.13 s. The hours of ΔT are those milliseconds integrated over
2.5 million days.

## Which timescale each existing dataset is in

- `step_1_collect_data/eqx_sol/*` — **UT** (Horizons OBSERVER default), with
  Horizons' own ΔT model baked in. Legacy; see its DATASHEET.
- `step_2_massage_data/2025/helio_*`, `geo_*` — **TDB** (JDTDB key). Canonical.
- `step_2_massage_data/2025/observe_*` — **UT** date labels.

New collections: Horizons OBSERVER queries take `TIME_TYPE=TT` (verified
working); local computation (Skyfield/DE441) is native TDB.

## Corrections to the lab notebook

The preserved notebook ([notebook/EQUINOX_original.md](notebook/EQUINOX_original.md))
contains conclusions later found wrong; for the record:

1. *"eqx_sol timestamps are TT (or TDB)"* — they are **UT**. The JD-difference
   argument only tested calendar arithmetic, which is timescale-blind.
   Empirical proof: the 2025 March equinox reads 09:01:30 in our data
   (published UTC value ~09:01:25); in TT it is 09:02:39.
2. *"Solar noon 12:00 UTC was 08:00 TT in 5000 BC; 10:00 TT in AD 1"* — sign
   flipped. TT = UT + ΔT with ΔT > 0 in the past: solar noon at AD 1 was
   ~14:55 TT; at 5000 BC, TT was ~40 *hours* ahead.
3. *"Days were 86399 s before 5000 BC"* — off ~8×; see above.
4. *"Solar noon was exactly 12:00:00.0000 TT on 1972-01-01"* — on that date
   TAI−UTC was set to exactly 10 s, hence TT−UTC = 42.184 s; and apparent solar
   noon differs from clock noon by the equation of time (±16 min through the
   year) regardless. The 1972 leap-second dates (June 30, Dec 31) were correct.
5. The tropical year derived from the UT data, 365.2422360 d, absorbs ~27 s/yr
   of Earth-rotation drift; the TT-based value over the same 4000-year baseline
   is ~365.24192 d. Dynamics must be measured in TDB (gotcha G13).
