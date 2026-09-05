## Description #############################################################################
#
# Types and structures related to orbit representation.
#
############################################################################################

export Orbit, KeplerianElements
export AbstractEquinoctialElements, EquinoctialElements, AlternateEquinoctialElements
export OrbitStateVector

"""
    abstract type Orbit{Tepoch <: Number, T <: Number}

Abstract type of an orbit representation with epoch type `Tepoch` and element type `T`.
"""
abstract type Orbit{Tepoch <: Number, T <: Number} end

############################################################################################
#                                    Keplerian Elements                                    #
############################################################################################

"""
    struct KeplerianElements{Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Orbit representation in terms of the Keplerian elements.

The parameter `Tanomaly` selects which anomaly is stored in the field `anomaly`. It must be
one of `TrueAnomaly`, `EccentricAnomaly`, or `MeanAnomaly`. Use the functions
[`true_anomaly`](@ref), [`eccentric_anomaly`](@ref), and [`mean_anomaly`](@ref) to obtain
the anomaly in a specific form regardless of `Tanomaly`.

The time scale of `epoch` is the one adopted by the caller (typically UTC), since this
package does not convert between time scales.

# Fields

- `epoch::Tepoch`: Epoch [Julian Day].
- `semi_major_axis::T`: Semi-major axis [m].
- `eccentricity::T`: Eccentricity [-].
- `inclination::T`: Inclination [rad].
- `raan::T`: Right ascension of the ascending node [rad].
- `argument_of_periapsis::T`: Argument of periapsis [rad].
- `anomaly::T`: Anomaly [rad], where the type depends on the parameter `Tanomaly`.

# Remarks

For backward compatibility, the following short property names are also available: `t`
(epoch), `a` (semi-major axis), `e` (eccentricity), `i` (inclination), `Ω` (RAAN), `ω`
(argument of periapsis), and `f` (**true** anomaly, converted from the stored anomaly if
necessary).

# Extended help

## Conversions

The Julia built-in function `convert` accepts the following targets:

- `KeplerianElements{Tanomaly}` and `KeplerianElements{Tanomaly, Tepoch, T}`: Change the
    stored anomaly and the numeric types. The anomaly conversions use the default settings
    of the Kepler's equation solver.
- `EquinoctialElements` and `EquinoctialElements{Tepoch, T}`: Throw an `ArgumentError` for
    retrograde equatorial orbits (`i = π`), where the equinoctial elements are singular.
- `AlternateEquinoctialElements` and `AlternateEquinoctialElements{Tepoch, T}`.
- `OrbitStateVector` and `OrbitStateVector{Tepoch, T}`: Use [`kepler_to_sv`](@ref) with the
    Earth's standard gravitational parameter `GM_EARTH`. Call that function directly with
    the keyword `μ` for an orbit around another central body.

Omitted type parameters are taken from the input. The conversions to other representations
are computed in the promoted numeric type of the input and the target.

## Printing

`show(io, orbit)` prints the compact form: the type with its parameters and the epoch as a
Julian Day and as a date. `show(io, MIME("text/plain"), orbit)` prints one element per line
with its unit, aligned at the decimal point, with the labels in bold if `io` supports color.

## Iteration

The object behaves as a collection with a single element (`length`, `iterate`, and `eltype`
are defined), so it can be used in broadcasting.
"""
struct KeplerianElements{Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number} <:
       Orbit{Tepoch, T}
    epoch::Tepoch

    semi_major_axis::T

    eccentricity::T

    inclination::T

    raan::T

    argument_of_periapsis::T

    anomaly::T
end

