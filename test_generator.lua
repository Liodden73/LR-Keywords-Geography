-- Test Generator.lua output
local Generator = dofile("Generator.lua")
local Norway = dofile("data/Norway.lua")

-- Minimal prefs for testing
local prefs = {
    national_parks = true,
    national_parks_max = 3,
    islands = true,
    islands_max = 10,
    fjords = true,
    fjords_max = 10,
    administrative = true,
    admin_detail = 1,
    counties = { ["Oslo"] = true },
    remote_islands_names = { "Svalbard" },
    remote_islands_selected = { ["Svalbard"] = true },
}

local output = Generator.generate(Norway, prefs)
print(output)
