# Geography Keyword Builder — Lightroom Classic Plugin

Builds a **slim, filtered geography keyword list** (`.txt`) for **Norway** that you
import into Lightroom Classic. All place-name data is **bundled and pre-verified**,
so the plugin works **fully offline** — you request a fragment of the complete,
already-validated list instead of exporting from live data each time.

- Names are **comma-free** (Lightroom rejects commas with a "corrupted data" error).
- **Tab** indentation, **UTF-8** encoding, Norwegian characters (Æ Ø Å) preserved.
- Nature features (Mountain, Fjord, Lake, River, Island, Viewpoint) can **optionally**
  carry a `{Norway}` synonym (checkbox, OFF by default to keep the list slim).
  National Park and Nature Reserve never get it (location implied).

### Hierarchy

Under the `Geography` root there are two organizational wrappers at level 2:

```
Geography
├── Nature   → National Park, Nature Reserve, Mountain, Fjord,
│              Lake, River, Island, Viewpoint
└── World    → Europe → Norway → counties → municipalities → cities
```

`Nature` groups the physical features; `World` groups administrative geography and
scales cleanly as more countries/continents are added (Asia, Africa, … all live
under `World`). Both are just organizing parents — if you'd rather they weren't
applied to every photo, uncheck *Include on Export* on those two keywords once in
Lightroom's Keyword List. Section names are singular (`Fjord`, not `Fjords`) so they
read well as tags.

---

## Contents

```
LR-Geography-Builder.lrplugin/
├── Info.lua              Plugin manifest (menu registration)
├── KeywordBuilder.lua    Menu action — the selection dialog + file writer
├── Generator.lua         Pure-Lua filter: data + choices → .txt string
├── data/
│   └── Norway.lua        Bundled, pre-verified data (generated from GeoNames)
├── VERSION               Single source of truth for the version (e.g. 0.2.0)
├── CHANGELOG.md          What changed in each version
└── README.md             This file
```

---

## Installation

1. Copy the whole **`LR-Geography-Builder.lrplugin`** folder to a permanent
   location (keep the `.lrplugin` extension). Suggested locations:
   - **Windows:** `C:\Users\<you>\AppData\Roaming\Adobe\Lightroom\Modules\`
   - **macOS:** `~/Library/Application Support/Adobe/Lightroom/Modules/`
   (Any stable folder works — Lightroom just needs the path.)

2. In Lightroom Classic: **File ▸ Plug-in Manager…**
3. Click **Add**, select the `LR-Geography-Builder.lrplugin` folder, click
   **Add Plug-in**. It should show **Installed and running**.

---

## Usage

1. Go to the **Library** module.
2. **Library ▸ Plug-in Extras ▸ Build Geography Keywords…**
   (also available under **File ▸ Plug-in Extras**).
3. In the dialog:
   - **Sections** (left): tick the sections you want. For **Mountain**, set the
     elevation cutoffs (mainland / Svalbard). For **Fjord / Lake / River /
     Island**, set the max count.
   - **Counties & Areas** (right): tick individual counties, or use **All
     counties**. Toggle **Svalbard** and **Jan Mayen** separately.
   - **Add {Norway} synonym** (optional): OFF by default for a slim list. Turn it
     on if you want each nature feature to also tag photos with "Norway".
4. Click **Generate**, then choose a **folder**. The file is saved automatically as
   `LR-Geography-<Country>-<YYYYMMDD>.txt` — e.g. `LR-Geography-Norway-20260825.txt`.
   (If a file of that name already exists in the folder you're asked to confirm.)
5. Import into Lightroom: **Metadata ▸ Import Keywords…** and select the
   generated file. Lightroom merges it into your keyword hierarchy.

---

## Updating the master list (owner / maintainer)

The "master keyword list" is **`data/Norway.lua`** — the complete, pre-verified set
of every keyword the plugin can export. You never hand-edit it; it is generated
from the source pipeline. The workflow to publish an update is:

1. **Edit the source.** Change the curated lists or GeoNames handling in
   `build_v04.py` (e.g. add a viewpoint, fix an elevation, add a municipality).
2. **Bump the version** in the single-source **`VERSION`** file
   (`MAJOR.MINOR.REVISION` — see the guidance in `CHANGELOG.md`).
3. **Regenerate:**
   ```bash
   python3 build_v04.py --export-lua
   ```
   This rewrites `data/Norway.lua` (stamping `meta.version` + generated date) **and**
   patches the `VERSION` table in `Info.lua` so both always match `VERSION`.
4. **Record the change** in `CHANGELOG.md`.
5. **Redistribute** the whole `.lrplugin` folder. Users replace their copy and the
   new version shows in the dialog + save confirmation.

Running `build_v04.py` with **no** arguments still produces the reference `.txt`
file unchanged.

### How updates affect already-exported / imported keywords — READ THIS

Lightroom matches keywords **by name**, not by any hidden ID. That single fact
drives everything about how an update behaves when a user re-imports:

- **Adding** new keywords (new places, a new section) is **safe** — re-importing
  simply merges the new names in next to the existing ones. This is why **MINOR**
  bumps are low-risk.
- **Renaming** a keyword (fixing a spelling, changing an elevation shown in the
  name like `Galdhøpiggen (2271m)` → `(2469m)`) is the **risky** case: on
  re-import Lightroom treats the new spelling as a **brand-new keyword** and keeps
  the old one too. Photos already tagged stay on the *old* name. Result: duplicates.
  These are **REVISION** bumps — flag them clearly in `CHANGELOG.md`.
- **Removing** a keyword from the master does **not** remove it from anyone's
  catalog — import only ever adds/merges, it never deletes. Old keywords linger
  until the user deletes them manually.
- **Moving** a keyword to a different parent (e.g. restructuring the hierarchy) can
  also create a duplicate under the new parent while the old one remains. These are
  **MAJOR** bumps.

**Practical guidance for keeping updates clean:**

- Treat keyword **names as stable identifiers**. Avoid renaming once published; if
  you must, list the exact old → new mapping in `CHANGELOG.md` so users can find and
  merge/delete the old keyword (Lightroom: right-click a keyword ▸ *Delete*, or drag
  one keyword onto another to merge).
- Because elevations are embedded in mountain names, decide up front whether that is
  worth the rename risk. If elevation accuracy will keep changing, consider dropping
  it from the *name* and keeping it elsewhere — but that itself is a one-time MAJOR
  rename, so do it deliberately.
- The generated filename carries the date (`…-YYYYMMDD.txt`) and the dialog shows the
  data version, so you can always tell which master a given export came from.
- Prefer **additive** releases. Batch risky renames into clearly-communicated MAJOR
  releases rather than sprinkling them into routine updates.

---

## Regenerating the bundled data (quick reference)

```bash
python3 build_v04.py --export-lua   # rewrites data/Norway.lua + patches Info.lua VERSION
python3 build_v04.py                # rebuilds the reference .txt only
```

---

## Notes

- The data table is loaded with `dofile()` relative to the plugin folder
  (`_PLUGIN.path`), so no network access is required at any point.
- `Generator.lua` is a **pure Lua** module — it performs only string/table work
  and has **no Lightroom SDK imports**, which keeps the plugin loadable.
- Currently scoped to **Norway**. The architecture (one data file per country +
  a country-agnostic generator) is designed to extend to more countries later.
