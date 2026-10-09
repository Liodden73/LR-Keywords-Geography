-- Nauru geography data for LR Geography Builder
-- Admin divisions and cities: GeoNames.org (CC BY 4.0); national parks, reserves
-- and viewpoints: curated lists. No commas in any name (Lightroom constraint).
-- Data version 0.1.1  generated 2026-10-09
return {
        meta = {
                version      = "0.1.1",
                country      = "Nauru",
                native_name  = "Naoero",
                continent    = "Oceania",
                generated    = "2026-10-09",
                min_city_pop = 0,
        },

        nature_reserves = {
                "Anibare Bay",
                "Buada Lagoon",
                "Topside Phosphate Plateau",
        },

        mountains = {
                { name = "Command Ridge", elev = 71, region = "Aiwo" },
        },

        lakes = {
                "Buada Lagoon",
        },

        islands = {
                "Nauru",
        },

        viewpoints = {
                { name = "Command Ridge" },
                { name = "Anibare Bay Beach" },
                { name = "Moqua Well" },
                { name = "Moqua Caves" },
                { name = "Parliament House Nauru" },
                { name = "Nauru Phosphate Cantilevers" },
                { name = "Japanese Guns Command Ridge" },
        },

        counties = {
                { name = "Aiwo",
                  cities = { "Arijejen", "Yangor" },
                },
                { name = "Anabar",
                  cities = { "Anabar" },
                },
                { name = "Anetan",
                  cities = { "Ronave" },
                },
                { name = "Anibare",
                  cities = { "Anibare" },
                },
                { name = "Baiti",
                  cities = { "Baiti" },
                },
                { name = "Boe",
                  cities = { "Boe" },
                },
                { name = "Buada",
                  cities = { "Arenibek" },
                },
                { name = "Denigomodu",
                  cities = { "Denigomodu" },
                },
                { name = "Ewa",
                  cities = { "Arubo" },
                },
                { name = "Ijuw",
                  cities = { "Ijuw" },
                },
                { name = "Meneng",
                  cities = { "Menen" },
                },
                { name = "Nibok",
                  cities = { "Nibok" },
                },
                { name = "Uaboe",
                  cities = { "Uaboe" },
                },
                { name = "Yaren",
                  cities = { "Yaren" },
                },
        },
}
