--[[
        GitHubSync.lua — Geography Keyword Builder

        Thin wrapper around the GitHub Contents API for reading and writing
        the per-country verification files (verified/<Country>.json).

        SECURITY MODEL
        --------------
        The GitHub personal-access token is stored ONLY in this machine's
        plugin preferences (File ▸ Plug-in Manager ▸ Geography Keyword Builder ▸
        GitHub Sync).  It is never bundled with the plugin and never distributed
        to customers.  Only the plugin author, on a machine where the token has
        been entered, can push updates.  Customers who receive the plugin have
        no token, so the sync buttons simply report "GitHub not configured".

        All network calls use LrHttp and therefore MUST be invoked from inside
        an LrTasks async task (the callers already do this).

        Returns a module table.
]]

local LrHttp      = import 'LrHttp'
local LrPrefs     = import 'LrPrefs'
local LrPathUtils = import 'LrPathUtils'

local Base64 = dofile( LrPathUtils.child( _PLUGIN.path, "Base64.lua" ) )
local dkjson = dofile( LrPathUtils.child( _PLUGIN.path, "dkjson.lua" ) )

local M = {}

-- Read the current GitHub configuration from plugin prefs, with sensible
-- defaults for this project's repo.
local function cfg()
        local p = LrPrefs.prefsForPlugin()
        return {
                token  = p.gh_token,
                owner  = ( p.gh_owner  and p.gh_owner  ~= "" ) and p.gh_owner  or "Liodden73",
                repo   = ( p.gh_repo   and p.gh_repo   ~= "" ) and p.gh_repo   or "LR-Keywords-Geography",
                branch = ( p.gh_branch and p.gh_branch ~= "" ) and p.gh_branch or "main",
                prefix = ( p.gh_pathPrefix and p.gh_pathPrefix ~= "" ) and p.gh_pathPrefix or "verified",
        }
end

M.cfg = cfg

-- True only when a token is present (and owner/repo resolved).
function M.isConfigured()
        local c = cfg()
        return c.token ~= nil and c.token ~= "" and c.owner ~= "" and c.repo ~= ""
end

-- Path within the repo for a country's verification file.
function M.verifiedPath( countryId )
        return cfg().prefix .. "/" .. countryId .. ".json"
end

-- True when owner/repo are resolved (enough to READ a public repo, even
-- without a token).
function M.isReadable()
        local c = cfg()
        return c.owner ~= nil and c.owner ~= "" and c.repo ~= nil and c.repo ~= ""
end

-- Standard API headers.  `accept` overrides the default JSON accept
-- (e.g. "application/vnd.github.raw" to fetch raw file bytes).
-- The Authorization header is only added when a token is present, so read
-- calls work anonymously against a public repository.
local function apiHeaders( c, accept, withContentType )
        local h = {
                { field = "Accept",        value = accept or "application/vnd.github+json" },
                { field = "User-Agent",    value = "LR-Geography-Builder" },
                { field = "X-GitHub-Api-Version", value = "2022-11-28" },
        }
        if c.token and c.token ~= "" then
                table.insert( h, 1, { field = "Authorization", value = "token " .. c.token } )
        end
        if withContentType then
                h[ #h + 1 ] = { field = "Content-Type", value = "application/json" }
        end
        return h
end

-- Ping the repo. Returns (true, "owner/repo") or (false, errorString).
-- Works anonymously on a public repo; a token additionally confirms write access.
function M.test()
        local c = cfg()
        if not M.isReadable() then
                return false, "Owner/repository not set. Enter them in Plug-in Manager."
        end
        local url = "https://api.github.com/repos/" .. c.owner .. "/" .. c.repo
        local body, hdrs = LrHttp.get( url, apiHeaders( c ) )
        local status = hdrs and hdrs.status
        if status == 200 then
                local obj = body and dkjson.decode( body )
                local name = ( obj and obj.full_name ) or ( c.owner .. "/" .. c.repo )
                local hasToken = ( c.token and c.token ~= "" )
                local canWrite = obj and obj.permissions and obj.permissions.push
                if hasToken then
                        if canWrite then
                                return true, name .. " (read/write — token OK)"
                        else
                                return true, name .. " (read only — token lacks write access)"
                        end
                end
                return true, name .. " (read only — no token; Save/push disabled)"
        elseif status == 401 then
                return false, "Unauthorized (401) — token is invalid or expired."
        elseif status == 404 then
                return false, "Repo not found (404) — check owner/repo (private repos need a token)."
        end
        return false, "HTTP " .. tostring( status ) .. ( body and ( ": " .. tostring( body ) ) or "" )
end

-- Fetch a file's raw text content. Returns (content, nil) on success,
-- (nil, "not found") for 404, or (nil, errorString) otherwise.
function M.readFile( path )
        local c = cfg()
        local url = "https://api.github.com/repos/" .. c.owner .. "/" .. c.repo ..
                    "/contents/" .. path .. "?ref=" .. c.branch
        local body, hdrs = LrHttp.get( url, apiHeaders( c, "application/vnd.github.raw" ) )
        local status = hdrs and hdrs.status
        if status == 200 then
                return body
        elseif status == 404 then
                return nil, "not found"
        elseif status == 401 then
                return nil, "unauthorized (401) — check token"
        end
        return nil, "HTTP " .. tostring( status )
end

-- Get the blob SHA of an existing file (needed to update it). Returns sha
-- string, or nil if the file does not exist yet.
local function getSha( c, path )
        local url = "https://api.github.com/repos/" .. c.owner .. "/" .. c.repo ..
                    "/contents/" .. path .. "?ref=" .. c.branch
        local body, hdrs = LrHttp.get( url, apiHeaders( c ) )
        if hdrs and hdrs.status == 200 and body then
                local obj = dkjson.decode( body )
                return obj and obj.sha
        end
        return nil
end

-- Create or update a file. Returns (true, commitUrl) or (false, errorString).
function M.writeFile( path, content, message )
        local c = cfg()
        if not M.isConfigured() then
                return false, "No token set."
        end
        local sha = getSha( c, path )
        local payload = {
                message = message or ( "Update " .. path ),
                content = Base64.encode( content ),
                branch  = c.branch,
        }
        if sha then payload.sha = sha end

        local jsonBody = dkjson.encode( payload )
        local url = "https://api.github.com/repos/" .. c.owner .. "/" .. c.repo ..
                    "/contents/" .. path
        local body, hdrs = LrHttp.post( url, jsonBody, apiHeaders( c, nil, true ), "PUT" )
        local status = hdrs and hdrs.status
        if status == 200 or status == 201 then
                local obj = body and dkjson.decode( body )
                local commitUrl = obj and obj.commit and obj.commit.html_url
                return true, commitUrl
        elseif status == 401 then
                return false, "Unauthorized (401) — token invalid or lacks write scope."
        elseif status == 404 then
                return false, "Not found (404) — token lacks write access to this repo."
        elseif status == 409 then
                return false, "Conflict (409) — the file changed on GitHub. Refresh first, then save again."
        elseif status == 422 then
                return false, "Unprocessable (422) — " .. tostring( body )
        end
        return false, "HTTP " .. tostring( status ) .. ( body and ( ": " .. tostring( body ) ) or "" )
end

return M
