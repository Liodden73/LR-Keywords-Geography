--[[
        ListVerification.lua — Geography Keyword Builder

        Data management window, using the same native f:tab_view +
        stopModalWithResult / while-loop navigation pattern as LR-ListDoctor.

        Four tabs:
          1. Keyword List Builder  — opens KeywordBuilder.lua (dofile after loop)
          2. List Overview         — bundled country database table
          3. Verification Monitor  — three-level (county / municipality / city)
                                     verification table with per-item conflict
                                     result, action popup, and Save button
          4. Help                  — usage guidance (stub)
]]

local LrView            = import 'LrView'
local LrBinding         = import 'LrBinding'
local LrColor           = import 'LrColor'
local LrDialogs         = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrPathUtils       = import 'LrPathUtils'
local LrPrefs           = import 'LrPrefs'
local LrHttp            = import 'LrHttp'
local LrTasks           = import 'LrTasks'

-- ── Bundled data files ────────────────────────────────────────────────────────

local pluginPath = _PLUGIN.path
local dataDir    = LrPathUtils.child( pluginPath, "data" )

local norwayData = dofile( LrPathUtils.child( dataDir, "Norway.lua"       ) )
local swedenData = dofile( LrPathUtils.child( dataDir, "Sweden.lua"       ) )
local panamaData = dofile( LrPathUtils.child( dataDir, "Panama.lua"       ) )
local usData     = dofile( LrPathUtils.child( dataDir, "UnitedStates.lua" ) )

-- Bundled pure-Lua JSON decoder (dkjson, MIT licence).
local dkjson = dofile( LrPathUtils.child( pluginPath, "dkjson.lua" ) )

local COUNTRIES = {
        { id = "Norway",       name = "Norway",        filename = "Norway.lua",       data = norwayData },
        { id = "Sweden",       name = "Sweden",        filename = "Sweden.lua",       data = swedenData },
        { id = "Panama",       name = "Panama",        filename = "Panama.lua",       data = panamaData },
        { id = "UnitedStates", name = "United States", filename = "UnitedStates.lua", data = usData     },
}

-- Per-country label overrides for the three hierarchy levels.
-- Keys must match COUNTRIES[*].id exactly.
local LABELS = {
        Norway       = { county = "County",   muni = "Municipality", city = "City" },
        Sweden       = { county = "County",   muni = "Municipality", city = "City" },
        Panama       = { county = "Province", muni = "District",     city = "City" },
        UnitedStates = { county = "State",    muni = "County",       city = "City" },
}
local DEFAULT_LABELS = { county = "County", muni = "Municipality", city = "City" }

-- ── Wikidata verification support ─────────────────────────────────────────────
--
-- One SPARQL call per country × level fetches the official name set.
-- Results are cached for the whole plugin session.

local WIKIDATA_CACHE = {}

-- Wikidata entity type (Q-code) per country × level.
-- ci = nil  →  no Wikidata check for cities (too heterogeneous).
local WIKIDATA_TYPES = {
        Norway       = { co = "Q507390",   mu = "Q755707",   ci = nil },
        Sweden       = { co = "Q200547",   mu = "Q127448",   ci = nil },
        Panama       = { co = "Q608190",   mu = "Q739779",   ci = nil },
        UnitedStates = { co = "Q35657",    mu = "Q13221722", ci = nil },
}

-- Preferred label language(s) per country for the Wikidata label service.
local WIKIDATA_LANG = {
        Norway       = "no,nb,en",
        Sweden       = "sv,en",
        Panama       = "es,en",
        UnitedStates = "en",
}

-- Percent-encode a string for safe inclusion in a URL query parameter.
local function urlEncode( s )
        s = tostring( s )
        s = s:gsub( "([^%w%-%.%_%~ ])", function( c )
                return string.format( "%%%02X", string.byte( c ) )
        end )
        s = s:gsub( " ", "+" )
        return s
end

