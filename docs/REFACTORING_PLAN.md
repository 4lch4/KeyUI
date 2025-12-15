# Refactoring-Plan: Best Practices & Code-Qualität

## Übersicht

Dieser Plan beschreibt umfassende Refactoring-Maßnahmen zur Verbesserung der Code-Qualität, Lesbarkeit und Wartbarkeit des KeyUI-Addons.

---

## 1. Naming Conventions

### 1.1 Aktuelle Probleme

**Inkonsistente Namenskonventionen:**
- `addon.keys_keyboard` (snake_case) ✅
- `addon.current_modifier_string` (snake_case) ✅
- `addon:load()` (lowercase) ✅
- `addon:CreateGlowFrame()` (PascalCase) ❌
- `addon:create_glow_border()` (snake_case) ❌
- `addon:GetCustomFont()` (PascalCase) ❌
- `addon:get_binding()` (snake_case) ❌

**Problem:** Mischung aus snake_case und PascalCase bei Funktionen

### 1.2 Empfohlene Konventionen

**Lua Best Practices:**
- **Funktionen:** `snake_case` (konsistent mit WoW-Addon-Standard)
- **Variablen:** `snake_case`
- **Konstanten:** `UPPER_SNAKE_CASE`
- **Klassen/Module:** `PascalCase` (nur wenn nötig)
- **Private Funktionen:** `local function _private_function()` (mit Unterstrich)

**Empfohlene Umbenennungen:**

```lua
-- Funktionen (konsistent snake_case)
addon:CreateGlowFrame() → addon:create_glow_frame()
addon:GetCustomFont() → addon:get_custom_font()
addon:GetCustomFontCondensed() → addon:get_custom_font_condensed()
addon:BuildProfileSnapshot() → addon:build_profile_snapshot()
addon:SerializeProfile() → addon:serialize_profile()
addon:DeserializeProfile() → addon:deserialize_profile()
addon:GetProfileExportString() → addon:get_profile_export_string()
addon:ApplyProfileSnapshot() → addon:apply_profile_snapshot()
addon:ImportProfileString() → addon:import_profile_string()
addon:RenameLayout() → addon:rename_layout()
addon:CopyLayout() → addon:copy_layout()
addon:ShowProfileExportPopup() → addon:show_profile_export_popup()
addon:ShowProfileImportPopup() → addon:show_profile_import_popup()
addon:ShowLayoutRenamePopup() → addon:show_layout_rename_popup()
addon:ShowLayoutCopyPopup() → addon:show_layout_copy_popup()
addon:SerializeTable() → addon:serialize_table()
addon:DeserializeTable() → addon:deserialize_table()
addon:SerializeLayoutPayload() → addon:serialize_layout_payload()
addon:DeserializeLayoutPayload() → addon:deserialize_layout_payload()
addon:ImportLayoutString() → addon:import_layout_string()
addon:ShowLayoutExportPopup() → addon:show_layout_export_popup()
addon:ShowLayoutImportPopup() → addon:show_layout_import_popup()
addon:SyncMinimapButton() → addon:sync_minimap_button()
addon:ResetAddonSettings() → addon:reset_addon_settings()
addon:get_keyboard_frame() → addon:get_keyboard_frame() ✅ (bereits korrekt)
addon:get_mouse_image() → addon:get_mouse_image() ✅ (bereits korrekt)
addon:get_mouse_frame() → addon:get_mouse_frame() ✅ (bereits korrekt)
addon:get_controller_frame() → addon:get_controller_frame() ✅ (bereits korrekt)
addon:get_controller_image() → addon:get_controller_image() ✅ (bereits korrekt)
addon:get_controls_frame() → addon:get_controls_frame() ✅ (bereits korrekt)
addon:create_tooltip() → addon:create_tooltip() ✅ (bereits korrekt)
addon:button_mouse_over() → addon:button_mouse_over() ✅ (bereits korrekt)
addon:set_key() → addon:set_key() ✅ (bereits korrekt)
```

**Konstanten:**
```lua
-- Bereits korrekt:
local PROFILE_EXPORT_VERSION = 1 ✅
local LAYOUT_EXPORT_VERSION = 1 ✅
local DEFAULT_FONT = "..." ✅
local BUTTON_TEXTURE = "..." ✅
local TEX_COORDS = {...} ✅
```

