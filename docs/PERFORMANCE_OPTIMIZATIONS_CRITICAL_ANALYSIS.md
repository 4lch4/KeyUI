# Kritische Analyse der Performance-Optimierungen

## ⚠️ Wichtige Erkenntnisse und Probleme

Diese Analyse identifiziert **reale Probleme** mit den vorgeschlagenen Optimierungen und bietet **realistische Lösungen**.

---

## 1. Preload beim Login - Probleme und Lösungen

### ❌ Problem 1: Layouts können sich ändern

**Problem:**
- Beim Login werden nur die **aktuellen** Layouts gecacht
- Wenn der Spieler ein **neues Layout lädt**, sind die Keys nicht im Cache
- Wenn der Spieler ein **Layout editiert** und neue Keys hinzufügt, fehlen diese im Cache

**Lösung:**
```lua
-- Preload muss auch bei Layout-Wechsel aufgerufen werden
function addon:preload_all_bindings()
    -- ... existing code ...
    cache_preloaded = true
end

-- Bei Layout-Wechsel: Cache erweitern
function addon:generate_keyboard_layout(layout_name)
    -- ... existing code ...
    
    -- Neue Keys aus dem Layout zum Cache hinzufügen
    addon:extend_binding_cache_for_layout(layout_name, "keyboard")
end

function addon:extend_binding_cache_for_layout(layout_name, layout_type)
    local layout
    if layout_type == "keyboard" then
        layout = addon.default_keyboard_layouts[layout_name] or keyui_settings.layout_edited_keyboard[layout_name]
    elseif layout_type == "mouse" then
        layout = addon.default_mouse_layouts[layout_name] or keyui_settings.layout_edited_mouse[layout_name]
    elseif layout_type == "controller" then
        layout = addon.default_controller_layouts[layout_name] or keyui_settings.layout_edited_controller[layout_name]
    end
    
    if not layout then return end
    
    -- Neue Keys zum Cache hinzufügen
    for _, key_data in ipairs(layout) do
        local raw_key = key_data[1]
        if raw_key then
            for _, modifier in ipairs(modifier_combinations) do
                local cache_key = modifier .. raw_key
                if not binding_cache[cache_key] then
                    local binding = GetBindingAction(cache_key, true) or ""
                    binding_cache[cache_key] = {
                        value = binding,
                        version = cache_version
                    }
                end
            end
        end
    end
end
```

### ❌ Problem 2: Lazy Loading ist sicherer

**Problem:**
- Preload beim Login könnte zu lange dauern (200-400 API-Calls)
- Was wenn das Addon beim Login noch nicht vollständig geladen ist?
- Was wenn Layouts noch nicht initialisiert sind?

**Bessere Lösung - Hybrid-Ansatz:**
```lua
-- Lazy Loading mit automatischem Preload
function addon:get_binding(raw_key)
    local cache_key = self.current_modifier_string .. (raw_key or "")
    
    -- Cache prüfen
    local cached = binding_cache[cache_key]
    if cached and cached.version == cache_version then
        return cached.value
    end
    
    -- Nicht im Cache: Jetzt laden
    local binding = GetBindingAction(cache_key, true) or ""
    
    -- Cache speichern
    binding_cache[cache_key] = {
        value = binding,
        version = cache_version
    }
    
    -- Nach dem ersten Refresh: Preload alle anderen Keys aus Layouts
    if not cache_preloaded and addon.open then
        C_Timer.After(0.1, function()
            addon:preload_remaining_bindings()
        end)
    end
    
    return binding
end

function addon:preload_remaining_bindings()
    if cache_preloaded then return end
    
    -- Sammle alle Keys aus Layouts
    local all_keys = {}
    -- ... (wie vorher)
    
    -- Preload nur die, die noch nicht im Cache sind
    for raw_key, _ in pairs(all_keys) do
        for _, modifier in ipairs(modifier_combinations) do
            local cache_key = modifier .. raw_key
            if not binding_cache[cache_key] then
                local binding = GetBindingAction(cache_key, true) or ""
                binding_cache[cache_key] = {
                    value = binding,
                    version = cache_version
                }
            end
        end
    end
    
    cache_preloaded = true
end
```

**Vorteil:** 
- Erste Refreshs funktionieren sofort (lazy loading)
- Nach kurzer Zeit sind alle Keys gecacht (preload im Hintergrund)
- Keine Verzögerung beim Login

---

## 2. ACTIONBAR_SLOT_CHANGED - Komplexes Mapping-Problem

### ❌ Problem: Slot-Mapping ist dynamisch

**Problem:**
- `ACTIONBUTTON1` kann auf **verschiedene Slots** zeigen:
  - Page 1: Slot 1
  - Page 2: Slot 13
  - Page 3: Slot 25
  - Stance 1 (Druid): Slot 73
  - Stance 2 (Druid): Slot 85
  - etc.

