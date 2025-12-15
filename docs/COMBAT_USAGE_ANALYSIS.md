# KeyUI im Kampf - Sinnvoll oder nicht?

## Übersicht

Diese Analyse untersucht, ob es sinnvoll ist, KeyUI während des Kampfes zu nutzen, und welche Funktionalität im Kampf noch verfügbar ist.

---

## 1. Was macht KeyUI?

### 1.1 Hauptfunktionen

**KeyUI ist ein UI-Addon, das:**
- Keybinds visuell anzeigt (Keyboard, Mouse, Controller)
- Icons von gebundenen Actions zeigt
- Layouts anzeigt und anpassbar macht
- Modifier-Status zeigt (ALT, CTRL, SHIFT)

**KeyUI ist KEIN Kampf-Addon:**
- ❌ Macht keine automatisierten Entscheidungen
- ❌ Gibt keine Kampf-Hinweise
- ❌ Optimiert keine Rotation
- ✅ Zeigt nur Informationen an (die auch die Basis-UI zeigt)

---

## 2. Aktuelle Implementierung

### 2.1 Combat-Handling

**Aktuell:**
- `stay_open_in_combat` = `true` (Standard)
- Addon kann im Kampf geöffnet bleiben
- Wird automatisch geschlossen, wenn `stay_open_in_combat = false`

**Code:**
```lua
-- Standard: stay_open_in_combat = true
-- Addon bleibt im Kampf offen, wenn aktiviert
```

### 2.2 Was funktioniert aktuell im Kampf?

**✅ Funktioniert:**
- Keybind-Anzeige (aus `GetBindingAction()`)
- Layout/Frame-Anzeige
- Modifier-Status
- Basis-Funktionalität

**⚠️ Eingeschränkt (nach API-Änderungen):**
- Icon-Updates (werden nicht aktualisiert)
- Stance/Page-Updates (werden nicht erkannt)
- Slot-Änderungen (werden nicht erkannt)

---

## 3. Nutzungsszenarien im Kampf

### 3.1 Szenario 1: Lernender Spieler

**Zweck:**
- Spieler lernt neue Klasse/Charakter
- Will während des Kampfes sehen, welche Keys gebunden sind
- Braucht visuelle Referenz

**Was funktioniert:**
- ✅ Keybinds werden angezeigt
- ✅ Layout ist sichtbar
- ⚠️ Icons sind veraltet (letzter Stand vor Kampf)

**Sinnvoll?**
- ✅ **JA!** Keybinds sind wichtiger als Icons
- Icons sind "nice to have", aber nicht kritisch
- Keybind-Text reicht für Lernzwecke

### 3.2 Szenario 2: Controller-Spieler

**Zweck:**
- Spieler nutzt Controller
- Will während des Kampfes sehen, welche Buttons gebunden sind
- Braucht visuelle Referenz für Controller-Layout

**Was funktioniert:**
- ✅ Controller-Layout wird angezeigt
- ✅ Keybinds werden angezeigt
- ⚠️ Icons sind veraltet

**Sinnvoll?**
- ✅ **JA!** Controller-Layout ist sehr hilfreich
- Visuelle Referenz ist wichtig
- Icons sind weniger wichtig als Layout

### 3.3 Szenario 2: Multi-Charakter-Spieler

**Zweck:**
- Spieler spielt mehrere Charaktere
- Will während des Kampfes sehen, welche Keys gebunden sind
- Braucht schnelle Referenz

**Was funktioniert:**
- ✅ Keybinds werden angezeigt
- ✅ Layout ist sichtbar
- ⚠️ Icons sind veraltet

**Sinnvoll?**
- ✅ **JA!** Keybind-Referenz ist wichtig
- Icons sind weniger wichtig
- Layout hilft bei Orientierung

### 3.4 Szenario 4: Hardcore-Raider

**Zweck:**
- Spieler braucht maximale Performance
- Will keine Ablenkung im Kampf
- Braucht nur außerhalb Kampf

**Was funktioniert:**
- ✅ Alles funktioniert außerhalb Kampf
- ⚠️ Im Kampf: Icons veraltet

**Sinnvoll?**
- ❌ **NEIN!** Hardcore-Raider wollen keine Ablenkung
- Addon sollte im Kampf geschlossen sein
- Außerhalb Kampf: Vollständige Funktionalität

---

## 4. Was funktioniert noch im Kampf? (Nach API-Änderungen)

### 4.1 Vollständig funktionsfähig

**✅ Keybind-Anzeige:**
- `GetBindingAction()` funktioniert weiterhin
- Keybind-Text wird angezeigt
- Modifier-Status wird angezeigt

**✅ Layout/Frame:**
- Frames werden angezeigt
- Layout bleibt sichtbar
- Positionierung funktioniert

**✅ Basis-Funktionalität:**
- Addon bleibt offen
- Frames sind sichtbar
- Interaktion möglich (theoretisch)

### 4.2 Eingeschränkt

**⚠️ Icons:**
- Icons werden nicht aktualisiert
- Zeigen letzten Stand vor Kampf
- Können veraltet sein