**Variablen:**
```lua
-- Bereits korrekt:
addon.keys_keyboard ✅
addon.current_modifier_string ✅
addon.bonusbar_offset ✅
addon.current_actionbar_page ✅
addon.class_name ✅
```

---

## 2. Datei-Struktur

### 2.1 Aktuelle Struktur

```
KeyUI/
├── Core.lua (2788 Zeilen - ZU GROSS!)
├── Variables.lua
├── Mappings.lua
├── UIHelpers.lua
├── Frames/
│   ├── Keyboard.lua
│   ├── Mouse.lua
│   ├── Controller.lua
│   ├── Controls.lua
│   ├── Selection.lua
│   └── Tutorial.lua
├── Layouts/
│   ├── Keyboard.lua
│   ├── Mouse.lua
│   └── Controller.lua
└── Media/
```

### 2.2 Probleme

1. **Core.lua ist zu groß** (2788 Zeilen)
   - Enthält: Serialization, Profile-Management, Layout-Management, Event-Handling, Key-Processing, Tooltip, etc.
   - Sollte aufgeteilt werden

2. **Keine klare Trennung von Concerns**
   - UI-Logik, Business-Logik, Daten-Management vermischt

### 2.3 Empfohlene Struktur

```
KeyUI/
├── Core.lua (Initialisierung, Haupt-API)
├── Variables.lua ✅
├── Mappings.lua ✅
├── UIHelpers.lua ✅
│
├── Core/
│   ├── Events.lua (Event-Handler)
│   ├── KeyProcessing.lua (set_key, get_binding, etc.)
│   ├── Serialization.lua (serialize/deserialize)
│   ├── ProfileManagement.lua (Profile-Import/Export)
│   ├── LayoutManagement.lua (Layout-Import/Export, Rename, Copy)
│   └── Spellbook.lua (load_spellbook)
│
├── Frames/
│   ├── Keyboard.lua ✅
│   ├── Mouse.lua ✅
│   ├── Controller.lua ✅
│   ├── Controls.lua ✅
│   ├── Selection.lua ✅
│   └── Tutorial.lua ✅
│
├── Layouts/
│   ├── Keyboard.lua ✅
│   ├── Mouse.lua ✅
│   └── Controller.lua ✅
│
├── Utils/
│   ├── Constants.lua (Magic Numbers, Offsets, etc.)
│   ├── Validators.lua (Validierungs-Funktionen)
│   └── Helpers.lua (Allgemeine Helper-Funktionen)
│
└── Media/
```

**Aufteilung von Core.lua:**

```lua
-- Core/Events.lua
-- Alle Event-Handler

-- Core/KeyProcessing.lua
-- set_key, get_binding, process_actionbutton_slot, etc.

-- Core/Serialization.lua
-- serialize_table, deserialize_value, etc.

-- Core/ProfileManagement.lua
-- build_profile_snapshot, import_profile_string, etc.

-- Core/LayoutManagement.lua
-- rename_layout, copy_layout, serialize_layout_payload, etc.

-- Core/Spellbook.lua
-- load_spellbook
```

---

## 3. Formatierung

### 3.1 Aktuelle Probleme

**Inkonsistente Einrückung:**
- Manche Stellen: 4 Spaces
- Manche Stellen: Tabs
- Manche Stellen: 2 Spaces

**Inkonsistente Leerzeilen:**
- Manchmal 1 Leerzeile zwischen Funktionen
- Manchmal 2 Leerzeilen
- Manchmal keine Leerzeilen

**Inkonsistente Kommentare:**
- `-- Kommentar` (einzelne Zeile)
- `--[[ Mehrzeiliger Kommentar ]]`
- Keine einheitliche Struktur

### 3.2 Empfohlene Formatierung

**Einrückung:**
- **4 Spaces** (konsistent)
- Keine Tabs

**Leerzeilen:**
- **2 Leerzeilen** zwischen Funktionen
- **1 Leerzeile** zwischen logischen Blöcken innerhalb einer Funktion
- **Keine Leerzeilen** zwischen verwandten Zeilen

**Kommentare:**
```lua
-- Einzeilige Kommentare für kurze Erklärungen
--[[
    Mehrzeilige Kommentare für:
    - Funktionen-Beschreibungen
    - Komplexe Logik
    - API-Dokumentation
]]

-- Funktionen-Header:
--[[
    Beschreibt die Funktion
    @param param1 Beschreibung
    @param param2 Beschreibung
    @return Beschreibung
]]
```

