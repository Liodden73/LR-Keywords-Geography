-- ==========================================================
-- GPSConverter.lua
-- ==========================================================
--
-- WHAT THIS MODULE DOES
--   A standalone, reusable Lua module that handles GPS-to-keyword
--   conversion for Lightroom Classic plugins. It can:
--     * Format decimal lat/lon into degrees-minutes-seconds (DMS).
--     * Reverse-geocode a coordinate to a country/state/county/city
--       using the OpenStreetMap Nominatim API.
--     * Match a geocoded city against the plugin's country geography
--       data (COUNTRIES from ListVerification) at the CITY level only.
--     * Build a "Geography > World > ..." keyword path from a match.
--     * Report a photo's file size as a human-readable string.
--
-- HOW TO USE FROM ANOTHER PLUGIN
--   local GPSConverter = dofile("/absolute/path/to/GPSConverter.lua")
--
--   local dms = GPSConverter.formatDMS(60.1139, 10.2745)
--   local geo = GPSConverter.reverseGeocode(60.1139, 10.2745)
--   local matches = GPSConverter.findCityMatches(geo, COUNTRIES, enabledSet)
--   for _, m in ipairs(matches) do
--       print(GPSConverter.formatKeywordPath(m))
--   end
--   local size = GPSConverter.getPhotoFileSize(photo)
--
-- PUBLIC API SURFACE
--   M.formatDMS(lat, lon)                        -> string
--   M.reverseGeocode(lat, lon)                   -> table|nil
--   M.findCityMatches(geo, countries, enabledSet)-> array of match tables
--   M.formatKeywordPath(match)                   -> string
--   M.getPhotoFileSize(photo)                    -> string
--
-- DEPENDENCY
--   LrHttp must be available via the Lightroom SDK, i.e. the host plugin
--   must be able to do:  local LrHttp  = import "LrHttp"
local LrTasks = import "LrTasks"
--   This module imports it internally. No other external dependency:
--   a minimal JSON decoder is bundled inline (dkjson is NOT assumed,
--   since other plugins may not ship it).
-- ==========================================================

-- LrHttp is imported lazily. Importing it at module load time initializes the
-- Lightroom HTTP stack (~60s on some systems), which would delay every dialog
-- that requires this module. We only need it when a reverse-geocode request
-- actually runs, so defer the import until first use.
local _LrHttp = nil
local function http()
    if _LrHttp == nil then
        _LrHttp = import "LrHttp"
    end
    return _LrHttp
end

local M = {}

