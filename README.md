<p align="center">
  <img src="./docs/src/assets/logo.png" width="150" title="SatelliteToolboxBase.jl"><br>
  <small><i>This package is part of the <a href="https://github.com/JuliaSpace/SatelliteToolbox.jl">SatelliteToolbox.jl</a> ecosystem.</i></small>
</p>

# SatelliteToolboxBase.jl

[![CI](https://img.shields.io/github/actions/workflow/status/JuliaSpace/SatelliteToolboxBase.jl/ci.yml?style=flat-square&logo=githubactions&logoColor=white&labelColor=475569&label=CI)](https://github.com/JuliaSpace/SatelliteToolboxBase.jl/actions/workflows/ci.yml)
[![Codecov](https://img.shields.io/codecov/c/github/JuliaSpace/SatelliteToolboxBase.jl?token=YADU7IB8CT&style=flat-square&logo=codecov&logoColor=white&labelColor=475569)](https://codecov.io/gh/JuliaSpace/SatelliteToolboxBase.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495D1?style=flat-square&logo=julia&logoColor=white&labelColor=475569)](https://github.com/invenia/BlueStyle)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.11285923-DB2777?style=flat-square&logo=doi&logoColor=white&labelColor=475569)](https://zenodo.org/doi/10.5281/zenodo.11285923)

This package contains base functions and type definitions for the **SatelliteToolbox.jl**
ecosystem.

> **Note**
> This package contains only basic definitions used for other packages in the
> **SatelliteToolbox.jl**. You will need to install other packages to perform analyses and
> studies.

## Installation

``` julia
julia> using Pkg
julia> Pkg.add("SatelliteToolboxBase")
```

## Usage

### Constants

We define and export the following constants in this package:

| Constant                  | Description                                                            |
|:--------------------------|:-----------------------------------------------------------------------|
| `ASTRONOMICAL_UNIT`       | The approximate distance between the Earth and the Sun.                |
| `GM_EARTH`                | Earth's standard gravitational parameter.                              |
| `EARTH_ANGULAR_SPEED`     | Earth's angular speed without LOD correction.                          |
| `EARTH_EQUATORIAL_RADIUS` | Earth's equatorial radius (WGS-84).                                    |
| `EARTH_ORBIT_MEAN_MOTION` | Earth's orbit mean motion.                                             |
| `EARTH_POLAR_RADIUS`      | Earth's polar radius (WGS-84).                                         |
| `WGS84_ELLIPSOID`         | The WGS-84 ellipsoid defined using the structure `Ellipsoid{Float64}`. |
| `WGS84_ELLIPSOID_F32`     | The WGS-84 ellipsoid defined using the structure `Ellipsoid{Float32}`. |
| `EGM_1996_J2`             | J2 perturbation term obtained from EGM-1996 model.                     |
| `EGM_1996_J3`             | J3 perturbation term obtained from EGM-1996 model.                     |
| `EGM_1996_J4`             | J4 perturbation term obtained from EGM-1996 model.                     |
| `EGM_2008_J2`             | J2 perturbation term obtained from EGM-2008 model.                     |
| `EGM_2008_J3`             | J3 perturbation term obtained from EGM-2008 model.                     |
| `EGM_2008_J4`             | J4 perturbation term obtained from EGM-2008 model.                     |
| `SUN_RADIUS`              | Sun radius.                                                            |
| `JD_J2000`                | Julian Day of J2000.0 epoch (2000-01-01T12:00:00.000).                 |

### Orbit

This package defines the abstract type `Orbit` for all orbit representations.

Currently, we defined four types to represent an orbit: `KeplerianElements`,
`EquinoctialElements`, `AlternateEquinoctialElements`, and `OrbitStateVector`.

#### Keplerian Elements

`KeplerianElements{Tanomaly, Tepoch, T}` defines an orbit in terms of the [Keplerian
elements](https://en.wikipedia.org/wiki/Orbital_elements). The type parameter `Tanomaly`
selects which anomaly is stored in the object: `TrueAnomaly`, `EccentricAnomaly`, or
`MeanAnomaly`. This object is created using the functions:

```julia
KeplerianElements(epoch::Tepoch, semi_major_axis::T1, eccentricity::T2, inclination::T3, raan::T4, argument_of_periapsis::T5, anomaly::T6)
KeplerianElements{Tanomaly}(epoch::Tepoch, semi_major_axis::T1, eccentricity::T2, inclination::T3, raan::T4, argument_of_periapsis::T5, anomaly::T6)
```

where it returns an orbit representation using Keplerian elements with semi-major axis
`semi_major_axis` [m], eccentricity `eccentricity` [ ], inclination `inclination` [rad],
right ascension of the ascending node `raan` [rad], argument of periapsis
`argument_of_periapsis` [rad], and anomaly `anomaly` [rad]. If `Tanomaly` is omitted, the
anomaly is the true anomaly.

```julia
julia> orb = KeplerianElements(
           date_to_jd(1986, 6, 19, 18, 35, 0),
           7130.982e3,
              0.0001111,
             98.405 |> deg2rad,
            200.000 |> deg2rad,
             90.000 |> deg2rad,
            123.456 |> deg2rad,
       )
KeplerianElements{TrueAnomaly, Float64, Float64}:
             Epoch :    2.4466e6 (1986-06-19T18:35:00)
   Semi-major axis : 7130.98      km
      Eccentricity :    0.0001111
       Inclination :   98.405     °
              RAAN :  200.0       °
 Arg. of Periapsis :   90.0       °
      True Anomaly :  123.456     °

julia> orb_M = KeplerianElements{MeanAnomaly}(
           date_to_jd(1986, 6, 19, 18, 35, 0),
           7130.982e3,
              0.0001111,
             98.405 |> deg2rad,
            200.000 |> deg2rad,
             90.000 |> deg2rad,
            123.456 |> deg2rad,
       )
KeplerianElements{MeanAnomaly, Float64, Float64}:
             Epoch :    2.4466e6 (1986-06-19T18:35:00)
   Semi-major axis : 7130.98      km
      Eccentricity :    0.0001111
       Inclination :   98.405     °
              RAAN :  200.0       °
 Arg. of Periapsis :   90.0       °
      Mean Anomaly :  123.456     °
```

The functions `true_anomaly`, `eccentric_anomaly`, and `mean_anomaly` return the desired
anomaly of the orbit, converting it from the stored one if necessary. The keywords of the
Newton-Raphson solver (see below) can be passed to those functions:

```julia
julia> true_anomaly(orb_M)
2.1546338615735434

julia> true_anomaly(orb_M; tol = 1e-6, max_iterations = 5)
2.1546338615735434
```

For backward compatibility, the properties `t`, `a`, `e`, `i`, `Ω`, `ω`, and `f` are
aliases for the fields `epoch`, `semi_major_axis`, `eccentricity`, `inclination`, `raan`,
`argument_of_periapsis`, and the **true** anomaly, respectively.

#### Equinoctial Elements

`EquinoctialElements{Tepoch, T}` defines an orbit in terms of the equinoctial elements, which
are non-singular for circular and equatorial orbits:

```julia
EquinoctialElements(epoch::Tepoch, semi_major_axis::T1, h::T2, k::T3, p::T4, q::T5, mean_longitude::T6)
```

where, given the Keplerian elements, `h = e * sin(ω + Ω)`, `k = e * cos(ω + Ω)`,
`p = tan(i / 2) * sin(Ω)`, `q = tan(i / 2) * cos(Ω)`, and the mean longitude is
`Ω + ω + M`. This set is singular for retrograde equatorial orbits (`i = π`).

```julia
julia> convert(EquinoctialElements, orb)
EquinoctialElements{Float64, Float64}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98       km
               h :   -0.0001044
               k :    3.79984e-5
               p :   -0.396269
               q :   -1.08874
  Mean Longitude :  413.445      °
```

#### Alternate Equinoctial Elements

`AlternateEquinoctialElements{Tepoch, T}` differs from the equinoctial elements only in the
inclination elements, where `sin(i / 2)` replaces `tan(i / 2)`:

```julia
AlternateEquinoctialElements(epoch::Tepoch, semi_major_axis::T1, h::T2, k::T3, p::T4, q::T5, mean_longitude::T6)
```

Hence, `p = sin(i / 2) * sin(Ω)` and `q = sin(i / 2) * cos(Ω)` are bounded (`p² + q² ≤ 1`)
and finite for every inclination, including retrograde equatorial orbits (`i = π`). This set
is called "Alternate Equinoctial" in GMAT and "Nonsingular Keplerian" in FreeFlyer.

Both equinoctial sets are subtypes of `AbstractEquinoctialElements{Tepoch, T}`, which can be
used to write code that accepts either of them.

```julia
julia> convert(AlternateEquinoctialElements, orb)
AlternateEquinoctialElements{Float64, Float64}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98       km
               h :   -0.0001044
               k :    3.79984e-5
               p :   -0.258917
               q :   -0.711369
  Mean Longitude :  413.445      °
```

#### Orbit State Vector

`OrbitStateVector` defines the orbit in terms of the [object state
vector](https://en.wikipedia.org/wiki/Orbital_state_vectors). This object is created using
the function:

```julia
OrbitStateVector(epoch::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}[, a::AbstractVector{Ta}])
```

where it creates an orbit state vector with `epoch` [Julian Day], position `r` [m], velocity
`v` [m/s], and acceleration `a` [m/s²]. If the latter is omitted, it will be filled with
`[0, 0, 0]`. For backward compatibility, the property `t` is an alias for `epoch`.

``` julia-repl
julia> r_i = [6525.344; 6861.535; 6449.125] * 1000
3-element Vector{Float64}:
 6.525344e6
 6.861535e6
 6.449125e6

julia> v_i = [4.902276; 5.533124; -1.975709] * 1000
3-element Vector{Float64}:
  4902.276
  5533.124
 -1975.7089999999998

julia> sv = OrbitStateVector(date_to_jd(1986, 6, 19, 18, 35, 0), r_i, v_i)
OrbitStateVector{Float64, Float64}:
        Epoch : 2.4466e6 (1986-06-19T18:35:00)
     Position : [6525.34, 6861.53, 6449.12]  km
     Velocity : [4.90228, 5.53312, -1.97571] km/s
 Acceleration : [0.0, 0.0, 0.0]              km/s²
```

#### Conversion between Orbit Representations

The conversion between the orbit representations can be performed using the following
functions:

- `kepler_to_rv`: Convert the Keplerian elements to Cartesian position and velocity.
- `kepler_to_sv`: Convert the Keplerian elements to orbit state vector.
- `rv_to_kepler`: Convert the Cartesian position and velocity to Keplerian elements.
- `sv_to_kepler`: Convert the orbit state vector to Keplerian elements.

Those functions accept the keyword `μ` to select the standard gravitational parameter of the
central body. For more information, see the built-in documentation of those functions.

All the representations can also be converted between each other using the Julia built-in
conversion system (`convert`), which uses the Earth as the central body:

```julia
julia> convert(KeplerianElements{MeanAnomaly}, sv)
julia> convert(EquinoctialElements, orb)
julia> convert(AlternateEquinoctialElements, convert(EquinoctialElements, orb))
julia> convert(OrbitStateVector{Float64, Float32}, orb_M)
```

#### Conversion between Orbit Anomalies

There are three types of anomalies (angles) that can be used to describe the position of the
satellite in the orbit plane with respect to the argument of perigee:

- The mean anomaly (`M`);
- The eccentric anomaly (`E`); and
- The true anomaly (`f`).

This package contains the following functions that can be used to convert one to another:

```julia
mean_to_eccentric_anomaly(e::Number, M::Number; kwargs...) -> T
mean_to_true_anomaly(e::Number, M::Number; kwargs...) -> T
eccentric_to_true_anomaly(e::Number, E::Number) -> T
eccentric_to_mean_anomaly(e::Number, E::Number) -> T
true_to_eccentric_anomaly(e::Number, f::Number) -> T
true_to_mean_anomaly(e::Number, f::Number) -> T
```

where:

- `M` is the mean anomaly [rad];
- `E` is the eccentric anomaly [rad];
- `f` is the true anomaly [rad];
- `e` is the eccentricity [-]; and
- `T` is the output type obtained by promoting the types of `e` and the input anomaly to
  float.

All the returned values are in [rad].

The functions `mean_to_eccentric_anomaly` and `mean_to_true_anomaly` use the Newton-Raphson
algorithm to solve the Kepler's equation. In this case, the following keywords are available
to configure it:

- `tol::Union{Nothing, Number}`: Tolerance to accept the solution from Newton-Raphson
    algorithm, applied to the residual of the Kepler's equation `|E - e sin(E) - M|`. If
    `tol` is `nothing`, it will be `eps(T) * max(1, M)`, which is the smallest residual that
    can be resolved in `T` given the magnitude of `M`.
    (**Default**: `nothing`)
- `max_iterations::Integer`: Maximum number of iterations allowed for the Newton-Raphson
    algorithm. It must be greater than or equal to 1, otherwise an `ArgumentError` is thrown.
    (**Default**: 10)

```julia
julia> mean_to_eccentric_anomaly(0.04, pi / 4)
0.814493281928579

julia> mean_to_true_anomaly(0.04, pi / 4)
0.8440031124631191

julia> true_to_mean_anomaly(0.04, pi / 4)
0.7300148523821107

julia> mean_to_true_anomaly(0, 0.343)
0.3430000000000001

julia> mean_to_true_anomaly(0.04, 0.343)
0.3712280339918371
```

### Time

> **Note**
> Julia already has some of the functionality implemented here.
> However, we use those functions for historical reasons or because the
> implementation here is more straightforward. For example, currently, we need
> to break an instant into year, month, day, hour, minute, second, and
> millisecond to convert it to Julian day using Julia's `Dates` package, where
> all terms must be `Integer`s. Here, `date_to_jd` accepts a floating-point
> seconds, leading to a easier initialization.

#### Converting epochs to Julian day

An epoch can be converted to Julian day using the function `date_to_jd`. This
function can receive:

- A set of numbers indicating the year, month, day, hour (24h-format), minute,
  and second;
- An object of type `Date`; or
- An object of type `DateTime`.

```julia
julia> date_to_jd(1986, 6, 19, 18, 35, 10.123456)
2.446601274422725e6

julia> date_to_jd(1986, 6, 19)
2.4466005e6

julia> date_to_jd(Date(1986, 6, 19))
2.4466005e6

julia> date_to_jd(DateTime(1986, 6, 19, 18, 35, 10))
2.446601274421296e6
```

#### Converting Julian day to epochs

We can convert a Julian day to an epoch using the function `jd_to_date`. Its
signature is:

```julia
jd_to_date([T,] JD::Number)
```

where `T` is the converted object format.

If `T` is omitted or `Int`, then a tuple with the following data will be
returned:

- Year.
- Month (`1` => **January**, `2` => **February**, ...).
- Day.
- Hour (0 - 24).
- Minute (0 - 59).
- Second (0 - 59).

Notice that if `T` is `Int`, the seconds field will be rounded to an `Int`.
Otherwise, it will be floating point.

If `T` is `Date`, it will return the Julia structure `Date`. Notice that the
hours, minutes, and seconds will be neglected because the structure `Date` does
not support them.

If `T` is `DateTime`, it will return the Julia structure `DateTime`.

```julia
julia> jd_to_date(2.446601274422725e6)
(1986, 6, 19, 18, 35, 10.1234570145607)

julia> jd_to_date(Int, 2.446601274422725e6)
(1986, 6, 19, 18, 35, 10)

julia> jd_to_date(Date, 2.446601274422725e6)
1986-06-19

julia> jd_to_date(DateTime, 2.446601274422725e6)
1986-06-19T18:35:10.123
```

#### Greenwich mean sidereal time

The function `jd_to_gmst` converts a Julian day into the Greenwich mean sidereal
time [rad]:

```julia
julia> jd_to_gmst(2.446601274422725e6)
3.2547373166809748
```
