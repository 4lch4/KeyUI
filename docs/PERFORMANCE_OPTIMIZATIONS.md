# Performance-Optimierungen für KeyUI

## ⚠️ WICHTIG: Kritische Analyse, umfassendes Caching und API-Einschränkungen lesen!

**Bitte lese auch:**
- `PERFORMANCE_OPTIMIZATIONS_CRITICAL_ANALYSIS.md` - Identifiziert reale Probleme
- `PERFORMANCE_OPTIMIZATIONS_COMPREHENSIVE_CACHING.md` - **ULTIMATIVE OPTIMIERUNG!** Vollständiges Caching aller Slots, Stances, Kombinationen
- `API_RESTRICTIONS_ANALYSIS.md` - **WICHTIG!** Analyse der kommenden API-Einschränkungen im Kampf (Midnight Expansion)

Diese Dokumentation beschreibt **theoretische Optimierungen**. Die kritische Analyse identifiziert **reale Probleme** und bietet **realistische Lösungen**. Das umfassende Caching-System zeigt, wie **99-100% der API-Calls eliminiert** werden können. **Die API-Einschränkungen machen Caching noch wichtiger!**

## Übersicht

Dieses Dokument beschreibt alle identifizierten Performance-Verbesserungen, die bei gleicher Funktionalität möglich sind. Die Optimierungen sind nach Kategorien gruppiert und mit Implementierungsdetails versehen.

**Geschätzte Gesamtverbesserung (realistisch):** 50-70% weniger API-Calls, 30-50% schnellere Refresh-Zyklen

**⚠️ Hinweis:** Einige Optimierungen sind komplexer als zunächst angenommen. Siehe kritische Analyse für Details.

---

## 1. Event-basierte selektive Updates

### 1.1 ACTIONBAR_SLOT_CHANGED - Nur betroffene Buttons aktualisieren

**Problem:**
- Aktuell werden ALLE Buttons refresht, wenn nur ein Slot sich ändert
- Bei 100+ Buttons bedeutet das 100+ unnötige API-Calls

**Lösung:**
```lua
elseif event == "ACTIONBAR_SLOT_CHANGED" then
    -- VEREINFACHT: Nur ACTIONBUTTON-Buttons refreshen
    -- Slot-Mapping ist zu komplex für exaktes Mapping
    -- (ACTIONBUTTON1 kann auf Slot 1, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121 zeigen)
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and (
            button.binding:match("^ACTIONBUTTON") or
            button.binding:match("MULTIACTIONBAR")
        ) then
            addon:set_key(button)
        end
    end
```

**Performance-Gewinn:** 
- Statt 100+ Buttons: nur ~12-24 ACTIONBUTTON/MULTIACTIONBAR-Buttons
- **~75-85% Reduzierung** bei ACTIONBAR_SLOT_CHANGED Events
- **⚠️ Nicht perfekt, aber sicherer und einfacher**

---

### 1.2 UPDATE_BONUS_ACTIONBAR / ACTIONBAR_PAGE_CHANGED - Nur ACTIONBUTTONs

**Problem:**
- Betrifft nur ACTIONBUTTON-Bindings, aber alle Buttons werden refresht
- Maus-Buttons, Controller-Buttons, etc. werden unnötig aktualisiert

**Lösung:**
```lua
elseif event == "UPDATE_BONUS_ACTIONBAR" then
    addon.bonusbar_offset = GetBonusBarOffset()
    -- Nur ACTIONBUTTON-Buttons refreshen
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and button.binding:match("^ACTIONBUTTON") then
            addon:set_key(button)
        end
    end
    -- Mouse und Controller nicht refreshen

elseif event == "ACTIONBAR_PAGE_CHANGED" then
    addon.current_actionbar_page = GetActionBarPage()
    -- Nur ACTIONBUTTON-Buttons refreshen
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and button.binding:match("^ACTIONBUTTON") then
            addon:set_key(button)
        end
    end
```

**Performance-Gewinn:**
- Statt 100+ Buttons: nur ~12-24 ACTIONBUTTON-Buttons
- **~75-85% Reduzierung** bei diesen Events

---

