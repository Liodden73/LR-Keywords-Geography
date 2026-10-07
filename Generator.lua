--[[
        Generator.lua — pure Lua data-filtering module.

        IMPORTANT: This module has ZERO Lightroom SDK dependencies. There must be
        NO top-level `import 'LrXxx'` calls anywhere in this file (a past mistake
        of importing the SDK at the top of a library module caused the whole plugin
        to fail to load). This file only performs string / table manipulation.

        Generator.generate(data, prefs) takes the bundled country data table and the
        user's selections (prefs) and returns the complete keyword .txt content as a
        single UTF-8 string.

        .txt format rules reproduced here:
          * Root keyword:              [GEOGRAPHY]
          * Level 2 wrappers:          [NATURE] (physical features) and [WORLD]
                                       (administrative geography). Everything sits
                                       under one of these two.
          * Nature sections:           children of [NATURE]: [NATIONAL PARK],
                                       [NATURE RESERVE], [MOUNTAIN], [FJORD], [LAKE],
                                       [RIVER], [ISLAND], [VIEWPOINT]
          * National Park / Nature Reserve: no country synonym (implied by location)
          * Mountain / Fjord / Lake / River / Island / Viewpoint: get a {Country}
            synonym on the next line (indented one level deeper) ONLY when
            prefs.country_synonym is true. Default OFF to keep the list slim.
          * Administrative:            [GEOGRAPHY] > [WORLD] > [CONTINENT] > <Country> >
                                       County > Municipality > Primary City > Districts ;
                                       secondary cities (no districts)
          * Container nodes (all-caps + brackets) are non-exportable markers managed
            by ListDoctor plugin after import. Lightroom strips [] on import.
          * Tab indentation only, no commas in names, UTF-8 throughout.
          * prefs.country_synonym (bool) — new unified field; also accepts the legacy
            prefs.norway_synonym for backward compatibility.
]]

local Generator = {}

-- ── helpers ────────────────────────────────────────────────────────────────

-- Remove commas from a name (LR rejects commas in keyword names with a
-- "corrupted data" error). The bundled data is already comma-free; this is a
-- defensive second line of defence.
local function sanitize(name)
        if not name then return "" end
        name = tostring(name)
        name = name:gsub(",", " ")
        name = name:gsub("%s+", " ")
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        return name
end

-- Alphabetical sort (byte order). Norwegian Æ Ø Å sort after ASCII which is
-- fine — Lightroom re-sorts keywords alphabetically on import anyway.
local function sortedCopy(list)
        local out = {}
        for i = 1, #list do out[i] = list[i] end
        table.sort(out, function(a, b) return a < b end)
        return out
end

-- Returns the list only if it has at least one entry (empty Lua tables are truthy,
-- which would otherwise emit empty container nodes like "[NATIONAL PARK]").
local function nonEmpty(list)
        if type(list) == "table" and #list > 0 then return list end
        return nil
end

