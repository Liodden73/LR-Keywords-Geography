-- Edition.lua — identifies which edition this bundle is.
--
-- This file is REWRITTEN by build_editions.py for each packaged bundle:
--   • Manager edition   → { isManager = true }
--   • End-user edition  → { isManager = false }
--
-- The raw source tree ships this Manager default so that running the plugin
-- straight from source behaves as the full admin superset.
return { isManager = true }