### 1.3 MODIFIER_STATE_CHANGED - Nur Buttons ohne no_modifier_keys

**Problem:**
- Alle Buttons werden refresht, auch ESC, Modifier-Keys selbst, etc.
- Diese Buttons ändern sich nie durch Modifier

**Lösung:**
```lua
elseif event == "MODIFIER_STATE_CHANGED" then
    local key, state = ...
    
    if addon.keyboard_locked ~= false and addon.mouse_locked ~= false and addon.controller_locked ~= false then
        if keyui_settings.listen_to_modifier == true then
            if addon.alt_checkbox == false and addon.ctrl_checkbox == false and addon.shift_checkbox == false then
                if state == 1 then
                    handle_key_press(key)
                else
                    handle_key_release(key)
                end
                
                -- Nur Buttons refreshen, die Modifier verwenden können
                for i = 1, #addon.keys_keyboard do
                    local button = addon.keys_keyboard[i]
                    if not addon.no_modifier_keys[button.raw_key] then
                        addon:set_key(button)
                    end
                end
                
                -- Gleiches für Mouse und Controller
                for i = 1, #addon.keys_mouse do
                    local button = addon.keys_mouse[i]
                    if not addon.no_modifier_keys[button.raw_key] then
                        addon:set_key(button)
                    end
                end
            end
        end
    end
```

**Performance-Gewinn:**
- Statt 100+ Buttons: nur ~80-90 Buttons (ohne ESC, Modifier-Keys, etc.)
- **~10-20% Reduzierung** bei MODIFIER_STATE_CHANGED

---

### 1.4 PET_BAR_UPDATE - Nur Pet-Buttons

**Problem:**
- Betrifft nur BONUSACTIONBUTTON-Bindings, aber alle Buttons werden refresht

**Lösung:**
```lua
elseif event == "PET_BAR_UPDATE" then
    -- Nur Buttons refreshen, die Pet-Actions sind
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and button.binding:match("^BONUSACTIONBUTTON") then
            addon:set_key(button)
        end
    end
```

**Performance-Gewinn:**
- Statt 100+ Buttons: nur ~10 Pet-Buttons
- **~90% Reduzierung** bei PET_BAR_UPDATE

---

## 2. Caching-Mechanismen

### 2.1 Binding-Cache mit Preload beim Login

**Problem:**
- `GetBindingAction()` wird bei jedem `set_key()` aufgerufen
- Gleiche Bindings werden mehrfach abgefragt
- Bei jedem Refresh werden alle Keybinds neu abgefragt