-- Mountain names at/above the active cutoff (region "svalbard" uses its own cutoff).
local function pickMountains(data, prefs)
        local mainlandCut = prefs.mainland_cutoff or 1800
        local svalbardCut = prefs.svalbard_cutoff or 1000
        local picked = {}
        for _, m in ipairs(data.mountains or {}) do
                if type(m) == "table" and m.name then
                        local elev = m.elev or 0
                        local cut = (m.region == "svalbard") and svalbardCut or mainlandCut
                        if elev >= cut then picked[#picked + 1] = m.name end
                end
        end
        return picked
end

-- ── main entry point ─────────────────────────────────────────────────────────

-- prefs = {
--   national_parks = bool,  national_parks_max = number,
--   nature_reserves = bool, nature_reserves_max = number,
--   mountains = bool, mainland_cutoff = number, svalbard_cutoff = number,
--   fjords = bool, fjords_max = number,
--   lakes = bool,  lakes_max = number,
--   rivers = bool, rivers_max = number,
--   islands = bool, islands_max = number,
--   viewpoints = bool, viewpoints_max = number,
--   administrative = bool,
--   counties = { ["Akershus"] = true, ... },    -- keyed by county display name
--   remote_islands_names    = { "Svalbard", ... }, -- ordered list of RI for this country
--   remote_islands_selected = { ["Svalbard"] = true, ... }, -- which ones to include
--   country_synonym = bool,  -- add {Country} synonym to nature features (default false)
--   norway_synonym = bool,   -- LEGACY alias for country_synonym; still accepted
-- }
function Generator.generate(data, prefs)
        local lines = {}
        local TAB = "\t"

        -- Resolve country name and native synonym text from data.meta.
        local countryName      = (data.meta and data.meta.country)     or "Norway"
        local nativeName       = (data.meta and data.meta.native_name) -- may be nil

        -- Whether to add a {Country} synonym to nature features. Default OFF to
        -- keep the list slim. Accepts both the new country_synonym field and the
        -- legacy norway_synonym field (backward compat).
        local wantSynonym = (prefs.country_synonym or prefs.norway_synonym) and true or false
        -- The synonym text appended after each nature keyword (e.g. "{Norway}").
        local countrySynonymText = "{" .. countryName .. "}"

        local function add(depth, text)
                lines[#lines + 1] = string.rep(TAB, depth) .. sanitize(text)
        end

        -- synonym line: raw braces preserved, NOT sanitized (keep the { } )
        local function addSynonym(depth, text)
                lines[#lines + 1] = string.rep(TAB, depth) .. text
        end

        -- Country synonym for a nature feature — emitted only when the user opted in.
        local function addCountrySynonym(depth)
                if wantSynonym then
                        lines[#lines + 1] = string.rep(TAB, depth) .. countrySynonymText
                end
        end

        -- Container node: all-caps + square brackets (non-exportable marker).
        local function container(name)
                return "[" .. name:upper() .. "]"
        end

        -- ── Root ────────────────────────────────────────────────────────────────
        -- Level 2 has exactly two wrappers under [GEOGRAPHY]:
        --   [NATURE]  → physical features ([MOUNTAIN], [FJORD], [ISLAND], …)
        --   [WORLD]   → administrative geography ([CONTINENT] > Country > …)
        -- These wrappers keep root tidy as more countries/continents are added.
        -- Container nodes (all-caps + []) are managed by ListDoctor after import.
        lines[#lines + 1] = container("Geography")

        -- ── Nature wrapper (emit only if at least one nature section is selected) ─
        local anyNature = (prefs.national_parks and nonEmpty(data.national_parks))
                or (prefs.nature_reserves and nonEmpty(data.nature_reserves))
                or (prefs.mountains and #pickMountains(data, prefs) > 0)
                or (prefs.fjords and nonEmpty(data.fjords))
                or (prefs.lakes and nonEmpty(data.lakes))
                or (prefs.rivers and nonEmpty(data.rivers))
                or (prefs.islands and nonEmpty(data.islands))
                or (prefs.viewpoints and nonEmpty(data.viewpoints))

        if anyNature then
                add(1, container("Nature"))
        end

        -- ── National Parks (no {Norway} synonym) ─────────────────────────────────
        if prefs.national_parks and nonEmpty(data.national_parks) then
                add(2, container("National Park"))
                local items = sortedCopy(data.national_parks)
                local maxN = prefs.national_parks_max or #items
                for i = 1, math.min(maxN, #items) do
                        add(3, items[i])
                end
        end

        -- ── Nature Reserves (no {Norway} synonym) ────────────────────────────────
        if prefs.nature_reserves and nonEmpty(data.nature_reserves) then
                add(2, container("Nature Reserve"))
                local items = sortedCopy(data.nature_reserves)
                local maxN = prefs.nature_reserves_max or #items
                for i = 1, math.min(maxN, #items) do
                        add(3, items[i])
                end
        end

        -- ── Mountains and Peaks (region-filtered, {Norway} synonym) ──────────────
        local mountainPicks = prefs.mountains and pickMountains(data, prefs) or {}
        if #mountainPicks > 0 then
                add(2, container("Mountain"))
                local picked = sortedCopy(mountainPicks)
                local maxM = math.min(prefs.mountains_max or 100, #picked)
                for i = 1, maxM do
                        add(3, picked[i])
                        addCountrySynonym(4)
                end
        end

        -- ── Fjords (top-N by importance, then alphabetical, {Norway} synonym) ────
        if prefs.fjords and nonEmpty(data.fjords) then
                local maxN = prefs.fjords_max or math.min(100, #data.fjords)
                local picked = {}
                for i = 1, math.min(maxN, #data.fjords) do picked[#picked + 1] = data.fjords[i] end
                add(2, container("Fjord"))
                picked = sortedCopy(picked)
                for _, name in ipairs(picked) do
                        add(3, name)
                        addCountrySynonym(4)
                end
        end

        -- ── Lakes ────────────────────────────────────────────────────────────────
        if prefs.lakes and nonEmpty(data.lakes) then
                local maxN = prefs.lakes_max or math.min(100, #data.lakes)
                local picked = {}
                for i = 1, math.min(maxN, #data.lakes) do picked[#picked + 1] = data.lakes[i] end
                add(2, container("Lake"))
                picked = sortedCopy(picked)
                for _, name in ipairs(picked) do
                        add(3, name)
                        addCountrySynonym(4)
                end
        end

        -- ── Rivers ────────────────────────────────────────────────────────────────
        if prefs.rivers and nonEmpty(data.rivers) then
                local maxN = prefs.rivers_max or math.min(100, #data.rivers)
                local picked = {}
                for i = 1, math.min(maxN, #data.rivers) do picked[#picked + 1] = data.rivers[i] end
                add(2, container("River"))
                picked = sortedCopy(picked)
                for _, name in ipairs(picked) do
                        add(3, name)
                        addCountrySynonym(4)
                end
        end

        -- ── Islands (top-N by importance, then alphabetical, {Norway} synonym) ────
        -- Norway has ~240 000 islands, so this is a curated + capped list bundled in
        -- importance order; the slider takes the top-N most notable.
        if prefs.islands and nonEmpty(data.islands) then
                local maxN = prefs.islands_max or math.min(100, #data.islands)
                local picked = {}
                for i = 1, math.min(maxN, #data.islands) do picked[#picked + 1] = data.islands[i] end
                add(2, container("Island"))
                picked = sortedCopy(picked)
                for _, name in ipairs(picked) do
                        add(3, name)
                        addCountrySynonym(4)
                end
        end

        -- ── Viewpoints ({Norway} synonym) ────────────────────────────────────────
        if prefs.viewpoints and nonEmpty(data.viewpoints) then
                local picked = {}
                for _, v in ipairs(data.viewpoints) do
                        -- Accept both { name = "...", suffix = "..." } and plain strings
                        -- (several older data files store viewpoints as strings).
                        local name = (type(v) == "table") and ((v.name or "") .. (v.suffix or "")) or tostring(v)
                        if name ~= "" then picked[#picked + 1] = name end
                end
                add(2, container("Viewpoint"))
                picked = sortedCopy(picked)
                local maxN = prefs.viewpoints_max or math.min(100, #picked)
                for i = 1, math.min(maxN, #picked) do
                        add(3, picked[i])
                        addCountrySynonym(4)
                end
        end

        -- ── World wrapper > Europe > Norway > County > Municipality > City ───────
        local riNames    = prefs.remote_islands_names    or {}
        local riSelected = prefs.remote_islands_selected or {}
        local prefsCounties = prefs.counties or {}
        -- admin_detail: 1=Less (counties only), 2=More (counties+municipalities),
        --               3=All (municipalities+cities+districts). Default=All.
        local adminDetail   = math.min( 3, math.max( 1, math.floor( (prefs.admin_detail or 3) + 0.5 ) ) )

        -- Determine whether any administrative content is selected at all.
        local anyCounty = false
        if prefs.administrative and data.counties then
                for _, county in ipairs(data.counties) do
                        if prefsCounties[county.name] then anyCounty = true break end
                end
        end
        local anyRI = false
        for _, riName in ipairs(riNames) do
                if riSelected[riName] then anyRI = true break end
        end

        if prefs.administrative and (anyCounty or anyRI) then
                add(1, container("World"))
                add(2, container(data.meta and data.meta.continent or "Europe"))
                add(3, countryName)
                if nativeName then
                        addSynonym(4, "{" .. nativeName .. "}")
                end

                if data.counties then
                        for _, county in ipairs(data.counties) do
                                if prefsCounties[county.name] then
                                        add(4, county.name)
                                        
                                        -- Flat structure: cities directly under the county
                                        -- (no municipality level, e.g. Uruguay, Moldova, Slovenia,
                                        -- Montenegro, Belarus, microstates). These should be shown
                                        -- even at Basic level since there's no ADM2 alternative.
                                        if adminDetail >= 1 then
                                                for _, cityName in ipairs(county.cities or {}) do
                                                        add(5, cityName)
                                                end
                                        end
                                        
                                        -- Level 2 (More / All): include municipalities
                                        if adminDetail >= 2 then
                                                for _, muni in ipairs(county.municipalities or {}) do
                                                        add(5, muni.name)
                                                        -- Level 3 (All): include cities and districts
                                                        if adminDetail >= 3 then
                                                                if muni.primary_city then
                                                                        add(6, muni.primary_city)
                                                                        for _, d in ipairs(muni.districts or {}) do
                                                                                add(7, d)
                                                                        end
                                                                end
                                                                for _, cityName in ipairs(muni.cities or {}) do
                                                                        add(6, cityName)
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end
                end

                -- Remote islands: iterate in declared order, emit each selected one.
                -- Svalbard and Jan Mayen get settlement sub-keywords when data exists.
                for _, riName in ipairs(riNames) do
                        if riSelected[riName] then
                                add(4, riName)
                                if adminDetail >= 2 then
                                        if riName == "Svalbard" and data.svalbard then
                                                local settlements = sortedCopy(data.svalbard.settlements or {})
                                                for _, s in ipairs(settlements) do add(5, s) end
                                        elseif riName == "Jan Mayen" and data.jan_mayen then
                                                local settlements = sortedCopy(data.jan_mayen.settlements or {})
                                                for _, s in ipairs(settlements) do add(5, s) end
                                        end
                                end
                        end
                end
        end

        return table.concat(lines, "\n") .. "\n"
end

return Generator
