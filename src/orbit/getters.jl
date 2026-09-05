## Description #############################################################################
#
# Getters for the orbits.
#
############################################################################################

export eccentric_anomaly, mean_anomaly, true_anomaly

############################################################################################
#                                    Keplerian Elements                                    #
############################################################################################

# == Property Aliases ======================================================================
#
# Those aliases are kept for backward compatibility. They are not recommended for new code.

"""
    Base.getproperty(orbit::KeplerianElements, sym::Symbol) -> Any

Return the property `sym` of `orbit`, supporting the legacy aliases `t` (epoch), `a`
(semi-major axis), `e` (eccentricity), `i` (inclination), `Ω` (RAAN), `ω` (argument of
periapsis), and `f` (true anomaly) besides the field names. The alias `f` always returns the
true anomaly, converting the stored anomaly if necessary.
"""
function Base.getproperty(orbit::KeplerianElements, sym::Symbol)
    sym === :t && return getfield(orbit, :epoch)
    sym === :a && return getfield(orbit, :semi_major_axis)
    sym === :e && return getfield(orbit, :eccentricity)
    sym === :i && return getfield(orbit, :inclination)
    sym === :Ω && return getfield(orbit, :raan)
    sym === :ω && return getfield(orbit, :argument_of_periapsis)
    sym === :f && return true_anomaly(orbit)
    return getfield(orbit, sym)
end

"""
    Base.propertynames(orbit::KeplerianElements, private::Bool = false) -> Tuple

Return the property names of `orbit`, including the legacy aliases.
"""
function Base.propertynames(::KeplerianElements, private::Bool = false)
    return (fieldnames(KeplerianElements)..., :t, :a, :e, :i, :Ω, :ω, :f)
end

# == Anomalies =============================================================================
#
# All getters accept `kwargs...`, which are forwarded to the Newton-Raphson solver of the
# Kepler's equation when the conversion from the mean anomaly is required. Otherwise, they
# are ignored.

# -- Eccentric Anomaly ---------------------------------------------------------------------

"""
    eccentric_anomaly(orbit::KeplerianElements{Tanomaly, Tepoch, T}; kwargs...) -> T

Return the eccentric anomaly [rad] of the `orbit`, converting the stored anomaly if it is not
already the eccentric anomaly.

# Keywords

The keywords are forwarded to [`mean_to_eccentric_anomaly`](@ref) if `Tanomaly` is
`MeanAnomaly`. Otherwise, they are ignored.
"""
eccentric_anomaly(orbit::KeplerianElements{EccentricAnomaly}; kwargs...) = orbit.anomaly

function eccentric_anomaly(orbit::KeplerianElements{MeanAnomaly}; kwargs...)
    return mean_to_eccentric_anomaly(orbit.eccentricity, orbit.anomaly; kwargs...)
end

function eccentric_anomaly(orbit::KeplerianElements{TrueAnomaly}; kwargs...)
    return true_to_eccentric_anomaly(orbit.eccentricity, orbit.anomaly)
end

# -- Mean Anomaly --------------------------------------------------------------------------

"""
    mean_anomaly(orbit::KeplerianElements{Tanomaly, Tepoch, T}; kwargs...) -> T

Return the mean anomaly [rad] of the `orbit`, converting the stored anomaly if it is not
already the mean anomaly.

# Keywords

The keywords are ignored. They exist so that all the anomaly getters share the same
signature.
"""
function mean_anomaly(orbit::KeplerianElements{EccentricAnomaly}; kwargs...)
    return eccentric_to_mean_anomaly(orbit.eccentricity, orbit.anomaly)
end

mean_anomaly(orbit::KeplerianElements{MeanAnomaly}; kwargs...) = orbit.anomaly

function mean_anomaly(orbit::KeplerianElements{TrueAnomaly}; kwargs...)
    return true_to_mean_anomaly(orbit.eccentricity, orbit.anomaly)
end

# -- True Anomaly --------------------------------------------------------------------------

"""
    true_anomaly(orbit::KeplerianElements{Tanomaly, Tepoch, T}; kwargs...) -> T

Return the true anomaly [rad] of the `orbit`, converting the stored anomaly if it is not
already the true anomaly.

# Keywords

The keywords are forwarded to [`mean_to_true_anomaly`](@ref) if `Tanomaly` is
`MeanAnomaly`. Otherwise, they are ignored.
"""
function true_anomaly(orbit::KeplerianElements{EccentricAnomaly}; kwargs...)
    return eccentric_to_true_anomaly(orbit.eccentricity, orbit.anomaly)
end

function true_anomaly(orbit::KeplerianElements{MeanAnomaly}; kwargs...)
    return mean_to_true_anomaly(orbit.eccentricity, orbit.anomaly; kwargs...)
end

true_anomaly(orbit::KeplerianElements{TrueAnomaly}; kwargs...) = orbit.anomaly

############################################################################################
#                                    Orbit State Vector                                    #
############################################################################################

# == Property Aliases ======================================================================

"""
    Base.getproperty(sv::OrbitStateVector, sym::Symbol) -> Any

Return the property `sym` of `sv`, supporting the legacy alias `t` for the field `epoch`.
"""
function Base.getproperty(sv::OrbitStateVector, sym::Symbol)
    sym === :t && return getfield(sv, :epoch)
    return getfield(sv, sym)
end

"""
    Base.propertynames(sv::OrbitStateVector, private::Bool = false) -> Tuple

Return the property names of `sv`, including the legacy alias `t`.
"""
function Base.propertynames(::OrbitStateVector, private::Bool = false)
    return (fieldnames(OrbitStateVector)..., :t)
end
