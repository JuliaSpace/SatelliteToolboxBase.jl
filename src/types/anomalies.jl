## Description #############################################################################
#
# Definition of types related to anomalies.
#
############################################################################################

export AbstractAnomaly, EccentricAnomaly, MeanAnomaly, TrueAnomaly

"""
    abstract type AbstractAnomaly

Abstract type of the markers that select which anomaly is stored in a `KeplerianElements`
object.
"""
abstract type AbstractAnomaly end

"""
    struct EccentricAnomaly <: AbstractAnomaly

Marker indicating that the `KeplerianElements` object stores the eccentric anomaly.
"""
struct EccentricAnomaly <: AbstractAnomaly end

"""
    struct MeanAnomaly <: AbstractAnomaly

Marker indicating that the `KeplerianElements` object stores the mean anomaly.
"""
struct MeanAnomaly <: AbstractAnomaly end

"""
    struct TrueAnomaly <: AbstractAnomaly

Marker indicating that the `KeplerianElements` object stores the true anomaly.
"""
struct TrueAnomaly <: AbstractAnomaly end
