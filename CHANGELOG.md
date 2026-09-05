SatelliteToolboxBase.jl Changelog
=================================

Version 2.0.0
-------------

- ![BREAKING][badge-breaking] `KeplerianElements` now has three type parameters:
  `KeplerianElements{Tanomaly, Tepoch, T}`, where `Tanomaly` selects the anomaly stored in
  the object (`TrueAnomaly`, `EccentricAnomaly`, or `MeanAnomaly`). Code that referred to
  `KeplerianElements{Tepoch, T}` must be updated.
- ![BREAKING][badge-breaking] The fields of `KeplerianElements` were renamed to `epoch`,
  `semi_major_axis`, `eccentricity`, `inclination`, `raan`, `argument_of_periapsis`, and
  `anomaly`. The old names (`t`, `a`, `e`, `i`, `Ω`, `ω`, and `f`) are still available as
  property aliases, where `f` always returns the true anomaly.
- ![BREAKING][badge-breaking] The field `t` of `OrbitStateVector` was renamed to `epoch`. The
  old name is still available as a property alias.
- ![BREAKING][badge-breaking] The element type of `OrbitStateVector` is now obtained by
  promoting the input types to float, as it already happened with `KeplerianElements`.
  Hence, integer inputs no longer create an `OrbitStateVector` with integer elements.
- ![BREAKING][badge-breaking] `rv_to_kepler` throws `DimensionMismatch` instead of
  `ErrorException` when the input vectors do not have three elements.
- ![BREAKING][badge-breaking] `is_leap_year` now delegates to `Dates.isleapyear` and no longer
  throws for negative years.
- ![Feature][badge-feature] `KeplerianElements` can store the true, eccentric, or mean
  anomaly, selected by the new type parameter `Tanomaly`. The constructor
  `KeplerianElements{Tanomaly}(...)` creates an object with the desired anomaly, and the
  default remains the true anomaly.
- ![Feature][badge-feature] We added the getters `true_anomaly`, `eccentric_anomaly`, and
  `mean_anomaly`, which return the desired anomaly of a `KeplerianElements` object,
  converting it if necessary. The keywords of the Newton-Raphson solver (`tol` and
  `max_iterations`) can be passed to those functions.
- ![Feature][badge-feature] We added the orbit representation `EquinoctialElements`.
- ![Feature][badge-feature] The Julia built-in conversion system (`convert`) now supports all
  the conversions between `KeplerianElements` (with any anomaly), `EquinoctialElements`, and
  `OrbitStateVector`.
- ![Enhancement][badge-enhancement] The decorations in the `show` methods now use
  **StyledStrings.jl** instead of **Crayons.jl**, which is no longer a dependency.
- ![Enhancement][badge-enhancement] The unused dependency **Printf.jl** was removed.
- ![Enhancement][badge-enhancement] The default tolerance of the Newton-Raphson solver in
  `mean_to_eccentric_anomaly` is now scaled by the magnitude of the mean anomaly, avoiding
  iterations that cannot improve the solution.

Version 1.2.0
-------------

- ![Feature][badge-feature] We added some definition of types to indicate which Jacobian
  method should be used. Those objects are currently used to select how the Jacobian is
  computed when fitting mean elements in orbit propagators.

Version 1.1.0
-------------

- ![Feature][badge-feature] The package now define a lower triangular storage type
  `LowerTriangularMatrix`. This object can be used to store data that fits in a lower
  triangular matrix, such as the Legendre coefficients of a spherical harmonics model. It
  supports both row-major and column-major storage order.

Version 1.0.0
-------------

- ![Info][badge-info] We dropped support for Julia 1.6. This version only supports the
  current Julia version and v1.10 (LTS).
- ![Info][badge-info] This version does not have breaking changes. We bump the version to
  1.0.0 because we now consider the API stable.

Version 0.3.2
-------------

- ![Feature][badge-feature] We added some helpers to assist multi-threaded execution of the
  functions in the SatelliteToolbox.jl ecosystem.

Version 0.3.1
-------------

- ![Enhancement][badge-enhancement] Minor source-code updates.

Version 0.3.0
-------------

- ![BREAKING][badge-breaking] We renamed the constants `EMG08_*` to `EGM_2008_*`.
- ![Feature][badge-feature] We added the constants: `EGM_1996_J2`, `EGM_1996_J3`, and
  `EGM_1996_J4`.
- ![Bugfix][badge-bugfix] We fixed the value of `GM_EARTH` to match that of EGM-2008.

Version 0.2.5
-------------

- ![Feature][badge-feature] We added the constants: `EARTH_EQUATORIAL_RADIUS`,
  `EARTH_POLAR_RADIUS`, and `SUN_RADIUS`.

Version 0.2.4
-------------

- ![Feature][badge-feature] We added an interface to Julia iterators for all orbit
  representations.
- ![Feature][badge-feature] We added the constant `EARTH_ORBIT_MEAN_MOTION`.

Version 0.2.3
-------------

- ![Enhancement][badge-enhancement] **SnoopPrecompile.jl** was replaced by
  **PrecompileTools.jl**.

Version 0.2.2
-------------

- ![Bugfix][badge-bugfix] We removed an unnecessary allocation in the function `date_to_jd`.

Version 0.2.1
-------------

- ![Feature][badge-feature] We added the constant `ASTRONOMICAL_UNIT`.

Version 0.2.0
-------------

- ![Feature][badge-feature] We added functions to convert between orbit anomalies:
  - `mean_to_eccentric_anomaly`
  - `mean_to_true_anomaly`
  - `eccentric_to_true_anomaly`
  - `eccentric_to_mean_anomaly`
  - `true_to_eccentric_anomaly`
  - `true_to_mean_anomaly`
- ![Info][badge-info]: We are increasing the minor version here to avoid breaking
  **SatelliteToolboxTransformations.jl** since the functions described in the previous point
  were initially implemented there.

Version 0.1.3
-------------

- ![Feature][badge-feature] We added the constant `EARTH_ANGULAR_SPEED`.

Version 0.1.2
-------------

- ![Feature][badge-feature] We added the constant `GM_EARTH`.
- ![Feature][badge-feature] The following functions to convert between the orbit
  representations were added: `kepler_to_rv`, `rv_to_kepler`, `kepler_to_sv`, and
  `sv_to_kepler`.
- ![Feature][badge-feature] The orbit representations can be converted between each other
  using the Julia built-in conversion system (`convert`).

Version 0.1.1
-------------

- ![Bugfix][badge-bugfix] We could not define a `OrbitStateVector` using `SVector`s as
  inputs. (Issue [#2][gh-issue-2])

Version 0.1.0
-------------

- Initial version.
  - This version was based on the functions in **SatelliteToolbox.jl**.

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/Deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/Feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/Enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/Bugfix-purple.svg
[badge-info]: https://img.shields.io/badge/Info-gray.svg

[gh-issue-2]: https://github.com/JuliaSpace/SatelliteToolboxBase.jl/issues/2