**⚠️ Stance/Page-Updates:**
- Stance-Wechsel werden nicht erkannt
- Page-Wechsel werden nicht erkannt
- Keybinds bleiben auf letztem Stand

**⚠️ Slot-Änderungen:**
- Slot-Änderungen werden nicht erkannt
- Icons werden nicht aktualisiert
- Keybinds bleiben statisch

### 4.3 Nicht verfügbar

**❌ Keybind-Änderungen:**
- Keybinds können im Kampf nicht geändert werden (schon jetzt)
- `SetBinding()` funktioniert nicht im Kampf

**❌ Layout-Änderungen:**
- Layout kann im Kampf nicht editiert werden (schon jetzt)
- Frames können nicht verschoben werden (schon jetzt)

---

## 5. Ist es sinnvoll?

### 5.1 Pro: Im Kampf nutzen

**✅ Argumente dafür:**
1. **Keybind-Referenz:** Spieler sehen, welche Keys gebunden sind
2. **Lernhilfe:** Hilft beim Lernen neuer Klassen/Charaktere
3. **Controller-Support:** Wichtig für Controller-Spieler
4. **Multi-Charakter:** Schnelle Referenz für verschiedene Charaktere
5. **Visuelle Orientierung:** Layout hilft bei Orientierung

**✅ Was funktioniert:**
- Keybind-Anzeige (Hauptfunktion)
- Layout-Anzeige
- Modifier-Status
- Basis-Funktionalität

### 5.2 Contra: Im Kampf nutzen

**❌ Argumente dagegen:**
1. **Veraltete Icons:** Icons sind nicht aktuell
2. **Ablenkung:** Kann im Kampf ablenken
3. **Performance:** Zusätzliche UI-Elemente
4. **Unvollständig:** Funktionalität ist eingeschränkt
5. **Hardcore-Raider:** Brauchen keine Ablenkung

**❌ Was nicht funktioniert:**
- Icon-Updates
- Stance/Page-Updates
- Slot-Änderungen

### 5.3 Fazit: Es kommt darauf an!

**✅ Sinnvoll für:**
- Lernende Spieler
- Controller-Spieler
- Multi-Charakter-Spieler
- Spieler, die visuelle Referenz brauchen

**❌ Nicht sinnvoll für:**
- Hardcore-Raider (Ablenkung)
- Spieler, die aktuelle Icons brauchen
- Spieler, die maximale Performance wollen

---

## 6. Sollte es möglich sein?

### 6.1 Blizzards Philosophie

**Blizzards Ziel:**
- Addons sollen keine automatisierten Entscheidungen treffen
- UI-Anpassungen sind erlaubt
- Informationen anzeigen ist erlaubt

**KeyUI:**
- ✅ Zeigt nur Informationen an
- ✅ Macht keine automatisierten Entscheidungen
- ✅ Ist reine UI-Anpassung
- ✅ Zeigt nur, was auch die Basis-UI zeigt

**Fazit:** KeyUI sollte im Kampf erlaubt sein!

### 6.2 Technische Machbarkeit

**Was funktioniert:**
- ✅ `GetBindingAction()` funktioniert weiterhin
- ✅ Layout/Frame-Management funktioniert
- ✅ Events funktionieren (teilweise)

**Was funktioniert nicht:**
- ❌ `HasAction()` im Kampf eingeschränkt
- ❌ `GetActionTexture()` im Kampf eingeschränkt
- ❌ Stance/Page-APIs im Kampf eingeschränkt

**Fazit:** Technisch möglich, aber eingeschränkt!

### 6.3 Empfehlung

**✅ JA, es sollte möglich sein!**

**Gründe:**
1. KeyUI ist kein "Kampf-Addon"
2. Zeigt nur Informationen (erlaubt)
3. Macht keine automatisierten Entscheidungen
4. Keybind-Anzeige ist wichtig für viele Spieler
5. Graceful Degradation ist möglich (Icons optional)

**Aber:**
- Mit eingeschränkter Funktionalität (Icons veraltet)
- Optional (Spieler kann es schließen)
- Graceful Degradation (Keybinds ja, Icons optional)

---

## 7. Empfohlene Strategie

### 7.1 Option 1: Im Kampf erlauben (Empfohlen)

**Implementierung:**
- `stay_open_in_combat = true` (Standard)
- Graceful Degradation: Icons optional
- Cache-basierte Anzeige (Icons aus Cache)
- Warnung: "Icons werden im Kampf nicht aktualisiert"

**Vorteile:**
- ✅ Maximale Flexibilität für Spieler
- ✅ Keybind-Referenz bleibt verfügbar
- ✅ Controller-Spieler profitieren

**Nachteile:**
- ⚠️ Veraltete Icons können verwirren
- ⚠️ Kann ablenken

### 7.2 Option 2: Im Kampf deaktivieren

**Implementierung:**
- `stay_open_in_combat = false` (Standard)
- Addon wird automatisch geschlossen
- Spieler kann es manuell aktivieren

**Vorteile:**
- ✅ Keine Ablenkung
- ✅ Keine Verwirrung durch veraltete Icons
- ✅ Klare Trennung

