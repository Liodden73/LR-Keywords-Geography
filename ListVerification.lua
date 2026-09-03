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
local chileData  = dofile( LrPathUtils.child( dataDir, "Chile.lua"        ) )
local kenyaData  = dofile( LrPathUtils.child( dataDir, "Kenya.lua"        ) )
local nzData          = dofile( LrPathUtils.child( dataDir, "NewZealand.lua"   ) )
local greenlandData   = dofile( LrPathUtils.child( dataDir, "Greenland.lua"    ) )
local finlandData     = dofile( LrPathUtils.child( dataDir, "Finland.lua"      ) )
local ukData          = dofile( LrPathUtils.child( dataDir, "UnitedKingdom.lua") )
local indiaData       = dofile( LrPathUtils.child( dataDir, "India.lua"        ) )
local argentinaData   = dofile( LrPathUtils.child( dataDir, "Argentina.lua"    ) )
local antarcticaData  = dofile( LrPathUtils.child( dataDir, "Antarctica.lua"   ) )
local australiaData   = dofile( LrPathUtils.child( dataDir, "Australia.lua"    ) )
local rwandaData      = dofile( LrPathUtils.child( dataDir, "Rwanda.lua"       ) )
local southAfricaData = dofile( LrPathUtils.child( dataDir, "SouthAfrica.lua"  ) )
local ecuadorData     = dofile( LrPathUtils.child( dataDir, "Ecuador.lua"      ) )
local botswanaData    = dofile( LrPathUtils.child( dataDir, "Botswana.lua"     ) )
local hungaryData     = dofile( LrPathUtils.child( dataDir, "Hungary.lua"      ) )
local netherlandsData = dofile( LrPathUtils.child( dataDir, "Netherlands.lua"  ) )
local chinaData       = dofile( LrPathUtils.child( dataDir, "China.lua"        ) )
local russiaData      = dofile( LrPathUtils.child( dataDir, "Russia.lua"       ) )
local franceData      = dofile( LrPathUtils.child( dataDir, "France.lua"       ) )
local denmarkData     = dofile( LrPathUtils.child( dataDir, "Denmark.lua"      ) )
local icelandData     = dofile( LrPathUtils.child( dataDir, "Iceland.lua"      ) )
local germanyData     = dofile( LrPathUtils.child( dataDir, "Germany.lua"      ) )
local spainData       = dofile( LrPathUtils.child( dataDir, "Spain.lua"        ) )
local portugalData    = dofile( LrPathUtils.child( dataDir, "Portugal.lua"     ) )
local italyData       = dofile( LrPathUtils.child( dataDir, "Italy.lua"        ) )
local austriaData     = dofile( LrPathUtils.child( dataDir, "Austria.lua"      ) )
local belgiumData     = dofile( LrPathUtils.child( dataDir, "Belgium.lua"      ) )
local switzerlandData = dofile( LrPathUtils.child( dataDir, "Switzerland.lua"  ) )
local irelandData     = dofile( LrPathUtils.child( dataDir, "Ireland.lua"      ) )
local polandData      = dofile( LrPathUtils.child( dataDir, "Poland.lua"       ) )
local greeceData      = dofile( LrPathUtils.child( dataDir, "Greece.lua"       ) )
local czechData       = dofile( LrPathUtils.child( dataDir, "CzechRepublic.lua") )
local romaniaData     = dofile( LrPathUtils.child( dataDir, "Romania.lua"      ) )
local ukraineData     = dofile( LrPathUtils.child( dataDir, "Ukraine.lua"      ) )
local croatiaData     = dofile( LrPathUtils.child( dataDir, "Croatia.lua"      ) )
local sloveniaData    = dofile( LrPathUtils.child( dataDir, "Slovenia.lua"     ) )
local bulgariaData    = dofile( LrPathUtils.child( dataDir, "Bulgaria.lua"     ) )
local serbiaData      = dofile( LrPathUtils.child( dataDir, "Serbia.lua"       ) )
local slovakiaData    = dofile( LrPathUtils.child( dataDir, "Slovakia.lua"     ) )

local genPath   = LrPathUtils.child( pluginPath, "Generator.lua" )
local Generator = dofile( genPath )
local WorldMap  = dofile( LrPathUtils.child( pluginPath, "WorldMap.lua" ) )

