module SatelliteToolboxBase

using Crayons
using Dates
using Printf
using StaticArrays

import Base: show

################################################################################
#                                    Types
################################################################################

include("./types/ellipsoid.jl")
include("./types/orbit.jl")

################################################################################
#                                  Constants
################################################################################

# Colors.
const _CRAYON_RESET = Crayon(reset = true)
const _CRAYON_BOLD  = crayon"bold"

include("./constants.jl")

################################################################################
#                                   Includes
################################################################################

include("./show/orbit.jl")

include("./time/gmst.jl")
include("./time/julian_day.jl")

include("precompile.jl")

end # module SatelliteToolboxBase