**Nachteile:**
- ❌ Controller-Spieler können es nicht nutzen
- ❌ Lernende Spieler können es nicht nutzen
- ❌ Weniger Flexibilität

### 7.3 Option 3: "Combat Mode" (Beste Lösung!)

**Implementierung:**
- `stay_open_in_combat = true` (Standard)
- `show_icons_in_combat = false` (neue Option)
- Im Kampf: Nur Keybinds, keine Icons
- Nach Kampf: Icons werden aktualisiert

**Vorteile:**
- ✅ Maximale Flexibilität
- ✅ Keine Verwirrung durch veraltete Icons
- ✅ Keybind-Referenz bleibt verfügbar
- ✅ Controller-Spieler profitieren

**Nachteile:**
- ⚠️ Zusätzliche Option (Komplexität)

---

## 8. Empfohlene Implementierung

### 8.1 "Combat Mode" mit Optionen

```lua
-- Neue Optionen
stay_open_in_combat = true          -- Standard: Im Kampf erlauben
show_icons_in_combat = false        -- Standard: Keine Icons im Kampf
show_keybinds_in_combat = true     -- Standard: Keybinds im Kampf zeigen

-- Combat-Safe Icon-Anzeige
function addon:process_actionbutton_slot(slot, button)
    if not slot then return end
    
    -- Slot-Berechnung (funktioniert immer)
    local adjusted_slot = addon:get_action_button_slot_cached(...)
    button.slot = adjusted_slot
    
    -- Icon-Anzeige (abhängig von Option)
    if InCombatLockdown() and not keyui_settings.show_icons_in_combat then
        -- Im Kampf: Keine Icons (wenn deaktiviert)
        button.icon:Hide()
        -- Keybind-Text bleibt sichtbar
    else
        -- Außerhalb Kampf oder Icons erlaubt: Normal
        local has_action, texture = addon:get_slot_info(adjusted_slot)
        if has_action and texture then
            button.icon:SetTexture(texture)
            button.icon:Show()
        else
            button.icon:Hide()
        end
    end
end
```

### 8.2 Graceful Degradation

```lua
-- Im Kampf: Weniger Features, aber funktional
function addon:refresh_keys_combat_safe()
    if InCombatLockdown() then
        -- Combat Mode: Nur Keybinds, keine Icons
        for i = 1, #addon.keys_keyboard do
            local button = addon.keys_keyboard[i]
            
            -- Keybind immer anzeigen
            local binding = addon:get_binding(button.raw_key)  -- Aus Cache
            button.binding = binding
            
            -- Icon nur wenn erlaubt
            if keyui_settings.show_icons_in_combat then
                -- Versuche Icon aus Cache
                local has_action, texture = addon:get_slot_info(button.slot)
                if has_action and texture then
                    button.icon:SetTexture(texture)
                    button.icon:Show()
                else
                    button.icon:Hide()
                end
            else
                button.icon:Hide()
            end
            
            -- Keybind-Text aktualisieren
            addon:update_button_key_text(button)
        end
    else
        -- Normal Mode: Alles aktualisieren
        addon:refresh_keys()
    end
end
```

---

## 9. Zusammenfassung

### 9.1 Ist es sinnvoll?

**✅ JA, für bestimmte Spieler:**
- Lernende Spieler
- Controller-Spieler
- Multi-Charakter-Spieler
- Spieler, die visuelle Referenz brauchen

**❌ NEIN, für andere Spieler:**
- Hardcore-Raider
- Spieler, die aktuelle Icons brauchen
- Spieler, die keine Ablenkung wollen

### 9.2 Sollte es möglich sein?

**✅ JA!**

**Gründe:**
1. KeyUI ist kein "Kampf-Addon"
2. Zeigt nur Informationen (erlaubt)
3. Macht keine automatisierten Entscheidungen
4. Keybind-Anzeige ist wichtig
5. Graceful Degradation ist möglich

### 9.3 Empfohlene Strategie

**"Combat Mode" mit Optionen:**
- ✅ `stay_open_in_combat = true` (Standard)
- ✅ `show_icons_in_combat = false` (neue Option)
- ✅ Im Kampf: Nur Keybinds, keine Icons
- ✅ Nach Kampf: Alles aktualisieren
- ✅ Spieler kann es anpassen

**Vorteile:**
- Maximale Flexibilität
- Keine Verwirrung durch veraltete Icons
- Keybind-Referenz bleibt verfügbar
- Controller-Spieler profitieren

---

## 10. Nächste Schritte

1. **Option hinzufügen:**
   - `show_icons_in_combat` (Standard: false)
   - Im Kampf: Icons optional

2. **Combat-Safe Implementierung:**
   - Graceful Degradation
   - Cache-basierte Anzeige
   - Optionen respektieren

3. **Dokumentation:**
   - Spieler informieren
   - Optionen erklären
   - Verhalten dokumentieren

**Fazit:** KeyUI sollte im Kampf nutzbar sein, aber mit eingeschränkter Funktionalität (Icons optional). Die Hauptfunktion (Keybind-Anzeige) bleibt erhalten und ist für viele Spieler wichtig!




