--[[
        Extensions.lua — Extensions panel for LR-Geography-Builder (Fase 1)

        Exports a single function:
            Extensions.buildPanel(f, props, prefs, pluginPath, switchTab, TAB_IDS)

        Returns an f:column panel node with a 4-column table (Area, File size,
        Buy Now, Activate). Users can buy specialised GPS-mapped keyword packs
        for selected regions and activate them with a licence key.

        Activation validates the key against the License Manager REST API on
        liodden.com, downloads the .lua file into the plugin's extensions/ dir,
        and stores activation status in prefs.

        The panel is rebuilt each time the tab is entered (like all other panels
        in ListVerification.lua's while-loop), so activation state is read fresh
        from prefs at build time — no live binding needed.
--]]

local LrView            = import 'LrView'
local LrTasks           = import 'LrTasks'
local LrDialogs         = import 'LrDialogs'
local LrColor           = import 'LrColor'
local LrPathUtils       = import 'LrPathUtils'
local LrFileUtils       = import 'LrFileUtils'
local LrStringUtils     = import 'LrStringUtils'

-- ── Lazy LrHttp ──────────────────────────────────────────────────────────────
-- Importing LrHttp at top level initialises the HTTP stack (proxy detection,
-- socket setup) during plugin registration, causing a ~60–76 second delay.
-- Defer the import until a network call is actually needed.
local _LrHttp = nil
local function http()
    if _LrHttp == nil then _LrHttp = import 'LrHttp' end
    return _LrHttp
end

-- Lazy loader for GitHubSync — only loaded when user clicks "Test connection",
-- not at panel render time (avoids loading dkjson/lpeg during tab switch).
local _GitHubSync = nil
local function ghSync( pluginPath )
    if _GitHubSync == nil then
        _GitHubSync = dofile( LrPathUtils.child( pluginPath, "GitHubSync.lua" ) )
    end
    return _GitHubSync
end

local Extensions = {}

-- ── Extension catalogue ──────────────────────────────────────────────────────
local EXTENSIONS = {
        { id = "svalbard",      name = "Svalbard GPS Extension",         description = "98 GPS-mapped keyword names · Norway › Svalbard",            filesize = "42 KB", buy_url = "https://liodden.com/extensions/svalbard/",         pref_key = "ext_activated_svalbard",      filename = "svalbard_gps.lua",     coming_soon = false },
        { id = "south_georgia", name = "South Georgia GPS Extension",     description = "GPS-mapped keyword names · United Kingdom › South Georgia",  filesize = "—",     buy_url = "https://liodden.com/extensions/south-georgia/",    pref_key = "ext_activated_south_georgia", filename = "south_georgia_gps.lua", coming_soon = true  },
        { id = "falklands",     name = "Falkland Islands GPS Extension",  description = "GPS-mapped keyword names · United Kingdom › Falkland Islands",filesize = "—",     buy_url = "https://liodden.com/extensions/falkland-islands/", pref_key = "ext_activated_falklands",     filename = "falklands_gps.lua",    coming_soon = true  },
        { id = "antarctica",    name = "Antarctica GPS Extension",        description = "GPS-mapped keyword names · Antarctica",                      filesize = "—",     buy_url = "https://liodden.com/extensions/antarctica/",       pref_key = "ext_activated_antarctica",    filename = "antarctica_gps.lua",   coming_soon = true  },
}

-- Column widths (total ≈ CONTENT_W_MN = 999 px)
local COL_AREA  = 420
local COL_SIZE  = 80
local COL_BUY   = 100
local COL_ACT   = 380

-- License Manager REST API credentials (placeholders — real values set later)
local API_CK = "ck_placeholder"
local API_CS = "cs_placeholder"

-- ── Activation logic ─────────────────────────────────────────────────────────
local function activateExtension( ext, props, prefs, pluginPath, switchTab, TAB_IDS )
        -- 1. Read key from edit field
        local rawKey = props[ "ext_key_" .. ext.id ]
        -- 2. Trim + validate
        local key = rawKey and LrStringUtils.trimWhitespace( tostring( rawKey ) ) or ""
        if key == "" then
                LrDialogs.message( "Manglende lisensnøkkel", "Skriv inn lisensnøkkelen din før du aktiverer.", "warning" )
                return
        end

        -- 3. Network work off the main thread
        LrTasks.startAsyncTask( function()
                local Base64 = dofile( LrPathUtils.child( pluginPath, "Base64.lua" ) )
                local json   = dofile( LrPathUtils.child( pluginPath, "dkjson.lua" ) )

                -- 4. POST to the License Manager activate endpoint
                local url = "https://liodden.com/wp-json/lmfwc/v2/licenses/activate/" .. key
                local headers = {
                        { field = "Authorization", value = "Basic " .. Base64.encode( API_CK .. ":" .. API_CS ) },
                        { field = "Content-Type",  value = "application/json" },
                }

                local body, respHeaders = http().post( url, "", headers )

                -- 5. HTTP / transport error
                if not body then
                        LrDialogs.message(
                                "Aktivering feilet",
                                "Kunne ikke kontakte aktiveringsserveren. Sjekk internettforbindelsen og prøv igjen.",
                                "error"
                        )
                        return
                end

                local status = respHeaders and respHeaders.status or nil

                -- 6. Try to parse the JSON response
                local parsed = nil
                if body and body ~= "" then
                        parsed = json.decode( body )
                end

                -- Server not yet configured (non-200 or missing/unsuccessful payload).
                local ok       = parsed and parsed.success == true
                local download = ok and parsed.data and parsed.data.download_url or nil

                if ( status and status ~= 200 ) or not ok then
                        -- Save the key anyway so activation works once the server is live.
                        prefs[ ext.pref_key ] = key
                        LrDialogs.message(
                                "Serveren er ikke konfigurert ennå",
                                "Serveren er ikke satt opp ennå. Nøkkelen din er lagret — aktivering vil fungere fullt ut når serveren er oppe.",
                                "info"
                        )
                        if switchTab and TAB_IDS then switchTab( TAB_IDS.EXT ) end
                        return
                end

                -- 7. Download the extension .lua file into extensions/
                if download then
                        local extDir = LrPathUtils.child( pluginPath, "extensions" )
                        if not LrFileUtils.exists( extDir ) then
                                LrFileUtils.createDirectory( extDir )
                        end

                        local fileBytes, getHeaders = http().get( download )
                        local getStatus = getHeaders and getHeaders.status or nil

                        if fileBytes and ( not getStatus or getStatus == 200 ) then
                                local destPath = LrPathUtils.child( extDir, ext.filename )
                                local fh = io.open( destPath, "wb" )
                                if fh then
                                        fh:write( fileBytes )
                                        fh:close()
                                else
                                        LrDialogs.message(
                                                "Kunne ikke lagre filen",
                                                "Aktiveringen lyktes, men extension-filen kunne ikke lagres i plugin-mappen.",
                                                "error"
                                        )
                                        return
                                end
                        else
                                LrDialogs.message(
                                        "Nedlasting feilet",
                                        "Aktiveringen lyktes, men extension-filen kunne ikke lastes ned. Prøv igjen senere.",
                                        "error"
                                )
                                return
                        end
                end

                -- 8. Store the key (truthy = activated)
                prefs[ ext.pref_key ] = key

                LrDialogs.message(
                        "Extension aktivert",
                        ext.name .. " er nå aktivert og klar til bruk.",
                        "info"
                )

                -- 9. Rebuild the panel to show the green "✓ Activated" state
                if switchTab and TAB_IDS then switchTab( TAB_IDS.EXT ) end
        end )
end

-- ── Row builder ──────────────────────────────────────────────────────────────
local function buildRow( f, ext, props, prefs, pluginPath, switchTab, TAB_IDS )
        local isActivated = prefs[ ext.pref_key ] and true or false

        -- Col 1 — Area (bold name + small italic description)
        local areaCol = f:column {
                width = COL_AREA,
                f:static_text {
                        title    = ext.name,
                        font     = "<system/bold>",
                        width    = COL_AREA,
                },
                f:static_text {
                        title      = ext.description,
                        font       = "<system/small>",
                        text_color = LrColor( 0.4, 0.4, 0.4 ),
                        width      = COL_AREA,
                },
        }

        -- Col 2 — File size
        local sizeCol = f:column {
                width = COL_SIZE,
                f:static_text { title = ext.filesize, width = COL_SIZE },
        }

        -- Col 3 — Buy Now
        local buyBtn
        if ext.coming_soon then
                buyBtn = f:push_button {
                        title   = "Coming soon",
                        enabled = false,
                        width   = COL_BUY,
                }
        else
                buyBtn = f:push_button {
                        title  = "Buy Now",
                        width  = COL_BUY,
                        action = function()
                                http().openUrlInBrowser( ext.buy_url )
                        end,
                }
        end
        local buyCol = f:column { width = COL_BUY, buyBtn }

        -- Col 4 — Activate (field + button, or green "✓ Activated")
        local actContent
        if isActivated then
                actContent = f:static_text {
                        title      = "✓ Activated",
                        font       = "<system/bold>",
                        text_color = LrColor( 0.1, 0.6, 0.1 ),
                        width      = COL_ACT,
                }
        else
                -- initialise the binding key
                if props[ "ext_key_" .. ext.id ] == nil then
                        props[ "ext_key_" .. ext.id ] = ""
                end
                actContent = f:row {
                        f:edit_field {
                                bind_to_object = props,
                                value          = LrView.bind( "ext_key_" .. ext.id ),
                                width          = 200,
                                enabled        = not ext.coming_soon,
                                placeholder_string = "Lisensnøkkel",
                        },
                        f:push_button {
                                title   = "Activate",
                                enabled = not ext.coming_soon,
                                action  = function()
                                        activateExtension( ext, props, prefs, pluginPath, switchTab, TAB_IDS )
                                end,
                        },
                }
        end
        local actCol = f:column { width = COL_ACT, actContent }

        return f:row {
                fill_horizontal = 1,
                spacing = f:label_spacing(),
                areaCol, sizeCol, buyCol, actCol,
        }
end

-- ── GitHub Sync section ───────────────────────────────────────────────────────
-- Moved from GitHubSettings.lua / LrPluginInfoProvider (which caused a ~75 s
-- delay when adding the plugin).  Rendered as the bottom section of the
-- Extensions tab instead.
local function buildGitHubSection( f, props, prefs, pluginPath )
        local bind = LrView.bind

        -- Seed prefs defaults (only if the user has never set them).
        if prefs.gh_owner == nil or prefs.gh_owner == "" then
                prefs.gh_owner = "Liodden73"
        end
        if prefs.gh_repo == nil or prefs.gh_repo == "" then
                prefs.gh_repo = "LR-Keywords-Geography"
        end
        if prefs.gh_branch == nil or prefs.gh_branch == "" then
                prefs.gh_branch = "main"
        end
        if prefs.gh_pathPrefix == nil or prefs.gh_pathPrefix == "" then
                prefs.gh_pathPrefix = "verified"
        end
        -- Status label — only reset if not already set so it survives tab switches.
        if props.gh_status == nil then
                props.gh_status = "GitHub Sync ready — click 'Test connection' to verify."
        end

        local function orDefault( v, default )
                if v == nil or v == "" then return default end
                return v
        end

        return {
                f:spacer { height = 16 },
                f:separator { fill_horizontal = 1 },
                f:spacer { height = 8 },
                f:static_text {
                        title = "GitHub Sync",
                        font  = "<system/bold>",
                },
                f:static_text {
                        title      = "Reading verification files from a PUBLIC repo works without a token. " ..
                                     "A GitHub personal-access token (with repo / Contents: write scope) is " ..
                                     "only required to SAVE (push) changes back to GitHub — writing always " ..
                                     "needs a token, even on a public repo. The token is stored only on this " ..
                                     "machine and is never included in the distributed plugin.",
                        text_color = LrColor( 0.4, 0.4, 0.4 ),
                        width      = 640,
                        height_in_lines = 3,
                },
                f:row {
                        f:static_text { title = "Token:", width = 90 },
                        f:edit_field {
                                value          = bind { object = prefs, key = "gh_token" },
                                width_in_chars = 44,
                                immediate      = true,
                        },
                },
                f:row {
                        f:static_text { title = "Owner:", width = 90 },
                        f:edit_field {
                                value          = bind { object = prefs, key = "gh_owner" },
                                width_in_chars = 30,
                                immediate      = true,
                        },
                },
                f:row {
                        f:static_text { title = "Repository:", width = 90 },
                        f:edit_field {
                                value          = bind { object = prefs, key = "gh_repo" },
                                width_in_chars = 30,
                                immediate      = true,
                        },
                },
                f:row {
                        f:static_text { title = "Branch:", width = 90 },
                        f:edit_field {
                                value          = bind { object = prefs, key = "gh_branch" },
                                width_in_chars = 16,
                                immediate      = true,
                        },
                },
                f:row {
                        f:static_text { title = "Folder:", width = 90 },
                        f:edit_field {
                                value          = bind { object = prefs, key = "gh_pathPrefix" },
                                width_in_chars = 16,
                                immediate      = true,
                        },
                        f:static_text { title = "(path in repo for verified/<Country>.json)" },
                },
                f:row {
                        f:push_button {
                                title  = "Test connection",
                                action = function()
                                        LrTasks.startAsyncTask( function()
                                                local snap = {
                                                        token  = prefs.gh_token or "",
                                                        owner  = orDefault( prefs.gh_owner,      "Liodden73" ),
                                                        repo   = orDefault( prefs.gh_repo,       "LR-Keywords-Geography" ),
                                                        branch = orDefault( prefs.gh_branch,     "main" ),
                                                        prefix = orDefault( prefs.gh_pathPrefix, "verified" ),
                                                }
                                                local ok, msg = ghSync( pluginPath ).test( snap )
                                                if ok then
                                                        props.gh_status = "Connected: " .. tostring( msg )
                                                        LrDialogs.message( "GitHub connection OK",
                                                                "Connected to " .. tostring( msg ) .. ".", "info" )
                                                else
                                                        props.gh_status = "Not connected."
                                                        LrDialogs.message( "GitHub connection failed",
                                                                tostring( msg ), "warning" )
                                                end
                                        end )
                                end,
                        },
                        f:static_text {
                                title           = bind { object = props, key = "gh_status" },
                                fill_horizontal = 1,
                        },
                },
        }
end

-- ── Public API ───────────────────────────────────────────────────────────────
function Extensions.buildPanel( f, props, prefs, pluginPath, switchTab, TAB_IDS )
        local children = {}

        children[ #children + 1 ] = f:static_text {
                title = "Extensions",
                font  = "<system/bold>",
        }
        children[ #children + 1 ] = f:static_text {
                title      = "Kjøp og aktiver spesialpakker med GPS-mappede stedsnavn for utvalgte regioner.",
                text_color = LrColor( 0.4, 0.4, 0.4 ),
        }
        children[ #children + 1 ] = f:spacer { height = 12 }

        -- Header row
        children[ #children + 1 ] = f:row {
                fill_horizontal = 1,
                spacing = f:label_spacing(),
                f:static_text { title = "Area",      font = "<system/bold>", width = COL_AREA },
                f:static_text { title = "File size", font = "<system/bold>", width = COL_SIZE },
                f:static_text { title = "Buy Now",   font = "<system/bold>", width = COL_BUY  },
                f:static_text { title = "Activate",  font = "<system/bold>", width = COL_ACT  },
        }
        children[ #children + 1 ] = f:separator { fill_horizontal = 1 }
        children[ #children + 1 ] = f:spacer { height = 8 }

        for i, ext in ipairs( EXTENSIONS ) do
                children[ #children + 1 ] = buildRow( f, ext, props, prefs, pluginPath, switchTab, TAB_IDS )
                if i < #EXTENSIONS then
                        children[ #children + 1 ] = f:spacer { height = 8 }
                end
        end

        -- GitHub Sync section (moved from GitHubSettings.lua / LrPluginInfoProvider
        -- to eliminate the ~75 s plugin-registration delay)
        children[ #children + 1 ] = f:spacer { height = 20 }
        table.insert( children, buildGitHubSection( f, props, prefs, pluginPath ) )

        children.spacing = f:control_spacing()
        return f:column( children )
end

return Extensions