**Beispiel:**
```lua
-- Vorher:
function addon:set_key(button)
    -- Reset button state
    addon:reset_button_state(button)
    -- Get the binding string
    local binding = addon:get_binding(button.raw_key)
    -- ...
end

-- Nachher:
--[[
    Updates a key button with its current binding and icon.
    @param button The button frame to update
]]
function addon:set_key(button)
    -- Reset button state
    addon:reset_button_state(button)

    -- Get the binding string
    local binding = addon:get_binding(button.raw_key)

    -- Process binding and update button
    -- ...
end
```

---

## 4. Code-Organisation

### 4.1 Aktuelle Probleme

**Fehlende Gruppierung:**
- Funktionen sind nicht logisch gruppiert
- Verwandte Funktionen sind weit voneinander entfernt

**Fehlende Module:**
- Keine klare Trennung von UI, Business-Logik, Daten

### 4.2 Empfohlene Organisation

**Gruppierung nach Funktionalität:**

```lua
-- Core.lua (nur Initialisierung)
-- 1. Imports
-- 2. Konstanten
-- 3. Initialisierung
-- 4. Haupt-API (delegiert an Module)

-- Core/KeyProcessing.lua
-- 1. Binding-Funktionen (get_binding, etc.)
-- 2. Action-Processing (process_actionbutton_slot, etc.)
-- 3. Key-Update-Funktionen (set_key, refresh_keys, etc.)
-- 4. Modifier-Funktionen (update_modifier_string, etc.)

-- Core/Events.lua
-- 1. Event-Registrierung
-- 2. Event-Handler (gruppiert nach Event-Typ)
```

**Module-Struktur:**

```lua
-- Core/KeyProcessing.lua
local KeyProcessing = {}

-- Private Funktionen
local function process_action_slot(slot, button)
    -- ...
end

-- Öffentliche API
function KeyProcessing.set_key(button)
    -- ...
end

function KeyProcessing.refresh_keys()
    -- ...
end

return KeyProcessing
```

---

## 5. Magic Numbers & Konstanten

### 5.1 Aktuelle Probleme

**Magic Numbers:**
```lua
-- Core.lua:1604-1610
if addon.bonusbar_offset == 1 then
    return action_slot + 72
elseif addon.bonusbar_offset == 2 then
    return action_slot + 84
-- ...
```

**Problem:** Zahlen sind nicht selbsterklärend

### 5.2 Empfohlene Lösung

**Konstanten-Datei erstellen:**

```lua
-- Utils/Constants.lua
local Constants = {}

-- Action Slot Offsets
Constants.ACTION_SLOT_OFFSETS = {
    BONUS_BAR_1 = 72,
    BONUS_BAR_2 = 84,
    BONUS_BAR_3 = 96,
    BONUS_BAR_4 = 108,
    BONUS_BAR_5 = 120,
    PAGE_2 = 12,
    PAGE_3 = 24,
    PAGE_4 = 36,
    PAGE_5 = 48,
    PAGE_6 = 60,
}

-- Action Slot Ranges
Constants.ACTION_SLOT_MIN = 1
Constants.ACTION_SLOT_MAX = 180

-- Font Sizes
Constants.FONT_SIZE_DEFAULT = 16
Constants.FONT_SIZE_SMALL = 12
Constants.FONT_SIZE_LARGE = 22
Constants.FONT_SIZE_TITLE = 28

-- Frame Sizes
Constants.BUTTON_WIDTH_DEFAULT = 160
Constants.BUTTON_HEIGHT_DEFAULT = 30
Constants.TEXTURE_HEIGHT_DEFAULT = 46

-- Colors
Constants.COLOR_DISABLED_TEXT = 0.192
Constants.COLOR_DISABLED_TEXTURE = 0.4
Constants.COLOR_ENABLED = 1.0

return Constants
```

**Verwendung:**
```lua
-- Vorher:
if addon.bonusbar_offset == 1 then
    return action_slot + 72

-- Nachher:
if addon.bonusbar_offset == 1 then
    return action_slot + Constants.ACTION_SLOT_OFFSETS.BONUS_BAR_1
```

---

## 6. Variablen-Namen

### 6.1 Aktuelle Probleme

**Unklare Namen:**
- `u`, `u1_25`, `u1_5` (in Layouts) - nicht selbsterklärend
- `addon.modif` - Abkürzung
- `addon.bonusbar_offset` - könnte `bonus_bar_offset` sein

