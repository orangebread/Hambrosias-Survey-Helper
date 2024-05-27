-- Markers.lua

local addonName, addonTable = ...
local HBD = LibStub("HereBeDragons-2.0")
local HBDP = LibStub("HereBeDragons-Pins-2.0")

-- Initialize the markers table if it doesn't exist
addonTable.minimapMarkers = addonTable.minimapMarkers or {}

-- Function to encode coordinates to a unique identifier
function addonTable.Markers.EncodeLoc(x, y)
    return string.format("%d:%d", x * 10000, y * 10000)
end

-- Function to place a marker on the minimap
function addonTable.Markers.PlaceMarkerOnMinimap(uiMapID, x, y, color)
    local id = addonTable.Markers.EncodeLoc(x, y)
    if not addonTable.minimapMarkers[id] then
        local pin = HBDP:CreateMinimapPin()
        pin:SetSize(16, 16)
        local texture = pin:CreateTexture(nil, "BACKGROUND")
        texture:SetColorTexture(unpack(color))
        texture:SetAllPoints(pin)
        pin.texture = texture

        HBDP:AddMinimapPin(pin, uiMapID, x, y)
        addonTable.minimapMarkers[id] = pin
    end
end

function addonTable.Markers.Initialize()
    -- Placeholder for any initialization needed
    print("Markers module initialized.")
end
