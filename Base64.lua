--[[
        Base64.lua — Geography Keyword Builder

        Minimal pure-Lua Base64 encode/decode (Lua 5.1 compatible).
        Used only to encode file content for the GitHub Contents API
        (PUT .../contents/... requires the "content" field to be Base64).

        Returns a module table: Base64.encode(str) / Base64.decode(str).
]]

local Base64 = {}

local ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Encode a binary/UTF-8 string to a Base64 string.
function Base64.encode( data )
        if data == nil then return "" end
        return ( ( data:gsub( '.', function( x )
                local r, byte = '', x:byte()
                for i = 8, 1, -1 do
                        r = r .. ( ( byte % 2^i - byte % 2^( i - 1 ) > 0 ) and '1' or '0' )
                end
                return r
        end ) .. '0000' ):gsub( '%d%d%d?%d?%d?%d?', function( x )
                if #x < 6 then return '' end
                local c = 0
                for i = 1, 6 do
                        c = c + ( ( x:sub( i, i ) == '1' ) and 2^( 6 - i ) or 0 )
                end
                return ALPHABET:sub( c + 1, c + 1 )
        end ) .. ( { '', '==', '=' } )[ #data % 3 + 1 ] )
end

-- Decode a Base64 string back to the original string.
function Base64.decode( data )
        if data == nil then return "" end
        data = string.gsub( data, '[^' .. ALPHABET .. '=]', '' )
        return ( data:gsub( '.', function( x )
                if x == '=' then return '' end
                local r, f = '', ( ALPHABET:find( x ) - 1 )
                for i = 6, 1, -1 do
                        r = r .. ( ( f % 2^i - f % 2^( i - 1 ) > 0 ) and '1' or '0' )
                end
                return r
        end ):gsub( '%d%d%d?%d?%d?%d?%d?%d?', function( x )
                if #x ~= 8 then return '' end
                local c = 0
                for i = 1, 8 do
                        c = c + ( ( x:sub( i, i ) == '1' ) and 2^( 8 - i ) or 0 )
                end
                return string.char( c )
        end ) )
end

return Base64
