--[[
        GitHubSettings.lua — Geography Keyword Builder

        Adds a "GitHub Sync" section to the plugin's page in
        File ▸ Plug-in Manager.  This is where the plugin author enters the
        GitHub personal-access token used to read/write the per-country
        verification files (verified/<Country>.json).

        The token and repo settings are stored in this machine's plugin
        preferences only — they are NOT part of the distributed plugin.  A
        customer who installs the plugin without entering a token simply has the
        sync features disabled.

        Registered from Info.lua via LrPluginInfoProvider.

        ── v0.9.229 DIAGNOSTIC: lazy imports at module load ──────────────────────
        Timing log (4) proved the ~78 s Plugin-Manager delay happens at MODULE
        LOAD of this file (the "Add"/registration path), NOT at dialog open. To
        find out WHAT in this module costs those seconds, this version imports NO
        Lightroom SDK module at the top level except LrPathUtils (a pure path
        utility, used only for the timing log). LrView / LrPrefs / LrTasks /
        LrDialogs are now imported lazily inside the functions that need them.

          • If "Add" is now FAST → one of those top-level imports triggered a
            synchronous init (e.g. socket/proxy) at registration. We can then keep
            GitHub Sync in Plug-in Manager with no delay (goal C achieved).
          • If "Add" is STILL ~78 s → the delay is caused by the mere presence of
            LrPluginInfoProvider itself (Lightroom's own handling), independent of
            this file's contents — and we must choose another placement.

        The [PluginMgr] markers below timestamp both module load and the page
        render so the next timing log pinpoints exactly where any delay remains.
]]

-- These SDK imports MUST be resolved at top-level module load. Deferring them into
-- sectionsForTopOfDialog (attempted in the 0.9.229 diagnostic) made Lightroom fail
-- with "An error occurred while attempting to load this plug-in", because Lightroom
-- runs sectionsForTopOfDialog while rendering the Plugin Manager page and needs the
-- imports already available. LrHttp stays lazy (loaded inside GitHubSync only).
local LrView      = import 'LrView'
local LrPrefs     = import 'LrPrefs'
local LrDialogs   = import 'LrDialogs'
local LrTasks     = import 'LrTasks'
local LrPathUtils = import 'LrPathUtils'

-- ── Diagnostic timing log (shared with ListVerification.lua) ──────────────────
local _tLog = LrPathUtils.child(
        LrPathUtils.getStandardFilePath( "documents" ),
        "LR-Geography-Builder-timing.log" )
local function tlog( msg )
        pcall( function()
                local fh = io.open( _tLog, "a" )
                if fh then
                        fh:write( os.date( "%Y-%m-%d %H:%M:%S" ) .. "  [PluginMgr] " .. msg .. "\n" )
                        fh:close()
                end
        end )
end
tlog( "GitHubSettings.lua module load START" )

-- GitHubSync is loaded lazily only when the user clicks "Test connection".
local _GitHubSync = nil
local function lazyGH()
  if _GitHubSync == nil then
    _GitHubSync = dofile( LrPathUtils.child( _PLUGIN.path, "GitHubSync.lua" ) )
  end
  return _GitHubSync
end

local provider = {}

function provider.sectionsForTopOfDialog( f, props )
        tlog( "sectionsForTopOfDialog START (Plugin Manager page render)" )

        local prefs = LrPrefs.prefsForPlugin()

        -- Helper: treat nil AND empty string as missing.
        local function orDefault( v, default )
                if v == nil or v == "" then return default end
                return v
        end

        -- In Plugin Manager sections, bind "key" reads/writes plugin PREFS, not props.
        -- So we seed the PREFS (not props) with defaults for fields the user hasn't set.
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

        if props.gh_status == nil then
                props.gh_status = "GitHub Sync ready — click 'Test connection' to verify."
        end

        local bind = LrView.bind

        local section = {
                {
                        title = "GitHub Sync",

                        f:static_text {
                                title = "Reading verification files from a PUBLIC repo works without a token. " ..
                                        "A GitHub personal-access token (with repo / Contents: write scope) is " ..
                                        "only required to SAVE (push) changes back to GitHub — writing always " ..
                                        "needs a token, even on a public repo. The token is stored only on this " ..
                                        "machine and is never included in the distributed plugin.",
                                width = 640,
                                height_in_lines = 3,
                        },

                        -- All edit_fields bind DIRECTLY to prefs (the real target in
                        -- Plugin Manager).  immediate=true flushes each keystroke to
                        -- prefs so the Test button always sees the current value.
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
                                f:static_text { title = "(path in the repo for verified/<Country>.json)" },
                        },

                        f:row {
                                f:push_button {
                                        title  = "Test connection",
                                        action = function()
                                                LrTasks.startAsyncTask( function()
                                                        local snap = {
                                                                token  = prefs.gh_token,
                                                                owner  = orDefault( prefs.gh_owner,      "Liodden73" ),
                                                                repo   = orDefault( prefs.gh_repo,       "LR-Keywords-Geography" ),
                                                                branch = orDefault( prefs.gh_branch,     "main" ),
                                                                prefix = orDefault( prefs.gh_pathPrefix, "verified" ),
                                                        }
                                                        local ok, msg = lazyGH().test( snap )
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
                },
        }

        tlog( "sectionsForTopOfDialog DONE (Plugin Manager page render)" )
        return section
end

tlog( "GitHubSettings.lua module load DONE" )

return provider
