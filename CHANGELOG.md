## [0.9.169] – 2026-09-03
### Changed
- **List Overview**: Scrolled_view bredde økt fra 980 px til 1000 px

## [0.9.168] – 2026-09-03
### Changed
- **List Overview**: Scrolled_view bredde økt fra 950 px til 980 px

## [0.9.167] – 2026-09-03
### Changed
- **List Overview**: Scrolled_view bredde satt til 950 px; bakgrunnsfarge lysnet til `0.88` (mellom mørkegrå `0.835` og dialogbakgrunn `0.90`)

## [0.9.166] – 2026-09-03
### Fixed
- **List Overview**: Scrolled_view fikk mørkegrå bakgrunn og full bredde (`width = CONTENT_W` — `fill_horizontal` virker ikke på `f:scrolled_view` i LR SDK)

## [0.9.165] – 2026-09-03
### Changed
- **List Overview**: Landrader pakket inn i `f:scrolled_view` (høyde 390 px, ca. 15 synlige rader). Overskriftsrad og separator forblir alltid synlig utenfor scroll-vinduet

## [0.9.164] – 2026-09-03
### Changed
- **New Zealand Remote Islands**: Erstattet «Subantarctic Islands» med de individuelle øyene. Remote Islands er nå: Auckland Islands, Bounty Islands, Campbell Island, Chatham Islands, Great Barrier Island, Kermadec Islands, Poor Knights Islands, The Antipodes Islands, The Snares (alfabetisk sortert)
- **New Zealand Islands (Selections)**: Fjernet Kermadec Islands, Great Barrier Island og Antipodes Island Group fra Islands-utvalget (disse ligger nå under Remote Islands)

## [0.9.163] – 2026-09-03
### Fixed
- **Keyword Builder UI**: Indre `scrolled_view` for kontinenter med > 4 land (Europa) fikk korrekt mørkegrå bakgrunn og skjult vertikal scrollbar-slider (`vertical_scroller = false`) — scroll med trackpad/mus fungerer fortsatt

## [0.9.162] – 2026-09-03
### Fixed
- **Sør-Afrika Remote Islands**: Beholder kun Marion Island og Prince Edward Island som Remote Islands (sub-antarktiske, tusenvis av km fra fastlandet)
- **Sør-Afrika Islands**: Bird Island, Dassen Island, Malgas Island, Robben Island og Saint Croix Island ligger nå under Selections > Islands (kystnære isolerte øyer). Lagt til «Dassen Island» (engelsk navn) i data-filen

## [0.9.161] – 2026-09-03
### Fixed
- **Sør-Afrika Remote Islands**: Erstattet arkipelagnavnet «Prince Edward Islands» med de individuelle øyene; lagt til 5 kystnære isolerte øyer — Bird Island, Dassen Island, Malgas Island, Marion Island, Prince Edward Island, Robben Island, St Croix Island (alfabetisk sortert)

## [0.9.160] – 2026-09-03
### Changed
- **Keyword Builder UI**: Land sorteres nå alfabetisk innenfor hvert kontinent
- **Keyword Builder UI**: Kontinenter med mer enn 4 land bruker nå `f:scrolled_view` (høyde 107) slik at lista kan scrolles (gjelder p.t. Europa med 6 land)

## [0.9.159] – 2026-09-03
### Fixed
- **Remote Islands**: Alle lister sortert alfabetisk for alle land (Norge, USA, Chile, Australia, Nederland)

## [0.9.158] – 2026-09-03
### Fixed
- **Argentina**: Fjernet «Islas Malvinas» fra Remote Islands — Falklandsøyene er britisk territorium og er allerede listet under United Kingdom

## [0.9.157] – 2026-09-03
### Fixed
- **Botswana**: Sub-distriktet under «South East District» rettet fra «Gaborone» til «Ramotswa» (riktig geografisk navn — Gaborone er et eget distrikts-nivå)

## [0.9.156] – 2026-09-02
### Added
- **9 nye land**: Argentina, Antarktis, Australia, Rwanda, Sør-Afrika, Ecuador, Botswana, Ungarn, Nederland
  - Hvert land har data-fil med regioner/fylker, kommuner, byer, fjell, innsjøer, elver, øyer, nasjonalparker og utsiktspunkter
  - `ListVerification.lua` oppdatert med dofile, addCountry, LABELS, WIKIDATA_TYPES og WIKIDATA_LANG for alle 9 land
  - `WorldMap.lua` oppdatert med polygondata (_PP), ORDER, ISO-koder og NM-visningsnavn for alle 9 land

## [0.9.155] – 2026-09-02
### Changed
- United Kingdom — Remote Islands: «South Georgia and the South Sandwich Islands» er delt opp i to separate oppføringer: «South Georgia» og «South Sandwich Islands». Lista er nå sortert alfabetisk (18 oppføringer totalt).

## [0.9.154] – 2026-09-02
### Changed
- **United Kingdom — Remote Islands utvidet**: `remoteIslandNames` er utvidet fra 4 til 17 oppføringer (alle 14 britiske oversjøiske territorier + 2 Crown Dependencies + Gibraltar). Nye territorier:
  - *Crown Dependencies*: Channel Islands, Isle of Man (beholdt)
  - *BOT Europa*: Gibraltar (beholdt)
  - *BOT Sør-Atlanteren*: Falkland Islands (beholdt), South Georgia and the South Sandwich Islands, Saint Helena, Ascension Island, Tristan da Cunha
  - *BOT Karibia*: Bermuda, Anguilla, British Virgin Islands, Cayman Islands, Montserrat, Turks and Caicos Islands
  - *BOT Stillehavet*: Pitcairn Islands
  - *BOT Indiahavet*: British Indian Ocean Territory
  - *BOT Antarktis*: British Antarctic Territory
  - Akrotiri og Dhekelia (militærbase på Kypros) er utelatt — ikke et fotografisk reisemål

## [0.9.153] – 2026-09-02
### Reverted
- Keyword List Builder — Country-panelet: tilbakeført til uendret linjeavstand (v0.9.150-tilstand). Forsøkene i v0.9.151 og v0.9.152 på å redusere luft mellom kontinentene hadde ingen synlig effekt og er annullert.

## [0.9.152] – 2026-09-02
### Fixed
- Keyword List Builder — Country-panelet: luft mellom kontinentene er nå eliminert for kollapsede kontinenter.
  Rot-årsak: hvert land-rad og Include-slideren var separate barn i parent-kolonnen med egne `visible`-bindinger; Lightroom legger til `spacing` også mellom usynlige elementer. Løsning: alt utvidbart innhold per kontinent er samlet i én enkelt `f:column` med `visible`-binding. Når kontinentet er kollapsert, er wrapper-kolonnen én enkelt 0-høyde enhet uten indre mellomrom.

## [0.9.151] – 2026-09-02
### Changed
- Keyword List Builder — Country-panelet: redusert linjeavstand (spacing 2 px, spacer 1 px) for å få plass til 2–3 flere rader i vinduet uten rulling
- List Overview: fjernet «New country»-knappen (oppretter bare en tom Lua-mal uten faktiske data; nye land legges inn manuelt via buildskript)

## [0.9.150] – 2026-09-02
### Changed
- List Overview: «Country»-kolonnen er bredere (90 → 130 px) så «United Kingdom» vises fullt ut
- List Overview: «File name»-kolonnen er smalere (150 → 110 px); «data/»-prefikset er fjernet fra visningen

## [0.9.149] - 2026-09-02
### Fixed
- **Verdenskart — 4 nye land vises nå**: `WorldMap.lua` hadde ikke polygondata for Grønland, Finland, Storbritannia og India, så de manglet på Intro-kartet (både statisk PNG og interaktivt HTML-kart).
  - Lagt til polygonringer i `_PP` for alle 4 land fra Natural Earth 110m-geometri med samme ekvirektangulære projeksjon som de øvrige landene.
  - Lagt til landene i `ORDER` (tegnerekkefølge) og ISO 3166-1-koder i `ISO`-tabellen og `NM`-objektet: Grønland 304, Finland 246, Storbritannia 826, India 356.

## [0.9.148] - 2026-09-02

### Fixed
- **Storbritannia — county-navn ryddet**: `data/UnitedKingdom.lua` hadde 20 county-navn med administrative prefiks/suffiks fra GeoNames som gir dårlige nøkkelord. Fjernet «Borough of …», «City and Borough of …», «Metropolitan Borough of …», «Royal Borough of …» og «… County Borough» slik at navnene nå er de vanlige stedsnavnene (f.eks. «Borough of Bolton» → «Bolton», «City and Borough of Birmingham» → «Birmingham», «Caerphilly County Borough» → «Caerphilly»). Ingen navnekollisjoner mellom counties.

### Verified
- **Storbritannia — hierarki bekreftet korrekt**: United Kingdom → nasjon (England/Scotland/Wales/Northern Ireland) → county → by. 4 nasjoner, 185 counties, 1114 byer. De tilsynelatende avkortede navnene i Verification Monitor («Antrim and», «Armagh City Banbridge») er komplette i dataene («Antrim and Newtownabbey», «Armagh City Banbridge and Craigavon») — bare avkortet i den smale UI-kolonnen.

## [0.9.147] - 2026-09-02

### Fixed
- **Grønland — admin-hierarki (Kommune → Distrikt → By)**: `data/Greenland.lua` hadde et feilaktig mellomnivå. GeoNames ga bare Kujalleq nedlagte ADM2-enheter (Nanortalik/Narsaq/Qaqortoq Municipality — slått sammen i 2009), mens de andre 4 kommunene fikk sitt eget navn duplisert som eneste «Area». Erstattet med korrekt geografisk struktur basert på bygdedistrikter (de gamle før-2009-kommunene), hver med by + tilhørende bygder:
  - **Avannaata** (4 distrikter): Ilulissat, Qaanaaq, Upernavik, Uummannaq
  - **Kujalleq** (3): Nanortalik, Narsaq, Qaqortoq
  - **Qeqertalik** (4): Aasiaat, Kangaatsiaq, Qasigiannguit, Qeqertarsuaq
  - **Qeqqata** (2): Maniitsoq, Sisimiut
  - **Sermersooq** (5): Ittoqqortoormiit, Ivittuut, Nuuk, Paamiut, Tasiilaq
  - Totalt 5 kommuner → 18 distrikter → 71 byer/bygder.
- **Etiketter for Grønland**: `LABELS` endret til Municipality / District / Town (var Municipality / Area / City).
- **Dedup**: Fjernet Saattut fra `islands[]` (finnes nå som bygd i Uummannaq-distriktet). Grønland-øyer: 96.

## [0.9.146] - 2026-09-02

### Added
- **4 nye land**: Lagt til `data/Greenland.lua`, `data/Finland.lua`, `data/UnitedKingdom.lua` og `data/India.lua`. Data er hentet fra GeoNames (CC BY 4.0) og filtrert med kurerte lister.
  - **Grønland**: 1 nasjonalpark, 1 naturreservat, 50 fjell (inkl. Gunnbjørn Fjeld 3694 m via NTK-kode), 57 fjorder, 97 øyer (3 duplikater fjernet), 100 innsjøer, 100 elver, 3 utsiktspunkter, 5 kommuner, 7 regioner.
  - **Finland**: 34 nasjonalparker, 130 naturreservater, 50 fjell, 100 innsjøer, 100 elver, 100 øyer, 8 utsiktspunkter, 18 regioner (Åland-øyer ikke i GeoNames FI — legg til manuelt).
  - **Storbritannia**: 15 nasjonalparker, 59 naturreservater, 50 fjell (Ben Nevis 1345 m øverst), 99 øyer (Isle of Wight fjernet — duplikat), 100 innsjøer, 100 elver, 15 utsiktspunkter, 4 nasjoner (England/Scotland/Wales/Northern Ireland), 185 county-/council-areas.
  - **India**: 31 nasjonalparker, 200 naturreservater, 50 fjell (Kangchenjunga 8505 m i GeoNames, mountain_max=8586), 100 øyer, 100 innsjøer, 100 elver, 9 utsiktspunkter, 36 stater/territorier, 763 distrikter.
- **ListVerification.lua oppdatert**: Lagt til `dofile`-linjer, `addCountry`-oppføringer og poster i `LABELS`, `WIKIDATA_TYPES` og `WIKIDATA_LANG` for alle 4 nye land.
- **GeoNames NTK-kode**: `extract_mountains()` inkluderer nå nunatakker (NTK) — nødvendig for Gunnbjørn Fjeld på Grønland.
- **Dedup-sjekk**: Fjernet overlapp mellom `islands[]` og admin-hierarki: Grønland (Kangaamiut, Qeqertarsuaq, Uummannaq), UK (Isle of Wight).

## [0.9.145] - 2026-09-02

### Fixed
- **Dobbeltoppføringer i islands-seksjoner**: Øyer som allerede er listet som admin-enheter (fylker, kommuner, regioner, provinser eller fjernøy-grupper) er fjernet fra `islands`-valglistene for å unngå dupliserte nøkkelord i hierarkiet.
  - **Norge** (`Norway.lua`): Fjernet 20 øykommuner: Askøy, Bømlo, Dønna, Fedje, Frøya, Giske, Hitra, Karmøy, Leka, Nøtterøy, Osterøy, Radøy, Røst, Senja, Smøla, Stord, Tjøme, Træna, Utsira, Vega. Islands-listen redusert fra 100 til 80.
  - **Sverige** (`Sweden.lua`): Fjernet Gotland (fylke), Lidingö og Orust (kommuner). Islands-listen redusert fra 4698 til 4695.
  - **Chile** (`Chile.lua`): Fjernet Tierra del Fuego (provins). Islands-listen redusert fra 100 til 99.
  - **Ny-Zealand** (`NewZealand.lua`): Fjernet 5 øyer som allerede finnes i `remote_islands`-seksjonen: Bounty Islands, Campbell Island, Chatham Islands, Pitt Island, Three Kings Islands. Islands-listen redusert fra 100 til 95.
  - Panama, USA og Kenya: Ingen overlapp funnet — ingen endringer.

