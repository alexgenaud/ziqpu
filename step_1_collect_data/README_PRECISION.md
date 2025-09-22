# Precision

## Reference Frames: J2000 vs ICRF

- J2000 (FK5/J2000.0): A widely used celestial reference frame defined by the Earth's
  mean equator and equinox at epoch J2000.0 (January 1, 2000, 12 TT). It incorporates
  precession and nutation models up to that epoch but is based on an Earth-centered
  inertial frame fixed at that time.

- ICRF (International Celestial Reference Frame): An extragalactic, quasi-inertial frame
  defined by the precise positions of distant quasars observed via VLBI, fixed with
  respect to the distant universe. Practically, J2000 and ICRF align to within a few
  milliarcseconds and can be treated equivalently for most solar system work.

Horizons uses J2000, and we note ICRF shows NO difference in our millennia timescales
(5000 BC to AD 2100). Solar system barycentric and geocentric motions are well defined
in both, and the differences are far below arcsecond scales.

## Time Scales: TT, TDB, UTC, UT1

- TT (Terrestrial Time): The independent variable for ephemerides
  and dynamical astronomy; a uniform time scale based on the Earth's
  geoid, used for solar system body positions.

- TDB (Barycentric Dynamical Time): Similar to TT but includes
  relativistic corrections for the solar system barycenter; differs
  from TT by less than 2 ms.

- UTC (Coordinated Universal Time): Civil time scale, adjusted by
  leap seconds to keep within 0.9 seconds of UT1.

- UT1: Based on Earth's actual rotation angle; varies irregularly
  due to tidal braking, core-mantle interactions, etc.

Horizons outputs ephemerides in TT or TDB by default for dynamical positions. The
"apparent" longitude retrieved is effectively referenced to TT/TDB. Conversion
to UTC or civil time requires Earth rotation models and leap second tables.

## Expected Accuracy & Precision Over Time

### Epoch: This century (2000–2100)

Precise to better than ±1 second in timing; solar longitude precision ~1e-7 degrees (sub-arcsecond). Model errors negligible; Earth rotation known well.

Minor Earth orientation variations, leap seconds, atmospheric refraction ignored in geocentric position are the main source of uncertainties.

### Year 1000 AD

Timing accurate to perhaps ±10 seconds; longitude precision degrades to ~1e-5 degrees (~0.036 arcseconds). Precession and nutation models less exact.

Uncertainty in Earth rotation (UT1), less precise precession/nutation models, ephemeris model errors.

### 1 BC to 1000 BC

Timing errors grow to minutes or more; longitude errors on the order of 0.01 degrees (~36 arcseconds). Earth's rotation and tidal deceleration poorly constrained.

Secular variations in Earth's rotation and tidal friction not precisely known; ephemeris extrapolated backward; historical calendar differences affect interpretation.

### 4000 BC to 9999 BC

Timing uncertainty can be hours; longitude errors possibly ~0.1 degrees or more; models extrapolate beyond direct observational constraints.

Earth rotation irregularities (ΔT unknown); precession/nutation less reliable; ephemerides extrapolated from modern data; uncertainties in Earth's orbital parameters increase.

### AD 3000 to 9999

Future uncertainties in Earth's rotation increase (hours); ephemeris models less reliable; dynamical perturbations accumulate. Longitude errors ~0.1 degrees or more expected.

Long-term tidal slowdown, core-mantle interactions, chaotic solar system perturbations; no direct observations exist for validation.

## Sources of uncertainty

- Ephemeris Model Errors: JPL ephemerides (DE430, DE440, etc.) are fitted to observational data primarily from recent centuries. Backwards extrapolation increases uncertainty due to chaotic dynamics and incomplete data.

- Earth Orientation Variations: ΔT (difference between TT and UT1) is well-known in recent centuries but largely uncertain beyond ~1600 AD. Ancient ΔT estimates come from historical records and lunar occultations but become increasingly speculative backward in time.

- Calendar Conventions and Year Zero: Historical dates are subject to interpretation. JPL Horizons does not have a year zero, and use of BC/AD can cause confusion, especially near the BCE/CE boundary.

- Time Zone and Civil Time Ambiguities: The concept of standardized time zones or GMT did not exist until the 19th century. So “midnight” or “00:00” in your dataset corresponds to Terrestrial Time at Greenwich meridian by convention, not to local civil time in ancient epochs.
