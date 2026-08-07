## Description #############################################################################
#
# Conversion from the Keplerian elements to orbit state vector.
#
############################################################################################

export sv_to_kepler

"""
    sv_to_kepler(sv::OrbitStateVector; μ::Number = GM_EARTH) -> KeplerianElements

Convert the orbit state vector `sv` to Keplerian elements.

# Keywords

- `μ::Number`: Standard gravitational parameter of the central body [m³ / s²].
    (**Default** = `GM_EARTH`)
"""
function sv_to_kepler(sv::OrbitStateVector; μ::Number = GM_EARTH)
    return rv_to_kepler(sv.r, sv.v, sv.t; μ)
end
