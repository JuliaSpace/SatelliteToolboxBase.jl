module SatelliteToolboxBase

using Crayons
using Dates
using Printf
using LinearAlgebra
using ReferenceFrameRotations
using StaticArrays

import Base: convert, iterate, length, eltype, show

############################################################################################
#                                          Types
############################################################################################

include("./types/ellipsoid.jl")
include("./types/orbit.jl")

############################################################################################
#                                        Constants
############################################################################################

# Colors.
const _CRAYON_RESET = Crayon(reset = true)
const _CRAYON_BOLD  = crayon"bold"

include("./constants.jl")

############################################################################################
#                                         Includes
############################################################################################

include("interfaces.jl")

include("./orbit/anomalies.jl")
include("./orbit/conversions.jl")
include("./orbit/kepler_to_rv.jl")
include("./orbit/kepler_to_sv.jl")
include("./orbit/rv_to_kepler.jl")
include("./orbit/sv_to_kepler.jl")

include("./show/orbit.jl")

include("./time/gmst.jl")
include("./time/julian_day.jl")

include("precompile.jl")

end # module SatelliteToolboxBase