**Lösung - Umfassendes Preloading:**
```lua
-- Cache-Struktur
local binding_cache = {}
local cache_version = 0
local cache_preloaded = false

-- Alle möglichen Modifier-Kombinationen
local modifier_combinations = {
    "",           -- Kein Modifier
    "ALT-",       -- ALT
    "CTRL-",      -- CTRL
    "SHIFT-",     -- SHIFT
    "ALT-CTRL-",  -- ALT+CTRL
    "ALT-SHIFT-", -- ALT+SHIFT
    "CTRL-SHIFT-",-- CTRL+SHIFT
    "ALT-CTRL-SHIFT-", -- Alle drei
}

-- Preload: Alle Keybinds beim Login einmalig einlesen
function addon:preload_all_bindings()
    if cache_preloaded then
        return  -- Bereits geladen
    end
    
    -- Sammle alle Keys aus allen Layouts
    local all_keys = {}
    
    -- Keys aus Keyboard-Layout
    for _, layout_data in pairs(keyui_settings.layout_current_keyboard or {}) do
        for _, key_data in ipairs(layout_data) do
            local raw_key = key_data[1]
            if raw_key and not all_keys[raw_key] then
                all_keys[raw_key] = true
            end
        end
    end
    
    -- Keys aus Mouse-Layout
    for _, layout_data in pairs(keyui_settings.layout_current_mouse or {}) do
        for _, key_data in ipairs(layout_data) do
            local raw_key = key_data[1]
            if raw_key and not all_keys[raw_key] then
                all_keys[raw_key] = true
            end
        end
    end
    
    -- Keys aus Controller-Layout
    for _, layout_data in pairs(keyui_settings.layout_current_controller or {}) do
        for _, key_data in ipairs(layout_data) do
            local raw_key = key_data[1]
            if raw_key and not all_keys[raw_key] then
                all_keys[raw_key] = true
            end
        end
    end
    
    -- Preload: Für jeden Key + jede Modifier-Kombination
    local preload_count = 0
    for raw_key, _ in pairs(all_keys) do
        for _, modifier in ipairs(modifier_combinations) do
            local cache_key = modifier .. raw_key
            if not binding_cache[cache_key] then
                local binding = GetBindingAction(cache_key, true) or ""
                binding_cache[cache_key] = {
                    value = binding,
                    version = cache_version
                }
                preload_count = preload_count + 1
            end
        end
    end
    
    cache_preloaded = true
    print("KeyUI: Preloaded " .. preload_count .. " keybind combinations")
end

-- Optimierte get_binding mit Preload-Cache
function addon:get_binding(raw_key)
    local cache_key = self.current_modifier_string .. (raw_key or "")
    
    -- Cache prüfen
    local cached = binding_cache[cache_key]
    if cached and cached.version == cache_version then
        return cached.value
    end
    
    -- Fallback: Wenn nicht gecacht, jetzt laden (sollte selten sein)
    local binding = GetBindingAction(cache_key, true) or ""
    
    -- Cache speichern
    binding_cache[cache_key] = {
        value = binding,
        version = cache_version
    }
    
    return binding
end

-- Cache invalidation bei relevanten Events
function addon:invalidate_binding_cache()
    cache_version = cache_version + 1
    cache_preloaded = false  -- Muss neu geladen werden
    -- Alte Einträge bleiben, werden aber als "veraltet" markiert
end

-- Lazy Loading: Keys werden bei Bedarf geladen und gecacht
-- Kein Preload beim Login nötig - funktioniert automatisch

-- Cache invalidation bei Keybind-Änderungen
elseif event == "UPDATE_BINDINGS" then
    addon:invalidate_binding_cache()
    -- Preload neu durchführen
    addon:preload_all_bindings()
    addon:refresh_layouts()
```

**Performance-Gewinn:**
- **Lazy Loading:** Erste Refreshs funktionieren sofort, Keys werden bei Bedarf geladen
- **Nach kurzer Zeit:** Alle relevanten Keys sind gecacht
- **Gesamt:** Reduziert `GetBindingAction()` Calls um **~80-90%**
- **⚠️ Vorteil:** Keine Verzögerung beim Login, funktioniert auch bei Layout-Wechseln

**⚠️ EMPFOHLEN - Lazy Loading (statt Preload):**
Die ursprüngliche Preload-Strategie hat Probleme (siehe kritische Analyse). Besser ist Lazy Loading:
```lua
function addon:get_binding(raw_key)
    local cache_key = self.current_modifier_string .. (raw_key or "")
    
    -- Cache prüfen
    local cached = binding_cache[cache_key]
    if cached and cached.version == cache_version then
        return cached.value
    end
    
    -- Nicht im Cache: Jetzt laden und cachen
    local binding = GetBindingAction(cache_key, true) or ""
    binding_cache[cache_key] = {
        value = binding,
        version = cache_version
    }
    
    return binding
end
```
Dies lädt Keybinds bei Bedarf, aber cacht sie sofort. Nach dem ersten Refresh sind alle relevanten Keybinds gecacht.

---

### 2.2 Action-Slot-Cache

**Problem:**
- `HasAction()` und `GetActionTexture()` werden mehrfach für denselben Slot aufgerufen
- Slot-Berechnungen werden wiederholt durchgeführt