- Wenn Slot 13 sich ändert, müssen wir wissen:
  - Welche Buttons zeigen auf Slot 13?
  - Das hängt von `current_actionbar_page` und `bonusbar_offset` ab!

**Realistische Lösung:**
```lua
elseif event == "ACTIONBAR_SLOT_CHANGED" then
    local changed_slot = ...  -- Der geänderte Slot (1-180)
    
    -- Problem: Wir müssen rückwärts rechnen
    -- Slot 13 könnte sein:
    -- - ACTIONBUTTON1 auf Page 2 (13 = 1 + 12)
    -- - ACTIONBUTTON2 auf Page 2 (13 = 2 + 12) - NEIN, das wäre 14!
    -- - MULTIACTIONBAR3BUTTON1 (13 = 25 - 12) - NEIN!
    
    -- Realistische Lösung: Alle ACTIONBUTTON-Buttons refreshen
    -- Die Slot-Berechnung ist zu komplex für exaktes Mapping
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and (
            button.binding:match("^ACTIONBUTTON") or
            button.binding:match("MULTIACTIONBAR")
        ) then
            -- Prüfe ob dieser Button auf den geänderten Slot zeigen könnte
            local slot_num = button.binding:match("ACTIONBUTTON(%d+)")
            if slot_num then
                local base_slot = tonumber(slot_num)
                -- Prüfe alle möglichen Slot-Kombinationen
                local possible_slots = {
                    base_slot,                    -- Page 1, keine Stance
                    base_slot + 12,               -- Page 2
                    base_slot + 24,               -- Page 3
                    base_slot + 36,               -- Page 4
                    base_slot + 48,               -- Page 5
                    base_slot + 60,               -- Page 6
                    base_slot + 72,               -- Stance 1
                    base_slot + 84,               -- Stance 2
                    base_slot + 96,               -- Stance 3
                    base_slot + 108,              -- Stance 4
                    base_slot + 120,              -- Stance 5
                }
                
                for _, possible_slot in ipairs(possible_slots) do
                    if possible_slot == changed_slot then
                        addon:set_key(button)
                        break
                    end
                end
            elseif button.binding:match("MULTIACTIONBAR") then
                -- MULTIACTIONBAR Slots sind statisch, einfacher
                local bar, btn = button.binding:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")
                if bar and btn then
                    local multi_slot = addon:calculate_multibar_slot(tonumber(bar), tonumber(btn))
                    if multi_slot == changed_slot then
                        addon:set_key(button)
                    end
                end
            end
        end
    end
```

**Problem:** Das ist immer noch komplex und könnte fehleranfällig sein.

**Einfachere Alternative:**
```lua
elseif event == "ACTIONBAR_SLOT_CHANGED" then
    -- Einfacher: Nur ACTIONBUTTON-Buttons refreshen
    -- Die Slot-Berechnung ist zu komplex für exaktes Mapping
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and button.binding:match("^ACTIONBUTTON") then
            addon:set_key(button)
        end
    end
    -- MULTIACTIONBAR-Buttons sind statisch, können auch refresht werden
    for i = 1, #addon.keys_keyboard do
        local button = addon.keys_keyboard[i]
        if button.binding and button.binding:match("MULTIACTIONBAR") then
            addon:set_key(button)
        end
    end
```

**Performance:** Immer noch besser als alle Buttons, aber nicht perfekt.

---

## 3. UPDATE_BONUS_ACTIONBAR / ACTIONBAR_PAGE_CHANGED - Realistische Lösung

### ✅ Diese Optimierung ist realistisch

**Warum:**
- ACTIONBUTTON-Bindings sind klar identifizierbar
- Die Slot-Berechnung ändert sich für ALLE ACTIONBUTTONs gleichzeitig
- Kein komplexes Mapping nötig

**Implementierung:**
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
    -- Mouse und Controller nicht refreshen (korrekt!)

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

**✅ Funktioniert:** Ja, diese Optimierung ist sicher und realistisch.

---

## 4. Change Detection - Probleme

### ❌ Problem: Was wird verglichen?

**Problem:**
- Button zeigt Icon von Slot 5
- Spieler wechselt Spell auf Slot 5
- Binding bleibt gleich ("ACTIONBUTTON1")
- Aber Icon ändert sich!

