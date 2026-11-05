--[[
    falkland_islands_gps.lua — GPS Extension for Falkland Islands
    Part of: LR-Geography-Builder  (Geography Keyword Builder plugin)

    36 named place polygons (Level 1), 3 regions (Level 2: East Falkland,
    West Falkland, Falkland Sound) and one Falkland Islands catch-all polygon
    (Level 3), drawn in the Falkland Islands polygon editor.

    3-level structure (tested in this order; first hit wins):
      polygons        = Level 1 — detailed place     (IPTC City)
      bounding_boxes  = Level 1 — rectangles (none)
      regions         = Level 2 — island / sound region
      country_polygon = Level 3 — Falkland Islands catch-all incl. surrounding sea
      place_regions   = which Level 2 region each Level 1 place belongs to
                        (keyword hierarchy only). Places not listed go directly
                        under Falkland Islands. Taken from the owner's keyword
                        list LR-Geography-Falkland-Islands-GPS-LioddenMedia-v1-2.

    Keyword hierarchy (for Wildlife-plugin GPS keyword generation):
      [GEOGRAPHY]
        [WORLD]
          [SOUTH AMERICA]
            [TERRITORIES]
              Falkland Islands
                  {United Kingdom}
                  {South Atlantic Ocean}
                <region>                 (e.g. East Falkland)
                  <place>                (e.g. Port Stanley)
                <place without region>   (e.g. Carcass Island)

    Coordinate system: WGS 84 (lat/lon decimal degrees).
    Negative values = South / West.
--]]

