## Description #############################################################################
#
# Helpers to print the rich and the compact representations of the types defined in the
# SatelliteToolbox.jl ecosystem.
#
# The rich representation is a tree with the same layout as the orbit data messages of
# SatelliteToolboxOrbitDataMessages.jl: a header, a list of fields printed as
# `Label : value unit`, and sections drawn as tree nodes that hold their own fields.
#
# The functions in this file are public but not exported. They must be called with the
# module prefix, e.g. `SatelliteToolboxBase.print_tree`.
#
# The decorations use the `StyledStrings` faces registered by `_register_faces`, which is
# called in `__init__`, so that the users can customize them in their `faces.toml`.
#
############################################################################################

"""
    PrintedField

Field of a rich representation: a tuple with the label, the value already converted to a
string, and the unit, which is empty for dimensionless values.

This type is public but not exported. Refer to it as `SatelliteToolboxBase.PrintedField`.
"""
const PrintedField = NTuple{3, String}

"""
    struct PrintedSection

Section of a rich representation, drawn as a tree node that holds its fields and, below
them, its subsections. A pair `name => fields` is converted to a section without
subsections, so the sections can be written as `PrintedSection["Name" => fields]`.

This type is public but not exported. Refer to it as `SatelliteToolboxBase.PrintedSection`.

# Fields

- `name::String`: Name of the section.
- `fields::Vector{PrintedField}`: Fields printed under the section name.
- `sections::Vector{PrintedSection}`: Subsections printed after the fields.
"""
struct PrintedSection
    name::String
    fields::Vector{PrintedField}
    sections::Vector{PrintedSection}
end

"""
    PrintedSection(name::String, fields::AbstractVector{PrintedField}) -> PrintedSection

Create a section called `name` with the `fields` and no subsections.
"""
function PrintedSection(name::String, fields::AbstractVector{PrintedField})
    return PrintedSection(name, fields, PrintedSection[])
end

function Base.convert(
    ::Type{PrintedSection}, p::Pair{<:AbstractString, <:AbstractVector{PrintedField}}
)
    return PrintedSection(String(first(p)), last(p))
end

############################################################################################
#                                      Compact Format                                      #
############################################################################################

"""
    print_compact(io::IO, name::String, epoch::Number) -> Nothing

Print to `io` the compact representation of an object whose type is described by `name`:
the `name` followed by the `epoch` [Julian Day] as a number and as a date.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_compact`.
"""
function print_compact(io::IO, name::String, epoch::Number)
    print(io, name, ": Epoch = ", epoch_string(epoch))
    return nothing
end

############################################################################################
#                                       Rich Format                                        #
############################################################################################

"""
    print_tree(io::IO, header::String, x) -> Nothing

Print to `io` the rich representation of `x`: the `header` followed by a colon, and the
body printed by [`print_tree_body`](@ref), which must be overloaded for the type of `x`.
The last line has no trailing newline.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_tree`.

    print_tree(
        io::IO,
        header::String,
        fields::AbstractVector{PrintedField},
        sections::AbstractVector{PrintedSection}
    ) -> Nothing

Print to `io` the rich representation composed of the `header` followed by a colon, the
`fields`, and the `sections`, as described in [`print_tree_body`](@ref).
"""
function print_tree(io::IO, header::String, x)
    println(io, styled"{satellitetoolbox_base_title:$header:}")
    print_tree_body(io, x)
    return nothing
end

function print_tree(
    io::IO,
    header::String,
    fields::AbstractVector{PrintedField},
    sections::AbstractVector{PrintedSection}
)
    println(io, styled"{satellitetoolbox_base_title:$header:}")
    print_tree_body(io, fields, sections)
    return nothing
end

