-- Barbados geography data for LR Geography Builder
-- Admin divisions and cities: GeoNames.org (CC BY 4.0); national parks, reserves
-- and viewpoints: curated lists. No commas in any name (Lightroom constraint).
-- Data version 0.1.1  generated 2026-10-09
return {
        meta = {
                version      = "0.1.1",
                country      = "Barbados",
                native_name  = "Barbados",
                continent    = "North America",
                generated    = "2026-10-09",
                min_city_pop = 1000,
        },

        national_parks = {
                "Barbados National Park",
                "Carlisle Bay Marine Park",
                "Folkestone Marine Reserve",
        },

        nature_reserves = {
                "Andromeda Botanic Gardens",
                "Barbados Wildlife Reserve",
                "Flower Forest",
                "Graeme Hall Nature Sanctuary",
                "Hunte's Gardens",
                "Turner's Hall Woods",
                "Welchman Hall Gully",
        },

        mountains = {
                { name = "Mount Hillaby", elev = 340, region = "Saint Andrew" },
        },

        lakes = {
                "Graeme Hall Swamp",
                "The Salt Lakes",
        },

        rivers = {
                "Constitution River",
                "Joe's River",
                "Bruce Vale River",
                "Indian River",
        },

        islands = {
                "Barbados",
                "Pelican Island",
                "Culpepper Island",
                "Pelican Island (historical)",
        },

        viewpoints = {
                { name = "Harrison's Cave" },
                { name = "Animal Flower Cave" },
                { name = "Bathsheba Beach" },
                { name = "Crane Beach" },
                { name = "Bottom Bay" },
                { name = "Cherry Tree Hill" },
                { name = "Gun Hill Signal Station" },
                { name = "St Nicholas Abbey" },
                { name = "Morgan Lewis Windmill" },
                { name = "Bridgetown Garrison" },
                { name = "Parliament Buildings Bridgetown" },
                { name = "Carlisle Bay" },
                { name = "Mullins Beach" },
                { name = "Accra Beach" },
                { name = "Hackleton's Cliff" },
                { name = "Farley Hill" },
        },

        counties = {
                { name = "Christ Church",
                  cities = { "Dover", "Hastings", "Oistins", "Six Cross Roads", "St Lawrence Gap" },
                },
                { name = "Saint Andrew",
                  cities = { "Belleplaine", "Greenland", "White Hill" },
                },
                { name = "Saint George",
                  cities = { "Bulkeley" },
                },
                { name = "Saint James",
                  cities = { "Holetown" },
                },
                { name = "Saint John",
                  cities = { "Four Cross Roads", "Four Roads" },
                },
                { name = "Saint Joseph",
                  cities = { "Bathsheba" },
                },
                { name = "Saint Lucy",
                  cities = { "Checker Hall" },
                },
                { name = "Saint Michael",
                  cities = { "Bridgetown" },
                },
                { name = "Saint Peter",
                  cities = { "Mile and a Quarter", "Speightstown" },
                },
                { name = "Saint Philip",
                  cities = { "Crane" },
                },
                { name = "Saint Thomas",
                  cities = { "Welchman Hall" },
                },
        },
}