"""
    KeplerianElements(
        epoch::Tepoch,
        semi_major_axis::T1,
        eccentricity::T2,
        inclination::T3,
        raan::T4,
        argument_of_periapsis::T5,
        anomaly::T6,
    ) -> KeplerianElements{TrueAnomaly, Tepoch, T}
    KeplerianElements{Tanomaly}(
        epoch::Tepoch,
        semi_major_axis::T1,
        eccentricity::T2,
        inclination::T3,
        raan::T4,
        argument_of_periapsis::T5,
        anomaly::T6,
    ) -> KeplerianElements{Tanomaly, Tepoch, T}

Create a Keplerian elements object with `epoch` [Julian Day], `semi_major_axis` [m],
`eccentricity` [-], `inclination` [rad], `raan` [rad], `argument_of_periapsis` [rad], and
`anomaly` [rad]. The type of the anomaly is determined by the parameter `Tanomaly`. If it is
omitted, the default is `TrueAnomaly`.

The object type `T` is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6` to
float.
"""
function KeplerianElements(
    epoch::Number,
    semi_major_axis::Number,
    eccentricity::Number,
    inclination::Number,
    raan::Number,
    argument_of_periapsis::Number,
    anomaly::Number,
)
    return KeplerianElements{TrueAnomaly}(
        epoch,
        semi_major_axis,
        eccentricity,
        inclination,
        raan,
        argument_of_periapsis,
        anomaly,
    )
end

function KeplerianElements{Tanomaly}(
    epoch::Tepoch,
    semi_major_axis::T1,
    eccentricity::T2,
    inclination::T3,
    raan::T4,
    argument_of_periapsis::T5,
    anomaly::T6,
) where {
    Tanomaly <: AbstractAnomaly,
    Tepoch <: Number,
    T1 <: Number,
    T2 <: Number,
    T3 <: Number,
    T4 <: Number,
    T5 <: Number,
    T6 <: Number,
}
    T = float(promote_type(T1, T2, T3, T4, T5, T6))
    return KeplerianElements{Tanomaly, Tepoch, T}(
        epoch,
        semi_major_axis,
        eccentricity,
        inclination,
        raan,
        argument_of_periapsis,
        anomaly,
    )
end

############################################################################################
#                                   Equinoctial Elements                                   #
############################################################################################

"""
    abstract type AbstractEquinoctialElements{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Abstract type of the orbit representations based on the equinoctial elements, which share
the fields `epoch`, `semi_major_axis`, `h`, `k`, `p`, `q`, and `mean_longitude`. The
concrete sets differ only in how `p` and `q` encode the inclination. See
[`EquinoctialElements`](@ref) and [`AlternateEquinoctialElements`](@ref).
"""
abstract type AbstractEquinoctialElements{Tepoch <: Number, T <: Number} <:
              Orbit{Tepoch, T} end

