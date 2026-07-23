# Precision and Accuracy

The policy in one line: **compute and store at full model precision in TDB;
publish any historical claim together with the ΔT model and its uncertainty.**

Sub-second precision is not absurd — it is what keeps derived quantities
(rates, periods, differences) free of rounding noise, and within the ephemeris
model it is meaningful. It becomes absurd only when presented as knowledge
about historical reality without an error bar. Same digits, different claims.

## Error budget by epoch

For solar/planetary event *times* as experienced on Earth (the quantity that
matters for calendars). Two separable parts: the ephemeris (where the bodies
were — excellent everywhere in our range) and Earth orientation (what time it
was on Earth — the dominant error almost everywhere).

| Epoch        | ephemeris (position) | ΔT / Earth rotation      | practical timing accuracy |
|--------------|----------------------|--------------------------|---------------------------|
| 2000–2100    | negligible           | ±seconds                 | ~1 s                      |
| AD 1000      | negligible           | ±minutes                 | minutes                   |
| 1 BC–1000 BC | arcseconds           | ±tens of minutes         | tens of minutes           |
| 2000–5000 BC | tens of arcseconds   | ±(one to several) hours  | hours; dates near day boundaries can shift a day |
| AD 3000–5000 | grows slowly         | extrapolation only       | hours (unvalidatable)     |

DE441 (the ephemeris behind Horizons and our local computations) is fitted to
modern data and integrated across ±13,000 years; planetary positions remain
good to arcsecond-ish levels at our range's edges. ΔT, by contrast, rests on
historical eclipse records and degrades fast: it is the error budget.

## What this means for the Babylonian goal

First-crescent visibility is a threshold phenomenon evaluated at a specific
local sunset. ΔT uncertainty shifts which sunset the threshold is compared at;
near-threshold months can flip a day. The honest method: propagate σ(ΔT)
(e.g., Monte Carlo over the Stephenson–Morrison–Hohenkerk band) and report,
per month, the probability of each candidate first day — the ideal calendar
becomes probabilistic exactly where it should be. The gap that remains between
that and the tablet record is then weather and human practice, which is the
phenomenon under study.

## House rules

1. Every published time carries: TDB instant, ΔT model name, σ.
2. Never average, difference, or fit across epochs in UT (gotcha G13).
3. Event times found by bracketing carry the bracket width as their model
   precision (eqx_sol: 0.5 s).
4. Displayed decimals never exceed the σ column. Stored decimals may.
