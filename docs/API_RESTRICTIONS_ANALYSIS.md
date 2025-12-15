# API-Einschränkungen im Kampf - Analyse für KeyUI

## Übersicht

Blizzard plant in der kommenden "Midnight" Expansion (2025) signifikante Einschränkungen für API-Calls im Kampf. Diese Analyse untersucht die Auswirkungen auf KeyUI und die geplanten Performance-Optimierungen.

---

## 1. Was plant Blizzard?

### 1.1 Geplante Änderungen

**Ziel:**
- Addons sollen keine automatisierten Kampfentscheidungen treffen können
- "Level playing field" - faire Bedingungen für alle Spieler
- Addons sollen nicht mehr tun können als die Basis-UI

**Betroffene Bereiche:**
- Kampfinformationen (DPS, Cooldowns, Boss-Warnungen)
- Automatisierte Entscheidungen im Kampf
- Echtzeit-Kampfdaten

**Was bleibt erlaubt:**
- UI-Anpassungen (solange keine automatisierten Entscheidungen)
- Anzeige von Informationen (die auch die Basis-UI zeigt)
- Layout-Anpassungen

**Zeitplan:**
- Midnight Expansion (voraussichtlich 2025)
- Möglicherweise früher in größeren Patches

---

## 2. Welche API-Calls nutzt KeyUI?

### 2.1 Aktuell genutzte API-Calls

**Binding-APIs:**
- `GetBindingAction(key, checkOverride)` - **WICHTIG!**
- `SetBinding(key, binding)` - Nur außerhalb Kampf
- `SaveBindings()` - Nur außerhalb Kampf

**Action Bar APIs:**
- `HasAction(slot)` - **WICHTIG!**
- `GetActionTexture(slot)` - **WICHTIG!**
- `GetActionBarPage()` - **WICHTIG!**
- `GetBonusBarOffset()` - **WICHTIG!**

**Pet APIs:**
- `PetHasActionBar()` - **WICHTIG!**
- `GetPetActionInfo(index)` - **WICHTIG!**

**Shapeshift APIs:**
- `GetShapeshiftFormInfo(index)` - **WICHTIG!**

**Spell/Macro APIs:**
- `GetMacroInfo(macroID)`
- `C_Spell.GetSpellTexture(spellID)`
- `IsSpellKnown(spellID)`
- `C_SpellBook.GetSpellBookItemInfo(spellIndex)`

**Unit APIs:**
- `UnitClassBase("player")` - Nur beim Login

**Events:**
- `ACTIONBAR_SLOT_CHANGED`
- `UPDATE_BONUS_ACTIONBAR`
- `ACTIONBAR_PAGE_CHANGED`
- `PET_BAR_UPDATE`
- `MODIFIER_STATE_CHANGED`
- `UPDATE_BINDINGS`

---

## 3. Welche API-Calls könnten betroffen sein?

### 3.1 Wahrscheinlich betroffen (im Kampf eingeschränkt)

**⚠️ KRITISCH - Wahrscheinlich eingeschränkt:**
- `HasAction(slot)` - Zeigt an, welche Actions verfügbar sind
- `GetActionTexture(slot)` - Zeigt Action-Icons
- `GetActionBarPage()` - Zeigt aktuelle Action Bar Page
- `GetBonusBarOffset()` - Zeigt Stance/Form-Informationen
- `GetPetActionInfo(index)` - Zeigt Pet-Actions
- `GetShapeshiftFormInfo(index)` - Zeigt Shapeshift-Forms

**Warum:**
- Diese APIs liefern Kampfinformationen
- Könnten für automatische Entscheidungen genutzt werden
- Blizzard will "level playing field"

### 3.2 Wahrscheinlich NICHT betroffen

**✅ Wahrscheinlich erlaubt:**
- `GetBindingAction(key)` - Zeigt nur Keybinds (UI-Information)
- `MODIFIER_STATE_CHANGED` Event - UI-Event
- `UPDATE_BINDINGS` Event - UI-Event
- Layout/Frame-Management - Reine UI-Anpassung

**Warum:**
- Keybinds sind UI-Information, keine Kampfinformation
- Layout-Anpassungen sind erlaubt
- Keine automatisierten Entscheidungen

### 3.3 Unklar

