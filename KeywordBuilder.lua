--[[
        KeywordBuilder.lua — Geography Keyword Builder (v0.8.6)

        Shared-UI / per-country state store.

        Layout (two panels side by side):
          [Country]  |  [Counties & Areas + Selections for X]

        Country panel:
          Collapsible continents (▼/▲). Each continent has a None–All quick-include
          slider. Each country: ▶ indicator | name | Select More | [Include checkbox].

        Right panel (merged Counties & Areas + Selections):
          Top: admin-division section (label, Detail slider, Select All, county list).
          County list uses per-country scrolled_views wrapped in visibility-toggled
          outer columns — reliable bidirectional show/hide, no shared-scroll binding.
          Bottom: feature checkboxes (Mountain, Fjord, Lake, …).
          "Save settings for [Country]" button below the panel.
          Dirty flag warns when switching with unsaved changes.

        Generate:
          Include=true  → custom saved settings.
          Include=false → continent quick-include level (0=skip).
          Custom wins when both apply.
]]

local LrView            = import 'LrView'
local LrBinding         = import 'LrBinding'
local LrDialogs         = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks           = import 'LrTasks'
local LrPathUtils       = import 'LrPathUtils'
local LrColor           = import 'LrColor'
local LrPrefs           = import 'LrPrefs'

-- ── Load data files and Generator ─────────────────────────────────────────────
local pluginPath = _PLUGIN.path
local dataDir    = LrPathUtils.child( pluginPath, "data" )
local genPath    = LrPathUtils.child( pluginPath, "Generator.lua" )

local Generator  = dofile( genPath )
local norwayData = dofile( LrPathUtils.child( dataDir, "Norway.lua" ) )
local swedenData = dofile( LrPathUtils.child( dataDir, "Sweden.lua" ) )
local panamaData = dofile( LrPathUtils.child( dataDir, "Panama.lua" ) )
local usData     = dofile( LrPathUtils.child( dataDir, "UnitedStates.lua" ) )
local chileData  = dofile( LrPathUtils.child( dataDir, "Chile.lua" ) )
local kenyaData  = dofile( LrPathUtils.child( dataDir, "Kenya.lua" ) )
local nzData     = dofile( LrPathUtils.child( dataDir, "NewZealand.lua" ) )

