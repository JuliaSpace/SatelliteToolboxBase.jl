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
        compact_string(io, ke.semi_major_axis / 1000),
        compact_string(io, ke.eccentricity),
        compact_string(io, rad2deg(ke.inclination)),
        compact_string(io, rad2deg(ke.raan)),
        compact_string(io, rad2deg(ke.argument_of_periapsis)),
        compact_string(io, rad2deg(ke.anomaly)),
    )

    units = ("km", "", "°", "°", "°", "°")

    print_elements(io, _orbit_type_name(ke), ke.epoch, labels, values, units)
    return nothing
end

# == Equinoctial Elements ==================================================================

function Base.show(io::IO, ::MIME"text/plain", orbit::AbstractEquinoctialElements)
    labels = ("Semi-major axis", "h", "k", "p", "q", "Mean Longitude")

    values = (
        compact_string(io, orbit.semi_major_axis / 1000),
        compact_string(io, orbit.h),
        compact_string(io, orbit.k),
        compact_string(io, orbit.p),
        compact_string(io, orbit.q),
        compact_string(io, rad2deg(orbit.mean_longitude)),
    )

    units = ("km", "", "", "", "", "°")

    print_elements(io, _orbit_type_name(orbit), orbit.epoch, labels, values, units)
    return nothing
end

# == Orbit State Vector ====================================================================

function Base.show(io::IO, ::MIME"text/plain", sv::OrbitStateVector)
    labels = ("Position", "Velocity", "Acceleration")

    values = (
        compact_string(io, sv.r ./ 1000),
        compact_string(io, sv.v ./ 1000),
        compact_string(io, sv.a ./ 1000),
    )

    units = ("km", "km/s", "km/s²")

    # The values are vectors, so aligning them at the first decimal point makes no sense.
    print_elements(
        io, _orbit_type_name(sv), sv.epoch, labels, values, units; align_decimal = false
    )
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
