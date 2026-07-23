# Gotchas

Every trap this project has hit (or narrowly avoided), recorded so nobody hits it
twice. Each entry: the trap, why it bites, and the rule that avoids it.
Empirical claims marked **[verified]** were tested against the live JPL Horizons
API on 2026-07-21; the test queries are reproduced in [HORIZONS.md](HORIZONS.md).

---

## Years and calendars

### G1. There is no year zero — and there are two ways to number BC years

The trap: "747 BC" is year **−746** in astronomical numbering, not −747.

Historical (BC/AD) counting goes ... 2 BC, 1 BC, AD 1 ... with no year zero.
Astronomical numbering (used by ISO 8601, JPL's Julian-date converter, Skyfield,
astropy, and this project) inserts year 0 = 1 BC, so:

| Historical | Astronomical | Horizons label |
|-----------:|-------------:|:---------------|
| AD 1       | 1            | `0001`         |
| 1 BC       | 0            | `b0001`        |
| 2 BC       | −1           | `b0002`        |
| 747 BC     | −746         | `b0747`        |
| 4500 BC    | −4499        | `b4500`        |

**[verified]** JD 1721057.5 — by construction the start of astronomical year 0 —
is labeled `b0001-Jan-01 00:00` by Horizons. JD 77798.5 (astronomical −4499
Jan 1) is labeled `b4500-Jan-01 00:00`.

**Rule:** machine data uses astronomical signed years only. "BC" strings appear
in human prose, always with the astronomical year alongside: "747 BC (−746)".

### G2. The `sed s:^b:-:` trap — our own convention collision

The legacy cleanup mapped Horizons `b4500` → `-4500` in the eqx_sol data files.
That string means "4500 BC", but every standard tool parses `-4500` as an
astronomical year (= 4501 BC). Meanwhile the notebook prose about the same event
correctly used astronomical `−4499`. Same year, two labels, one project — a
guaranteed off-by-one when joining against any external tool.

**Rule:** never re-encode BC years by sticking a minus on them. Convert
(`bN` → `−(N−1)`) or don't touch them. The eqx_sol files retain the legacy
labels; their [datasheet](../step_1_collect_data/eqx_sol/DATASHEET.md) says so.

### G3. Horizons switches calendars mid-stream in 1582

Dates ≤ 1582-Oct-04 are **Julian calendar**; the next day is 1582-Oct-15
**Gregorian**. Both look like ISO dates. All BC-era output is Julian, which is
why the 4500 BC March equinox prints as "April 26" — the Julian year (365.25 d)
outruns the tropical year by ~0.0078 d/yr, ~1 day drift per 128 years.

**Rule:** record per dataset which calendar the date strings are in. Better:
key every record on the Julian Day number and treat date strings as decoration.

### G4. The December solstice fell in *January* before ~1300 BC

Consequence of G3's drift: the "winter" solstice belonged to the *following*
Julian calendar year, which broke a year-at-a-time harvesting script. A special
script was needed for 1330–1075 BC.

**Rule:** never assume the four cardinal events fall inside one calendar year.
Search by solar longitude crossing, not by calendar window.

### G5. Proleptic calendars are conventions, not history

The Julian calendar extended before AD 8 is a fiction: Rome actually applied
leap years erratically between 45 BC and AD 8 (the pontifex error), and before
45 BC there was no Julian calendar at all. Babylonian dates come from a
luni-solar calendar with its own rules. "4500 BC April 26" locates a moment in
a coordinate system, not in anyone's lived calendar.

**Rule:** proleptic Julian + astronomical years + JD is our *coordinate system*;
mapping to historical calendars (Babylonian months!) is a separate, explicit layer.

### G6. Horizons year input/output formats disagree with each other

Input wants `747BC`, `333AD`, `2025`; output gives `b0747`, `0333`, `2025`.
No year zero, no signed years accepted. JD input works but output is calendar
strings anyway.

**Rule:** wrap year handling in one function (see `run_get_eqx_sol.sh:parse_year`
for the battle-tested version).

---

## Time scales

### G7. Horizons OBSERVER tables are UT; VECTORS tables are TDB — by default