local function makeCountyNames( data )
        local names = {}
        for _, c in ipairs( data.counties or {} ) do
                names[ #names + 1 ] = c.name
        end
        table.sort( names )
        return names
end

--- Compute slider maxes from actual data lengths.
--- NP/NR: full count (no cap).
--- FJ/LK/RV/IS/VP: capped at 100 (top-100 policy).
local function addCountry( t )
        local d = t.data
        t.np_max      = #( d.national_parks  or {} )
        t.nr_max      = #( d.nature_reserves or {} )
        t.fj_max      = math.min( #( d.fjords     or {} ), 100 )
        t.lk_max      = math.min( #( d.lakes      or {} ), 100 )
        t.rv_max      = math.min( #( d.rivers     or {} ), 100 )
        t.is_max      = math.min( #( d.islands    or {} ), 100 )
        t.vp_max      = math.min( #( d.viewpoints or {} ), 100 )
        t.countyNames = makeCountyNames( d )
        return t
end

-- Bundled pure-Lua JSON decoder (dkjson, MIT licence).
local dkjson = dofile( LrPathUtils.child( pluginPath, "dkjson.lua" ) )

-- GitHub sync helper (reads/writes verified/<Country>.json). Sync is only
-- active on a machine where a token has been entered in Plug-in Manager.
local GitHubSync = dofile( LrPathUtils.child( pluginPath, "GitHubSync.lua" ) )

local COUNTRIES = {
        addCountry { id = "Norway",       name = "Norway",        code = "NO-578", filename = "Norway.lua",       continent = "Europe",        admin_label = "Counties & Areas",  mountain_max = 2469, data = norwayData, remoteIslandNames = { "Bouvetøya", "Dronning Mauds Land", "Jan Mayen", "Peter 1. Island", "Svalbard" } },
        addCountry { id = "Sweden",       name = "Sweden",        code = "SE-752", filename = "Sweden.lua",       continent = "Europe",        admin_label = "Counties & Areas",  mountain_max = 2097, data = swedenData, remoteIslandNames = {} },
        addCountry { id = "Panama",       name = "Panama",        code = "PA-591", filename = "Panama.lua",       continent = "North America", admin_label = "Provinces & Areas", mountain_max = 3474, data = panamaData, remoteIslandNames = {} },
        addCountry { id = "UnitedStates", name = "United States", code = "US-840", filename = "UnitedStates.lua", continent = "North America", admin_label = "States & Areas",    mountain_max = 6194, data = usData,     remoteIslandNames = { "American Samoa", "Guam", "Northern Mariana Islands", "Puerto Rico", "US Virgin Islands" } },
        addCountry { id = "Chile",        name = "Chile",         code = "CL-152", filename = "Chile.lua",        continent = "South America", admin_label = "Regions & Areas",   mountain_max = 6893, data = chileData,  remoteIslandNames = { "Archipiélago Juan Fernández", "Isla de Pascua" } },
        addCountry { id = "Kenya",        name = "Kenya",         code = "KE-404", filename = "Kenya.lua",        continent = "Africa",        admin_label = "Counties & Areas",  mountain_max = 5199, data = kenyaData,  remoteIslandNames = {} },
        addCountry { id = "NewZealand",   name = "New Zealand",   code = "NZ-554", filename = "NewZealand.lua",   continent = "Oceania",       admin_label = "Regions & Areas",   mountain_max = 3724, data = nzData,          remoteIslandNames = { "Auckland Islands", "Bounty Islands", "Campbell Island", "Chatham Islands", "Great Barrier Island", "Kermadec Islands", "Poor Knights Islands", "The Antipodes Islands", "The Snares" } },
        addCountry { id = "Greenland",    name = "Greenland",     code = "GL-304", filename = "Greenland.lua",    continent = "North America", admin_label = "Municipalities & Areas", mountain_max = 3694, data = greenlandData,  remoteIslandNames = {} },
        addCountry { id = "Finland",      name = "Finland",       code = "FI-246", filename = "Finland.lua",      continent = "Europe",        admin_label = "Regions & Areas",        mountain_max = 1328, data = finlandData,    remoteIslandNames = { "Åland Islands" } },
        addCountry { id = "UnitedKingdom",name = "United Kingdom",code = "GB-826", filename = "UnitedKingdom.lua",continent = "Europe",        admin_label = "Countries & Areas",      mountain_max = 1345, data = ukData,         remoteIslandNames = {
                "Anguilla",
                "Ascension Island",
                "Bermuda",
                "British Antarctic Territory",
                "British Indian Ocean Territory",
                "British Virgin Islands",
                "Cayman Islands",
                "Channel Islands",
                "Falkland Islands",
                "Gibraltar",
                "Isle of Man",
                "Montserrat",
                "Pitcairn Islands",
                "Saint Helena",
                "South Georgia",
                "South Sandwich Islands",
                "Tristan da Cunha",
                "Turks and Caicos Islands",
        } },
        addCountry { id = "India",        name = "India",         code = "IN-356", filename = "India.lua",        continent = "Asia",          admin_label = "States & Areas",         mountain_max = 8586, data = indiaData,      remoteIslandNames = { "Andaman and Nicobar Islands", "Lakshadweep" } },
        addCountry { id = "Argentina",   name = "Argentina",    code = "AR-032", filename = "Argentina.lua",   continent = "South America", admin_label = "Provinces & Areas",  mountain_max = 6961, data = argentinaData,   remoteIslandNames = { "Isla de los Estados", "Tierra del Fuego" } },
        addCountry { id = "Ecuador",     name = "Ecuador",      code = "EC-218", filename = "Ecuador.lua",     continent = "South America", admin_label = "Provinces & Areas",  mountain_max = 6268, data = ecuadorData,     remoteIslandNames = { "Galápagos Islands" } },
        addCountry { id = "Rwanda",      name = "Rwanda",       code = "RW-646", filename = "Rwanda.lua",      continent = "Africa",        admin_label = "Provinces & Areas",  mountain_max = 4507, data = rwandaData,      remoteIslandNames = {} },
        addCountry { id = "Botswana",    name = "Botswana",     code = "BW-072", filename = "Botswana.lua",    continent = "Africa",        admin_label = "Districts & Areas",  mountain_max = 1491, data = botswanaData,    remoteIslandNames = {} },
        addCountry { id = "SouthAfrica", name = "South Africa", code = "ZA-710", filename = "SouthAfrica.lua", continent = "Africa",        admin_label = "Provinces & Areas",  mountain_max = 3482, data = southAfricaData, remoteIslandNames = { "Marion Island", "Prince Edward Island" } },
        addCountry { id = "Australia",   name = "Australia",    code = "AU-036", filename = "Australia.lua",   continent = "Oceania",       admin_label = "States & Areas",     mountain_max = 2228, data = australiaData,   remoteIslandNames = { "Christmas Island", "Cocos Islands", "Heard Island", "Lord Howe Island", "Macquarie Island", "Norfolk Island" } },
        addCountry { id = "Hungary",     name = "Hungary",      code = "HU-348", filename = "Hungary.lua",     continent = "Europe",        admin_label = "Counties & Areas",   mountain_max = 1014, data = hungaryData,     remoteIslandNames = {} },
        addCountry { id = "Netherlands", name = "Netherlands",  code = "NL-528", filename = "Netherlands.lua", continent = "Europe",        admin_label = "Provinces & Areas",  mountain_max = 323,  data = netherlandsData, remoteIslandNames = { "Aruba", "Bonaire", "Curaçao", "Saba", "Sint Eustatius", "Sint Maarten" } },
        addCountry { id = "China",        name = "China",         code = "CN-156", filename = "China.lua",        continent = "Asia",          admin_label = "Provinces & Areas",       mountain_max = 8849, data = chinaData,       remoteIslandNames = {} },
        addCountry { id = "Russia",      name = "Russia",       code = "RU-643", filename = "Russia.lua",      continent = "Europe",        admin_label = "Federal Subjects & Areas", mountain_max = 5642, data = russiaData,      remoteIslandNames = {} },
        addCountry { id = "France",      name = "France",       code = "FR-250", filename = "France.lua",      continent = "Europe",        admin_label = "Regions & Areas",    mountain_max = 4808, data = franceData,      remoteIslandNames = { "Amsterdam Island", "Clipperton Island", "Crozet Islands", "French Guiana", "French Polynesia", "Guadeloupe", "Kerguelen Islands", "Martinique", "Mayotte", "New Caledonia", "Réunion", "Saint Barthélemy", "Saint Martin", "Saint Pierre and Miquelon", "Saint-Paul Island", "Wallis and Futuna" } },
        addCountry { id = "Denmark",     name = "Denmark",      code = "DK-208", filename = "Denmark.lua",     continent = "Europe",        admin_label = "Regions & Areas",    mountain_max = 171,  data = denmarkData,     remoteIslandNames = { "Faroe Islands" } },
        addCountry { id = "Iceland",     name = "Iceland",      code = "IS-352", filename = "Iceland.lua",     continent = "Europe",        admin_label = "Regions & Areas",    mountain_max = 2110, data = icelandData,     remoteIslandNames = {} },
        addCountry { id = "Germany",     name = "Germany",      code = "DE-276", filename = "Germany.lua",     continent = "Europe",        admin_label = "States & Areas",     mountain_max = 2962, data = germanyData,     remoteIslandNames = {} },
        addCountry { id = "Spain",       name = "Spain",        code = "ES-724", filename = "Spain.lua",       continent = "Europe",        admin_label = "Communities & Areas", mountain_max = 3715, data = spainData,       remoteIslandNames = {} },
        addCountry { id = "Portugal",    name = "Portugal",     code = "PT-620", filename = "Portugal.lua",    continent = "Europe",        admin_label = "Districts & Areas",     mountain_max = 2351, data = portugalData,    remoteIslandNames = { "Azores", "Madeira" } },
        addCountry { id = "Italy",       name = "Italy",        code = "IT-380", filename = "Italy.lua",       continent = "Europe",        admin_label = "Regions & Areas",       mountain_max = 4810, data = italyData,       remoteIslandNames = {} },
        addCountry { id = "Austria",     name = "Austria",      code = "AT-040", filename = "Austria.lua",     continent = "Europe",        admin_label = "States & Areas",        mountain_max = 3798, data = austriaData,     remoteIslandNames = {} },
        addCountry { id = "Belgium",     name = "Belgium",      code = "BE-056", filename = "Belgium.lua",     continent = "Europe",        admin_label = "Regions & Areas",       mountain_max = 694,  data = belgiumData,     remoteIslandNames = {} },
        addCountry { id = "Bulgaria",    name = "Bulgaria",     code = "BG-100", filename = "Bulgaria.lua",    continent = "Europe",        admin_label = "Provinces & Areas",     mountain_max = 2925, data = bulgariaData,    remoteIslandNames = {} },
        addCountry { id = "Switzerland", name = "Switzerland",  code = "CH-756", filename = "Switzerland.lua", continent = "Europe",        admin_label = "Cantons & Areas",       mountain_max = 4634, data = switzerlandData, remoteIslandNames = {} },
        addCountry { id = "Croatia",     name = "Croatia",      code = "HR-191", filename = "Croatia.lua",     continent = "Europe",        admin_label = "Counties & Areas",      mountain_max = 1830, data = croatiaData,     remoteIslandNames = {} },
        addCountry { id = "Ireland",     name = "Ireland",      code = "IE-372", filename = "Ireland.lua",     continent = "Europe",        admin_label = "Counties & Areas",      mountain_max = 1038, data = irelandData,     remoteIslandNames = {} },
        addCountry { id = "Poland",      name = "Poland",       code = "PL-616", filename = "Poland.lua",      continent = "Europe",        admin_label = "Voivodeships & Areas",  mountain_max = 2499, data = polandData,      remoteIslandNames = {} },
        addCountry { id = "Greece",      name = "Greece",       code = "GR-300", filename = "Greece.lua",      continent = "Europe",        admin_label = "Regions & Areas",       mountain_max = 2918, data = greeceData,      remoteIslandNames = {} },
        addCountry { id = "CzechRepublic", name = "Czech Republic", code = "CZ-203", filename = "CzechRepublic.lua", continent = "Europe",  admin_label = "Regions & Areas",       mountain_max = 1603, data = czechData,       remoteIslandNames = {} },
        addCountry { id = "Romania",     name = "Romania",      code = "RO-642", filename = "Romania.lua",     continent = "Europe",        admin_label = "Counties & Areas",      mountain_max = 2544, data = romaniaData,     remoteIslandNames = {} },
        addCountry { id = "Serbia",      name = "Serbia",       code = "RS-688", filename = "Serbia.lua",      continent = "Europe",        admin_label = "Regions & Areas",       mountain_max = 2174, data = serbiaData,      remoteIslandNames = {} },
        addCountry { id = "Slovakia",    name = "Slovakia",     code = "SK-703", filename = "Slovakia.lua",    continent = "Europe",        admin_label = "Regions & Areas",       mountain_max = 2655, data = slovakiaData,    remoteIslandNames = {} },
        addCountry { id = "Slovenia",    name = "Slovenia",     code = "SI-705", filename = "Slovenia.lua",    continent = "Europe",        admin_label = "Municipalities & Areas", mountain_max = 2740, data = sloveniaData,    remoteIslandNames = {} },
        addCountry { id = "Ukraine",     name = "Ukraine",      code = "UA-804", filename = "Ukraine.lua",     continent = "Europe",        admin_label = "Oblasts & Areas",       mountain_max = 2061, data = ukraineData,     remoteIslandNames = {} },
        addCountry { id = "Antarctica",  name = "Antarctica",   code = "AQ-010", filename = "Antarctica.lua",  continent = "Antarctica",    admin_label = "Regions & Areas",    mountain_max = 4892, data = antarcticaData,  remoteIslandNames = {} },
}

-- Fixed continent order — shown in Country column regardless of whether
-- any countries are currently loaded for that continent.
local CONTINENT_ORDER = {
        "Europe",
        "North America",
        "South America",
        "Africa",
        "Asia",
        "Oceania",
        "Antarctica",
}

local maxCounties = 0
for _, c in ipairs( COUNTRIES ) do
        if #c.countyNames > maxCounties then maxCounties = #c.countyNames end
end

local maxRemoteIslands = 0
for _, c in ipairs( COUNTRIES ) do
        local n = #( c.remoteIslandNames or {} )
        if n > maxRemoteIslands then maxRemoteIslands = n end
end

-- Per-country label overrides for the three hierarchy levels.
-- Keys must match COUNTRIES[*].id exactly.
local LABELS = {
        Norway       = { county = "County",   muni = "Municipality", city = "City" },
        Sweden       = { county = "County",   muni = "Municipality", city = "City" },
        Panama       = { county = "Province", muni = "District",     city = "City" },
        UnitedStates = { county = "State",    muni = "County",       city = "City" },
        Chile        = { county = "Region",   muni = "Province",     city = "City" },
        Kenya        = { county = "County",   muni = "Sub-county",   city = "City" },
        NewZealand    = { county = "Region",       muni = "District",   city = "City" },
        Greenland     = { county = "Municipality", muni = "District",   city = "Town" },
        Finland       = { county = "Region",       muni = "Sub-region", city = "City" },
        UnitedKingdom = { county = "Country",      muni = "County",     city = "City" },
        India         = { county = "State",        muni = "District",   city = "City" },
        Argentina     = { county = "Province",    muni = "Department",   city = "City" },
        Antarctica    = { county = "Region",      muni = "Territory",    city = "Station" },
        Australia     = { county = "State",       muni = "Region",       city = "City" },
        Rwanda        = { county = "Province",    muni = "District",     city = "City" },
        SouthAfrica   = { county = "Province",    muni = "District",     city = "City" },
        Ecuador       = { county = "Province",    muni = "Canton",       city = "City" },
        Botswana      = { county = "District",    muni = "Sub-district", city = "City" },
        Hungary       = { county = "County",      muni = "District",     city = "City" },
        Netherlands   = { county = "Province",    muni = "Municipality", city = "City" },
        China         = { county = "Province",    muni = "Prefecture",   city = "City" },
        Russia        = { county = "Federal Subject", muni = "District",  city = "City" },
        France        = { county = "Region",       muni = "Department",   city = "Commune" },
        Denmark       = { county = "Region",       muni = "Municipality", city = "City" },
        Iceland       = { county = "Region",       muni = "Municipality", city = "City" },
        Germany       = { county = "State",        muni = "District",     city = "City" },
        Spain         = { county = "Community",    muni = "Province",     city = "City" },
        Portugal      = { county = "District",     muni = "Municipality", city = "City" },
        Italy         = { county = "Region",       muni = "Province",     city = "City" },
        Austria       = { county = "State",        muni = "District",     city = "City" },
        Belgium       = { county = "Region",       muni = "Province",     city = "City" },
        Switzerland   = { county = "Canton",       muni = "District",     city = "City" },
        Ireland       = { county = "County",       muni = "Local Authority", city = "City" },
        Poland        = { county = "Voivodeship",  muni = "County",       city = "City" },
        Greece        = { county = "Region",       muni = "Municipality", city = "City" },
        CzechRepublic = { county = "Region",       muni = "District",     city = "City" },
        Romania       = { county = "County",       muni = "Commune",      city = "City" },
        Ukraine       = { county = "Oblast",       muni = "Raion",        city = "City" },
        Croatia       = { county = "County",       muni = "Municipality", city = "City" },
        Slovenia      = { county = "Municipality", muni = "Settlement",   city = "City" },
        Bulgaria      = { county = "Province",     muni = "Municipality", city = "City" },
        Serbia        = { county = "Region",       muni = "District",     city = "City" },
        Slovakia      = { county = "Region",       muni = "District",     city = "City" },
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
        Chile        = { co = nil,         mu = nil,         ci = nil },
        Kenya        = { co = nil,         mu = nil,         ci = nil },
        NewZealand    = { co = nil, mu = nil, ci = nil },
        Greenland     = { co = nil, mu = nil, ci = nil },
        Finland       = { co = nil, mu = nil, ci = nil },
        UnitedKingdom = { co = nil, mu = nil, ci = nil },
        India         = { co = nil, mu = nil, ci = nil },
        Argentina     = { co = nil, mu = nil, ci = nil },
        Antarctica    = { co = nil, mu = nil, ci = nil },
        Australia     = { co = nil, mu = nil, ci = nil },
        Rwanda        = { co = nil, mu = nil, ci = nil },
        SouthAfrica   = { co = nil, mu = nil, ci = nil },
        Ecuador       = { co = nil, mu = nil, ci = nil },
        Botswana      = { co = nil, mu = nil, ci = nil },
        Hungary       = { co = nil, mu = nil, ci = nil },
        Netherlands   = { co = nil, mu = nil, ci = nil },
        China         = { co = nil, mu = nil, ci = nil },
        Russia        = { co = nil, mu = nil, ci = nil },
        France        = { co = nil, mu = nil, ci = nil },
        Denmark       = { co = nil, mu = nil, ci = nil },
        Iceland       = { co = nil, mu = nil, ci = nil },
        Germany       = { co = nil, mu = nil, ci = nil },
        Spain         = { co = nil, mu = nil, ci = nil },
        Portugal      = { co = nil, mu = nil, ci = nil },
        Italy         = { co = nil, mu = nil, ci = nil },
        Austria       = { co = nil, mu = nil, ci = nil },
        Belgium       = { co = nil, mu = nil, ci = nil },
        Switzerland   = { co = nil, mu = nil, ci = nil },
        Ireland       = { co = nil, mu = nil, ci = nil },
        Poland        = { co = nil, mu = nil, ci = nil },
        Greece        = { co = nil, mu = nil, ci = nil },
        CzechRepublic = { co = nil, mu = nil, ci = nil },
        Romania       = { co = nil, mu = nil, ci = nil },
        Ukraine       = { co = nil, mu = nil, ci = nil },
        Croatia       = { co = nil, mu = nil, ci = nil },
        Slovenia      = { co = nil, mu = nil, ci = nil },
        Bulgaria      = { co = nil, mu = nil, ci = nil },
        Serbia        = { co = nil, mu = nil, ci = nil },
        Slovakia      = { co = nil, mu = nil, ci = nil },
}

-- Preferred label language(s) per country for the Wikidata label service.
local WIKIDATA_LANG = {
        Norway       = "no,nb,en",
        Sweden       = "sv,en",
        Panama       = "es,en",
        UnitedStates = "en",
        Chile        = "es,en",
        Kenya        = "sw,en",
        NewZealand    = "en,mi",
        Greenland     = "kl,da,en",
        Finland       = "fi,sv,en",
        UnitedKingdom = "en",
        India         = "hi,en",
        Argentina     = "es,en",
        Antarctica    = "en",
        Australia     = "en",
        Rwanda        = "rw,fr,en",
        SouthAfrica   = "en,af,zu",
        Ecuador       = "es,en",
        Botswana      = "tn,en",
        Hungary       = "hu,en",
        Netherlands   = "nl,en",
        China         = "zh,en",
        Russia        = "ru,en",
        France        = "fr,en",
        Denmark       = "da,en",
        Iceland       = "is,en",
        Germany       = "de,en",
        Spain         = "es,en",
        Portugal      = "pt,en",
        Italy         = "it,en",
        Austria       = "de,en",
        Belgium       = "nl,fr,de,en",
        Switzerland   = "de,fr,it,en",
        Ireland       = "en,ga",
        Poland        = "pl,en",
        Greece        = "el,en",
        CzechRepublic = "cs,en",
        Romania       = "ro,en",
        Ukraine       = "uk,en",
        Croatia       = "hr,en",
        Slovenia      = "sl,en",
        Bulgaria      = "bg,en",
        Serbia        = "sr,en",
        Slovakia      = "sk,en",
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
local TAB_IDS = { INTRO = "intro", KB = "builder", OV = "overview", MN = "monitor", HLP = "help" }

-- ── Column widths for List Overview ──────────────────────────────────────────

local W_ONOFF    = 35
local W_COUNTRY  = 130
local W_CODE     = 60
local W_FILE     = 110
local W_FILESIZE = 60
local W_VERSION  = 50
local W_NAMES    = 55
local W_VERIFIED = 115
local W_UPDATED  = 115
local W_BUTTON   = 60
local CONTENT_W  = W_ONOFF + W_COUNTRY + W_CODE + W_FILE + W_FILESIZE
                 + W_VERSION + W_NAMES + W_VERIFIED + W_BUTTON + W_UPDATED + W_BUTTON + 8 * 8 + 15

-- ── Column widths for Verification Monitor ───────────────────────────────────

local W_M_NAME = 145  -- name cell (widest — municipality names can be long)
local W_M_CONF = 85   -- conflict result cell ("-" or short suggested name)
local W_M_ACT  = 65   -- action popup cell ("—" or "Change")
-- G_W: width of one group column (+ scrollbar allowance).
local G_W          = W_M_NAME + W_M_CONF + W_M_ACT + 12 + 16   -- ~323 px
-- Total monitor width: 3 groups + inter-group spacing
local CONTENT_W_MN = G_W * 3 + 30

-- ── Column widths for Keyword List Builder ────────────────────────────────────
local KB_COL_W_COUNTRY = 380  -- Country column
local KB_COL_W_COUNTY  = 300  -- Counties & Areas column
local KB_COL_W_FEAT    = 300  -- Selections (Features) column
local KB_COUNTY_LIST_H = 327  -- Fixed height of the county scrolled_view (fills the
                              -- middle column down to the version text; fill_vertical
                              -- on scrolled_view is unreliable in the LR SDK)

-- ── Approximate dialog background grey for scrolled_view content ─────────────
-- LR Classic dialog background is roughly 0.9 (light mode).
local DLG_BG = LrColor( 0.9, 0.9, 0.9 )

-- ── Action value sanitiser (used across initVerProps + applyVerifiedJson) ─────
-- Only "change", "change_manual" and "delete" are meaningful persisted actions.
-- Everything else (old "dash", nil, unknown) maps to "none".
local function sanitizeAction( v )
        if v == "change"        then return "change" end
        if v == "change_manual" then return "change_manual" end
        if v == "delete"        then return "delete" end
        return "none"
end

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

        -- ── Keyword Builder state ──────────────────────────────────────────────

        local countryState = {}    -- per-country saved settings (keyed by country.id)
        local loading      = false -- prevents markDirty during state transitions

        -- ── Keyword Builder props ──────────────────────────────────────────────

        props.active_country_id       = ""
        props.active_country_name     = ""
        props.active_is_norway        = false
        props.dirty                   = false
        props.active_selections_label = "Selections"
        props.active_divisions_label  = "Counties & Areas"
        props.active_save_label       = "Save setting"
        props.active_version_label    = ""
        props.active_mountain_max     = COUNTRIES[1].mountain_max
        props.active_np_max           = COUNTRIES[1].np_max
        props.active_nr_max           = COUNTRIES[1].nr_max
        props.active_fj_max           = COUNTRIES[1].fj_max
        props.active_lk_max           = COUNTRIES[1].lk_max
        props.active_rv_max           = COUNTRIES[1].rv_max
        props.active_is_max           = COUNTRIES[1].is_max
        props.active_vp_max           = COUNTRIES[1].vp_max

        props.feat_select_all          = false
        props.feat_national_parks      = false
        props.feat_national_parks_max  = COUNTRIES[1].np_max
        props.feat_nature_reserves     = false
        props.feat_nature_reserves_max = COUNTRIES[1].nr_max
        props.feat_mountains           = false
        props.feat_mainland_cutoff     = 1800
        props.feat_fjords              = false
        props.feat_fjords_max          = COUNTRIES[1].fj_max
        props.feat_lakes               = false
        props.feat_lakes_max           = COUNTRIES[1].lk_max
        props.feat_rivers              = false
        props.feat_rivers_max          = COUNTRIES[1].rv_max
        props.feat_islands             = false
        props.feat_islands_max         = COUNTRIES[1].is_max
        props.feat_viewpoints          = false
        props.feat_viewpoints_max      = COUNTRIES[1].vp_max
        props.feat_admin_detail        = 3
        props.feat_remote_islands_all  = false
        props.show_ri_section          = false
        props.ri_count                 = 0
        for i = 1, maxRemoteIslands do
                props[ "ri_value_" .. i ] = false
                props[ "ri_name_"  .. i ] = ""
        end

        props.div_select_all = false
        for i = 1, maxCounties do
                props[ "div_value_" .. i ] = false
        end

        for _, _cont in ipairs( CONTINENT_ORDER ) do
                local _cl = _cont:lower():gsub( "%s+", "_" )
                props[ _cl .. "_expanded" ] = false
        end

        for _, country in ipairs( COUNTRIES ) do
                props[ country.id .. "_include" ]      = false
                props[ country.id .. "_has_settings" ] = false
                props[ country.id .. "_enabled" ]      = prefs[ "enabled_" .. country.id ] or false
        end

        for i = 1, maxCounties do
                props[ "county_name_" .. i ] = ""
        end
        props.active_select_all_label     = "Select All"

        -- ── Keyword Builder helpers ────────────────────────────────────────────

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

        -- ── Keyword Builder state management ───────────────────────────────────

        local function kbDefaultState( country )
                return {
                        feat_national_parks      = false,
                        feat_national_parks_max  = country.np_max,
                        feat_nature_reserves     = false,
                        feat_nature_reserves_max = country.nr_max,
                        feat_mountains           = false,
                        feat_mainland_cutoff     = (country.id == "Norway" and 1800 or country.id == "UnitedStates" and 4000 or 1000),
                        feat_fjords              = false,
                        feat_fjords_max          = country.fj_max,
                        feat_lakes               = false,
                        feat_lakes_max           = country.lk_max,
                        feat_rivers              = false,
                        feat_rivers_max          = country.rv_max,
                        feat_islands             = false,
                        feat_islands_max         = country.is_max,
                        feat_viewpoints          = false,
                        feat_viewpoints_max      = country.vp_max,
                        feat_admin_detail        = 1,
                        ri                       = {},
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
                        ri                       = (function()
                                local t = {}
                                local riNames = activeCountry.remoteIslandNames or {}
                                for i, riName in ipairs( riNames ) do
                                        t[ riName ] = props[ "ri_value_" .. i ] and true or false
                                end
                                return t
                        end)(),
                        counties                 = counties,
                }
                props[ cid .. "_has_settings" ] = true
                props[ cid .. "_include" ]      = true
                props.dirty = false
        end

        local function loadCountryState( cid, country )
                loading = true
                local state = countryState[ cid ] or kbDefaultState( country )
                local names = country.countyNames
                props.active_np_max            = country.np_max
                props.active_nr_max            = country.nr_max
                props.active_fj_max            = country.fj_max
                props.active_lk_max            = country.lk_max
                props.active_rv_max            = country.rv_max
                props.active_is_max            = country.is_max
                props.active_vp_max            = country.vp_max
                props.feat_national_parks      = state.feat_national_parks      or false
                props.feat_national_parks_max  = math.min( state.feat_national_parks_max  or country.np_max, country.np_max )
                props.feat_nature_reserves     = state.feat_nature_reserves      or false
                props.feat_nature_reserves_max = math.min( state.feat_nature_reserves_max or country.nr_max, country.nr_max )
                props.feat_mountains           = state.feat_mountains            or false
                props.feat_mainland_cutoff     = math.min(
                        state.feat_mainland_cutoff or country.mountain_max,
                        country.mountain_max )
                props.feat_fjords              = state.feat_fjords               or false
                props.feat_fjords_max          = math.min( state.feat_fjords_max           or country.fj_max, math.max( country.fj_max, 1 ) )
                props.feat_lakes               = state.feat_lakes                or false
                props.feat_lakes_max           = math.min( state.feat_lakes_max            or country.lk_max, math.max( country.lk_max, 1 ) )
                props.feat_rivers              = state.feat_rivers               or false
                props.feat_rivers_max          = math.min( state.feat_rivers_max           or country.rv_max, math.max( country.rv_max, 1 ) )
                props.feat_islands             = state.feat_islands              or false
                props.feat_islands_max         = math.min( state.feat_islands_max          or country.is_max, math.max( country.is_max, 1 ) )
                props.feat_viewpoints          = state.feat_viewpoints           or false
                props.feat_viewpoints_max      = math.min( state.feat_viewpoints_max or country.vp_max, math.max( country.vp_max, 1 ) )
                props.feat_admin_detail        = state.feat_admin_detail         or 1
                props.feat_select_all          = false
                local savedCounties = state.counties or {}
                for i = 1, #names do
                        props[ "div_value_" .. i ] = savedCounties[ names[ i ] ] and true or false
                end
                for i = #names + 1, maxCounties do
                        props[ "div_value_" .. i ] = false
                end
                props.div_select_all = false
                for i = 1, maxCounties do
                        props[ "county_name_" .. i ] = names[ i ] or ""
                end
                -- Remote islands
                local riNames  = country.remoteIslandNames or {}
                local savedRI  = state.ri or {}
                local riCount  = #riNames
                props.ri_count        = riCount
                props.show_ri_section = riCount > 0
                for i = 1, riCount do
                        props[ "ri_name_"  .. i ] = riNames[ i ]
                        props[ "ri_value_" .. i ] = savedRI[ riNames[ i ] ] and true or false
                end
                for i = riCount + 1, maxRemoteIslands do
                        props[ "ri_name_"  .. i ] = ""
                        props[ "ri_value_" .. i ] = false
                end
                local adminLabel = country.admin_label or "Counties & Areas"
                local dataVer    = (country.data.meta and country.data.meta.version) or "?"
                local ver        = props[ "list_version_" .. cid ] or dataVer
                props.active_country_id       = cid
                props.active_country_name     = country.name
                props.active_is_norway        = (cid == "Norway")
                props.active_mountain_max     = country.mountain_max
                props.active_selections_label = "Selections for " .. country.name
                props.active_divisions_label  = adminLabel .. " for " .. country.name
                props.active_save_label       = "Save setting"
                props.active_select_all_label = "Select All"
                props.active_version_label    = country.name .. " v" .. ver
                props.dirty = false
                loading = false
        end

        -- Shared upvalue: tracks which country buildBuilderPanel should render.
        -- Declared here (before makeSwitchAction AND buildBuilderPanel) so both
        -- functions see it as the same upvalue.  Initialised below after the
        -- first loadCountryState call.
        local activePanelCountry

        -- Forward reference: switchTab is defined in the dialog setup section
        -- (after this function), but makeSwitchAction needs to call it from
        -- inside startAsyncTask.  Lua requires the local to be declared before
        -- the closure that captures it; the actual function body is assigned
        -- below where `contents` is also in scope.
        local switchTab

        local function makeSwitchAction( cid, country )
                return function()
                        -- Button action callbacks run outside a task context, so
                        -- LrDialogs.confirm and LrDialogs.stopModalWithResult require
                        -- startAsyncTask to work correctly.
                        LrTasks.startAsyncTask( function()
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
                                activePanelCountry = country
                                -- Rebuild KB panel with exact row count for the new country.
                                -- (visible=false in LR SDK preserves layout space, so rebuild
                                -- via the keepOpen loop is the only correct approach.)
                                switchTab( TAB_IDS.KB )
                        end )
                end
        end

        -- ── Keyword Builder generate helpers ───────────────────────────────────

        local function buildCustomPrefs( country )
                local state = countryState[ country.id ] or kbDefaultState( country )
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
                        remote_islands_names    = country.remoteIslandNames or {},
                        remote_islands_selected = state.ri or {},
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
                        remote_islands_names    = country.remoteIslandNames or {},
                        remote_islands_selected = (function()
                                local t = {}
                                if more then
                                        for _, riName in ipairs( country.remoteIslandNames or {} ) do
                                                t[ riName ] = true
                                        end
                                end
                                return t
                        end)(),
                        counties            = counties,
                }
        end

        -- ── doGenerate: collect + write keyword file ───────────────────────────

        local function doGenerate()
                saveCurrentState()
                local parts      = {}
                local countryIds = {}
                local skipped    = {}
                for _, country in ipairs( COUNTRIES ) do
                        local cid      = country.id
                        local genPrefs = nil
                        if props[ cid .. "_include" ] then
                                genPrefs = buildCustomPrefs( country )
                        else
                                local contLower = (country.continent or "Other"):lower():gsub( "%s+", "_" )
                                local detail    = math.floor( (props[ contLower .. "_detail" ] or 0) + 0.5 )
                                if detail > 0 then
                                        genPrefs = buildQuickPrefs( detail, country )
                                end
                        end
                        if genPrefs then
                                local output    = Generator.generate( country.data, genPrefs )
                                local lineCount = 0
                                for _ in output:gmatch( "[^\n]+" ) do lineCount = lineCount + 1 end
                                if lineCount > 1 then
                                        parts[      #parts      + 1 ] = output
                                        countryIds[ #countryIds + 1 ] = cid
                                else
                                        skipped[ #skipped + 1 ] = country.name
                                end
                        end
                end
                if #skipped > 0 then
                        LrDialogs.message(
                                "Nothing exported for " .. table.concat( skipped, ", " ),
                                "These countries had no counties or features selected and were "
                                .. "skipped: " .. table.concat( skipped, ", " ) .. ".\n\n"
                                .. 'Click "Select More" next to a country to configure it, '
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
                local content  = table.concat( parts, "\n" )
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
                                if ok ~= "ok" then skipThisFile = true end
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
        end

        -- ── Keyword Builder colours ────────────────────────────────────────────

        local panelGrey = LrColor( 0.878, 0.878, 0.878 )
        local dimColor  = LrColor( 0.4, 0.4, 0.4 )

        -- ── Keyword Builder observers ──────────────────────────────────────────

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
                "feat_remote_islands_all",
        }
        for _, key in ipairs( featKeys ) do
                props:addObserver( key, markDirty )
        end
        for i = 1, maxCounties do
                props:addObserver( "div_value_" .. i, markDirty )
        end
        for i = 1, maxRemoteIslands do
                props:addObserver( "ri_value_" .. i, markDirty )
        end

        local suppressRIAll = false
        props:addObserver( "feat_remote_islands_all", function()
                if suppressRIAll or loading then return end
                suppressRIAll = true
                local v = props.feat_remote_islands_all
                local n = props.ri_count or 0
                for i = 1, n do
                        props[ "ri_value_" .. i ] = v
                end
                suppressRIAll = false
        end )

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
                                local n = #( c.remoteIslandNames or {} )
                                for i = 1, n do
                                        props[ "ri_value_" .. i ] = v
                                end
                                break
                        end
                end
                suppressDivAll = false
        end )

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

        for _, country in ipairs( COUNTRIES ) do
                local cid = country.id
                props:addObserver( cid .. "_enabled", function()
                        prefs[ "enabled_" .. cid ] = props[ cid .. "_enabled" ]
                end )
        end

        loadCountryState( COUNTRIES[1].id, COUNTRIES[1] )
        activePanelCountry = COUNTRIES[1]   -- initialise shared upvalue


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
                -- Sanitise saved action value: "change", "change_manual", "delete" are
                -- preserved; everything else (old "dash", nil, unknown) → "none".
                local validAction = sanitizeAction
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

        -- Persist the current in-memory verification state (conflict + action)
        -- for a country to prefs.  Captures action changes made via the popup
        -- after a Verify run (which otherwise would only live in props).
        local function persistVerToPrefs( cid )
                local geo = GEO[ cid ]
                if not geo then return end
                local function grab( names, vcPfx, vaPfx )
                        local saved = {}
                        for i = 1, #names do
                                saved[ i ] = {
                                        c = props[ vcPfx .. cid .. "_" .. i ],
                                        a = props[ vaPfx .. cid .. "_" .. i ],
                                }
                        end
                        return saved
                end
                prefs[ "ver_" .. cid .. "_co" ] = grab( geo.counties, "vcco_", "vaco_" )
                prefs[ "ver_" .. cid .. "_mu" ] = grab( geo.munis,    "vcmu_", "vamu_" )
                prefs[ "ver_" .. cid .. "_ci" ] = grab( geo.cities,   "vcci_", "vaci_" )
        end

        -- Build the verified/<Country>.json payload (Lua table) from the current
        -- in-memory verification state.  Entries with a real conflict suggestion
        -- or a non-default action (change / change_manual / delete) are included.
        local function buildVerifiedJson( cid, ver )
                local geo = GEO[ cid ]
                local function levelArr( names, vcPfx, vaPfx )
                        local arr = {}
                        for i = 1, #names do
                                local conflict = props[ vcPfx .. cid .. "_" .. i ]
                                local action   = props[ vaPfx .. cid .. "_" .. i ]
                                local realC    = conflict and conflict ~= "—"
                                                 and conflict ~= "-" and conflict ~= "..."
                                                 and conflict ~= "✓"
                                local activeAct = action == "change"
                                                  or action == "change_manual"
                                                  or action == "delete"
                                if realC or activeAct then
                                        arr[ #arr + 1 ] = {
                                                i        = i,
                                                name     = names[ i ],
                                                conflict = realC and conflict or nil,
                                                action   = activeAct and action or "none",
                                        }
                                end
                        end
                        return arr
                end
                return {
                        country  = cid,
                        version  = ver or prefs[ "list_version_" .. cid ] or "?",
                        verified = os.date( "%Y-%m-%d %H:%M" ),
                        listname = props[ "listname_" .. cid ],
                        levels   = {
                                co = levelArr( geo.counties, "vcco_", "vaco_" ),
                                mu = levelArr( geo.munis,    "vcmu_", "vamu_" ),
                                ci = levelArr( geo.cities,   "vcci_", "vaci_" ),
                        },
                }
        end

        -- Apply a decoded verified/<Country>.json payload back into props.
        -- Entries are matched by name (with an index fallback), so the mapping
        -- survives small reorderings of the underlying data.
        local function applyVerifiedJson( cid, obj )
                local geo = GEO[ cid ]
                if not geo or not obj or not obj.levels then return end
                local function applyLevel( names, vcPfx, vaPfx, arr )
                        if type( arr ) ~= "table" then return end
                        local byName = {}
                        for i = 1, #names do
                                byName[ names[ i ] ] = byName[ names[ i ] ] or {}
                                table.insert( byName[ names[ i ] ], i )
                        end
                        local used = {}
                        for _, e in ipairs( arr ) do
                                local idx
                                if e.name and byName[ e.name ] then
                                        for _, cand in ipairs( byName[ e.name ] ) do
                                                if not used[ cand ] then idx = cand; break end
                                        end
                                        idx = idx or byName[ e.name ][ 1 ]
                                end
                                idx = idx or e.i
                                if idx and idx >= 1 and idx <= #names then
                                        used[ idx ] = true
                                        if e.conflict and e.conflict ~= "" then
                                                props[ vcPfx .. cid .. "_" .. idx ] = e.conflict
                                        end
                                        props[ vaPfx .. cid .. "_" .. idx ] =
                                                sanitizeAction( e.action )
                                end
                        end
                end
                applyLevel( geo.counties, "vcco_", "vaco_", obj.levels.co )
                applyLevel( geo.munis,    "vcmu_", "vamu_", obj.levels.mu )
                applyLevel( geo.cities,   "vcci_", "vaci_", obj.levels.ci )

                if obj.version then
                        prefs[ "list_version_" .. cid ] = obj.version
                        props[ "list_version_" .. cid ] = obj.version
                end
                if obj.verified then
                        prefs[ "verified_" .. cid ] = obj.verified
                        props[ "verified_" .. cid ] = obj.verified
                end
                if obj.listname and obj.listname ~= "" then
                        prefs[ "listname_" .. cid ] = obj.listname
                        props[ "listname_" .. cid ] = obj.listname
                end
                persistVerToPrefs( cid )
        end

        ------------------------------------------------------------------------
        -- Tab navigation — LR-ListDoctor pattern
        ------------------------------------------------------------------------

        props.activeTabId = TAB_IDS.INTRO

        local contents
        local currentDialog = TAB_IDS.INTRO
        local switching     = false

        -- Assign the forward-declared upvalue (declared before makeSwitchAction
        -- so that startAsyncTask closures can call it).
        switchTab = function( target )
                if switching then return end
                switching = true
                LrDialogs.stopModalWithResult( contents, target )
        end

        props:addObserver( "activeTabId", function()
                if props.activeTabId ~= currentDialog then
                        switchTab( props.activeTabId )
                end
        end )


        ------------------------------------------------------------------------
        -- Tab 1 — List Overview
        ------------------------------------------------------------------------

        local function buildOverviewPanel()
                local headerRow = f:row {
                        spacing = 6,
                        f:static_text { title = "Show",          width = W_ONOFF,    font = "<system/bold>" },
                        f:static_text { title = "Country",       width = W_COUNTRY,  font = "<system/bold>" },
                        f:static_text { title = "Code",          width = W_CODE,     font = "<system/bold>" },
                        f:static_text { title = "File name",     width = W_FILE,     font = "<system/bold>" },
                        f:static_text { title = "File size",     width = W_FILESIZE, font = "<system/bold>" },
                        f:static_text { title = "Version",       width = W_VERSION,  font = "<system/bold>" },
                        f:spacer      { width = 5 },
                        f:static_text { title = "Names",         width = W_NAMES,    font = "<system/bold>" },
                        f:static_text { title = "Last verified", width = W_VERIFIED, font = "<system/bold>" },
                        f:spacer      { width = W_BUTTON },
                        f:spacer      { width = 10 },
                        f:static_text { title = "Last update",   width = W_UPDATED,  font = "<system/bold>" },
                        f:spacer      { width = W_BUTTON },
                }

                -- Sort: enabled countries first (alphabetical), then disabled (alphabetical).
                -- If none enabled, all are sorted alphabetically.
                local sorted = {}
                for _, c in ipairs( COUNTRIES ) do sorted[ #sorted + 1 ] = c end
                table.sort( sorted, function( a, b )
                        local ae = props[ a.id .. "_enabled" ] and true or false
                        local be = props[ b.id .. "_enabled" ] and true or false
                        if ae ~= be then return ae end
                        return a.name < b.name
                end )

                local rowViews = {}
                for _, country in ipairs( sorted ) do
                        local verKey  = "verified_"     .. country.id
                        local updKey  = "updated_"      .. country.id
                        local lvKey   = "list_version_" .. country.id
                        local cname   = country.name
                        local geo     = GEO[ country.id ]
                        local nTotal  = ( geo and ( #geo.counties + #geo.munis + #geo.cities ) or 0 )
                        rowViews[ #rowViews + 1 ] = f:row {
                                spacing = 6,
                                f:checkbox {
                                        bind_to_object = props,
                                        title          = "",
                                        value          = LrView.bind( country.id .. "_enabled" ),
                                        width          = W_ONOFF,
                                },
                                f:static_text { title = cname,               width = W_COUNTRY },
                                f:static_text { title = country.code or "",  width = W_CODE },
                                f:static_text { title = country.filename, width = W_FILE },
                                f:static_text { title = getFileSize( country.filename ), width = W_FILESIZE },
                                -- Version column: shows list_version prop (may be bumped by Save).
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( lvKey ),
                                        width          = W_VERSION,
                                },
                                f:spacer { width = 5 },
                                f:static_text { title = tostring( nTotal ), width = W_NAMES },
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( verKey ),
                                        width          = W_VERIFIED,
                                },
                                -- Verify with Wiki button → opens Monitor for this country.
                                f:push_button {
                                        title  = "Verify with Wiki",
                                        width  = W_BUTTON,
                                        action = function()
                                                props.verify_country_id = country.id
                                                initVerPropsForCountry( country.id )
                                                switchTab( TAB_IDS.MN )
                                        end,
                                },
                                f:spacer { width = 10 },
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( updKey ),
                                        width          = W_UPDATED,
                                },
                                f:push_button {
                                        title  = "Update",
                                        width  = W_BUTTON,
                                        action = function()
                                                LrTasks.startAsyncTask( function()
                                                local cid    = country.id
                                                local geo    = GEO[ cid ]
                                                local labels = LABELS[ cid ] or DEFAULT_LABELS

                                                -- Flush any action popup changes that were made after
                                                -- the last Verify/Save (user may have switched tabs
                                                -- without clicking Save on the Monitor tab).
                                                persistVerToPrefs( cid )

                                                -- Collect all non-default actions from prefs.
                                                local savedCo = prefs[ "ver_" .. cid .. "_co" ] or {}
                                                local savedMu = prefs[ "ver_" .. cid .. "_mu" ] or {}
                                                local savedCi = prefs[ "ver_" .. cid .. "_ci" ] or {}

                                                -- coChanges / muChanges / ciChanges: rename (change or change_manual)
                                                -- coDeletes / muDeletes / ciDeletes: remove entry from data file
                                                local coChanges = {}
                                                local muChanges = {}
                                                local ciChanges = {}
                                                local coDeletes = {}
                                                local muDeletes = {}
                                                local ciDeletes = {}

                                                local function hasName( c )
                                                        return c and c ~= "" and c ~= "—" and c ~= "-" and c ~= "✓"
                                                end

                                                -- For "Change manually" rows where Conflicts shows "✓"
                                                -- (no Wikidata suggestion), prompt the user for a custom name
                                                -- before the main confirmation dialog.
                                                local function promptCustomName( oldName )
                                                        local result = nil
                                                        LrFunctionContext.callWithContext(
                                                                "promptCustomName", function( ctx )
                                                                local np = LrBinding.makePropertyTable( ctx )
                                                                np.customName = ""
                                                                local dlgResult = LrDialogs.presentModalDialog {
                                                                        title    = "Custom name — " .. cname,
                                                                        contents = f:column {
                                                                                spacing = f:control_spacing(),
                                                                                f:static_text {
                                                                                        title = "Enter new name for \"" .. oldName .. "\":",
                                                                                        width = 300,
                                                                                },
                                                                                f:edit_field {
                                                                                        bind_to_object = np,
                                                                                        value          = LrView.bind( "customName" ),
                                                                                        width          = 300,
                                                                                        immediate      = true,
                                                                                },
                                                                        },
                                                                        actionVerb = "OK",
                                                                        cancelVerb = "Skip",
                                                                }
                                                                if dlgResult == "ok" and np.customName ~= "" then
                                                                        result = np.customName
                                                                end
                                                        end )
                                                        return result
                                                end

                                                -- Pre-pass: resolve change_manual rows with no Wikidata name.
                                                for i, entry in ipairs( savedCo ) do
                                                        if geo.counties[ i ] and entry.a == "change_manual"
                                                                        and not hasName( entry.c ) then
                                                                local custom = promptCustomName( geo.counties[ i ] )
                                                                if custom then entry.c = custom end
                                                        end
                                                end
                                                for i, entry in ipairs( savedMu ) do
                                                        if geo.munis[ i ] and entry.a == "change_manual"
                                                                        and not hasName( entry.c ) then
                                                                local custom = promptCustomName( geo.munis[ i ] )
                                                                if custom then entry.c = custom end
                                                        end
                                                end
                                                for i, entry in ipairs( savedCi ) do
                                                        if geo.cities[ i ] and entry.a == "change_manual"
                                                                        and not hasName( entry.c ) then
                                                                local custom = promptCustomName( geo.cities[ i ] )
                                                                if custom then entry.c = custom end
                                                        end
                                                end

                                                for i, entry in ipairs( savedCo ) do
                                                        if not geo.counties[ i ] then break end
                                                        if entry.a == "change" or entry.a == "change_manual" then
                                                                if hasName( entry.c ) then
                                                                        coChanges[ #coChanges + 1 ] = {
                                                                                idx = i,
                                                                                old = geo.counties[ i ],
                                                                                new = entry.c,
                                                                        }
                                                                end
                                                        elseif entry.a == "delete" then
                                                                coDeletes[ #coDeletes + 1 ] = {
                                                                        idx = i,
                                                                        old = geo.counties[ i ],
                                                                }
                                                        end
                                                end
                                                for i, entry in ipairs( savedMu ) do
                                                        if not geo.munis[ i ] then break end
                                                        if entry.a == "change" or entry.a == "change_manual" then
                                                                if hasName( entry.c ) then
                                                                        muChanges[ #muChanges + 1 ] = {
                                                                                idx = i,
                                                                                old = geo.munis[ i ],
                                                                                new = entry.c,
                                                                        }
                                                                end
                                                        elseif entry.a == "delete" then
                                                                muDeletes[ #muDeletes + 1 ] = {
                                                                        idx = i,
                                                                        old = geo.munis[ i ],
                                                                }
                                                        end
                                                end
                                                for i, entry in ipairs( savedCi ) do
                                                        if not geo.cities[ i ] then break end
                                                        if entry.a == "change" or entry.a == "change_manual" then
                                                                if hasName( entry.c ) then
                                                                        ciChanges[ #ciChanges + 1 ] = {
                                                                                idx = i,
                                                                                old = geo.cities[ i ],
                                                                                new = entry.c,
                                                                        }
                                                                end
                                                        elseif entry.a == "delete" then
                                                                ciDeletes[ #ciDeletes + 1 ] = {
                                                                        idx = i,
                                                                        old = geo.cities[ i ],
                                                                }
                                                        end
                                                end

                                                local totalOps = #coChanges + #muChanges + #ciChanges
                                                                 + #coDeletes + #muDeletes + #ciDeletes
                                                if totalOps == 0 then
                                                        -- No changes to apply, but still record today's
                                                        -- date so "Last update" reflects the verification run.
                                                        prefs[ "updated_" .. cid ] = os.date( "%Y-%m-%d %H:%M" )
                                                        props[ "updated_" .. cid ] = prefs[ "updated_" .. cid ]
                                                        LrDialogs.message(
                                                                "No changes to apply — " .. cname,
                                                                "No entries are marked with Change, " ..
                                                                "Change manually, or Delete in " ..
                                                                "Verification Monitor for " .. cname .. ".\n\n" ..
                                                                "The 'Last update' date has been set to today.",
                                                                "info" )
                                                        return
                                                end

                                                -- Build change summary for confirmation.
                                                local lines = {}
                                                for _, ch in ipairs( coChanges ) do
                                                        lines[ #lines + 1 ] =
                                                                labels.county .. ":  \"" .. ch.old .. "\"  →  \"" .. ch.new .. "\""
                                                end
                                                for _, ch in ipairs( muChanges ) do
                                                        lines[ #lines + 1 ] =
                                                                labels.muni .. ":  \"" .. ch.old .. "\"  →  \"" .. ch.new .. "\""
                                                end
                                                for _, ch in ipairs( coDeletes ) do
                                                        lines[ #lines + 1 ] =
                                                                "DELETE " .. labels.county .. ":  \"" .. ch.old .. "\""
                                                end
                                                for _, ch in ipairs( muDeletes ) do
                                                        lines[ #lines + 1 ] =
                                                                "DELETE " .. labels.muni .. ":  \"" .. ch.old .. "\""
                                                end
                                                for _, ch in ipairs( ciChanges ) do
                                                        lines[ #lines + 1 ] =
                                                                labels.city .. ":  \"" .. ch.old .. "\"  →  \"" .. ch.new .. "\""
                                                end
                                                for _, ch in ipairs( ciDeletes ) do
                                                        lines[ #lines + 1 ] =
                                                                "DELETE " .. labels.city .. ":  \"" .. ch.old .. "\""
                                                end
                                                local currentVer = prefs[ "list_version_" .. cid ]
                                                                   or getVersion( country.data )
                                                local newVer     = nextPatchVersion( currentVer )

                                                local answer = LrDialogs.confirm(
                                                        "Update " .. country.filename,
                                                        "The following changes will be written to the data file:\n\n" ..
                                                        table.concat( lines, "\n" ) ..
                                                        "\n\nVersion: " .. currentVer .. " → " .. newVer ..
                                                        "\n\nThis modifies the bundled data file on disk. Continue?",
                                                        "Update", "Cancel" )
                                                if answer ~= "ok" then return end

                                                -- Read the data file as text.
                                                local filePath = LrPathUtils.child( dataDir, country.filename )
                                                local fh = io.open( filePath, "r" )
                                                if not fh then
                                                        LrDialogs.message(
                                                                "Kan ikke lese filen", filePath, "warning" )
                                                        return
                                                end
                                                local content = fh:read( "*all" )
                                                fh:close()

                                                -- ── 1. Apply name substitutions (change / change_manual). ──────
                                                -- Targets the pattern:  name = "ExactOldName"
                                                local applied = 0
                                                local function doSubs( changes )
                                                        for _, ch in ipairs( changes ) do
                                                                local esc = ch.old:gsub(
                                                                        "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1" )
                                                                local pat = '(name%s*=%s*")' .. esc .. '(")'
                                                                local safeNew = ch.new:gsub( "%%", "%%%%" )
                                                                local newContent, n =
                                                                        content:gsub( pat, "%1" .. safeNew .. "%2" )
                                                                if n > 0 then
                                                                        content = newContent
                                                                        applied = applied + n
                                                                end
                                                        end
                                                end
                                                local function doCitySubs( changes )
                                                        for _, ch in ipairs( changes ) do
                                                                local esc = ch.old:gsub(
                                                                        "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1" )
                                                                local safeNew = ch.new:gsub( "%%", "%%%%" )
                                                                -- Try structured entry:  name = "OldName"
                                                                local pat1 = '(name%s*=%s*")' .. esc .. '(")'  
                                                                local newContent, n =
                                                                        content:gsub( pat1, "%1" .. safeNew .. "%2" )
                                                                if n > 0 then
                                                                        content = newContent
                                                                        applied = applied + n
                                                                else
                                                                        -- Fallback: plain string literal:  "OldName"
                                                                        local pat2 = '"' .. esc .. '"'
                                                                        newContent, n =
                                                                                content:gsub(
                                                                                        pat2, '"' .. safeNew .. '"' )
                                                                        if n > 0 then
                                                                                content = newContent
                                                                                applied = applied + n
                                                                        end
                                                                end
                                                        end
                                                end
                                                doSubs( coChanges )
                                                doSubs( muChanges )
                                                doCitySubs( ciChanges )

                                                -- ── 2. Apply deletions (delete). ───────────────────────────────
                                                -- Line-based block removal: find the { ... }, block whose
                                                -- first name field matches the target, strip quoted strings
                                                -- before counting braces to handle nested tables safely.
                                                local deleted = 0
                                                local function deleteName( targetName )
                                                        local lns = {}
                                                        for line in ( content .. "\n" ):gmatch( "([^\n]*)\n" ) do
                                                                lns[ #lns + 1 ] = line
                                                        end
                                                        local esc = targetName:gsub(
                                                                "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1" )
                                                        -- Find the line that holds name = "targetName"
                                                        local nameLine = nil
                                                        for i, ln in ipairs( lns ) do
                                                                if ln:match( 'name%s*=%s*"' .. esc .. '"' ) then
                                                                        nameLine = i; break
                                                                end
                                                        end
                                                        if not nameLine then return end
                                                        -- Scan backwards for the opening "{" of this entry.
                                                        local openLine = nameLine - 1
                                                        while openLine >= 1 do
                                                                local stripped = lns[ openLine ]:gsub( '"[^"]*"', '""' )
                                                                if stripped:match( "^%s*{%s*$" ) or
                                                                   stripped:match( "^%s*{%s*%-%-" ) then
                                                                        break
                                                                end
                                                                openLine = openLine - 1
                                                        end
                                                        if openLine < 1 then return end
                                                        -- Scan forward from openLine to find the matching close.
                                                        local depth    = 0
                                                        local closeLine = nil
                                                        for i = openLine, #lns do
                                                                local stripped = lns[ i ]:gsub( '"[^"]*"', '""' )
                                                                for ch in stripped:gmatch( "." ) do
                                                                        if     ch == "{" then depth = depth + 1
                                                                        elseif ch == "}" then
                                                                                depth = depth - 1
                                                                                if depth == 0 then
                                                                                        closeLine = i; break
                                                                                end
                                                                        end
                                                                end
                                                                if closeLine then break end
                                                        end
                                                        if not closeLine then return end
                                                        -- Rebuild content without lines openLine..closeLine.
                                                        local out = {}
                                                        for i, ln in ipairs( lns ) do
                                                                if i < openLine or i > closeLine then
                                                                        out[ #out + 1 ] = ln
                                                                end
                                                        end
                                                        content = table.concat( out, "\n" )
                                                        deleted = deleted + 1
                                                end
                                                for _, ch in ipairs( coDeletes ) do deleteName( ch.old ) end
                                                for _, ch in ipairs( muDeletes ) do deleteName( ch.old ) end
                                                for _, ch in ipairs( ciDeletes ) do deleteName( ch.old ) end

                                                -- ── 3. Bump version in the meta block. ────────────────────────
                                                content = content:gsub(
                                                        '(version%s*=%s*")([^"]*)"',
                                                        "%1" .. newVer .. '"', 1 )
                                                content = content:gsub(
                                                        '(generated%s*=%s*")([^"]*)"',
                                                        "%1" .. os.date( "%Y-%m-%d" ) .. '"', 1 )
                                                content = content:gsub(
                                                        "Data version [%d%.]+ generated [%d%-]+",
                                                        "Data version " .. newVer ..
                                                        " generated " .. os.date( "%Y-%m-%d" ) )

                                                -- Write back to disk.
                                                local wh = io.open( filePath, "w" )
                                                if not wh then
                                                        LrDialogs.message(
                                                                "Kan ikke skrive filen", filePath, "warning" )
                                                        return
                                                end
                                                wh:write( content )
                                                wh:close()

                                                -- Update prefs and UI props.
                                                prefs[ "list_version_" .. cid ] = newVer
                                                props[ "list_version_" .. cid ] = newVer
                                                prefs[ "updated_" .. cid ]      = os.date( "%Y-%m-%d %H:%M" )
                                                props[ "updated_" .. cid ]      = prefs[ "updated_" .. cid ]

                                                -- Clear applied actions in prefs so next Verify starts clean.
                                                local coSaved = prefs[ "ver_" .. cid .. "_co" ] or {}
                                                for _, ch in ipairs( coChanges ) do
                                                        if coSaved[ ch.idx ] then
                                                                coSaved[ ch.idx ].a = "none"
                                                        end
                                                end
                                                for _, ch in ipairs( coDeletes ) do
                                                        if coSaved[ ch.idx ] then
                                                                coSaved[ ch.idx ].a = "none"
                                                        end
                                                end
                                                prefs[ "ver_" .. cid .. "_co" ] = coSaved

                                                local muSaved = prefs[ "ver_" .. cid .. "_mu" ] or {}
                                                for _, ch in ipairs( muChanges ) do
                                                        if muSaved[ ch.idx ] then
                                                                muSaved[ ch.idx ].a = "none"
                                                        end
                                                end
                                                for _, ch in ipairs( muDeletes ) do
                                                        if muSaved[ ch.idx ] then
                                                                muSaved[ ch.idx ].a = "none"
                                                        end
                                                end
                                                prefs[ "ver_" .. cid .. "_mu" ] = muSaved

                                                local ciSaved = prefs[ "ver_" .. cid .. "_ci" ] or {}
                                                for _, ch in ipairs( ciChanges ) do
                                                        if ciSaved[ ch.idx ] then
                                                                ciSaved[ ch.idx ].a = "none"
                                                        end
                                                end
                                                for _, ch in ipairs( ciDeletes ) do
                                                        if ciSaved[ ch.idx ] then
                                                                ciSaved[ ch.idx ].a = "none"
                                                        end
                                                end
                                                prefs[ "ver_" .. cid .. "_ci" ] = ciSaved

                                                -- Reload data file in memory so Verification Monitor
                                                -- sees the updated names immediately (no plugin reload needed
                                                -- to re-verify).  Keyword List Builder is a separate
                                                -- dofile() and still needs a plugin reload.
                                                local newData = dofile( filePath )
                                                for _, c in ipairs( COUNTRIES ) do
                                                        if c.id == cid then
                                                                c.data = newData
                                                                break
                                                        end
                                                end
                                                local rCos, rMus, rCis = extractGeoData( newData )
                                                GEO[ cid ] = { counties = rCos, munis = rMus, cities = rCis }
                                                verInited[ cid ] = false  -- Force Monitor to reinit on next open

                                                -- Push updated data file to GitHub if a token is configured.
                                                local summary = applied .. " name(s) changed"
                                                if deleted > 0 then
                                                        summary = summary .. ", " .. deleted .. " entr" ..
                                                                  ( deleted == 1 and "y" or "ies" ) .. " deleted"
                                                end

                                                if GitHubSync.isConfigured() then
                                                        LrTasks.startAsyncTask( function()
                                                                local ok, info = GitHubSync.writeFile(
                                                                        "data/" .. country.filename,
                                                                        content,
                                                                        "Update " .. cid .. " data → " .. newVer )
                                                                if ok then
                                                                        LrDialogs.message(
                                                                                "Updated & pushed — " .. cname,
                                                                                summary .. ". " ..
                                                                                country.filename .. " version " .. newVer ..
                                                                                " written and pushed to GitHub.\n\n" ..
                                                                                "You can run Verify again immediately. " ..
                                                                                "To update the Keyword List Builder, " ..
                                                                                "click 'Reload Plug-in'.",
                                                                                "info" )
                                                                else
                                                                        LrDialogs.message(
                                                                                "Updated locally — GitHub push FAILED — " .. cname,
                                                                                summary .. " in " ..
                                                                                country.filename .. " (version " .. newVer ..
                                                                                "), but the GitHub push failed:\n" ..
                                                                                tostring( info ) ..
                                                                                "\n\nCheck your token in File ▸ Plug-in Manager.\n\n" ..
                                                                                "You can run Verify again immediately. " ..
                                                                                "To update the Keyword List Builder, " ..
                                                                                "click 'Reload Plug-in'.",
                                                                                "warning" )
                                                                end
                                                        end )
                                                else
                                                        LrDialogs.message(
                                                                "Updated — " .. cname,
                                                                summary .. " in " ..
                                                                country.filename .. " (version " .. newVer .. ").\n\n" ..
                                                                "You can run Verify again immediately. " ..
                                                                "To update the Keyword List Builder, " ..
                                                                "click 'Reload Plug-in'.",
                                                                "info" )
                                                end
                                                end )  -- LrTasks.startAsyncTask
                                        end,
                                },
                        }
                end

                local rowSpec = { spacing = f:control_spacing() }
                for _, row in ipairs( rowViews ) do
                        rowSpec[ #rowSpec + 1 ] = row
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
                        headerRow,
                        f:separator { fill_horizontal = 1 },
                        f:scrolled_view {
                                height              = 390,
                                width               = 1000,
                                horizontal_scroller = false,
                                background_color    = LrColor( 0.88, 0.88, 0.88 ),
                                f:column( rowSpec ),
                        },
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
        --   "vaco_<cid>_<i>"  action value ("none"|"change"|"change_manual"|"delete")
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

                -- Groups with more than this many items use the compact / lazy
                -- rendering strategy: only conflict rows are shown; large verified-OK
                -- groups are collapsed to a single summary line.
                local LARGE_GROUP = 300

                local function makeGroup( label, items, vcPfx, vaPfx, prefKey )

                        -- Scan verification state: count verified & conflict items.
                        local verifiedCount = 0
                        local conflictItems = {}   -- {i, name} for items with real suggestions
                        for i = 1, #items do
                                local vc = props[ vcPfx .. cid .. "_" .. i ] or "—"
                                if vc ~= "—" and vc ~= "-" then
                                        verifiedCount = verifiedCount + 1
                                        if vc ~= "✓" then
                                                conflictItems[ #conflictItems + 1 ] = { i = i, name = items[ i ] }
                                        end
                                end
                        end
                        local noneVerified = ( verifiedCount == 0 )
                        local allVerified  = ( verifiedCount == #items )
                        local isLarge      = ( #items > LARGE_GROUP )

                        -- Build display order each time the panel is constructed.
                        -- For large groups use only the conflict subset (already small).
                        -- For small groups (counties, municipalities) include all items.
                        local display = {}
                        if isLarge then
                                -- Sort conflict rows alphabetically (no "all items" sort needed).
                                table.sort( conflictItems, function( a, b ) return a.name < b.name end )
                                display = conflictItems
                        else
                                for i = 1, #items do
                                        display[ #display + 1 ] = { i = i, name = items[ i ] }
                                end
                                table.sort( display, function( a, b )
                                        local vcA = props[ vcPfx .. cid .. "_" .. a.i ] or "—"
                                        local vcB = props[ vcPfx .. cid .. "_" .. b.i ] or "—"
                                        local aC  = ( vcA ~= "—" ) and ( vcA ~= "-" ) and ( vcA ~= "✓" )
                                        local bC  = ( vcB ~= "—" ) and ( vcB ~= "-" ) and ( vcB ~= "✓" )
                                        if aC ~= bC then return aC end
                                        return a.name < b.name
                                end )
                        end

                        -- Verify action: compare every item against Wikidata canonical names
                        -- (or fall back to pattern analysis if Wikidata is unreachable).
                        --
                        -- Runs bottom-to-top so the user immediately sees activity at the
                        -- bottom of the list, then yields every batchSize rows to repaint.
                        --
                        -- Existing Actions (change / change_manual / delete) are PRESERVED
                        -- so re-verifying keeps the user's decisions intact.
                        --
                        --   Conflicts = "—"        → not yet verified (initial state)
                        --   Conflicts = "..."       → currently being checked
                        --   Conflicts = "✓"         → confirmed OK by Wikidata / pattern
                        --   Conflicts = "SomeName"  → suggested canonical spelling
                        local vprogKey = "vprog_"  .. prefKey .. "_" .. cid
                        local vcurrKey = "vcurr_"  .. prefKey .. "_" .. cid

                        local function doVerify()
                                LrTasks.startAsyncTask( function()

                                        local today     = os.date( "%Y-%m-%d %H:%M" )
                                        local startTime = os.time()   -- for time-remaining estimate

                                        -- Reset progress counter and current-item label.
                                        props[ vprogKey ] = ""
                                        props[ vcurrKey ] = ""

                                        -- Mark all cells in this group as "checking..."
                                        for i = 1, #items do
                                                props[ vcPfx .. cid .. "_" .. i ] = "..."
                                        end
                                        LrTasks.sleep( 0.05 )   -- let UI repaint to show "..."

                                        -- Fetch Wikidata canonical name set (one HTTP call, cached).
                                        -- Returns { [name]=true } or nil when offline / not applicable.
                                        local wikidataNames = fetchWikidataNames( cid, prefKey )

                                        -- Check each item bottom-to-top so the user sees progress
                                        -- immediately from the bottom of the list.
                                        -- Yield every batchSize rows (~25 visual refreshes per group).
                                        local batchSize = math.max( 1, math.ceil( #items / 25 ) )
                                        for idx = 1, #items do
                                                local i          = #items - idx + 1
                                                local name       = items[ i ]
                                                local suggestion = nil

                                                -- Show current item name above the scroll list.
                                                props[ vcurrKey ] = name

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

                                                props[ vcPfx .. cid .. "_" .. i ] = suggestion or "✓"

                                                -- Preserve existing user decisions (change / change_manual / delete).
                                                -- Only reset to "none" when the entry has no prior user decision.
                                                local curAct = props[ vaPfx .. cid .. "_" .. i ]
                                                if curAct ~= "change" and curAct ~= "change_manual"
                                                                      and curAct ~= "delete" then
                                                        props[ vaPfx .. cid .. "_" .. i ] = "none"
                                                end

                                                -- Update progress label: "idx / total — ca. X min/sec remaining".
                                                -- Time estimate is computed after the first batch yield.
                                                if idx % batchSize == 0 then
                                                        local elapsed = os.time() - startTime
                                                        local remStr  = ""
                                                        if elapsed > 0 and idx > 0 then
                                                                local rate      = idx / elapsed
                                                                local remaining = math.ceil( ( #items - idx ) / rate )
                                                                if remaining > 60 then
                                                                        remStr = " — ca. " ..
                                                                                 math.ceil( remaining / 60 ) ..
                                                                                 " min remaining"
                                                                elseif remaining > 1 then
                                                                        remStr = " — ca. " .. remaining .. " sec remaining"
                                                                end
                                                        end
                                                        props[ vprogKey ] = idx .. " / " .. #items .. remStr
                                                        LrTasks.sleep( 0.04 )
                                                end
                                        end

                                        -- Mark as fully done; clear current-item label.
                                        props[ vprogKey ] = #items .. " / " .. #items .. " ✓"
                                        props[ vcurrKey ] = ""

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

                        -- Top row: "Verify with Wiki" button, centred across the group width.
                        local verRow = f:row {
                                fill_horizontal = 1,
                                f:spacer { fill_horizontal = 1 },
                                f:push_button { title = "Verify with Wiki", action = doVerify },
                                f:spacer { fill_horizontal = 1 },
                        }

                        -- Sub-header row (bold column labels).
                        local subHdr = f:row {
                                spacing = 6,
                                f:static_text { title = label,       width = W_M_NAME, font = "<system/bold>" },
                                f:static_text { title = "Conflicts", width = W_M_CONF, font = "<system/bold>" },
                                f:static_text { title = "Action",    width = W_M_ACT,  font = "<system/bold>" },
                        }

                        -- One data row per item in sorted display order.
                        -- Large groups (> LARGE_GROUP) use compact rendering:
                        --   • Not yet verified → placeholder row only.
                        --   • All verified, no conflicts → single "all OK" row.
                        --   • Conflicts found → only the conflict rows.
                        local colSpec = {
                                spacing          = f:control_spacing(),
                                background_color = DLG_BG,
                        }

                        if isLarge and noneVerified then
                                -- Not verified yet — show a single placeholder row.
                                colSpec[ #colSpec + 1 ] = f:row {
                                        spacing = 6,
                                        f:static_text {
                                                title = "Click 'Verify with Wiki' to verify " ..
                                                        #items .. " entries.",
                                                width           = W_M_NAME + W_M_CONF + W_M_ACT + 12,
                                                height_in_lines = 2,
                                                font            = "<system/small>",
                                        },
                                }

                        elseif isLarge and allVerified and #conflictItems == 0 then
                                -- All verified, no conflicts — compact summary row.
                                colSpec[ #colSpec + 1 ] = f:row {
                                        spacing = 6,
                                        f:static_text {
                                                title = "All " .. #items .. " entries confirmed ✓ — no conflicts.",
                                                width = W_M_NAME + W_M_CONF + W_M_ACT + 12,
                                                font  = "<system/small>",
                                        },
                                }

                        else
                                -- Small group OR large group with conflicts: render data rows.
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
                                                                { title = "None",            value = "none"          },
                                                                { title = "Change",          value = "change"        },
                                                                { title = "Change manually", value = "change_manual" },
                                                                { title = "Delete",          value = "delete"        },
                                                        },
                                                        width = W_M_ACT,
                                                },
                                        }
                                end
                        end

                        -- Label that shows the name currently being verified (updates live
                        -- during the async task; hidden when verification is not running).
                        local currLabel = f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( vcurrKey ),
                                font           = "<system/small>",
                                fill_horizontal = 1,
                        }

                        local scrolled = f:scrolled_view {
                                width               = G_W,
                                height              = 250,
                                background_color    = DLG_BG,
                                horizontal_scroller = false,
                                f:column( colSpec ),
                        }

                        -- Row count + live progress indicator below the scroll area.
                        local countLabel = f:row {
                                spacing = 4,
                                f:static_text {
                                        title = #items .. " " .. label:lower() .. " entries",
                                        font  = "<system/small>",
                                },
                                f:spacer { fill_horizontal = 1 },
                                f:static_text {
                                        bind_to_object = props,
                                        title          = LrView.bind( vprogKey ),
                                        font           = "<system/small>",
                                        alignment      = "right",
                                },
                        }

                        return f:column {
                                spacing = f:control_spacing(),
                                verRow,
                                subHdr,
                                f:separator { fill_horizontal = 1 },
                                currLabel,
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
                                title = "Click 'Verify with Wiki' to check names against Wikidata " ..
                                        "(counties and municipalities; falls back to pattern analysis " ..
                                        "when offline). Conflicts shows '✓' for confirmed names " ..
                                        "or a suggested canonical name when a mismatch is found. " ..
                                        "Set Action = Change, Change manually, or Delete " ..
                                        "for entries you want to update, then click Update " ..
                                        "in List Overview.",
                                width           = CONTENT_W_MN,
                                height_in_lines = 3,
                        },
                        f:static_text {
                                title = "Click Save to store the results as version " ..
                                        nextVer .. " of the " .. cname .. " list" ..
                                        ( GitHubSync.isConfigured()
                                          and " and push to GitHub."
                                          or  ". To push to GitHub, add a token in Plug-in Manager." ),
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
        -- Tab 0 — Keyword Builder
        ------------------------------------------------------------------------

        local function buildBuilderPanel()

                -- Country column
                -- Show only enabled countries; if none are enabled, show all.
                local anyEnabled = false
                for _, c in ipairs( COUNTRIES ) do
                        if props[ c.id .. "_enabled" ] then anyEnabled = true break end
                end

                local byContinent = {}
                for _, country in ipairs( COUNTRIES ) do
                        if not anyEnabled or props[ country.id .. "_enabled" ] then
                                local cont = country.continent or "Other"
                                if not byContinent[ cont ] then byContinent[ cont ] = {} end
                                local cl = byContinent[ cont ]
                                cl[ #cl + 1 ] = country
                        end
                end
                -- Sort countries alphabetically within each continent.
                for _, cl in pairs( byContinent ) do
                        table.sort( cl, function( a, b ) return a.name:lower() < b.name:lower() end )
                end
                -- Use fixed order; continents without countries still get a button.
                local continents = CONTINENT_ORDER

                local countryChildren = {
                        spacing = f:control_spacing(),
                        width   = KB_COL_W_COUNTRY - 20,
                        f:static_text { title = "Country", font = "<system/bold>" },
                        f:static_text {
                                title = "Select a country (Select More) and check \226\128\156Include\226\128\157\nto export keywords.",
                                font  = "<system>",
                                width = KB_COL_W_COUNTRY - 20,
                        },
                        f:separator { fill_horizontal = 1 },
                        f:spacer { height = 2 },
                }

                for _, cont in ipairs( continents ) do
                        local contLower = cont:lower():gsub( "%s+", "_" )
                        local contKey   = contLower .. "_expanded"

                        countryChildren[ #countryChildren + 1 ] = f:push_button {
                                bind_to_object = props,
                                title = LrView.bind {
                                        key       = contKey,
                                        transform = function( v )
                                                return (v and "\226\150\178" or "\226\150\188") .. "   " .. cont
                                        end,
                                },
                                action = function()
                                        -- Accordion: close all other continents first
                                        for _, otherCont in ipairs( continents ) do
                                                local otherKey = otherCont:lower():gsub( "%s+", "_" ) .. "_expanded"
                                                if otherKey ~= contKey then
                                                        props[ otherKey ] = false
                                                end
                                        end
                                        props[ contKey ] = not props[ contKey ]
                                        switchTab( TAB_IDS.KB )
                                end,
                        }

                        -- Only build country rows when this continent is expanded.
                        -- Rebuild-on-click (switchTab above) ensures correct layout:
                        -- invisible elements are never created, so LR SDK space-reservation
                        -- for visible=false is completely avoided.
                        if props[ contKey ] then
                                local contCountries = byContinent[ cont ] or {}

                                local function makeCountryRow( country )
                                        local cid          = country.id
                                        local includeKey   = cid .. "_include"
                                        local switchAction = makeSwitchAction( cid, country )
                                        return f:column {
                                                fill_horizontal = 1,
                                                f:row {
                                                        fill_horizontal = 1,
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
                                                        f:static_text {
                                                                title           = country.name,
                                                                fill_horizontal = 1,
                                                        },
                                                        f:spacer { width = 12 },
                                                        f:push_button {
                                                                title  = "Select More",
                                                                action = switchAction,
                                                        },
                                                        f:checkbox {
                                                                bind_to_object = props,
                                                                title          = "Include",
                                                                value          = LrView.bind( includeKey ),
                                                        },
                                                        f:spacer { width = 20 },
                                                },
                                        }
                                end

                                if #contCountries > 4 then
                                        -- Wrap in a scrolled_view showing 4 rows; scroll for the rest.
                                        -- Height = 4 rows × 26 px per row (button height + spacing).
                                        local innerSpec = { spacing = f:control_spacing() }
                                        for _, country in ipairs( contCountries ) do
                                                innerSpec[ #innerSpec + 1 ] = makeCountryRow( country )
                                        end
                                        countryChildren[ #countryChildren + 1 ] = f:scrolled_view {
                                                height              = 107,
                                                width               = KB_COL_W_COUNTRY - 20,
                                                horizontal_scroller = false,
                                                vertical_scroller   = false,
                                                background_color    = LrColor( 0.835, 0.835, 0.835 ),
                                                f:column( innerSpec ),
                                        }
                                else
                                        for _, country in ipairs( contCountries ) do
                                                countryChildren[ #countryChildren + 1 ] = makeCountryRow( country )
                                        end
                                end
                        end

                        countryChildren[ #countryChildren + 1 ] = f:spacer { height = 4 }
                end

                local countryScrollView = f:scrolled_view {
                        height              = 481,
                        width               = KB_COL_W_COUNTRY - 20,
                        horizontal_scroller = false,
                        background_color    = LrColor( 0.835, 0.835, 0.835 ),
                        border_color        = LrColor( 0.835, 0.835, 0.835 ),
                        border_width        = 0,
                        f:column( countryChildren ),
                }

                -- County section — exact-count approach (v0.9.77).
                -- LR SDK: visible=false on ANY element type preserves layout space.
                -- The only fix is to build EXACTLY the right number of rows at construction
                -- time. We do this by reading the active country's county list from
                -- props (already populated by loadCountryState before buildBuilderPanel
                -- is called). When the user switches country, makeSwitchAction calls
                -- switchTab(TAB_IDS.KB), which closes and rebuilds the panel via the
                -- while-keepOpen dialog loop — ensuring the new country's exact count.
                -- activePanelCountry is the shared upvalue set by makeSwitchAction
                -- (and initialised after the first loadCountryState call).  Using it
                -- directly avoids any prop-timing race with props.active_country_id.
                local activeCountry = activePanelCountry or COUNTRIES[1]
                local names  = activeCountry.countyNames  or {}
                local riList = activeCountry.remoteIslandNames or {}
                local n   = #names
                local riN = #riList

                local countyItems = {
                        bind_to_object  = props,
                        spacing         = 4,
                        fill_horizontal = 1,
                }
                for i = 1, n do
                        countyItems[ #countyItems + 1 ] = f:checkbox {
                                bind_to_object = props,
                                font           = "<system/small>",
                                title          = LrView.bind( "county_name_" .. i ),
                                value          = LrView.bind( "div_value_"   .. i ),
                        }
                end
                if riN > 0 then
                        countyItems[ #countyItems + 1 ] = f:separator { fill_horizontal = 1 }
                        for i = 1, riN do
                                countyItems[ #countyItems + 1 ] = f:checkbox {
                                        bind_to_object = props,
                                        font           = "<system/small>",
                                        title          = LrView.bind( "ri_name_"  .. i ),
                                        value          = LrView.bind( "ri_value_" .. i ),
                                }
                        end
                end

                -- Explicit height instead of fill_vertical.  fill_vertical=1 on an
                -- f:scrolled_view proved unreliable across v0.9.74–v0.9.81 (the
                -- scrolled_view locks its content-based height at construction and
                -- does not expand to fill the parent column, regardless of the
                -- fill chain).  KB_COUNTY_LIST_H is sized so the county list fills
                -- down to the version text, matching the tall left country column.
                -- border_color/border_width are not honoured by LR SDK for scrolled_view
                -- (the OS draws the frame independently); left here as documentation.
                -- scrolled_view width = group_box width minus internal padding (~10 px each side).
                -- This makes the group_box total outer width match KB_COL_W_COUNTY.
                -- fill_horizontal=1 pushes the group_box wider (LR SDK limitation), so
                -- an explicit inner width is required.
                local countyListContainer = f:scrolled_view {
                        bind_to_object      = props,
                        height              = KB_COUNTY_LIST_H,
                        width               = KB_COL_W_COUNTY - 20,
                        horizontal_scroller = false,
                        background_color    = LrColor( 0.835, 0.835, 0.835 ),
                        border_color        = LrColor( 0.835, 0.835, 0.835 ),
                        border_width        = 0,
                        f:column( countyItems ),
                }

                -- County group_box (matches the left country column and right
                -- features column, which are also group_boxes).  Its height is
                -- driven by the fixed-height scrolled_view child, so no
                -- fill_vertical is needed — that mechanism was unreliable here.
                local countyGroupBox = f:group_box {
                        bind_to_object = props,
                        title          = "",
                        spacing        = f:control_spacing(),
                        width          = KB_COL_W_COUNTY,
                        f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( "active_divisions_label" ),
                                font           = "<system/bold>",
                        },
                        f:static_text {
                                title = "Select which information to include\nand how detailed.",
                                font  = "<system>",
                        },
                        f:separator { fill_horizontal = 1 },
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
                        f:checkbox {
                                bind_to_object = props,
                                font           = "<system>",
                                title          = LrView.bind( "active_select_all_label" ),
                                value          = LrView.bind( "div_select_all" ),
                        },
                        countyListContainer,
                        f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( "active_version_label" ),
                                text_color     = dimColor,
                        },
                }

                -- Feature selections
                local featuresContent = f:column {
                        bind_to_object  = props,
                        spacing         = f:control_spacing(),
                        fill_horizontal = 1,
                        f:static_text {
                                bind_to_object = props,
                                title          = LrView.bind( "active_selections_label" ),
                                font           = "<system/bold>",
                        },
                        f:static_text {
                                title = "Use the sliders below to set max count or\nmin elevation (only for mountains).",
                                font  = "<system>",
                        },
                        f:separator { fill_horizontal = 1 },
                        f:checkbox {
                                bind_to_object = props,
                                font           = "<system>",
                                title          = "Select All",
                                value          = LrView.bind( "feat_select_all" ),
                        },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="National Park",  value=LrView.bind("feat_national_parks") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_national_parks_max",  1, LrView.bind("active_np_max"), "" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Nature Reserve", value=LrView.bind("feat_nature_reserves") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_nature_reserves_max", 1, LrView.bind("active_nr_max"), "" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Mountain",       value=LrView.bind("feat_mountains") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_mainland_cutoff", 500, LrView.bind("active_mountain_max"), "m" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Fjord",          value=LrView.bind("feat_fjords") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_fjords_max",     1, LrView.bind("active_fj_max"), "" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Lake",           value=LrView.bind("feat_lakes") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_lakes_max",      1, LrView.bind("active_lk_max"), "" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="River",          value=LrView.bind("feat_rivers") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_rivers_max",     1, LrView.bind("active_rv_max"), "" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Island",         value=LrView.bind("feat_islands") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_islands_max",    1, LrView.bind("active_is_max"), "" ) },
                        f:row { fill_horizontal = 1, spacing = f:label_spacing(),
                                f:checkbox { bind_to_object=props, font="<system>", title="Viewpoint",      value=LrView.bind("feat_viewpoints") },
                                f:spacer { fill_horizontal = 1 },
                                inlineSlider( "feat_viewpoints_max", 1, LrView.bind("active_vp_max"), "" ) },
                }

                -- Save + Generate row
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
                        f:push_button {
                                title  = "Generate",
                                action = doGenerate,
                        },
                }

                return f:column {
                        bind_to_object  = props,
                        spacing         = f:control_spacing(),
                        fill_horizontal = 1,
                        f:static_text {
                                title = "Select a country (Select More), configure sections and areas, "
                                     .. "check Include to add it to the export, then click Generate.",
                        },
                        f:row {
                                spacing         = f:label_spacing() * 2,
                                fill_horizontal = 1,
                                f:column {
                                        background_color = LrColor( 0.94, 0.94, 0.94 ),
                                        f:group_box {
                                                title   = "",
                                                spacing = f:control_spacing(),
                                                width   = KB_COL_W_COUNTRY,
                                                countryScrollView,
                                        },
                                },
                                countyGroupBox,
                                f:column {
                                        spacing         = f:control_spacing(),
                                        fill_horizontal = 1,
                                        f:group_box {
                                                title           = "",
                                                fill_horizontal = 1,
                                                featuresContent,
                                        },
                                        saveRow,
                                },
                        },
                }

        end  -- buildBuilderPanel

        ------------------------------------------------------------------------
        -- Tab 0 — Intro  (world-map welcome panel)
        ------------------------------------------------------------------------

        local function buildIntroPanel()
                -- Generate (or retrieve cached) world-map PNG with current enabled colours.
                local enabledSet = {}
                for _, c in ipairs( COUNTRIES ) do
                        if props[ c.id .. "_enabled" ] then enabledSet[ c.id ] = true end
                end
                local mapPath = WorldMap.generate( enabledSet )

                local mapItem
                if mapPath then
                        mapItem = f:picture {
                                value  = mapPath,
                                width  = 900,
                                height = 450,
                        }
                else
                        mapItem = f:static_text {
                                title = "(Map image could not be generated)",
                                width = 900,
                        }
                end

                return f:column {
                        bind_to_object = props,
                        spacing        = f:control_spacing(),
                        f:spacer { height = 8 },
                        f:row {
                                f:spacer { fill_horizontal = 1 },
                                mapItem,
                                f:spacer { fill_horizontal = 1 },
                        },
                        f:row {
                                f:spacer { fill_horizontal = 1 },
                                f:static_text {
                                        title = "Map of country geography keywords - Red: currently enabled (On) - Blue: supported countries",
                                        font  = "<system/small>",
                                },
                                f:spacer { fill_horizontal = 1 },
                        },
                        f:spacer { height = 6 },
                        f:separator { fill_horizontal = 1 },
                        f:spacer { height = 4 },
                        f:static_text {
                                title = "Geography Keyword Builder",
                                font  = "<system/bold>",
                        },
                        f:spacer { height = 2 },
                        f:static_text {
                                title           = "Welcome to the Geography Keyword Builder plugin for Adobe Lightroom Classic. "
                                                .. "This plugin helps you create and manage hierarchical geographic keyword lists "
                                                .. "for your photo library. "
                                                .. "Use the tabs above to build keyword lists (Keyword List Builder), "
                                                .. "manage country data files (List Overview), verify keyword data "
                                                .. "(Verification Monitor), or read the documentation (Help).",
                                width           = CONTENT_W,
                                height_in_lines = 4,
                        },
                        f:spacer { height = 2 },
                        f:static_text {
                                title           = "Click below to open a fully interactive map in your browser.",
                                width           = CONTENT_W,
                                height_in_lines = 1,
                        },
                        f:spacer { height = 6 },
                        f:row {
                                f:spacer { fill_horizontal = 1 },
                                f:push_button {
                                        title = "Show Interactive Map in Browser",
                                        action = function()
                                                LrTasks.startAsyncTask( function()
                                                        local currentEnabled = {}
                                                        for _, c in ipairs( COUNTRIES ) do
                                                                if props[ c.id .. "_enabled" ] then
                                                                        currentEnabled[ c.id ] = true
                                                                end
                                                        end
                                                        local htmlPath = WorldMap.generateHTML( currentEnabled )
                                                        if htmlPath then
                                                                local url
                                                                if WIN_ENV then
                                                                        url = "file:///" .. htmlPath:gsub( "\\", "/" )
                                                                else
                                                                        url = "file://" .. htmlPath
                                                                end
                                                                LrHttp.openUrlInBrowser( url )
                                                        end
                                                end )
                                        end,
                                },
                                f:spacer { fill_horizontal = 1 },
                        },
                }
        end  -- buildIntroPanel

        ------------------------------------------------------------------------
        -- Dialog loop
        ------------------------------------------------------------------------

        local keepOpen = true
        while keepOpen do

                switching = true
                props.activeTabId = currentDialog
                switching = false

                local placeholder = f:column { f:spacer { height = 5 } }

                local panelINTRO = ( currentDialog == TAB_IDS.INTRO ) and buildIntroPanel()  or placeholder
                local panelKB    = ( currentDialog == TAB_IDS.KB    ) and buildBuilderPanel() or placeholder
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
                                title      = "Intro",
                                identifier = TAB_IDS.INTRO,
                                f:column { width = CONTENT_W, spacing = f:control_spacing(), panelINTRO },
                        },
                        f:tab_view_item {
                                title      = "Keyword List Builder",
                                identifier = TAB_IDS.KB,
                                f:column { spacing = f:control_spacing(), fill_horizontal = 1, panelKB },
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

                -- Copyright footer shown left-aligned on the same line as the action buttons.
                -- accessoryView is the SDK mechanism for placing content in the button bar.
                local info   = dofile( LrPathUtils.child( _PLUGIN.path, "Info.lua" ) )
                local pv     = info.VERSION
                local pvStr  = string.format( "%d.%d.%d.%d", pv.major, pv.minor, pv.revision, pv.build )
                local footer = f:static_text {
                        title      = string.char( 194, 169 ) .. " Liodden Media " .. os.date( "%Y" ) .. " - version " .. pvStr,
                        text_color = LrColor( 0.45, 0.45, 0.45 ),
                        font       = { name = "<system>", size = 11 },
                        height     = 12,
                }

                -- On the Monitor (with a country selected): actionVerb = "Save" (blue,
                -- Enter-key default), cancelVerb = "Cancel" — both appear on the right side
                -- of the button bar together.
                -- On all other tabs: actionVerb = "Close", no cancel button.
                local result = LrDialogs.presentModalDialog {
                        title         = "Geography Keyword Builder",
                        contents      = contents,
                        actionVerb    = showSave and "Save" or "Close",
                        cancelVerb    = showSave and "Cancel" or "< exclude >",
                        accessoryView = footer,
                }

                if result == TAB_IDS.INTRO or result == TAB_IDS.KB or result == TAB_IDS.OV or result == TAB_IDS.MN or result == TAB_IDS.HLP then
                        -- Tab switch triggered by observer or switchTab() call.
                        -- If leaving the Monitor tab, flush any unsaved action popup changes
                        -- to prefs so Update can read them even if Save was not clicked.
                        if currentDialog == TAB_IDS.MN then
                                local cid = props.verify_country_id
                                if cid then persistVerToPrefs( cid ) end
                        end
                        currentDialog = result

                elseif showSave and result == "ok" then
                        -- Save clicked on Monitor tab (actionVerb = "Save" → result "ok").
                        local cid = props.verify_country_id
                        if cid then
                                local newVer = computeNextVersion( cid, prefs )
                                prefs[ "list_version_" .. cid ] = newVer
                                props[ "list_version_" .. cid ] = newVer
                                prefs[ "verified_" .. cid ]     = os.date( "%Y-%m-%d %H:%M" )
                                props[ "verified_" .. cid ]     = prefs[ "verified_" .. cid ]
                                -- Capture any Action changes made after Verify (popup-only edits).
                                persistVerToPrefs( cid )
                                local cname = getCountryName( cid )

                                if GitHubSync.isConfigured() then
                                        -- Build the payload now (on the UI thread, where props are
                                        -- valid) then push from an async task (LrHttp requires one).
                                        local payload = buildVerifiedJson( cid, newVer )
                                        local path    = GitHubSync.verifiedPath( cid )
                                        local pretty  = dkjson.encode( payload, { indent = true } )
                                        LrTasks.startAsyncTask( function()
                                                local ok, info = GitHubSync.writeFile(
                                                        path, pretty,
                                                        "Verify " .. cname .. " → " .. newVer )
                                                if ok then
                                                        LrDialogs.message(
                                                                "Saved & pushed — " .. cname,
                                                                "Version " .. newVer .. " saved locally and pushed " ..
                                                                "to GitHub:\n" .. path ..
                                                                ( info and ( "\n\nCommit: " .. info ) or "" ),
                                                                "info" )
                                                else
                                                        LrDialogs.message(
                                                                "Saved locally — GitHub push FAILED — " .. cname,
                                                                "Version " .. newVer .. " was saved on this machine, " ..
                                                                "but the GitHub push failed:\n" .. tostring( info ) ..
                                                                "\n\nCheck your token in File ▸ Plug-in Manager.",
                                                                "warning" )
                                                end
                                        end )
                                else
                                        LrDialogs.message(
                                                "Saved — " .. cname,
                                                "Verification results saved.\n\n" ..
                                                "The " .. cname .. " list is now listed as version " ..
                                                newVer .. " in List Overview.\n\n" ..
                                                "(GitHub sync is off — set a token in Plug-in Manager to " ..
                                                "push verification files automatically.)",
                                                "info" )
                                end
                        end
                        currentDialog = TAB_IDS.OV   -- return to List Overview after Save

                else
                        -- "Close" (non-Monitor, actionVerb "ok") or "Cancel" (Monitor,
                        -- cancelVerb "cancel"), or any other dismiss → exit loop.
                        currentDialog = result
                        keepOpen = false
                end

        end


end )
