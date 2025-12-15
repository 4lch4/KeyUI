-- Validators for KeyUI Addon
-- This file contains validation functions for various data types

local Validators = {}

-- Import Constants for validation ranges
local Constants = require("Utils.Constants")

-- ============================================
-- Button Validation
-- ============================================

--[[
    Validates that a button parameter is valid.
    @param button The button to validate
    @return boolean True if valid, false otherwise
]]
function Validators.validate_button(button)
    if not button then
        return false
    end
    if type(button) ~= "table" then
        return false
    end
    return true
end

--[[
    Validates that a button parameter is valid and throws error if not.
    @param button The button to validate
    @throws Error if button is invalid
]]
function Validators.validate_button_strict(button)
    if not button then
        error("Button parameter is required")
    end
    if type(button) ~= "table" then
        error("Button must be a table")
    end
    return true
end

-- ============================================
-- Slot Validation
-- ============================================

--[[
    Validates that an action slot is within valid range.
    @param slot The slot number to validate
    @return boolean True if valid, false otherwise
]]
function Validators.validate_slot(slot)
    if not slot then
        return false
    end
    if type(slot) ~= "number" then
        return false
    end
    if slot < Constants.ACTION_SLOT_MIN or slot > Constants.ACTION_SLOT_MAX then
        return false
    end
    return true
end

--[[
    Validates that an action slot is within valid range and throws error if not.
    @param slot The slot number to validate
    @throws Error if slot is invalid
]]
function Validators.validate_slot_strict(slot)
    if not slot then
        error("Slot parameter is required")
    end
    if type(slot) ~= "number" then
        error("Slot must be a number")
    end
    if slot < Constants.ACTION_SLOT_MIN or slot > Constants.ACTION_SLOT_MAX then
        error(string.format("Slot must be between %d and %d", Constants.ACTION_SLOT_MIN, Constants.ACTION_SLOT_MAX))
    end
    return true
end

-- ============================================
-- Font Path Validation
-- ============================================

--[[
    Validates that a font path is valid by attempting to load it.
    @param font_path The font path to validate
    @return boolean True if valid, false otherwise
]]
function Validators.validate_font_path(font_path)
    if not font_path or type(font_path) ~= "string" or font_path == "" then
        return false
    end
    
    -- Try to create a test font to validate the path
    local testFont = CreateFont("KeyUI_FontTest")
    if not testFont then
        return false
    end
    
    testFont:SetFont(font_path, 12)
    local success = pcall(function()
        local font, size, flags = testFont:GetFont()
        return font ~= nil
    end)
    
    return success
end

-- ============================================
-- String Validation
-- ============================================

--[[
    Validates that a string is not empty.
    @param str The string to validate
    @return boolean True if valid, false otherwise
]]
function Validators.validate_string(str)
    if not str then
        return false
    end
    if type(str) ~= "string" then
        return false
    end
    if str:match("^%s*$") then
        return false
    end
    return true
end

-- ============================================
-- Number Validation
-- ============================================

--[[
    Validates that a number is within a range.
    @param num The number to validate
    @param min Minimum value (optional)
    @param max Maximum value (optional)
    @return boolean True if valid, false otherwise
]]
function Validators.validate_number(num, min, max)
    if not num then
        return false
    end
    if type(num) ~= "number" then
        return false
    end
    if min and num < min then
        return false
    end
    if max and num > max then
        return false
    end
    return true
end

-- ============================================
-- Table Validation
-- ============================================

--[[
    Validates that a value is a table.
    @param tbl The value to validate
    @return boolean True if valid, false otherwise
]]
function Validators.validate_table(tbl)
    if not tbl then
        return false
    end
    if type(tbl) ~= "table" then
        return false
    end
    return true
end

-- ============================================
-- Layout Name Validation
-- ============================================

--[[
    Validates that a layout name is valid.
    @param name The layout name to validate
    @return boolean True if valid, false otherwise
]]
function Validators.validate_layout_name(name)
    if not Validators.validate_string(name) then
        return false
    end
    -- Check for invalid characters
    if name:match("[^%w%s%-_]") then
        return false
    end
    -- Check length (reasonable limit)
    if #name > 50 then
        return false
    end
    return true
end

-- ============================================
-- Export
-- ============================================

return Validators




