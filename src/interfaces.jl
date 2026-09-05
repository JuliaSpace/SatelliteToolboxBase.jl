## Description #############################################################################
#
# Interfaces with Julia APIs.
#
############################################################################################

############################################################################################
#                                    Iterator Interface                                    #
############################################################################################

# These functions allow broadcast when using the orbit propagators.

"""
    Base.iterate(orb::Orbit) -> Tuple{Orbit, Nothing}
    Base.iterate(orb::Orbit, ::Nothing) -> Nothing
    Base.length(orb::Orbit) -> Int
    Base.eltype(orb::T) where {T <: Orbit} -> Type{T}

Implement the iterator interface for the orbit representations, treating the orbit `orb` as
a collection with a single element. Hence, the orbit representations can be used in
broadcasting.
"""
Base.iterate(orb::Orbit) = (orb, nothing)
Base.iterate(::Orbit, ::Nothing) = nothing
Base.length(::Orbit) = 1
Base.eltype(::T) where {T <: Orbit} = T