**Inkonsistente Präfixe:**
- `addon.keys_keyboard` vs `addon.keyboard_locked`
- `addon.is_keyboard_visible` vs `addon.open`

### 6.2 Empfohlene Umbenennungen

**Layout-Variablen:**
```lua
-- Vorher:
local u = 60
local u1_25 = 1.25 * u

-- Nachher:
local KEY_SIZE_BASE = 60
local KEY_SIZE_125_PERCENT = 1.25 * KEY_SIZE_BASE
local KEY_SIZE_150_PERCENT = 1.5 * KEY_SIZE_BASE
```

**Addon-Variablen:**
```lua
-- Vorher:
addon.modif → addon.modifiers
addon.bonusbar_offset → addon.bonus_bar_offset
addon.current_actionbar_page → addon.current_action_bar_page
addon.is_keyboard_visible → addon.is_keyboard_visible ✅ (bereits gut)
```

**Konsistente Präfixe:**
```lua
-- Boolean-Flags:
addon.is_open (statt addon.open)
addon.is_in_combat (statt addon.in_combat)
addon.is_keyboard_visible ✅
addon.is_keyboard_locked (statt addon.keyboard_locked)

-- Collections:
addon.keyboard_keys (statt addon.keys_keyboard)
addon.mouse_keys (statt addon.keys_mouse)
addon.controller_keys (statt addon.keys_controller)

-- Settings:
addon.settings (statt keyui_settings - optional)
```

---

## 7. Funktions-Namen

### 7.1 Aktuelle Probleme

**Inkonsistente Verben:**
- `load()` vs `load_spellbook()`
- `show_frames()` vs `hide_all_frames()`
- `refresh_keys()` vs `refresh_layouts()`

**Unklare Namen:**
- `set_key()` - könnte `update_key()` oder `refresh_key()` sein
- `get_binding()` - klar, aber könnte `get_key_binding()` sein

### 7.2 Empfohlene Umbenennungen

**Konsistente Verben:**
```lua
-- Initialisierung:
addon:load() → addon:initialize() oder addon:open()
addon:load_spellbook() → addon:load_spellbook() ✅ (klar)

-- Anzeige:
addon:show_frames() → addon:show_frames() ✅
addon:hide_all_frames() → addon:hide_frames() (konsistenter)

-- Updates:
addon:refresh_keys() → addon:refresh_keys() ✅
addon:refresh_layouts() → addon:refresh_layouts() ✅
addon:set_key() → addon:update_key_button() (klarer)

-- Getters:
addon:get_binding() → addon:get_key_binding() (klarer)
addon:get_keyboard_frame() → addon:get_keyboard_frame() ✅
```

---

## 8. Kommentare & Dokumentation

### 8.1 Aktuelle Probleme

**Fehlende Dokumentation:**
- Viele Funktionen haben keine Beschreibung
- Komplexe Logik ist nicht dokumentiert
- Parameter und Rückgabewerte sind nicht dokumentiert

**Inkonsistente Kommentare:**
- Manche Funktionen haben Kommentare, andere nicht
- Keine einheitliche Struktur

### 8.2 Empfohlene Dokumentation

**Funktions-Header:**
```lua
--[[
    Updates a key button with its current binding and icon.
    
    Processes the binding for the given button, determines the action type,
    retrieves the appropriate icon, and updates the button's visual state.
    
    @param button Frame The button frame to update
    @return nil
]]
function addon:update_key_button(button)
    -- ...
end

--[[
    Calculates the actual action slot for an ACTIONBUTTON binding.
    
    Adjusts the slot based on the current action bar page, bonus bar offset,
    and class-specific stance information.
    
    @param base_slot number The base action button slot (1-12)
    @return number The adjusted slot number
]]
function addon:get_action_button_slot(base_slot)
    -- ...
end
```

**Komplexe Logik:**
```lua
-- Serialization logic with detailed comments
local function serialize_table(tbl)
    local out = { "{" }

    -- Serialize array part (indices 1..n)
    for index = 1, #tbl do
        out[#out + 1] = serialize_value(index)
        out[#out + 1] = serialize_value(tbl[index])
    end

    -- Collect non-array keys
    local extra_keys = {}
    for key in pairs(tbl) do
        if not (type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #tbl) then
            extra_keys[#extra_keys + 1] = key
        end
    end

    -- Sort keys for consistent output
    table.sort(extra_keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    -- Serialize non-array keys
    for _, key in ipairs(extra_keys) do
        out[#out + 1] = serialize_value(key)
        out[#out + 1] = serialize_value(tbl[key])
    end

    out[#out + 1] = "}"
    return table.concat(out)
end
```

