## Description #############################################################################
#
# Methods to show types related to orbit.
#
############################################################################################

# The printing formats are described in the docstrings of the orbit representations.

############################################################################################
#                                      Compact Format                                      #
############################################################################################

function Base.show(io::IO, orbit::Orbit)
    _print_compact(io, _orbit_type_name(orbit), orbit.epoch)
    return nothing
end

############################################################################################
#                                       Rich Format                                        #
############################################################################################

# == Keplerian Elements ====================================================================

function Base.show(
    io::IO, ::MIME"text/plain", ke::KeplerianElements{Tanomaly}
) where {Tanomaly <: AbstractAnomaly}
    labels = (
        "Semi-major axis",
        "Eccentricity",
        "Inclination",
        "RAAN",
        "Arg. of Periapsis",
        _anomaly_label(Tanomaly),
    )

    values = (
        _compact_string(io, ke.semi_major_axis / 1000),
        _compact_string(io, ke.eccentricity),
        _compact_string(io, rad2deg(ke.inclination)),
        _compact_string(io, rad2deg(ke.raan)),
        _compact_string(io, rad2deg(ke.argument_of_periapsis)),
        _compact_string(io, rad2deg(ke.anomaly)),
    )

    units = ("km", "", "°", "°", "°", "°")

    _print_elements(io, _orbit_type_name(ke), ke.epoch, labels, values, units)
    return nothing
end

# == Equinoctial Elements ==================================================================

function Base.show(io::IO, ::MIME"text/plain", orbit::AbstractEquinoctialElements)
    labels = ("Semi-major axis", "h", "k", "p", "q", "Mean Longitude")

    values = (
        _compact_string(io, orbit.semi_major_axis / 1000),
        _compact_string(io, orbit.h),
        _compact_string(io, orbit.k),
        _compact_string(io, orbit.p),
        _compact_string(io, orbit.q),
        _compact_string(io, rad2deg(orbit.mean_longitude)),
    )

    units = ("km", "", "", "", "", "°")

    _print_elements(io, _orbit_type_name(orbit), orbit.epoch, labels, values, units)
    return nothing
end

# == Orbit State Vector ====================================================================

function Base.show(io::IO, ::MIME"text/plain", sv::OrbitStateVector)
    epoch_str = _compact_string(io, sv.epoch)
    date_str  = sprint(print, jd_to_date(DateTime, sv.epoch))
    r_str     = _compact_string(io, sv.r ./ 1000)
    v_str     = _compact_string(io, sv.v ./ 1000)

    # Add units.
    max_length = max(length(r_str), length(v_str)) + 1

    r_str = _append_unit(r_str, max_length, "km")
    v_str = _append_unit(v_str, max_length, "km/s")

    println(io, _orbit_type_name(sv), ":")
    _println_field(io, "  epoch :", " ", epoch_str, " (", date_str, ")")
    _println_field(io, "      r :", " ", r_str)
    _print_field(io, "      v :", " ", v_str)

    return nothing
end

############################################################################################
#                                     Private Functions                                    #
############################################################################################

"""
    _align_on_decimal(strs::Vararg{String, N}) -> NTuple{N, String}

Return the strings `strs` left-padded so that their decimal points are aligned. Strings
without a decimal point are treated as if the point were right after the last character.
"""
function _align_on_decimal(strs::Vararg{String, N}) where {N}
    Δs = map(strs) do s
        Δ = findfirst('.', s)
        return isnothing(Δ) ? length(s) + 1 : Δ
    end

    dp_pos = maximum(Δs)

    return map((s, Δ) -> " "^(dp_pos - Δ) * s, strs, Δs)
end

"""
    _anomaly_label(::Type{Tanomaly}) -> String

Return the label of the anomaly selected by the marker type `Tanomaly` for the rich
representation of the Keplerian elements.
"""
_anomaly_label(::Type{<:AbstractAnomaly}) = "Anomaly"
_anomaly_label(::Type{<:EccentricAnomaly}) = "Eccentric Anomaly"
_anomaly_label(::Type{<:MeanAnomaly}) = "Mean Anomaly"
_anomaly_label(::Type{<:TrueAnomaly}) = "True Anomaly"

