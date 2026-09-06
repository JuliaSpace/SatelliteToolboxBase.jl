## Description #############################################################################
#
# Tests related to the public helpers that print the rich and the compact representations.
#
############################################################################################

@testset "Show Helpers" verbose = true begin
    @testset "epoch_string" begin
        str = SatelliteToolboxBase.epoch_string(2.4466e6)
        @test str == "2.4466e6 (1986-06-18T12:00:00)"
    end

    @testset "format_value" begin
        # Floating-point numbers are rounded to 10 significant digits.
        @test SatelliteToolboxBase.format_value(7130.982) == "7130.982"
        @test SatelliteToolboxBase.format_value(8000.0) == "8000.0"
        @test SatelliteToolboxBase.format_value(1 / 3) == "0.3333333333"
        @test SatelliteToolboxBase.format_value(100.00000000000001) == "100.0"
        @test SatelliteToolboxBase.format_value(7130.982f0) == "7130.98"
        @test SatelliteToolboxBase.format_value(199.99998f0) == "200.0"
        @test SatelliteToolboxBase.format_value(-2.53215e-6) == "-2.53215e-6"
        @test SatelliteToolboxBase.format_value(NaN) == "NaN"

        # Vectors are printed between brackets, and other values with `string`.
        @test SatelliteToolboxBase.format_value([1 / 3, 2.0]) == "[0.3333333333, 2.0]"
        @test SatelliteToolboxBase.format_value(12) == "12"
        @test SatelliteToolboxBase.format_value("SGP4") == "SGP4"
    end

    @testset "print_compact" begin
        str = sprint(SatelliteToolboxBase.print_compact, "MyOrbit", 2.4466e6)
        @test str == "MyOrbit: Epoch = 2.4466e6 (1986-06-18T12:00:00)"
    end

    @testset "print_fields" begin
        fields = SatelliteToolboxBase.PrintedField[
            ("Semi-Major Axis", "7130.982", "km"),
            ("Inclination",     "98.405",   "°"),
            ("Name",            "SGP4",     ""),
        ]

        # The labels are left-aligned, and the degree symbol hugs the value.
        expected = join(
            (
                "│  Semi-Major Axis : 7130.982 km",
                "│  Inclination     : 98.405°",
                "│  Name            : SGP4",
            ),
            '\n',
        ) * '\n'

        str = sprint(SatelliteToolboxBase.print_fields, fields, "│  ")
        @test str == expected

        # An empty value leaves no trailing space after the colon.
        empty_value = SatelliteToolboxBase.PrintedField[("Decay Date", "", "")]
        @test sprint(SatelliteToolboxBase.print_fields, empty_value, "  ") == "  Decay Date :\n"

        # Nothing is printed without fields.
        no_fields = SatelliteToolboxBase.PrintedField[]
        @test sprint(SatelliteToolboxBase.print_fields, no_fields, "  ") == ""

        # The rails, the labels, and the units must be decorated when the output supports
        # colors.
        str_color = sprint(
            SatelliteToolboxBase.print_fields, fields[1:1], "│  "; context = :color => true
        )
        @test str_color ==
            "\e[90m│  \e[39m\e[1mSemi-Major Axis\e[22m : 7130.982 \e[90mkm\e[39m\n"
    end

    @testset "print_node" begin
        @test sprint(SatelliteToolboxBase.print_node, "Constants", "  ", "└─ ") ==
            "  └─ Constants\n"

        str_color = sprint(
            SatelliteToolboxBase.print_node,
            "Constants",
            "  ",
            "├─ ";
            context = :color => true,
        )
        @test str_color == "\e[90m  \e[39m\e[90m├─ \e[39m\e[33m\e[1mConstants\e[39m\e[22m\n"
    end

    @testset "print_tree and print_tree_body" begin
        fields = SatelliteToolboxBase.PrintedField[
            ("Epoch",            SatelliteToolboxBase.epoch_string(2.4466e6), ""),
            ("Last Propagation", "100.0",                                     "s"),
        ]

        sections = SatelliteToolboxBase.PrintedSection[
            "Mean Elements" => [
                ("Semi-Major Axis", "7130.982",  "km"),
                ("Eccentricity",    "0.0001111", ""),
            ],
            "Constants" => [
                ("R₀", "6378.137",   "km"),
                ("J₂", "0.00108263", ""),
            ],
        ]

        expected = join(
            (
                "MyType:",
                "  Epoch            : 2.4466e6 (1986-06-18T12:00:00)",
                "  Last Propagation : 100.0 s",
                "  ├─ Mean Elements",
                "  │    Semi-Major Axis : 7130.982 km",
                "  │    Eccentricity    : 0.0001111",
                "  └─ Constants",
                "       R₀ : 6378.137 km",
                "       J₂ : 0.00108263",
            ),
            '\n',
        )

        str = sprint(SatelliteToolboxBase.print_tree, "MyType", fields, sections)
        @test str == expected

        # The body has no header and no trailing newline.
        str = sprint(SatelliteToolboxBase.print_tree_body, fields, sections)
        @test str == expected[(length("MyType:\n") + 1):end]

        # Without sections, only the fields are printed.
        str = sprint(
            SatelliteToolboxBase.print_tree,
            "MyType",
            fields,
            SatelliteToolboxBase.PrintedSection[],
        )
        @test str == join(
            (
                "MyType:",
                "  Epoch            : 2.4466e6 (1986-06-18T12:00:00)",
                "  Last Propagation : 100.0 s",
            ),
            '\n',
        )

        # The subsections are printed after the fields of their section, with the rails
        # extended while the section has siblings.
        nested = SatelliteToolboxBase.PrintedSection[
            SatelliteToolboxBase.PrintedSection(
                "Data",
                [("Comment", "Data comment", "")],
                [
                    SatelliteToolboxBase.PrintedSection(
                        "Mean Elements", [("Semi-Major Axis", "7130.982", "km")]
                    ),
                    SatelliteToolboxBase.PrintedSection(
                        "Parameters", [("Mass", "100.0", "kg")]
                    ),
                ],
            ),
            "Constants" => [("J₂", "0.00108263", "")],
        ]

        expected_nested = join(
            (
                "MyType:",
                "  ├─ Data",
                "  │    Comment : Data comment",
                "  │    ├─ Mean Elements",
                "  │    │    Semi-Major Axis : 7130.982 km",
                "  │    └─ Parameters",
                "  │         Mass : 100.0 kg",
                "  └─ Constants",
                "       J₂ : 0.00108263",
            ),
            '\n',
        )

        str = sprint(
            SatelliteToolboxBase.print_tree,
            "MyType",
            SatelliteToolboxBase.PrintedField[],
            nested,
        )
        @test str == expected_nested

        # The header must be highlighted when the output supports colors, and the
        # decorations must not change the text.
        str_color = sprint(
            SatelliteToolboxBase.print_tree,
            "MyType",
            fields,
            sections;
            context = :color => true,
        )
        @test startswith(str_color, "\e[1mMyType:\e[22m\n")
        @test replace(str_color, r"\e\[[0-9;]*m" => "") == expected
    end
end
