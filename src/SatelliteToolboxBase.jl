module SatelliteToolboxBase

using Dates
using LinearAlgebra
using StyledStrings

using ReferenceFrameRotations
using StaticArrays

import Base: throw_boundserror, @boundscheck, @propagate_inbounds
import PrecompileTools

############################################################################################
#                                          Types                                           #
############################################################################################

include("./types/anomalies.jl")
include("./types/ellipsoid.jl")
include("./types/jacobian.jl")
include("./types/storage.jl")
include("./types/orbit.jl")

############################################################################################
#                                        Constants                                         #
############################################################################################

include("./constants.jl")

############################################################################################
#                                         Includes                                         #
############################################################################################

include("./helpers.jl")
include("./interfaces.jl")
include("./storage.jl")

# == Orbit =================================================================================

include("./orbit/anomalies.jl")
include("./orbit/conversions.jl")
include("./orbit/getters.jl")
include("./orbit/kepler_to_rv.jl")
include("./orbit/kepler_to_sv.jl")
include("./orbit/rv_to_kepler.jl")
include("./orbit/sv_to_kepler.jl")

# == Show ==================================================================================

include("./show/orbit.jl")

# == Time ==================================================================================

include("./time/gmst.jl")
include("./time/julian_day.jl")

# == Precompilation ========================================================================

include("./precompile.jl")

end # module SatelliteToolboxBase
