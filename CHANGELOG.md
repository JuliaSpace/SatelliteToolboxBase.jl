SatelliteToolboxBase.jl Changelog
=================================

Version 2.0.0
-------------

- ![BREAKING][badge-breaking] Add the type parameter `Tanomaly` to `KeplerianElements`,
  which now is `KeplerianElements{Tanomaly, Tepoch, T}`, to select the anomaly stored in the
  object (`TrueAnomaly`, `EccentricAnomaly`, or `MeanAnomaly`). Update the code that refers
  to `KeplerianElements{Tepoch, T}`.
- ![BREAKING][badge-breaking] Rename the fields of `KeplerianElements` to `epoch`,
  `semi_major_axis`, `eccentricity`, `inclination`, `raan`, `argument_of_periapsis`, and
  `anomaly`. Keep the old names (`t`, `a`, `e`, `i`, `Ω`, `ω`, and `f`) as property aliases,
  where `f` always returns the true anomaly.
- ![BREAKING][badge-breaking] Rename the field `t` of `OrbitStateVector` to `epoch`. Keep
  the old name as a property alias.
- ![BREAKING][badge-breaking] Promote the inputs of `OrbitStateVector` to float when
  obtaining the element type, as `KeplerianElements` already does. Hence, integer inputs no
  longer create an `OrbitStateVector` with integer elements.
- ![BREAKING][badge-breaking] Throw `DimensionMismatch` instead of `ErrorException` in
  `rv_to_kepler` when the input vectors do not have three elements.
- ![BREAKING][badge-breaking] Delegate `is_leap_year` to `Dates.isleapyear`, which no longer
  throws for negative years.
- ![Feature][badge-feature] Support the true, eccentric, or mean anomaly in
  `KeplerianElements`, selected by the new type parameter `Tanomaly`. Use the constructor
  `KeplerianElements{Tanomaly}(...)` to create an object with the desired anomaly. The
  default remains the true anomaly.
- ![Feature][badge-feature] Add the getters `true_anomaly`, `eccentric_anomaly`, and
  `mean_anomaly`, which return the desired anomaly of a `KeplerianElements` object,
  converting it if necessary. Pass the keywords of the Newton-Raphson solver (`tol` and
  `max_iterations`) to those functions when the conversion starts from the mean anomaly.
- ![Feature][badge-feature] Add the orbit representation `EquinoctialElements`.
- ![Feature][badge-feature] Add the orbit representation `AlternateEquinoctialElements`,
  which uses `sin(i / 2)` instead of `tan(i / 2)` in the elements `p` and `q`, keeping them
  bounded and finite for every inclination, including retrograde equatorial orbits.
- ![Feature][badge-feature] Support all the conversions between `KeplerianElements` (with
  any anomaly), `EquinoctialElements`, `AlternateEquinoctialElements`, and
  `OrbitStateVector` in the Julia built-in conversion system (`convert`).
- ![Enhancement][badge-enhancement] Use **StyledStrings.jl** instead of **Crayons.jl** for
  the decorations in the `show` methods. **Crayons.jl** is no longer a dependency.
- ![Enhancement][badge-enhancement] Remove the unused dependency **Printf.jl**.
- ![Enhancement][badge-enhancement] Scale the default tolerance of the Newton-Raphson solver
  in `mean_to_eccentric_anomaly` by the magnitude of the mean anomaly, avoiding iterations
  that cannot improve the solution.
- ![Info][badge-info] Add the `.JuliaFormatter.toml` configuration and format the code base
  according to the coding style.

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