**Lösung:**
```lua
function addon:set_key(button)
    -- Cache-Werte vor Update
    local old_binding = button.cached_binding
    local old_active_slot = button.cached_active_slot
    local old_modifier = button.cached_modifier_string
    local old_bonusbar = button.cached_bonusbar_offset
    local old_page = button.cached_actionbar_page
    
    -- Aktuelle Werte
    local binding = addon:get_binding(button.raw_key)
    local current_modifier = addon.current_modifier_string
    local current_bonusbar = addon.bonusbar_offset
    local current_page = addon.current_actionbar_page
    
    -- WICHTIG: Auch den tatsächlichen Slot prüfen
    local adjusted_slot = nil
    if binding and binding:match("^ACTIONBUTTON") then
        local slot = tonumber(binding:match("ACTIONBUTTON(%d+)"))
        adjusted_slot = addon:get_action_button_slot(slot)
    end
    
    -- Prüfe ob sich etwas geändert hat
    if old_binding == binding and 
       old_modifier == current_modifier and
       old_bonusbar == current_bonusbar and
       old_page == current_page and
       old_active_slot == adjusted_slot then
        -- ZUSÄTZLICH: Prüfe ob sich das Icon geändert hat
        if adjusted_slot and HasAction(adjusted_slot) then
            local current_texture = GetActionTexture(adjusted_slot)
            if button.cached_texture == current_texture then
                -- Nichts geändert, skip
                return
            end
        else
            -- Kein Action, nichts geändert
            return
        end
    end
    
    -- ... rest of function ...
    
    -- Cache aktualisieren
    button.cached_binding = binding
    button.cached_modifier_string = current_modifier
    button.cached_active_slot = adjusted_slot
    button.cached_bonusbar_offset = current_bonusbar
    button.cached_actionbar_page = current_page
    if adjusted_slot and HasAction(adjusted_slot) then
        button.cached_texture = GetActionTexture(adjusted_slot)
    else
        button.cached_texture = nil
    end
end
```

**Problem:** Das macht die Change Detection komplexer und könnte fehleranfällig sein.

**Alternative:** Change Detection nur für Binding-Änderungen, nicht für Icon-Änderungen.

---

## 5. keybind_patterns außerhalb Funktion - ✅ Funktioniert

**Warum:**
- Patterns ändern sich nie
- Addon-Checks können beim Laden gemacht werden
- Keine Probleme erwartet

**✅ Diese Optimierung ist sicher.**

---

## 6. Modifier-String-Cache - ⚠️ Problem

### ❌ Problem: Modifier-String ändert sich dynamisch

**Problem:**
- `current_modifier_string` wird bei jedem Modifier-Change aktualisiert
- Cache muss invalidiert werden, wenn sich Modifier ändern
- Aber: Der Cache-Key ändert sich ja sowieso!

**Realität:**
- Modifier-String wird nur bei `MODIFIER_STATE_CHANGED` geändert
- Das passiert selten genug, dass Caching nicht nötig ist
- `table.concat()` ist schnell genug

**Fazit:** Diese Optimierung bringt wenig, kann aber implementiert werden.

---

## 7. Event-Batching - ⚠️ Problem

### ❌ Problem: Kann zu verzögerten Updates führen

**Problem:**
- Spieler drückt SHIFT → Modifier ändert sich
- 50ms Delay → Buttons werden nicht sofort aktualisiert
- Spieler sieht veraltete Anzeige

**Lösung:**
```lua
-- Nur für bestimmte Events batching, nicht für Modifier
local refresh_pending = false

function addon:schedule_refresh(refresh_kind, immediate)
    if immediate then
        -- Sofort refreshen (z.B. Modifier-Change)
        if refresh_kind == "all" then
            addon:refresh_keys()
        elseif refresh_kind == "actionbuttons" then
            addon:refresh_keys_for_actionbuttons()
        end
        return
    end
    
    -- Batching nur für nicht-kritische Events
    refresh_type = refresh_type or refresh_kind
    
    if refresh_pending then
        return
    end
    
    refresh_pending = true
    C_Timer.After(0.05, function()
        refresh_pending = false
        local kind = refresh_type
        refresh_type = nil
        
        if kind == "all" then
            addon:refresh_keys()
        elseif kind == "actionbuttons" then
            addon:refresh_keys_for_actionbuttons()
        end
    end)
end

-- Modifier-Change: Sofort
elseif event == "MODIFIER_STATE_CHANGED" then
    -- ... modifier handling ...
    addon:schedule_refresh("all", true)  -- immediate = true

-- Andere Events: Batching
elseif event == "UPDATE_BONUS_ACTIONBAR" then
    addon.bonusbar_offset = GetBonusBarOffset()
    addon:schedule_refresh("actionbuttons", false)  -- Batching OK
```

---

## 8. Button-Pooling - ⚠️ Komplexität

### ❌ Problem: Buttons haben State

**Problem:**
- Buttons haben Event-Handler, Texturen, etc.
- Zurücksetzen ist komplex
- Könnte zu Memory-Leaks führen wenn nicht richtig gemacht

