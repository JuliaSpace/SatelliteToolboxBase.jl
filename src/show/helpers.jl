## Description #############################################################################
#
# Helpers to print the rich and the compact representations of the types defined in the
# SatelliteToolbox.jl ecosystem.
#
# The functions in this file are public but not exported. They must be called with the
# module prefix, e.g. `SatelliteToolboxBase.print_elements`.
#
# The decorations use the `StyledStrings` faces registered by `_register_faces`, which is
# called in `__init__`, so that the users can customize them in their `faces.toml`.
#
############################################################################################

"""
    print_compact(io::IO, name::String, epoch::Number) -> Nothing

Print to `io` the compact representation of an object whose type is described by `name`:
the `name` followed by the `epoch` [Julian Day] as a number and as a date.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_compact`.
"""
function print_compact(io::IO, name::String, epoch::Number)
    epoch_str = compact_string(io, epoch)
    date_str  = sprint(print, jd_to_date(DateTime, epoch))
    print(io, name, ": Epoch = ", epoch_str, " (", date_str, ")")
    return nothing
end

"""
    print_elements(
        io::IO,
        header::String,
        epoch::Number,
        labels::NTuple{N, String},
        values::NTuple{N, String},
        units::NTuple{N, String};
        kwargs...
    ) where {N} -> Nothing

Print to `io` the rich representation of an object: the `header` followed by a colon, a
line with the `epoch` [Julian Day] and its date, and one line per element with its label,
value, and unit, taken from `labels`, `values`, and `units`. The non-empty units are aligned
after the longest value. The labels are right-aligned two spaces after the header column.
If `io` supports color, the labels are printed in bold and the units are dimmed, using the
faces `:satellitetoolbox_base_label` and `:satellitetoolbox_base_unit`. The last line has no
trailing newline.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_elements`.

# Keywords

- `align_decimal::Bool`: If `true`, the values, the epoch included, are aligned at the
    decimal point.
    (**Default**: `true`)
"""
function print_elements(
    io::IO,
    header::String,
    epoch::Number,
    labels::NTuple{N, String},
    values::NTuple{N, String},
    units::NTuple{N, String};
    align_decimal::Bool = true,
) where {N}
    epoch_str = compact_string(io, epoch)
    date_str  = sprint(print, jd_to_date(DateTime, epoch))

    # Align all the values at the decimal point, if requested.
    if align_decimal
        aligned   = align_on_decimal(epoch_str, values...)
        epoch_str = first(aligned)
        values    = Base.tail(aligned)
    end

    # Pad the values with a unit so that the units are aligned.
    max_length = maximum(length, values)

    values = map(values, units) do value, unit
        return isempty(unit) ? value : append_unit(value, max_length, unit)
    end

    # Right-align the labels, leaving two spaces before the longest one so that the rows
    # are indented with respect to the header.
    label_width = maximum(length, ("Epoch", labels...)) + 2

    println(io, header, ":")
    println_field(io, lpad("Epoch", label_width) * " : ", epoch_str, " (", date_str, ")")

    for k in 1:N
        label = lpad(labels[k], label_width) * " : "

        if k < N
            println_field(io, label, values[k])
        else
            print_field(io, label, values[k])
        end
    end

    return nothing
end

"""
    println_field(io::IO, label::String, xs...) -> Nothing

Print the field `label` to `io` with the face `:satellitetoolbox_base_label` (bold by
default), followed by the values `xs...` and a newline. The decoration is rendered only if
`io` supports color.

This function is public but not exported. Call it as `SatelliteToolboxBase.println_field`.
"""
function println_field(io::IO, label::String, xs...)
    print(io, styled"{satellitetoolbox_base_label:$label}")
    println(io, xs...)
    return nothing
end

"""
    print_field(io::IO, label::String, xs...) -> Nothing

Print the field `label` to `io` with the face `:satellitetoolbox_base_label` (bold by
default), followed by the values `xs...` without a trailing newline. The decoration is
rendered only if `io` supports color.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_field`.
"""
function print_field(io::IO, label::String, xs...)
    print(io, styled"{satellitetoolbox_base_label:$label}")
    print(io, xs...)
    return nothing
end

"""
    align_on_decimal(strs::Vararg{String, N}) where {N} -> NTuple{N, String}

Return the strings `strs` left-padded so that their decimal points are aligned. Strings
without a decimal point are treated as if the point were right after the last character.

This function is public but not exported. Call it as
`SatelliteToolboxBase.align_on_decimal`.
"""
function align_on_decimal(strs::Vararg{String, N}) where {N}
    Δs = map(strs) do s
        Δ = findfirst('.', s)
        return isnothing(Δ) ? length(s) + 1 : Δ
    end

    dp_pos = maximum(Δs)

    return map((s, Δ) -> " "^(dp_pos - Δ) * s, strs, Δs)
end

"""
    append_unit(str::String, max_length::Int, unit::String) -> AnnotatedString{String}

Return `str` right-padded to `max_length` characters and followed by a space and `unit`,
which carries the face `:satellitetoolbox_base_unit` (dimmed by default) so that it is
decorated when printed to an output that supports color.

This function is public but not exported. Call it as `SatelliteToolboxBase.append_unit`.
"""
function append_unit(str::String, max_length::Int, unit::String)
    unit_str = styled"{satellitetoolbox_base_unit:$unit}"
    return str * " "^(max_length - length(str)) * " " * unit_str
end

"""
    compact_string(io::IO, x) -> String

Return the string obtained by printing `x` while honoring the `:compact` property of `io`,
which defaults to `true` if it is absent.

This function is public but not exported. Call it as `SatelliteToolboxBase.compact_string`.
"""
function compact_string(io::IO, x)
    compact = get(io, :compact, true)::Bool
    return sprint(print, x; context = :compact => compact)
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _register_faces() -> Nothing

Register the `StyledStrings` faces used by the printed representations. A face already
defined, e.g. by the user, is not overwritten.

The registered faces are:

- `:satellitetoolbox_base_label`: Labels of the fields (bold).
- `:satellitetoolbox_base_unit`: Units of the values (gray).
"""
function _register_faces()
    faces = (
        :satellitetoolbox_base_label => StyledStrings.Face(; weight = :bold),
        :satellitetoolbox_base_unit  => StyledStrings.Face(; foreground = :gray),
    )

    for (name, face) in faces
        haskey(StyledStrings.FACES.default, name) && continue
        StyledStrings.addface!(name => face)
    end

    return nothing
end