---

## 9. Code-Duplikation

### 9.1 Aktuelle Probleme

**Duplizierter Code:**
- Font-Setting wird mehrfach wiederholt
- Button-Erstellung ist ähnlich in mehreren Dateien
- Modifier-Checks werden mehrfach durchgeführt

### 9.2 Empfohlene Lösung

**Helper-Funktionen:**
```lua
-- Utils/Helpers.lua
local Helpers = {}

-- Font-Helper
function Helpers.apply_font(font_string, font_path, size, flags)
    font_string:SetFont(font_path, size or 16, flags or "")
end

-- Button-Helper
function Helpers.create_key_button(parent, raw_key, options)
    -- Gemeinsame Button-Erstellung
end

-- Modifier-Helper
function Helpers.build_modifier_string(modifiers)
    local parts = {}
    if modifiers.ALT then table.insert(parts, "ALT-") end
    if modifiers.CTRL then table.insert(parts, "CTRL-") end
    if modifiers.SHIFT then table.insert(parts, "SHIFT-") end
    if modifiers.CMD then table.insert(parts, "CMD-") end
    return table.concat(parts)
end

return Helpers
```

---

## 10. Fehlerbehandlung

### 10.1 Aktuelle Probleme

**Fehlende Validierung:**
- Viele Funktionen prüfen nicht auf nil
- API-Calls haben keine Fehlerbehandlung

### 10.2 Empfohlene Lösung

**Validierungs-Helper:**
```lua
-- Utils/Validators.lua
local Validators = {}

function Validators.validate_button(button)
    if not button then
        error("Button parameter is required")
    end
    if type(button) ~= "table" then
        error("Button must be a table")
    end
    return true
end

function Validators.validate_slot(slot)
    if not slot then return false end
    if type(slot) ~= "number" then return false end
    if slot < Constants.ACTION_SLOT_MIN or slot > Constants.ACTION_SLOT_MAX then
        return false
    end
    return true
end

return Validators
```

**Safe API-Calls:**
```lua
-- Utils/APIHelpers.lua
local APIHelpers = {}

function APIHelpers.safe_get_action_texture(slot)
    if not Validators.validate_slot(slot) then
        return nil
    end
    
    if InCombatLockdown() then
        -- Im Kampf: Aus Cache lesen
        return Cache.get_action_texture(slot)
    end
    
    local success, texture = pcall(GetActionTexture, slot)
    if success and texture then
        return texture
    end
    return nil
end

return APIHelpers
```

---

## 11. Implementierungs-Plan

### Phase 1: Konstanten & Magic Numbers (Einfach, schnell)

**Priorität:** Hoch
**Aufwand:** Niedrig
**Risiko:** Niedrig

1. `Utils/Constants.lua` erstellen
2. Magic Numbers durch Konstanten ersetzen
3. Alle Dateien aktualisieren

**Geschätzte Zeit:** 2-3 Stunden

---

### Phase 2: Naming Conventions (Mittel)

**Priorität:** Hoch
**Aufwand:** Mittel
**Risiko:** Mittel (viele Änderungen)

1. Funktionen umbenennen (PascalCase → snake_case)
2. Variablen konsistent machen
3. Alle Referenzen aktualisieren

**Geschätzte Zeit:** 4-6 Stunden

---

### Phase 3: Code-Organisation (Komplex)

**Priorität:** Mittel
**Aufwand:** Hoch
**Risiko:** Hoch (große Umstrukturierung)

1. `Core/` Verzeichnis erstellen
2. Core.lua aufteilen
3. Module erstellen
4. Imports aktualisieren

**Geschätzte Zeit:** 8-12 Stunden

---

### Phase 4: Formatierung & Kommentare (Einfach, zeitaufwendig)

**Priorität:** Niedrig
**Aufwand:** Mittel
**Risiko:** Niedrig

1. Einrückung konsistent machen (4 Spaces)
2. Leerzeilen standardisieren
3. Kommentare hinzufügen
4. Funktions-Header dokumentieren

**Geschätzte Zeit:** 6-8 Stunden

---

