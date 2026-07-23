# The Sidereal Frame: Fixed-Star Zodiac and the 82 Lunarpada

Design document for ziqpu's sidereal layer: a strictly normalized star-anchored
zodiac defined on the ecliptic (not on horizon phenomena or heliacal risings),
plus an original 82-point lunar division. Status: **specification** — the
authoritative star ephemeris dataset does not exist yet (see "Planned data").

## Sidereal vs tropical, in one paragraph

The tropical frame is anchored to the equinox, which precesses along the
ecliptic at 50.29″/yr — 1° per 71.6 years, a full nakshatra (13°20′) per ~954
years, a full cycle in ~25,772 years. The sidereal frame is anchored to the
stars, which drift only by proper motion (arcseconds per century). The seasons
follow the equinoxes; the constellations don't. Both frames are exact and
computable; neither is "wrong" — but a calendar of star positions must be
sidereal, with the tropical drift *derived* (gotchas G28–G32 govern the traps).

## Anchor stars

The four royal quadrant stars, all within ~5.5° of the ecliptic, each the
yogatāra (determinative star) of its namesake nakshatra:

| star | Bayer | nakshatra | J2000 ecl. longitude | latitude | proper motion | drift/5000 yr |
|------|-------|-----------|---------------------:|---------:|--------------:|--------------:|
| Aldebaran | α Tau | Rohiṇī  | 69°47′  | −5°28′ | 199 mas/yr | 0.28° |
| Regulus   | α Leo | Maghā   | 149°50′ | +0°28′ | 249 mas/yr | 0.35° |
| Spica     | α Vir | Citrā   | 203°50′ | −2°03′ | 52 mas/yr  | 0.072° |
| Antares   | α Sco | Jyeṣṭhā | 249°46′ | −4°34′ | 26 mas/yr  | 0.036° |

(Longitudes/latitudes on the J2000 ecliptic; final dataset values will come
from Gaia astrometry, epoch-propagated.)

**The ziqpu anchor is Antares.** Two independent justifications:

1. *Empirical* (the project's finding): pinning Antares makes the other bright
   ecliptic yogatāras fall within — or exactly on the boundary of — their
   namesake equal-division nakshatras, better than a Spica (Citrā-pakṣa/Lahiri)
   pin does.
2. *Astrometric*: Antares has the smallest proper motion of the four by an
   order of magnitude over Aldebaran/Regulus (it is a distant supergiant) — the
   steadiest available flagpole.

Geometric bonus: Aldebaran sits within ~0.03° of exact opposition to Antares
(Δλ = 179.97° at J2000), so the Antares anchor *is* an Aldebaran anchor to
within two arcminutes — the Fagan–Bradley/Babylonian Aldebaran–Antares axis
and this system nearly coincide by construction.

### Open design decisions (to be fixed before data collection)

1. **Pinned value**: Antares = what longitude, exactly? (Candidates: middle of
   Jyeṣṭhā = 233°20′; a value optimized over all yogatāras; a round number.)
2. **Co-moving vs frozen** (G32): recommend co-moving (re-pin Antares each
   epoch; its 0.036°/5000 yr drift is the smallest achievable systematic).
3. **Which ecliptic** (G29): recommend ecliptic of date, with boundaries as
   longitude divisions only (latitude-free), matching observational tradition.
4. **Precession model** (G30): Vondrák et al. 2011 for anything beyond ±2000
   years from J2000.

## The 82 lunarpada (original to this project, 2025–2026)

An equal division of the sidereal ecliptic into 82 cells of 360/82 = 4.3902°,
scaled to the Moon's 8-hour motion. The arithmetic (verified):

- Sidereal month 27.321662 d × 3 (8-hour steps) = **81.965** → 82 cells is the
  integer fit, off by 0.04%.
- Mean dwell per cell: 27.321662 d / 82 = **7ʰ59.7ᵐ** — twelve seconds per
  hour short of exact.
- True dwell ranges ~6.8–9.0 h with lunar speed (11.7–15.4°/day, G33): cell
  crossings must be computed as true-longitude root-findings, never scheduled
  by mean motion.
- Synodic − sidereal month = 29.530589 − 27.321662 = **2.209 d** — after one
  star-to-star circuit the Moon needs ~2.2 more days (≈ 6⅔ cells) to reach the
  Sun again, which is why phase slips against the cells month by month.
- The equinox crosses one cell per ~314 years — the cells themselves are a
  slow clock of precession.

Provenance note: the 82-division is Alex Genaud's independent modern
construction. Any correlation with historical systems (Sumerian, Indian,
Norse, Chinese, African, Pacific...) is a *hypothesis to test after* the
astronomical facts and the primary sources (stone, clay) are separately
recorded — correlation work must not contaminate the data layer.

## Historical precedents recorded for context (not evidence)

- **Babylonian Normal Stars**: the Astronomical Diaries record planet positions
  *relative to ~28–32 reference stars near the ecliptic* ("Jupiter 2 cubits
  above β Geminorum") — star-relative planetary coordinates are the oldest
  systematic method, and exactly what the planned star+planet correlation
  reproduces. The Babylonian cubit (KÙŠ) ≈ 2–2.5°; one lunarpada (4.39°) ≈ 2
  cubits — noted as a coincidence, nothing more.
- **MUL.MUL (Pleiades)** heads the MUL.APIN star list; **Kṛttikā (Pleiades)**
  heads the oldest nakshatra lists. The vernal point sat at the Pleiades
  (Alcyone, J2000 λ ≈ 60°) around **2300 BC** and at Aldebaran (λ ≈ 69.8°)
  around **3000 BC** — an early-3rd-millennium Pleiades/Taurus zero is
  astronomically coherent.
- **Equal-division sidereal zodiac**: Babylonian, 5th c. BC; reached India in
  the Hellenistic transmission (e.g., Yavanajātaka) — while the nakshatras
  themselves are older and indigenous (Kṛttikā-first lists in Vedic sources).
  The project's claim "Common-era Indian astronomers aligned nakshatras to the
  equally divided zodiac" is the scholarly consensus.
- **Ayanāṃśa precedents**: Lahiri (Citrā/Spica pinned at 180°, co-moving,
  official in India since 1955); Fagan–Bradley (Aldebaran–Antares axis at
  15° Taurus/Scorpio, argued from Babylonian data). The Antares anchor is a
  third, explicitly normalized member of this family.

## Planned data

1. **Star ephemeris table**: Aldebaran, Regulus, Spica, Antares (+ Alcyone/
   Pleiades as the ancient zero candidate) — ecliptic λ, β at decadal steps,
   −3000 … +3000 (extendable ±5000), in both of-date (Vondrák) and J2000
   frames, from Gaia DR3 astrometry epoch-propagated via Skyfield. Stars are
   slow: decadal sampling overshoots; the of-date grid motion dominates.
2. **Moon sidereal longitude** every 8 hours (TDB-keyed) across the target
   span → 82-cell index as a derived column, crossings by root-finding.
3. **Planet-vs-star correlation**: planetary sidereal longitudes + angular
   separations from the four anchors (the Normal-Star observable), enabling
   direct comparison against Diary-style records.

Each dataset gets a DATASHEET.md and MANIFEST.sha256 per project policy;
timescale TDB, astronomical years, JD keys ([TIMESCALES](TIMESCALES.md),
[CALENDARS](CALENDARS.md)).
