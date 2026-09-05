## Description #############################################################################
#
# Conversion from the Keplerian elements to position and velocity state vector.
#
## References ##############################################################################
#
# [1] Schwarz, R (2014). Memorandum No. 2: Cartesian State Vectors to Keplerian Orbit
#     Elements. Available at www.rene-schwarz.com.
#
#     https://downloads.rene-schwarz.com/dc/category/18
#     (Accessed on 2017-08-09).
#
# [2] Kuga, H. K., Carrara, V., Rao, K. R (2005). Introdução à Mecânica Orbital. 2ª ed.
#     Instituto Nacional de Pesquisas Espaciais.
#
############################################################################################

export kepler_to_rv

"""
    kepler_to_rv(ke::KeplerianElements{Tanomaly, Tepoch, T}; kwargs...) -> SVector{3, T}, SVector{3, T}

Convert the Keplerian elements `ke` to a Cartesian representation (position vector `r` [m]
and velocity vector `v` [m/s]). The eccentricity of `ke` must be in the interval [0, 1).

!!! note

    The returned vectors are represented in the same reference frame as the Keplerian
    elements.

# Keywords

- `μ::Number`: Standard gravitational parameter of the central body [m³/s²].
    (**Default**: `GM_EARTH`)

# Returns

- `SVector{3, T}`: The position vector represented in the inertial reference frame [m].
- `SVector{3, T}`: The velocity vector represented in the inertial reference frame [m/s].

# Remarks

This algorithm was adapted from **[1]** and **[2]** (p. 37-38).

# References

- **[1]**: Schwarz, R (2014). Memorandum No. 2: Cartesian State Vectors to Keplerian Orbit
    Elements. Available at www.rene-schwarz.com.
- **[2]**: Kuga, H. K., Carrara, V., Rao, K. R (2005). Introdução à Mecânica Orbital. 2ª ed.
    Instituto Nacional de Pesquisas Espaciais.

# Extended help

## Throws

- `ArgumentError`: If the eccentricity is not in the interval [0, 1).
"""
function kepler_to_rv(
    ke::KeplerianElements{Tanomaly, Tepoch, T}; μ::Number = GM_EARTH
) where {Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number}
    # Check the eccentricity.
    e = ke.eccentricity
    !(0 <= e < 1) &&
        throw(ArgumentError("The eccentricity must be in the interval [0, 1)."))

    # Unpack.
    a = ke.semi_major_axis
    i = ke.inclination
    Ω = ke.raan
    ω = ke.argument_of_periapsis
    f = true_anomaly(ke)

    # Auxiliary variables.
    sin_f, cos_f = sincos(f)
    e² = e * e

    # Compute the distance to the center of the central body.
    r = a * (1 - e²) / (1 + e * cos_f)

    # Compute the position vector in the orbit plane, defined as:
    #   - The X axis points towards the periapsis;
    #   - The Z axis is perpendicular to the orbital plane (right-hand);
    #   - The Y axis completes a right-hand coordinate system.
    r_o = SVector{3, T}(r * cos_f, r * sin_f, 0)

    # Compute the velocity vector in the orbit plane without perturbations.
    n₀  = √(T(μ) / T(a)^3)
    v_o = n₀ * a / sqrt(1 - e²) * SVector{3, T}(-sin_f, e + cos_f, 0)

    # Compute the matrix that rotates the orbit reference frame into the inertial reference
    # frame.
    D_i_o = angle_to_dcm(-ω, -i, -Ω, :ZXZ)

    # Compute the position and velocity represented in the inertial frame.
    r_i = D_i_o * r_o
    v_i = D_i_o * v_o

    return r_i, v_i
end