The single most consequential gotcha in this project. The eqx_sol dataset was
collected via OBSERVER queries, so its timestamps are **UT** (Earth-rotation
time, with Horizons' ΔT model baked in), while the vector JSONs carry **JDTDB**
(uniform dynamical time). The notebook originally concluded the opposite for
eqx_sol.

**[verified]** The 2025 March equinox: `09:01:30` in our UT data,
`09:02:39` when re-queried with `TIME_TYPE=TT` — difference 69.2 s = ΔT(2025).
At 4500 BC: `Apr 26 19:59:17` (UT file) vs `Apr 28 ~06:57 TT` —
ΔT ≈ **35 hours**; even the calendar date differs by two days.

**Rule:** every dataset's datasheet states its time scale. New collections use
`TIME_TYPE=TT` (verified working) or compute locally in TDB. See
[TIMESCALES.md](TIMESCALES.md) for the architecture.

### G8. ΔT has a sign, and it's positive in the past

ΔT = TT − UT. It is ~+69 s today, was ~+2.9 h at AD 1, ~+13 h at 2000 BC,
~+35 h at 4500 BC **[verified]**. An event at 12:00 UT in AD 1 occurred at
~14:55 TT — TT clock *ahead*, not behind. The notebook had this backwards.

**Rule:** TT = UT + ΔT, ΔT > 0 in the deep past and (projected) deep future,
minimum near the 19th century where the scales were aligned.

### G9. Accumulated ΔT (hours) ≠ length-of-day excess (milliseconds)

The day lengthens by only ~+1.7–2.3 ms per century. In 5000 BC a day was
~86400 − 0.13 s — not 86399 s. The *hours* of ΔT are the integral of those
milliseconds over millions of days. Two different quantities; don't swap units.

### G10. Leap seconds exist only from 1972, and UTC is presentation-only

TAI−UTC was set to exactly 10 s on 1972-01-01 (so TT−UTC = 42.184 s that day
— solar noon was *not* 12:00:00 TT). First leap seconds: 1972-06-30 and
1972-12-31; TT−UTC = 69.184 s since 2017. Before 1972, "UTC" doesn't
meaningfully exist; before ~1600, even UT is a model reconstruction.

**Rule:** never store UTC. Convert to it, if ever, at the final presentation
step for modern dates only.

### G11. TT vs TDB: ignore the difference, but say so once

They differ by < 2 ms (periodic, relativistic). We store TDB because DE441
integrates in it and Horizons vectors emit JDTDB; we say "TT ≈ TDB at our
precision" exactly once (here) and never again.

### G12. Solar noon ≠ 12:00, even with a perfect clock

The equation of time swings ±16 min through the year (apparent vs mean sun).
Any statement tying "12:00" to the sun overhead is wrong twice over (equation
of time + longitude within time zone). For Babylonian day boundaries we compute
actual sunset moments; we never use "noon" as an anchor.

### G13. A uniform timescale measures orbits; UT measures Earth's wobble

Deriving the tropical year from UT timestamps over 4000 years absorbed the
change in ΔT (~30 h) into the result: 365.2422360 d (UT-based) vs ~365.24192 d
(TT-based) — a 27 s/yr contamination, five orders of magnitude above the
quoted precision. Neither number is "wrong"; they measure different things.

**Rule:** dynamics (year lengths, periods, ephemerides) in TDB; human-visible
phenomena (sunrise, crescent visibility) via UT/local — and label which.

---

## Centers, frames, and coordinates

### G14. "Sun-centered" has two meanings: body center vs barycenter

Horizons `@10` is the Sun's **body center**; `@0` is the **solar-system
barycenter** (SSB). They differ by up to ~2 solar radii (the Sun orbits the
SSB, dragged mainly by Jupiter). DE441 integrates barycentrically; our
"heliocentric" vectors are `500@10` = Sun body center. Similarly `3` is the
Earth-Moon barycenter and `399` is Earth's center — not the same point (~4700 km
apart, inside the Earth but off-center).

**Rule:** name centers by Horizons code in every datasheet: `500@10`, `500@399`,
never just "heliocentric"/"geocentric".

### G15. We observe from Earth's *surface*, not Earth's center

Geocentric (`500@399`) is the right storage frame, but visible phenomena are
**topocentric**. For the Moon the difference is up to ~1° (its horizontal
parallax) — larger than crescent-visibility margins. First-crescent work MUST
use a Babylon site: Horizons `CENTER='coord@399'` with
`SITE_COORD='44.42,32.54,0'` (lon E, lat N, km), or Skyfield's
`wgs84.latlon(32.54, 44.42)`.

### G16. Geometric vs astrometric vs apparent positions

