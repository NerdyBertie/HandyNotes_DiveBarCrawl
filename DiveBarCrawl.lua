-- HandyNotes: Dive Bar Front Crawl
-- Adds world map pins for every Tortollan dive bar needed to complete the
-- "Dive Bar Front Crawl" housing endeavor (Visit all of Azeroth's underwater
-- Tortollan Bars).
--
-- Note: "The Watering Hole" objective is completed via the portal in the
-- Beach Party housing plot ("Stay a While and Glisten") inside your own
-- neighborhood, so it isn't a world coordinate and has no pin here.
--
-- Locations sourced from the official Blizzard forum thread "Dive Bar Front
-- Crawl Endeavor Locations" and cross-checked against Warcraft Wiki zone
-- pages. uiMapIDs verified against the HandyNotes: Battle for Azeroth
-- Treasures zone files (Tiragarde Sound, Drustvar, Stormsong Valley,
-- Zuldazar, Nazmir, Vol'dun, Nazjatar all confirmed) and the
-- handynotes-plugins Dragonflight zone files (Waking Shores, Azure Span).

local addonName = ...
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")

local floor = math.floor
-- Tortollan Seekers faction crest -- a clean emblem rather than a detailed
-- creature render, so it stays readable at map-pin size, and it's the
-- Tortollans' own faction symbol.
local ICON = "Interface\\Icons\\INV_TortollanSeekers"
local ICON_SCALE = 1.4

-- Pack an x,y coordinate pair, given as 0-100 percentages (the convention
-- used by TomTom, Wowhead, and the forum data these were sourced from),
-- into HandyNotes' single integer coord format. HandyNotes itself works in
-- 0.0-1.0 fractions internally, so we convert before packing -- skipping
-- this step silently corrupts the y value once it overflows the 4-digit
-- slot the packing scheme reserves for it.
local function C(x, y)
    x, y = x / 100, y / 100
    return floor(x * 10000 + 0.5) * 10000 + floor(y * 10000 + 0.5)
end

-- db[uiMapID][coord] = { title, subtext }
local db = {
    [895] = { -- Tiragarde Sound
        [C(53.92, 44.26)] = { "Whale's Belly", "Sunken dive bar in the shallows of Tiragarde Sound." },
    },
    [896] = { -- Drustvar
        [C(19.41, 42.87)] = { "The Drunk Tank", "Tortollan dive bar tucked away in Drustvar." },
    },
    [942] = { -- Stormsong Valley
        [C(40.38, 30.37)] = { "Anchors Down", "Shipwreck bar in the waters of the Jeweled Coast, directly north of Seekers' Vista." },
    },
    [862] = { -- Zuldazar
        [C(54.24, 54.54)] = { "The Dive Bar", "Where the river beside Dazar'alor meets the South Sea." },
        [C(81.66, 44.18)] = { "Gral's Grotto", "Tortollan dive bar along the Zuldazar coastline." },
        [C(78.66, 10.68)] = { "Sand Bar", "Tortollan dive bar along the Zuldazar coastline." },
    },
    [863] = { -- Nazmir
        [C(74.11, 7.55)] = { "Torga's Tavern", "Tortollan dive bar in the swamps of Nazmir." },
    },
    [864] = { -- Vol'dun
        [C(40.57, 1.80)] = { "Heyman's Hideaway", "Tortollan dive bar in Vol'dun." },
    },
    [1355] = { -- Nazjatar
        [C(57.32, 39.84)] = { "Maedin's Challenge", "Entrance to the underwater dive bar in Nazjatar." },
    },
    [2022] = { -- The Waking Shores
        [C(19.53, 37.33)] = { "Hissing Grotto (The Bubble Bath)", "Underwater dive bar beneath the Hissing Grotto in the north-western Waking Shores." },
    },
    [2024] = { -- The Azure Span
        [C(29.18, 57.16)] = { "Drifter's Dive", "Tortollan dive bar in the Azure Span." },
    },
}

local addon = {}
local emptyTbl = {}

function addon:GetNodes2(uiMapID, minimap)
    local nodes = db[uiMapID]
    if not nodes then
        -- HandyNotes always does `for ... in plugin:GetNodes2(...) do`, so
        -- this must never return a bare nil -- that leaves the iterator
        -- slot nil and HandyNotes crashes trying to call it. Returning
        -- plain `next` over an empty table just ends the loop immediately,
        -- same as HandyNotes' own internal empty-case fallback.
        return next, emptyTbl, nil
    end

    -- Iterator yields coord, uiMapID, icon, scale, alpha for each node in
    -- this zone, per the HandyNotes GetNodes2 contract.
    local function iter(t, prevCoord)
        local coord = next(t, prevCoord)
        if coord then
            return coord, uiMapID, ICON, ICON_SCALE, 1.0
        end
    end

    return iter, nodes, nil
end

-- self here is the pin/button HandyNotes is asking about, not the addon --
-- that's how HandyNotes invokes these two callbacks.
function addon:OnEnter(uiMapID, coord)
    local nodes = db[uiMapID]
    local data = nodes and nodes[coord]
    if not data then return end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(data[1], 1, 1, 1)
    GameTooltip:AddLine(data[2], nil, nil, nil, true)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Dive Bar Front Crawl (housing endeavor)", 0.6, 0.8, 1)
    GameTooltip:Show()
end

function addon:OnLeave()
    GameTooltip:Hide()
end

local pluginOptions = {
    type = "group",
    name = "Dive Bar Front Crawl",
    args = {
        desc = {
            type = "description",
            order = 1,
            name = "Map pins for every Tortollan dive bar needed for the \"Dive Bar Front Crawl\" housing endeavor.",
        },
    },
}

HandyNotes:RegisterPluginDB(addonName, addon, pluginOptions)
