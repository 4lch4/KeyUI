-- Constants for KeyUI Addon
-- This file contains all magic numbers and constants used throughout the addon

local Constants = {}

-- ============================================
-- Action Slot Constants
-- ============================================

-- Action Slot Ranges
Constants.ACTION_SLOT_MIN = 1
Constants.ACTION_SLOT_MAX = 180

-- Action Slot Offsets for Bonus Bars
Constants.ACTION_SLOT_OFFSETS = {
    BONUS_BAR_1 = 72,
    BONUS_BAR_2 = 84,
    BONUS_BAR_3 = 96,
    BONUS_BAR_4 = 108,
    BONUS_BAR_5 = 120,
}

-- Action Slot Offsets for Action Bar Pages
Constants.ACTION_SLOT_OFFSETS_PAGE = {
    PAGE_1 = 0,   -- Default (1-12)
    PAGE_2 = 12,
    PAGE_3 = 24,
    PAGE_4 = 36,
    PAGE_5 = 48,
    PAGE_6 = 60,
}

-- ============================================
-- Font Constants
-- ============================================

Constants.FONT_SIZE = {
    SMALL = 12,
    DEFAULT = 16,
    LARGE = 22,
    TITLE = 28,
}

Constants.FONT_PATH = {
    REGULAR = "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF",
    CONDENSED = "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF",
}

-- ============================================
-- Frame Size Constants
-- ============================================

Constants.BUTTON_SIZE = {
    WIDTH_DEFAULT = 160,
    HEIGHT_DEFAULT = 30,
}

Constants.ICON_SIZE = {
    DEFAULT = 50,
}

Constants.TEXTURE_HEIGHT = {
    DEFAULT = 46,
}

-- ============================================
-- Color Constants
-- ============================================

Constants.COLOR = {
    DISABLED_TEXT = 0.192,
    DISABLED_TEXTURE = 0.4,
    ENABLED = 1.0,
    WHITE = { 1.0, 1.0, 1.0 },
}

-- ============================================
-- Modifier Constants
-- ============================================

Constants.MODIFIER_KEYS = {
    ALT = "ALT",
    CTRL = "CTRL",
    SHIFT = "SHIFT",
    CMD = "CMD",
}

-- ============================================
-- Layout Key Size Constants
-- ============================================

-- Base unit size for keyboard layouts
Constants.KEY_SIZE_BASE = 60

-- Multipliers for different key sizes
Constants.KEY_SIZE_MULTIPLIERS = {
    SIZE_125_PERCENT = 1.25,
    SIZE_150_PERCENT = 1.5,
    SIZE_175_PERCENT = 1.75,
    SIZE_200_PERCENT = 2.0,
    SIZE_225_PERCENT = 2.25,
    SIZE_275_PERCENT = 2.75,
    SIZE_625_PERCENT = 6.25,
}

-- ============================================
-- Serialization Constants
-- ============================================

Constants.SERIALIZATION = {
    PROFILE_EXPORT_VERSION = 1,
    LAYOUT_EXPORT_VERSION = 1,
}

-- ============================================
-- Export Constants
-- ============================================

return Constants