Three different answers to "where is the planet":
- **Geometric** (`VEC_CORR=NONE`, our vectors): where it *is* right now.
- **Astrometric**: where it was when the light left it (light-time only).
- **Apparent** (OBSERVER tables, our eqx_sol): light-time + stellar aberration
  + gravitational deflection + precession/nutation of date. What an observer
  measures.

Light-time alone displaces Jupiter by ~40 min of orbital motion. Never mix
these within one computation without saying so.

### G17. "Ecliptic longitude" needs an equinox: J2000 vs of-date

QUANTITIES=31 (`ObsEcLon`) is referred to the **true equinox and ecliptic of
date** — it includes precession (~50.3″/yr, a full sign of the zodiac in
~2150 yr) and nutation (±17″, 18.6-yr period). That's what defines equinoxes
(longitude = 0° *of date*, by construction) and matches what ancient observers
tracked. Vector data in ICRF/J2000 is a *fixed* frame. Converting between them
is a rotation that grows with distance from J2000 — at 4500 BC the equinox has
precessed ~90°.

**Rule:** state the equinox (J2000 or of-date) next to every ecliptic
coordinate. Seasonal/zodiacal quantities: of-date. Stored vectors: ICRF.

### G18. J2000 vs ICRF: the one difference that doesn't matter

They differ by ~17 milliarcseconds of frame tie. Irrelevant at our precision
across ±7000 years. **[verified]** — identical Horizons output. Say it once,
stop worrying.

---

## The Horizons API itself

(Full cookbook with working queries: [HORIZONS.md](HORIZONS.md).)

### G19. No seconds-unit step size

`STEP_SIZE='1 s'` is rejected. A bare integer N divides the interval into N
equal steps — that's how the eqx_sol half-second brackets were made
(e.g. 30 s window ÷ 60). Fractional-second output needs `TIME_DIGITS=FRACSEC`.

### G20. Longitude wraps 360 → 0 mid-search

A bisection hunting the 0° crossing sees 359.999… then 0.000… — and a grep for
"360.0000000" can match nothing or, worse, an exact-360 row breaks the bracket
logic (legacy scripts patched it with `sed s:360.0000000,:359.9999999,:`).

**Rule:** solve crossings on unwrapped longitude (or sin/cos), not on string
patterns. Root-finding on `sin(λ)` near λ=0 has no wrap at all.

### G21. CSV rows contain empty "presence" columns, and column counts vary

OBSERVER CSV inserts solar-presence / lunar-presence flag columns (often empty,
sometimes `*`, `C`, `N`, `A`, `m`) between the date and the data. Fixed-index
parsing (`parts[3]`) is fragile across targets and quantity sets — the likely
cause of `observe_10sun.json` anomalies.

**Rule:** parse by header names from the `$$SOE` block's column line, never by
position.

### G22. QUANTITIES numbers are not what you'd guess