## [0.9.144] - 2026-09-02

### Fixed
- **Norway mountain_max**: Rettet feil høyde for Galdhøpiggen fra 2271 m til 2469 m. Årsaken var at `build_v04.py` brukte GeoNames-kolonnen `dem` (SRTM-modell) i stedet for den autoritative `elevation`-kolonnen. `elev()`-funksjonen er nå oppdatert til å foretrekke `elevation`-verdien (ignorerer 0) og faller tilbake til `dem` kun hvis `elevation` mangler. COUNTRIES-tabellen i `ListVerification.lua` er tilsvarende oppdatert.

### Added
- **Manglende kategorier — Chile, Kenya, New Zealand**: Lagt til seksjoner for fjorder, innsjøer, elver, øyer og utsiktspunkter i `data/Chile.lua`, `data/Kenya.lua` og `data/NewZealand.lua`. Data er hentet fra GeoNames (CC BY 4.0) for hvert land og kuratert til topp-100 per kategori (VP-grense: 15).

### Changed
- **Dynamiske slider-maks**: `np_max`, `nr_max`, `fj_max`, `lk_max`, `rv_max`, `is_max` og `vp_max` i COUNTRIES-tabellen beregnes nå automatisk av `addCountry()`-funksjonen i `ListVerification.lua`. Hardkodede verdier er fjernet fra alle landoppføringer. Policy: NP/NR = fullt antall; FJ/LK/RV/IS/VP = min(antall, 100).
- **Runtime «New country»**: Oppdatert patching-kode til å sette inn `addCountry { ... }` i stedet for det gamle `{ id = ... }`-formatet, slik at dynamiske slider-maks fungerer også for brukeropprettede land. Regex-mønster for UnitedStates-ankerpunkt er tilsvarende oppdatert.

## [0.9.121] - 2026-09-02

### Changed
- ListVerification (Keyword List Builder — Country column):
  1. **Fjernet kontinent-Include-slider**: Hele `f:column { visible=… f:row { "Include:" slider contDetailLabel } }` blokken per kontinent er fjernet. `detailKey` / `_detail`-props initialiseres ikke lenger, og `contDetailLabel`-hjelperfunksjonen er slettet.
  2. **Rebuild-on-click for kontinent-ekspandering**: Kontinentknappens `action` kaller nå `switchTab(TAB_IDS.KB)` i tillegg til å toggle `props[contKey]`, slik at panelet bygges på nytt ved ekspandere/kollapse — samme mønster som land-veksling. Dette omgår LR SDK-feilen der `visible=false` beholder layoutplass.
  3. **Scrolled view i Country-kolonnen**: `countryColumn` er pakket inn i en `f:scrolled_view` med `height=100`, `width=KB_COL_W_COUNTRY-20`, `horizontal_scroller=false`. Group_box bruker nå `countryScrollView` i stedet for `countryColumn` direkte. (Testverdien 100 px er ment for verifisering; juster etter behov.)

## [0.9.82] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed the county list not filling the middle column down to the version text (large empty gap below the last county). After six unsuccessful `fill_vertical` attempts (v0.9.74–v0.9.81), the conclusion is that `fill_vertical=1` on an `f:scrolled_view` is unreliable in the LR SDK — the scrolled_view locks its content-based height at construction and does not expand to fill its parent, regardless of the fill chain. Fix: switched to a **deterministic explicit height** (`KB_COUNTY_LIST_H = 300`) on the county `f:scrolled_view`, sized so the list fills down to the version text, matching the tall left country column. The middle column was also converted to an `f:group_box` (title `""`) so it visually matches the left country column and right features column, which are already group_boxes.

## [0.9.81] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed county scrolled_view not filling dialog height down to bottom version text. Root cause: v0.9.79 added an intermediate `f:column { fill_vertical=1 }` wrapper between `countySection` and `countyListContainer` (scrolled_view), which breaks the fill_vertical chain in LR SDK — nested fill_vertical containers do not propagate fill correctly. Fix: removed the wrapper; `countyListContainer` is now a direct child of `countySection`, restoring the single-level fill chain: `countySection { fill_vertical=1 }` → `countyListContainer { fill_vertical=1 }`. The scrolled_view now expands correctly to fill remaining vertical space.

## [0.9.80] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed crash when clicking "Select More" for any country — `[ListVerification.lua]:611: attempt to call global 'switchTab' (a nil value)`. Root cause: `switchTab` is defined *after* `makeSwitchAction` in the file (at the dialog setup section, line ~1053), so `makeSwitchAction` could not close over it as an upvalue. In plain button `action` callbacks (v0.9.78 and earlier) LR SDK silently swallowed the error; wrapping the body in `startAsyncTask` (v0.9.79) caused the error to propagate visibly. Fix: forward-declared `local switchTab` before `makeSwitchAction`, then changed the definition site from `local function switchTab(...)` to `switchTab = function(...)` so the same upvalue is assigned where `contents` is in scope.

## [0.9.79] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed two remaining layout issues in the county panel.
  1. **Country switch did not rebuild panel** — `makeSwitchAction` returned a plain function used as a button `action` callback. In LR SDK, button `action` callbacks run outside a task context, so `LrDialogs.stopModalWithResult` (called inside `switchTab`) silently failed. Fix: wrapped the callback body in `LrTasks.startAsyncTask(...)`. The panel now correctly closes and rebuilds via the `while keepOpen` loop when the user switches country.
  2. **County list not filling dialog height** — `fill_vertical=1` on `f:scrolled_view` as a direct child of `countySection` did not expand the scrolled_view to fill remaining space. Root cause: a two-level `fill_vertical` chain is required in the LR SDK for scrolled views. Fix: restored an intermediate `f:column { fill_vertical=1 }` wrapping the Select All checkbox, the scrolled_view, and the version label. The chain is now `countySection { fill_vertical=1 }` → `f:column { fill_vertical=1 }` → `countyListContainer { fill_vertical=1 }`, which expands the scrolled_view correctly.
  3. **activePanelCountry upvalue** — `buildBuilderPanel` now reads a shared `local activePanelCountry` upvalue (set at startup and updated by `makeSwitchAction`) instead of looking up `props.active_country_id` at construction time, eliminating any prop-timing race.

## [0.9.78] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed scrolled_view not filling available height (only ~15 US states visible; county box ending midway for Norway). Root cause: `fill_vertical=1` on `f:scrolled_view` only works when the scrolled_view is a **direct** child of the `fill_vertical=1` `f:column` — it does not cascade through an intermediate `f:column`. Fix: removed the intermediate inner `f:column { fill_vertical=1 }` wrapper that contained the Select All checkbox and the scrolled_view. Both are now direct children of `countySection { fill_vertical=1 }`. The scrolled_view now correctly fills the remaining height after the header items, Select All, and version text.

## [0.9.77] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Eliminated empty rows after last county. Root cause (definitive): `visible=false` in LR SDK preserves layout space for ALL element types — columns, scrolled_views, AND leaf-level checkboxes. The only fix is to build exactly the right number of rows at construction time. Solution: `buildBuilderPanel()` now reads `props.active_country_id` (set by `loadCountryState` before panel construction) and builds exactly `#activeCountry.countyNames` checkbox rows — no hidden slots, no wasted space. When the user clicks "Select More" for a different country, `makeSwitchAction` calls `switchTab(TAB_IDS.KB)` after `loadCountryState`, which triggers the existing `while keepOpen` dialog loop to close and rebuild the panel with the new country's exact county count. Remote Islands section is also exact: only rendered if `#remoteIslandNames > 0`. Removed all `show_county_i`, `show_ri_i`, and `county_visible_*` props (no longer needed).

## [0.9.76] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed county list layout — hidden scrolled_views (visible=false) still consumed fill_vertical space in v0.9.75, causing large empty gaps. Root cause: `visible=false` on any element hides it but does NOT remove it from layout flow; fill_vertical still distributes space equally to all 7 elements. Fix: replaced 7 per-country scrolled_views with ONE single scrolled_view containing `maxCounties` (51) slots. Each slot is a `f:checkbox` with `visible = LrView.bind("show_county_i")` directly on the leaf element. `loadCountryState` sets `show_county_i = true` for slots within the active country's count and `false` for the rest. Removed all `county_visible_*` props (no longer needed).
- ListVerification (Keyword List Builder): Remote Islands section now uses individual `show_ri_i` props per island, set in `loadCountryState`. Removed "Remote Islands (All)" master toggle (not required).

## [0.9.75] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed stacking regression — definitively. Root cause confirmed: LR SDK ignores `visible` bindings on `f:column` containers entirely. The fix: move the `visible = LrView.bind("county_visible_<id>")` binding directly onto `f:scrolled_view` (a concrete SDK control that does honour `visible` bindings), removing the now-redundant `f:column` wrapper. Only the active country's scrolled_view is shown; all others are hidden.

## [0.9.74] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed stacking regression — root cause now definitively identified. LR SDK does NOT support `transform` functions on the `visible` property of `f:column`: the transform is silently ignored and the element stays `visible=true` at all times. This caused all 7 countries' county lists to stack simultaneously in v0.9.68–v0.9.73. Fix: replaced transform-based binding with one dedicated boolean prop per country (`county_visible_<id>`), initialised to `false` and updated in `loadCountryState` (all set to `false`, then the active country set to `true`). Each wrapper column now uses `visible = LrView.bind("county_visible_<id>")` — a direct boolean binding, the same pattern that correctly drives continent section visibility.

## [0.9.73] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed stacking regression (present since v0.9.68, root cause now confirmed). Root cause: each per-country `f:column { visible=LrView.bind{...} }` wrapper was missing `bind_to_object = props`. Without it, LR SDK cannot resolve the `active_country_id` prop from the binding and silently defaults to `visible=true` for every wrapper — causing all 7 countries' county lists to stack simultaneously. Fix: add `bind_to_object = props` to `listContainerSpec` and to each wrapper column.
- ListVerification (Keyword List Builder): Fixed missing scrollbar (slider) on the right side of the county list. Root cause: the previous workaround used a fixed `height=600` on each scrolled_view to avoid fill_vertical stacking, but this prevented the scrollbar from showing correctly. Now that the visible binding works, `fill_vertical=1` is restored on both the wrapper and the scrolled_view, so the county list fills the dialog height and the scrollbar appears when needed (e.g. United States with 51 states).

## [0.9.72] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed all-countries county rows stacking on top of each other (regression since v0.9.68). Root cause: `fill_vertical=1` on each country's `f:scrolled_view` prevented its `f:column { visible=false }` wrapper from collapsing to zero height, so hidden countries still occupied space. Fix: replaced shared-slot approach with per-country `f:scrolled_view` elements (no `fill_vertical`); each scrolled_view has `height=600` so it fills the dialog and shows a scrollbar only when content exceeds 600 px. County names are now read directly from the country data table, eliminating empty-row and missing-title issues.

## [0.9.71] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed 36 empty checkbox rows showing below the last county. Root cause: `f:row` does not support the `visible` property in LR SDK — the binding was silently ignored and all 51 slots were always rendered. Fix: changed all county/RI slots from `f:row` to `f:column`, which does honour the `visible` binding.
- ListVerification (Keyword List Builder): Fixed grey county box not filling all the way down to the version text. Root cause: redundant `f:column { fill_vertical=1 }` wrapper around the `f:scrolled_view` broke the fill_vertical chain. Fix: removed the wrapper; `countyListContainer` is now the `f:scrolled_view` directly.

## [0.9.70] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed persistent stacking regression (introduced v0.9.68, not resolved in v0.9.69). Root cause: `fill_vertical=1` on the inner `f:scrolled_view` inside a `visible=false` wrapper column prevents the wrapper from collapsing to zero height — the LR SDK allocates space for all 7 countries simultaneously. Fix: replaced the per-country scrolled_view approach with a single shared `f:scrolled_view`. Row visibility is now driven by `county_name_i` / `ri_name_i` props (set by `loadCountryState`), which collapse rows cleanly inside a scrolled_view because the transform-based `visible` binding works reliably in this direction. Only the active country's county rows are shown.

## [0.9.69] - 2026-09-01

### Fixed
- ListVerification (Keyword List Builder): Fixed v0.9.68 regression where all 7 countries' county lists stacked on top of each other. Root cause: `fill_vertical=1` on the per-country `f:column` wrapper (even with `visible=false`) prevented height collapse in the outer plain-column context. Fix: removed `fill_vertical=1` from the outer wrapper; kept it only on the `f:scrolled_view` inside, and on the outer `listContainerSpec` column.
- ListVerification (Keyword List Builder): County names are now sorted alphabetically (A–Z) for all countries.

### Added
- ListVerification (Keyword List Builder): Remote Islands section added after the county list for countries that have remote territories. A separator line separates counties from islands. A "Remote Islands (All)" master toggle selects/deselects all island checkboxes at once. Individual island checkboxes are indented below the master toggle.
  - Norway: Svalbard, Jan Mayen, Peter 1. Island, Bouvetøya, Dronning Mauds Land
  - United States: Puerto Rico, Guam, US Virgin Islands, American Samoa, Northern Mariana Islands
  - Chile: Isla de Pascua, Archipiélago Juan Fernández
  - New Zealand: Chatham Islands, Subantarctic Islands
