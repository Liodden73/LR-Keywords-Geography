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

        -- Seed the observable dialog props from stored prefs (with defaults).
        props.gh_token      = prefs.gh_token      or ""
        props.gh_owner      = prefs.gh_owner      or "Liodden73"
        props.gh_repo       = prefs.gh_repo       or "LR-Keywords-Geography"
        props.gh_branch     = prefs.gh_branch     or "main"
        props.gh_pathPrefix = prefs.gh_pathPrefix or "verified"
        props.gh_status     = GitHubSync.isConfigured()
                                 and "Token stored on this machine."
                                 or  "No token set — sync disabled."

        -- Persist each field back to prefs as it changes.
        local function persist( key )
                props:addObserver( key, function()
                        local v = props[ key ]
                        if v == "" then v = nil end
                        prefs[ key ] = v
                end )
        end
        persist( "gh_token" )
        persist( "gh_owner" )
        persist( "gh_repo" )
        persist( "gh_branch" )
        persist( "gh_pathPrefix" )

        local bind = LrView.bind

        return {
                {
                        title = "GitHub Sync",

                        f:static_text {
                                title = "Enter a GitHub personal-access token (with repo scope) to " ..
                                        "read and write verification files. The token is stored only " ..
                                        "on this machine and is never included in the distributed plugin.",
                                width = 640,
                                height_in_lines = 2,
                        },

                        f:row {
                                f:static_text { title = "Token:", width = 90 },
                                f:password_field {
                                        value = bind "gh_token",
                                        width_in_chars = 44,
                                },
                        },
                        f:row {
                                f:static_text { title = "Owner:", width = 90 },
                                f:edit_field { value = bind "gh_owner", width_in_chars = 30 },
                        },
                        f:row {
                                f:static_text { title = "Repository:", width = 90 },
                                f:edit_field { value = bind "gh_repo", width_in_chars = 30 },
                        },
                        f:row {
                                f:static_text { title = "Branch:", width = 90 },
                                f:edit_field { value = bind "gh_branch", width_in_chars = 16 },
                        },
                        f:row {
                                f:static_text { title = "Folder:", width = 90 },
                                f:edit_field { value = bind "gh_pathPrefix", width_in_chars = 16 },
                                f:static_text { title = "(path in the repo for verified/<Country>.json)" },
                        },

                        f:row {
                                f:push_button {
                                        title  = "Test connection",
                                        action = function()
                                                LrTasks.startAsyncTask( function()
                                                        local ok, msg = GitHubSync.test()
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
                                        title = bind "gh_status",
                                        fill_horizontal = 1,
                                },
                        },
                },
        }
end

return provider
