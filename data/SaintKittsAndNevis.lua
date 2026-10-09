-- Saint Kitts and Nevis geography data for LR Geography Builder
-- Admin divisions and cities: GeoNames.org (CC BY 4.0); national parks, reserves
-- and viewpoints: curated lists. No commas in any name (Lightroom constraint).
-- Data version 0.1.0  generated 2026-10-09
return {
        meta = {
                version      = "0.1.0",
                country      = "Saint Kitts and Nevis",
                native_name  = "Saint Kitts and Nevis",
                continent    = "North America",
                generated    = "2026-10-09",
                min_city_pop = 1000,
        },

        national_parks = {
                "Brimstone Hill Fortress National Park",
                "Central Forest Reserve National Park",
                "Nevis Peak Forest Reserve",
        },

        nature_reserves = {
                "Booby Island Reserve",
                "Great Salt Pond",
                "Nevis Botanical Garden",
                "Saint Kitts Marine Management Area",
                "Southeast Peninsula",
        },

        mountains = {
                { name = "Mount Liamuiga", elev = 1156, region = "Saint John Capesterre" },
                { name = "Nevis Peak", elev = 985, region = "Saint George Gingerland" },
                { name = "Olivees Mountain", elev = 886, region = "Saint Peter Basseterre" },
                { name = "Verchilds Mountain", elev = 873, region = "Saint Thomas Middle Island" },
                { name = "The Weir", elev = 733, region = "Saint Thomas Middle Island" },
                { name = "Saddle Hill", elev = 375, region = "Saint George Gingerland" },
                { name = "Monkey Hill", elev = 346, region = "Saint Peter Basseterre" },
                { name = "Round Hill", elev = 301, region = "Saint James Windward" },
        },

        lakes = {
                "Great Salt Pond",
                "Mount Liamuiga Crater Lake",
        },

        rivers = {
                "Wingfields River",
                "Cranstowns Gut",
                "Fancy River",
                "Lavingtons Gut",
                "Molines Gut",
                "Sulphur Ghut",
        },

        islands = {
                "Saint Kitts",
                "Nevis",
                "Booby Island",
        },

        viewpoints = {
                { name = "Brimstone Hill Fortress" },
                { name = "Timothy Hill" },
                { name = "Romney Gardens" },
                { name = "Saint Kitts Scenic Railway" },
                { name = "Cockleshell Bay" },
                { name = "South Friars Bay" },
                { name = "Pinney's Beach" },
                { name = "Bath Springs Nevis" },
                { name = "Alexander Hamilton Birthplace" },
                { name = "The Circus Basseterre" },
                { name = "Black Rocks" },
                { name = "Wingfield Estate" },
        },

        counties = {
                { name = "Christ Church Nichola Town",
                  cities = { "Nicola Town" },
                },
                { name = "Saint Anne Sandy Point",
                  cities = { "Sandy Point Town" },
                },
                { name = "Saint George Basseterre",
                  cities = { "Basseterre" },
                },
                { name = "Saint George Gingerland",
                  cities = { "Market Shop" },
                },
                { name = "Saint James Windward",
                  cities = { "Newcastle" },
                },
                { name = "Saint John Capesterre",
                  cities = { "Dieppe Bay Town", "Sadlers" },
                },
                { name = "Saint John Figtree",
                  cities = { "Fig Tree" },
                },
                { name = "Saint Mary Cayon",
                  cities = { "Cayon" },
                },
                { name = "Saint Paul Capesterre",
                  cities = { "Saint Paul's" },
                },
                { name = "Saint Paul Charlestown",
                  cities = { "Charlestown" },
                },
                { name = "Saint Peter Basseterre",
                  cities = { "Monkey Hill" },
                },
                { name = "Saint Thomas Lowland",
                  cities = { "Cotton Ground" },
                },
                { name = "Saint Thomas Middle Island",
                  cities = { "Middle Island", "Old Road Town" },
                },
                { name = "Trinity Palmetto Point",
                  cities = { "Boyds", "Trinity" },
                },
        },
}
