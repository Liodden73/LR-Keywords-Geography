--[[
        Geography Keyword Builder — Lightroom Classic plugin
        Builds a slim, filtered geography keyword list (.txt) for Norway or Sweden
        from pre-verified bundled data. Works fully offline.
]]

return {

        LrSdkVersion = 6.0,
        LrSdkMinimumVersion = 6.0,

        LrToolkitIdentifier = "com.lioddenMedia.geographyBuilder",
        LrPluginName = "Geography Keyword Builder",

        LrPluginInfoProvider = "GitHubSettings.lua",

        LrLibraryMenuItems = {
                {
                        title = "Geography Keyword Builder...",
                        file  = "ListVerification.lua",
                },
        },

        VERSION = { major = 0, minor = 9, revision = 171, build = 0 },
}
