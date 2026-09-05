## Description #############################################################################
#
# Methods to show types related to orbit.
#
############################################################################################

############################################################################################
#                                     Private Functions                                    #
############################################################################################

# Return the strings in `strs` left-padded so that their decimal points are aligned. Strings
# without a decimal point are treated as if the point were right after the last character.
function _align_on_decimal(strs::Vararg{String, N}) where N
    Δs = map(strs) do s
        Δ = findfirst('.', s)
        return isnothing(Δ) ? length(s) + 1 : Δ
    end

    dp_pos = maximum(Δs)

    return map((s, Δ) -> " "^(dp_pos - Δ) * s, strs, Δs)
end

# Return `str` right-padded to `max_length` characters followed by ` unit`.
function _append_unit(str::String, max_length::Int, unit::String)
    return str * " "^(max_length - length(str)) * " " * unit
end

# Print the field `label` in bold followed by the values `xs...` and a newline. The bold
# decoration is rendered only if `io` supports color.
function _println_field(io::IO, label::String, xs...)
    print(io, styled"{bold:$label}")
    println(io, xs...)
    return nothing
end

# Same as `_println_field` but without the trailing newline.
function _print_field(io::IO, label::String, xs...)
    print(io, styled"{bold:$label}")
    print(io, xs...)
    return nothing
end

# Print `x` to a string honoring the `:compact` property in `io`.
function _compact_string(io::IO, x)
    compact = get(io, :compact, true)::Bool
    return sprint(print, x; context = :compact => compact)
end

############################################################################################
#                                    Keplerian Elements                                    #
############################################################################################

