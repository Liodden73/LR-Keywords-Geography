--[[
    south_georgia_gps.lua — GPS Extension for South Georgia
    Part of: LR-Geography-Builder  (Geography Keyword Builder plugin)

    40 named regions with polygon boundaries derived from the interactive
    South Georgia polygon editor.  Each region is stored as a polygon so it
    can be refined by re-exporting from the editor and replacing these entries.

    3-level structure (tested in this order; first hit wins):
      polygons        = Level 1 — city / detailed place  (IPTC City)
                        { { name = "…", points = { {lat=,lon=}, … } }, … }
      regions         = Level 2 — state / large region   (IPTC State)
                        same format as polygons; empty for South Georgia
      country_polygon = Level 3 — country / catch-all     (IPTC Country)
                        { name = "South Georgia", points = { … } }
      bounding_boxes  = legacy rectangles, kept empty for backwards compat

    Keyword hierarchy (for Wildlife-plugin GPS keyword generation):
      [GEOGRAPHY]
        [WORLD]
          [SOUTH AMERICA]
            [TERRITORIES]
              South Georgia
                  {United Kingdom}
                  {Subantarctic island}
                  {South Atlantic Ocean}
                <name>

    Coordinate system: WGS 84 (lat/lon decimal degrees).
    Negative values = South / West.
--]]

