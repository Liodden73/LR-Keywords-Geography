--[[
    falkland_islands_gps.lua — GPS Extension for Falkland Islands
    Part of: LR-Geography-Builder  (Geography Keyword Builder plugin)

    Named regions with polygon boundaries for Falkland Islands (Islas Malvinas),
    a British Overseas Territory in the South Atlantic Ocean.

    Format mirrors svalbard_gps.lua and south_georgia_gps.lua structure:
      polygons       = { { name = "…", points = { {lat=,lon=}, … } }, … }
      bounding_boxes = { { name = "…", south=, north=, west=, east= }, … }

    Keyword hierarchy (for Wildlife-plugin GPS keyword generation):
      [GEOGRAPHY]
        [WORLD]
          [SOUTH AMERICA]
            Falkland Islands
              <name>

    Coordinate system: WGS 84 (lat/lon decimal degrees).
    Negative values = South / West.
    
    NOTE: Initial polygons are PLACEHOLDER rectangles. Refine with the
    interactive polygon editor, then paste the export here.
--]]

return {
    meta = {
        version = "1.0.0",
        name = "Falkland Islands GPS Extension",
        region = "Falkland Islands",
        country = "Falkland Islands",
        continent = "South America",
        -- Keyword path template using container convention:
        -- [GEOGRAPHY] > [WORLD] > [SOUTH AMERICA] > Falkland Islands > {place}
        keyword_path = {
            "[GEOGRAPHY]",
            "[WORLD]",
            "[SOUTH AMERICA]",
            "Falkland Islands"
        }
    },

    falkland_islands = {
            settlements = {
                    "Barren Island",
                    "Beaver Island",
                    "Bleaker Island",
                    "Carcass Island",
                    "Dyke Island",
                    "George Island",
                    "Golding Island",
                    "Keppel Island",
                    "Mount Pleasant",
                    "New Island",
                    "Pebble Island",
                    "Port Stanley",
                    "Saunders Island",
                    "Sea Lion Island",
                    "Speedwell Island",
                    "Weddell Island",
                    "West Point Island",
            },

            -- Curated POLYGONS for named locations (settlements, bays, straits, islands).
            -- These are precise shapes (point-in-polygon) and are tested BEFORE the
            -- rectangular bounding_boxes below. Points are { lat, lon } and the
            -- ring is auto-closed. Keyword becomes
            -- Geography > World > South America > Falkland Islands > <name>.
            polygons = {
                    { name = "Port Stanley", points = {
                            { lat = -51.6823, lon = -57.9258 },
                            { lat = -51.6829, lon = -57.7519 },
                            { lat = -51.6916, lon = -57.7788 },
                            { lat = -51.7005, lon = -57.7838 },
                            { lat = -51.7000, lon = -57.8500 },
                            { lat = -51.6952, lon = -57.9247 },
                    } },
                    { name = "Mount Pleasant", points = {
                            { lat = -51.8002, lon = -58.4934 },
                            { lat = -51.8160, lon = -58.4152 },
                            { lat = -51.8352, lon = -58.4232 },
                            { lat = -51.8359, lon = -58.4984 },
                    } },
                    { name = "Carcass Island", points = {
                            { lat = -51.2197, lon = -60.6694 },
                            { lat = -51.2314, lon = -60.5342 },
                            { lat = -51.3275, lon = -60.4904 },
                            { lat = -51.3142, lon = -60.6296 },
                    } },
                    { name = "Saunders Island", points = {
                            { lat = -51.2404, lon = -60.3465 },
                            { lat = -51.2838, lon = -60.0739 },
                            { lat = -51.3375, lon = -60.0334 },
                            { lat = -51.4073, lon = -60.0938 },
                            { lat = -51.4232, lon = -60.3225 },
                    } },
                    { name = "West Point Island", points = {
                            { lat = -51.3288, lon = -60.7498 },
                            { lat = -51.3220, lon = -60.7199 },
                            { lat = -51.3462, lon = -60.6569 },
                            { lat = -51.3761, lon = -60.6783 },
                            { lat = -51.3871, lon = -60.7132 },
                    } },
                    { name = "Pebble Island", points = {
                            { lat = -51.2348, lon = -59.8274 },
                            { lat = -51.2868, lon = -59.3111 },
                            { lat = -51.3611, lon = -59.4711 },
                            { lat = -51.3533, lon = -59.5892 },
                            { lat = -51.3233, lon = -59.6187 },
                            { lat = -51.3177, lon = -59.7169 },
                            { lat = -51.2898, lon = -59.8508 },
                    } },
                    { name = "New Island", points = {
                            { lat = -51.6757, lon = -61.3470 },
                            { lat = -51.6740, lon = -61.1981 },
                            { lat = -51.7495, lon = -61.2218 },
                            { lat = -51.7723, lon = -61.3166 },
                    } },
                    { name = "Bleaker Island", points = {
                            { lat = -52.1133, lon = -58.8218 },
                            { lat = -52.1773, lon = -58.8023 },
                            { lat = -52.2230, lon = -58.8342 },
                            { lat = -52.2621, lon = -58.9969 },
                            { lat = -52.2259, lon = -59.0234 },
                    } },
                    { name = "Falkland Sound", points = {
                            { lat = -51.3821, lon = -59.2973 },
                            { lat = -51.3958, lon = -58.9224 },
                            { lat = -51.6836, lon = -58.9828 },
                            { lat = -52.1588, lon = -59.6049 },
                            { lat = -52.0026, lon = -60.0032 },
                    } },
                    { name = "Sea Lion Island", points = {
                            { lat = -52.4430, lon = -59.0199 },
                            { lat = -52.4656, lon = -59.1579 },
                            { lat = -52.4259, lon = -59.1813 },
                            { lat = -52.3940, lon = -59.0289 },
                    } },
                    { name = "Barren Island", points = {
                            { lat = -52.3894, lon = -59.7594 },
                            { lat = -52.3144, lon = -59.6571 },
                            { lat = -52.3919, lon = -59.6125 },
                            { lat = -52.4150, lon = -59.7237 },
                    } },
                    { name = "George Island", points = {
                            { lat = -52.3051, lon = -59.7855 },
                            { lat = -52.2887, lon = -59.6613 },
                            { lat = -52.3144, lon = -59.6571 },
                            { lat = -52.3894, lon = -59.7594 },
                            { lat = -52.3681, lon = -59.8501 },
                    } },
                    { name = "Speedwell Island", points = {
                            { lat = -52.3051, lon = -59.7855 },
                            { lat = -52.2887, lon = -59.6613 },
                            { lat = -52.1777, lon = -59.6599 },
                            { lat = -52.1255, lon = -59.7849 },
                            { lat = -52.1916, lon = -59.8370 },
                    } },
                    { name = "Bay of Harbours", points = {
                            { lat = -52.3563, lon = -59.3172 },
                            { lat = -52.2621, lon = -58.9969 },
                            { lat = -52.2259, lon = -59.0234 },
                            { lat = -52.1002, lon = -59.3797 },
                            { lat = -52.1331, lon = -59.4992 },
                            { lat = -52.3261, lon = -59.3887 },
                    } },
                    { name = "Dyke Island", points = {
                            { lat = -51.9481, lon = -60.8691 },
                            { lat = -52.0157, lon = -60.8279 },
                            { lat = -52.0204, lon = -60.9267 },
                            { lat = -51.9929, lon = -60.9714 },
                    } },
                    { name = "Beaver Island", points = {
                            { lat = -51.8286, lon = -61.3820 },
                            { lat = -51.8930, lon = -61.2344 },
                            { lat = -51.8146, lon = -61.1691 },
                            { lat = -51.7785, lon = -61.2138 },
                            { lat = -51.8112, lon = -61.3943 },
                    } },
                    { name = "Weddell Island", points = {
                            { lat = -51.9929, lon = -60.9714 },
                            { lat = -51.9481, lon = -60.8691 },
                            { lat = -51.7542, lon = -60.8327 },
                            { lat = -51.7627, lon = -61.0874 },
                            { lat = -51.8146, lon = -61.1691 },
                            { lat = -51.8930, lon = -61.2344 },
                            { lat = -51.9870, lon = -61.1499 },
                    } },
                    { name = "Keppel Island", points = {
                            { lat = -51.2838, lon = -60.0739 },
                            { lat = -51.3375, lon = -60.0334 },
                            { lat = -51.3688, lon = -59.9393 },
                            { lat = -51.3152, lon = -59.8707 },
                            { lat = -51.2688, lon = -59.9668 },
                    } },
                    { name = "Golding Island", points = {
                            { lat = -51.3724, lon = -59.6595 },
                            { lat = -51.3904, lon = -59.7996 },
                            { lat = -51.3576, lon = -59.8346 },
                            { lat = -51.3049, lon = -59.7785 },
                            { lat = -51.3177, lon = -59.7169 },
                            { lat = -51.3416, lon = -59.7193 },
                            { lat = -51.3608, lon = -59.6908 },
                            { lat = -51.3662, lon = -59.6575 },
                    } },
                    { name = "Gypsy Cove", points = {
                            { lat = -51.6712, lon = -57.8150 },
                            { lat = -51.6827, lon = -57.8135 },
                            { lat = -51.6828, lon = -57.7845 },
                            { lat = -51.6701, lon = -57.7847 },
                    } },
                    { name = "Kidney Cove", points = {
                            { lat = -51.6384, lon = -57.7618 },
                            { lat = -51.6314, lon = -57.7524 },
                            { lat = -51.6194, lon = -57.7683 },
                            { lat = -51.6237, lon = -57.7721 },
                    } },
                    { name = "Berkeley Sound", points = {
                            { lat = -51.6237, lon = -57.7721 },
                            { lat = -51.5967, lon = -58.0669 },
                            { lat = -51.5515, lon = -58.1747 },
                            { lat = -51.5293, lon = -58.1692 },
                            { lat = -51.5070, lon = -58.1149 },
                            { lat = -51.4946, lon = -57.9831 },
                            { lat = -51.5395, lon = -57.7620 },
                            { lat = -51.6194, lon = -57.7683 },
                    } },
            },

            -- Rectangular BOUNDING BOXES for broad regions. These are fallback matches
            -- when point-in-polygon tests (above) fail. Tested AFTER polygons.
            bounding_boxes = {
            },
    }
}