"""
    struct EquinoctialElements{Tepoch <: Number, T <: Number} <: AbstractEquinoctialElements{Tepoch, T}

Orbit representation in terms of the equinoctial elements **[1]**. Given the Keplerian
elements `a`, `e`, `i`, `Ω`, `ω`, and the mean anomaly `M`, the equinoctial elements are:

    h = e * sin(ω + Ω)
    k = e * cos(ω + Ω)
    p = tan(i / 2) * sin(Ω)
    q = tan(i / 2) * cos(Ω)
    λ = Ω + ω + M

This set is non-singular for circular (`e = 0`) and equatorial (`i = 0`) orbits.

The time scale of `epoch` is the one adopted by the caller (typically UTC), since this
package does not convert between time scales.

!!! warning

    The equinoctial elements are singular for retrograde equatorial orbits (`i = π`),
    because `tan(i / 2)` diverges. Converting Keplerian elements whose inclination is so
    close to `π` that `tan(i / 2)` exceeds `1 / eps(T)` throws an `ArgumentError`.

# Fields

- `epoch::Tepoch`: Epoch [Julian Day].
- `semi_major_axis::T`: Semi-major axis [m].
- `h::T`: h = e * sin(ω + Ω) [-].
- `k::T`: k = e * cos(ω + Ω) [-].
- `p::T`: p = tan(i / 2) * sin(Ω) [-].
- `q::T`: q = tan(i / 2) * cos(Ω) [-].
- `mean_longitude::T`: Mean longitude λ = Ω + ω + M [rad].

# References

- **[1]** Broucke, R. A., Cefola, P. J (1972). On the equinoctial orbit elements. Celestial
    Mechanics, v. 5, p. 303-310.

# Extended help

## Conversions

The Julia built-in function `convert` accepts the following targets:

- `EquinoctialElements{Tepoch, T}`: Change the numeric types.
- `AlternateEquinoctialElements` and `AlternateEquinoctialElements{Tepoch, T}`: Replace
    `tan(i / 2)` by `sin(i / 2)` in `p` and `q` without solving the Kepler's equation.
- `KeplerianElements`, `KeplerianElements{Tanomaly}`, and
    `KeplerianElements{Tanomaly, Tepoch, T}`: Store the anomaly `Tanomaly` (`TrueAnomaly` if
    omitted) and return the RAAN, the argument of periapsis, and the anomaly in the interval
    [0, 2π).
- `OrbitStateVector` and `OrbitStateVector{Tepoch, T}`: Use [`kepler_to_sv`](@ref) with the
    Earth's standard gravitational parameter `GM_EARTH`. Call that function directly with
    the keyword `μ` for an orbit around another central body.

Omitted type parameters are taken from the input. The conversions to other representations
are computed in the promoted numeric type of the input and the target.

## Printing

`show(io, orbit)` prints the compact form: the type with its parameters and the epoch as a
Julian Day and as a date. `show(io, MIME("text/plain"), orbit)` prints one element per line
with its unit, aligned at the decimal point, with the labels in bold if `io` supports color.

## Iteration

The object behaves as a collection with a single element (`length`, `iterate`, and `eltype`
are defined), so it can be used in broadcasting.
"""
struct EquinoctialElements{Tepoch <: Number, T <: Number} <:
       AbstractEquinoctialElements{Tepoch, T}
    epoch::Tepoch

    semi_major_axis::T

    h::T

    k::T

    p::T

    q::T

    mean_longitude::T

    # == Constructors ======================================================================

    # This inner constructor avoids the automatic outer constructor, which would bypass the
    # float promotion when all the elements have the same type.
    function EquinoctialElements{Tepoch, T}(
        epoch, semi_major_axis, h, k, p, q, mean_longitude
    ) where {Tepoch <: Number, T <: Number}
        return new{Tepoch, T}(epoch, semi_major_axis, h, k, p, q, mean_longitude)
    end
end

"""
    EquinoctialElements(
        epoch::Tepoch,
        semi_major_axis::T1,
        h::T2,
        k::T3,
        p::T4,
        q::T5,
        mean_longitude::T6,
    ) -> EquinoctialElements{Tepoch, T}

Create an equinoctial elements object with `epoch` [Julian Day], `semi_major_axis` [m], `h`,
`k`, `p`, `q` [-], and `mean_longitude` [rad].

The object type `T` is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6` to
float.
"""
function EquinoctialElements(
    epoch::Tepoch, semi_major_axis::T1, h::T2, k::T3, p::T4, q::T5, mean_longitude::T6
) where {
    Tepoch <: Number,
    T1 <: Number,
    T2 <: Number,
    T3 <: Number,
    T4 <: Number,
    T5 <: Number,
    T6 <: Number,
}
    T = float(promote_type(T1, T2, T3, T4, T5, T6))
    return EquinoctialElements{Tepoch, T}(
        epoch, semi_major_axis, h, k, p, q, mean_longitude
    )
end

############################################################################################
#                              Alternate Equinoctial Elements                              #
############################################################################################