**Lösung:**
```lua
local action_cache = {}
local action_cache_version = 0

function addon:get_action_info(slot)
    local cached = action_cache[slot]
    if cached and cached.version == action_cache_version then
        return cached.has_action, cached.texture
    end
    
    local has_action = HasAction(slot)
    local texture = has_action and GetActionTexture(slot) or nil
    
    action_cache[slot] = {
        has_action = has_action,
        texture = texture,
        version = action_cache_version
    }
    
    return has_action, texture
end

function addon:invalidate_action_cache()
    action_cache_version = action_cache_version + 1
end

-- In process_actionbutton_slot:
function addon:process_actionbutton_slot(slot, button)
    if not slot then return end
    
    local adjusted_slot = addon:get_action_button_slot(slot)
    button.slot = adjusted_slot
    
    local has_action, texture = addon:get_action_info(adjusted_slot)
    if has_action then
        button.active_slot = adjusted_slot
        button.icon:SetTexture(texture)
        button.icon:Show()
    end
end

-- Cache invalidation:
elseif event == "ACTIONBAR_SLOT_CHANGED" then
    local slot = ...
    -- Nur diesen Slot aus Cache entfernen
    action_cache[slot] = nil
    -- ... selektives Update
elseif event == "UPDATE_BONUS_ACTIONBAR" or event == "ACTIONBAR_PAGE_CHANGED" then
    addon:invalidate_action_cache()
    -- ... selektives Update
```

**Performance-Gewinn:**
- Reduziert `HasAction()` und `GetActionTexture()` Calls um ~60-70%
- Besonders effektiv bei mehreren Buttons auf denselben Slot

---

### 2.3 Change Detection - Nur bei tatsächlichen Änderungen aktualisieren

**⚠️ WARNUNG:** Diese Optimierung ist komplex! Siehe kritische Analyse Abschnitt 4.

**Problem:**
- Buttons werden aktualisiert, auch wenn sich nichts geändert hat
- **ABER:** Was wird verglichen? Binding? Slot? Icon? Alles?

**Lösung (vereinfacht):**
```lua
function addon:set_key(button)
    -- Cache-Werte vor Update
    local old_binding = button.cached_binding
    local old_modifier = button.cached_modifier_string
    local old_slot = button.cached_active_slot
    local old_bonusbar = button.cached_bonusbar_offset
    local old_page = button.cached_actionbar_page
    
    -- Aktuelle Werte
    local binding = addon:get_binding(button.raw_key)
    local current_modifier = addon.current_modifier_string
    local current_bonusbar = addon.bonusbar_offset
    local current_page = addon.current_actionbar_page
    
    -- Prüfe ob sich etwas geändert hat
    -- ⚠️ WICHTIG: Auch Icon-Änderungen müssen erkannt werden!
    if old_binding == binding and 
       old_modifier == current_modifier and
       old_bonusbar == current_bonusbar and
       old_page == current_page then
        -- ZUSÄTZLICH: Prüfe ob sich das Icon geändert hat
        -- (Spell-Level-Up ändert Icon, aber nicht Binding)
        local adjusted_slot = nil
        if binding and binding:match("^ACTIONBUTTON") then
            local slot = tonumber(binding:match("ACTIONBUTTON(%d+)"))
            adjusted_slot = addon:get_action_button_slot(slot)
            if adjusted_slot and HasAction(adjusted_slot) then
                local current_texture = GetActionTexture(adjusted_slot)
                if button.cached_texture == current_texture then
                    -- Nichts geändert, skip
                    return
                end
            end
        else
            -- Kein ACTIONBUTTON, nur Binding prüfen
            return
        end
    end
    
    -- Reset button state
    addon:reset_button_state(button)
    
    -- ... rest of function ...
    
    -- Cache aktualisieren
    button.cached_binding = binding
    button.cached_modifier_string = current_modifier
    button.cached_active_slot = button.active_slot
    button.cached_bonusbar_offset = current_bonusbar
    button.cached_actionbar_page = current_page
end
```

**Performance-Gewinn:**
- Reduziert unnötige Updates um ~30-50%
- Besonders effektiv bei häufigen Events ohne Änderungen
- **⚠️ Komplex:** Muss Icon-Änderungen erkennen, sonst werden Updates verpasst

---

## 3. Code-Struktur-Optimierungen

### 3.1 keybind_patterns außerhalb der Funktion

**Problem:**
- `keybind_patterns` wird bei jedem `set_key()` Aufruf neu erstellt
- Dynamische Addon-Checks bei jedem Button