### Phase 5: Helper-Funktionen & Code-Duplikation (Mittel)

**Priorität:** Mittel
**Aufwand:** Mittel
**Risiko:** Mittel

1. `Utils/Helpers.lua` erstellen
2. Duplizierten Code extrahieren
3. Helper-Funktionen verwenden

**Geschätzte Zeit:** 4-6 Stunden

---

### Phase 6: Fehlerbehandlung & Validierung (Mittel)

**Priorität:** Hoch
**Aufwand:** Mittel
**Risiko:** Niedrig

1. `Utils/Validators.lua` erstellen
2. `Utils/APIHelpers.lua` erstellen
3. Validierung hinzufügen
4. Safe API-Calls implementieren

**Geschätzte Zeit:** 4-6 Stunden

---

## 12. Empfohlene Reihenfolge

### Sofort (Phase 1 + 6):
1. ✅ Konstanten erstellen (Phase 1)
2. ✅ Fehlerbehandlung hinzufügen (Phase 6)

**Grund:** Schnell, hoher Nutzen, niedriges Risiko

### Bald (Phase 2):
3. ✅ Naming Conventions (Phase 2)

**Grund:** Wichtig für Konsistenz, aber viele Änderungen

### Später (Phase 3, 4, 5):
4. ⚠️ Code-Organisation (Phase 3) - Nur wenn nötig
5. ⚠️ Formatierung & Kommentare (Phase 4) - Wartbarkeit
6. ⚠️ Helper-Funktionen (Phase 5) - Code-Qualität

---

## 13. Checkliste für jede Datei

### Vor Refactoring:
- [ ] Backup erstellen
- [ ] Tests durchführen (falls vorhanden)
- [ ] Git-Branch erstellen

### Während Refactoring:
- [ ] Naming Conventions prüfen
- [ ] Formatierung konsistent machen
- [ ] Kommentare hinzufügen
- [ ] Magic Numbers durch Konstanten ersetzen
- [ ] Code-Duplikation reduzieren
- [ ] Fehlerbehandlung hinzufügen

### Nach Refactoring:
- [ ] Code kompiliert ohne Fehler
- [ ] Addon funktioniert im Spiel
- [ ] Alle Features getestet
- [ ] Git-Commit mit klarer Nachricht

---

## 14. Beispiel: Refactored Code

### Vorher:
```lua
function addon:set_key(button)
    addon:reset_button_state(button)
    if button.original_icon_size then
        button.icon:SetSize(button.original_icon_size.width, button.original_icon_size.height)
    else
        button.icon:SetSize(50, 50)
    end
    local binding = addon:get_binding(button.raw_key)
    button.binding = binding
    -- ...
end
```

### Nachher:
```lua
--[[
    Updates a key button with its current binding and icon.
    
    Resets the button state, retrieves the binding, processes it,
    and updates the button's visual representation.
    
    @param button Frame The button frame to update
    @return nil
]]
function addon:update_key_button(button)
    -- Validate input
    Validators.validate_button(button)

    -- Reset button state
    addon:reset_button_state(button)

    -- Restore original icon size
    if button.original_icon_size then
        button.icon:SetSize(
            button.original_icon_size.width,
            button.original_icon_size.height
        )
    else
        button.icon:SetSize(
            Constants.ICON_SIZE_DEFAULT,
            Constants.ICON_SIZE_DEFAULT
        )
    end

    -- Get binding
    local binding = addon:get_key_binding(button.raw_key)
    button.binding = binding

    -- Process binding and update button
    -- ...
end
```

---

## 15. Zusammenfassung

### Kritische Verbesserungen:
1. ✅ **Konstanten** (Magic Numbers eliminieren)
2. ✅ **Naming Conventions** (Konsistenz)
3. ✅ **Fehlerbehandlung** (Robustheit)

### Wichtige Verbesserungen:
4. ⚠️ **Code-Organisation** (Wartbarkeit)
5. ⚠️ **Formatierung** (Lesbarkeit)
6. ⚠️ **Kommentare** (Dokumentation)

### Optionale Verbesserungen:
7. ⚠️ **Helper-Funktionen** (Code-Duplikation)
8. ⚠️ **Module-Struktur** (Architektur)

**Geschätzter Gesamtaufwand:** 28-41 Stunden

**Empfohlener Start:** Phase 1 (Konstanten) + Phase 6 (Fehlerbehandlung) - Schnell, hoher Nutzen!