function Base.show(
    io::IO,
    ke::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    epoch_str = _compact_string(io, ke.epoch)
    date_str  = sprint(print, jd_to_date(DateTime, ke.epoch))

    print(
        io,
        "KeplerianElements{", Tanomaly, ", ", Tepoch, ", ", T, "}: ",
        "Epoch = ", epoch_str, " (", date_str, ")"
    )

    return nothing
end

function Base.show(
    io::IO,
    ::MIME"text/plain",
    ke::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    # Convert the data to string.
    date_str  = sprint(print, jd_to_date(DateTime, ke.epoch))
    epoch_str = _compact_string(io, ke.epoch)
    a_str     = _compact_string(io, ke.semi_major_axis / 1000)
    e_str     = _compact_string(io, ke.eccentricity)
    i_str     = _compact_string(io, rad2deg(ke.inclination))
    Ω_str     = _compact_string(io, rad2deg(ke.raan))
    ω_str     = _compact_string(io, rad2deg(ke.argument_of_periapsis))
    f_str     = _compact_string(io, rad2deg(ke.anomaly))

    # Current anomaly type.
    anomaly_type = if Tanomaly <: TrueAnomaly
        "     True"
    elseif Tanomaly <: EccentricAnomaly
        "Eccentric"
    elseif Tanomaly <: MeanAnomaly
        "     Mean"
    else
        "  Unknown"
    end

    # Padding to align in the floating point.
    epoch_str, a_str, e_str, i_str, Ω_str, ω_str, f_str = _align_on_decimal(
        epoch_str,
        a_str,
        e_str,
        i_str,
        Ω_str,
        ω_str,
        f_str
    )

    max_length = max(
        length(a_str),
        length(e_str),
        length(i_str),
        length(Ω_str),
        length(ω_str),
        length(f_str)
    )

    # Add the units.
    a_str = _append_unit(a_str, max_length, "km")
    i_str = _append_unit(i_str, max_length, "°")
    Ω_str = _append_unit(Ω_str, max_length, "°")
    ω_str = _append_unit(ω_str, max_length, "°")
    f_str = _append_unit(f_str, max_length, "°")

    # Print the Keplerian elements.
    println(io, "KeplerianElements{", Tanomaly, ", ", Tepoch, ", ", T, "}:")
    _println_field(io, "             Epoch : ", epoch_str, " (", date_str, ")")
    _println_field(io, "   Semi-major axis : ", a_str)
    _println_field(io, "      Eccentricity : ", e_str)
    _println_field(io, "       Inclination : ", i_str)
    _println_field(io, "              RAAN : ", Ω_str)
    _println_field(io, " Arg. of Periapsis : ", ω_str)
    _print_field(io, " " * anomaly_type * " Anomaly : ", f_str)

    return nothing
end

############################################################################################
#                                   Equinoctial Elements                                   #
############################################################################################

function Base.show(io::IO, ee::EquinoctialElements{Tepoch, T}) where {Tepoch, T}
    epoch_str = _compact_string(io, ee.epoch)
    date_str  = sprint(print, jd_to_date(DateTime, ee.epoch))

    print(
        io,
        "EquinoctialElements{", Tepoch, ", ", T, "}: ",
        "Epoch = ", epoch_str, " (", date_str, ")"
    )

    return nothing
end

function Base.show(
    io::IO,
    ::MIME"text/plain",
    ee::EquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    # Convert the data to string.
    date_str  = sprint(print, jd_to_date(DateTime, ee.epoch))
    epoch_str = _compact_string(io, ee.epoch)
    a_str     = _compact_string(io, ee.semi_major_axis / 1000)
    h_str     = _compact_string(io, ee.h)
    k_str     = _compact_string(io, ee.k)
    p_str     = _compact_string(io, ee.p)
    q_str     = _compact_string(io, ee.q)
    λ_str     = _compact_string(io, rad2deg(ee.mean_longitude))

    # Padding to align in the floating point.
    epoch_str, a_str, h_str, k_str, p_str, q_str, λ_str = _align_on_decimal(
        epoch_str,
        a_str,
        h_str,
        k_str,
        p_str,
        q_str,
        λ_str
    )

    max_length = max(
        length(a_str),
        length(h_str),
        length(k_str),
        length(p_str),
        length(q_str),
        length(λ_str)
    )

    # Add the units.
    a_str = _append_unit(a_str, max_length, "km")
    λ_str = _append_unit(λ_str, max_length, "°")

    # Print the equinoctial elements.
    println(io, "EquinoctialElements{", Tepoch, ", ", T, "}:")
    _println_field(io, "           Epoch : ", epoch_str, " (", date_str, ")")
    _println_field(io, " Semi-major axis : ", a_str)
    _println_field(io, "               h : ", h_str)
    _println_field(io, "               k : ", k_str)
    _println_field(io, "               p : ", p_str)
    _println_field(io, "               q : ", q_str)
    _print_field(io, "  Mean Longitude : ", λ_str)

    return nothing
end

############################################################################################
#                                    Orbit State Vector                                    #
############################################################################################

function Base.show(io::IO, sv::OrbitStateVector{Tepoch, T}) where {Tepoch, T}
    epoch_str = _compact_string(io, sv.epoch)
    date_str  = sprint(print, jd_to_date(DateTime, sv.epoch))

    print(
        io,
        "OrbitStateVector{", Tepoch, ", ", T, "}: ",
        "Epoch = ", epoch_str, " (", date_str, ")"
    )

    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", sv::OrbitStateVector{Tepoch, T}) where {Tepoch, T}
    epoch_str = _compact_string(io, sv.epoch)
    date_str  = sprint(print, jd_to_date(DateTime, sv.epoch))
    r_str     = _compact_string(io, sv.r ./ 1000)
    v_str     = _compact_string(io, sv.v ./ 1000)

    # Add units.
    max_length = max(length(r_str), length(v_str)) + 1

    r_str = _append_unit(r_str, max_length, "km")
    v_str = _append_unit(v_str, max_length, "km/s")

    println(io, "OrbitStateVector{", Tepoch, ", ", T, "}:")
    _println_field(io, "  epoch :", " ", epoch_str, " (", date_str, ")")
    _println_field(io, "      r :", " ", r_str)
    _print_field(io, "      v :", " ", v_str)

    return nothing
end