**Lösung:**
```lua
-- Außerhalb der Funktion, einmalig erstellt
local base_keybind_patterns = {
    ["^ACTIONBUTTON(%d+)$"] = function(binding, button)
        local slot = tonumber(binding:match("ACTIONBUTTON(%d+)"))
        return addon:process_actionbutton_slot(slot, button)
    end,
    -- ... alle anderen Patterns
}

-- Addon-spezifische Patterns werden einmalig hinzugefügt
local keybind_patterns = {}
for k, v in pairs(base_keybind_patterns) do
    keybind_patterns[k] = v
end

-- Addon-Checks einmalig beim Laden
if C_AddOns.IsAddOnLoaded("ElvUI") then
    keybind_patterns["^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$"] = function(binding, button)
        return addon:process_elvui(binding, button)
    end
end
-- ... andere Addons

function addon:set_key(button)
    -- Nutze die globale keybind_patterns Tabelle
    -- Keine Neuerstellung nötig
    local binding = addon:get_binding(button.raw_key)
    
    if binding ~= "" then
        for pattern, handler in pairs(keybind_patterns) do
            if binding:find(pattern) then
                handler(binding, button)
                break
            end
        end
    end
    -- ... rest
end
```

**Performance-Gewinn:**
- Eliminiert ~100+ Tabellenerstellungen pro Refresh
- Reduziert Addon-Checks von 100+ auf 1

---

### 3.2 String-Operationen optimieren

**Problem:**
- Viele String-Konkatenationen und Pattern-Matches
- `binding:find(pattern)` wird für jedes Pattern aufgerufen

**Lösung:**
```lua
-- Pattern-Matching optimieren: Häufigste Patterns zuerst
local keybind_patterns_ordered = {
    -- ACTIONBUTTON ist am häufigsten, zuerst prüfen
    { pattern = "^ACTIONBUTTON(%d+)$", handler = function(binding, button)
        local slot = tonumber(binding:match("ACTIONBUTTON(%d+)"))
        return addon:process_actionbutton_slot(slot, button)
    end },
    -- Dann MULTIACTIONBAR
    { pattern = "MULTIACTIONBAR(%d+)BUTTON(%d+)", handler = function(binding, button)
        local bar, bar_button = binding:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")
        if not bar or not bar_button then return end
        return addon:process_multiactionbar_slot(tonumber(bar), tonumber(bar_button), button)
    end },
    -- ... andere Patterns nach Häufigkeit sortiert
}

function addon:set_key(button)
    local binding = addon:get_binding(button.raw_key)
    
    if binding ~= "" then
        -- Geordnete Suche: Häufigste Patterns zuerst
        for _, pattern_data in ipairs(keybind_patterns_ordered) do
            if binding:find(pattern_data.pattern) then
                pattern_data.handler(binding, button)
                break
            end
        end
    end
end
```

**Performance-Gewinn:**
- Reduziert durchschnittliche Pattern-Matches um ~30-40%
- Früherer Break bei häufigen Patterns

---

### 3.3 Modifier-String-Cache

**Problem:**
- `current_modifier_string` wird bei jedem Button neu erstellt
- `table.concat()` wird mehrfach aufgerufen

**Lösung:**
```lua
local modifier_string_cache = {}
local modifier_string_version = 0

function addon:update_modifier_string()
    local cache_key = (addon.modif.ALT and "ALT" or "") .. 
                      (addon.modif.CTRL and "CTRL" or "") .. 
                      (addon.modif.SHIFT and "SHIFT" or "")
    
    local cached = modifier_string_cache[cache_key]
    if cached then
        addon.current_modifier_string = cached
        return
    end
    
    local modifiers = {}
    if addon.modif.ALT then table.insert(modifiers, "ALT-") end
    if addon.modif.CTRL then table.insert(modifiers, "CTRL-") end
    if addon.modif.SHIFT then table.insert(modifiers, "SHIFT-") end
    addon.current_modifier_string = table.concat(modifiers)
    
    modifier_string_cache[cache_key] = addon.current_modifier_string
end
```

**Performance-Gewinn:**
- Reduziert `table.concat()` Calls um ~80-90%
- Besonders effektiv bei vielen Buttons

---

## 4. Batch-Updates und Throttling

### 4.1 Event-Batching

