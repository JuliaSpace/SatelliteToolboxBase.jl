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
    print_compact(io, _orbit_type_name(orbit), orbit.epoch)
    return nothing
end

############################################################################################
#                                       Rich Format                                        #
############################################################################################

function Base.show(io::IO, ::MIME"text/plain", orbit::Orbit)
    print_tree(io, _orbit_type_name(orbit), orbit)
    return nothing
end

# == Keplerian Elements ====================================================================

function print_tree_body(io::IO, ke::KeplerianElements{Tanomaly}) where {Tanomaly}
    fields = PrintedField[
        ("Epoch",                  epoch_string(ke.epoch),                          ""),
        ("Semi-Major Axis",        format_value(ke.semi_major_axis / 1000),         "km"),
        ("Eccentricity",           format_value(ke.eccentricity),                   ""),
        ("Inclination",            format_value(rad2deg(ke.inclination)),           "°"),
        ("RA of Asc. Node",        format_value(rad2deg(ke.raan)),                  "°"),
        ("Arg. of Periapsis",      format_value(rad2deg(ke.argument_of_periapsis)), "°"),
        (_anomaly_label(Tanomaly), format_value(rad2deg(ke.anomaly)),               "°"),
    ]

    print_tree_body(io, fields, PrintedSection[])
    return nothing
end

# == Equinoctial Elements ==================================================================

function print_tree_body(io::IO, orbit::AbstractEquinoctialElements)
    fields = PrintedField[
        ("Epoch",           epoch_string(orbit.epoch),                   ""),
        ("Semi-Major Axis", format_value(orbit.semi_major_axis / 1000),  "km"),
        ("h",               format_value(orbit.h),                       ""),
        ("k",               format_value(orbit.k),                       ""),
        ("p",               format_value(orbit.p),                       ""),
        ("q",               format_value(orbit.q),                       ""),
        ("Mean Longitude",  format_value(rad2deg(orbit.mean_longitude)), "°"),
    ]

    print_tree_body(io, fields, PrintedSection[])
    return nothing
end

# == Orbit State Vector ====================================================================

function print_tree_body(io::IO, sv::OrbitStateVector)
    fields = PrintedField[
        ("Epoch",        epoch_string(sv.epoch),     ""),
        ("Position",     format_value(sv.r ./ 1000), "km"),
        ("Velocity",     format_value(sv.v ./ 1000), "km/s"),
        ("Acceleration", format_value(sv.a ./ 1000), "km/s²"),
    ]

    print_tree_body(io, fields, PrintedSection[])
    return nothing
end

############################################################################################
#                                     Private Functions                                    #
############################################################################################

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
    _orbit_type_name(orbit::Orbit) -> String

Return the name of the type of `orbit` with its parameters, as used in the headers of the
printed representations.
"""
function _orbit_type_name(orbit::Orbit)
    Torbit = typeof(orbit)
    return string(nameof(Torbit), "{", join(Torbit.parameters, ", "), "}")
end