-- County/province name lists (loaded once at module level)
local norwayCountyNames = {}
for _, c in ipairs( norwayData.counties or {} ) do
        norwayCountyNames[ #norwayCountyNames + 1 ] = c.name
end

local swedenCountyNames = {}
for _, c in ipairs( swedenData.counties or {} ) do
        swedenCountyNames[ #swedenCountyNames + 1 ] = c.name
end

local panamaProvinceNames = {}
for _, c in ipairs( panamaData.counties or {} ) do
        panamaProvinceNames[ #panamaProvinceNames + 1 ] = c.name
end

local usStateNames = {}
for _, c in ipairs( usData.counties or {} ) do
        usStateNames[ #usStateNames + 1 ] = c.name
end

local chileRegionNames = {}
for _, c in ipairs( chileData.counties or {} ) do
        chileRegionNames[ #chileRegionNames + 1 ] = c.name
end

local kenyaCountyNames = {}
for _, c in ipairs( kenyaData.counties or {} ) do
        kenyaCountyNames[ #kenyaCountyNames + 1 ] = c.name
end

local nzRegionNames = {}
for _, c in ipairs( nzData.counties or {} ) do
        nzRegionNames[ #nzRegionNames + 1 ] = c.name
end

-- Country registry — the ONLY place to add new countries
-- mountain_max: highest peak in country data (metres); caps the Min-elevation slider.
local COUNTRIES = {
        { id           = "Norway",
          name         = "Norway",
          continent    = "Europe",
          admin_label  = "Counties & Areas",
          mountain_max = 2271,
          data         = norwayData,
          countyNames  = norwayCountyNames },
        { id           = "Sweden",
          name         = "Sweden",
          continent    = "Europe",
          admin_label  = "Counties & Areas",
          mountain_max = 2097,
          data         = swedenData,
          countyNames  = swedenCountyNames },
        { id           = "Panama",
          name         = "Panama",
          continent    = "Americas",
          admin_label  = "Provinces & Areas",
          mountain_max = 3474,
          data         = panamaData,
          countyNames  = panamaProvinceNames },
        { id           = "UnitedStates",
          name         = "United States",
          continent    = "Americas",
          admin_label  = "States & Areas",
          mountain_max = 6194,
          data         = usData,
          countyNames  = usStateNames },
        { id           = "Chile",
          name         = "Chile",
          continent    = "Americas",
          admin_label  = "Regions & Areas",
          mountain_max = 6893,
          data         = chileData,
          countyNames  = chileRegionNames },
        { id           = "Kenya",
          name         = "Kenya",
          continent    = "Africa",
          admin_label  = "Counties & Areas",
          mountain_max = 5199,
          data         = kenyaData,
          countyNames  = kenyaCountyNames },
        { id           = "NewZealand",
          name         = "New Zealand",
          continent    = "Oceania",
          admin_label  = "Regions & Areas",
          mountain_max = 3724,
          data         = nzData,
          countyNames  = nzRegionNames },
}

-- Maximum county count across all countries (drives how many div_value_i props we need)
local maxCounties = 0
for _, c in ipairs( COUNTRIES ) do
        if #c.countyNames > maxCounties then maxCounties = #c.countyNames end
end

-- ─────────────────────────────────────────────────────────────────────────────
local function showDialog()
        LrFunctionContext.callWithContext( "geographyKeywordBuilder", function( context )

                local f     = LrView.osFactory()
                local props = LrBinding.makePropertyTable( context )

                -- Per-country saved settings (keyed by country.id)
                local countryState = {}

                -- Guard: prevents markDirty from firing during state transitions
                local loading = false

                -- ── Initialise props ───────────────────────────────────────────────

                -- Active-country state
                props.active_country_id       = ""
                props.active_country_name     = ""
                props.active_is_norway        = false
                props.dirty                   = false

                -- Dynamic labels
                props.active_selections_label = "Selections"
                props.active_divisions_label  = "Counties & Areas"
                props.active_save_label       = "Save settings"
                props.active_version_label    = ""
                props.active_mountain_max     = COUNTRIES[1].mountain_max

                -- Feature props (shared; swapped per country)
                props.feat_select_all          = false
                props.feat_national_parks      = false
                props.feat_national_parks_max  = 100
                props.feat_nature_reserves     = false
                props.feat_nature_reserves_max = 100
                props.feat_mountains           = false
                props.feat_mainland_cutoff     = 1800
                props.feat_fjords              = false
                props.feat_fjords_max          = 100
                props.feat_lakes               = false
                props.feat_lakes_max           = 100
                props.feat_rivers              = false
                props.feat_rivers_max          = 100
                props.feat_islands             = false
                props.feat_islands_max         = 100
                props.feat_viewpoints          = false
                props.feat_viewpoints_max      = 100
                props.feat_admin_detail        = 3

                -- Norway-only
                props.feat_svalbard  = false
                props.feat_jan_mayen = false

                -- New Zealand-only
                props.feat_remote_islands = false

                -- Shared division (county) value slots (one per county, indexed by position)
                props.div_select_all = false
                for i = 1, maxCounties do
                        props[ "div_value_" .. i ] = false
                end

                -- Continent props
                props.europe_expanded = false
                props.europe_detail   = 0   -- 0=None  1=Less  2=More  3=All

                -- Per-country flags
                for _, country in ipairs( COUNTRIES ) do
                        props[ country.id .. "_include" ]      = false
                        props[ country.id .. "_has_settings" ] = false
                end

                -- Single dynamic county list: name slots (titles update when country switches)
                for i = 1, maxCounties do
                        props[ "county_name_" .. i ] = ""
                end
                props.show_svalbard_section       = false
                props.show_remote_islands_section = false
                props.active_select_all_label     = "Select All"

                -- ── Helpers ────────────────────────────────────────────────────────

                -- Inline slider: just the slider + numeric value label.
                -- Used in feature rows where the slider sits on the same line as the checkbox.
                local function inlineSlider( key, minV, maxV, unit )
                        return f:row {
                                spacing = f:label_spacing(),
                                f:slider {
                                        bind_to_object = props,
                                        value          = LrView.bind( key ),
                                        min            = minV,
                                        max            = maxV,
                                        integral       = true,
                                        width          = 90,
                                },
                                f:static_text {
                                        bind_to_object = props,
                                        font           = { name = "<system>", size = 11 },
                                        title = LrView.bind {
                                                key       = key,
                                                transform = function( v )
                                                        return tostring( math.floor( v or 0 ) ) .. ( unit or "" )
                                                end,
                                        },
                                        width     = 40,
                                        alignment = "right",
                                },
                        }
                end

                local function detailLabel( v )
                        local n = math.min( 3, math.max( 1, math.floor( (v or 3) + 0.5 ) ) )
                        return ( { "Less", "More", "All" } )[ n ] or "All"
                end

                local function contDetailLabel( v )
                        local n = math.min( 3, math.max( 0, math.floor( (v or 0) + 0.5 ) ) )
                        return ( { "None", "Less", "More", "All" } )[ n + 1 ] or "None"
                end

                -- ── State management ───────────────────────────────────────────────

                local function defaultState( country )
                        return {
                                feat_national_parks      = false,
                                feat_national_parks_max  = 100,
                                feat_nature_reserves     = false,
                                feat_nature_reserves_max = 100,
                                feat_mountains           = false,
                                feat_mainland_cutoff     = (country.id == "Norway" and 1800 or country.id == "UnitedStates" and 4000 or 1000),
                                feat_fjords              = false,
                                feat_fjords_max          = 100,
                                feat_lakes               = false,
                                feat_lakes_max           = 100,
                                feat_rivers              = false,
                                feat_rivers_max          = 100,
                                feat_islands             = false,
                                feat_islands_max         = 100,
                                feat_viewpoints          = false,
                                feat_viewpoints_max      = 100,
                                feat_admin_detail        = 1,
                                feat_svalbard            = false,
                                feat_jan_mayen           = false,
                                feat_remote_islands      = false,
                                counties                 = {},
                        }
                end

                local function saveCurrentState()
                        local cid = props.active_country_id
                        if cid == "" then return end

                        local activeCountry = nil
                        for _, c in ipairs( COUNTRIES ) do
                                if c.id == cid then activeCountry = c break end
                        end
                        if not activeCountry then return end

                        local counties = {}
                        for i, name in ipairs( activeCountry.countyNames ) do
                                counties[ name ] = props[ "div_value_" .. i ] and true or false
                        end

                        countryState[ cid ] = {
                                feat_national_parks      = props.feat_national_parks,
                                feat_national_parks_max  = props.feat_national_parks_max,
                                feat_nature_reserves     = props.feat_nature_reserves,
                                feat_nature_reserves_max = props.feat_nature_reserves_max,
                                feat_mountains           = props.feat_mountains,
                                feat_mainland_cutoff     = props.feat_mainland_cutoff,
                                feat_fjords              = props.feat_fjords,
                                feat_fjords_max          = props.feat_fjords_max,
                                feat_lakes               = props.feat_lakes,
                                feat_lakes_max           = props.feat_lakes_max,
                                feat_rivers              = props.feat_rivers,
                                feat_rivers_max          = props.feat_rivers_max,
                                feat_islands             = props.feat_islands,
                                feat_islands_max         = props.feat_islands_max,
                                feat_viewpoints          = props.feat_viewpoints,
                                feat_viewpoints_max      = props.feat_viewpoints_max,
                                feat_admin_detail        = props.feat_admin_detail,
                                feat_svalbard            = props.feat_svalbard,
                                feat_jan_mayen           = props.feat_jan_mayen,
                                feat_remote_islands      = props.feat_remote_islands,
                                counties                 = counties,
                        }

                        props[ cid .. "_has_settings" ] = true
                        props[ cid .. "_include" ]      = true   -- saving implies intent to include
                        props.dirty = false
                end

                local function loadCountryState( cid, country )
                        loading = true

                        local state = countryState[ cid ] or defaultState( country )
                        local names = country.countyNames

                        -- Feature props
                        props.feat_national_parks      = state.feat_national_parks      or false
                        props.feat_national_parks_max  = state.feat_national_parks_max  or 100
                        props.feat_nature_reserves     = state.feat_nature_reserves      or false
                        props.feat_nature_reserves_max = state.feat_nature_reserves_max or 100
                        props.feat_mountains           = state.feat_mountains            or false
                        props.feat_mainland_cutoff     = math.min(
                                state.feat_mainland_cutoff or country.mountain_max,
                                country.mountain_max )
                        props.feat_fjords              = state.feat_fjords               or false
                        props.feat_fjords_max          = state.feat_fjords_max           or 100
                        props.feat_lakes               = state.feat_lakes                or false
                        props.feat_lakes_max           = state.feat_lakes_max            or 100
                        props.feat_rivers              = state.feat_rivers               or false
                        props.feat_rivers_max          = state.feat_rivers_max           or 100
                        props.feat_islands             = state.feat_islands              or false
                        props.feat_islands_max         = state.feat_islands_max          or 100
                        props.feat_viewpoints          = state.feat_viewpoints           or false
                        props.feat_viewpoints_max      = state.feat_viewpoints_max       or 100
                        props.feat_admin_detail        = state.feat_admin_detail         or 1
                        props.feat_svalbard            = state.feat_svalbard             or false
                        props.feat_jan_mayen           = state.feat_jan_mayen            or false
                        props.feat_remote_islands      = state.feat_remote_islands       or false
                        props.feat_select_all          = false

                        -- Division (county) slots — fill from saved state
                        local savedCounties = state.counties or {}
                        for i = 1, #names do
                                props[ "div_value_" .. i ] = savedCounties[ names[ i ] ] and true or false
                        end
                        -- Clear slots beyond the active country's count
                        for i = #names + 1, maxCounties do
                                props[ "div_value_" .. i ] = false
                        end
                        props.div_select_all = false

                        -- Populate the single dynamic county list with this country's names
                        for i = 1, maxCounties do
                                props[ "county_name_" .. i ] = names[ i ] or ""
                        end
                        props.show_svalbard_section    = ( cid == "Norway" )
                        props.show_remote_islands_section = ( cid == "NewZealand" )

                        -- Active-country state
                        local adminLabel = country.admin_label or "Counties & Areas"
                        -- Prefer the version saved by the Verification Monitor (may be
                        -- bumped beyond the data file's meta.version by a Save action).
                        local dataVer    = (country.data.meta and country.data.meta.version) or "?"
                        local ver        = LrPrefs.prefsForPlugin()[ "list_version_" .. cid ] or dataVer
                        props.active_country_id       = cid
                        props.active_country_name     = country.name
                        props.active_is_norway        = (cid == "Norway")
                        props.active_mountain_max     = country.mountain_max
                        props.active_selections_label = "Selections for " .. country.name
                        props.active_divisions_label  = adminLabel .. " for " .. country.name
                        props.active_save_label       = "Save settings for " .. country.name
                        props.active_select_all_label = "Select All"
                        props.active_version_label    = country.name .. " v" .. ver
                        props.dirty = false

                        loading = false
                end

                local function makeSwitchAction( cid, country )
                        return function()
                                if props.active_country_id == cid then return end
                                if props.dirty then
                                        local r = LrDialogs.confirm(
                                                "Unsaved settings for " .. props.active_country_name,
                                                "Save settings before switching to " .. country.name .. "?",
                                                "Save", "Switch without saving"
                                        )
                                        if r == "ok" then saveCurrentState() end
                                end
                                loadCountryState( cid, country )
                        end
                end

                -- ── Generate helpers ───────────────────────────────────────────────

                local function buildCustomPrefs( country )
                        local state = countryState[ country.id ] or defaultState( country )
                        return {
                                national_parks      = state.feat_national_parks      and true or false,
                                national_parks_max  = math.floor( state.feat_national_parks_max  or 100 ),
                                nature_reserves     = state.feat_nature_reserves      and true or false,
                                nature_reserves_max = math.floor( state.feat_nature_reserves_max or 100 ),
                                mountains           = state.feat_mountains            and true or false,
                                mainland_cutoff     = math.floor( state.feat_mainland_cutoff     or 1800 ),
                                svalbard_cutoff     = 800,
                                fjords              = state.feat_fjords               and true or false,
                                fjords_max          = math.floor( state.feat_fjords_max          or 100 ),
                                lakes               = state.feat_lakes               and true or false,
                                lakes_max           = math.floor( state.feat_lakes_max           or 100 ),
                                rivers              = state.feat_rivers              and true or false,
                                rivers_max          = math.floor( state.feat_rivers_max          or 100 ),
                                islands             = state.feat_islands             and true or false,
                                islands_max         = math.floor( state.feat_islands_max         or 100 ),
                                viewpoints          = state.feat_viewpoints          and true or false,
                                viewpoints_max      = math.floor( state.feat_viewpoints_max      or 100 ),
                                administrative      = true,
                                admin_detail        = math.min( 3, math.max( 1,
                                        math.floor( (state.feat_admin_detail or 3) + 0.5 ) ) ),
                                svalbard            = state.feat_svalbard            and true or false,
                                jan_mayen           = state.feat_jan_mayen           and true or false,
                                remote_islands      = state.feat_remote_islands      and true or false,
                                counties            = state.counties or {},
                        }
                end

                local function buildQuickPrefs( detail, country )
                        local isNorway = (country.id == "Norway")
                        local less = (detail >= 1)
                        local more = (detail >= 2)
                        local all  = (detail >= 3)

                        local counties = {}
                        if more then
                                for _, name in ipairs( country.countyNames ) do
                                        counties[ name ] = true
                                end
                        end

                        return {
                                national_parks      = less,
                                national_parks_max  = 100,
                                nature_reserves     = more,
                                nature_reserves_max = 50,
                                mountains           = less,
                                mainland_cutoff     = (isNorway and 2000 or 1500),
                                svalbard_cutoff     = 1000,
                                fjords              = more,
                                fjords_max          = 50,
                                lakes               = more,
                                lakes_max           = 50,
                                rivers              = all,
                                rivers_max          = 50,
                                islands             = all,
                                islands_max         = 50,
                                viewpoints          = all,
                                viewpoints_max      = 50,
                                administrative      = more,
                                admin_detail        = (all and 3 or 2),
                                country_synonym     = false,
                                svalbard            = (isNorway and more),
                                jan_mayen           = (isNorway and all),
                                remote_islands      = ((country.id == "NewZealand") and more),
                                counties            = counties,
                        }
                end

                -- ── Observers ─────────────────────────────────────────────────────

                local function markDirty()
                        if (not loading) and props.active_country_id ~= "" then
                                props.dirty = true
                        end
                end

                local featKeys = {
                        "feat_national_parks", "feat_national_parks_max",
                        "feat_nature_reserves", "feat_nature_reserves_max",
                        "feat_mountains", "feat_mainland_cutoff",
                        "feat_fjords", "feat_fjords_max",
                        "feat_lakes", "feat_lakes_max",
                        "feat_rivers", "feat_rivers_max",
                        "feat_islands", "feat_islands_max",
                        "feat_viewpoints", "feat_viewpoints_max",
                        "feat_admin_detail",
                        "feat_svalbard", "feat_jan_mayen", "feat_remote_islands",
                }
                for _, key in ipairs( featKeys ) do
                        props:addObserver( key, markDirty )
                end
                for i = 1, maxCounties do
                        props:addObserver( "div_value_" .. i, markDirty )
                end

                -- Select All divisions
                local suppressDivAll = false
                props:addObserver( "div_select_all", function()
                        if suppressDivAll or loading then return end
                        suppressDivAll = true
                        local v   = props.div_select_all
                        local cid = props.active_country_id
                        for _, c in ipairs( COUNTRIES ) do
                                if c.id == cid then
                                        for i = 1, #c.countyNames do
                                                props[ "div_value_" .. i ] = v
                                        end
                                        break
                                end
                        end
                        -- Norway: also include Svalbard / Jan Mayen
                        if cid == "Norway" then
                                props.feat_svalbard  = v
                                props.feat_jan_mayen = v
                        end
                        -- New Zealand: also include Remote Islands
                        if cid == "NewZealand" then
                                props.feat_remote_islands = v
                        end
                        suppressDivAll = false
                end )

                -- Select All features
                props:addObserver( "feat_select_all", function()
                        if loading then return end
                        local v = props.feat_select_all
                        props.feat_national_parks  = v
                        props.feat_nature_reserves = v
                        props.feat_mountains       = v
                        props.feat_fjords          = v
                        props.feat_lakes           = v
                        props.feat_rivers          = v
                        props.feat_islands         = v
                        props.feat_viewpoints      = v
                end )

                -- ── Auto-load first country ────────────────────────────────────────
                loadCountryState( COUNTRIES[1].id, COUNTRIES[1] )

                -- ── Colour constants ───────────────────────────────────────────────
                local panelGrey = LrColor( 0.878, 0.878, 0.878 )
                local dimColor  = LrColor( 0.4, 0.4, 0.4 )

                -- ── Panel 1: Country ───────────────────────────────────────────────

                -- Group countries by continent, preserving COUNTRIES order
                local continents  = {}
                local byContinent = {}
                for _, country in ipairs( COUNTRIES ) do
                        local cont = country.continent or "Other"
                        if not byContinent[ cont ] then
                                byContinent[ cont ] = {}
                                continents[ #continents + 1 ] = cont
                        end
                        local cl = byContinent[ cont ]
                        cl[ #cl + 1 ] = country
                end

                local countryChildren = {
                        spacing         = 2,
                        fill_horizontal = 1,
                        f:static_text { title = "Country", font = "<system/bold>" },
                        f:spacer { height = 1 },
                }

                for _, cont in ipairs( continents ) do
                        local contLower = cont:lower():gsub( "%s+", "_" )
                        local contKey   = contLower .. "_expanded"
                        local detailKey = contLower .. "_detail"

                        -- Continent toggle button — natural width so text is left-aligned
                        countryChildren[ #countryChildren + 1 ] = f:push_button {
                                bind_to_object = props,
                                title = LrView.bind {
                                        key       = contKey,
                                        transform = function( v )
                                                return (v and "\226\150\178" or "\226\150\188") .. "   " .. cont
                                        end,
                                },
                                action = function()
                                        props[ contKey ] = not props[ contKey ]
                                end,
                        }

                        -- Continent Include slider (shown when expanded)
                        countryChildren[ #countryChildren + 1 ] = f:column {
                                bind_to_object = props,
                                visible        = LrView.bind( contKey ),
                                fill_horizontal = 1,
                                f:row {
                                        spacing = f:label_spacing(),
                                        f:static_text { title = "Include:", width = 55 },
                                        f:slider {
                                                bind_to_object = props,
                                                value          = LrView.bind( detailKey ),
                                                min            = 0,
                                                max            = 3,
                                                integral       = true,
                                                width          = 90,
                                        },
                                        f:static_text {
                                                bind_to_object = props,
                                                title = LrView.bind {
                                                        key       = detailKey,
                                                        transform = function( v )
                                                                return contDetailLabel( v )
                                                        end,
                                                },
                                                width = 36,
                                        },
                                },
                        }

                        -- Country rows (shown when continent expanded)
                        for _, country in ipairs( byContinent[ cont ] ) do
                                local cid          = country.id
                                local includeKey   = cid .. "_include"
                                local switchAction = makeSwitchAction( cid, country )

                                countryChildren[ #countryChildren + 1 ] = f:column {
                                        bind_to_object  = props,
                                        visible         = LrView.bind( contKey ),
                                        fill_horizontal = 1,
                                        f:row {
                                                spacing         = f:label_spacing(),
                                                fill_horizontal = 1,

                                                -- ▶ active indicator (U+25B6)
                                                f:static_text {
                                                        bind_to_object = props,
                                                        title = LrView.bind {
                                                                key       = "active_country_id",
                                                                transform = function( v )
                                                                        return v == cid and "\226\150\182" or "  "
                                                                end,
                                                        },
                                                        width = 16,
                                                },

                                                -- Country name (plain — no ✓ indicator; Include checkbox is the single status+action control)
                                                f:static_text {
                                                        title           = country.name,
                                                        fill_horizontal = 1,
                                                },

                                                -- Select More
                                                f:push_button {
                                                        title  = "Select More",
                                                        action = switchAction,
                                                },

                                                -- Include in export (labelled; auto-checked on Save)
                                                f:checkbox {
                                                        bind_to_object = props,
                                                        title          = "Include",
                                                        value          = LrView.bind( includeKey ),
                                                },
                                        },
                                }
                        end

                        countryChildren[ #countryChildren + 1 ] = f:spacer { height = 2 }
                end

                local countryColumn = f:column( countryChildren )

                -- ── County section (middle column) ───────────────────────────────
                -- Single dynamic county list.
                -- All checkbox slots are built once with titles/values bound to
                -- county_name_X / div_value_X props.  loadCountryState writes the
                -- active country's names into those props on every country switch,
                -- so the titles update live without any show/hide gymnastics.
                -- Slots beyond the active country's count get an empty string title
                -- and a false value; they remain in the scroll area but are blank.
                -- Norway's Svalbard / Jan Mayen are fixed extra items below a separator,
                -- shown only when show_svalbard_section is true.
                local singleListSpec = {
                        bind_to_object  = props,
                        spacing         = 4,
                        fill_horizontal = 1,
                }
                for i = 1, maxCounties do
                        singleListSpec[ #singleListSpec + 1 ] = f:checkbox {
                                bind_to_object = props,
                                font           = "<system/small>",
                                title          = LrView.bind( "county_name_" .. i ),
                                value          = LrView.bind( "div_value_"   .. i ),
                        }
                end
                -- Norway-only extras (hidden when show_svalbard_section is false)
                singleListSpec[ #singleListSpec + 1 ] = f:separator {
                        fill_horizontal = 1,
                        visible         = LrView.bind( "show_svalbard_section" ),
                }
                singleListSpec[ #singleListSpec + 1 ] = f:checkbox {
                        bind_to_object = props,
                        font           = "<system/small>",
                        title          = "Svalbard",
                        value          = LrView.bind( "feat_svalbard" ),
                        visible        = LrView.bind( "show_svalbard_section" ),
                }
                singleListSpec[ #singleListSpec + 1 ] = f:checkbox {
                        bind_to_object = props,
                        font           = "<system/small>",
                        title          = "Jan Mayen",
                        value          = LrView.bind( "feat_jan_mayen" ),
                        visible        = LrView.bind( "show_svalbard_section" ),
                }
                -- New Zealand-only extras (hidden when show_remote_islands_section is false)
                singleListSpec[ #singleListSpec + 1 ] = f:separator {
                        fill_horizontal = 1,
                        visible         = LrView.bind( "show_remote_islands_section" ),
                }
                singleListSpec[ #singleListSpec + 1 ] = f:checkbox {
                        bind_to_object = props,
                        font           = "<system/small>",
                        title          = "Remote Islands",
                        value          = LrView.bind( "feat_remote_islands" ),
                        visible        = LrView.bind( "show_remote_islands_section" ),
                }

                local countyListContainer = f:scrolled_view {
                        bind_to_object      = props,
                        height              = 250,
                        width               = 210,
                        horizontal_scroller = false,
                        background_color    = panelGrey,
                        f:column( singleListSpec ),
                }

                local countySection = f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),

                        f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( "active_divisions_label" ),
                                font           = "<system/bold>",
                        },
                        f:static_text {
                                title      = "Select which information to include\nand how detailed.",
                                wrap       = true,
                                width      = 210,
                        },
                        f:separator { fill_horizontal = 1 },
                        -- Fixed-width row: label(101) + gap(2) + slider(75) + gap(2) + value(30) = 210
                        -- No fill_horizontal on the row (which would expand the whole group_box).
                        f:row {
                                spacing = 2,
                                f:static_text { title = "Level of detail:", width = 101 },
                                f:slider {
                                        bind_to_object = props,
                                        value          = LrView.bind( "feat_admin_detail" ),
                                        min            = 1,
                                        max            = 3,
                                        integral       = true,
                                        width          = 75,
                                },
                                f:static_text {
                                        bind_to_object = props,
                                        title = LrView.bind {
                                                key       = "feat_admin_detail",
                                                transform = function( v ) return detailLabel( v ) end,
                                        },
                                        width     = 30,
                                        alignment = "right",
                                },
                        },
                        f:column {
                                spacing = 4,
                                f:checkbox {
                                        bind_to_object = props,
                                        font           = "<system>",
                                        title          = LrView.bind( "active_select_all_label" ),
                                        value          = LrView.bind( "div_select_all" ),
                                        width          = 210,
                                },
                                countyListContainer,
                        },
                        f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( "active_version_label" ),
                                text_color     = dimColor,
                        },
                }

                -- ── Feature selections panel (right column) ──────────────────────

                local featuresContent = f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),

                        f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( "active_selections_label" ),
                                font           = "<system/bold>",
                        },
                        f:column {
                                spacing = 2,
                                f:static_text {
                                        title = "Use the sliders below to set max count or",
                                },
                                f:static_text {
                                        title = "min elevation (only for mountains).",
                                },
                        },
                        f:separator { fill_horizontal = 1 },
                        f:checkbox {
                                bind_to_object = props,
                                font           = "<system>",
                                title          = "Select All",
                                value          = LrView.bind( "feat_select_all" ),
                        },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="National Park",   value=LrView.bind("feat_national_parks") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_national_parks_max",  10, 500, "" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Nature Reserve",  value=LrView.bind("feat_nature_reserves") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_nature_reserves_max", 10, 500, "" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Mountain",        value=LrView.bind("feat_mountains") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_mainland_cutoff", 500, LrView.bind("active_mountain_max"), "m" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Fjord",           value=LrView.bind("feat_fjords") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_fjords_max",     10, 100, "" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Lake",            value=LrView.bind("feat_lakes") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_lakes_max",      10, 100, "" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="River",           value=LrView.bind("feat_rivers") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_rivers_max",     10, 100, "" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Island",          value=LrView.bind("feat_islands") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_islands_max",    10, 100, "" ) },

                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Viewpoint",       value=LrView.bind("feat_viewpoints") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_viewpoints_max", 10, 500, "" ) },

                }

                -- featuresContent used directly as right column (no extra wrapper needed)

                -- ── Save row ───────────────────────────────────────────────────────
                local saveRow = f:row {
                        bind_to_object  = props,
                        fill_horizontal = 1,
                        f:spacer { fill_horizontal = 1 },
                        f:static_text {
                                bind_to_object = props,
                                visible        = LrView.bind( "dirty" ),
                                title          = "Unsaved changes  ",
                                text_color     = dimColor,
                        },
                        f:push_button {
                                bind_to_object = props,
                                title          = LrView.bind( "active_save_label" ),
                                action         = saveCurrentState,
                        },
                }

                -- ── Full dialog layout ─────────────────────────────────────────────
                local contents = f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),
                        f:static_text {
                                title = "Select a country (Select More), configure sections and areas, "
                                     .. "check Include to add it to the export, then click Generate.",
                        },
                        f:row {
                                spacing = f:label_spacing() * 2,

                                -- Column 1: Country list
                                f:group_box {
                                        title   = "",
                                        spacing = f:control_spacing(),
                                        countryColumn,
                                },

                                -- Column 2: Counties & Areas
                                f:group_box {
                                        title   = "",
                                        spacing = f:control_spacing(),
                                        countySection,
                                },

                                -- Column 3: Feature selections + Save row
                                f:column {
                                        spacing = f:control_spacing(),

                                        f:group_box {
                                                title           = "",
                                                fill_horizontal = 1,
                                                featuresContent,
                                        },

                                        saveRow,
                                },
                        },
                }

                -- ── Present dialog ─────────────────────────────────────────────────
                local result = LrDialogs.presentModalDialog {
                        title      = "Geography Keyword Builder",
                        contents   = contents,
                        actionVerb = "Generate",
                }

                if result ~= "ok" then return end

                -- Capture active country settings before generating
                saveCurrentState()

                -- ── Collect countries to generate ──────────────────────────────────
                local parts      = {}
                local countryIds = {}
                local skipped    = {}   -- countries included but with no exportable content

                for _, country in ipairs( COUNTRIES ) do
                        local cid   = country.id
                        local prefs = nil

                        if props[ cid .. "_include" ] then
                                prefs = buildCustomPrefs( country )
                        else
                                local contLower = (country.continent or "Other"):lower():gsub( "%s+", "_" )
                                local detail    = math.floor( (props[ contLower .. "_detail" ] or 0) + 0.5 )
                                if detail > 0 then
                                        prefs = buildQuickPrefs( detail, country )
                                end
                        end

                        if prefs then
                                local output = Generator.generate( country.data, prefs )
                                -- Count lines: output that is only "Geography\n" has a
                                -- single line and means no counties or features were selected.
                                local lineCount = 0
                                for _ in output:gmatch( "[^\n]+" ) do
                                        lineCount = lineCount + 1
                                end
                                if lineCount > 1 then
                                        parts[      #parts      + 1 ] = output
                                        countryIds[ #countryIds + 1 ] = cid
                                else
                                        skipped[ #skipped + 1 ] = country.name
                                end
                        end
                end

                -- Warn about included-but-empty countries (do not abort the whole export)
                if #skipped > 0 then
                        LrDialogs.message(
                                "Nothing exported for " .. table.concat( skipped, ", " ),
                                "These countries had no counties or features selected and were "
                                .. "skipped: " .. table.concat( skipped, ", " ) .. ".\n\n"
                                .. "Click \"Select More\" next to a country to configure it, "
                                .. "then pick counties or enable features before generating.",
                                "warning"
                        )
                end

                if #parts == 0 then
                        LrDialogs.message(
                                "No country selected for export",
                                "Check the Include box next to a country, or move a continent's "
                                .. "Include slider above None.",
                                "warning"
                        )
                        return
                end

                local content = table.concat( parts, "\n" )

                -- ── Choose destination and write the file ──────────────────────────
                local dateStr  = os.date( "%Y%m%d" )
                local namePart
                if #countryIds == 1 then
                        namePart = countryIds[1]
                else
                        namePart = table.concat( countryIds, "+" )
                end
                local fileName = "LR-Geography-" .. namePart .. "-" .. dateStr .. ".txt"

                LrTasks.startAsyncTask( function()
                        local dirs = LrDialogs.runOpenPanel {
                                title                   = "Choose a folder to save the keyword file",
                                canChooseFiles          = false,
                                canChooseDirectories    = true,
                                canCreateDirectories    = true,
                                allowsMultipleSelection = false,
                        }

                        if not dirs or not dirs[1] then return end

                        local LrFileUtils = import 'LrFileUtils'
                        local savePath    = LrPathUtils.child( dirs[1], fileName )

                        local skipThisFile = false
                        if LrFileUtils.exists( savePath ) then
                                local ok = LrDialogs.confirm(
                                        "File already exists",
                                        fileName .. " already exists. Overwrite it?",
                                        "Overwrite", "Cancel"
                                )
                                if ok ~= "ok" then
                                        skipThisFile = true
                                end
                        end

                        if not skipThisFile then
                                local fh, err = io.open( savePath, "w" )
                                if not fh then
                                        LrDialogs.message( "Could not save file", tostring( err ), "critical" )
                                        return
                                end
                                fh:write( content )
                                fh:close()
                                LrDialogs.message(
                                        "Keywords saved",
                                        fileName .. " saved to:\n" .. dirs[1]
                                        .. "\n\nImport into Lightroom via:\n"
                                        .. "Metadata > Import Keywords... "
                                        .. "(or File > Import Keywords from Disk)",
                                        "info"
                                )
                        end
                end )
        end )
end

LrTasks.startAsyncTask( showDialog )
