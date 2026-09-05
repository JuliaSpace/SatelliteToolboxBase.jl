## Description #############################################################################
#
# Definition of types related to anomalies.
#
############################################################################################

export AbstractAnomaly, EccentricAnomaly, MeanAnomaly, TrueAnomaly

abstract type AbstractAnomaly end

struct EccentricAnomaly <: AbstractAnomaly end
struct MeanAnomaly <: AbstractAnomaly end
struct TrueAnomaly <: AbstractAnomaly end
