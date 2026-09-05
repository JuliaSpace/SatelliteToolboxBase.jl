## Description #############################################################################
#
# Functions to convert anomalies related to the orbit.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export mean_to_eccentric_anomaly, mean_to_true_anomaly
export eccentric_to_true_anomaly, eccentric_to_mean_anomaly
export true_to_eccentric_anomaly, true_to_mean_anomaly

############################################################################################
#                                     Private Functions                                    #
############################################################################################

# Wrap the angle `x` [rad] to the interval [0, 2π).
#
# `mod(x, 2π)` alone is not enough because it returns `2π` when `x` is a tiny negative
# number, since `2π + x` rounds to `2π` in floating point.
@inline function _wrap_to_2π(x::T) where {T <: AbstractFloat}
    y = mod(x, T(2π))
    return y == T(2π) ? zero(T) : y
end

############################################################################################
#                                    From Mean Anomaly                                     #
############################################################################################

"""
    mean_to_eccentric_anomaly(e::T1, M::T2; kwargs...) where {T1, T2} -> T

Compute the eccentric anomaly [0, 2π) [rad] given the orbit eccentricity `e` and the mean
anomaly `M` [rad].

This function uses the Newton-Raphson algorithm to solve the Kepler's equation.

!!! note

    The output type `T` is obtained by promoting `T1` and `T2` to float.

# Keywords

- `tol::Union{Nothing, Number}`: Tolerance to accept the solution from Newton-Raphson
    algorithm, applied to the residual of the Kepler's equation `|E - e sin(E) - M|`. If
    `tol` is `nothing`, it will be `eps(T) * max(1, M)`, which is the smallest residual that
    can be resolved in `T` given the magnitude of `M`.
    (**Default** = `nothing`)
- `max_iterations::Integer`: Maximum number of iterations allowed for the Newton-Raphson
    algorithm. If it is lower than 1, then it is set to 10.
    (**Default** = 10)
"""
function mean_to_eccentric_anomaly(
    e::T1, M::T2; max_iterations::Integer = 10, tol::Union{Nothing, Number} = nothing
) where {T1, T2}
    T = float(promote_type(T1, T2))

    # == Compute the Eccentric Anomaly Using the Newton-Raphson method =====================

    # Make sure that M is in the interval [0, 2π).
    M = _wrap_to_2π(T(M))
    e = T(e)

    # Initial guess.
    #
    # See [1, p. 75].
    E = (M > π) ? M - e : M + e

    sin_E, cos_E = sincos(E)

    # Check the tolerance.
    #
    # The residual `E - e * sin(E) - M` cannot be resolved below the rounding error of `M`
    # in `T`. Hence, we scale the default tolerance by the magnitude of `M`, which avoids
    # spending iterations that cannot improve the solution.
    δ = isnothing(tol) ? eps(T) * max(one(T), M) : T(tol)

    # Check the maximum number of iterations.
    if max_iterations < 1
        max_iterations = 10
    end

    # Newton-Raphson iterations.
    for _ in 1:max_iterations
        residual = E - e * sin_E - M
        abs(residual) ≤ δ && break
        E -= residual / (1 - e * cos_E)
        sin_E, cos_E = sincos(E)
    end

    # Return the eccentric anomaly in the interval [0, 2π).
    return _wrap_to_2π(E)
end

"""
    mean_to_true_anomaly(e::T1, M::T2; kwargs...) where {T1, T2} -> T

Compute the true anomaly [0, 2π) [rad] given the orbit eccentricity `e` and the mean anomaly
`M` [rad].

This function uses the Newton-Raphson algorithm to solve the Kepler's equation.

!!! note

    The output type `T` is obtained by promoting `T1` and `T2` to float.

# Keywords

- `tol::Union{Nothing, Number}`: Tolerance to accept the solution from Newton-Raphson
    algorithm, applied to the residual of the Kepler's equation `|E - e sin(E) - M|`. If
    `tol` is `nothing`, it will be `eps(T) * max(1, M)`, which is the smallest residual that
    can be resolved in `T` given the magnitude of `M`.
    (**Default** = `nothing`)
- `max_iterations::Integer`: Maximum number of iterations allowed for the Newton-Raphson
    algorithm. If it is lower than 1, then it is set to 10.
    (**Default** = 10)
"""
function mean_to_true_anomaly(e::T1, M::T2; kwargs...) where {T1, T2}
    # Compute the eccentric anomaly.
    E = mean_to_eccentric_anomaly(e, M; kwargs...)

    # Compute the true anomaly in the interval [0, 2π].
    return eccentric_to_true_anomaly(e, E)
end

############################################################################################
#                                  From Eccentric Anomaly                                  #
############################################################################################

"""
    eccentric_to_true_anomaly(e::T1, E::T2) where {T1, T2} -> T

Compute the true anomaly [0, 2π) [rad] given the orbit eccentricity `e` and the eccentric
anomaly `E` [rad].

!!! note

    The output type `T` is obtained by promoting `T1` and `T2` to float.
"""
function eccentric_to_true_anomaly(e::T1, E::T2) where {T1, T2}
    T = float(promote_type(T1, T2))
    sin_Eo2, cos_Eo2 = sincos(T(E) / 2)

    # Compute the true anomaly in the interval [0, 2*π].
    return _wrap_to_2π(2atan(√(1 + T(e)) * sin_Eo2, √(1 - T(e)) * cos_Eo2))
end

"""
    eccentric_to_mean_anomaly(e::T1, E::T2) where {T1, T2} -> T

Compute the mean anomaly [0, 2π) [rad] given the orbit eccentricity `e` and the eccentric
anomaly `E` [rad].

!!! note

    The output type `T` is obtained by promoting `T1` and `T2` to float.
"""
function eccentric_to_mean_anomaly(e::T1, E::T2) where {T1, T2}
    T = float(promote_type(T1, T2))
    return _wrap_to_2π(T(E) - T(e) * sin(T(E)))
end

############################################################################################
#                                    From True Anomaly                                     #
############################################################################################

"""
    true_to_eccentric_anomaly(e::T1, f::T2) where {T1, T2} -> T

Compute the eccentric anomaly [0, 2π) [rad] given the orbit eccentricity `e` and the true
anomaly `f` [rad].

!!! note

    The output type `T` is obtained by promoting `T1` and `T2` to float.
"""
function true_to_eccentric_anomaly(e::T1, f::T2) where {T1, T2}
    T = float(promote_type(T1, T2))
    sin_fo2, cos_fo2 = sincos(T(f) / 2)

    return _wrap_to_2π(2atan(√(1 - T(e)) * sin_fo2, √(1 + T(e)) * cos_fo2))
end

"""
    true_to_mean_anomaly(e::T1, f::T2) where {T1, T2} -> T

Compute the mean anomaly [0, 2π) [rad] given the orbit eccentricity `e` and the true anomaly
`f` [rad].

!!! note

    The output type `T` is obtained by promoting `T1` and `T2` to float.
"""
function true_to_mean_anomaly(e::T1, f::T2) where {T1, T2}
    # Compute the eccentric anomaly.
    E = true_to_eccentric_anomaly(e, f)

    # Compute the mean anomaly in the interval [0, 2π).
    return eccentric_to_mean_anomaly(e, E)
end