return {
    meta = {
        version = "1.2.0",
        name = "Falkland Islands GPS Extension",
        region = "Falkland Islands",
        country = "Falkland Islands",
        continent = "South America",
        keyword_path = {
            "[GEOGRAPHY]",
            "[WORLD]",
            "[SOUTH AMERICA]",
            "[TERRITORIES]",
            "Falkland Islands"
        },
        -- Synonyms on the territory node (sovereign country + geographic context)
        synonyms = { "United Kingdom", "South Atlantic Ocean" }
    },

    falkland_islands = {
        -- Settlements list (unchanged from 1.1.0; not used for GPS lookup).
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

        -- ── Level 1 / Level 2 / Level 3 — from the polygon editor ────────────
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
                { lat = -51.3499, lon = -60.6612 },
                { lat = -51.3761, lon = -60.6783 },
                { lat = -51.3871, lon = -60.7132 },
            } },
            { name = "Pebble Island", points = {
                { lat = -51.2348, lon = -59.8274 },
                { lat = -51.2868, lon = -59.3111 },
                { lat = -51.3611, lon = -59.4711 },
                { lat = -51.3521, lon = -59.5953 },
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
                { lat = -52.3358, lon = -59.3639 },
                { lat = -52.3186, lon = -59.3193 },
                { lat = -52.2621, lon = -58.9969 },
                { lat = -52.2259, lon = -59.0234 },
                { lat = -52.1259, lon = -59.3083 },
                { lat = -52.1453, lon = -59.3598 },
                { lat = -52.1217, lon = -59.4175 },
                { lat = -52.1562, lon = -59.4903 },
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
                { lat = -51.3833, lon = -59.6974 },
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
            { name = "Bull Point", points = {
                { lat = -52.3358, lon = -59.3639 },
                { lat = -52.3186, lon = -59.3193 },
                { lat = -52.3290, lon = -59.2836 },
                { lat = -52.3563, lon = -59.3172 },
            } },
            { name = "Elephant Cays", points = {
                { lat = -52.1225, lon = -59.9023 },
                { lat = -52.1061, lon = -59.8542 },
                { lat = -52.1284, lon = -59.8254 },
                { lat = -52.1512, lon = -59.8597 },
            } },
            { name = "Great Island", points = {
                { lat = -51.9222, lon = -59.7141 },
                { lat = -51.9853, lon = -59.7382 },
                { lat = -52.0021, lon = -59.6855 },
                { lat = -51.9773, lon = -59.6558 },
                { lat = -51.9311, lon = -59.6647 },
            } },
            { name = "Ruggles Island", points = {
                { lat = -52.0508, lon = -59.6935 },
                { lat = -52.0370, lon = -59.7273 },
                { lat = -52.0609, lon = -59.7560 },
                { lat = -52.0952, lon = -59.7582 },
                { lat = -52.0985, lon = -59.7361 },
                { lat = -52.0770, lon = -59.7018 },
            } },
            { name = "Ruggles Bay", points = {
                { lat = -52.1343, lon = -59.6317 },
                { lat = -52.1179, lon = -59.5864 },
                { lat = -52.0635, lon = -59.5390 },
                { lat = -52.0166, lon = -59.5912 },
                { lat = -52.0102, lon = -59.6407 },
                { lat = -52.1120, lon = -59.7052 },
                { lat = -52.1331, lon = -59.6722 },
            } },
            { name = "North Arm", points = {
                { lat = -52.1259, lon = -59.3083 },
                { lat = -52.0981, lon = -59.3660 },
                { lat = -52.1217, lon = -59.4175 },
                { lat = -52.1453, lon = -59.3598 },
            } },
            { name = "Adventure Sound", points = {
                { lat = -52.0098, lon = -59.3269 },
                { lat = -52.0757, lon = -59.2163 },
                { lat = -52.1546, lon = -59.1655 },
                { lat = -52.1972, lon = -59.1051 },
                { lat = -52.2259, lon = -59.0234 },
                { lat = -52.1090, lon = -58.9252 },
                { lat = -52.0432, lon = -58.9492 },
                { lat = -52.0111, lon = -59.0234 },
                { lat = -51.9756, lon = -59.1277 },
                { lat = -51.9895, lon = -59.2905 },
            } },
            { name = "Low Bay", points = {
                { lat = -52.0757, lon = -58.9080 },
                { lat = -52.0301, lon = -58.8785 },
                { lat = -52.0276, lon = -58.7817 },
                { lat = -52.0402, lon = -58.7199 },
                { lat = -52.0964, lon = -58.6629 },
                { lat = -52.1238, lon = -58.6890 },
            } },
            { name = "Lively Island", points = {
                { lat = -52.1175, lon = -58.4122 },
                { lat = -51.9916, lon = -58.3141 },
                { lat = -51.9578, lon = -58.5297 },
                { lat = -52.0222, lon = -58.5606 },
                { lat = -52.0820, lon = -58.5427 },
            } },
            { name = "Mare Harbour", points = {
                { lat = -51.8786, lon = -58.4905 },
                { lat = -51.9112, lon = -58.4871 },
                { lat = -51.9206, lon = -58.4095 },
                { lat = -51.8943, lon = -58.3889 },
            } },
            { name = "Goose Green", points = {
                { lat = -51.8065, lon = -58.9892 },
                { lat = -51.8250, lon = -59.0062 },
                { lat = -51.8384, lon = -58.9777 },
                { lat = -51.8304, lon = -58.9604 },
                { lat = -51.8163, lon = -58.9653 },
            } },
            { name = "Choiseul Sound", points = {
                { lat = -51.8676, lon = -58.9780 },
                { lat = -51.9320, lon = -58.8936 },
                { lat = -51.9828, lon = -58.7508 },
                { lat = -51.9845, lon = -58.5880 },
                { lat = -51.8888, lon = -58.5269 },
                { lat = -51.8968, lon = -58.6677 },
                { lat = -51.8752, lon = -58.7686 },
                { lat = -51.8362, lon = -58.9259 },
            } },
            { name = "Volunteer Point", points = {
                { lat = -51.4668, lon = -57.8279 },
                { lat = -51.4985, lon = -57.8657 },
                { lat = -51.5083, lon = -57.8348 },
                { lat = -51.5264, lon = -57.7065 },
                { lat = -51.5156, lon = -57.7098 },
                { lat = -51.4886, lon = -57.7392 },
            } },
            { name = "Port Howard", points = {
                { lat = -51.6075, lon = -59.5280 },
                { lat = -51.6214, lon = -59.5433 },
                { lat = -51.6297, lon = -59.5260 },
                { lat = -51.6173, lon = -59.5045 },
            } },
            { name = "South Jason Island", points = {
                { lat = -51.2060, lon = -60.9782 },
                { lat = -51.1811, lon = -60.8340 },
                { lat = -51.2034, lon = -60.8066 },
                { lat = -51.2387, lon = -60.9302 },
            } },
        },

        regions = {
            { name = "Falkland Sound", points = {
                { lat = -51.5087, lon = -59.2863 },
                { lat = -51.4326, lon = -59.1847 },
                { lat = -51.4514, lon = -59.1531 },
                { lat = -51.5250, lon = -59.1367 },
                { lat = -51.5591, lon = -59.1833 },
                { lat = -51.6044, lon = -59.1833 },
                { lat = -51.6657, lon = -59.0735 },
                { lat = -51.7610, lon = -59.3674 },
                { lat = -51.8527, lon = -59.5335 },
                { lat = -51.9087, lon = -59.6132 },
                { lat = -51.9773, lon = -59.6558 },
                { lat = -52.0609, lon = -59.7560 },
                { lat = -52.1066, lon = -59.7589 },
                { lat = -52.0288, lon = -59.9881 },
                { lat = -51.9629, lon = -59.8384 },
                { lat = -51.8629, lon = -59.7615 },
                { lat = -51.7950, lon = -59.6777 },
                { lat = -51.7347, lon = -59.5857 },
                { lat = -51.6538, lon = -59.5129 },
                { lat = -51.6453, lon = -59.4292 },
            } },
            { name = "East Falkland", points = {
                { lat = -52.0609, lon = -59.7560 },
                { lat = -52.1066, lon = -59.7589 },
                { lat = -52.1777, lon = -59.6599 },
                { lat = -52.2887, lon = -59.6613 },
                { lat = -52.3722, lon = -59.3962 },
                { lat = -52.3563, lon = -59.3172 },
                { lat = -52.2621, lon = -58.9969 },
                { lat = -52.2230, lon = -58.8342 },
                { lat = -52.1773, lon = -58.8023 },
                { lat = -52.1680, lon = -58.5846 },
                { lat = -51.9510, lon = -58.5489 },
                { lat = -51.9078, lon = -58.2111 },
                { lat = -51.6768, lon = -57.6604 },
                { lat = -51.5156, lon = -57.7098 },
                { lat = -51.3495, lon = -57.8911 },
                { lat = -51.3692, lon = -58.2784 },
                { lat = -51.2971, lon = -58.3841 },
                { lat = -51.2791, lon = -58.5544 },
                { lat = -51.3152, lon = -58.6739 },
                { lat = -51.2714, lon = -58.8593 },
                { lat = -51.2163, lon = -58.9966 },
                { lat = -51.2877, lon = -58.9636 },
                { lat = -51.3666, lon = -58.8895 },
                { lat = -51.3701, lon = -58.9966 },
                { lat = -51.3975, lon = -59.1106 },
                { lat = -51.4514, lon = -59.1531 },
                { lat = -51.5250, lon = -59.1367 },
                { lat = -51.5591, lon = -59.1833 },
                { lat = -51.6044, lon = -59.1833 },
                { lat = -51.6657, lon = -59.0735 },
                { lat = -51.7610, lon = -59.3674 },
                { lat = -51.8527, lon = -59.5335 },
                { lat = -51.9087, lon = -59.6132 },
                { lat = -51.9773, lon = -59.6558 },
            } },
            { name = "West Falkland", points = {
                { lat = -51.4315, lon = -59.5933 },
                { lat = -51.4435, lon = -59.7114 },
                { lat = -51.4136, lon = -59.7351 },
                { lat = -51.3904, lon = -59.7996 },
                { lat = -51.3774, lon = -59.9277 },
                { lat = -51.3868, lon = -59.9661 },
                { lat = -51.3654, lon = -60.0224 },
                { lat = -51.4073, lon = -60.0938 },
                { lat = -51.4724, lon = -60.1268 },
                { lat = -51.4767, lon = -60.2216 },
                { lat = -51.4172, lon = -60.3726 },
                { lat = -51.3298, lon = -60.6617 },
                { lat = -51.3420, lon = -60.6670 },
                { lat = -51.3499, lon = -60.6612 },
                { lat = -51.3761, lon = -60.6783 },
                { lat = -51.4403, lon = -60.6473 },
                { lat = -51.5711, lon = -60.4509 },
                { lat = -51.6496, lon = -60.2490 },
                { lat = -51.6623, lon = -60.6473 },
                { lat = -51.6998, lon = -60.7008 },
                { lat = -51.9510, lon = -60.6651 },
                { lat = -51.9481, lon = -60.8691 },
                { lat = -52.0157, lon = -60.8279 },
                { lat = -52.0204, lon = -60.9267 },
                { lat = -51.9929, lon = -60.9714 },
                { lat = -51.9870, lon = -61.1499 },
                { lat = -52.1217, lon = -61.0208 },
                { lat = -52.1588, lon = -60.8862 },
                { lat = -52.2799, lon = -60.6418 },
                { lat = -52.1958, lon = -60.4605 },
                { lat = -52.1857, lon = -60.3520 },
                { lat = -52.0280, lon = -60.1762 },
                { lat = -52.0288, lon = -59.9881 },
                { lat = -51.9629, lon = -59.8384 },
                { lat = -51.8629, lon = -59.7615 },
                { lat = -51.7950, lon = -59.6777 },
                { lat = -51.7347, lon = -59.5857 },
                { lat = -51.6538, lon = -59.5129 },
                { lat = -51.6453, lon = -59.4292 },
                { lat = -51.5087, lon = -59.2863 },
                { lat = -51.4326, lon = -59.1847 },
                { lat = -51.3821, lon = -59.1779 },
                { lat = -51.2868, lon = -59.3111 },
                { lat = -51.3611, lon = -59.4711 },
            } },
        },

        country_polygon = {
            name = "Falkland Islands",
            points = {
                { lat = -53.4226, lon = -56.4258 },
                { lat = -51.0138, lon = -54.3604 },
                { lat = -49.7954, lon = -62.2046 },
                { lat = -52.6697, lon = -63.5889 },
            },
        },

        bounding_boxes = {},

        -- Level 2 parent of each Level 1 place (keyword hierarchy only).
        -- Places not listed sit directly under Falkland Islands.
        place_regions = {
            ["Adventure Sound"] = "East Falkland",
            ["Bay of Harbours"] = "East Falkland",
            ["Berkeley Sound"] = "East Falkland",
            ["Bleaker Island"] = "East Falkland",
            ["Bull Point"] = "East Falkland",
            ["Choiseul Sound"] = "East Falkland",
            ["Elephant Cays"] = "Falkland Sound",
            ["Goose Green"] = "East Falkland",
            ["Great Island"] = "Falkland Sound",
            ["Gypsy Cove"] = "East Falkland",
            ["Kidney Cove"] = "East Falkland",
            ["Low Bay"] = "East Falkland",
            ["Mare Harbour"] = "East Falkland",
            ["Mount Pleasant"] = "East Falkland",
            ["North Arm"] = "East Falkland",
            ["Port Howard"] = "West Falkland",
            ["Port Stanley"] = "East Falkland",
            ["Ruggles Bay"] = "Falkland Sound",
            ["Ruggles Island"] = "Falkland Sound",
            ["Volunteer Point"] = "East Falkland",
        },
    }
}