"""
    struct AlternateEquinoctialElements{Tepoch <: Number, T <: Number} <: AbstractEquinoctialElements{Tepoch, T}

Orbit representation in terms of the alternate equinoctial elements, which differ from the
equinoctial elements (see [`EquinoctialElements`](@ref)) only in the inclination elements,
where `sin(i / 2)` replaces `tan(i / 2)`. Given the Keplerian elements `a`, `e`, `i`, `Ω`,
`ω`, and the mean anomaly `M`, the alternate equinoctial elements are:

    h = e * sin(ω + Ω)
    k = e * cos(ω + Ω)
    p = sin(i / 2) * sin(Ω)
    q = sin(i / 2) * cos(Ω)
    λ = Ω + ω + M

This set is non-singular for circular (`e = 0`) and equatorial (`i = 0`) orbits. Unlike the
equinoctial elements, `p` and `q` are bounded (`p² + q² ≤ 1`) and finite for every
inclination, including `i = π`. Notice, however, that the RAAN and the argument of periapsis
of a retrograde equatorial orbit remain degenerate. This set is called "Alternate
Equinoctial" in GMAT and "Nonsingular Keplerian" in FreeFlyer.

The time scale of `epoch` is the one adopted by the caller (typically UTC), since this
package does not convert between time scales.

# Fields

- `epoch::Tepoch`: Epoch [Julian Day].
- `semi_major_axis::T`: Semi-major axis [m].
- `h::T`: h = e * sin(ω + Ω) [-].
- `k::T`: k = e * cos(ω + Ω) [-].
- `p::T`: p = sin(i / 2) * sin(Ω) [-].
- `q::T`: q = sin(i / 2) * cos(Ω) [-].
- `mean_longitude::T`: Mean longitude λ = Ω + ω + M [rad].

# Extended help

## Conversions

The Julia built-in function `convert` accepts the following targets:

- `AlternateEquinoctialElements{Tepoch, T}`: Change the numeric types.
- `EquinoctialElements` and `EquinoctialElements{Tepoch, T}`: Replace `sin(i / 2)` by
    `tan(i / 2)` in `p` and `q` without solving the Kepler's equation. Throw an
    `ArgumentError` for retrograde equatorial orbits (`i = π`), where the equinoctial
    elements are singular.
- `KeplerianElements`, `KeplerianElements{Tanomaly}`, and
    `KeplerianElements{Tanomaly, Tepoch, T}`: Store the anomaly `Tanomaly` (`TrueAnomaly` if
    omitted) and return the RAAN, the argument of periapsis, and the anomaly in the interval
    [0, 2π). Throw an `ArgumentError` if `p² + q² > 1`, which does not represent an orbit.
- `OrbitStateVector` and `OrbitStateVector{Tepoch, T}`: Use [`kepler_to_sv`](@ref) with the
    Earth's standard gravitational parameter `GM_EARTH`. Call that function directly with
    the keyword `μ` for an orbit around another central body.

Omitted type parameters are taken from the input. The conversions to other representations
are computed in the promoted numeric type of the input and the target.

## Printing

`show(io, orbit)` prints the compact form: the type with its parameters and the epoch as a
Julian Day and as a date. `show(io, MIME("text/plain"), orbit)` prints one element per line
with its unit, aligned at the decimal point, with the labels in bold if `io` supports color.

## Iteration

The object behaves as a collection with a single element (`length`, `iterate`, and `eltype`
are defined), so it can be used in broadcasting.
"""
struct AlternateEquinoctialElements{Tepoch <: Number, T <: Number} <:
       AbstractEquinoctialElements{Tepoch, T}
    epoch::Tepoch

    semi_major_axis::T

    h::T

    k::T

    p::T

    q::T

    mean_longitude::T

    # == Constructors ======================================================================

    # This inner constructor avoids the automatic outer constructor, which would bypass the
    # float promotion when all the elements have the same type.
    function AlternateEquinoctialElements{Tepoch, T}(
        epoch, semi_major_axis, h, k, p, q, mean_longitude
    ) where {Tepoch <: Number, T <: Number}
        return new{Tepoch, T}(epoch, semi_major_axis, h, k, p, q, mean_longitude)
    end
end

"""
    AlternateEquinoctialElements(
        epoch::Tepoch,
        semi_major_axis::T1,
        h::T2,
        k::T3,
        p::T4,
        q::T5,
        mean_longitude::T6,
    ) -> AlternateEquinoctialElements{Tepoch, T}

Create an alternate equinoctial elements object with `epoch` [Julian Day], `semi_major_axis`
[m], `h`, `k`, `p`, `q` [-], and `mean_longitude` [rad].

The object type `T` is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6` to
float.
"""
function AlternateEquinoctialElements(
    epoch::Tepoch, semi_major_axis::T1, h::T2, k::T3, p::T4, q::T5, mean_longitude::T6
) where {
    Tepoch <: Number,
    T1 <: Number,
    T2 <: Number,
    T3 <: Number,
    T4 <: Number,
    T5 <: Number,
    T6 <: Number,
}
    T = float(promote_type(T1, T2, T3, T4, T5, T6))
    return AlternateEquinoctialElements{Tepoch, T}(
        epoch, semi_major_axis, h, k, p, q, mean_longitude
    )
