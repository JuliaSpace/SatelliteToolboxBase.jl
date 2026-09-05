## Description #############################################################################
#
# Conversion from position and velocity state vector to Keplerian elements.
#
## References ##############################################################################
#
# [1] Schwarz, R (2014). Memorandum No. 2: Cartesian State Vectors to Keplerian Orbit
#     Elements. Available at www.rene-schwarz.com.
#
#     https://downloads.rene-schwarz.com/dc/category/18
#     (Accessed on 2017-08-09).
#
############################################################################################

export rv_to_kepler

"""
    rv_to_kepler(r_i::AbstractVector{T1}, v_i::AbstractVector{T2}, epoch::T3 = 0; kwargs...) -> KeplerianElements{TrueAnomaly, Tepoch, T}

Convert a Cartesian representation (position vector `r_i` [m] and velocity vector `v_i`
[m/s]) to Keplerian elements with the `epoch` [Julian Day], which defaults to 0. The vectors
must have three elements, and the orbit must be elliptical.

!!! note

    The output type `Tepoch` is obtained by converting `T3` to float, whereas the output
    type `T` is obtained by promoting `T1` and `T2` and converting the result to float.

# Keywords

- `μ::Number`: Standard gravitational parameter of the central body [m³/s²].
    (**Default**: `GM_EARTH`)

# Returns

- `KeplerianElements{TrueAnomaly, Tepoch, T}`: The Keplerian elements [SI units].

# Remarks

The algorithm was adapted from **[1]**.

The special cases are treated as follows:

- **Circular and equatorial**: the right ascension of the ascending node and the argument of
    perigee are set to 0. Hence, the true anomaly is equal to the true longitude.
- **Elliptical and equatorial**: the right ascension of the ascending node is set to 0.
    Hence, the argument of perigee is equal to the longitude of periapsis.
- **Circular and inclined**: the argument of perigee is set to 0. Hence, the true anomaly is
    equal to the argument of latitude.

# References

- **[1]**: Schwarz, R (2014). Memorandum No. 2: Cartesian State Vectors to Keplerian Orbit
    Elements. Available at www.rene-schwarz.com.

# Extended help

## Throws

- `DimensionMismatch`: If `r_i` or `v_i` does not have three elements.
- `ArgumentError`: If the computed eccentricity is not lower than 1, i.e., the orbit is not
    elliptical.
"""
function rv_to_kepler(
    r_i::AbstractVector{T1}, v_i::AbstractVector{T2}, epoch::T3 = 0; μ::Number = GM_EARTH
) where {T1 <: Number, T2 <: Number, T3 <: Number}
    # Check inputs.
    length(r_i) != 3 && throw(DimensionMismatch("The vector r_i must have 3 elements."))
    length(v_i) != 3 && throw(DimensionMismatch("The vector v_i must have 3 elements."))

    # Obtain the type of the output elements.
    Tepoch = float(T3)
    T      = float(promote_type(T1, T2))

    # Convert the input vectors to `SVector` with the correct type. The lengths were checked
    # above, so we can skip the bounds checking.
    sr_i = @inbounds SVector{3, T}(r_i[begin], r_i[begin + 1], r_i[begin + 2])
    sv_i = @inbounds SVector{3, T}(v_i[begin], v_i[begin + 1], v_i[begin + 2])

    # Position vector norm, velocity squared norm, and auxiliary dot product.
    r  = sqrt(dot(sr_i, sr_i))
    v² = dot(sv_i, sv_i)
    rv = dot(sr_i, sv_i)

    μ = T(μ)

    # Angular momentum vector.
    h_i = sr_i × sv_i
    h   = norm(h_i)

    # Vector that points to the right ascension of the ascending node (RAAN), which is the
    # cross product between the Z axis and the angular momentum vector.
    n_i = SVector{3, T}(-h_i[2], h_i[1], 0)
    n   = norm(n_i)

    # Eccentricity vector.
    e_i = ((v² - μ / r) * sr_i - rv * sv_i) / μ

    # Orbit energy.
    ξ = v² / 2 - μ / r

    # == Eccentricity ======================================================================

    ecc = norm(e_i)

    abs(ecc) <= 1 - 1e-6 || throw(
        ArgumentError(
            "The computed eccentricity is not lower than 1, so the orbit is not elliptical."
        )
    )

    # == Semi-major Axis ===================================================================

    a = -μ / (2ξ)

    # == Inclination =======================================================================

    i = _angle_from_cos(h_i[3] / h, false)

    # == Special Cases =====================================================================

    # The angles that are undefined in the special cases are set to 0. See the docstring.

    if abs(n) <= 1e-6
        # -- Equatorial --------------------------------------------------------------------

        Ω = T(0)

        if abs(ecc) > 1e-6
            # .. Equatorial and Elliptical .................................................

            ω = _angle_from_cos(e_i[1] / ecc, e_i[2] < 0)
            f = _angle_from_cos(dot(e_i, sr_i) / (ecc * r), rv < 0)
        else
            # .. Equatorial and Circular ...................................................

            ω = T(0)
            f = _angle_from_cos(sr_i[1] / r, sr_i[2] < 0)
        end
    else
        # -- Inclined ----------------------------------------------------------------------

        Ω = _angle_from_cos(n_i[1] / n, n_i[2] < 0)

        if abs(ecc) < 1e-6
            # .. Inclined and Circular .....................................................

            ω = T(0)
            f = _angle_from_cos(dot(n_i, sr_i) / (n * r), sr_i[3] < 0)
        else
            # .. Inclined and Elliptical ...................................................

            ω = _angle_from_cos(dot(n_i, e_i) / (n * ecc), e_i[3] < 0)
            f = _angle_from_cos(dot(e_i, sr_i) / (ecc * r), rv < 0)
        end
    end

    return KeplerianElements{TrueAnomaly}(Tepoch(epoch), a, ecc, i, Ω, ω, f)
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _angle_from_cos(cos_x::T, negative::Bool) -> T

Return the angle `x` [rad] in the interval [0, 2π] whose cosine is `cos_x`, clamped to the
interval [-1, 1] to absorb rounding errors. If `negative` is `true`, meaning that `x` lies
in the interval (π, 2π), the returned angle is `2π - acos(cos_x)`. Otherwise, it is
`acos(cos_x)`.
"""
function _angle_from_cos(cos_x::T, negative::Bool) where {T <: Number}
    x = acos(clamp(cos_x, -one(T), one(T)))
    return negative ? T(2π) - x : x
end