-- Query Wikidata SPARQL for all canonical names at a given country × level.
-- Returns { [name] = true } on success, or nil on failure / no data.
-- Each unique country+level combination is queried at most once per session.
local function fetchWikidataNames( cid, level )
        local cacheKey = cid .. "_" .. level
        if WIKIDATA_CACHE[ cacheKey ] then
                return WIKIDATA_CACHE[ cacheKey ]
        end

        local typeTable = WIKIDATA_TYPES[ cid ]
        if not typeTable then return nil end
        local qcode = typeTable[ level ]
        if not qcode then return nil end   -- city level: skip Wikidata

        local lang   = WIKIDATA_LANG[ cid ] or "en"
        local sparql =
                'SELECT ?item ?itemLabel WHERE { ' ..
                '?item wdt:P31 wd:' .. qcode .. '. ' ..
                'SERVICE wikibase:label ' ..
                '{ bd:serviceParam wikibase:language "' .. lang .. '". } }'

        local url     = "https://query.wikidata.org/sparql?format=json&query="
                        .. urlEncode( sparql )
        local headers = {
                { field = "User-Agent", value = "LR-Geography-Builder/0.9 (liodden-media)" },
                { field = "Accept",     value = "application/sparql-results+json" },
        }

        local body = LrHttp.get( url, headers, 30 )
        if not body or body == "" then return nil end

        local data, _pos, decErr = dkjson.decode( body )
        if decErr or type( data ) ~= "table" then return nil end

        local nameSet  = {}
        local bindings = ( data.results and data.results.bindings ) or {}
        for _, b in ipairs( bindings ) do
                local lbl = b.itemLabel and b.itemLabel.value
                if lbl then nameSet[ lbl ] = true end
        end

        -- Reject suspiciously small result sets (wrong Q-code guard).
        local count = 0
        for _ in pairs( nameSet ) do count = count + 1 end
        if count < 5 then return nil end

        WIKIDATA_CACHE[ cacheKey ] = nameSet
        return nameSet
end

-- Stable string identifiers for the four tabs.
local TAB_IDS = { KB = "builder", OV = "overview", MN = "monitor", HLP = "help" }

-- ── Column widths for List Overview ──────────────────────────────────────────

local W_COUNTRY  = 90
local W_LISTNAME = 110
local W_FILE     = 150
local W_FILESIZE = 60
local W_VERSION  = 50
local W_VERIFIED = 85
local W_UPDATED  = 85
local W_BUTTON   = 60
local CONTENT_W  = W_COUNTRY + W_LISTNAME + W_FILE + W_FILESIZE
                 + W_VERSION + W_VERIFIED + W_BUTTON + W_UPDATED + W_BUTTON + 6 * 8

-- ── Column widths for Verification Monitor ───────────────────────────────────

local W_M_NAME = 145  -- name cell (widest — municipality names can be long)
local W_M_CONF = 85   -- conflict result cell ("-" or short suggested name)
local W_M_ACT  = 65   -- action popup cell ("—" or "Change")
-- G_W: width of one group column (+ scrollbar allowance).
local G_W          = W_M_NAME + W_M_CONF + W_M_ACT + 12 + 16   -- ~323 px
-- Total monitor width: 3 groups + inter-group spacing
local CONTENT_W_MN = G_W * 3 + 30

-- ── Approximate dialog background grey for scrolled_view content ─────────────
-- LR Classic dialog background is roughly 0.9 (light mode).
local DLG_BG = LrColor( 0.9, 0.9, 0.9 )

-- ── Geo data extraction ───────────────────────────────────────────────────────

