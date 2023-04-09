SatelliteToolboxBase.jl
=======================

[![CI](https://github.com/JuliaSpace/SatelliteToolboxBase.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaSpace/SatelliteToolboxBase.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/JuliaSpace/SatelliteToolboxBase.jl/branch/main/graph/badge.svg?token=YADU7IB8CT)](https://codecov.io/gh/JuliaSpace/SatelliteToolboxBase.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package contains base functions and type definitions for the
**SatelliteToolbox.jl** ecosystem.

> **Note**
> This package contains only basic definitions used for other packages in the
> **SatelliteToolbox.jl**. You will need to install other packages to perform analyses and
> studies.

## Installation

``` julia
julia> using Pkg
julia> Pkg.install("SatelliteToolboxTimeBase")
```

## Usage

### Constants

We define and export the following constants in this package:

| Constant              | Description                                                            |
|:----------------------|:-----------------------------------------------------------------------|
| `GM_EARTH`            | Earth's standard gravitational parameter.                              |
| `EARTH_ANGULAR_SPEED` | Earth's angular speed without LOD correction.                          |
| `WGS84_ELLIPSOID`     | The WGS-84 ellipsoid defined using the structure `Ellipsoid{Float64}`. |
| `WGS84_ELLIPSOID_F32` | The WGS-84 ellipsoid defined using the structure `Ellipsoid{Float32}`. |
| `EGM08_J2`            | J2 perturbation term obtained from EGM-08 model.                       |
| `EGM08_J3`            | J3 perturbation term obtained from EGM-08 model.                       |
| `EGM08_J4`            | J4 perturbation term obtained from EGM-08 model.                       |
| `JD_J2000`            | Julian Day of J2000.0 epoch (2000-01-01T12:00:00.000).                 |

### Orbit

This package defines the abstract type `Orbit` for all orbit representations.

Currently, we defined two types to represent an orbit: `KeplerianElements` and
`OrbitStateVector`.

`KeplerianElements` defines an orbit in terms of the [Keplerian
elements](https://en.wikipedia.org/wiki/Orbital_elements). This object is created using the
function:

```julia
function KeplerianElements(t::Tepoch, a::T1, e::T2, i::T3, Ω::T4, ω::T5, f::T6)
```

where it returns an orbit representation using Keplerian elements with semi-major axis `a`
[m], eccentricity `e` [ ], inclination `i` [rad], right ascension of the ascending node `Ω`
[rad], argument of perigee `ω` [rad], and true anomaly `f` [rad].

```julia-repl
julia> orb = KeplerianElements(
           date_to_jd(1986, 6, 19, 18, 35, 0),
           7130.982e3,
              0.0001111,
             98.405 |> deg2rad,
            200.000 |> deg2rad,
             90.000 |> deg2rad,
            123.456 |> deg2rad,
       )
KeplerianElements{Float64, Float64}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98      km
    Eccentricity :    0.0001111
     Inclination :   98.405     °
            RAAN :  200.0       °
 Arg. of Perigee :   90.0       °
    True Anomaly :  123.456     °
```

`OrbitStateVector` defines the orbit in terms of the [object state
vector](https://en.wikipedia.org/wiki/Orbital_state_vectors). This object is created using
the function:

```julia
function OrbitStateVector(t::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}[, a::AbstractVector{Ta}])
```

where it creates an orbit state vector with epoch `t` [Julian Day], position `r`
[m], velocity `v` [m / s], and acceleration `a` [m / s²]. If the latter is
omitted, it will be filled with `[0, 0, 0]`.

``` julia-repl
julia> r_i = [6525.344; 6861.535; 6449.125] * 1000
3-element Vector{Float64}:
 6.525344e6
 6.861535e6
 6.449125e6

julia> v_i = [49.02276; 55.33124; -19.75709] * 1000
3-element Vector{Float64}:
  49022.759999999995
  55331.24
 -19757.09

julia> sv = OrbitStateVector(date_to_jd(1986, 6, 19, 18, 35, 0), r_i, v_i)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4466e6 (1986-06-19T18:35:00)
      r : [6525.34, 6861.53, 6449.12]   km
      v : [49.0228, 55.3312, -19.7571]  km/s
```

The conversion between the orbit representations can be performed using the following
functions:

- `kepler_to_rv`: Convert the Keplerian elements to Cartesian position and velocity.
- `kepler_to_sv`: convert the Keplerian elements to orbit state vector.
- `rv_to_kepler`: Convert the Cartesian position and velocity to Keplerian elements.
- `sv_to_kepler`: Convert the orbit state vector to Keplerian elements.

For more information, see the built-in documentation of those functions.

#### Conversion between Orbit Anomalies

There are three types of anomalies (angles) that can be used to describe the position of the
satellite in the orbit plane with respect to the argument of perigee:

- The mean anomaly (`M`);
- The eccentric anomaly (`E`); and
- The true anomaly (`f`).

This package contains the following functions that can be used to convert one to another:

```julia
function mean_to_eccentric_anomaly(e::Number, M::Number; kwargs...) -> T
function mean_to_true_anomaly(e::Number, M::Number; kwargs...) -> T
function eccentric_to_true_anomaly(e::Number, E::Number) -> T
function eccentric_to_mean_anomaly(e::Number, E::Number) -> T
function true_to_eccentric_anomaly(e::Number,f::Number) -> T
function true_to_mean_anomaly(e::Number, f::Number) -> T
```

where:

- `M` is the mean anomaly [rad];
- `E` is the eccentric anomaly [rad];
- `f` is the true anomaly [rad];
- `e` is the eccentricity.
- `T` is the output type obtained by promoting `T1` and `T2` to float.

All the returned values are in [rad].

The functions `mean_to_eccentric` and `mean_to_true` uses the Newton-Raphson algorithm to
solve the Kepler's equation. In this case, the following keywords are available to configure
it:

- `tol::Union{Nothing, Number}`: Tolerance to accept the solution from Newton-Raphson
    algorithm. If `tol` is `nothing`, then it will be `eps(T)`, where `T` is a
    floating-point type obtained from the promotion of `T1` and `T2` to a float.
    (**Default** = `nothing`)
- `max_iterations::Number`: Maximum number of iterations allowed for the Newton-Raphson
    algorithm. If it is lower than 1, then it is set to 10. (**Default** = 10)

```julia-repl
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
