-- Core.lua
local addonName, addonTable = ...
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

local HBD = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

local SURVEY_SPELL_ID = 80451  -- Spell ID for Survey
local minimapMarkers = {}
local worldMapMarkers = {}
local pendingMarker = {}

-- SavedVariables
HambrosiasSurveyHelperDB = HambrosiasSurveyHelperDB or {}

-- Initialization
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        LoadMarkers()
        CreateOptionsMenu()
        print("Hambrosia's Survey Helper Loaded")
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        if unit == "player" and spellID == SURVEY_SPELL_ID then
            ShowColorSelectionUI()
        end
    end
end)

SLASH_CLEARMARKERS1 = '/clearmarkers'
SlashCmdList['CLEARMARKERS'] = function()
    ClearMarkers()
end

function ShowColorSelectionUI()
    local uiMapID = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
    if position then
        local x, y = position:GetXY()
        pendingMarker = {uiMapID = uiMapID, x = x, y = y}

        if not addonTable.colorSelectionFrame then
            local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            frame:SetSize(150, 50)
            frame:SetPoint("CENTER", UIParent, "CENTER")
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, tileSize = 32, edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })

            -- Red Button
            local redButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            redButton:SetSize(40, 40)
            redButton:SetPoint("LEFT", frame, "LEFT", 10, 0)
            redButton:SetText("Red")
            redButton:SetScript("OnClick", function()
                PlaceMarker(pendingMarker.uiMapID, pendingMarker.x, pendingMarker.y, {1, 0, 0, 1})
                frame:Hide()
            end)

            -- Yellow Button
            local yellowButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            yellowButton:SetSize(40, 40)
            yellowButton:SetPoint("CENTER", frame, "CENTER", 0, 0)
            yellowButton:SetText("Yellow")
            yellowButton:SetScript("OnClick", function()
                PlaceMarker(pendingMarker.uiMapID, pendingMarker.x, pendingMarker.y, {1, 1, 0, 1})
                frame:Hide()
            end)

            -- Green Button
            local greenButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            greenButton:SetSize(40, 40)
            greenButton:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
            greenButton:SetText("Green")
            greenButton:SetScript("OnClick", function()
                PlaceMarker(pendingMarker.uiMapID, pendingMarker.x, pendingMarker.y, {0, 1, 0, 1})
                frame:Hide()
            end)

            addonTable.colorSelectionFrame = frame
        end
        addonTable.colorSelectionFrame:Show()
    end
end

function PlaceMarker(uiMapID, x, y, color)
    local id = EncodeLoc(x, y)
    HambrosiasSurveyHelperDB[uiMapID] = HambrosiasSurveyHelperDB[uiMapID] or {}
    HambrosiasSurveyHelperDB[uiMapID][id] = color

    PlaceMarkerOnMinimap(uiMapID, x, y, color, id)
    PlaceMarkerOnWorldMap(uiMapID, x, y, color, id)

    print("Placed marker on minimap and world map at:", x, y, "with color", color)
end

function PlaceMarkerOnMinimap(uiMapID, x, y, color, id)
    local icon = CreateFrame("Frame", nil, Minimap)
    icon:SetSize(12, 12)

    local texture = icon:CreateTexture(nil, "OVERLAY")
    texture:SetColorTexture(unpack(color))
    texture:SetAllPoints(icon)
    icon.texture = texture

    minimapMarkers[id] = icon
    HBDPins:AddMinimapIconMap(addonName, icon, uiMapID, x, y, true, true)
end

function PlaceMarkerOnWorldMap(uiMapID, x, y, color, id)
    local icon = CreateFrame("Frame", nil, WorldMapFrame)
    icon:SetSize(12, 12)

    local texture = icon:CreateTexture(nil, "OVERLAY")
    texture:SetColorTexture(unpack(color))
    texture:SetAllPoints(icon)
    icon.texture = texture

    worldMapMarkers[id] = icon
    HBDPins:AddWorldMapIconMap(addonName, icon, uiMapID, x, y, true)
end

function EncodeLoc(x, y)
    return floor(x * 10000 + 0.5) * 1000000 + floor(y * 10000 + 0.5) * 100
end

function DecodeLoc(id)
    local x = floor(id / 1000000) / 10000
    local y = (id % 1000000) / 10000
    return x, y
end

function LoadMarkers()
    for uiMapID, markers in pairs(HambrosiasSurveyHelperDB) do
        for id, color in pairs(markers) do
            local x, y = DecodeLoc(id)
            PlaceMarkerOnMinimap(uiMapID, x, y, color, id)
            PlaceMarkerOnWorldMap(uiMapID, x, y, color, id)
        end
    end
    print("Loaded markers from saved data")
end

function ClearMarkers()
    local uiMapID = C_Map.GetBestMapForUnit("player")
    if HambrosiasSurveyHelperDB[uiMapID] then
        for id, icon in pairs(minimapMarkers) do
            HBDPins:RemoveMinimapIcon(addonName, icon)
            minimapMarkers[id] = nil
        end
        for id, icon in pairs(worldMapMarkers) do
            HBDPins:RemoveWorldMapIcon(addonName, icon)
            worldMapMarkers[id] = nil
        end
        HambrosiasSurveyHelperDB[uiMapID] = nil
        print("All markers cleared from the current minimap and world map.")
    else
        print("No markers to clear.")
    end
end

function CreateOptionsMenu()
    local panel = CreateFrame("Frame", "HambrosiasSurveyHelperPanel", UIParent)
    panel.name = "Hambrosia's Survey Helper"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Hambrosia's Survey Helper")

    local clearButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearButton:SetSize(120, 25)
    clearButton:SetText("Clear Markers")
    clearButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    clearButton:SetScript("OnClick", function()
        ClearMarkers()
    end)

    InterfaceOptions_AddCategory(panel)
end
