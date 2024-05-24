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
    rv_to_kepler(r_i::AbstractVector{T1}, v_i::AbstractVector{T2}, t::T3 = 0) where {T1<:Number, T2<:Number, T3<:Number} -> KeplerianElements{Tepoch, T}

Convert a Cartesian representation (position vector `r_i` [m] and velocity vector `v_i`
[m / s]) to Keplerian elements. Optionally, the user can specify the epoch of the returned
elements using the parameter `t`. It it is omitted, then it defaults to 0.

!!! note

    The output type `Tepoch` is obtained by converting `T3` to float, whereas the output
    type `T` is obtained by promoting `T1` and `T2` and converting the result to float.

# Returns

- `KeplerianElements{Tepoch, T}`: The Keplerian elements [SI units].

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
"""
function rv_to_kepler(
    r_i::AbstractVector{T1},
    v_i::AbstractVector{T2},
    t::T3 = 0
) where {T1<:Number, T2<:Number, T3<:Number}
    # Check inputs.
    length(r_i) != 3 && error("The vector r_i must have 3 dimensions.")
    length(v_i) != 3 && error("The vector v_i must have 3 dimensions.")

    # Obtain the type of the output elements.
    Tepoch = float(T3)
    T      = float(promote_type(T1, T2))

    @inbounds begin
        # Convert the input vectors to `SVector` with the correct type.
        sr_i = SVector{3, T}(r_i[begin + 0], r_i[begin + 1], r_i[begin + 2])
        sv_i = SVector{3, T}(v_i[begin + 0], v_i[begin + 1], v_i[begin + 2])

        # Position and velocity vector norms and auxiliary dot products.
        r² = dot(sr_i, sr_i)
        v² = dot(sv_i, sv_i)
        r  = sqrt(r²)
        v  = sqrt(v²)
        rv = dot(sr_i, sv_i)

        μ  = T(GM_EARTH)

        # Angular momentum vector.
        h_i = sr_i × sv_i
        h   = norm(h_i)

        # Vector that points to the right ascension of the ascending node (RAAN).
        n_i = SVector{3}(0, 0, 1) × h_i
        n   = norm(n_i)

        # Eccentricity vector.
        e_i = ((v² - μ / r) * sr_i - rv * sv_i ) / μ

        # Orbit energy.
        ξ = v² / 2 - μ / r

        # == Eccentricity ==================================================================

        ecc = norm(e_i)

        # == Semi-major axis ===============================================================

        if abs(ecc) <= 1 - 1e-6
            a = -μ / (2ξ)
        else
            throw(ArgumentError("""
                Could not convert the provided Cartesian values to Kepler elements.
                The computed eccentricity was not between 0 and 1."""
            ))
        end

        # == Inclination ===================================================================

        cos_i = h_i[3] / h
        cos_i = abs(cos_i) > 1 ? sign(cos_i) : cos_i
        i     = acos(cos_i)

        # == Check the Type of the Orbit to Account for Special Cases ======================

        # -- Equatorial --------------------------------------------------------------------

        if abs(n) <= 1e-6

            # == Right Ascension of the Ascending Node. ====================================

            Ω = T(0)

            # -- Equatorial and Elliptical -------------------------------------------------

            if abs(ecc) > 1e-6

                # == Argument of Perigee ===================================================

                cos_ω = e_i[1] / ecc
                cos_ω = abs(cos_ω) > 1 ? sign(cos_ω) : cos_ω
                ω     = acos(cos_ω)

                if e_i[2] < 0
                    ω = T(2π) - ω
                end

                # == True Anomaly ==========================================================

                cos_f = dot(e_i, sr_i) / (ecc * r)
                cos_f = abs(cos_f) > 1 ? sign(cos_f) : cos_f
                f     = acos(cos_f)

                if rv < 0
                    f = T(2π) - f
                end

            # -- Equatorial and Circular ---------------------------------------------------

            else
                # == Argument of Perigee ===================================================

                ω = T(0)

                # == True Anomaly ==========================================================

                cos_f = sr_i[1] / r
                cos_f = abs(cos_f) > 1 ? sign(cos_f) : cos_f
                f     = acos(cos_f)

                if sr_i[2] < 0
                    f = T(2π) - f
                end
            end

        # -- Inclined ----------------------------------------------------------------------
        else

            # == Right Ascension of the Ascending Node =====================================

            cos_Ω = n_i[1] / n
            cos_Ω = abs(cos_Ω) > 1 ? sign(cos_Ω) : cos_Ω
            Ω     = acos(cos_Ω)

            if n_i[2] < 0
                Ω = T(2π) - Ω
            end

            # -- Circular and Inclined -----------------------------------------------------

            if abs(ecc) < 1e-6

                # == Argument of Perigee ===================================================

                ω = T(0)

                # == True Anomaly ==========================================================

                cos_f = dot(n_i, sr_i) / (n * r)
                cos_f = abs(cos_f) > 1 ? sign(cos_f) : cos_f
                f     = acos(cos_f)

                if sr_i[3] < 0
                    f = T(2π) - f
                end
            else

                # == Argument of Perigee ===================================================

                cos_ω = dot(n_i, e_i) / (n * ecc)
                cos_ω = abs(cos_ω) > 1 ? sign(cos_ω) : cos_ω
                ω     = acos(cos_ω)

                if e_i[3] < 0
                    ω = T(2π) - ω
                end

                # == True Anomaly ==========================================================

                cos_f = dot(e_i, sr_i) / (ecc * r)
                cos_f = abs(cos_f) > 1 ? sign(cos_f) : cos_f
                f     = acos(cos_f)

                if rv < 0
                    f = T(2π) - f
                end
            end
        end
    end

    # Return the Keplerian elements.
    return KeplerianElements(Tepoch(t), a, ecc, i, Ω, ω, f)
end