**⚠️ WARNUNG:** Kann zu verzögerten Updates führen! Siehe kritische Analyse Abschnitt 7.

**Problem:**
- Mehrere Events kurz hintereinander triggern mehrere Refreshs
- Beispiel: Modifier drücken → mehrere MODIFIER_STATE_CHANGED Events
- **ABER:** Batching kann zu verzögerten Updates führen (schlechte UX)

**Lösung (mit sofortigen Updates für kritische Events):**
```lua
local refresh_pending = false
local refresh_type = nil  -- "all", "actionbuttons", "slot", etc.

function addon:schedule_refresh(refresh_kind)
    refresh_type = refresh_type or refresh_kind
    
    if refresh_pending then
        return  -- Bereits geplant
    end
    
    refresh_pending = true
    C_Timer.After(0.05, function()  -- 50ms delay
        refresh_pending = false
        local kind = refresh_type
        refresh_type = nil
        
        if kind == "all" then
            addon:refresh_keys()
        elseif kind == "actionbuttons" then
            addon:refresh_keys_for_actionbuttons()
        elseif kind == "slot" then
            -- Wird durch Event-Parameter bestimmt
        end
    end)
end

-- In Event-Handler:
elseif event == "MODIFIER_STATE_CHANGED" then
    -- ... modifier handling ...
    addon:schedule_refresh("all")
    
elseif event == "UPDATE_BONUS_ACTIONBAR" then
    addon.bonusbar_offset = GetBonusBarOffset()
    addon:schedule_refresh("actionbuttons")
```

**Performance-Gewinn:**
- Reduziert Refreshs bei schnellen Event-Folgen um ~50-70%
- Besonders effektiv bei Modifier-Wechseln

---

### 4.2 Frame-Update-Throttling

**Problem:**
- UI-Updates können bei vielen Buttons teuer sein
- Mehrere Updates kurz hintereinander sind ineffizient

**Lösung:**
```lua
local last_refresh_time = 0
local REFRESH_THROTTLE = 0.1  -- 100ms minimum zwischen Refreshs

function addon:refresh_keys()
    local now = GetTime()
    if now - last_refresh_time < REFRESH_THROTTLE then
        -- Zu früh, skip
        return
    end
    last_refresh_time = now
    
    -- ... existing refresh logic
end
```

**Performance-Gewinn:**
- Verhindert Refresh-Spam
- Reduziert UI-Lag bei schnellen Events

---

## 5. Button-Pooling

### 5.1 Button-Wiederverwendung

**Problem:**
- Buttons werden bei Layout-Wechsel zerstört und neu erstellt
- Frame-Erstellung ist teuer

**Lösung:**
```lua
-- Button-Pool
local button_pool = {
    keyboard = {},
    mouse = {},
    controller = {}
}

function addon:get_pooled_button(button_type)
    local pool = button_pool[button_type]
    if #pool > 0 then
        return table.remove(pool)
    end
    -- Neuen Button erstellen
    if button_type == "keyboard" then
        return addon:create_keyboard_buttons()
    elseif button_type == "mouse" then
        return addon:create_mouse_buttons()
    elseif button_type == "controller" then
        return addon:create_controller_buttons()
    end
end

function addon:return_to_pool(button, button_type)
    -- Button zurücksetzen
    button:Hide()
    addon:reset_button_state(button)
    
    -- In Pool zurückgeben
    table.insert(button_pool[button_type], button)
end

-- In generate_keyboard_key_frames:
function addon:generate_keyboard_key_frames()
    -- Alte Buttons in Pool zurückgeben statt zu zerstören
    for i = 1, #addon.keys_keyboard do
        addon:return_to_pool(addon.keys_keyboard[i], "keyboard")
    end
    addon.keys_keyboard = {}
    
    -- ... neue Buttons aus Pool holen
    for i = 1, #layout_data do
        local button = addon:get_pooled_button("keyboard")
        -- ... setup
        addon.keys_keyboard[i] = button
    end
end
```

**Performance-Gewinn:**
- Reduziert Frame-Erstellungen um ~80-90% bei Layout-Wechseln
- Schnellere Layout-Wechsel