"""
    _append_unit(str::String, max_length::Int, unit::String) -> String

Return `str` right-padded to `max_length` characters and followed by a space and `unit`.
"""
function _append_unit(str::String, max_length::Int, unit::String)
    return str * " "^(max_length - length(str)) * " " * unit
end

"""
    _compact_string(io::IO, x) -> String

Return the string obtained by printing `x` while honoring the `:compact` property of `io`.
"""
function _compact_string(io::IO, x)
    compact = get(io, :compact, true)::Bool
    return sprint(print, x; context = :compact => compact)
end

"""
    _orbit_type_name(orbit::Orbit) -> String

Return the name of the type of `orbit` with its parameters, as used in the headers of the
printed representations.
"""
function _orbit_type_name(orbit::Orbit)
    Torbit = typeof(orbit)
    return string(nameof(Torbit), "{", join(Torbit.parameters, ", "), "}")
end

"""
    _print_compact(io::IO, name::String, epoch::Number) -> Nothing

Print to `io` the compact representation of an orbit whose type is described by `name`: the
`name` followed by the `epoch` as a Julian Day and as a date.
"""
function _print_compact(io::IO, name::String, epoch::Number)
    epoch_str = _compact_string(io, epoch)
    date_str  = sprint(print, jd_to_date(DateTime, epoch))
    print(io, name, ": Epoch = ", epoch_str, " (", date_str, ")")
    return nothing
end

"""
    _print_elements(io::IO, header::String, epoch::Number, labels::NTuple{N, String}, values::NTuple{N, String}, units::NTuple{N, String}) -> Nothing

Print to `io` the rich representation of an orbit: the `header` followed by a colon, a line
with the `epoch` [Julian Day] and its date, and one line per element with its label, value,
and unit, taken from `labels`, `values`, and `units`. The values, the epoch included, are
aligned at the decimal point, and the non-empty units are aligned after the longest value.
The labels are right-aligned, and printed in bold if `io` supports color. The last line has
no trailing newline.
"""
function _print_elements(
    io::IO,
    header::String,
    epoch::Number,
    labels::NTuple{N, String},
    values::NTuple{N, String},
    units::NTuple{N, String},
) where {N}
    epoch_str = _compact_string(io, epoch)
    date_str  = sprint(print, jd_to_date(DateTime, epoch))

    # Align all the values at the decimal point.
    aligned   = _align_on_decimal(epoch_str, values...)
    epoch_str = first(aligned)
    values    = Base.tail(aligned)

    # Pad the values with a unit so that the units are aligned.
    max_length = maximum(length, values)

    values = map(values, units) do value, unit
        return isempty(unit) ? value : _append_unit(value, max_length, unit)
    end

    # Right-align the labels, leaving one space before the longest one.
    label_width = maximum(length, ("Epoch", labels...)) + 1

    println(io, header, ":")
    _println_field(io, lpad("Epoch", label_width) * " : ", epoch_str, " (", date_str, ")")

    for k in 1:N
        label = lpad(labels[k], label_width) * " : "

        if k < N
            _println_field(io, label, values[k])
        else
            _print_field(io, label, values[k])
        end
    end

    return nothing
end

"""
    _println_field(io::IO, label::String, xs...) -> Nothing

Print the field `label` in bold to `io`, followed by the values `xs...` and a newline. The
bold decoration is rendered only if `io` supports color.
"""
function _println_field(io::IO, label::String, xs...)
    print(io, styled"{bold:$label}")
    println(io, xs...)
    return nothing
end

"""
    _print_field(io::IO, label::String, xs...) -> Nothing

Print the field `label` in bold to `io`, followed by the values `xs...` without a trailing
newline. The bold decoration is rendered only if `io` supports color.
"""
function _print_field(io::IO, label::String, xs...)
    print(io, styled"{bold:$label}")
    print(io, xs...)
    return nothing
end