local function extractGeoData( cdata )
        local counties, munis, cities = {}, {}, {}
        if cdata and cdata.counties then
                for _, co in ipairs( cdata.counties ) do
                        counties[ #counties + 1 ] = co.name or "?"
                        local mlist = co.municipalities or {}
                        for _, mu in ipairs( mlist ) do
                                munis[ #munis + 1 ] = mu.name or "?"
                                local clist = mu.cities or {}
                                for _, ci in ipairs( clist ) do
                                        if type( ci ) == "string" then
                                                cities[ #cities + 1 ] = ci
                                        elseif type( ci ) == "table" then
                                                cities[ #cities + 1 ] = ci.name or "?"
                                        end
                                end
                        end
                end
        end
        return counties, munis, cities
end

local GEO = {}
for _, c in ipairs( COUNTRIES ) do
        local cos, mus, cis = extractGeoData( c.data )
        GEO[ c.id ] = { counties = cos, munis = mus, cities = cis }
end

-- ── Helper functions ──────────────────────────────────────────────────────────

local function getVersion( data )
        return ( data and data.meta and data.meta.version ) or "?"
end

local function getListName( data )
        return ( data and data.meta and data.meta.native_name ) or "?"
end

local function getCountryName( cid )
        for _, c in ipairs( COUNTRIES ) do
                if c.id == cid then return c.name end
        end
        return cid
end

local function getFileSize( filename )
        local path = LrPathUtils.child( dataDir, filename )
        local fh   = io.open( path, "rb" )
        if not fh then return "?" end
        local bytes = fh:seek( "end" )
        fh:close()
        return math.floor( ( bytes + 512 ) / 1024 ) .. " KB"
end

-- Return the next patch-incremented version string (e.g. "0.5.0" → "0.5.1").
local function nextPatchVersion( ver )
        local maj, min, pat = ver:match( "^(%d+)%.(%d+)%.(%d+)$" )
        if maj then
                return maj .. "." .. min .. "." .. tostring( tonumber(pat) + 1 )
        end
        return ver .. ".1"
end

-- Compute the version that a Save would produce for a given country.
-- Uses the currently-saved list version in prefs if available; otherwise
-- falls back to the data file's meta.version.
local function computeNextVersion( cid, prefs )
        local current = prefs[ "list_version_" .. cid ]
        if not current then
                for _, c in ipairs( COUNTRIES ) do
                        if c.id == cid then
                                current = getVersion( c.data )
                                break
                        end
                end
        end
        return nextPatchVersion( current or "0.0.0" )
end

-- Check a single name for known conflict patterns.
-- Returns the suggested correct name if a conflict is found, or nil if OK.
-- Current rule: "NameA - NameB" dual-language form → suggest NameB
-- (the second part, which in Norwegian dual-name municipalities is typically
-- the primary Norwegian/Bokmål name).
local function checkName( name )
        local _, b = name:match( "^(.+) %- (.+)$" )
        if b then return b end
        return nil
end

-- ── Main entry point ──────────────────────────────────────────────────────────

LrFunctionContext.callWithContext( "ListVerification", function( context )

        local prefs = LrPrefs.prefsForPlugin()
        local f     = LrView.osFactory()
        local props = LrBinding.makePropertyTable( context )

        -- Restore per-country props from prefs.
        for _, c in ipairs( COUNTRIES ) do
                props[ "verified_"    .. c.id ] = prefs[ "verified_"    .. c.id ] or "—"
                props[ "updated_"     .. c.id ] = prefs[ "updated_"     .. c.id ] or "—"
                props[ "listname_"    .. c.id ] = prefs[ "listname_"    .. c.id ] or getListName( c.data )
                -- list_version_: the version label shown in List Overview; may have been
                -- bumped beyond the data file's meta.version via a Save in the Monitor.
                props[ "list_version_" .. c.id ] = prefs[ "list_version_" .. c.id ] or getVersion( c.data )
        end

        -- Which country is currently open in the Verification Monitor.
        props.verify_country_id = nil

        -- Track which countries have had their verification props initialised this session.
        local verInited = {}

        -- Populate verification props for one country from prefs (or seed defaults).
        --
        -- Conflict text (vcKey) is ALWAYS initialised to "—" (unverified).
        -- Previous run's conflict results are intentionally NOT restored — the
        -- user must click Verify to see current results.
        --
        -- Action (vaKey) IS restored from prefs so the user's "change" decisions
        -- survive across sessions.  Old "none" values (removed option) are
        -- sanitised to "dash".
        local function initVerPropsForCountry( cid )
                if verInited[ cid ] then return end
                verInited[ cid ] = true
                local geo = GEO[ cid ]
                if not geo then return end
                local savedCo = prefs[ "ver_" .. cid .. "_co" ] or {}
                local savedMu = prefs[ "ver_" .. cid .. "_mu" ] or {}
                local savedCi = prefs[ "ver_" .. cid .. "_ci" ] or {}
                -- Sanitise saved action value: only "change" is preserved; anything else
                -- (including the old "none" option) resets to "dash".
                local function validAction( v )
                        if v == "change" then return "change" end
                        return "dash"
                end
                for i = 1, #geo.counties do
                        props[ "vcco_" .. cid .. "_" .. i ] = "—"
                        props[ "vaco_" .. cid .. "_" .. i ] = validAction( savedCo[ i ] and savedCo[ i ].a )
                end
                for i = 1, #geo.munis do
                        props[ "vcmu_" .. cid .. "_" .. i ] = "—"
                        props[ "vamu_" .. cid .. "_" .. i ] = validAction( savedMu[ i ] and savedMu[ i ].a )
                end
                for i = 1, #geo.cities do
                        props[ "vcci_" .. cid .. "_" .. i ] = "—"
                        props[ "vaci_" .. cid .. "_" .. i ] = validAction( savedCi[ i ] and savedCi[ i ].a )
                end
        end

        ------------------------------------------------------------------------
        -- Tab navigation — LR-ListDoctor pattern
        ------------------------------------------------------------------------

        props.activeTabId = TAB_IDS.OV

        local contents
        local currentDialog = TAB_IDS.OV
        local switching     = false

        local function switchTab( target )
                if switching then return end
                switching = true
                LrDialogs.stopModalWithResult( contents, target )
        end

        props:addObserver( "activeTabId", function()
                if props.activeTabId ~= currentDialog then
                        switchTab( props.activeTabId )
                end
        end )

        for _, c in ipairs( COUNTRIES ) do
                local cid = c.id
                props:addObserver( "listname_" .. cid, function()
                        prefs[ "listname_" .. cid ] = props[ "listname_" .. cid ]
                end )
        end

        ------------------------------------------------------------------------
        -- Tab 1 — List Overview
        ------------------------------------------------------------------------

        local function buildOverviewPanel()
                local headerRow = f:row {
                        spacing = 6,
                        f:static_text { title = "Country",       width = W_COUNTRY,  font = "<system/bold>" },
                        f:static_text { title = "List name",     width = W_LISTNAME, font = "<system/bold>" },
                        f:static_text { title = "File",          width = W_FILE,     font = "<system/bold>" },
                        f:static_text { title = "File size",     width = W_FILESIZE, font = "<system/bold>" },
                        f:static_text { title = "Version",       width = W_VERSION,  font = "<system/bold>" },
                        f:static_text { title = "Last verified", width = W_VERIFIED, font = "<system/bold>" },
                        f:spacer      { width = W_BUTTON },
                        f:static_text { title = "Last update",   width = W_UPDATED,  font = "<system/bold>" },
                        f:spacer      { width = W_BUTTON },
                }

                local rowViews = {}
                for _, country in ipairs( COUNTRIES ) do
                        local verKey  = "verified_"     .. country.id
                        local updKey  = "updated_"      .. country.id
                        local nmKey   = "listname_"     .. country.id
                        local lvKey   = "list_version_" .. country.id
                        local cname   = country.name
                        rowViews[ #rowViews + 1 ] = f:row {
                                spacing = 6,
                                f:static_text { title = cname, width = W_COUNTRY },
                                f:edit_field {
                                        bind_to_object = props,
                                        value          = LrView.bind( nmKey ),
                                        width          = W_LISTNAME,
                                        immediate      = true,
                                },
                                f:static_text { title = "data/" .. country.filename, width = W_FILE },
                                f:static_text { title = getFileSize( country.filename ), width = W_FILESIZE },
                                -- Version column: shows list_version prop (may be bumped by Save).
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( lvKey ),
                                        width          = W_VERSION,
                                },
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( verKey ),
                                        width          = W_VERIFIED,
                                },
                                -- Verify button → opens Monitor for this country.
                                f:push_button {
                                        title  = "Verify",
                                        width  = W_BUTTON,
                                        action = function()
                                                props.verify_country_id = country.id
                                                initVerPropsForCountry( country.id )
                                                switchTab( TAB_IDS.MN )
                                        end,
                                },
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( updKey ),
                                        width          = W_UPDATED,
                                },
                                f:push_button {
                                        title  = "Update",
                                        width  = W_BUTTON,
                                        action = function()
                                                local answer = LrDialogs.confirm(
                                                        "Update Keyword List",
                                                        "Do you want to update the keyword list for " .. cname .. "?",
                                                        "Update", "Cancel"
                                                )
                                                if answer == "ok" then
                                                        LrDialogs.message(
                                                                "Update — " .. cname,
                                                                "Update functionality is not yet implemented.",
                                                                "info"
                                                        )
                                                        local today = os.date( "%Y-%m-%d" )
                                                        props[ updKey ]                   = today
                                                        prefs[ "updated_" .. country.id ] = today
                                                end
                                        end,
                                },
                        }
                end

                local tableSpec = {
                        spacing = f:control_spacing(),
                        headerRow,
                        f:separator { fill_horizontal = 1 },
                }
                for _, row in ipairs( rowViews ) do
                        tableSpec[ #tableSpec + 1 ] = row
                end

                return f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),
                        f:spacer { height = 5 },
                        f:static_text { title = "List Overview", font = "<system/bold>" },
                        f:spacer { height = 5 },
                        f:static_text {
                                title           = "All bundled country keyword databases and their current status.",
                                width           = CONTENT_W,
                                height_in_lines = 2,
                        },
                        f:separator { fill_horizontal = 1 },
                        f:spacer { height = 5 },
                        f:column( tableSpec ),
                }
        end

        ------------------------------------------------------------------------
        -- Tab 2 — Verification Monitor
        --
        -- Three side-by-side groups (county / municipality / city level).
        -- Each group has its own Verify button, a scrollable name list with
        -- bound Conflicts and Action cells, and a row count at the bottom.
        --
        -- Verify logic:
        --   • Dual-language "NameA - NameB" → conflict; suggest NameB.
        --   • All other names → OK; Conflicts shows "-", Action shows "—".
        -- After verify the panel is rebuilt (via switchTab MN) so that
        -- conflict rows sort to the top of each group.
        --
        -- Prop naming (cid = country id, i = GEO index):
        --   "vcco_<cid>_<i>"  conflict text for county i
        --   "vaco_<cid>_<i>"  action value ("dash"|"change")
        --   (same with vcmu_/vamu_ for munis, vcci_/vaci_ for cities)
        ------------------------------------------------------------------------

        local function buildMonitorPanel()
                local cid = props.verify_country_id

                if not cid then
                        return f:column {
                                bind_to_object  = props,
                                spacing         = f:control_spacing(),
                                f:spacer { height = 5 },
                                f:static_text { title = "Verification Monitor", font = "<system/bold>" },
                                f:spacer { height = 5 },
                                f:static_text {
                                        title           = "Click 'Verify' for a country in the List Overview tab to open its verification data here.",
                                        width           = CONTENT_W_MN,
                                        height_in_lines = 2,
                                },
                        }
                end

                local cname = cid
                for _, c in ipairs( COUNTRIES ) do
                        if c.id == cid then cname = c.name; break end
                end

                local geo    = GEO[ cid ]
                local labels = LABELS[ cid ] or DEFAULT_LABELS
                local nextVer = computeNextVersion( cid, prefs )

                ----------------------------------------------------------------
                -- makeGroup — builds one scrollable verification group.
                --
                --   label    : column header ("County", "Municipality", etc.)
                --   items    : flat array of name strings
                --   vcPfx    : prop prefix for conflict cells ("vcco_", etc.)
                --   vaPfx    : prop prefix for action cells  ("vaco_", etc.)
                --   prefKey  : prefs sub-key ("co" | "mu" | "ci")
                ----------------------------------------------------------------

                local function makeGroup( label, items, vcPfx, vaPfx, prefKey )

                        -- Build display order each time the panel is constructed.
                        -- Rows with an actual conflict suggestion sort first;
                        -- the rest follow in alphabetical name order.
                        local display = {}
                        for i = 1, #items do
                                display[ #display + 1 ] = { i = i, name = items[i] }
                        end
                        table.sort( display, function( a, b )
                                local vcA = props[ vcPfx .. cid .. "_" .. a.i ] or "—"
                                local vcB = props[ vcPfx .. cid .. "_" .. b.i ] or "—"
                                local aC  = ( vcA ~= "—" ) and ( vcA ~= "-" )
                                local bC  = ( vcB ~= "—" ) and ( vcB ~= "-" )
                                if aC ~= bC then return aC end
                                return a.name < b.name
                        end )

                        -- Verify action: compare every item against Wikidata canonical names
                        -- (or fall back to pattern analysis if Wikidata is unreachable).
                        --
                        -- Runs in an async task so the UI updates row-by-row as each item
                        -- is checked.  The Wikidata HTTP call (one per country × level) runs
                        -- first; rows show "..." during the fetch then fill in one by one.
                        --
                        -- Action = "change" is PRESERVED: if the user already flagged an
                        -- entry for renaming, re-verifying keeps that decision intact.
                        --
                        --   Conflicts = "—"        → not yet verified (initial state)
                        --   Conflicts = "..."       → currently being checked
                        --   Conflicts = "-"         → confirmed OK
                        --   Conflicts = "SomeName"  → suggested canonical spelling
                        local function doVerify()
                                LrTasks.startAsyncTask( function()

                                        local today = os.date( "%Y-%m-%d" )

                                        -- Mark all cells in this group as "checking…"
                                        for i = 1, #items do
                                                props[ vcPfx .. cid .. "_" .. i ] = "..."
                                        end
                                        LrTasks.sleep( 0.05 )   -- let UI repaint to show "..."

                                        -- Fetch Wikidata canonical name set (one HTTP call, cached).
                                        -- Returns { [name]=true } or nil when offline / not applicable.
                                        local wikidataNames = fetchWikidataNames( cid, prefKey )

                                        -- Check each item and update its row progressively.
                                        -- Yield every batchSize rows (~25 visual refreshes per group).
                                        local batchSize = math.max( 1, math.ceil( #items / 25 ) )
                                        for i = 1, #items do
                                                local name       = items[ i ]
                                                local suggestion = nil

                                                if wikidataNames then
                                                        -- Wikidata available: exact-match lookup.
                                                        if not wikidataNames[ name ] then
                                                                -- Not found as-is; try dual-name "A - B" split.
                                                                local a, b = name:match( "^(.+) %- (.+)$" )
                                                                if a and b then
                                                                        if wikidataNames[ b ] then
                                                                                suggestion = b
                                                                        elseif wikidataNames[ a ] then
                                                                                suggestion = a
                                                                        end
                                                                end
                                                                -- Non-dual-name not in Wikidata → conservative
                                                                -- (no suggestion; avoid false positives).
                                                        end
                                                else
                                                        -- Wikidata unavailable: pattern-only fallback.
                                                        suggestion = checkName( name )
                                                end

                                                props[ vcPfx .. cid .. "_" .. i ] = suggestion or "-"

                                                -- Preserve Action = "change" (user's acknowledged decision).
                                                -- Only set "dash" when the entry is still at its default.
                                                if props[ vaPfx .. cid .. "_" .. i ] ~= "change" then
                                                        props[ vaPfx .. cid .. "_" .. i ] = "dash"
                                                end

                                                -- Yield every batchSize items to let the UI repaint.
                                                if i % batchSize == 0 then
                                                        LrTasks.sleep( 0.04 )
                                                end
                                        end

                                        -- Persist all results to prefs.
                                        local saved = {}
                                        for i = 1, #items do
                                                saved[ i ] = {
                                                        c = props[ vcPfx .. cid .. "_" .. i ],
                                                        a = props[ vaPfx .. cid .. "_" .. i ],
                                                }
                                        end
                                        prefs[ "ver_" .. cid .. "_" .. prefKey ] = saved
                                        -- Refresh Last-verified stamp.
                                        props[ "verified_" .. cid ] = today
                                        prefs[ "verified_" .. cid ] = today
                                        -- Rebuild panel so conflict rows float to the top.
                                        switchTab( TAB_IDS.MN )

                                end )   -- end startAsyncTask
                        end

                        -- Top row: Verify button above Name column.
                        local verRow = f:row {
                                spacing = 6,
                                f:push_button { title = "Verify", width = W_M_NAME, action = doVerify },
                                f:spacer { width = W_M_CONF },
                                f:spacer { width = W_M_ACT  },
                        }

                        -- Sub-header row (bold column labels).
                        local subHdr = f:row {
                                spacing = 6,
                                f:static_text { title = label,       width = W_M_NAME, font = "<system/bold>" },
                                f:static_text { title = "Conflicts", width = W_M_CONF, font = "<system/bold>" },
                                f:static_text { title = "Action",    width = W_M_ACT,  font = "<system/bold>" },
                        }

                        -- One data row per item in sorted display order.
                        local colSpec = {
                                spacing          = f:control_spacing(),
                                background_color = DLG_BG,
                        }
                        for _, d in ipairs( display ) do
                                local vcKey = vcPfx .. cid .. "_" .. d.i
                                local vaKey = vaPfx .. cid .. "_" .. d.i
                                colSpec[ #colSpec + 1 ] = f:row {
                                        spacing = 6,
                                        f:static_text {
                                                title = d.name,
                                                width = W_M_NAME,
                                        },
                                        f:static_text {
                                                bind_to_object = props,
                                                title          = LrView.bind( vcKey ),
                                                width          = W_M_CONF,
                                        },
                                        f:popup_menu {
                                                bind_to_object = props,
                                                value          = LrView.bind( vaKey ),
                                                items          = {
                                                        { title = "—",      value = "dash"   },
                                                        { title = "Change", value = "change" },
                                                },
                                                width = W_M_ACT,
                                        },
                                }
                        end

                        local scrolled = f:scrolled_view {
                                width            = G_W,
                                height           = 250,
                                background_color = DLG_BG,
                                f:column( colSpec ),
                        }

                        -- Row count summary below the scroll area.
                        local countLabel = f:static_text {
                                title = #items .. " " .. label:lower() .. " entries",
                                font  = "<system/small>",
                        }

                        return f:column {
                                spacing = f:control_spacing(),
                                verRow,
                                subHdr,
                                f:separator { fill_horizontal = 1 },
                                scrolled,
                                countLabel,
                        }
                end  -- makeGroup

                local groupCo = makeGroup( labels.county, geo.counties, "vcco_", "vaco_", "co" )
                local groupMu = makeGroup( labels.muni,   geo.munis,    "vcmu_", "vamu_", "mu" )
                local groupCi = makeGroup( labels.city,   geo.cities,   "vcci_", "vaci_", "ci" )

                return f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),
                        f:spacer { height = 5 },
                        f:static_text {
                                title = "Verification Monitor — " .. cname,
                                font  = "<system/bold>",
                        },
                        f:spacer { height = 5 },
                        f:static_text {
                                title = "Click a 'Verify' button to check entries against " ..
                                        "Wikidata (county and municipality levels; falls back " ..
                                        "to pattern analysis when offline). Conflicts shows " ..
                                        "'-' for confirmed names or a suggested canonical " ..
                                        "spelling. Set Action to 'Change' to flag an entry " ..
                                        "for renaming in a future data update.",
                                width           = CONTENT_W_MN,
                                height_in_lines = 3,
                        },
                        f:static_text {
                                title = "Clicking Save will store the current verification results as version " ..
                                        nextVer .. " of the " .. cname .. " list.",
                                width           = CONTENT_W_MN,
                                height_in_lines = 2,
                        },
                        f:separator { fill_horizontal = 1 },
                        f:spacer { height = 5 },
                        f:row {
                                spacing = 6,
                                groupCo,
                                f:separator { fill_vertical = 1 },
                                groupMu,
                                f:separator { fill_vertical = 1 },
                                groupCi,
                        },
                }
        end  -- buildMonitorPanel

        ------------------------------------------------------------------------
        -- Tab 3 — Help
        ------------------------------------------------------------------------

        local function buildHelpPanel()
                return f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),
                        f:spacer { height = 5 },
                        f:static_text { title = "Help", font = "<system/bold>" },
                        f:spacer { height = 5 },
                        f:static_text {
                                title           = "How to use the Geography Keyword Builder — Data Management window.",
                                width           = CONTENT_W,
                                height_in_lines = 2,
                        },
                        f:separator { fill_horizontal = 1 },
                        f:spacer { height = 5 },
                        f:static_text { title = "Help content is not yet implemented." },
                }
        end

        ------------------------------------------------------------------------
        -- Dialog loop
        ------------------------------------------------------------------------

        local keepOpen = true
        while keepOpen do

                switching = true
                props.activeTabId = currentDialog
                switching = false

                local placeholder = f:column { f:spacer { height = 5 } }

                local panelOV  = ( currentDialog == TAB_IDS.OV  ) and buildOverviewPanel() or placeholder
                local panelMN  = ( currentDialog == TAB_IDS.MN  ) and buildMonitorPanel()  or placeholder
                local panelHLP = ( currentDialog == TAB_IDS.HLP ) and buildHelpPanel()     or placeholder

                -- Show Save button only when the Monitor is active and a country is selected.
                local showSave = ( currentDialog == TAB_IDS.MN )
                                 and ( props.verify_country_id ~= nil )

                contents = f:tab_view {
                        bind_to_object = props,
                        value          = LrView.bind( "activeTabId" ),
                        f:tab_view_item {
                                title      = "Keyword List Builder",
                                identifier = TAB_IDS.KB,
                                f:column { width = CONTENT_W, spacing = f:control_spacing(), placeholder },
                        },
                        f:tab_view_item {
                                title      = "List Overview",
                                identifier = TAB_IDS.OV,
                                f:column { width = CONTENT_W, spacing = f:control_spacing(), panelOV },
                        },
                        f:tab_view_item {
                                title      = "Verification Monitor",
                                identifier = TAB_IDS.MN,
                                -- Monitor tab is wider (3 full-width groups side by side).
                                f:column { width = CONTENT_W_MN, spacing = f:control_spacing(), panelMN },
                        },
                        f:tab_view_item {
                                title      = "Help",
                                identifier = TAB_IDS.HLP,
                                f:column { width = CONTENT_W, spacing = f:control_spacing(), panelHLP },
                        },
                }

                -- On the Monitor (with a country selected): actionVerb = "Save" (blue,
                -- Enter-key default), cancelVerb = "Cancel" — both appear on the right side
                -- of the button bar together.
                -- On all other tabs: actionVerb = "Close", no cancel button.
                local result = LrDialogs.presentModalDialog {
                        title      = "Geography Keyword Builder — Data Management",
                        contents   = contents,
                        actionVerb = showSave and "Save" or "Close",
                        cancelVerb = showSave and "Cancel" or "< exclude >",
                }

                if result == TAB_IDS.OV or result == TAB_IDS.MN or result == TAB_IDS.HLP then
                        -- Tab switch triggered by observer or switchTab() call.
                        currentDialog = result

                elseif showSave and result == "ok" then
                        -- Save clicked on Monitor tab (actionVerb = "Save" → result "ok").
                        local cid = props.verify_country_id
                        if cid then
                                local newVer = computeNextVersion( cid, prefs )
                                prefs[ "list_version_" .. cid ] = newVer
                                props[ "list_version_" .. cid ] = newVer
                                LrDialogs.message(
                                        "Saved — " .. getCountryName( cid ),
                                        "Verification results saved.\n\n" ..
                                        "The " .. getCountryName( cid ) .. " list is now listed as version " ..
                                        newVer .. " in List Overview.",
                                        "info"
                                )
                        end
                        currentDialog = TAB_IDS.OV   -- return to List Overview after Save

                else
                        -- "Close" (non-Monitor, actionVerb "ok") or "Cancel" (Monitor,
                        -- cancelVerb "cancel"), or any other dismiss → exit loop.
                        currentDialog = result
                        keepOpen = false
                end

        end

        if currentDialog == TAB_IDS.KB then
                dofile( LrPathUtils.child( pluginPath, "KeywordBuilder.lua" ) )
        end

end )