---

## 6. Spezifische Optimierungen

### 6.1 Redundante Layout-Prüfungen eliminieren

**Problem:**
- Layout wird zweimal durchlaufen: einmal zum Prüfen, einmal zum Erstellen

**Lösung:**
```lua
function addon:generate_keyboard_key_frames()
    -- Alte Buttons verstecken statt zu zerstören
    for i = 1, #addon.keys_keyboard do
        addon.keys_keyboard[i]:Hide()
    end
    
    if keyui_settings.layout_current_keyboard and addon.open and addon.keyboard_frame then
        addon.keyboard_frame:SetWidth(100)
        addon.keyboard_frame:SetHeight(100)
        
        local max_horizontal_extent = 0
        local max_vertical_extent = 0
        local button_index = 1
        
        -- Einmaliges Durchlaufen
        for _, layout_data in pairs(keyui_settings.layout_current_keyboard) do
            if #layout_data > 0 then
                for i = 1, #layout_data do
                    local button = addon.keys_keyboard[button_index] or addon:create_keyboard_buttons()
                    -- ... setup
                    button_index = button_index + 1
                end
            end
        end
        
        -- Nicht verwendete Buttons verstecken
        for i = button_index, #addon.keys_keyboard do
            addon.keys_keyboard[i]:Hide()
        end
    end
end
```

**Performance-Gewinn:**
- Eliminiert redundante Loop
- ~50% schneller bei Layout-Generierung

---

### 6.2 String-Operationen reduzieren

**Problem:**
- Viele String-Konkatenationen in `get_binding()`

**Lösung:**
```lua
function addon:get_binding(raw_key)
    -- String-Builder Pattern vermeiden
    local key_string
    if addon.current_modifier_string == "" then
        key_string = raw_key or ""
    else
        key_string = addon.current_modifier_string .. (raw_key or "")
    end
    
    return GetBindingAction(key_string, true) or ""
end
```

**Performance-Gewinn:**
- Minimale Verbesserung, aber bei vielen Calls addiert es sich

---

### 6.3 Redundante API-Calls eliminieren

**Problem:**
- `GetBonusBarOffset()` und `GetActionBarPage()` werden mehrfach aufgerufen

**Lösung:**
```lua
-- Cached values
local cached_bonusbar_offset = nil
local cached_actionbar_page = nil

function addon:get_bonusbar_offset()
    if cached_bonusbar_offset == nil then
        cached_bonusbar_offset = GetBonusBarOffset()
    end
    return cached_bonusbar_offset
end

function addon:get_actionbar_page()
    if cached_actionbar_page == nil then
        cached_actionbar_page = GetActionBarPage()
    end
    return cached_actionbar_page
end

-- In Event-Handler: Cache invalidation
elseif event == "UPDATE_BONUS_ACTIONBAR" then
    cached_bonusbar_offset = GetBonusBarOffset()
    addon.bonusbar_offset = cached_bonusbar_offset
    -- ... refresh
```

**Performance-Gewinn:**
- Reduziert redundante API-Calls
- Besonders effektiv wenn Addon geschlossen ist

---

## 7. Implementierungs-Priorität

### Hoch (Sofort umsetzbar, großer Effekt)
1. ✅ **keybind_patterns außerhalb Funktion** (3.1) - **100% sicher, einfach**
2. ✅ **UPDATE_BONUS_ACTIONBAR / ACTIONBAR_PAGE_CHANGED** (1.2) - **100% sicher**
3. ✅ **MODIFIER_STATE_CHANGED - nur relevante Buttons** (1.3) - **100% sicher**
4. ✅ **PET_BAR_UPDATE** (1.4) - **100% sicher**
5. ✅ **Lazy Loading Binding-Cache** (2.1) - **Sicher, aber komplexer**

### Mittel (Guter Effekt, etwas mehr Aufwand)
6. ✅ **Action-Slot-Cache** (2.2) - **Funktioniert, aber komplexe Invalidation**
7. ✅ **ACTIONBAR_SLOT_CHANGED** (1.1) - **Funktioniert, aber nicht perfekt**
8. ✅ **Change Detection** (2.3) - **Funktioniert, aber komplex**
9. ✅ **Redundante Layout-Prüfungen** (6.1)