**❓ Möglicherweise betroffen:**
- `ACTIONBAR_SLOT_CHANGED` Event - Könnte eingeschränkt werden
- `UPDATE_BONUS_ACTIONBAR` Event - Könnte eingeschränkt werden
- `ACTIONBAR_PAGE_CHANGED` Event - Könnte eingeschränkt werden

**Warum:**
- Diese Events liefern Kampf-relevante Informationen
- Könnten für automatische Entscheidungen genutzt werden

---

## 4. Auswirkungen auf KeyUI (Ist-Zustand)

### 4.1 Aktuelle Funktionalität

**Was KeyUI macht:**
- Zeigt Keybinds visuell an (Keyboard, Mouse, Controller)
- Zeigt Icons von Actions, die auf Keys gebunden sind
- Aktualisiert sich bei Stance/Page-Wechseln
- Zeigt Modifier-Status

**Ist es ein "Kampf-Addon"?**
- ❌ **NEIN!** KeyUI macht keine automatisierten Entscheidungen
- ✅ Es ist ein **UI-Addon**, das Informationen anzeigt
- ✅ Es zeigt nur, was auch die Basis-UI zeigt (Keybinds, Icons)

### 4.2 Potenzielle Probleme

**Problem 1: Action-Icons im Kampf**
- Wenn `HasAction()` und `GetActionTexture()` im Kampf eingeschränkt werden:
  - Icons werden nicht mehr aktualisiert
  - Buttons zeigen alte/leere Icons
  - **Funktionalität:** Keybinds werden weiterhin angezeigt, aber ohne Icons

**Problem 2: Stance/Page-Updates im Kampf**
- Wenn `GetBonusBarOffset()` und `GetActionBarPage()` im Kampf eingeschränkt werden:
  - Stance-Wechsel werden nicht erkannt
  - Page-Wechsel werden nicht erkannt
  - **Funktionalität:** Keybinds bleiben auf letztem bekannten Stand

**Problem 3: Events im Kampf**
- Wenn `ACTIONBAR_SLOT_CHANGED` im Kampf eingeschränkt wird:
  - Slot-Änderungen werden nicht erkannt
  - Icons werden nicht aktualisiert
  - **Funktionalität:** Keybinds bleiben statisch

### 4.3 Was funktioniert weiterhin

**✅ Weiterhin funktionierend:**
- Keybind-Anzeige (aus `GetBindingAction()`)
- Layout/Frame-Management
- Modifier-Status-Anzeige
- Basis-Funktionalität (Keybinds werden angezeigt)

**⚠️ Eingeschränkt:**
- Icon-Updates im Kampf
- Stance/Page-Updates im Kampf
- Slot-Änderungen im Kampf

---

## 5. Auswirkungen auf Performance-Optimierungen

### 5.1 Vollständiges Caching-System

**Aktueller Plan:**
- Alle 180 Slots beim Login cachen
- Alle Keybinds beim Login cachen
- Während des Spielens: 0 API-Calls (aus Cache)

**Problem mit API-Einschränkungen:**
- ✅ **Caching funktioniert weiterhin!**
- Cache wird beim Login erstellt (außerhalb Kampf)
- Während des Kampfes: Cache wird genutzt (keine API-Calls nötig)
- **Vorteil:** Caching wird noch wichtiger!

**Aber:**
- Cache kann im Kampf nicht aktualisiert werden
- Icons bleiben auf letztem Stand (vor Kampf)
- **Lösung:** Cache vor Kampf aktualisieren, im Kampf nur lesen

### 5.2 Event-basierte Updates

**Aktueller Plan:**
- `ACTIONBAR_SLOT_CHANGED`: Nur betroffene Buttons aktualisieren
- `UPDATE_BONUS_ACTIONBAR`: Nur ACTIONBUTTONs aktualisieren

**Problem mit API-Einschränkungen:**
- ⚠️ Events könnten im Kampf nicht mehr feuern
- ⚠️ Oder API-Calls in Event-Handlern könnten fehlschlagen

**Lösung:**
- Event-Handler mit `InCombatLockdown()` prüfen
- Fallback: Cache-Werte nutzen
- Nach Kampf: Cache aktualisieren

### 5.3 Lazy Loading

**Aktueller Plan:**
- Keys werden bei Bedarf geladen und gecacht

