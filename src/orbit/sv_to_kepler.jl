## Description #############################################################################
#
# Conversion from the orbit state vector to Keplerian elements.
#
############################################################################################

export sv_to_kepler

"""
    sv_to_kepler(sv::OrbitStateVector{Tepoch, T}; kwargs...) -> KeplerianElements{TrueAnomaly, Tepoch, T}

Convert the orbit state vector `sv` to Keplerian elements storing the true anomaly. The
orbit must be elliptical.

# Keywords

- `μ::Number`: Standard gravitational parameter of the central body [m³/s²].
    (**Default**: `GM_EARTH`)
"""
function sv_to_kepler(sv::OrbitStateVector; μ::Number = GM_EARTH)
    return rv_to_kepler(sv.r, sv.v, sv.epoch; μ)
end
