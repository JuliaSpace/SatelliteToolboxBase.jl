SatelliteToolboxBase.jl Changelog
=================================

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