- Generator: Remote islands are now output per-island (each gets its own level-4 keyword under the country). Svalbard and Jan Mayen still get their named settlements as sub-keywords (level 5) when detail level ≥ 2.

## [0.9.68] - 2026-08-31

### Fixed
- ListVerification (Keyword List Builder): Phantom empty checkboxes below last county are permanently eliminated. Root cause (confirmed): `visible=false` on an `f:column` inside a `f:scrolled_view` does not collapse height — LR SDK pre-calculates the scrolled_view layout at construction time, so hidden rows still occupy space. Fix: replaced the single shared `scrolled_view` (with `maxCounties` slots, most hidden) with one `f:scrolled_view` per country, each containing exactly the right number of checkboxes. Visibility is now a binding on the outer `f:column` wrapper in plain-column context, where reactive collapse works correctly.
- ListVerification (Keyword List Builder): County column now fills the full height of the dialog (same as Country column). The `fill_vertical=1` chain is complete through all wrapper layers: group_box → countySection → inner column → countyListContainer → per-country column → scrolled_view.
- ListVerification (Keyword List Builder): United States (51 states) and other large countries now show a vertical scrollbar inside the county column, keeping the dialog compact while allowing all states to be reached.


## [0.9.67] - 2026-08-31

### Fixed
- ListVerification (Keyword List Builder): Regression from v0.9.66 — phantom empty checkboxes below last visible county are gone. Root cause: `f:spacer { height=4 }` inside `f:column { visible=false }` wrappers caused LR SDK to allocate height for invisible slots inside the scrolled_view, making the checkbox widget render. Fix: spacers removed from inside county wrappers; `spacing=4` on the parent singleListSpec column is sufficient (same working approach as v0.9.65).
- ListVerification (Keyword List Builder): Same spacer fix applied to Svalbard/Jan Mayen and Remote Islands wrappers — no phantom items for countries where those sections are hidden. Spacing inside those wrappers now handled by `spacing=4` on the wrapper column itself.


## [0.9.66] - 2026-08-31

### Fixed
- ListVerification (Keyword List Builder): County column now matches Country column height (`fill_vertical=1` propagated through group_box → countySection → inner column → scrolled_view; fixed `height=320` removed).
- ListVerification (Keyword List Builder): No more phantom checkbox circles for Svalbard, Jan Mayen and Remote Islands. These items are now wrapped in `f:column { visible=bind }` — identical to the county-slot fix in v0.9.65 — so hidden entries collapse completely.
- ListVerification (Keyword List Builder): Spacing between county slots fixed: `singleListSpec` now uses `spacing=0` and each visible county wrapper contains an explicit `f:spacer { height=4 }`, so invisible slots contribute exactly 0 px of gap.


## [0.9.65] - 2026-08-31

### Fixed
- ListVerification (Keyword List Builder): Empty county slots no longer leave visible circles or blank space. Root cause: LR SDK's `visible=false` on a `f:checkbox` hides only the label text, not the checkbox control itself. Fix: each checkbox is now wrapped in a `f:column` whose `visible` binding collapses the entire row (control + label) when the slot is empty.
- ListVerification (Keyword List Builder): County list restored to `scrolled_view` (height 320 px) so the dialog stays compact when United States is selected (51 states).


## [0.9.64] - 2026-08-31

### Fixed
- ListVerification (Keyword List Builder): Continent collapse/expand now works correctly. The country column was previously a scrolled_view, which prevents reactive visible-binding re-layouts in LR SDK. Changed to a plain column so visible bindings fire properly.
- ListVerification (Keyword List Builder): Blank space below last county in the list is gone. County list changed from fixed-height scrolled_view (250 px) to a plain column that auto-sizes to actual county count.

### Changed
- ListVerification (Keyword List Builder): County checkbox spacing restored to 4 px between items (was incorrectly set to 0 in v0.9.63).


## [0.9.63] - 2026-08-31

### Changed
- ListVerification (Keyword List Builder): Country column widened to 380 px (was 280 px) to better accommodate the continent include-level sliders.
- ListVerification (Keyword List Builder): Counties & Areas column narrowed to 230 px (was 280 px).
- ListVerification (Keyword List Builder): County checkbox list spacing set to 0 (was 4 px) to eliminate blank space left by hidden empty rows.


## [0.9.62] - 2026-08-31

### Fixed
- ListVerification (Keyword List Builder): Continent sections (Europe, Americas, Africa, Oceania) now correctly expand/collapse. Previously only Europe was initialized; all other continents defaulted to nil (hidden). All continents now start expanded.
- ListVerification (Keyword List Builder): Empty county/division rows are now hidden. Previously all 51 checkbox slots were always shown; now only slots with an actual name are visible.
- ListVerification (Keyword List Builder): Version label in Counties column now matches List Overview exactly. Previously read from prefs directly, which could differ from the displayed version.

### Changed
- ListVerification (Keyword List Builder): Country column is now a scrolled view (height 350 px, width 280 px) so all countries are accessible regardless of dialog height.
- ListVerification (Keyword List Builder): All three columns (Country, Counties & Areas, Selections) now use equal width (280 px) for a more balanced layout.


## [0.9.61] - 2026-08-31

### Fixed
- ListVerification: Update button now correctly picks up Action popup changes (Change/Delete) made after Verify without clicking Save. Previously, switching tabs without saving caused those changes to be lost, and Update would report "No changes to apply" even when entries were marked.


## [0.9.60] - 2026-08-31

### Changed
- Generator: Nature categories (Mountains, Fjords, Lakes, Rivers, Islands, Viewpoints) now default to a maximum of 100 entries per country. User-set `*_max` preferences still override the cap.
- Data (all 7 countries): City lists rebuilt from GeoNames — only cities with population ≥ 1000 are retained. `meta.min_city_pop = 1000` added to each country's data file.


## [0.9.59] - 2026-08-31

### Changed
- ListVerification: Column header renamed from "On/Off" to "Show" in List Overview.


## [0.9.58] - 2026-08-31

### Changed
- ListVerification: Slått sammen første og andre avsnitt i introduksjonsteksten på Intro-fanen.
- ListVerification: Ny kolonne "Code" i List Overview mellom "Country" og "File name" med ISO 3166-1 koder (alpha-2 + numerisk, f.eks. NO-578 for Norway).


## [0.9.57] - 2026-08-31

### Changed
- WorldMap: Kartet i Intro-fanen er nå større (600×300 px, var 480×240).
- WorldMap: Aktiverte land vises nå i rødt direkte i plugin-kartet (ikke bare i nettleservisningen). Polygondata fra Natural Earth 110m er innebygd og tegnes med scanline-fill.
- ListVerification: Redusert avstand mellom de tre tekstparagrafene på Intro-fanen.


# Changelog

## v0.9.107 (2026-09-02)
- Country column: 390→400 px. Counties and Selections unchanged at 300 px.

## v0.9.106 (2026-09-02)
- Country column: 380→390 px. Counties and Selections unchanged at 300 px.

## v0.9.105 (2026-09-02)
- Country column: 350→380 px. Counties and Selections unchanged at 300 px.

## v0.9.104 (2026-09-02)
- Country column: 300→350 px. Counties and Selections unchanged at 300 px.

## v0.9.103 (2026-09-02)
- Fix Counties column width: scrolled_view width = KB_COL_W_COUNTY - 20 (accounts for group_box internal padding) so outer column matches 300 px.

## v0.9.102 (2026-09-02)
- Fix Counties column width: replace width=KB_COL_W_COUNTY on scrolled_view with fill_horizontal=1; group_box outer width (300 px) now controls the column width without double-counting padding.

## v0.9.101 (2026-09-02)
- Remove explicit width=KB_COL_W_COUNTY from children inside countyGroupBox (static_text and checkbox were pushing the box wider than 300 px).

## v0.9.100 (2026-09-02)
- Fix Counties group_box missing width=KB_COL_W_COUNTY (300 px); now all three columns have explicit width on their group_box.

## v0.9.99 (2026-09-02)
- Fix Selections column width: move width=KB_COL_W_FEAT from outer f:column to group_box directly (matches Country column pattern).

## v0.9.98 (2026-09-02)
- Selections: 280→300 px. All three columns now 300 px.

## v0.9.97 (2026-09-01)
- Selections: 250→280 px.

## v0.9.96 (2026-09-01)
- Country: 350→300 px, Counties: 350→300 px, Selections: 300→250 px.

## v0.9.95 (2026-09-01)
- Country: 400→350 px, Counties: 300→350 px, Selections: 250→300 px.

## v0.9.94 (2026-09-01)
- Fix Country group_box missing width=KB_COL_W_COUNTRY (400 px); constant was defined but never applied to the layout.

## v0.9.93 (2026-09-01)
- Selections column: 300→250 px.
- Save button label changed to "Save setting" (was "Save settings for <country>").

## v0.9.92 (2026-09-01)
- Country column: 380→400 px, Counties: 230→300 px, Selections: add KB_COL_W_FEAT=300 px (was fill_horizontal).

## v0.9.91 (2026-09-01)
- Revert v0.9.90 county column change; restore scrolled_view for all countries (as in v0.9.89).

## v0.9.90 (2026-09-01)
- Use f:column (no system border) for county lists with ≤25 items; keep f:scrolled_view for large lists (e.g. USA with 51 states).

## v0.9.89 (2026-09-01)
- Add border_width=0 on county scrolled_view to suppress system-drawn border.

## v0.9.88 (2026-09-01)
- Set county scrolled_view border_color to match background (0.835) so border is invisible.

## v0.9.87 (2026-09-01)
- Change county scrolled_view background_color from panelGrey (0.878) to LrColor(0.835) to match group_box background.

## v0.9.86 (2026-09-01)
- Adjust KB_COUNTY_LIST_H from 325 to 327 px.

## v0.9.85 (2026-09-01)
- Reduce KB_COUNTY_LIST_H from 330 to 325 px.

## v0.9.84 (2026-09-01)
- Increase KB_COUNTY_LIST_H from 310 to 330 px.

## v0.9.83 (2026-09-01)
- Increase KB_COUNTY_LIST_H from 300 to 310 so county scrolled_view matches country column height. — Geography Keyword Builder

All notable changes to the plugin and its bundled data are recorded here.
The version in `VERSION` is the single source of truth; `build_v04.py --export-lua`
stamps it into `data/Norway.lua` (`meta.version`) and into `Info.lua` (`VERSION`).

Versioning follows `MAJOR.MINOR.REVISION`:

- **MAJOR** — structural changes to the keyword hierarchy (new levels, renamed
  sections). May require re-importing and cleaning up old keywords in the catalog.
- **MINOR** — new data or new options (added places, new sections/toggles).
  Safe additive changes.
- **REVISION** — fixes to existing names/data (typo fixes, corrected elevations).
  May create duplicate keywords on re-import if a keyword *name* changed — see the
  "Updating the master list" section of README.md.

---

## 0.9.56 — 2026-08-31
### Changed
- **Intro tab — Alternativ A** — Erstattet den Lua-genererte PNG-rektangelkartet med:
  1. **Statisk verdenskart** (`worldmap_bg.png`, 480x240) generert fra Natural Earth
     110m GeoJSON med ekte landgrenser. Bundlet i plugin-mappen. Plugin-land er blå;
     havområder er lyseblå; øvrig land er lysegrå.
  2. **«Show Interactive Map in Browser»-knapp** — åpner en d3.js/topojson-basert
     interaktiv HTML-fil i systemets nettleser. Kartet reflekterer gjeldende On/Off-
     innstillinger: blå = støttede land, rød = aktiverte land. Krever internett i
     nettleseren for å laste CDN-ressurser (jsDelivr).
- **WorldMap.lua** — fullstendig omskrevet; genererer nå HTML i stedet for PNG.

## 0.9.55 — 2026-08-31
### Fixed
- **WorldMap.lua: os.getenv sandbox error** — `os.getenv` is not available in
  Lightroom's Lua sandbox.  Replaced with `_PLUGIN.path` (always accessible) for
  the cache-file output path, and added an explicit `local LrPathUtils = import
  'LrPathUtils'` at module level so the import is self-contained.

## 0.9.54 — 2026-08-31
### Added
- **Intro tab** — New first tab in the Geography Keyword Builder window.
  - Displays a 480×240 world-map overview image generated in pure Lua at runtime (no
    external dependencies or image assets required).
  - Map colour coding: light grey = all land; steel blue = the 7 plugin-supported
    countries; light red = countries currently enabled (On checkbox); light blue = ocean.
  - Map is cached and only regenerated when the enabled-country set changes.
  - Includes placeholder welcome text describing the plugin and its tabs.
- **WorldMap.lua** — New module; pure Lua 5.1 PNG encoder using deflate stored blocks,
  CRC32 (XOR-table based), and Adler-32. No external libraries required.

## 0.9.53 — 2026-08-31
### Added
- **List Overview — On/Off column** — A checkbox column (first column) in List Overview
  controls which countries appear in the Keyword List Builder.
  - Checked countries appear first in List Overview (alphabetical within group),
    unchecked countries follow (also alphabetical).
  - If no country is checked, List Overview and Keyword List Builder both show all
    countries alphabetically (no filtering applied).
  - The On/Off setting persists across sessions via plugin preferences.

