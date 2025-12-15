# Code Review - Gefundene Probleme und Verbesserungen

## Übersicht

Diese Analyse identifiziert potenzielle Fehler, Verbesserungen und Best-Practice-Verletzungen im KeyUI-Addon.

---

## 1. Kritische Probleme

### 1.1 Fehlende Nil-Checks in Font-Funktionen

**Problem:**
```lua
-- UIHelpers.lua:116-123
function addon:GetCustomFont()
    return keyui_settings.custom_font or DEFAULT_FONT
end

function addon:GetCustomFontCondensed()
    return keyui_settings.custom_font_condensed or "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF"
end
```

**Problem:** Wenn `keyui_settings` noch nicht initialisiert ist, gibt es einen Fehler.

**Lösung:**
```lua
function addon:GetCustomFont()
    if not keyui_settings then
        return DEFAULT_FONT
    end
    return keyui_settings.custom_font or DEFAULT_FONT
end

function addon:GetCustomFontCondensed()
    if not keyui_settings then
        return "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF"
    end
    return keyui_settings.custom_font_condensed or "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF"
end
```

**Priorität:** ⚠️ Hoch (kann zu Fehlern beim Laden führen)

---

### 1.2 Fehlende Nil-Checks bei Button-Zugriffen

**Problem:**
```lua
-- Core.lua:1419
if addon.current_hovered_button.active_slot then
    -- ...
end
```

**Problem:** Wenn `addon.current_hovered_button` nil ist, gibt es einen Fehler.

**Lösung:**
```lua
if addon.current_hovered_button and addon.current_hovered_button.active_slot then
    -- ...
end
```

**Priorität:** ⚠️ Mittel (kann bei schnellen Mausbewegungen auftreten)

---

### 1.3 Fehlende Fehlerbehandlung bei API-Calls

**Problem:**
```lua
-- Core.lua:1639
if HasAction(adjusted_slot) then
    button.icon:SetTexture(GetActionTexture(adjusted_slot))
    button.icon:Show()
end
```

**Problem:** `GetActionTexture()` kann nil zurückgeben oder fehlschlagen.

**Lösung:**
```lua
if HasAction(adjusted_slot) then
    local texture = GetActionTexture(adjusted_slot)
    if texture then
        button.icon:SetTexture(texture)
        button.icon:Show()
    end
end
```

**Priorität:** ⚠️ Mittel (selten, aber möglich)

---

### 1.4 Fehlende Combat-Checks für API-Calls

**Problem:**
```lua
-- Core.lua:2479
addon.bonusbar_offset = GetBonusBarOffset()
addon:refresh_keys()
```

**Problem:** Im Kampf könnten diese API-Calls eingeschränkt sein (Midnight Expansion).

**Lösung:**
```lua
if not InCombatLockdown() then
    addon.bonusbar_offset = GetBonusBarOffset()
    addon:refresh_keys()
else
    -- Im Kampf: Nur aus Cache lesen
    addon:refresh_keys_combat_safe()
end
```

**Priorität:** ⚠️ Hoch (für Midnight Expansion wichtig)

---

## 2. Potenzielle Fehler

### 2.1 Fehlende Validierung bei Font-Pfaden

**Problem:**
```lua
-- Core.lua: custom_font Option
set = function(_, value)
    if value and value ~= "" then
        keyui_settings.custom_font = value
        -- Keine Validierung, ob Font existiert!
    end
end
```

**Problem:** Ungültige Font-Pfade werden akzeptiert, führen aber zu Fehlern.

**Lösung:**
```lua
set = function(_, value)
    if value and value ~= "" then
        -- Versuche Font zu laden (validiert automatisch)
        local testFont = CreateFont("KeyUI_FontTest")
        testFont:SetFont(value, 12)
        local success = pcall(function() testFont:GetFont() end)
        
        if success then
            keyui_settings.custom_font = value
            if addon.open then
                addon:refresh_keys()
            end
            print("KeyUI: Custom font set to: " .. value)
        else
            print("KeyUI: Invalid font path: " .. value)
        end
    end
end
```

**Priorität:** ⚠️ Niedrig (UX-Verbesserung)

---

### 2.2 Fehlende Nil-Checks bei Spellbook-Laden

**Problem:**
```lua
-- Core.lua:1075-1095
for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
    local name = skillLineInfo.name
    -- ...
    for j = offset + 1, offset + numSlots do
        local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
        -- Keine Nil-Check für spellBookItemInfo!
    end
end
```

**Problem:** `GetSpellBookItemInfo()` kann nil zurückgeben.

**Lösung:**
```lua
for j = offset + 1, offset + numSlots do
    local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
    if spellBookItemInfo then
        local spellName = spellBookItemInfo.name
        local spellID = spellBookItemInfo.spellID
        local isPassive = spellBookItemInfo.isPassive

        if spellName and not isPassive then
            table.insert(addon.spells[name], { name = spellName, id = spellID })
        end
    end
end
```

**Priorität:** ⚠️ Mittel (kann bei bestimmten Klassen/Stances auftreten)

---

### 2.3 Fehlende Initialisierung von cmd_checkbox

**Problem:**
```lua
-- Variables.lua:80
addon.cmd_checkbox = false  -- Wird initialisiert
```

**Aber:** In `Core.lua:690` wird `self.cmd_checkbox = false` gesetzt, aber nur wenn `reset_button_state` aufgerufen wird.

**Problem:** Wenn `cmd_checkbox` nicht initialisiert ist, kann es zu nil-Fehlern kommen.

**Lösung:** ✅ Bereits in Variables.lua initialisiert - OK

