-- Kuwait geography data for LR Geography Builder
-- Admin divisions and cities: GeoNames.org (CC BY 4.0); national parks, reserves
-- and viewpoints: curated lists. No commas in any name (Lightroom constraint).
-- Data version 0.1.0  generated 2026-10-09
return {
        meta = {
                version      = "0.1.0",
                country      = "Kuwait",
                native_name  = "Dawlat al Kuwayt",
                continent    = "Asia",
                generated    = "2026-10-09",
                min_city_pop = 2000,
        },

        national_parks = {
                "Sabah Al Ahmad Nature Reserve",
        },

        nature_reserves = {
                "Al Jahra Wetlands",
                "Bubiyan Island Reserve",
                "Doha Nature Reserve",
                "Jahra Pool Reserve",
                "Kubbar Island Marine Reserve",
                "Sulaibikhat Nature Reserve",
                "Umm Niqa Reserve",
        },

        mountains = {
                { name = "Mutla Ridge", elev = 145, region = "Jahra Governorate" },
                { name = "Khashm Ghudayy", elev = 110, region = "Jahra Governorate" },
        },

        islands = {
                "Failaka Island",
                "Bubiyan Island",
                "Warbah Island",
                "Kubbar Island",
                "Qaruh Island",
                "Umm al Maradim Island",
                "Miskan Island",
                "Auhah Island",
                "Green Island",
                "Jazirat Umm an Naml",
                "Jazirat Faylaka",
                "Jazirat Awhah",
        },

        viewpoints = {
                { name = "Kuwait Towers" },
                { name = "Liberation Tower" },
                { name = "Grand Mosque Kuwait" },
                { name = "Souq Al Mubarakiya" },
                { name = "Al Hamra Tower" },
                { name = "Sheikh Jaber Al Ahmad Cultural Centre" },
                { name = "Kuwait National Museum" },
                { name = "Seif Palace" },
                { name = "Marina Crescent" },
                { name = "Scientific Center Kuwait" },
                { name = "Mirror House" },
                { name = "Failaka Island Ruins" },
                { name = "Al Shaheed Park" },
                { name = "Sheikh Jaber Causeway" },
                { name = "Mutla Ridge Viewpoint" },
                { name = "Green Island Kuwait" },
        },

        counties = {
                { name = "Ahmadi Governorate",
                  cities = { "Ahmadi", "Al Mahbulah", "Al Wafrah", "Fahaheel", "Fintas", "Mangaf", "Riqqa" },
                },
                { name = "Capital Governorate",
                  cities = { "Ad Dasmah", "Az Zawr", "Kaifan", "Kuwait City", "Mirqab", "Sharq", "Shuwaikh" },
                },
                { name = "Farwaniya Governorate",
                  cities = { "Ardiya", "Farwaniya", "Janub as Surrah", "Jleeb Al-Shuyoukh", "Khaitan" },
                },
                { name = "Hawalli Governorate",
                  cities = { "Bayan", "Hawalli", "Jabriya", "Mishref", "Rumaithiya", "Salmiya" },
                },
                { name = "Jahra Governorate",
                  cities = { "Jahra", "Mazari al Abdali" },
                },
                { name = "Mubarak Al-Kabeer Governorate",
                  cities = { "Al-Masayel", "Mubarak al Kabir", "Sabah as Salim" },
                },
        },
}