## 0.9.52 — 2026-08-31
### Changed
- **Unified window** — «Keyword List Builder» and «List Verification» are now
  merged into a single **Geography Keyword Builder** window with four tabs:
  Keyword List Builder | List Overview | Verification Monitor | Help.
  The Library menu now shows one item instead of two.
  The Generate button lives inside the Keyword List Builder tab; the window stays
  open after generating.

## 0.9.51 — 2026-08-31
### Fixed
- **Kenya** — Bykeywords (Nairobi, Mombasa, Kisumu, Nakuru, Eldoret m.fl.) vises
  nå korrekt i Verification Monitor. Alle `primary_city`-felt er konvertert til
  `cities`-arrays slik at `extractGeoData` plukker dem opp (79 sub-counties med by).
  Migori by er flyttet til korrekt sub-county (Suna East).
### Added
- **New Zealand — Remote Islands** — Åtte øygrupper lagt til som ny seksjon under
  New Zealand: Chatham Islands (med bosetninger Waitangi, Te One, Port Hutt), Pitt
  Island, Auckland Islands, Campbell Island, Antipodes Islands, Snares Islands,
  Bounty Islands og Three Kings Islands. Aktiveres via nytt avkryssningsfelt
  «Remote Islands» i divisjonslisten.

## 0.9.50 — 2026-08-30
### Added
- **Chile** — 16 regions with provinces and municipalities. Includes national
  parks (20), nature reserves, and mountains up to Ojos del Salado (6893 m).
  Continent tag: Americas.
- **Kenya** — All 47 counties with sub-counties. Includes national parks,
  nature reserves, and mountains up to Mount Kenya (5199 m).
  Continent tag: Africa.
- **New Zealand / Aotearoa** — 16 regions with territorial authorities (districts
  and cities). Includes 14 national parks, nature reserves, and mountains up to
  Aoraki Mount Cook (3724 m). Continent tag: Oceania.
### Fixed
- **Generator.lua** — The continent keyword (level 2 under "World") was
  hardcoded to "Europe" for all countries. It now reads
  `data.meta.continent` with "Europe" as a fallback, so Chile, Kenya and
  New Zealand generate the correct continent keyword.

## 0.9.49 — 2026-08-30
### Changed
- **Update no longer requires a plugin reload to re-verify.** After writing the
  data file, the Update action now calls `dofile()` on the updated file and
  rebuilds `GEO[cid]` in memory, then clears `verInited[cid]`. The user can
  click "Verify" immediately and see the updated names without reloading the
  plugin. A plugin reload is still needed for the **Keyword List Builder** tab
  to pick up the new names (it loads data in a separate `dofile()`). The
  success message now says "You can run Verify again immediately" and notes
  that only the Keyword List Builder requires a reload.

## 0.9.48 — 2026-08-30
### Fixed
- **Update crashed on first use with "attempt to index global 'labels' (a nil value)".**
  The `labels` variable (`LABELS[cid] or DEFAULT_LABELS`) was only defined in the
  Verification Monitor panel, not in the Update button action. Added
  `local labels = LABELS[ cid ] or DEFAULT_LABELS` inside the Update action
  body immediately after `local cid` and `local geo`.

## 0.9.47 — 2026-08-30
### Fixed
- **Update button did nothing (no dialog, no date stamp).** The `action = function()`
  callback for the Update button in List Overview was not wrapped in
  `LrTasks.startAsyncTask`. All `LrDialogs` calls (confirm, message,
  presentModalDialog) require a task context and silently fail when called from a
  plain synchronous UI callback. Wrapped the entire Update action body in
  `LrTasks.startAsyncTask(function() … end)`. The Update button now shows the
  confirmation dialog, applies changes, and writes the Last Update timestamp.

### Data
- **Norway.lua 0.5.1:** Replaced bilingual municipality names with Norwegian-only
  forms. "Raarvihke - Røyrvik" → "Røyrvik"; "Snåase - Snåsa" → "Snåsa"
  (primary_city also updated to "Snåsa"). These official bilingual names were
  repeatedly flagged as conflicts by the Verification Monitor on every Verify run
  because the Wikidata lookup finds only the Norwegian form. Using the single
  Norwegian name removes the recurring false-positive conflicts.

## 0.9.46 — 2026-08-30
### Fixed
- **Syntax error in New country button code.** A Python heredoc inserted a literal
  newline inside a single-quoted Lua string in the self-patch section, causing
  Lightroom to report "unfinished string" at line 1114 on startup. The broken
  `gsub` pattern is replaced with a valid double-quoted form using `[^\n]`.

## 0.9.45 — 2026-08-30
### Changed
- **List Overview — "List name" column removed.** The editable name field had no
  clear purpose and cluttered the table. "File" column renamed to "File name".
- **List Overview — "Names" column added** between Version and Last verified.
  Shows the total place-name count for the country (Counties + Municipalities +
  Cities) computed from the loaded data at startup.
- **List Overview — timestamp format now includes time** (`2026-08-30 22:04`)
  for both "Last verified" and "Last update" columns. Column widths widened to
  115 px to accommodate the longer value.
- **List Overview — spacing tightened**: 5 px gap between Version and Names
  columns; 10 px gap between the Verify button and Last update column.
- **List Overview — "New country" button added** below the table. Opens a dialog
  to enter country name, native name, short ID, and admin-level labels. Creates
  a skeleton data file in `data/` and patches `ListVerification.lua` to register
  the new country. Reload the plug-in afterwards to see it appear.

## 0.9.44 — 2026-08-30
### Fixed
- **City-name substitution now handles plain-string city arrays.** `doSubs` used a
  `name = "OldName"` pattern that only matched table-entry names (counties,
  municipalities). USA cities are stored as plain string literals in a `cities = {…}`
  array, so the pattern never matched and the change was silently dropped. A new
  `doCitySubs` helper first tries the structured `name = "OldName"` pattern, then
  falls back to matching the bare string literal `"OldName"` anywhere in the file.
  Result: Update now actually rewrites city names in the data file, and Verify no
  longer re-flags the same conflicts after saving.

## 0.9.43 — 2026-08-30
### Fixed
- **Update now applies city-level changes.** Previously, selecting Change or Delete
  for a city conflict had no effect — the Update button only processed county and
  municipality entries. Cities (`savedCi` / `vaci_` / `vcci_` props) are now fully
  collected, confirmed in the summary dialog, applied via `doSubs`/`deleteName`,
  and their saved actions reset to `"none"` so re-running Verify no longer shows
  the same conflicts again.

## 0.9.42 — 2026-08-30
### Changed
- **All plugin UI text is now in English**: all messages, labels, button titles, and descriptions have been translated. Place names in the data files remain in their local languages.

## 0.9.41 — 2026-08-30
### Fixed
- **«Last update»-dato vises nå alltid etter Update**: selv om ingen endringer ble gjort i datafilen, settes datoen til i dag. Meldingsteksten bekrefter at datoen er oppdatert.
### Changed
- **Rask åpning av Verification Monitor for store lister**: grupper med > 300 oppføringer (f.eks. by-kolonnen for Panama/Sverige) rendres ikke lenger som individuelle rader ved oppstart. Klikk «Verify with Wiki» for å starte. Etter verifisering vises enten «Ingen konflikter»-melding eller bare konflikt-radene.
- **Tidsestimering under verifisering**: framdriftsetiketten viser nå «1234 / 11117 — ca. 3 min gjenstår» for lange by-lister.

## 0.9.40 — 2026-08-30
### Fixed
- **Sortering av konflikter**: sorteringslogikken ekskluderer nå «✓»-oppføringer korrekt, slik at rader med faktiske navneforslag sorteres til toppen etter verifisering.
### Changed
- **Grå bakgrunn på Conflicts-kolonne**: tilbake til `static_text` (grå bakgrunn) — `background_color` på `edit_field` ignoreres av macOS SDK på native tekstkontroller.
- **«Endre manuelt»-dialog**: når en rad har handlingen «Endre manuelt» og ingen Wikidata-forslag finnes (Conflicts viser «✓»), vises nå en innleggsdialog som ber brukeren om et egendefinert navn før selve bekreftelsesdialogen åpnes. Hopper brukeren over, hoppes raden over.

## 0.9.39 — 2026-08-30
### Changed
- **«Verifiserer: [navn]»-etikett**: en bundet etikett over scrollvinduet viser i sanntid hvilket navn som verifiseres akkurat nå. Forsvinner automatisk når verifiseringen er ferdig.
- **Horisontal scroller fjernet**: `horizontal_scroller = false` på alle tre scrollvinduer i Monitor-panelet.
- **Grå bakgrunn på Conflicts-felt (forsøk)**: `background_color = DLG_BG` er lagt til `edit_field` — virker om macOS/SDK honorerer det; hvis feltene fortsatt er hvite er det en SDK-begrensning i native tekstkontroller.

## 0.9.38 — 2026-08-30
### Changed
- **Verification Monitor — knappetittel**: alle «Verify»-knapper (i List Overview og Monitor-panelet) er omdøpt til «Verify with Wiki».
- **Monitor-knapp sentrert**: «Verify with Wiki»-knappen i Monitor-panelet er nå sentrert over gruppen i stedet for venstrejustert.
- **Bunnen-til-toppen-iterasjon**: verifisering starter nå fra siste oppføring og arbeider seg oppover, slik at brukeren umiddelbart ser at systemet er aktivt.
- **«✓» i stedet for «-»**: verifiserte OK-oppføringer viser nå «✓» i Conflicts-kolonnen i stedet for «-».
- **Action-meny utvidet**: ny handling «Delete» (sletter oppføringen fra datafilen) og «Change manually» (bruker innholdet i Conflicts-feltet som egendefinert navn). «—»-valget er omdøpt til «None».
- **Conflicts er nå et redigerbart felt**: Conflicts-kolonnen bruker nå `edit_field` slik at brukeren kan skrive inn et egendefinert navn ved «Change manually».
- **Fremdriftsindikator**: en «12 / 448»-teller vises til høyre for antall-etiketten og oppdateres i sanntid under verifisering; viser «N / N ✓» når ferdig.
- **Fjernet «Refresh from GitHub»-knappen**: var redundant (lokale data er alltid gjeldende).

## 0.9.37 — 2026-08-30
### Added
- **Oppdater-knapp i List Overview** (Verification Monitor): klikk «Oppdater» etter verifisering for å skrive «Change»-beslutninger direkte inn i `data/Norway.lua`. Gamle navn erstattes med nye navn i filen (tekstbasert søk/erstatt), versjonsnummeret i datafilen økes automatisk, og endringer lagres. Etter at oppdateringen er gjennomført tilbakestilles alle «Change»-handlinger til «—» slik at neste verifisering starter rent. Hvis GitHub-integrasjon er konfigurert, pushes den oppdaterte datafilen automatisk til repoet.
- Innebygd bekreftelsesdialog viser alle planlagte endringer (gamle → nye navn) før de skrives til filen.
- Reload Plug-in kreves etter oppdatering for at endringene skal bli synlige i Keyword List Builder.

## 0.9.36 — 2026-08-30
### Fixed
- GitHub Sync: all `edit_field` controls now bind **explicitly to `LrPrefs`** via
  `bind { object = prefs, key = "..." }` instead of `bind "key"`.  In the Plug-in
  Manager's `sectionsForTopOfDialog`, `bind "key"` targets the plugin's prefs store
  directly — not the `props` table — so reading `props.gh_token` inside the Test
  button always returned an empty string (the seeded props value was never updated by
  user edits).  Binding directly to `prefs` and reading `prefs.gh_token` inside the
  async task removes the disconnect entirely.
- Status label now uses `bind { object = props, key = "gh_status" }` so only the
  computed status is props-based; all user-typed fields go straight to prefs.
- Defaults for Owner / Repository / Branch / Folder are now written to `prefs`
  (not `props`) so the fields display the correct initial values when the Plugin
  Manager opens.

## 0.9.35 — 2026-08-30

### Fixed
- **GitHub Sync: token read as empty when "Test connection" clicked without tabbing out**
  — `edit_field` in the LR SDK only commits its value to the bound prop when the
  field loses focus (Tab or click elsewhere). Clicking "Test connection" directly
  after typing left `props.gh_token` still `""`. Fixed by adding `immediate = true`
  to all five edit fields so `props` updates on every keystroke — no Tab needed
  before clicking Test.

## 0.9.34 — 2026-08-30

### Fixed
- **GitHub Sync: "Test connection" still showed "no token"** — the async task
  in "Test connection" read config from `LrPrefs`, but prefs writes from the
  dialog are not guaranteed to be visible to the async task in time. Fixed by
  capturing all field values synchronously from `props` into a local snapshot
  table the moment the button is clicked, and passing that snapshot directly to
  `GitHubSync.test()` as a config override — bypassing `LrPrefs` entirely for
  the test. Prefs are still written at the same time so Save/push can use them
  later. `GitHubSync.test()` now accepts an optional `cfgOverride` table for
  this purpose.

## 0.9.33 — 2026-08-30

### Fixed
- **GitHub Sync: token field never updated props** — `password_field` in the
  Lightroom SDK does not honour `value = bind` (the binding is one-way display
  only; typing into the field does not update `props`). Replaced with a plain
  `edit_field` so the token is readable from `props` when "Test connection"
  force-flushes it to prefs. The Plugin Manager is author-only, so plaintext
  display is acceptable.

## 0.9.32 — 2026-08-30