return {
    meta = {
        version = "1.2.0",
        name = "South Georgia GPS Extension",
        region = "South Georgia",
        country = "South Georgia",
        continent = "South America",
        -- Keyword path template using container convention:
        -- [GEOGRAPHY] > [WORLD] > [SOUTH AMERICA] > [TERRITORIES] > South Georgia > {place}
        keyword_path = {
            "[GEOGRAPHY]",
            "[WORLD]",
            "[SOUTH AMERICA]",
            "[TERRITORIES]",
            "South Georgia"
        },
        -- Synonyms on the territory node (sovereign country + geographic context)
        synonyms = { "United Kingdom", "Subantarctic island", "South Atlantic Ocean" }
    },

    south_georgia = {

        -- ── Level 1 — detailed place polygons (IPTC City; tested first) ──────
        polygons = {
            { name = "Bird Island", points = {
                { lat = -54.0023, lon = -38.1016 },
                { lat = -53.9900, lon = -38.0000 },
                { lat = -54.0030, lon = -38.0005 },
                { lat = -54.0330, lon = -38.0815 },
            } },
            { name = "Willis Islands", points = {
                { lat = -53.9702, lon = -38.2359 },
                { lat = -53.9840, lon = -38.1123 },
                { lat = -54.0412, lon = -38.1226 },
                { lat = -54.0618, lon = -38.2544 },
                { lat = -53.9904, lon = -38.3286 },
            } },
            { name = "Salisbury Plain", points = {
                { lat = -54.0441, lon = -37.3810 },
                { lat = -54.0511, lon = -37.2567 },
                { lat = -54.0706, lon = -37.2600 },
                { lat = -54.0691, lon = -37.4071 },
            } },
            { name = "Possession Bay", points = {
                { lat = -54.0710, lon = -37.0962 },
                { lat = -54.0666, lon = -37.0236 },
                { lat = -54.1373, lon = -37.1067 },
                { lat = -54.1377, lon = -37.1705 },
                { lat = -54.0719, lon = -37.1695 },
            } },
            { name = "Fortuna Bay", points = {
                { lat = -54.0795, lon = -36.8282 },
                { lat = -54.0971, lon = -36.7407 },
                { lat = -54.1817, lon = -36.7706 },
                { lat = -54.1785, lon = -36.8447 },
                { lat = -54.1293, lon = -36.8464 },
            } },
            { name = "Stromness Bay", points = {
                { lat = -54.1206, lon = -36.6394 },
                { lat = -54.1636, lon = -36.5536 },
                { lat = -54.1809, lon = -36.5913 },
                { lat = -54.1898, lon = -36.6401 },
            } },
            { name = "Cumberland East Bay", points = {
                { lat = -54.2436, lon = -36.4712 },
                { lat = -54.2468, lon = -36.3963 },
                { lat = -54.3686, lon = -36.3043 },
                { lat = -54.4175, lon = -36.3534 },
                { lat = -54.4077, lon = -36.4173 },
                { lat = -54.3201, lon = -36.4327 },
                { lat = -54.3057, lon = -36.4962 },
                { lat = -54.2977, lon = -36.4923 },
                { lat = -54.2805, lon = -36.4789 },
            } },
            { name = "St Andrews Bay", points = {
                { lat = -54.3762, lon = -36.1574 },
                { lat = -54.4680, lon = -36.0338 },
                { lat = -54.4890, lon = -36.1594 },
                { lat = -54.4171, lon = -36.2371 },
            } },
            { name = "Royal Bay", points = {
                { lat = -54.5047, lon = -35.9754 },
                { lat = -54.5462, lon = -35.8965 },
                { lat = -54.5838, lon = -35.9627 },
                { lat = -54.6107, lon = -36.1169 },
                { lat = -54.5770, lon = -36.1941 },
                { lat = -54.5179, lon = -36.1471 },
                { lat = -54.5364, lon = -36.0812 },
                { lat = -54.5207, lon = -36.0389 },
                { lat = -54.5113, lon = -36.0492 },
            } },
            { name = "Gold Harbour", points = {
                { lat = -54.6208, lon = -35.9953 },
                { lat = -54.5995, lon = -35.9583 },
                { lat = -54.6011, lon = -35.9164 },
                { lat = -54.6333, lon = -35.9026 },
                { lat = -54.6577, lon = -35.9263 },
            } },
            { name = "Drygalski Fjord", points = {
                { lat = -54.7393, lon = -36.1533 },
                { lat = -54.8248, lon = -35.8656 },
                { lat = -54.8687, lon = -35.8971 },
                { lat = -54.8058, lon = -36.1402 },
            } },
            { name = "Cooper Bay", points = {
                { lat = -54.7959, lon = -35.9397 },
                { lat = -54.7845, lon = -35.8992 },
                { lat = -54.7973, lon = -35.8353 },
                { lat = -54.8248, lon = -35.8656 },
                { lat = -54.8105, lon = -35.9137 },
            } },
            { name = "King Haakon Bay", points = {
                { lat = -54.1351, lon = -37.4486 },
                { lat = -54.1349, lon = -37.2021 },
                { lat = -54.1800, lon = -37.2093 },
                { lat = -54.1914, lon = -37.4071 },
            } },
            { name = "Grytviken", points = {
                { lat = -54.2721, lon = -36.5071 },
                { lat = -54.2894, lon = -36.5174 },
                { lat = -54.2977, lon = -36.4923 },
                { lat = -54.2805, lon = -36.4789 },
                { lat = -54.2744, lon = -36.4923 },
            } },
            { name = "Husvik Harbour", points = {
                { lat = -54.1978, lon = -36.7191 },
                { lat = -54.1898, lon = -36.6401 },
                { lat = -54.1665, lon = -36.6399 },
                { lat = -54.1685, lon = -36.7232 },
            } },
            { name = "Stromness", points = {
                { lat = -54.1685, lon = -36.7232 },
                { lat = -54.1459, lon = -36.7170 },
                { lat = -54.1572, lon = -36.6398 },
                { lat = -54.1661, lon = -36.6399 },
            } },
            { name = "Leith Harbour", points = {
                { lat = -54.1367, lon = -36.6396 },
                { lat = -54.1287, lon = -36.7088 },
                { lat = -54.1459, lon = -36.7170 },
                { lat = -54.1572, lon = -36.6398 },
            } },
            { name = "Antarctic Bay", points = {
                { lat = -54.1544, lon = -37.0397 },
                { lat = -54.0795, lon = -36.8825 },
                { lat = -54.0566, lon = -36.9656 },
                { lat = -54.1250, lon = -37.0700 },
            } },
            { name = "Prince Olav Harbour", points = {
                { lat = -54.0530, lon = -37.1576 },
                { lat = -54.0719, lon = -37.1695 },
                { lat = -54.0710, lon = -37.0962 },
                { lat = -54.0433, lon = -37.1201 },
            } },
            { name = "Prion Island", points = {
                { lat = -54.0309, lon = -37.2732 },
                { lat = -54.0349, lon = -37.2581 },
                { lat = -54.0184, lon = -37.2292 },
                { lat = -54.0138, lon = -37.2552 },
            } },
            { name = "Albatross Island", points = {
                { lat = -54.0316, lon = -37.3556 },
                { lat = -54.0347, lon = -37.3206 },
                { lat = -54.0181, lon = -37.3154 },
                { lat = -54.0100, lon = -37.3346 },
            } },
            { name = "Right Whale Bay", points = {
                { lat = -54.0207, lon = -37.6989 },
                { lat = -54.0110, lon = -37.6282 },
                { lat = -53.9848, lon = -37.6735 },
                { lat = -54.0070, lon = -37.7106 },
            } },
            { name = "Godthul", points = {
                { lat = -54.2829, lon = -36.3304 },
                { lat = -54.3109, lon = -36.2926 },
                { lat = -54.2841, lon = -36.2418 },
                { lat = -54.2620, lon = -36.2933 },
            } },
            { name = "Elsehul", points = {
                { lat = -54.0334, lon = -37.9729 },
                { lat = -54.0277, lon = -37.9420 },
                { lat = -54.0035, lon = -37.9578 },
                { lat = -54.0170, lon = -37.9966 },
            } },
            { name = "Cumberland West Bay", points = {
                { lat = -54.1870, lon = -36.4804 },
                { lat = -54.1878, lon = -36.5728 },
                { lat = -54.2151, lon = -36.6483 },
                { lat = -54.2119, lon = -36.7932 },
                { lat = -54.2450, lon = -36.8718 },
                { lat = -54.3145, lon = -36.6923 },
                { lat = -54.2436, lon = -36.4712 },
            } },
            { name = "Ocean Harbour", points = {
                { lat = -54.3213, lon = -36.2398 },
                { lat = -54.3353, lon = -36.2810 },
                { lat = -54.3606, lon = -36.2521 },
                { lat = -54.3437, lon = -36.2109 },
            } },
            { name = "Hound Bay", points = {
                { lat = -54.3950, lon = -36.2700 },
                { lat = -54.4171, lon = -36.2371 },
                { lat = -54.3762, lon = -36.1574 },
                { lat = -54.3437, lon = -36.2109 },
                { lat = -54.3606, lon = -36.2521 },
            } },
            { name = "Cooper Island", points = {
                { lat = -54.8019, lon = -35.8161 },
                { lat = -54.7944, lon = -35.7564 },
                { lat = -54.8387, lon = -35.7687 },
                { lat = -54.8319, lon = -35.8182 },
            } },
            { name = "Iris Bay", points = {
                { lat = -54.6845, lon = -35.9857 },
                { lat = -54.6863, lon = -36.0273 },
                { lat = -54.7082, lon = -35.9710 },
                { lat = -54.7222, lon = -35.9146 },
                { lat = -54.6988, lon = -35.9064 },
            } },
            { name = "Moraine Fjord", points = {
                { lat = -54.3860, lon = -36.4976 },
                { lat = -54.3201, lon = -36.4327 },
                { lat = -54.3057, lon = -36.4962 },
                { lat = -54.3780, lon = -36.5316 },
            } },
            { name = "Sunset Fjord", points = {
                { lat = -54.0691, lon = -37.5042 },
                { lat = -54.0691, lon = -37.4071 },
                { lat = -54.0441, lon = -37.3810 },
                { lat = -54.0346, lon = -37.4270 },
                { lat = -54.0429, lon = -37.4582 },
            } },
            { name = "Church Bay", points = {
                { lat = -54.0277, lon = -37.8438 },
                { lat = -54.0132, lon = -37.7449 },
                { lat = -53.9656, lon = -37.7315 },
                { lat = -53.9942, lon = -37.8774 },
            } },
            { name = "Ice Fjord", points = {
                { lat = -54.0384, lon = -37.5962 },
                { lat = -54.0314, lon = -37.7095 },
                { lat = -54.0537, lon = -37.7579 },
                { lat = -54.1023, lon = -37.7216 },
                { lat = -54.0630, lon = -37.5777 },
            } },
            { name = "Queen Maud Bay", points = {
                { lat = -54.2046, lon = -37.4208 },
                { lat = -54.2640, lon = -37.4421 },
                { lat = -54.2432, lon = -37.2732 },
                { lat = -54.2127, lon = -37.2629 },
            } },
            { name = "Newark Bay", points = {
                { lat = -54.3590, lon = -36.9841 },
                { lat = -54.3758, lon = -36.9305 },
                { lat = -54.3582, lon = -36.8234 },
                { lat = -54.3229, lon = -36.9189 },
            } },
            { name = "Annenkov Island", points = {
                { lat = -54.4545, lon = -37.0919 },
                { lat = -54.5004, lon = -36.9594 },
                { lat = -54.5326, lon = -37.1290 },
                { lat = -54.4900, lon = -37.1764 },
            } },
            { name = "Undine South Harbour", points = {
                { lat = -54.5506, lon = -36.5721 },
                { lat = -54.5748, lon = -36.5000 },
                { lat = -54.5306, lon = -36.4204 },
                { lat = -54.4856, lon = -36.5371 },
                { lat = -54.5179, lon = -36.6531 },
            } },
            { name = "Rosita Harbour", points = {
                { lat = -54.0051, lon = -37.4479 },
                { lat = -54.0223, lon = -37.4685 },
                { lat = -54.0265, lon = -37.4369 },
                { lat = -54.0078, lon = -37.3892 },
            } },
            { name = "Moltke Harbour", points = {
                { lat = -54.5113, lon = -36.0492 },
                { lat = -54.5207, lon = -36.0389 },
                { lat = -54.5364, lon = -36.0812 },
                { lat = -54.5193, lon = -36.1038 },
                { lat = -54.5103, lon = -36.0726 },
            } },
            { name = "Twitcher Bay", points = {
                { lat = -54.6863, lon = -36.0273 },
                { lat = -54.7064, lon = -36.0448 },
                { lat = -54.7450, lon = -35.9565 },
                { lat = -54.7339, lon = -35.9013 },
                { lat = -54.7222, lon = -35.9146 },
                { lat = -54.7082, lon = -35.9710 },
            } },
        },

        -- ── Level 2 — no large sub-regions for South Georgia (IPTC State) ────
        regions = {},

        -- ── Level 3 — country / catch-all polygon (IPTC Country; tested last)
        -- Follows the island's NW-SE diagonal with a ~20 km sea buffer.
        -- Approximate; may be refined in the polygon editor.
        country_polygon = {
            name = "South Georgia",
            points = {
                { lat = -53.75, lon = -38.75 },  -- NW
                { lat = -53.78, lon = -37.80 },
                { lat = -53.90, lon = -36.80 },
                { lat = -54.10, lon = -35.90 },
                { lat = -54.50, lon = -35.40 },
                { lat = -54.90, lon = -35.45 },
                { lat = -55.05, lon = -36.00 },
                { lat = -55.00, lon = -37.20 },
                { lat = -54.60, lon = -38.60 },
                { lat = -54.10, lon = -38.80 },
            },
        },

        -- ── Legacy rectangular catch-alls (kept empty for backwards compat) ──
        bounding_boxes = {},
    },
}