**Priorität:** ✅ Kein Problem

---

## 3. Performance-Probleme

### 3.1 Fehlende Caching bei wiederholten API-Calls

**Problem:**
```lua
-- Core.lua:1639
if HasAction(adjusted_slot) then
    button.icon:SetTexture(GetActionTexture(adjusted_slot))
end
```

**Problem:** Wird bei jedem `refresh_keys()` für jeden Button aufgerufen.

**Lösung:** Siehe `PERFORMANCE_OPTIMIZATIONS_COMPREHENSIVE_CACHING.md`

**Priorität:** ⚠️ Hoch (Performance-Optimierung)

---

### 3.2 Redundante String-Operationen

**Problem:**
```lua
-- Core.lua:2018
addon.current_modifier_string = table.concat(modifiers)
```

**Problem:** Wird bei jedem Modifier-Change neu erstellt.

**Lösung:** Caching (siehe Performance-Dokumentation)

**Priorität:** ⚠️ Niedrig (kleiner Performance-Gewinn)

---

## 4. Code-Qualität

### 4.1 Inkonsistente Nil-Checks

**Problem:**
- Manche Stellen haben Nil-Checks, andere nicht
- Inkonsistente Verwendung von `or` vs explizite Nil-Checks

**Beispiel:**
```lua
-- Inkonsistent:
if keyui_settings.show_keyboard == true then  -- Explizit
if not keyui_settings.stay_open_in_combat then  -- Implizit
```

**Lösung:** Konsistente Verwendung von Nil-Checks

**Priorität:** ⚠️ Niedrig (Code-Qualität)

---

### 4.2 Fehlende Kommentare bei komplexen Funktionen

**Problem:**
- `serialize_table` und `deserialize_value` sind komplex, aber wenig dokumentiert
- `get_action_button_slot` hat komplexe Logik, aber keine Kommentare

**Lösung:** Kommentare hinzufügen

**Priorität:** ⚠️ Niedrig (Wartbarkeit)

---

### 4.3 Magic Numbers

**Problem:**
```lua
-- Core.lua:1604-1610
if addon.bonusbar_offset == 1 then
    return action_slot + 72
elseif addon.bonusbar_offset == 2 then
    return action_slot + 84
-- ...
```

**Problem:** Magic Numbers (72, 84, 96, etc.) sollten Konstanten sein.

**Lösung:**
```lua
local BONUS_BAR_OFFSETS = {
    [1] = 72,
    [2] = 84,
    [3] = 96,
    [4] = 108,
    [5] = 120,
}
```

**Priorität:** ⚠️ Niedrig (Code-Qualität)

---

## 5. Sicherheitsprobleme

### 5.1 Fehlende Validierung bei Layout-Import

**Problem:**
```lua
-- Core.lua: DeserializeLayoutPayload
-- Validiert Version, aber nicht die Datenstruktur vollständig
```

**Problem:** Malformed Layout-Daten könnten zu Fehlern führen.

**Lösung:** Strengere Validierung

**Priorität:** ⚠️ Mittel (Sicherheit)

---

### 5.2 Fehlende Validierung bei Font-Pfaden

**Problem:** Siehe 2.1

**Priorität:** ⚠️ Niedrig (UX)

---

## 6. Verbesserungsvorschläge

### 6.1 Helper-Funktion für Safe API-Calls

**Vorschlag:**
```lua
function addon:safe_api_call(func, fallback_value, ...)
    if InCombatLockdown() then
        return fallback_value
    end
    
    local success, result = pcall(func, ...)
    if success then
        return result
    else
        return fallback_value
    end
end
```

**Priorität:** ⚠️ Hoch (für Midnight Expansion)

---

### 6.2 Validierungs-Helper

**Vorschlag:**
```lua
function addon:validate_font_path(path)
    if not path or path == "" then
        return false
    end
    
    local testFont = CreateFont("KeyUI_FontTest")
    testFont:SetFont(path, 12)
    local success = pcall(function() testFont:GetFont() end)
    return success
end
```

**Priorität:** ⚠️ Mittel (UX)

---

### 6.3 Konstanten für Magic Numbers

**Vorschlag:**
```lua
-- Core.lua (oben)
local ACTION_SLOT_OFFSETS = {
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
```

**Priorität:** ⚠️ Niedrig (Code-Qualität)

---

## 7. Zusammenfassung

### Kritische Probleme (Sofort beheben):
1. ✅ Nil-Checks in Font-Funktionen
2. ✅ Combat-Checks für API-Calls (Midnight)
3. ✅ Nil-Checks bei Button-Zugriffen

### Wichtige Verbesserungen:
4. ⚠️ Fehlerbehandlung bei API-Calls
5. ⚠️ Validierung bei Font-Pfaden
6. ⚠️ Nil-Checks bei Spellbook-Laden

### Code-Qualität:
7. ⚠️ Konsistente Nil-Checks
8. ⚠️ Kommentare bei komplexen Funktionen
9. ⚠️ Magic Numbers als Konstanten

### Performance:
10. ⚠️ Caching (siehe Performance-Dokumentation)

---

## 8. Empfohlene Reihenfolge

1. **Sofort:**
   - Nil-Checks in Font-Funktionen
   - Nil-Checks bei Button-Zugriffen
   - Combat-Checks für API-Calls

2. **Bald:**
   - Fehlerbehandlung bei API-Calls
   - Validierung bei Font-Pfaden
   - Nil-Checks bei Spellbook-Laden

3. **Später:**
   - Code-Qualität-Verbesserungen
   - Performance-Optimierungen