**Problem mit API-Einschränkungen:**
- ⚠️ Im Kampf können neue Keys nicht geladen werden
- ⚠️ Cache kann nicht erweitert werden

**Lösung:**
- Preload beim Login (außerhalb Kampf)
- Im Kampf: Nur aus Cache lesen
- Nach Kampf: Cache erweitern (falls nötig)

---

## 6. Anpassungen für API-Einschränkungen

### 6.1 Combat-Safe Implementierung

```lua
-- Combat-Safe API-Call Wrapper
function addon:safe_api_call(func, fallback_value, ...)
    if InCombatLockdown() then
        -- Im Kampf: Fallback-Wert nutzen
        return fallback_value
    end
    
    -- Außerhalb Kampf: API-Call durchführen
    local success, result = pcall(func, ...)
    if success then
        return result
    else
        return fallback_value
    end
end

-- Combat-Safe Slot-Info
function addon:get_slot_info(slot)
    if slot < 1 or slot > 180 then return false, nil end
    
    -- Immer zuerst Cache prüfen
    local cached = slot_cache[slot]
    if cached and cached.version == slot_cache_version then
        return cached.has_action, cached.texture
    end
    
    -- Cache fehlt: Versuche zu laden (nur außerhalb Kampf)
    if InCombatLockdown() then
        -- Im Kampf: Fallback (leeres Icon)
        return false, nil
    end
    
    -- Außerhalb Kampf: Laden und cachen
    local has_action = addon:safe_api_call(HasAction, false, slot)
    local texture = nil
    if has_action then
        texture = addon:safe_api_call(GetActionTexture, nil, slot)
    end
    
    slot_cache[slot] = {
        has_action = has_action,
        texture = texture,
        version = slot_cache_version
    }
    
    return has_action, texture
end
```

### 6.2 Event-Handler mit Combat-Checks

```lua
elseif event == "ACTIONBAR_SLOT_CHANGED" then
    local changed_slot = ...
    
    -- Im Kampf: Nur aus Cache lesen, nicht aktualisieren
    if InCombatLockdown() then
        -- Finde betroffene Buttons und aktualisiere aus Cache
        local has_action, texture = addon:get_slot_info(changed_slot)
        -- ... Button-Updates aus Cache
        return
    end
    
    -- Außerhalb Kampf: Cache aktualisieren
    local has_action = HasAction(changed_slot)
    local texture = has_action and GetActionTexture(changed_slot) or nil
    slot_cache[changed_slot] = {
        has_action = has_action,
        texture = texture,
        version = slot_cache_version
    }
    -- ... Button-Updates

elseif event == "UPDATE_BONUS_ACTIONBAR" then
    -- Im Kampf: Nur aus Cache lesen
    if InCombatLockdown() then
        -- Nutze letzten bekannten bonusbar_offset
        -- Aktualisiere Buttons aus Cache
        return
    end
    
    -- Außerhalb Kampf: Normal aktualisieren
    addon.bonusbar_offset = GetBonusBarOffset()
    -- ... normale Logik
```

### 6.3 Preload-Strategie anpassen

```lua
-- Preload beim Login (außerhalb Kampf)
elseif event == "PLAYER_LOGIN" then
    -- ... Initialisierung
    
    -- Preload sofort (außerhalb Kampf)
    C_Timer.After(2.0, function()
        if not InCombatLockdown() then
            addon:preload_everything()
        else
            -- Falls im Kampf: Später versuchen
            C_Timer.After(5.0, function()
                if not InCombatLockdown() then
                    addon:preload_everything()
                end
            end)
        end
    end)

-- Preload vor Kampf (wenn möglich)
elseif event == "PLAYER_REGEN_ENABLED" then
    addon.in_combat = false
    
    -- Cache aktualisieren (außerhalb Kampf)
    if addon.open then
        -- Aktualisiere alle Slots im Cache
        addon:refresh_slot_cache()
    end
```

### 6.4 Graceful Degradation