end

############################################################################################
#                                    Orbit State Vector                                    #
############################################################################################

"""
    struct OrbitStateVector{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Orbit representation in terms of the state vector (position, velocity, and acceleration).

The time scale of `epoch` is the one adopted by the caller (typically UTC), since this
package does not convert between time scales.

# Fields

- `epoch::Tepoch`: Epoch [Julian Day].
- `r::SVector{3, T}`: Position vector [m].
- `v::SVector{3, T}`: Velocity vector [m/s].
- `a::SVector{3, T}`: Acceleration vector [m/s²].

# Remarks

For backward compatibility, the property `t` is an alias for `epoch`.

# Extended help

## Conversions

The Julia built-in function `convert` accepts the following targets:

- `OrbitStateVector{Tepoch, T}`: Change the numeric types.
- `KeplerianElements`, `KeplerianElements{Tanomaly}`, and
    `KeplerianElements{Tanomaly, Tepoch, T}`: Store the anomaly `Tanomaly` (`TrueAnomaly` if
    omitted).
- `EquinoctialElements` and `EquinoctialElements{Tepoch, T}`.
- `AlternateEquinoctialElements` and `AlternateEquinoctialElements{Tepoch, T}`.

The conversions to the orbital elements use [`sv_to_kepler`](@ref) with the Earth's standard
gravitational parameter `GM_EARTH`. Call that function directly with the keyword `μ` for an
orbit around another central body. Omitted type parameters are taken from the input, and the
conversions are computed in the promoted numeric type of the input and the target.

## Printing

`show(io, orbit)` prints the compact form: the type with its parameters and the epoch as a
Julian Day and as a date. `show(io, MIME("text/plain"), orbit)` prints the epoch and the
position, velocity, and acceleration vectors, one per line with its unit, with the labels in
bold if `io` supports color.

## Iteration

The object behaves as a collection with a single element (`length`, `iterate`, and `eltype`
are defined), so it can be used in broadcasting.
"""
struct OrbitStateVector{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}
    epoch::Tepoch

    r::SVector{3, T}

    v::SVector{3, T}

    a::SVector{3, T}

    # == Constructors ======================================================================

    # This inner constructor avoids the automatic outer constructor, which would bypass the
    # float promotion when all the vectors are `SVector`s with the same element type.
    function OrbitStateVector{Tepoch, T}(
        epoch, r, v, a
    ) where {Tepoch <: Number, T <: Number}
        return new{Tepoch, T}(epoch, r, v, a)
    end
end

"""
    OrbitStateVector(
        epoch::Tepoch,
        r::AbstractVector{Tr},
        v::AbstractVector{Tv},
        a::AbstractVector{Ta},
    ) -> OrbitStateVector{Tepoch, T}
    OrbitStateVector(
        epoch::Tepoch,
        r::AbstractVector{Tr},
        v::AbstractVector{Tv},
    ) -> OrbitStateVector{Tepoch, T}

Create an orbit state vector with `epoch` [Julian Day], position `r` [m], velocity `v`
[m/s], and acceleration `a` [m/s²]. If the latter is omitted, it will be filled with
`[0, 0, 0]`.

The object type `T` is obtained by promoting `Tr`, `Tv`, and `Ta` to float.
"""
function OrbitStateVector(
    epoch::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}, a::AbstractVector{Ta}
) where {Tepoch <: Number, Tr <: Number, Tv <: Number, Ta <: Number}
    T = float(promote_type(Tr, Tv, Ta))
    return OrbitStateVector{Tepoch, T}(epoch, r, v, a)
end

function OrbitStateVector(
    epoch::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}
) where {Tepoch <: Number, Tr <: Number, Tv <: Number}
    T = float(promote_type(Tr, Tv))
    a = @SVector zeros(T, 3)
    return OrbitStateVector(epoch, r, v, a)
end
