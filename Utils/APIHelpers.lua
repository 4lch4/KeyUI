-- API Helpers for KeyUI Addon
-- This file contains safe wrappers for WoW API calls with combat checks and error handling

local APIHelpers = {}

-- Import dependencies
local Validators = require("Utils.Validators")
local Constants = require("Utils.Constants")

-- ============================================
-- Combat State Helpers
-- ============================================

--[[
    Checks if the player is in combat lockdown.
    @return boolean True if in combat, false otherwise
]]
function APIHelpers.is_in_combat()
    return InCombatLockdown() == true
end

-- ============================================
-- Safe API Call Wrapper
-- ============================================

--[[
    Safely calls a WoW API function with combat checks and error handling.
    @param func The API function to call
    @param fallback_value The value to return if call fails or in combat
    @param ... Arguments to pass to the function
    @return The result of the API call or fallback_value
]]
function APIHelpers.safe_api_call(func, fallback_value, ...)
    if not func or type(func) ~= "function" then
        return fallback_value
    end
    
    -- In combat: return fallback (for restricted APIs)
    if APIHelpers.is_in_combat() then
        return fallback_value
    end
    
    -- Try to call the function with error handling
    local success, result = pcall(func, ...)
    if success then
        return result
    else
        -- Function call failed, return fallback
        return fallback_value
    end
end

-- ============================================
-- Action Slot API Helpers
-- ============================================

--[[
    Safely gets action texture for a slot.
    @param slot The action slot number
    @return string|nil The texture path or nil
]]
function APIHelpers.safe_get_action_texture(slot)
    -- Validate slot
    if not Validators.validate_slot(slot) then
        return nil
    end
    
    -- In combat: return nil (API restricted)
    if APIHelpers.is_in_combat() then
        -- TODO: Return from cache when cache is implemented
        return nil
    end
    
    -- Check if slot has action first
    local has_action = HasAction(slot)
    if not has_action then
        return nil
    end
    
    -- Get texture with error handling
    local success, texture = pcall(GetActionTexture, slot)
    if success and texture then
        return texture
    end
    
    return nil
end

--[[
    Safely checks if a slot has an action.
    @param slot The action slot number
    @return boolean True if slot has action, false otherwise
]]
function APIHelpers.safe_has_action(slot)
    -- Validate slot
    if not Validators.validate_slot(slot) then
        return false
    end
    
    -- In combat: return false (API restricted)
    if APIHelpers.is_in_combat() then
        -- TODO: Return from cache when cache is implemented
        return false
    end
    
    -- Check with error handling
    local success, has_action = pcall(HasAction, slot)
    if success then
        return has_action == true
    end
    
    return false
end

-- ============================================
-- Binding API Helpers
-- ============================================

--[[
    Safely gets binding action for a key.
    @param key_string The key string (e.g., "ALT-1")
    @return string The binding action or empty string
]]
function APIHelpers.safe_get_binding_action(key_string)
    if not key_string or type(key_string) ~= "string" then
        return ""
    end
    
    -- GetBindingAction is usually allowed in combat
    -- But we add error handling anyway
    local success, binding = pcall(GetBindingAction, key_string, true)
    if success and binding then
        return binding
    end
    
    return ""
end

-- ============================================
-- Action Bar API Helpers
-- ============================================

--[[
    Safely gets the current action bar page.
    @return number The current action bar page (1-6)
]]
function APIHelpers.safe_get_action_bar_page()
    -- In combat: return cached value if available
    if APIHelpers.is_in_combat() then
        -- TODO: Return from cache when cache is implemented
        -- For now, return last known value
        return 1 -- Fallback
    end
    
    local success, page = pcall(GetActionBarPage)
    if success and page then
        return page
    end
    
    return 1 -- Default fallback
end

--[[
    Safely gets the bonus bar offset.
    @return number The bonus bar offset (0-5)
]]
function APIHelpers.safe_get_bonus_bar_offset()
    -- In combat: return cached value if available
    if APIHelpers.is_in_combat() then
        -- TODO: Return from cache when cache is implemented
        -- For now, return last known value
        return 0 -- Fallback
    end
    
    local success, offset = pcall(GetBonusBarOffset)
    if success and offset then
        return offset
    end
    
    return 0 -- Default fallback
end

-- ============================================
-- Pet API Helpers
-- ============================================

--[[
    Safely checks if pet has action bar.
    @return boolean True if pet has action bar, false otherwise
]]
function APIHelpers.safe_pet_has_action_bar()
    -- In combat: return cached value if available
    if APIHelpers.is_in_combat() then
        -- TODO: Return from cache when cache is implemented
        return false -- Fallback
    end
    
    local success, has_bar = pcall(PetHasActionBar)
    if success then
        return has_bar == true
    end
    
    return false
end

--[[
    Safely gets pet action info.
    @param index The pet action index (1-10)
    @return table|nil Pet action info or nil
]]
function APIHelpers.safe_get_pet_action_info(index)
    if not index or type(index) ~= "number" or index < 1 or index > 10 then
        return nil
    end
    
    -- In combat: return nil (API restricted)
    if APIHelpers.is_in_combat() then
        return nil
    end
    
    local success, pet_name, pet_texture, is_token, is_active, auto_cast_allowed, auto_cast_enabled, spell_id = 
        pcall(GetPetActionInfo, index)
    
    if success and pet_name then
        return {
            name = pet_name,
            texture = pet_texture,
            is_token = is_token,
            is_active = is_active,
            auto_cast_allowed = auto_cast_allowed,
            auto_cast_enabled = auto_cast_enabled,
            spell_id = spell_id,
        }
    end
    
    return nil
end

-- ============================================
-- Shapeshift API Helpers
-- ============================================

--[[
    Safely gets shapeshift form info.
    @param index The shapeshift form index (1-10)
    @return table|nil Shapeshift form info or nil
]]
function APIHelpers.safe_get_shapeshift_form_info(index)
    if not index or type(index) ~= "number" or index < 1 or index > 10 then
        return nil
    end
    
    -- In combat: return nil (API restricted)
    if APIHelpers.is_in_combat() then
        return nil
    end
    
    local success, icon, is_active, is_castable, spell_id = pcall(GetShapeshiftFormInfo, index)
    
    if success and icon then
        return {
            icon = icon,
            is_active = is_active,
            is_castable = is_castable,
            spell_id = spell_id,
        }
    end
    
    return nil
end

-- ============================================
-- Export
-- ============================================

return APIHelpers