"""
    print_tree_body(io::IO, x) -> Nothing

Print to `io` the body of the rich representation of `x`, i.e. its fields and sections
without the header. The types of the ecosystem overload this function, which allows a
wrapper to print the body of the object it holds under its own header.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_tree_body`.

    print_tree_body(
        io::IO,
        fields::AbstractVector{PrintedField},
        sections::AbstractVector{PrintedSection}
    ) -> Nothing

Print to `io` the `fields` indented by two spaces, followed by the `sections` drawn as tree
nodes whose fields and subsections are indented by two more spaces after the tree rails,
recursively. The labels are left-aligned to the widest one of each group, the unit `°` hugs
the value whereas any other unit is separated from it by a space, and the last line has no
trailing newline. If `io`
supports color, the labels are printed in bold, the units are dimmed, and the tree nodes are
highlighted, using the faces `:satellitetoolbox_base_label`, `:satellitetoolbox_base_unit`,
`:satellitetoolbox_base_node`, and `:satellitetoolbox_base_tree`.
"""
function print_tree_body end

function print_tree_body(
    io::IO,
    fields::AbstractVector{PrintedField},
    sections::AbstractVector{PrintedSection}
)
    # The tree is rendered in a buffer that inherits the properties of `io`, so that the
    # trailing newline can be removed.
    buf = IOContext(IOBuffer(), io)

    print_fields(buf, fields, "  ")
    _print_sections(buf, sections, "  ")

    print(io, chomp(String(take!(buf.io))))

    return nothing
end

"""
    print_fields(io::IO, fields::AbstractVector{PrintedField}, rail::String) -> Nothing

Print to `io` the `fields`, one per line, each preceded by `rail`, which holds the tree
rails of the ancestors. The labels are left-aligned to the widest one, the unit `°` hugs the
value whereas any other unit is separated from it by a space, an empty value leaves no
trailing space after the colon, and every line ends with a newline. If `io` supports color, the rails are printed with the face
`:satellitetoolbox_base_tree`, the labels with `:satellitetoolbox_base_label`, and the units
with `:satellitetoolbox_base_unit`.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_fields`.
"""
function print_fields(io::IO, fields::AbstractVector{PrintedField}, rail::String)
    isempty(fields) && return nothing

    width = maximum(textwidth ∘ first, fields)

    for (label, value, unit) in fields
        # The padding that aligns the labels is not decorated.
        padding = " "^(width - textwidth(label))

        print(
            io,
            styled"{satellitetoolbox_base_tree:$rail}",
            styled"{satellitetoolbox_base_label:$label}",
            padding,
            " :",
        )

        # An empty value leaves no trailing space after the colon.
        isempty(value) || print(io, " ", value)

        if !isempty(unit)
            unit == "°" || print(io, " ")
            print(io, styled"{satellitetoolbox_base_unit:$unit}")
        end

        println(io)
    end

    return nothing
end

"""
    print_node(io::IO, name::String, rail::String, connector::String) -> Nothing

Print to `io` a tree node called `name`, preceded by `rail`, which holds the tree rails of
the ancestors, and by `connector`, which is `"├─ "` for a node followed by siblings or
`"└─ "` for the last one. The line ends with a newline. If `io` supports color, the rails
and the connector are printed with the face `:satellitetoolbox_base_tree` and the name with
`:satellitetoolbox_base_node`.

This function is public but not exported. Call it as `SatelliteToolboxBase.print_node`.
"""
function print_node(io::IO, name::String, rail::String, connector::String)
    println(
        io,
        styled"{satellitetoolbox_base_tree:$rail}",
        styled"{satellitetoolbox_base_tree:$connector}",
        styled"{satellitetoolbox_base_node:$name}",
    )

    return nothing
end

"""
    print_status(io::IO, status::String) -> Nothing

Print to `io` the body of a rich representation composed of the single field `Status` with
the value `status`, e.g. `not initialized`, as described in [`print_tree_body`](@ref).

This function is public but not exported. Call it as `SatelliteToolboxBase.print_status`.
"""
function print_status(io::IO, status::String)
    print_tree_body(io, PrintedField[("Status", status, "")], PrintedSection[])
    return nothing