-- ==========================================================
-- Minimal JSON decoder (bundled — no external dependency)
-- Handles objects, arrays, strings (with escapes/\uXXXX),
-- numbers, true/false/null. Sufficient for Nominatim responses.
-- Returns (value) on success or (nil, errorMessage) on failure.
-- ==========================================================
local function jsonDecode(str)
    if type(str) ~= "string" then return nil, "input is not a string" end

    local pos = 1
    local len = #str

    local parseValue  -- forward declaration

    local function skipWhitespace()
        while pos <= len do
            local c = string.byte(str, pos)
            -- space, tab, newline, carriage return
            if c == 32 or c == 9 or c == 10 or c == 13 then
                pos = pos + 1
            else
                break
            end
        end
    end

    local function parseError(msg)
        return nil, ("JSON parse error at position %d: %s"):format(pos, msg or "")
    end

    -- Encode a Unicode code point as UTF-8 (Lightroom Lua strings are bytes)
    local function utf8Encode(cp)
        if cp < 0x80 then
            return string.char(cp)
        elseif cp < 0x800 then
            return string.char(
                0xC0 + math.floor(cp / 0x40),
                0x80 + (cp % 0x40))
        elseif cp < 0x10000 then
            return string.char(
                0xE0 + math.floor(cp / 0x1000),
                0x80 + (math.floor(cp / 0x40) % 0x40),
                0x80 + (cp % 0x40))
        else
            return string.char(
                0xF0 + math.floor(cp / 0x40000),
                0x80 + (math.floor(cp / 0x1000) % 0x40),
                0x80 + (math.floor(cp / 0x40) % 0x40),
                0x80 + (cp % 0x40))
        end
    end

    local escapeMap = {
        ['"'] = '"', ['\\'] = '\\', ['/'] = '/',
        b = '\b', f = '\f', n = '\n', r = '\r', t = '\t',
    }

    local function parseString()
        -- assumes current char is the opening quote
        pos = pos + 1
        local buf = {}
        while pos <= len do
            local c = string.sub(str, pos, pos)
            if c == '"' then
                pos = pos + 1
                return table.concat(buf)
            elseif c == '\\' then
                pos = pos + 1
                local esc = string.sub(str, pos, pos)
                if esc == 'u' then
                    local hex = string.sub(str, pos + 1, pos + 4)
                    if not hex:match("^%x%x%x%x$") then
                        return parseError("invalid \\u escape")
                    end
                    local cp = tonumber(hex, 16)
                    pos = pos + 5
                    -- Handle UTF-16 surrogate pairs
                    if cp >= 0xD800 and cp <= 0xDBFF then
                        if string.sub(str, pos, pos + 1) == '\\u' then
                            local hex2 = string.sub(str, pos + 2, pos + 5)
                            if hex2:match("^%x%x%x%x$") then
                                local cp2 = tonumber(hex2, 16)
                                if cp2 >= 0xDC00 and cp2 <= 0xDFFF then
                                    cp = 0x10000 + (cp - 0xD800) * 0x400 + (cp2 - 0xDC00)
                                    pos = pos + 6
                                end
                            end
                        end
                    end
                    buf[#buf + 1] = utf8Encode(cp)
                else
                    local mapped = escapeMap[esc]
                    if not mapped then
                        return parseError("invalid escape character")
                    end
                    buf[#buf + 1] = mapped
                    pos = pos + 1
                end
            else
                buf[#buf + 1] = c
                pos = pos + 1
            end
        end
        return parseError("unterminated string")
    end

    local function parseNumber()
        local numStr = string.match(str, "^%-?%d+%.?%d*[eE]?[%+%-]?%d*", pos)
        if not numStr or numStr == "" then
            return parseError("invalid number")
        end
        pos = pos + #numStr
        return tonumber(numStr)
    end

    local function parseObject()
        pos = pos + 1  -- skip '{'
        local obj = {}
        skipWhitespace()
        if string.sub(str, pos, pos) == '}' then
            pos = pos + 1
            return obj
        end
        while pos <= len do
            skipWhitespace()
            if string.sub(str, pos, pos) ~= '"' then
                return parseError("expected string key in object")
            end
            local key, err = parseString()
            if key == nil then return nil, err end
            skipWhitespace()
            if string.sub(str, pos, pos) ~= ':' then
                return parseError("expected ':' after object key")
            end
            pos = pos + 1
            skipWhitespace()
            local val, verr = parseValue()
            if val == nil and verr then return nil, verr end
            obj[key] = val
            skipWhitespace()
            local c = string.sub(str, pos, pos)
            if c == ',' then
                pos = pos + 1
            elseif c == '}' then
                pos = pos + 1
                return obj
            else
                return parseError("expected ',' or '}' in object")
            end
        end
        return parseError("unterminated object")
    end

    local function parseArray()
        pos = pos + 1  -- skip '['
        local arr = {}
        skipWhitespace()
        if string.sub(str, pos, pos) == ']' then
            pos = pos + 1
            return arr
        end
        while pos <= len do
            skipWhitespace()
            local val, verr = parseValue()
            if val == nil and verr then return nil, verr end
            arr[#arr + 1] = val
            skipWhitespace()
            local c = string.sub(str, pos, pos)
            if c == ',' then
                pos = pos + 1
            elseif c == ']' then
                pos = pos + 1
                return arr
            else
                return parseError("expected ',' or ']' in array")
            end
        end
        return parseError("unterminated array")
    end

    parseValue = function()
        skipWhitespace()
        if pos > len then return parseError("unexpected end of input") end
        local c = string.sub(str, pos, pos)
        if c == '{' then
            return parseObject()
        elseif c == '[' then
            return parseArray()
        elseif c == '"' then
            return parseString()
        elseif c == '-' or c:match("%d") then
            return parseNumber()
        elseif string.sub(str, pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif string.sub(str, pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif string.sub(str, pos, pos + 3) == "null" then
            pos = pos + 4
            return nil, nil  -- null decodes to nil, no error
        else
            return parseError("unexpected character '" .. c .. "'")
        end
    end

    local ok, result = pcall(function()
        skipWhitespace()
        local value, err = parseValue()
        if value == nil and err then error(err) end
        return value
    end)

    if not ok then
        return nil, tostring(result)
    end
    return result
end

-- ==========================================================
-- Helpers
-- ==========================================================
local function trim(s)
    if type(s) ~= "string" then return "" end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- ==========================================================
-- M.formatDMS(lat, lon)
-- Returns e.g.  60°6'50.0194" N  10°16'28.1673" E
-- Negative lat = S, negative lon = W.
-- ==========================================================
function M.formatDMS(lat, lon)
    local function component(value, posHemi, negHemi)
        local hemi = posHemi
        if value < 0 then hemi = negHemi end
        local absVal = math.abs(value)
        local deg = math.floor(absVal)
        local minFull = (absVal - deg) * 60
        local minutes = math.floor(minFull)
        local seconds = (minFull - minutes) * 60
        -- Guard against rounding that pushes seconds to 60.0000
        if seconds >= 59.99995 then
            seconds = 0
            minutes = minutes + 1
            if minutes >= 60 then
                minutes = 0
                deg = deg + 1
            end
        end
        return string.format('%d°%d\'%.4f" %s', deg, minutes, seconds, hemi)
    end

    lat = tonumber(lat) or 0
    lon = tonumber(lon) or 0
    return component(lat, "N", "S") .. "  " .. component(lon, "E", "W")
end

-- ==========================================================
-- M.reverseGeocode(lat, lon)
-- Calls Nominatim reverse geocoding, returns a normalized table
-- or nil on any error.
-- ==========================================================
function M.reverseGeocode(lat, lon)
    lat = tonumber(lat)
    lon = tonumber(lon)
    if lat == nil or lon == nil then
        return nil
    end

    local url = string.format(
        "https://nominatim.openstreetmap.org/reverse?lat=%.7f&lon=%.7f&format=json&accept-language=en",
        lat, lon)

    local headers = {
        { field = "User-Agent", value = "LR-Geography-Builder/1.0 (Lightroom Plugin)" },
    }

    -- IMPORTANT: LrHttp.get yields internally. In Lua 5.1 you cannot yield
    -- across a standard pcall() C-call boundary, so LrTasks.pcall MUST be used
    -- here — a plain pcall() makes every request fail silently ("No GPS result").
    local ok, body, respHeaders = LrTasks.pcall(function()
        return http().get(url, headers)
    end)

    if not ok then
        return nil, "http_error: " .. tostring(body)
    end
    if type(body) ~= "string" or body == "" then
        return nil, "empty_response"
    end

    local data, jerr = jsonDecode(body)
    if type(data) ~= "table" then
        return nil, "json_error: " .. tostring(jerr)
    end

    -- Nominatim returns { error = "..." } on failure
    if data.error ~= nil then
        return nil, "nominatim_error: " .. tostring(data.error)
    end

    local addr = data.address
    if type(addr) ~= "table" then
        addr = {}
    end

    -- City resolved in priority order
    local city = addr.city or addr.town or addr.village
        or addr.municipality or addr.hamlet or addr.suburb or ""

    local result = {
        country     = addr.country or "",
        countryCode = addr.country_code and string.upper(addr.country_code) or "",
        state       = addr.state or "",
        county      = addr.county or "",
        city        = city,
        displayName = data.display_name or "",
        rawAddress  = addr,
    }

    if city == "" then
        return result, "no_city_in_response"
    end

    return result
end

-- ==========================================================
-- M.findCityMatches(geo, countries, enabledSet)
-- Searches ONLY at city level across enabled countries.
-- Returns an array of match tables:
--   { countryId, countryName, countyName, muniName, cityName }
--   muniName is nil for flat-structure countries.
-- ==========================================================
function M.findCityMatches(geo, countries, enabledSet)
    local matches = {}

    if type(geo) ~= "table" or type(countries) ~= "table" then
        return matches
    end

    local targetCity = trim(geo.city)
    if targetCity == "" then
        return matches
    end
    local targetLower = string.lower(targetCity)

    enabledSet = enabledSet or {}

    for _, country in ipairs(countries) do
        if country and country.id and enabledSet[country.id] then
            local data = country.data
            if type(data) == "table" and type(data.counties) == "table" then
                for _, county in ipairs(data.counties) do
                    local countyName = county.name

                    -- Hierarchical structure: counties -> municipalities -> cities
                    if type(county.municipalities) == "table" then
                        for _, muni in ipairs(county.municipalities) do
                            -- Match the municipality's PRIMARY city. In the data,
                            -- the main city of a municipality is stored in
                            -- `primary_city` (e.g. "Oslo"), NOT in the `cities`
                            -- list (which holds only secondary cities and is often
                            -- empty). Without this check, primary cities never match.
                            if type(muni.primary_city) == "string"
                               and string.lower(trim(muni.primary_city)) == targetLower then
                                matches[#matches + 1] = {
                                    countryId   = country.id,
                                    countryName = country.name or country.id,
                                    countyName  = countyName,
                                    muniName    = muni.name,
                                    cityName    = muni.primary_city,
                                }
                            end
                            if type(muni.cities) == "table" then
                                for _, cityName in ipairs(muni.cities) do
                                    if string.lower(trim(cityName)) == targetLower then
                                        matches[#matches + 1] = {
                                            countryId   = country.id,
                                            countryName = country.name or country.id,
                                            countyName  = countyName,
                                            muniName    = muni.name,
                                            cityName    = cityName,
                                        }
                                    end
                                end
                            end
                        end
                    end

                    -- Flat structure: counties -> cities directly
                    if type(county.cities) == "table" then
                        for _, cityName in ipairs(county.cities) do
                            if string.lower(trim(cityName)) == targetLower then
                                matches[#matches + 1] = {
                                    countryId   = country.id,
                                    countryName = country.name or country.id,
                                    countyName  = countyName,
                                    muniName    = nil,
                                    cityName    = cityName,
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    return matches
end

-- ==========================================================
-- M.formatKeywordPath(match)
-- Returns "Geography > World > Country > County > Muni > City"
-- Omits the muniName segment for flat-structure countries (nil).
-- ==========================================================
function M.formatKeywordPath(match)
    if type(match) ~= "table" then return "" end

    local segments = { "Geography", "World" }
    if match.countryName then segments[#segments + 1] = match.countryName end
    if match.countyName then segments[#segments + 1] = match.countyName end
    if match.muniName then segments[#segments + 1] = match.muniName end
    if match.cityName then segments[#segments + 1] = match.cityName end

    return table.concat(segments, " > ")
end

-- ==========================================================
-- M.getPhotoFileSize(photo)
-- Returns human-readable size, e.g. "12.3 MB", or "–" if unknown.
-- Uses photo:getRawMetadata("fileSize") (bytes).
-- ==========================================================
function M.getPhotoFileSize(photo)
    if photo == nil then return "–" end

    local ok, bytes = pcall(function()
        return photo:getRawMetadata("fileSize")
    end)

    if not ok or type(bytes) ~= "number" or bytes <= 0 then
        return "–"
    end

    local units = { "B", "KB", "MB", "GB", "TB" }
    local idx = 1
    local size = bytes
    while size >= 1024 and idx < #units do
        size = size / 1024
        idx = idx + 1
    end

    if idx == 1 then
        -- Bytes: no decimal
        return string.format("%d %s", size, units[idx])
    end
    return string.format("%.1f %s", size, units[idx])
end

return M
