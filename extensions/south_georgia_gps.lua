--[[
    south_georgia_gps.lua — GPS Extension for South Georgia
    Part of: LR-Geography-Builder  (Geography Keyword Builder plugin)

    37 named regions with polygon boundaries derived from the interactive
    South Georgia polygon editor.  Each region is stored as a polygon so it
    can be refined by re-exporting from the editor and replacing these entries.

    Format mirrors Norway.lua's  data.svalbard  structure:
      polygons       = { { name = "…", points = { {lat=,lon=}, … } }, … }
      bounding_boxes = { { name = "…", south=, north=, west=, east= }, … }

    Keyword hierarchy (for Wildlife-plugin GPS keyword generation):
      [GEOGRAPHY]
        [WORLD]
          [SOUTH AMERICA]
            South Georgia & South Sandwich Islands
              South Georgia
                <name>

    Coordinate system: WGS 84 (lat/lon decimal degrees).
    Negative values = South / West.
--]]

return {
    meta = {
        version = "1.0.0",
        name = "South Georgia GPS Extension",
        region = "South Georgia",
        country = "South Georgia",
        continent = "South America",
        -- Keyword path template using container convention:
        -- [GEOGRAPHY] > [WORLD] > [SOUTH AMERICA] > South Georgia > {place}
        keyword_path = {
            "[GEOGRAPHY]",
            "[WORLD]",
            "[SOUTH AMERICA]",
            "South Georgia"
        }
    },

    south_georgia = {

        -- ── Precise polygons (point-in-polygon tested first) ─────────────────
        polygons = {
            { name = "Bird Island", points = {
                { lat = -54.0023, lon = -38.1016 },
                { lat = -53.9900, lon = -38.0000 },
                { lat = -54.0030, lon = -38.0005 },
                { lat = -54.0330, lon = -38.0815 },
            } },
            { name = "Trinity Island", points = {
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
                { lat = -54.0832, lon = -36.8344 },
                { lat = -54.0993, lon = -36.7534 },
                { lat = -54.1817, lon = -36.7706 },
                { lat = -54.1785, lon = -36.8447 },
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
                { lat = -54.3930, lon = -36.3332 },
                { lat = -54.3774, lon = -36.4169 },
                { lat = -54.3201, lon = -36.4327 },
                { lat = -54.3057, lon = -36.4962 },
                { lat = -54.2977, lon = -36.4923 },
                { lat = -54.2805, lon = -36.4789 },
            } },
            { name = "St Andrews Bay", points = {
                { lat = -54.3762, lon = -36.1574 },
                { lat = -54.4680, lon = -36.0338 },
                { lat = -54.4920, lon = -36.1656 },
                { lat = -54.4365, lon = -36.2748 },
            } },
            { name = "Royal Bay", points = {
                { lat = -54.5047, lon = -35.9754 },
                { lat = -54.5462, lon = -35.8965 },
                { lat = -54.5838, lon = -35.9627 },
                { lat = -54.6107, lon = -36.1169 },
                { lat = -54.5770, lon = -36.1941 },
                { lat = -54.5179, lon = -36.1471 },
            } },
            { name = "Gold Harbour", points = {
                { lat = -54.6208, lon = -35.9953 },
                { lat = -54.5987, lon = -35.9129 },
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
                { lat = -54.0219, lon = -37.3091 },
                { lat = -54.0145, lon = -37.3417 },
            } },
            { name = "Right Whale Bay", points = {
                { lat = -54.0207, lon = -37.6989 },
                { lat = -54.0300, lon = -37.5358 },
                { lat = -54.0243, lon = -37.4850 },
                { lat = -54.0074, lon = -37.4603 },
                { lat = -53.9912, lon = -37.4531 },
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
                { lat = -54.7409, lon = -35.9988 },
                { lat = -54.7433, lon = -35.8470 },
                { lat = -54.6853, lon = -35.9061 },
            } },
            { name = "Moraine Fjord", points = {
                { lat = -54.3860, lon = -36.4976 },
                { lat = -54.3201, lon = -36.4327 },
                { lat = -54.3057, lon = -36.4962 },
                { lat = -54.3780, lon = -36.5316 },
            } },
            { name = "Sunset Fjord", points = {
                { lat = -54.0707, lon = -37.5106 },
                { lat = -54.0691, lon = -37.4071 },
                { lat = -54.0441, lon = -37.3810 },
                { lat = -54.0032, lon = -37.3968 },
                { lat = -54.0082, lon = -37.4483 },
                { lat = -54.0206, lon = -37.4670 },
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
        },

        -- ── Broad rectangular catch-alls (empty — polygons cover all regions) ─
        bounding_boxes = {},
    },
}