end

############################################################################################
#                                          Values                                          #
############################################################################################

"""
    epoch_string(epoch::Number) -> String

Return the string that prints `epoch` [Julian Day] in the representations: the number in
the compact form followed by the date in parentheses.

This function is public but not exported. Call it as `SatelliteToolboxBase.epoch_string`.
"""
function epoch_string(epoch::Number)
    epoch_str = sprint(print, epoch; context = :compact => true)
    date_str  = sprint(print, jd_to_date(DateTime, epoch))
    return string(epoch_str, " (", date_str, ")")
end

"""
    type_name(x) -> String

Return the name of the type of `x` followed by its parameters between braces, as used in
the headers of the representations, e.g. `KeplerianElements{TrueAnomaly, Float64, Float64}`.
The braces are omitted for a type without parameters.

This function is public but not exported. Call it as `SatelliteToolboxBase.type_name`.
"""
function type_name(x)
    T = typeof(x)
    isempty(T.parameters) && return string(nameof(T))
    return string(nameof(T), "{", join(T.parameters, ", "), "}")
end

"""
    format_value(x) -> String

Return the string that prints the value `x` in the rich representations. Floating-point
numbers are rounded to 10 significant digits, or to one digit less than the precision of the
type if it is lower (6 digits for `Float32`), and printed in the shortest form that
represents the rounded number, which hides the rounding noise of the computations. The
elements of a vector are formatted the same way and printed between brackets. Any other
value is printed with `string`.

This function is public but not exported. Call it as `SatelliteToolboxBase.format_value`.
"""
function format_value(x::T) where {T <: AbstractFloat}
    sigdigits = min(10, floor(Int, precision(T) * log10(2)) - 1)
    return string(round(x; sigdigits = sigdigits))
end

format_value(v::AbstractVector) = string("[", join(map(format_value, v), ", "), "]")
format_value(x) = string(x)

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _print_sections(
        io::IO,
        sections::AbstractVector{PrintedSection},
        rail::String
    ) -> Nothing

Print to `io` the `sections` as tree nodes preceded by `rail`, which holds the tree rails
of the ancestors. The fields and the subsections of each section are printed below its
name, with the rail extended by `│` while the section has siblings after it.
"""
function _print_sections(io::IO, sections::AbstractVector{PrintedSection}, rail::String)
    for (k, section) in enumerate(sections)
        is_last    = k == lastindex(sections)
        child_rail = rail * (is_last ? "     " : "│    ")

        print_node(io, section.name, rail, is_last ? "└─ " : "├─ ")
        print_fields(io, section.fields, child_rail)
        _print_sections(io, section.sections, child_rail)
    end

    return nothing
end

"""
    _register_faces() -> Nothing

Register the `StyledStrings` faces used by the printed representations. A face already
registered, e.g. by the user, is kept.

The registered faces are:

- `:satellitetoolbox_base_title`: Header of the rich representations (bold).
- `:satellitetoolbox_base_node`: Names of the tree nodes (yellow, bold).
- `:satellitetoolbox_base_tree`: Tree rails and connectors (gray).
- `:satellitetoolbox_base_label`: Labels of the fields (bold).
- `:satellitetoolbox_base_unit`: Units of the values (gray).
"""
function _register_faces()
    faces = (
        :satellitetoolbox_base_title => StyledStrings.Face(; weight = :bold),
        :satellitetoolbox_base_node  =>
            StyledStrings.Face(; foreground = :yellow, weight = :bold),
        :satellitetoolbox_base_tree  => StyledStrings.Face(; foreground = :gray),
        :satellitetoolbox_base_label => StyledStrings.Face(; weight = :bold),
        :satellitetoolbox_base_unit  => StyledStrings.Face(; foreground = :gray),
    )

    # `addface!` keeps a face that is already registered, e.g. by the user.
    foreach(StyledStrings.addface!, faces)

    return nothing
end