**Realistische Lösung:**
- Button-Pooling ist komplex
- Aktueller Ansatz (Buttons werden wiederverwendet wenn möglich) ist gut genug
- Nur implementieren wenn wirklich nötig

---

## 9. Realistische Prioritätenliste (REVIDIERT)

### ✅ Sicher und einfach umsetzbar:
1. **keybind_patterns außerhalb Funktion** (3.1) - 100% sicher
2. **UPDATE_BONUS_ACTIONBAR / ACTIONBAR_PAGE_CHANGED** (1.2) - 100% sicher
3. **MODIFIER_STATE_CHANGED - nur relevante Buttons** (1.3) - 100% sicher
4. **PET_BAR_UPDATE** (1.4) - 100% sicher
5. **Lazy Loading Binding-Cache** (2.1) - Sicher, aber komplexer

### ⚠️ Funktioniert, aber mit Einschränkungen:
6. **ACTIONBAR_SLOT_CHANGED** (1.1) - Funktioniert, aber nicht perfekt (nur ACTIONBUTTONs)
7. **Change Detection** (2.3) - Funktioniert, aber komplex
8. **Action-Slot-Cache** (2.2) - Funktioniert, aber muss bei jedem Slot-Change invalidiert werden

### ❌ Nicht empfohlen oder zu komplex:
9. **Event-Batching** (4.1) - Kann zu verzögerten Updates führen
10. **Button-Pooling** (5.1) - Zu komplex, wenig Nutzen
11. **Modifier-String-Cache** (3.3) - Zu wenig Nutzen

---

## 10. Realistische Performance-Verbesserung (REVIDIERT)

### Mit sicheren Optimierungen:
- **API-Calls:** 50-70% Reduzierung (nicht 85-95%)
- **Refresh-Zeit:** 30-50% schneller (nicht 50-70%)
- **Event-Handling:** 60-80% weniger unnötige Updates

### Warum weniger als ursprünglich geschätzt?
- Preload ist komplexer als gedacht
- ACTIONBAR_SLOT_CHANGED Mapping ist nicht perfekt
- Change Detection ist komplexer
- Einige Optimierungen bringen weniger als erwartet

---

## 11. Empfohlene Implementierungs-Reihenfolge (REVIDIERT)

### Phase 1: Sichere, einfache Optimierungen (Sofort)
1. keybind_patterns außerhalb Funktion
2. UPDATE_BONUS_ACTIONBAR - nur ACTIONBUTTONs
3. ACTIONBAR_PAGE_CHANGED - nur ACTIONBUTTONs
4. MODIFIER_STATE_CHANGED - nur relevante Buttons
5. PET_BAR_UPDATE - nur Pet-Buttons

**Geschätzter Gewinn:** 40-60% weniger API-Calls

### Phase 2: Caching (Nach Phase 1 testen)
6. Lazy Loading Binding-Cache (ohne Preload beim Login)
7. Action-Slot-Cache (mit korrekter Invalidation)

**Geschätzter Gewinn:** +20-30% zusätzliche Reduzierung

### Phase 3: Weitere Optimierungen (Optional)
8. ACTIONBAR_SLOT_CHANGED - selektives Update (mit Einschränkungen)
9. Change Detection (wenn nötig)

**Geschätzter Gewinn:** +10-20% zusätzliche Reduzierung

---

## 12. Zusammenfassung

### ✅ Was funktioniert definitiv:
- Event-basierte selektive Updates (außer ACTIONBAR_SLOT_CHANGED)
- keybind_patterns außerhalb Funktion
- Lazy Loading Binding-Cache
- Action-Slot-Cache

### ⚠️ Was funktioniert mit Einschränkungen:
- ACTIONBAR_SLOT_CHANGED selektives Update (nur ACTIONBUTTONs, nicht perfekt)
- Change Detection (komplex, muss gut getestet werden)
- Preload beim Login (besser: Lazy Loading)

### ❌ Was nicht empfohlen wird:
- Event-Batching (kann zu verzögerten Updates führen)
- Button-Pooling (zu komplex, wenig Nutzen)
- Modifier-String-Cache (zu wenig Nutzen)

### Realistische Gesamtverbesserung:
- **50-70% weniger API-Calls** (nicht 85-95%)
- **30-50% schnellere Refreshs** (nicht 50-70%)
- **60-80% weniger unnötige Updates**

**Fazit:** Die Optimierungen sind größtenteils realistisch, aber einige müssen angepasst oder vereinfacht werden. Die wichtigsten Optimierungen (selektive Updates, keybind_patterns, Lazy Loading Cache) sind sicher und bringen den größten Nutzen.