```lua
-- Graceful Degradation: Im Kampf weniger Features
function addon:process_actionbutton_slot(slot, button)
    if not slot then return end
    
    -- Slot-Berechnung (funktioniert immer)
    local adjusted_slot = addon:get_action_button_slot_cached(
        slot,
        addon.current_actionbar_page,
        addon.bonusbar_offset
    )
    button.slot = adjusted_slot
    
    -- Icon-Info (kann im Kampf eingeschränkt sein)
    local has_action, texture = addon:get_slot_info(adjusted_slot)
    
    if has_action and texture then
        button.active_slot = adjusted_slot
        button.icon:SetTexture(texture)
        button.icon:Show()
    elseif InCombatLockdown() then
        -- Im Kampf: Zeige Keybind, aber kein Icon
        button.icon:Hide()
        -- Keybind-Text bleibt sichtbar
    else
        button.icon:Hide()
    end
end
```

---

## 7. Empfehlungen

### 7.1 Sofortige Maßnahmen

1. **Combat-Checks implementieren**
   - Alle API-Calls mit `InCombatLockdown()` prüfen
   - Fallback-Werte für Kampf-Situationen

2. **Caching priorisieren**
   - Vollständiges Caching wird noch wichtiger!
   - Cache vor Kampf aktualisieren
   - Im Kampf: Nur aus Cache lesen

3. **Graceful Degradation**
   - Im Kampf: Keybinds anzeigen, Icons optional
   - Nach Kampf: Alles aktualisieren

### 7.2 Langfristige Strategie

1. **Monitoring**
   - Blizzard-Ankündigungen verfolgen
   - Beta-Tests beobachten
   - API-Changes dokumentieren

2. **Anpassungen**
   - Addon für "Midnight" vorbereiten
   - Combat-Safe Implementierung
   - Fallback-Mechanismen

3. **Kommunikation**
   - Nutzer informieren (Icons im Kampf möglicherweise nicht aktuell)
   - Option: "Combat Mode" (nur Keybinds, keine Icons)

---

## 8. Zusammenfassung

### 8.1 Betroffene APIs

**Wahrscheinlich eingeschränkt:**
- `HasAction(slot)` ⚠️
- `GetActionTexture(slot)` ⚠️
- `GetActionBarPage()` ⚠️
- `GetBonusBarOffset()` ⚠️
- `GetPetActionInfo(index)` ⚠️
- `GetShapeshiftFormInfo(index)` ⚠️

**Wahrscheinlich erlaubt:**
- `GetBindingAction(key)` ✅
- Layout/Frame-Management ✅
- Events (teilweise) ✅

### 8.2 Auswirkungen auf KeyUI

**Funktioniert weiterhin:**
- ✅ Keybind-Anzeige (Hauptfunktion)
- ✅ Layout/Frame-Management
- ✅ Modifier-Status

**Eingeschränkt:**
- ⚠️ Icon-Updates im Kampf
- ⚠️ Stance/Page-Updates im Kampf
- ⚠️ Slot-Änderungen im Kampf

### 8.3 Auswirkungen auf Optimierungen

**Caching wird wichtiger:**
- ✅ Cache funktioniert weiterhin
- ✅ Im Kampf: Nur aus Cache lesen
- ✅ Vor Kampf: Cache aktualisieren

**Anpassungen nötig:**
- ⚠️ Combat-Checks in Event-Handlern
- ⚠️ Fallback-Mechanismen
- ⚠️ Graceful Degradation

### 8.4 Fazit

**KeyUI ist relativ sicher:**
- Es ist kein "Kampf-Addon" (keine automatisierten Entscheidungen)
- Hauptfunktion (Keybind-Anzeige) bleibt erhalten
- Icons sind "nice to have", nicht kritisch

**Aber Anpassungen nötig:**
- Combat-Safe Implementierung
- Caching-Strategie anpassen
- Graceful Degradation

**Caching wird noch wichtiger:**
- Eliminiert API-Calls im Kampf (die sowieso nicht funktionieren würden)
- Cache vor Kampf aktualisieren
- Im Kampf: Nur aus Cache lesen

---

## 9. Nächste Schritte

1. **Sofort:**
   - Combat-Checks in kritischen Funktionen
   - Fallback-Mechanismen implementieren

2. **Vor Midnight:**
   - Vollständiges Caching-System implementieren
   - Combat-Safe Event-Handler
   - Graceful Degradation

3. **Während Beta:**
   - API-Changes testen
   - Anpassungen vornehmen
   - Nutzer informieren

**Fazit:** KeyUI wird weiterhin funktionieren, aber mit eingeschränkten Features im Kampf. Caching wird noch wichtiger und sollte priorisiert werden!




