## Description #############################################################################
#
# Methods to show types related to orbit.
#
############################################################################################

############################################################################################
#                                    Keplerian Elements                                    #
############################################################################################

function Base.show(
    io::IO,
    k::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    compact   = get(io, :compact, true)
    epoch_str = sprint(print, k.epoch, context = :compact => compact)
    jd_str    = sprint(print, jd_to_date(DateTime, k.epoch))

    print(
        io,
        "KeplerianElements{",
        Tanomaly,
        ", ",
        Tepoch,
        ", ",
        T,
        "}: Epoch = $epoch_str ($jd_str)"
    )

    return nothing
end

function Base.show(
    io::IO,
    mime::MIME"text/plain",
    k::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    d2r = 180 / π

    # Check if the IO supports color.
    color = get(io, :color, false)

    # Compact printing.
    compact = get(io, :compact, true)

    # Definition of colors that will be used for printing.
    b = color ? string(_CRAYON_BOLD)  : ""
    r = color ? string(_CRAYON_RESET) : ""

    # Convert the data to string.
    date_str  = sprint(print, jd_to_date(DateTime, k.epoch))
    epoch_str = sprint(print, k.epoch, context = :compact => compact)
    a_str     = sprint(print, k.semi_major_axis / 1000, context = :compact => compact)
    e_str     = sprint(print, k.eccentricity, context = :compact => compact)
    i_str     = sprint(print, rad2deg(k.inclination), context = :compact => compact)
    Ω_str     = sprint(print, rad2deg(k.raan), context = :compact => compact)
    ω_str     = sprint(print, rad2deg(k.argument_of_periapsis), context = :compact => compact)
    f_str     = sprint(print, rad2deg(k.anomaly), context = :compact => compact)

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
    Δepoch = findfirst('.', epoch_str)
    Δepoch === nothing && (Δepoch = length(epoch_str) + 1)

    Δa = findfirst('.', a_str)
    Δa === nothing && (Δa = length(a_str) + 1)

    Δe = findfirst('.', e_str)
    Δe === nothing && (Δe = length(e_str) + 1)

    Δi = findfirst('.', i_str)
    Δi === nothing && (Δi = length(i_str) + 1)

    ΔΩ = findfirst('.', Ω_str)
    ΔΩ === nothing && (ΔΩ = length(Ω_str) + 1)

    Δω = findfirst('.', ω_str)
    Δω === nothing && (Δω = length(ω_str) + 1)

    Δf = findfirst('.', f_str)
    Δf === nothing && (Δf = length(f_str) + 1)

    dp_pos = max(Δepoch, Δa, Δe, Δi, ΔΩ, Δω, Δf)

    epoch_str = " "^(dp_pos - Δepoch) * epoch_str
    a_str     = " "^(dp_pos - Δa) * a_str
    e_str     = " "^(dp_pos - Δe) * e_str
    i_str     = " "^(dp_pos - Δi) * i_str
    Ω_str     = " "^(dp_pos - ΔΩ) * Ω_str
    ω_str     = " "^(dp_pos - Δω) * ω_str
    f_str     = " "^(dp_pos - Δf) * f_str

    max_length = max(
        length(a_str),
        length(e_str),
        length(i_str),
        length(Ω_str),
        length(ω_str),
        length(f_str)
    )

    # Add the units.
    a_str *= " "^(max_length - length(a_str)) * " km"
    i_str *= " "^(max_length - length(i_str)) * " °"
    Ω_str *= " "^(max_length - length(Ω_str)) * " °"
    ω_str *= " "^(max_length - length(ω_str)) * " °"
    f_str *= " "^(max_length - length(f_str)) * " °"

    # Print the Keplerian elements.
    println(io, "KeplerianElements{", Tanomaly, ", ", Tepoch, ", ", T, "}:")
    println(io, "$b             Epoch : $r", epoch_str, " (", date_str, ")");
    println(io, "$b   Semi-major axis : $r", a_str)
    println(io, "$b      Eccentricity : $r", e_str)
    println(io, "$b       Inclination : $r", i_str)
    println(io, "$b              RAAN : $r", Ω_str)
    println(io, "$b Arg. of Periapsis : $r", ω_str)
    print(io,   "$b $anomaly_type Anomaly : $r", f_str)

    return nothing
end

############################################################################################
#                                   Equinoctial Elements                                   #
############################################################################################

function Base.show(io::IO, eq::EquinoctialElements{Tepoch, T}) where {Tepoch, T}
    compact   = get(io, :compact, true)
    epoch_str = sprint(print, eq.epoch, context = :compact => compact)
    jd_str    = sprint(print, jd_to_date(DateTime, eq.epoch))

    print(io, "EquinoctialElements{", Tepoch, ", ", T, "}: Epoch = $epoch_str ($jd_str)")

    return nothing
end

function Base.show(
    io::IO,
    ::MIME"text/plain",
    eq::EquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    # Check if the IO supports color.
    color = get(io, :color, false)

    # Compact printing.
    compact = get(io, :compact, true)

    # Definition of colors that will be used for printing.
    b = color ? string(_CRAYON_BOLD)  : ""
    r = color ? string(_CRAYON_RESET) : ""

    # Convert the data to string.
    date_str  = sprint(print, jd_to_date(DateTime, eq.epoch))
    epoch_str = sprint(print, eq.epoch, context = :compact => compact)
    a_str     = sprint(print, eq.semi_major_axis / 1000, context = :compact => compact)
    h_str     = sprint(print, eq.h, context = :compact => compact)
    k_str     = sprint(print, eq.k, context = :compact => compact)
    p_str     = sprint(print, eq.p, context = :compact => compact)
    q_str     = sprint(print, eq.q, context = :compact => compact)
    l_str     = sprint(print, rad2deg(eq.longitude), context = :compact => compact)

    # Padding to align in the floating point.
    Δepoch = findfirst('.', epoch_str)
    isnothing(Δepoch) && (Δepoch = length(epoch_str) + 1)

    Δa = findfirst('.', a_str)
    isnothing(Δa) && (Δa = length(a_str) + 1)

    Δh = findfirst('.', h_str)
    isnothing(Δh) && (Δh = lhngth(h_str) + 1)

    Δk = findfirst('.', k_str)
    isnothing(Δk) && (Δk = length(k_str) + 1)

    Δp = findfirst('.', p_str)
    isnothing(Δp) && (Δp = length(p_str) + 1)

    Δq = findfirst('.', q_str)
    isnothing(Δq) && (Δq = length(q_str) + 1)

    Δl = findfirst('.', l_str)
    isnothing(Δl) && (Δl = length(l_str) + 1)

    dp_pos = max(Δepoch, Δa, Δh, Δk, Δp, Δq, Δl)

    epoch_str = " "^(dp_pos - Δepoch) * epoch_str
    a_str     = " "^(dp_pos - Δa) * a_str
    h_str     = " "^(dp_pos - Δh) * h_str
    k_str     = " "^(dp_pos - Δk) * k_str
    p_str     = " "^(dp_pos - Δp) * p_str
    q_str     = " "^(dp_pos - Δq) * q_str
    l_str     = " "^(dp_pos - Δl) * l_str

    max_length = max(
        length(a_str),
        length(h_str),
        length(k_str),
        length(p_str),
        length(q_str),
        length(l_str)
    )

    # Add the units.
    a_str *= " km"
    l_str *= " °"

    # Print the Keplerian elements.
    println(io, "EquinoctialElements{", Tepoch, ", ", T, "}:")
    println(io, "$b           Epoch : $r", epoch_str, " (", date_str, ")");
    println(io, "$b Semi-major axis : $r", a_str)
    println(io, "$b    Eccentricity : $r", e_str)
    println(io, "$b     Inclination : $r", i_str)
    println(io, "$b            RAAN : $r", Ω_str)
    println(io, "$b Arg. of Perigee : $r", ω_str)
    print(io,   "$b    True Anomaly : $r", f_str)

    return nothing
end

############################################################################################
#                                    Orbit State Vector                                    #
############################################################################################

function Base.show(io::IO, sv::OrbitStateVector{Tepoch, T}) where {Tepoch, T}
    compact   = get(io, :compact, true)
    epoch_str = sprint(print, sv.t, context = :compact => compact)
    jd_str    = sprint(print, jd_to_date(DateTime, sv.t))

    print(io, "OrbitStateVector{", Tepoch, ", ", T, "}: Epoch = $epoch_str ($jd_str)")

    return nothing
end

function Base.show(
    io::IO,
    mime::MIME"text/plain",
    sv::OrbitStateVector{Tepoch, T}
) where {Tepoch, T}
    # Check if the `io` supports colors.
    color = get(io, :color, false)

    # Compact printing.
    compact = get(io, :compact, true)

    # Definition of colors that will be used for printing.
    b = color ? string(_CRAYON_BOLD)  : ""
    r = color ? string(_CRAYON_RESET) : ""

    t_str  = sprint(print, sv.t, context = :compact => compact)
    JD_str = sprint(print, jd_to_date(DateTime, sv.t), context = :compact => compact)
    r_str  = sprint(print, sv.r ./ 1000, context = :compact => compact)
    v_str  = sprint(print, sv.v ./ 1000, context = :compact => compact)

    # Add units.
    max_length = max(length(r_str), length(v_str))

    r_str *= " "^(max_length - length(r_str) + 1) * " km"
    v_str *= " "^(max_length - length(v_str) + 1) * " km/s"

    println(io, "OrbitStateVector{", Tepoch, ", ", T, "}:")
    println(io, "$b  epoch :$r ", t_str, " (", JD_str, ")")
    println(io, "$b      r :$r ", r_str)
    print(io,   "$b      v :$r ", v_str)

    return nothing
end