9 = visual magnitude **and surface brightness** (not "mag, illumination,
phase"). Illuminated fraction is **10**, sun-observer-target elongation **23**,
phase angle **24**, observer ecliptic lon/lat **31**. Crescent-visibility work
needs 4 (az/el), 10, 23, 24 — none of which the legacy observe files contain.

### G23. The API returns JSON-wrapped text with literal `\n`

Every pipeline needs the `sed 's/\\n/\n/g'` unwrap (or request `format=text`).
Also: single quotes in parameters must be URL-encoded `%27`, and there is a
per-query output limit on the order of 90,000 lines — size STEP accordingly.

### G24. Keep the headers you're tempted to strip

The block above `$$SOE` states the time system, calendar mode, ephemeris
version (DE441), and target/center — exactly the metadata whose absence caused
the UT/TT confusion. The legacy cleanup threw it away.

**Rule:** archive at least one full raw response per collection run alongside
the cleaned data.

---

## Precision and storage

### G25. Model precision ≠ historical accuracy

Half-second event brackets are legitimate *within the model* (they keep derived
rates clean; see G13). As claims about history they are false precision: real
uncertainty is ~seconds today, minutes by 1000 BC (ΔT σ), and hours by 5000 BC.

**Rule:** store full precision in TDB + publish alongside the ΔT model name and
its uncertainty. Precision with a stated σ is rigor; without one, naïveté.

### G26. float64 Julian Dates resolve ~20–40 µs — fine, but know it

A float64 JD near 2.4×10⁶ has ~4×10⁻¹⁰ day granularity. Far below every other
error here. If that ever matters, use two-part JDs (integer day + fraction),
which is also the friendlier raw format: compact like JD, greppable by day.

### G27. File-level traps found in the current data (as of 2026-07-21)

- `helio_499jupiter.json` / `helio_499saturn.json` are md5-identical stale
  duplicates of the 599/699 files (a fixed naming bug's leftovers).
- `observe_10sun.json` has 365 daily rows where siblings have 8760 hourly.
- The retired step-1 notebook described geocentric CENTER as `500@10`;
  correct is `500@399` (scripts were always right).
- eqx_sol event times are *bracket pairs* (last sample below, first above the
  cardinal longitude); the event is between them — interpolate, don't pick one.

---

## Stars and the sidereal frame

### G28. "Fixed" stars aren't — proper motion at millennial scale

Catalog positions are a snapshot; stars drift. For the four zodiac anchors,
great-circle motion per 5000 years:

| star      | proper motion | drift / 5000 yr | why |
|-----------|--------------:|----------------:|-----|
| Antares   | ~26 mas/yr    | **0.036°**      | distant supergiant (~170 pc) |
| Spica     | ~52 mas/yr    | 0.072°          | distant (~250 pc) |
| Aldebaran | ~199 mas/yr   | 0.28°           | nearby (~20 pc) |
| Regulus   | ~249 mas/yr   | 0.35°           | nearby (~24 pc) |

Sub-nakshatra (13°20′) and sub-lunarpada (4.39°), but fatal to any
"exactly on the boundary" claim held fixed across millennia. Use
epoch-propagated astrometry (Hipparcos/Gaia via Skyfield `Star` objects),
never catalog constants. Note Antares — the chosen anchor — is the steadiest
of the four by an order of magnitude over Regulus/Aldebaran.

### G29. The ecliptic grid moves under the stars in TWO ways

1. **Equinox precession**: the zero point slides along the ecliptic
   50.29″/yr — 1° per 71.6 yr, one nakshatra per ~954 yr, one 82-cell per
   ~314 yr. This is the famous, fast one — the whole reason sidereal ≠
   tropical.
2. **The ecliptic plane itself tilts** (planetary precession, ~47″/century):
   over ±5000 yr the plane reorients by several tenths of a degree, so even a
   motionless star's ecliptic **latitude** changes, and of-date longitudes
   pick up a small extra term.

A sidereal zodiac must therefore declare *which ecliptic* its boundaries live
on (of-date vs a frozen epoch). Of-date matches observation and tradition;
frozen is simpler math. Declare it; don't mix.

### G30. Standard precession formulas expire after a few millennia

IAU 1976 and IAU 2006 precession expressions are polynomial fits around
J2000 — fine for centuries, degrading (arcminute-level and worse) beyond a few
thousand years. For ±5000-year star-grid work use the **Vondrák, Capitaine &
Wallace (2011) long-term precession** model (valid ±200 millennia). Horizons'
of-date reductions use classical IAU models — check the response header — and
DE441's *positions* are unaffected (integration doesn't use precession); only
of-date *coordinate labels* are.

### G31. Horizons has no stars

It serves solar-system bodies only. Star ecliptic positions must come from
catalog astrometry (Gaia DR3 / Hipparcos) propagated and transformed locally
(Skyfield). Consequence: the star-vs-planet correlation program *requires* the
local pipeline — Horizons can only supply the planet half.

### G32. A sidereal zodiac is TWO free choices, made explicit

(1) Which star anchors, pinned to what value; (2) whether the anchor is
**co-moving** (star re-pinned every epoch; all other stars drift only by
*relative* proper motion) or **frozen-epoch** (grid fixed at, say, J2000; every
star drifts). Traditions differ silently: Lahiri pins Citrā/Spica at 180°
co-moving; Fagan–Bradley pinned the Aldebaran–Antares axis at 15° Taurus/
Scorpio. Useful geometric fact: Aldebaran and Antares sit within ~0.03° of
exact opposition (J2000 λ 69.79° / 249.76°), so anchoring on one nearly
anchors the other — and the pair straddles the sky as a natural axis.

### G33. The Moon keeps mean time only on average

Mean motion 13.176°/day gives one 82-cell (4.390°) per 7ʰ59.7ᵐ — but true
lunar speed swings 11.7–15.4°/day (eccentric orbit, perturbations), so real
dwell per cell ranges **~6.8 to ~9.0 hours**. Never generate cell-crossing
times from mean motion; compute true longitude crossings.