### Fixed
- **GitHub Sync: token and branch/folder defaults not registering** — two bugs
  in `GitHubSettings.lua`:
  1. `"" or "default"` does not work in Lua (empty string is truthy), so
     Branch and Folder showed blank even though defaults are "main" and
     "verified". Fixed with an `orDefault()` helper that treats both `nil`
     and `""` as missing.
  2. The "Test connection" button reads plugin prefs from an async task, but
     the observer only writes prefs when the user *edits* a field — so a
     token pasted in during the same session was never in prefs when the
     async task ran. Fixed by force-flushing all field values to prefs
     synchronously in the button action, before starting the async task.

## 0.9.31 — 2026-08-30

### Changed
- **Anonymous read from a public repo**: now that `LR-Keywords-Geography` is
  public, the "Refresh from GitHub" button and the Plug-in Manager "Test
  connection" button work **without a token**. The `Authorization` header is
  only sent when a token is present. A token is still required to **Save (push)**
  changes — writing to GitHub always requires authentication, even on a public
  repo.
  - `GitHubSync.lua`: new `isReadable()` (owner/repo set) alongside
    `isConfigured()` (token set); `apiHeaders()` omits `Authorization` when no
    token; `test()` reports whether the connection is read-only or read/write
    (checks `permissions.push`).
  - `ListVerification.lua`: "Refresh from GitHub" now gates on `isReadable()`
    instead of `isConfigured()`, so it works on the public repo without a token.
    Monitor text clarifies that Save pushes to GitHub only when a token is set.
  - `GitHubSettings.lua`: help text and status line explain that reading a
    public repo needs no token, while Save/push does.

## 0.9.30 — 2026-08-29

### Added
- **GitHub sync for verification data**: the Verification Monitor can now read
  and write per-country verification files to a GitHub repository, so verified
  corrections and versions can be synced across machines.
  - **Save now pushes to GitHub**: clicking Save in the Monitor still bumps the
    local version, and (when a token is configured) also writes
    `verified/<Country>.json` to the repo. The file contains the version,
    verified date, list name, and every entry flagged with a conflict or an
    Action of "Change".
  - **New "Refresh from GitHub" button** in the Monitor: pulls the latest
    `verified/<Country>.json` and applies it to the current view (matched by
    name, with an index fallback). Explicit, author-only action.
  - **Plug-in Manager ▸ GitHub Sync section**: enter a GitHub personal-access
    token (repo scope), owner, repository, branch, and folder. A **Test
    connection** button verifies access. The token is stored only in this
    machine's plugin preferences and is **never** bundled with the distributed
    plugin — customers without a token simply have sync disabled.
  - New files: `GitHubSync.lua` (Contents API wrapper), `Base64.lua` (content
    encoding for the API), `GitHubSettings.lua` (Plug-in Manager section).

### Fixed
- **Action changes made after Verify are now persisted**: setting an Action to
  "Change" via the popup (without re-running Verify) is now saved to prefs on
  Save, closing a gap where such edits could be lost.

## 0.9.29 — 2026-08-29

### Fixed
- **ListVerification — Verification Monitor: blank start**: the Conflict column
  now always starts empty (shown as "—") when a verification session opens,
  regardless of any previous run. The conflict text is transient and must be
  re-fetched from Wikidata each time; it was incorrectly restored from plugin
  prefs.
- **ListVerification — Verification Monitor: row-by-row animation**: clicking
  Verify now fetches Wikidata in a background task (`LrTasks.startAsyncTask`)
  and updates each row visually as results arrive (batch size ~25 rows, with a
  yield between batches). Previously all rows appeared resolved at once because
  the check ran synchronously before the UI could refresh. Added missing
  `LrTasks` import.
- **ListVerification — Verification Monitor: Action preserved on re-verify**:
  rows whose Action was set to "Change" by the user now keep that action when
  Verify is clicked again. Previously doVerify() unconditionally reset every
  Action to "–" (Dash/No Change), wiping the user's decision. Only rows whose
  Action has not been set to "Change" are reset on re-verify.

## 0.9.28 — 2026-08-29

### Fixed
- **ListVerification — Save → List Overview**: after clicking Save on the
  Verification Monitor and dismissing the confirmation dialog, the window now
  switches to the List Overview tab instead of staying on the Monitor tab.
- **KeywordBuilder — version label**: the country version displayed at the
  bottom of the Keyword List Builder window (e.g. "Norway v0.5.4") now reads
  the version saved by the Verification Monitor (from plugin prefs) rather than
  always reading the hardcoded `meta.version` from the data file. This means
  the label stays in sync after a Save in the Monitor.
  - Added `LrPrefs` import to KeywordBuilder.lua.

---

## 0.9.27 — 2026-08-29

### Added
- **Wikidata verification** — each Verify button in the Monitor now queries the
  Wikidata SPARQL endpoint (`query.wikidata.org`) to fetch the full official
  name set for that country × level (county or municipality). One SPARQL call
  per country × level; results are cached for the plugin session.
  - County level uses country-specific Q-codes (Norway Q507390, Sweden Q200547,
    Panama Q608190, United States Q35657).
  - Municipality level: Norway Q755707, Sweden Q127448, Panama Q739779, US
    Q13221722.
  - City level: no Wikidata check (too heterogeneous); pattern analysis only.
  - Falls back to the existing dual-name pattern check when offline or when the
    result set is suspiciously small (< 5 entries).
- **`dkjson.lua`** — bundled pure-Lua JSON decoder (David Kolf, MIT licence)
  for parsing Wikidata SPARQL responses. No external dependencies.
- **`urlEncode()`** helper — percent-encodes the SPARQL query for the URL.
- Updated Monitor description text to mention the Wikidata source.

### Verification logic (Wikidata path)
- Name found exactly in Wikidata → Conflicts shows `-` (confirmed OK).
- Dual-name `A - B` not found as-is → check each half; if `B` (or `A`) is
  canonical, suggest it. If neither half is canonical, treat as OK (conservative).
- Non-dual-name not found in Wikidata → treated as OK (avoids false positives
  for legitimate names not yet indexed in Wikidata).

---

## 0.9.26 — 2026-08-29

### Changed
- **ListVerification.lua — Monitor: scrolled-view background** — added `background_color = DLG_BG` directly on `f:scrolled_view` (in addition to the inner column) so both the scroll container and its content use the dialog grey instead of the OS-native white.
- **ListVerification.lua — Monitor: Action popup** — removed "None" option. The popup now offers only `— | Change` (two options). Both OK and conflict entries default to "—"; the user changes to "Change" to flag a conflict for a future data update.
- **ListVerification.lua — Monitor: name column width** — `W_M_NAME` increased from 90 → 145 px so longer names (e.g. "Snåase - Snåsa", "Møre og Romsdal") are not clipped. `W_M_CONF` reduced to 85 px and `W_M_ACT` to 65 px; total group width `G_W` stays similar.
- **ListVerification.lua — Monitor: Save/Cancel button placement** — on the Monitor tab the dialog now uses `actionVerb = "Save"` (blue, Enter-key default) and `cancelVerb = "Cancel"`. Both buttons appear together in the right corner: `[Cancel] [Save]`. On all other tabs the dialog keeps its plain `Close` button with no Cancel.

---

## 0.9.25 — 2026-08-29

