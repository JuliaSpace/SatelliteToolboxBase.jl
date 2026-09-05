## Description #############################################################################
#
# Getters for the orbits.
#
############################################################################################

export eccentric_anomaly, mean_anomaly, true_anomaly

############################################################################################
#                                    Keplerian Elements                                    #
############################################################################################

# == Old API ===============================================================================
#
# Those getters are kept for backward compatibility. They are not recommended for new code.

function Base.getproperty(orbit::KeplerianElements, sym::Symbol)
    sym == :t && return orbit.epoch
    sym == :a && return orbit.semi_major_axis
    sym == :e && return orbit.eccentricity
    sym == :i && return orbit.inclination
    sym == :Ω && return orbit.raan
    sym == :ω && return orbit.argument_of_periapsis
    sym == :f && return orbit.anomaly
    return getfield(orbit, sym)
end

# == Anomalies =============================================================================

# -- Eccentric Anomaly ---------------------------------------------------------------------

"""
    eccentric_anomaly(orbit::KeplerianElements{Tanomaly, Tepoch, T}) -> T

Return the eccentric anomaly of the orbit. This function will convert the anomaly to
eccentric anomaly if it is not already in that form.
"""
eccentric_anomaly(orbit::KeplerianElements{EccentricAnomaly}) = orbit.anomaly

function eccentric_anomaly(orbit::KeplerianElements{MeanAnomaly})
    return mean_to_eccentric_anomaly(orbit.eccentricity, orbit.anomaly)
end

function eccentric_anomaly(orbit::KeplerianElements{TrueAnomaly})
    return true_to_eccentric_anomaly(orbit.eccentricity, orbit.anomaly)
end

# -- Mean Anomaly --------------------------------------------------------------------------

"""
    mean_anomaly(orbit::KeplerianElements{Tanomaly, Tepoch, T}) -> T

Return the mean anomaly of the orbit. This function will convert the anomaly to mean anomaly
if it is not already in that form.
"""
function mean_anomaly(orbit::KeplerianElements{EccentricAnomaly})
    return eccentric_to_mean_anomaly(orbit.eccentricity, orbit.anomaly)
end

mean_anomaly(orbit::KeplerianElements{MeanAnomaly}) = orbit.anomaly

function mean_anomaly(orbit::KeplerianElements{TrueAnomaly})
    return true_to_mean_anomaly(orbit.eccentricity, orbit.anomaly)
end

# -- True Anomaly --------------------------------------------------------------------------

"""
    true_anomaly(orbit::KeplerianElements{Tanomaly, Tepoch, T}) -> T

Return the true anomaly of the orbit. This function will convert the anomaly to true anomaly
if it is not already in that form.
"""
function true_anomaly(orbit::KeplerianElements{EccentricAnomaly})
    return eccentric_to_true_anomaly(orbit.eccentricity, orbit.anomaly)
end

function true_anomaly(orbit::KeplerianElements{MeanAnomaly})
    return mean_to_true_anomaly(orbit.eccentricity, orbit.anomaly)
end

true_anomaly(orbit::KeplerianElements{TrueAnomaly}) = orbit.anomaly
