## Description #############################################################################
#
# General helpers for the SatelliteToolbox.jl environment.
#
############################################################################################

############################################################################################
#                                          Macros                                          #
############################################################################################

# == Threads ===============================================================================

"""
    @maybe_threads(ntasks, expr)

Run `expr` using `Threads.@threads` if `ntasks` is larger than 1. Otherwise, just run
`expr`, avoiding the overhead.
"""
macro maybe_threads(ntasks, expr)
    expr = quote
        if $ntasks > 1
            Threads.@threads $expr
        else
            $expr
        end
    end

    return esc(expr)
end

############################################################################################
#                                     Public Functions                                     #
############################################################################################

# == Threads ===============================================================================

"""
    get_partition(cp::Integer, inds::AbstractVector, np::Integer) -> Int, Int

Return the `cp`-th partition (start and end indices) of a vector with indices `inds`
considering that we are partitioning it into `np` parts.

It is useful to split the input information when spawning multiple tasks.

!!! note

    - `np` is clamped if it is larger than the number of elements in `inds`.
    - `cp` is clamped if it is larger than `np`.

# Returns

- `Int`: Current partition start index.
- `Int`: Current partition last index.
"""
function get_partition(cp::Integer, inds::AbstractVector, np::Integer)
    num_elements = length(inds)

    num_elements == 0 && return 0, 0

    # Check inputs.
    np = min(np, num_elements)
    cp = min(cp, np)

    len, rem = divrem(num_elements, np)

    i₀ = first(inds) + (cp - 1) * len
    i₁ = i₀ + len - 1

    i₀ += cp <= rem ? cp - 1 : rem
    i₁ += cp <= rem ? cp : rem

    return i₀, i₁
end