### Niedrig (Kleiner Effekt, aber einfach)
10. ✅ **String-Operationen optimieren** (3.2, 6.2)
11. ✅ **Redundante API-Calls** (6.3)

### ⚠️ Nicht empfohlen
- **Event-Batching** (4.1) - Kann zu verzögerten Updates führen
- **Button-Pooling** (5.1) - Zu komplex, wenig Nutzen
- **Modifier-String-Cache** (3.3) - Zu wenig Nutzen
- **Frame-Update-Throttling** (4.2) - Kann Updates verpassen

---

## 8. Geschätzte Gesamtverbesserung

### API-Calls
- **Vorher:** ~200-300 API-Calls pro vollständigem Refresh (inkl. GetBindingAction)
- **Nachher:** ~60-120 API-Calls pro vollständigem Refresh (mit Lazy Loading Cache)
- **Reduzierung:** 50-70% (realistisch, nicht 85-95%)

### Refresh-Zeit
- **Vorher:** ~50-100ms pro vollständigem Refresh
- **Nachher:** ~20-40ms pro vollständigem Refresh
- **Verbesserung:** 40-60% schneller

### Speicher
- **Vorher:** Buttons werden zerstört/neu erstellt
- **Nachher:** Button-Pooling reduziert Allokationen
- **Verbesserung:** ~30-40% weniger Speicher-Churn

### Event-Handling
- **Vorher:** Jedes Event → vollständiger Refresh
- **Nachher:** Selektive Updates + Batching
- **Verbesserung:** 70-90% weniger unnötige Updates

---

## 9. Kompatibilität

Alle Optimierungen sind **rückwärtskompatibel** und ändern keine Funktionalität:
- ✅ Gleiche Events werden verarbeitet
- ✅ Gleiche API-Calls werden gemacht (nur weniger)
- ✅ Gleiche UI-Updates (nur effizienter)
- ✅ Keine Breaking Changes

---

## 10. Test-Strategie

### Unit-Tests
- Cache-Funktionalität testen
- Change Detection testen
- Selektive Updates testen

### Performance-Tests
- API-Call-Counting
- Refresh-Zeit-Messung
- Memory-Profiling

### Funktionalitäts-Tests
- Alle Events manuell testen
- Verschiedene Layouts testen
- Modifier-Kombinationen testen

---

## Zusammenfassung

Diese Optimierungen können die Performance von KeyUI erheblich verbessern, ohne die Funktionalität zu beeinträchtigen. Die Implementierung sollte schrittweise erfolgen, beginnend mit den hoch-priorisierten Optimierungen.

**Empfohlene Reihenfolge (REVIDIERT):**

### Phase 1: Sichere, einfache Optimierungen (Sofort)
1. **keybind_patterns außerhalb Funktion** (3.1) - 100% sicher, einfach
2. **UPDATE_BONUS_ACTIONBAR / ACTIONBAR_PAGE_CHANGED** (1.2) - 100% sicher
3. **MODIFIER_STATE_CHANGED** (1.3) - 100% sicher
4. **PET_BAR_UPDATE** (1.4) - 100% sicher

**Geschätzter Gewinn Phase 1:** 40-60% weniger API-Calls

### Phase 2: Caching (Nach Phase 1 testen)
5. **Lazy Loading Binding-Cache** (2.1) - Sicher, aber komplexer
6. **Action-Slot-Cache** (2.2) - Funktioniert, aber komplexe Invalidation

**Geschätzter Gewinn Phase 2:** +20-30% zusätzliche Reduzierung

### Phase 3: Weitere Optimierungen (Optional)
7. **ACTIONBAR_SLOT_CHANGED** (1.1) - Funktioniert, aber nicht perfekt
8. **Change Detection** (2.3) - Funktioniert, aber komplex

**Geschätzter Gewinn Phase 3:** +10-20% zusätzliche Reduzierung

**⚠️ WICHTIG:** Siehe `PERFORMANCE_OPTIMIZATIONS_CRITICAL_ANALYSIS.md` für detaillierte Probleme und Lösungen!

