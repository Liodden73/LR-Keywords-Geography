--[[
    south_georgia_gps.lua — GPS Extension for South Georgia
    Part of: LR-Geography-Builder  (Geography Keyword Builder plugin)

    15 named regions with rectangular polygon boundaries derived from the
    interactive South Georgia polygon editor.  Each rectangle is stored as a
    4-point polygon so it can later be refined into a true polygon shape by
    re-exporting from the editor and replacing these entries.

    Format mirrors Norway.lua's  data.svalbard  structure:
      polygons       = { { name = "…", points = { {lat=,lon=}, … } }, … }
      bounding_boxes = { { name = "…", south=, north=, west=, east= }, … }

    Keyword path when matched:
      Geography > World > Europe > United Kingdom > South Georgia > <name>

    Coordinate system: WGS 84 (lat/lon decimal degrees).
    Negative values = South / West.
--]]

return {
    south_georgia = {

        -- ── Precise polygons (point-in-polygon tested first) ─────────────────
        -- Listed north-coast west→east, then east coast north→south, then south coast.
        polygons = {

            -- ── Northern coast – west to east ────────────────────────────────
            { name = "Bird Island", points = {
                { lat = -53.99, lon = -38.13 },
                { lat = -53.99, lon = -38.00 },
                { lat = -54.07, lon = -38.00 },
                { lat = -54.07, lon = -38.13 },
            } },

            { name = "Antarctic Bay", points = {
                { lat = -53.90, lon = -38.22 },
                { lat = -53.90, lon = -37.97 },
                { lat = -54.12, lon = -37.97 },
                { lat = -54.12, lon = -38.22 },
            } },

            { name = "Prince Olav Harbour", points = {
                { lat = -54.02, lon = -38.03 },
                { lat = -54.02, lon = -37.78 },
                { lat = -54.22, lon = -37.78 },
                { lat = -54.22, lon = -38.03 },
            } },

            { name = "Bay of Isles", points = {
                { lat = -53.95, lon = -37.70 },
                { lat = -53.95, lon = -37.08 },
                { lat = -54.23, lon = -37.08 },
                { lat = -54.23, lon = -37.70 },
            } },

            { name = "Salisbury Plain", points = {
                { lat = -54.00, lon = -37.45 },
                { lat = -54.00, lon = -37.20 },
                { lat = -54.13, lon = -37.20 },
                { lat = -54.13, lon = -37.45 },
            } },

            { name = "Possession Bay", points = {
                { lat = -54.01, lon = -37.30 },
                { lat = -54.01, lon = -37.07 },
                { lat = -54.18, lon = -37.07 },
                { lat = -54.18, lon = -37.30 },
            } },

            { name = "Fortuna Bay", points = {
                { lat = -54.04, lon = -36.99 },
                { lat = -54.04, lon = -36.74 },
                { lat = -54.25, lon = -36.74 },
                { lat = -54.25, lon = -36.99 },
            } },

            { name = "Stromness Bay", points = {
                { lat = -54.02, lon = -36.82 },
                { lat = -54.02, lon = -36.53 },
                { lat = -54.23, lon = -36.53 },
                { lat = -54.23, lon = -36.82 },
            } },

            { name = "Cumberland Bay", points = {
                { lat = -54.10, lon = -36.82 },
                { lat = -54.10, lon = -36.22 },
                { lat = -54.46, lon = -36.22 },
                { lat = -54.46, lon = -36.82 },
            } },

            { name = "St Andrews Bay", points = {
                { lat = -54.35, lon = -36.22 },
                { lat = -54.35, lon = -35.87 },
                { lat = -54.54, lon = -35.87 },
                { lat = -54.54, lon = -36.22 },
            } },

            -- ── Eastern coast – north to south ───────────────────────────────
            { name = "Royal Bay", points = {
                { lat = -54.46, lon = -36.10 },
                { lat = -54.46, lon = -35.72 },
                { lat = -54.63, lon = -35.72 },
                { lat = -54.63, lon = -36.10 },
            } },

            { name = "Gold Harbour", points = {
                { lat = -54.57, lon = -36.07 },
                { lat = -54.57, lon = -35.82 },
                { lat = -54.73, lon = -35.82 },
                { lat = -54.73, lon = -36.07 },
            } },

            { name = "Drygalski Fjord", points = {
                { lat = -54.63, lon = -36.12 },
                { lat = -54.63, lon = -35.52 },
                { lat = -54.83, lon = -35.52 },
                { lat = -54.83, lon = -36.12 },
            } },

            { name = "Cooper Bay", points = {
                { lat = -54.72, lon = -36.20 },
                { lat = -54.72, lon = -35.80 },
                { lat = -54.88, lon = -35.80 },
                { lat = -54.88, lon = -36.20 },
            } },

            -- ── Southern coast ────────────────────────────────────────────────
            { name = "King Haakon Bay", points = {
                { lat = -54.10, lon = -38.40 },
                { lat = -54.10, lon = -37.80 },
                { lat = -54.57, lon = -37.80 },
                { lat = -54.57, lon = -38.40 },
            } },
        },

        -- ── Broad rectangular catch-alls (empty — polygons cover all regions) ─
        bounding_boxes = {},
    },
}
