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
]]

local LrView    = import 'LrView'
local LrPrefs   = import 'LrPrefs'
local LrDialogs = import 'LrDialogs'
local LrTasks   = import 'LrTasks'
local LrPathUtils = import 'LrPathUtils'

local GitHubSync = dofile( LrPathUtils.child( _PLUGIN.path, "GitHubSync.lua" ) )

local provider = {}

function provider.sectionsForTopOfDialog( f, props )
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

        -- Status label uses an explicit props binding (we set it ourselves;
        -- it is NOT a user-typed field, so we don't want it in prefs).
        props.gh_status = GitHubSync.isConfigured()
                                 and "Token stored on this machine — read & write enabled."
                                 or  "No token — read-only (Save/push disabled)."

        local bind = LrView.bind

        return {
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
                                                -- prefs IS the binding target, so it always has the
                                                -- latest values (updated on every keystroke by immediate=true).
                                                -- Read from prefs inside the async task — no pre-capture needed.
                                                LrTasks.startAsyncTask( function()
                                                        local snap = {
                                                                token  = prefs.gh_token,
                                                                owner  = orDefault( prefs.gh_owner,      "Liodden73" ),
                                                                repo   = orDefault( prefs.gh_repo,       "LR-Keywords-Geography" ),
                                                                branch = orDefault( prefs.gh_branch,     "main" ),
                                                                prefix = orDefault( prefs.gh_pathPrefix, "verified" ),
                                                        }
                                                        local ok, msg = GitHubSync.test( snap )
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
end

return provider