### Changed
- **ListVerification.lua — Verification Monitor: scrolled-view background** — added `background_color = LrColor(0.9, 0.9, 0.9)` to the column inside each scrolled_view so the list area matches the dialog's grey background instead of the OS-default white.
- **ListVerification.lua — Monitor: Action popup options** — renamed "No change" → "None". Added a third option "—" (value `"dash"`) as the default for entries that verified OK, so the Action column shows a neutral dash rather than a selectable label when there is no conflict.
- **ListVerification.lua — Monitor: real conflict detection** — `doVerify()` now runs `checkName()` on every entry. Any name matching the dual-language pattern `"NameA - NameB"` (e.g. `"Snåase - Snåsa"`) is flagged as a conflict; the suggested correction (the part after `" - "`) is written to the Conflicts column and Action is set to "None". Entries with no conflict show "-" in Conflicts and "—" in Action.
- **ListVerification.lua — Monitor: conflict-first sort order** — after a Verify run the panel rebuilds (via `switchTab(MN)`) so that conflict rows float to the top of each group, with the remainder sorted alphabetically by name.
- **ListVerification.lua — Monitor: country-specific level labels** — the group headers now use country-appropriate terminology: Norway/Sweden → County / Municipality / City; Panama → Province / District / City; United States → State / County / City.
- **ListVerification.lua — Monitor: row count footer** — each group shows an entry count below its scroll area (e.g. "15 county entries").
- **ListVerification.lua — Monitor: Save button** — a "Save" button appears next to the Close button whenever the Monitor is active and a country is selected. Clicking it increments the patch version (e.g. 0.5.0 → 0.5.1), saves it to prefs, and updates the Version column in List Overview immediately. A confirmation message shows the new version number.
- **ListVerification.lua — Monitor: next-version preview text** — a line above the group table reads "Clicking Save will store the current verification results as version X.X.X of the [Country] list" so the user knows what version will be assigned before committing.
- **ListVerification.lua — List Overview: Version column** — now shows the list_version prop (which may be higher than the data file's meta.version if Save has been used), and is reactive to Save without requiring a dialog restart.

---

## 0.9.24 — 2026-08-29

### Changed
- **ListVerification.lua — Verification Monitor**: Fully implemented. Clicking "Verify" for a country in List Overview now opens the Verification Monitor tab showing that country's data in three side-by-side groups: **Counties / Areas**, **Municipality**, and **City**. Each group has its own **Verify** button; clicking it fills the **Conflicts** column with `OK - YYYY-MM-DD` for every entry (stub — real spelling/existence checks are future work) and persists results to prefs. An **Action** popup per row offers `No change` / `Change`. The "Last verified" stamp in List Overview is updated whenever any group is verified. Results survive dialog close and are reloaded on next open.
- **ListVerification.lua — geo extraction**: Added module-level `extractGeoData()` + `GEO` table (computed once at load time) providing flat county, municipality and city name arrays for all four countries.
- **ListVerification.lua — monitor width**: Verification Monitor tab uses a wider column (`CONTENT_W_MN ≈ 954 px`) so all three groups (each `G_W = 308 px`) fit without horizontal clipping.

---

## 0.9.23 — 2026-08-29

### Changed
- **ListVerification.lua — tab strip**: Added "Keyword List Builder" as the first (leftmost) tab. Clicking it closes the Data Management dialog and immediately opens the Keyword List Builder window (via `dofile(KeywordBuilder.lua)`) — same session, no menu trip needed.
- **ListVerification.lua — List name field**: Changed `immediate` from `false` to `true` so list-name edits are written to prefs on every keystroke. No click-away or Save button required.

---

## 0.9.22 — 2026-08-29

### Changed
- **ListVerification.lua — List Overview table**:
  - Added **"Last update"** column (between Verify and Update buttons), showing the date Update was last confirmed; persisted to prefs; shows "—" until first Update.
  - **List name** column changed from static text to an editable `f:edit_field`; the current native name (e.g. "Norge") is shown and can be overwritten; custom names are persisted to prefs immediately on change.
  - **File** column widened (120 → 150 px) so "data/UnitedStates.lua" is no longer truncated.

---

## 0.9.21 — 2026-08-29

### Changed
- **ListVerification.lua**: Replaced custom push_button tab strip + visible-binding panels with the native `f:tab_view` / `f:tab_view_item` + `stopModalWithResult` / `while keepOpen` loop pattern used in LR-ListDoctor. Clicking "Verification Monitor" or "Help" now closes the current dialog and opens the selected tab as a new `presentModalDialog` window. The active tab is visually distinguished by the OS-native tab rendering (matching the ListDoctor appearance). State (verified dates etc.) persists across tab switches via the shared `props` table.

---

## 0.9.20 — 2026-08-29

### Changed
- **ListVerification.lua**: Replaced single-page layout with a three-tab interface modelled on ListDoctor — tabs "List Overview", "Verification Monitor", and "Help" at the top; active tab indicated by push_button focus ring; inactive tabs rendered as plain buttons separated by "|" dividers.
- List Overview panel retains the country table (Country, List name, File, File size, Version, Last verified, Verify / Update buttons).
- Verification Monitor and Help panels are stubbed with titles and placeholder text, ready for future content.

---

## 0.9.19 — 2026-08-29
### Changed
- **ListVerification** — removed the "List Verification" tab button (tab strip
  removed entirely; content is displayed directly).
- **File size column** — added between "File" and "Version"; reads the actual
  `.lua` file size from disk at dialog open time (e.g. "543 KB").

---

## 0.9.18 — 2026-08-29
### Changed
- **ListVerification** — replaced `f:tab_view` with a ListDoctor-style custom tab
  strip: a row of `f:push_button` tabs separated by "|" labels, with content panels
  switched via `visible` bindings. Matches the horizontal tab style shown in the
  ListDoctor screenshot. Structured for easy addition of future tabs.

---

## 0.9.17 — 2026-08-29
### Changed
- **ListVerification** — window restructured with `f:tab_view` (native tab strip
  at the top), titled "Geography Keyword Builder — Data Management". The
  "List Verification" tab contains the country table as before. Additional tabs
  (e.g. Update History) can be added later without rebuilding the dialog.
- **Update button** — added to the right of Verify in each country row. Clicking
  it shows a confirmation dialog: "Do you want to update the keyword list for
  [Country]?" with Update / Cancel. Update logic is a stub to be implemented later.

---

## 0.9.16 — 2026-08-28
### Added
- **Menu — "Keyword List Builder…"** — renamed from "Build Geography Keywords…".
- **Menu — "List Verification…"** — new second menu entry opening `ListVerification.lua`.
- **ListVerification.lua** — draft verification window. Shows a table of all bundled
  country databases with columns: Country | List name (native name) | File | Version |
  Last verified | [Verify] button. "Last verified" dates are stored in plugin prefs and
  persist across sessions. The Verify button is a stub in this draft.

---

## 0.9.15 — 2026-08-28
### Changed
- **Middle column description text** — updated to "Select which information to
  include and how detailed." with an explicit `\n` after "include" to guarantee
  the sentence wraps to two lines.

---

## 0.9.14 — 2026-08-28
### Changed
- **Middle column description text** — shortened to "Select which information to include."

---

## 0.9.13 — 2026-08-28
### Changed
- **Middle column — description text added** — new `f:static_text` beneath the
  bold title: "Select which counties and areas to include in the keyword list,
  and how detailed."
- **Middle column — separator added** — horizontal dark grey line
  (`f:separator { fill_horizontal = 1 }`) between the description and the
  Level of detail row, matching the right column style.
- **Select-all checkbox label** — changed from "Select Counties & Areas to
  include:" / "Select [admin] to include:" to simply "Select All".

---

## 0.9.12 — 2026-08-28
### Fixed
- **"Select Counties…" checkbox — reverted to `"<system>"` font** — at 14 pt
  the tick-box was visibly larger than the county rows; back to the LR default.
- **Right-column value numbers too large** — `f:static_text` in `inlineSlider`
  was using `"<system>"` which renders at the full macOS system text size, making
  "100" / "1800m" noticeably bigger than the adjacent checkbox labels (which
  render at AppKit's small control size). Set to
  `{ name = "<system>", size = 11 }` to match the checkbox label size.

---

## 0.9.11 — 2026-08-28
### Changed
- **"Select Counties…" checkbox font — 13 pt → 14 pt** — user found 13 pt
  still slightly small; bumped to 14 pt.

---

## 0.9.10 — 2026-08-28
### Fixed
- **"Select Counties…" checkbox — match size of county list checkboxes** —
  county checkboxes inside `f:scrolled_view` render at AppKit "regular" control
  size; the select-all checkbox outside the scrolled_view was rendering at
  Lightroom's default "small" size. Setting `font = { name = "<system>", size = 13 }`
  (macOS regular system font, 13 pt) should bring the select-all tick-box to the
  same visual size as the county rows. The `height = 20` override from v0.9.9 is
  removed; the erroneous `size = 14` from v0.9.8 is also gone.

---

## 0.9.9 — 2026-08-28
### Changed
- **"Select Counties…" checkbox — taller control** — reverted the erroneous
  `size = 14` font change from v0.9.8; text size is restored to `"<system>"`.
  Added `height = 20` to the checkbox to ask the SDK to allocate more vertical
  space, which may cause AppKit to render the tick-box button at a larger size.
  Untested in live LR — if the button looks unchanged or the layout breaks,
  please report back.

---

## 0.9.8 — 2026-08-28
### Changed
- **"Select Counties…" checkbox — slightly larger font** — changed `font` from
  `"<system>"` to `{ name = "<system>", size = 14 }` on the select-all checkbox.
  This increases the label text size by ~1 pt and may (depending on the macOS
  AppKit version) also scale the tick-box button itself. Untested in live LR;
  revert to `"<system>"` if the control looks too large or the layout breaks.

---

## 0.9.7 — 2026-08-28
### Reverted
- **Reverts v0.9.5 and v0.9.6** — both versions introduced layout regressions in
  the middle column. Restores the v0.9.4 county section layout: select-all is a
  plain `f:checkbox` placed in a `f:column { spacing=4 }` above the county
  scrolled_view (`countyListContainer`, height=250). County list height returns to
  250 px.

---

## 0.9.6 — 2026-08-28
### Fixed
- **Huge gap between select-all and county list** — removed the dedicated 24-px
  scrolled_view for the select-all checkbox; the SDK enforces a large minimum height
  on any scrolled_view, making that gap unavoidable. Instead the select-all is now
  the first item inside the single shared scrolled_view (countyListContainer),
  immediately followed by a thin separator and then the county rows. This gives it
  native regular control size with zero extra gap.
- **Left indent** — the select-all is in an `f:row` with a 3-px spacer before it,
  giving a slight indent relative to the county checkboxes without being excessive.
- **scrolled_view height** — increased from 250 → 280 px to account for the
  select-all row and separator now living inside the same scroll area.

---

## 0.9.5 — 2026-08-28
### Changed
- **"Select … to include:" checkbox size** — wrapped in its own tiny
  `f:scrolled_view` (height = 24 px) so the SDK forces native macOS regular
  control size, matching the county checkboxes in the list below.
- **"Select … to include:" left indent** — replaced non-working `margin_left`
  with an `f:row` + 5-px `f:spacer`, which is reliably honoured by LrView.

### Note
- The tiny scrolled_view approach is the only known SDK lever for control size
  outside the main county list. If the SDK enforces a minimum height larger than
  24 px, extra whitespace will appear between the select-all row and the county
  list; report the result and we will adjust the height.

---

## 0.9.4 — 2026-08-28
### Changed
- **"Select … to include" label** — added trailing colon: now reads
  "Select Counties & Areas to include:" / "Select States & Areas to include:" etc.
- **"Select … to include:" checkbox indented** — added `margin_left = 5` so
  the checkbox sits 5 px further from the left edge of the column.

### Known SDK limitation
- County/state checkbox squares inside the scrolled_view render at native macOS
  regular control size regardless of `font = "<system/small>"`. There is no other
  LrView attribute to control NSButton control size inside a scrolled_view.

---

## 0.9.3 — 2026-08-28
### Fixed
- **County checkbox clipping** — removed `margin_left = -4` from the inner column
  inside the scrolled_view; the SDK clips content that goes outside the scroll
  bounds, which was cutting off the left side of checkbox squares.
- **Middle column width no longer expands to fill dialog** — root cause was
  `fill_horizontal = 1` on the "Level of detail:" row, which caused the entire
  middle group_box to grow as wide as the dialog. Replaced with a fixed-width row
  (label 101 px + slider 75 px + value 30 px + two 2 px gaps = 210 px total) so
  the right edge of "Less" aligns with the right edge of the scrolled_view below.
- **"Select … to include" checkbox width constrained** — set `width = 210` to
  prevent the long label text (~222 px natural) from driving the column wider than
  the scrolled_view and creating extra whitespace to the right of the slider.

---

## 0.9.2 — 2026-08-28
### Fixed
- **Right column description font** — removed `font = "<system>"` from the two
  description lines so they match the checkbox label size.
- **Separator under "Select All" removed** — the horizontal line that appeared
  below the Select All checkbox in the Selections column is gone.
- **Middle column — spacing between select-all and county list** — changed from
  `spacing = 0` to `spacing = 4` to restore a small gap.
- **Middle column — detail slider pushed right** — reduced element gaps to
  `spacing = 2` and narrowed the slider to 75 px and value label to 30 px so
  the fill spacer actually has room to expand and the slider sits more to the right.
- **County checkbox left indent** — added `margin_left = -4` to the county
  list inner column to reduce the extra left padding inside the scrolled_view.
  (May be a no-op if the SDK ignores `margin_left` on f:column.)

---

## 0.9.1 — 2026-08-28
### Fixed
- **County/state name font** — scrolled_view renders at native macOS size; added
  `font = "<system/small>"` to all county, Svalbard, and Jan Mayen checkboxes so
  they match the rest of the dialog text.
- **"Level of detail:" and value label font** — removed `font = "<system>"` from
  these controls; they now use the default dialog font size.
- **Middle column — detail slider right-aligned** — added spacer so the slider and
  value label are pushed to the right edge of the 210 px county column.
- **Middle column — gap removed** — the "Select … to include" checkbox and the
  county scrolled_view are now in a `spacing = 0` column so no extra gap appears
  between them.
- **Right column — description line break** — the description sentence is now split
  across two lines using two static_text elements.
- **Right column — sliders right-aligned** — each feature row now has
  `fill_horizontal = 1`; the right group_box has `fill_horizontal = 1` restored so
  rows have a consistent width and sliders align to the right edge.

---

## 0.9.0 — 2026-08-28
### Changed
- **Font size increased** — all dialog controls (feature checkboxes, labels, slider
  values, county checkboxes) now use `font = "<system>"` instead of the smaller
  default `<system/small>`.
- **"Detail:" label** in the middle column renamed to **"Level of detail:"**.
- **Default detail level** changed from 3 (Most) to 1 (Less) for all countries.
- **Dynamic middle-column checkbox title** — the "Select All" checkbox is now
  labelled "Select Counties & Areas to include" (or "States & Areas" / "Provinces &
  Areas") matching the active country.
- **Sliders moved inline** — each feature row in the Selections column now shows its
  slider (max count or min elevation) on the same line as the checkbox, removing the
  separate indented slider row below each feature.
- **Middle column (Counties/Areas) scrolled view** — background colour changed to
  grey (matching the rest of the dialog) and width constrained to 210 px.
- **Right column (Selections) group_box** — `fill_horizontal` removed so the column
  no longer stretches to fill remaining horizontal space.
- **Description line added** below the Selections column title: *"Use the sliders
  below to set max count or min elevation (only for mountains)."*

---

## 0.8.9 — 2026-08-27
### Fixed
- **County list switching now works without any gap or crash.** Abandoned the
  show/hide approach entirely (visible binding on containers doesn't collapse
  height; height binding crashes the SDK). Instead the middle column now has a
  **single** `f:scrolled_view` with one checkbox slot per maximum county count (51).
  Each slot's `title` and `value` are bound to `county_name_X` / `div_value_X`
  props. When the user clicks "Select More" for a country, `loadCountryState`
  writes that country's names into the `county_name_X` props — the checkboxes
  update live, with no container visibility or height manipulation needed.
  Norway's Svalbard / Jan Mayen extras remain as separate fixed slots, shown
  only when `show_svalbard_section` is true.

## 0.8.8 — 2026-08-27
### Fixed
- **No more blank gap above the active county list.** `visible=false` hides content
  but does not collapse height in the LR SDK, leaving up to 500 px of empty space
  above the active country's list. Fixed by binding `height` to a separate
  `county_height_X` prop (250 when active, 0 when inactive) alongside the existing
  `visible` binding, so the hidden scrolled_views take zero vertical space.

## 0.8.7 — 2026-08-27
### Fixed
- **Only the active country's county list is shown.** Previous approach put
  `visible = LrView.bind("show_county_X")` on an outer `f:column` wrapper, which
  the LR SDK silently ignores (all four country lists rendered simultaneously).  
  Fix: `visible` binding is now placed directly on each `f:scrolled_view`.  
  All lists start `visible=true` at construction so the SDK renders them, then a
  post-construction pass immediately hides the non-active ones before the dialog
  opens.  Switching countries via "Select More" flips the props to show only the
  newly chosen country's list.

## 0.8.6 — 2026-08-27
### Fixed
- **County list now visible.** v0.8.5 called `f:column {}` first (constructing an
  empty view), then tried to add children afterward — but the LR SDK reads children
  only at construction time. Fixed by building the spec table first and calling
  `f:column(countyListSpec)` once all children are in it (same pattern as
  `countryColumn`).

## 0.8.5 — 2026-08-27
### Changed
- **Tab bar eliminated completely.** Replaced `f:tab_view` with per-country
  `f:column` wrappers using `visible = LrView.bind("show_county_X")`. Each country
  has its own outer column (NOT inside a shared scrolled_view), which allows the
  visible binding to work two-way: `loadCountryState` hides the outgoing country's
  column and shows the incoming one. No tab bar of any kind.
- **`show_county_X` props** added to the prop initialisation block (all start false).
- **`loadCountryState`** captures the previous country ID before switching and sets
  its `show_county_X` prop to false, then sets the new country's prop to true.
- Inner `f:scrolled_view { height=250 }` per country handles county-list scrolling.

## 0.8.4 — 2026-08-27
### Changed
- **Tab bar country names removed.** All `f:tab_view_item` titles set to `""` so no
  country names appear in the tab bar regardless of whether the clip trick works.
- **Single scroll container (fixes v0.8.2 regression).** Removed the inner
  `f:scrolled_view` from each tab. The outer `f:scrolled_view` (height=250, vertical
  scroll enabled, horizontal scroll suppressed) is now the only scroll container.
  Double-nesting caused the outer NSScrollView to swallow scroll events before they
  reached the inner one, making the county list non-interactive in v0.8.2.
- **`margin_top = -30` on `f:tab_view`** inside the outer scrolled_view — best-effort
  attempt to push the (now empty) tab bar above the clip boundary. If LR Classic
  clamps negative margins, a thin empty bar may still show at the top of the list.

## 0.8.3 — 2026-08-27
### Changed
- **Three-column dialog layout.** Country list (left) · Counties & Areas (middle) ·
  Feature selections (right). The right column no longer contains the county list.
- **County list now uses `f:tab_view` directly** (no clip-window wrapper). The broken
  clip approach from v0.8.2 is removed; the tab_view that worked in v0.8.0 is restored
  in a dedicated middle column. The tab bar at the top of the county list is an
  unavoidable SDK limitation and remains visible.

## 0.8.2 — 2026-08-27
### Changed
- **County list tab bar hidden (clip-window approach).** Wraps `f:tab_view` in a
  non-scrollable `f:scrolled_view` (250 px, no scrollers) that acts as a clip
  window. Applies `margin_top = -30` to push the tab bar (~26–30 px) above the
  clip boundary so macOS clips it out of view. If the SDK clamps negative margins
  to zero, falls back to the v0.8.0 tab-bar-visible layout with no other regression.

## 0.8.1 — 2026-08-27
### Changed
- **Tab bar removed from county list.** Replaced `f:tab_view` (which always renders
  a tab bar) with per-country `f:scrolled_view` elements whose `height` is bound
  directly on the viewport element. A scrolled_view's viewport height is independent
  of its content, so height=0 collapses it to nothing while height=250 shows it.
  No tab bar, no visible binding (avoids one-way bug), no outer column wrapper
  (avoids the fixed-child-height issue from v0.7.8).

---

## 0.8.0 — 2026-08-27
### Fixed
- **"tab_view_item needs a string or number identifier" error fixed.** Each
  `f:tab_view_item` must carry an explicit `identifier` field that the parent
  `f:tab_view` matches against its `value` prop. Adding
  `identifier = divCountry.name` resolves the nil-nil crash.

---

## 0.7.9 — 2026-08-27
### Fixed
- **County list now shows only one country at a time.** Replaced the per-country
  outer-column approach (visible + height binding) with `f:tab_view`. LR SDK does
  not support dynamic height binding after construction, so invisible columns still
  occupied full layout space — all four county lists were stacked simultaneously.
  `f:tab_view` is the only SDK control that natively manages geometry so inactive
  tab panels occupy zero space. The active tab is driven by `active_country_name`
  (set automatically when "Select More" is clicked); clicking a tab directly also
  switches the active country through the same dirty-check flow.

---

## 0.7.8 — 2026-08-27
### Fixed
- **County columns now truly collapse when inactive.** LR SDK's `visible = false`
  makes an element invisible but still reserves its layout space. Added a `height`
  binding alongside `visible`: inactive country columns get `height = 0`, which
  forces zero vertical footprint. Only the active country's scrolled_view is
  visible and occupies space; all others are both invisible and zero-height.

---

## 0.7.7 — 2026-08-27
### Changed
- **Counties & Areas merged into Selections panel** (Option 2). The left panel is
  now a pure country-picker. The right panel shows the admin-division section (label,
  Detail slider, Select All, county scrolled_view) above the feature checkboxes.
- **Per-country scrolled_views** replace the shared slot-based approach. Each country
  gets its own `f:scrolled_view` wrapped in an outer column whose `visible` binding
  toggles on `active_country_id`. This is the reliable bidirectional approach that
  avoids the one-way visibility bug of toggling leaf nodes inside a shared scroll.
  Fixes Sweden's empty-checkbox rows.
- **Mountain slider max capped per country**: Norway 2271 m, Sweden 2097 m,
  Panama 3474 m, United States 6194 m. The slider `max` is bound to
  `active_mountain_max` which updates on every country switch.
- **Elevation clamped on country switch**: if a saved elevation exceeds the new
  country's peak, it is clamped down to that country's maximum on load.

---

## 0.7.6 — 2026-08-27
### Changed
- **States & Areas panel removed as a separate panel** — county/state checkboxes are
  now shown inline at the bottom of the Country panel. Dynamic title and visibility
  bindings (`div_name_N`, `div_visible_N`) update on every country switch, so no
  tab bar is needed. Scales to 20+ countries without UI changes.
- Dialog is now **two panels**: Country (with inline States & Areas) + Selections.

---

## 0.7.5 — 2026-08-27
### Changed
- **Svalbard elevation slider removed entirely** — the slider is gone from both
  panels; `svalbard_cutoff = 800` is now hardcoded when passing prefs to Generator.
- **"Min elevation (mainland)" renamed to "Min elevation"** in the Selections panel
  under Mountain, since Svalbard is no longer a separate concept.
- **Panel order swapped** — layout is now: 1. Country  2. States & Areas  3. Selections.

---

## 0.7.4 — 2026-08-27
### Changed
- **Svalbard elevation slider** moved from the shared "Selections" panel (Panel 2)
  into the Norway tab of the "Counties & Areas" panel (Panel 3), so it only
  appears when Norway is selected — it was incorrectly shown for all countries.
- **"Add country synonym to nature features" option removed** — the checkbox and
  its hint text have been removed from the UI; synonym output remains disabled
  (Generator still accepts `country_synonym = false` internally).

---

## 0.7.3 — 2026-08-27
### Added
- **United States** — new country (scalability test for large datasets):
  - 51 states (50 + District of Columbia) as top-level divisions.
  - 3 143 counties/county-equivalents per state (incl. Louisiana parishes, Alaska
    boroughs/census areas, Virginia independent cities, San Francisco city-county).
  - ~7 100 cities with population ≥ 5 000 per county.
  - 3 130 named mountains ≥ 3 000 m (Denali 6 194 m, Mount Whitney 4 412 m,
    Mount Rainier 4 392 m, all Colorado 14ers, Sierra Nevada peaks, etc.).
  - 63 official NPS National Park units (curated; Acadia → Zion).
  - 249 nature reserves from GeoNames RESN entries.
  - 2 402 lakes named "Lake X" (Great Lakes, Lake Tahoe, Lake Champlain, etc.).
  - 3 802 main-stem rivers (ending " River", no Fork/Branch/Tributary variants).
  - 2 169 islands (ISL, " Island" suffix, per-state cap of 50).
  - 15 curated viewpoints (Glacier Point, Mather Point, Zabriskie Point, etc.).
  - Continent key "Americas" — groups with Panama in the Americas slider.
  - `admin_label = "States & Areas"` used instead of "Counties & Areas".
  - Data file: 606 KB / 15 213 lines (compared to Sweden 938 KB / Norway 543 KB).
### Changed
- **Mountain elevation slider** — max expanded from 2 469 m to 6 500 m to cover
  US peaks (Denali 6 194 m). Range for Norway/Sweden is unchanged in practice.
- **Default mainland cutoff** — United States defaults to 4 000 m (~595 peaks,
  the iconic high summits); other countries unchanged.

---

## 0.7.2 — 2026-08-26
### Added
- **Panama** — new country with full geographic keyword data:
  - 14 provinces & areas (10 provinces + 4 indigenous comarcas): Bocas del Toro,
    Chiriquí, Coclé, Colón, Darién, Herrera, Los Santos, Panamá, Guna Yala,
    Veraguas, Emberá-Wounaan, Ngöbe-Buglé, Panamá Oeste, Naso Tjër Di.
  - Distritos per province (prefix "Distrito de/del" stripped), with cities.
  - 280 mountains (≥800 m from GeoNames; Volcán Barú 3 474 m, Cerro Fábrega
    3 335 m, and other curated peaks included).
  - 16 national parks and 13 nature reserves (curated; GeoNames duplicates removed).
  - 32 lakes and reservoirs (Lago Gatún, Lago Bayano, Lago Alajuela, etc.).
  - 1 268 rivers (Río-prefixed only; Quebradas excluded to keep the list clean).
  - 918 islands (Isla, Cayo, Archipiélago; major islands: Coiba, Isla del Rey,
    Colón, Taboga, Contadora, Cébaco, etc.).
  - 12 curated viewpoints.
  - Continent key "Americas" — appears under the Americas continent slider
    alongside any future Americas countries.
  - `admin_label = "Provinces & Areas"` used instead of "Counties & Areas".

---

## 0.7.1 — 2026-08-26
### Fixed
- **Counties & Areas panel** — replaced `f:column` / `visible = LrView.bind(...)` approach
  with `f:tab_view` / `value = LrView.bind("active_division_tab")`. The `visible` binding
  on `f:column` is one-way in the LR SDK: it can show a hidden element but cannot re-hide
  one once rendered, so both Norway and Sweden panels appeared simultaneously after
  switching. `f:tab_view` is the correct LR SDK mechanism for mutually exclusive panels
  and switches reliably in both directions.
- **Svalbard cutoff slider** — removed the `visible` binding wrapper; slider is now always
  shown (Generator ignores `svalbard_cutoff` for non-Norway countries, so this is harmless
  and avoids a second one-way-visibility issue).
- **Auto-load on open** — Norway is now pre-loaded when the dialog opens, so the county
  list is populated immediately.
- **Tab-click observer** — clicking a tab directly (as opposed to using "Select More")
  now correctly switches the active country and loads its saved state.

## 0.7.0 — 2026-08-26
### Changed — Architecture (shared-UI / per-country state store)
- **Shared panels** — `Selections` and `Counties & Areas` panels are now a single shared
  set of controls instead of per-country stacked columns. State (all checkbox and slider
  values) is saved and restored per country via an in-memory state store.
- **Select More button** — renamed from "Select"; loads the chosen country's saved state
  into the shared panels without requiring a full dialog rebuild.
- **Save settings button** — new "Save settings for [Country]" button below the two
  shared panels. Unsaved changes are tracked with a dirty flag; switching countries
  with unsaved changes prompts to save first.
- **Welcome state** — panels 2 and 3 display a prompt until a country is selected.
- **Country indicator** — ✓ (U+2713) appended to a country name once its settings have
  been saved at least once this session.
- **Continent Include slider** — each continent now has a None / Less / More / All slider
  (shown when the continent is expanded). Countries not individually included are
  exported at this quick-include level during Generate; custom (individually included)
  settings always win.
- **MAX\_DIVS = 60** — a fixed pool of 60 shared county/division checkbox slots is
  reused for every country; unused slots are hidden via `visible` binding.
- **Norway-specific controls** — dual mountain-elevation cutoff (mainland + Svalbard),
  and Svalbard / Jan Mayen area checkboxes, shown only when Norway is active via
  `active_is_norway` visibility binding.
- **`bind_to_object = props`** set explicitly on every element that uses a `visible` or
  `value` binding, ensuring LrView resolves bindings correctly regardless of construction
  order.
- **`loading` guard** on all observers — prevents `dirty` flag and `Select All` observers
  from firing during state transitions.

## 0.6.5 — 2026-08-26
### Fixed
- **Continent expand/collapse not working** — country rows bound to `visible =
  LrView.bind(contKey)` were missing `bind_to_object = props`. Without it the LR SDK
  had no property table to watch at creation time, so clicking the continent toggle
  button had no visible effect. Added `bind_to_object = props` to each country row and
  to the continent toggle button itself.
- **Selection panel showed both countries** — `norwaySelectionsCol` and
  `swedenSelectionsCol` lacked `bind_to_object = props`, causing the `visible` binding
  to be unresolved. Both countries' sections were always rendered visible. Fixed.
- **Counties & Areas panel showed both countries** — same root cause as above;
  `norwayCountiesCol` and `swedenCountiesCol` now have `bind_to_object = props`.
- **Anchor symbol removed from hint text** — replaced U+2693 (⚓) with the plain word
  "Include" in the dialog instruction and warning message.
- **More space between arrow and continent name** — continent toggle button title now
  uses three spaces between the ▼/▲ glyph and the continent name.

---

## 0.6.4 — 2026-08-26
### Changed
- **Collapsible continents** — continent headers (Europe, etc.) now collapse/expand
  with a ▼/▲ toggle button. All continents default to collapsed so the Country
  panel starts compact.
- **Include checkbox per country** — a checkbox to the right of each "Select" button
  marks that country for export. Only countries with the checkbox ticked are included
  when Generate is clicked.
- **Multi-country Generate** — Generate now combines all included countries into one
  `.txt` file (e.g. `LR-Geography-Norway+Sweden-20260826.txt`). A warning is shown
  if no country is ticked.
- **All feature checkboxes default unchecked** — every selection checkbox (National
  Park, Nature Reserve, Mountains, etc.) starts unchecked. A "Select All" checkbox
  at the top of the Selections panel checks/unchecks them all at once.
- **County "Select All"** — the former "All Norway/Sweden counties" checkbox is
  renamed "Select All" and moved to the top of the Counties scrolled panel; all
  county checkboxes also default unchecked.
- **Data version below Counties panel** — a small label below the Counties scrolled
  view now shows the data version (e.g. "Norway v0.5.0" / "Sweden v0.5.0").
- **Generated date in button row** — the generation date of the bundled data is shown
  in the dialog's button row (to the left of Cancel / Generate) via `accessoryView`.

---

## 0.6.3 — 2026-08-25
### Changed
- **Continent grouping in Country panel** — countries are now listed under a continent
  header ("Europe") so more continents can be added cleanly as the plugin grows.
- **"Select" button per country** — replaced country checkboxes with a Select button
  next to each country name. Clicking Select loads that country's independent settings
  into the Selections and Counties & Areas panels. A ▶ indicator shows the active country.
- **Per-country independent settings** — the Selections panel heading and all sliders/
  checkboxes are now specific to the selected country ("Selections for Norway",
  "Selections for Sweden"). Norway has two mountain sliders (mainland + Svalbard);
  Sweden has one. The Countries & Areas panel heading also reflects the selection
  ("Counties & Areas for Norway", "Counties & Areas for Sweden").
- **Generate produces one file** — clicking Generate now creates a single `.txt` file
  for the currently selected country only, instead of one file per checked country.

---

## 0.6.2 — 2026-08-25
### Fixed
- **Lua 5.1 compatibility**: replaced `goto continue` / `::continue::` in the save
  loop with a plain `if not skipThisFile then … end` block. Lightroom Classic runs
  Lua 5.1, which does not support `goto` (added in Lua 5.2).

---

## 0.6.1 — 2026-08-25
### Changed
- **Single 3-panel dialog** — removed the two-step country-selector popup. The main
  dialog now has three panels side by side: **Country | Sections | Counties & Areas**.
- **Country panel** (leftmost): Norway and Sweden checkboxes. Both can be checked
  simultaneously. Select one or both and click Generate to produce one `.txt` file
  per selected country, all written to a single chosen folder in one go.
- **Counties & Areas panel** now lists counties for both countries in a single
  scrolled view, with "Norway" and "Sweden" bold headers as visual separators.
  "All Norway counties" and "All Sweden counties" master checkboxes sit at the top
  of each country's section.
- **Mountain slider** unified: Min elevation 500–2469 m (covers Kebnekaise 2097 m
  and Galdhøpiggen 2469 m); default 1500 m. Svalbard cutoff slider retained for
  Norway's Svalbard region.
- **Data version line** in dialog now shows both data versions:
  "Norway data v0.5.0   Sweden data v0.1.0".

### No data changes — Norway v0.5.0 and Sweden v0.1.0 are unchanged.

---

## 0.6.0 — 2026-08-25
### Added
- **Sweden support**: the plugin now supports both Norway and Sweden via a two-step
  dialog. A small country-selector dialog appears first (Norway / Sweden); after
  choosing, the full configuration dialog loads with country-specific data and UI.
- **`data/Sweden.lua`** (v0.1.0): 30 national parks, 44 nature reserves, 1 608
  mountains ≥ 500 m (GeoNames), 5 fjords, 7 729 lakes, 2 415 rivers, 4 698 islands,
  20 viewpoints, 21 counties (Blekinge → Västra Götaland) with all municipalities
  and cities. All names comma-free and UTF-8.
- **Country-aware UI**: dialog title, county-panel title, mountain-slider range, and
  synonym checkbox label all adapt to the selected country. The Svalbard / Jan Mayen
  checkboxes are shown only for Norway.
- **`Generator.lua` country-agnostic**: the administrative path (`Geography > World >
  Europe > <Country>`), the native-name synonym (`{Norge}` / `{Sverige}`), and the
  nature-feature synonym (`{Norway}` / `{Sweden}`) are now derived from `data.meta`
  instead of being hardcoded. The legacy `prefs.norway_synonym` field is still
  accepted as an alias for the new `prefs.country_synonym`.
- **`native_name`** added to `data/Norway.lua` and `data/Sweden.lua` meta sections
  (`Norge` and `Sverige` respectively) — used for the administrative synonym node.

### No data changes to Norway — `data/Norway.lua` remains at version 0.5.0.

---

## 0.5.9 — 2026-08-25
### Fixed (dialog UI polish, round 7)
- **Data version gap**: `margin_bottom` increased to -36 to further reduce space
  below the "Data version …" line.
- **Right panel height**: scrolled_view fixed height increased from 350 px to 400 px.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.8 — 2026-08-25
### Added
- **Max count sliders for National Park, Nature Reserve, Viewpoint**: each section now
  has a "Max count" slider (range 10–500, default 100, step 10), consistent with
  Fjord / Lake / River / Island. Generator.lua updated to honour the caps.
  Designed with larger countries in mind where these lists may be much longer.

### Fixed
- **Right panel height**: scrolled_view fixed height increased from 280 px to 350 px.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.7 — 2026-08-25
### Fixed (dialog UI polish, round 6)
- **Panel heights — definitive fix**: removed `fill_vertical` from the scrolled_view
  entirely. In LR's layout engine `fill_vertical` inside a `group_box` can inflate the
  group_box beyond its `LrView.share` height, which breaks the equalization. The
  scrolled_view now has a fixed pixel height (280 px). Combined with
  `LrView.share("gkb_panel_h")` on both group_boxes (left panel's natural content
  height sets the shared value), both panels are forced to the same height. The
  scrollbar is visible when county list content overflows 280 px — correct behaviour
  per the requirement "only show scrollbar if needed".

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.6 — 2026-08-25
### Fixed (dialog UI polish, round 5)
- **Panel heights equal**: restored `LrView.share("gkb_panel_h")` on both group_boxes
  so the right panel matches the left panel height. `fill_vertical = 1` on the
  `scrolled_view` (direct child of group_box, no wrapping column) now propagates
  correctly and fills all remaining space inside the shared height.
- **Data version gap**: increased `margin_bottom` to -24 to further reduce the gap
  below the "Data version …" line.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.5 — 2026-08-25
### Fixed (dialog UI polish, round 4)
- **scrolled_view height**: replaced `fill_vertical` + `LrView.share` approach (which
  caused the county list to fill only ~50% of the panel) with a computed fixed height
  (`scrollViewH`) based on the number of county rows × approx. row height. The scrollbar
  now only appears when content actually overflows — it will not appear for the current
  17 counties.
- **Data version gap**: increased `margin_bottom` negative offset from -8 to -16 to
  halve the gap below the "Data version …" line.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.4 — 2026-08-25
### Fixed (dialog UI polish, round 3)
- **Removed separator line** between "Data version" text and the two panels — it was
  unnecessary visual noise.
- **Right panel height**: combined `LrView.share("gkb_panel_h")` on both group_boxes
  (equalises them to the taller Sections column) with `fill_vertical = 1` on the
  right group_box, rightColumn, and scrolled_view (ensures the scroll list fills
  all the way to the bottom of the shared height). Using both mechanisms together is
  more robust than either alone.
- **Norway synonym description**: shortened to "Off keeps the list slim." — the
  second sentence was redundant.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.3 — 2026-08-25
### Fixed (dialog UI polish, round 2)
- **Mountain slider spacing**: replaced `control_spacing * 2` with default spacing +
  a fixed 8 px `f:spacer` between the two slider rows — more separation than the
  original collision, less than the previous double gap.
- **Removed "Administrative" checkbox**: counties / municipalities / cities are the
  core purpose of the right panel and were never meaningfully turned off. The toggle
  is removed from the UI; `administrative = true` is now hardcoded in the prefs.
- **Grey background fix**: changed `background_color` from 0.92 to 0.878 to better
  match the native macOS group_box inner background. Further tweaking may be needed
  depending on LR / macOS version — the value is in one place (`panelGrey` local).
- **Equal-height panels**: removed `LrView.share` (which wasn't reliably propagating
  height through group_box wrappers). The left group_box keeps its natural height
  (set by the Sections content). The right group_box now uses `fill_vertical = 1`,
  which stretches it to match the left's height within the row. The rightColumn and
  scrolled_view also use `fill_vertical = 1`, so the scrolled list fills all the way
  to the bottom of the right panel. Scroll bar appears only when the county list
  overflows this height.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.2 — 2026-08-25
### Fixed (dialog UI polish)
- **Mountain sliders no longer collide**: doubled the vertical spacing between the
  Mainland cutoff and Svalbard cutoff slider rows.
- **Counties list background is grey again**: the `scrolled_view` defaults to a white
  canvas; set its `background_color` to the dialog grey so it blends into the panel.
- **Both panels are the same height**: the Sections and "Norway — Counties & Areas"
  group boxes now share one height via `LrView.share` (largest wins → the taller
  Sections column), and the county `scrolled_view` uses `fill_vertical` to expand to
  that height.
- **Scroll bar behaviour clarified**: the county list scroll bar appears only when the
  list is taller than the panel. Norway's 17 items fit, so none shows (expected); it
  will appear automatically once more regions/countries are added.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.1 — 2026-08-25
### Changed
- **Dialog layout — column proportions**: Sections panel now fills all remaining
  horizontal space; Counties panel has a fixed narrower width (~220 px), giving an
  effective ~60 / 40 split without hardcoding pixel counts on either side.
- **Dialog layout — Counties panel height**: The county list is now wrapped in a
  `scrolled_view` (height capped at 500 px). The panel can never grow taller than
  the Sections column; a scroll bar appears automatically if the county list exceeds
  the cap (e.g. after adding more countries / regions in future data updates).
- **Administrative detail slider** (new, in "Norway — Counties & Areas" panel):
  A single-line slider directly below the panel title lets the user choose how many
  levels of administrative geography to include:
  - `Less` — county / fylke names only (one level below Norway)
  - `More` — counties + municipalities (two levels)
  - `All` — counties + municipalities + cities + districts (full depth; default)
  The slider drives `admin_detail` (1 / 2 / 3) which Generator.lua applies at
  generation time, so no data regeneration is needed to use the new option.

### No data changes — data/Norway.lua remains at version 0.5.0.

---

## 0.5.0 — 2026-08-25
### Changed (BREAKING — hierarchy restructure)
- **Level 2 now has exactly two wrapper folders under `Geography`:**
  ```
  Geography
  ├── Nature   → National Park, Nature Reserve, Mountain, Fjord,
  │              Lake, River, Island, Viewpoint
  └── World    → Europe → Norway → counties → …
  ```
- **Why:** previously the physical features (Fjord, Island, …) and the continent
  (`Europe`) sat side by side at level 2. As more countries are added, `Asia`,
  `Africa`, etc. would pile up at that level. Grouping all continents under `World`
  (and all physical features under `Nature`) keeps the root clean and scalable.
- Everything that used to be at level 2 is now at level 3 (shifted one level deeper).
- **Tip:** `Nature` and `World` are organizational parents, so they get applied to
  every photo in their branch. If you don't want them as tags, uncheck
  *Include on Export* on those two keywords once in Lightroom's Keyword List — no
  descriptive information is lost (the useful keywords are the feature/continent/
  country names below them).

### Migration note (if you already imported a v0.4.0 list)
- This is a re-parenting of every keyword, and Lightroom matches by name, so after
  importing v0.5.0 the section keywords (Fjord, Island, Europe, …) will appear a
  second time — once under the new `Nature`/`World` parent — while your existing
  copies stay where they are. To consolidate, drag each old top-level section onto
  its new counterpart under `Nature`/`World` to **merge** (re-tags photos), or just
  keep the new tree and remove the old top-level entries. One-time cleanup.

## 0.4.0 — 2026-08-25
### Changed (BREAKING — section keyword renames)
- **Level-2 section names are now singular**, so they read well as keywords applied
  to every photo under them (Lightroom applies the parent keyword too):
  | Old (plural)          | New (singular)  |
  |-----------------------|-----------------|
  | `National Parks`      | `National Park` |
  | `Nature Reserves`     | `Nature Reserve`|
  | `Mountains and Peaks` | `Mountain`      |
  | `Fjords`              | `Fjord`         |
  | `Lakes`               | `Lake`          |
  | `Rivers`              | `River`         |
  | `Viewpoints`          | `Viewpoint`     |
- Section names use Title Case for consistency (e.g. `National Park`, not
  `National park`).

### Added
- **New `Island` section** (root category under Geography, alongside Mountain / Fjord
  / Lake / River). Norway has ~240 000 islands, so this is a **curated + capped** list:
  the most notable/photogenic islands first (Lofoten, Vesterålen, Senja, Vega, Runde,
  Magerøya, the main Svalbard islands, etc.), then filled from GeoNames by importance,
  capped at 100. Controlled by its own checkbox and a **Max count slider (10–100)**,
  exactly like Fjord/Lake/River. Gets the optional `{Norway}` synonym like the other
  nature features.

### Migration note (if you already imported a v0.3.0 list)
- The section renames are keyword renames, and Lightroom matches keywords by name, so
  after importing v0.4.0 you will have BOTH the old plural section (e.g. `Fjords`) and
  the new singular one (`Fjord`). To consolidate, drag the old plural section keyword
  onto the new singular one in the Keyword List to **merge** (this re-tags photos), or
  delete the old empty section. One-time cleanup.

## 0.3.0 — 2026-08-25
### Changed (BREAKING — keyword rename)
- **Mountain keyword names no longer include the elevation.** `Galdhøpiggen (2469m)`
  is now just `Galdhøpiggen`. The elevation is still stored internally (in the data's
  `elev` field) and still drives the mountain elevation sliders — only the visible
  keyword name changed.
- **Why:** embedding the elevation in the name meant any future elevation correction
  would rename the keyword, and Lightroom matches keywords by name — a rename creates
  a duplicate rather than updating the existing keyword. Dropping the elevation from
  the name makes future data corrections non-breaking.

### Migration note (if you already imported a v0.2.0 list)
- After importing a v0.3.0 list you will have BOTH the old `Galdhøpiggen (2469m)` and
  the new `Galdhøpiggen`. Photos stay tagged with the old name. To consolidate: in
  Lightroom's Keyword List, drag the old `<Name> (####m)` keyword onto the new
  `<Name>` keyword to **merge** them (this re-tags the photos), or delete the old one
  if you don't need it. This is a one-time cleanup.

## 0.2.0 — 2026-08-25
### Added
- `{Norway}` synonym on nature features is now an **optional checkbox**, OFF by
  default to keep the list slim (previously always on, which roughly doubled the
  nature sections).
- Data version + generated date are shown in the dialog and in the save
  confirmation.
- Single-source `VERSION` file; the build script stamps it into `Norway.lua` and
  `Info.lua` automatically.

### Changed
- "Generate and Save…" button renamed to **Generate**.
- Output file is now written into a chosen **folder** with an auto-generated name
  `LR-Geography-<Country>-<YYYYMMDD>.txt` (e.g. `LR-Geography-Norway-20260825.txt`)
  instead of prompting for a full filename.
- Overwrite confirmation added when a file of the same name already exists.

## 0.1.0 — 2026-08-25
### Added
- Initial release. Offline Lightroom Classic plugin that builds a filtered Norway
  geography keyword list from bundled, pre-verified data (`data/Norway.lua`).
- Sections: National Parks, Nature Reserves, Mountains and Peaks, Fjords, Lakes,
  Rivers, Viewpoints, Administrative (county → municipality → city → district).
- Sliders for mountain elevation cutoffs (mainland / Svalbard) and max counts for
  Fjords / Lakes / Rivers; per-county checkboxes plus Svalbard and Jan Mayen.
