-- UI.lua

local addonName, addonTable = ...
local HBD = LibStub("HereBeDragons-2.0")

function addonTable.UI.ShowColorSelectionUI()
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
            local x, y, uiMapID = HBD:GetPlayerZonePosition()
            if x and y and uiMapID then
                addonTable.Markers.PlaceMarkerOnMinimap(uiMapID, x, y, {1, 0, 0, 1})
            end
            frame:Hide()
        end)

        -- Yellow Button
        local yellowButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        yellowButton:SetSize(40, 40)
        yellowButton:SetPoint("CENTER", frame, "CENTER", 0, 0)
        yellowButton:SetText("Yellow")
        yellowButton:SetScript("OnClick", function()
            local x, y, uiMapID = HBD:GetPlayerZonePosition()
            if x and y and uiMapID then
                addonTable.Markers.PlaceMarkerOnMinimap(uiMapID, x, y, {1, 1, 0, 1})
            end
            frame:Hide()
        end)

        -- Green Button
        local greenButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        greenButton:SetSize(40, 40)
        greenButton:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        greenButton:SetText("Green")
        greenButton:SetScript("OnClick", function()
            local x, y, uiMapID = HBD:GetPlayerZonePosition()
            if x and y and uiMapID then
                addonTable.Markers.PlaceMarkerOnMinimap(uiMapID, x, y, {0, 1, 0, 1})
            end
            frame:Hide()
        end)

        addonTable.colorSelectionFrame = frame
    end
    addonTable.colorSelectionFrame:Show()
end
