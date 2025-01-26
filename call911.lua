local addonName, addonTable = ...

-- Default SavedVariables
call911SV = call911SV or {}

-- Save frame position
local function saveFramePosition(frame)
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    call911SV.framePosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
end

-- Restore frame position
local function restoreFramePosition(frame)
    local pos = call911SV.framePosition
    if pos then
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        frame:SetPoint("CENTER", 0, 0) -- Default position
    end
end

-- Function to whisper a message to your current target if it's a valid player
local function whisperTarget(message)
    if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        local targetName = UnitName("target")
        SendChatMessage(message, "WHISPER", nil, targetName)
    else
        print("No valid target to whisper.")
    end
end

-- Send the "stay safe" message
local function sendStaySafeMessage()
    if IsInGroup() then
        -- Send to group chat
        SendChatMessage("Stay safe", "PARTY")
    else
        -- Say it in /s
        SendChatMessage("Stay safe", "SAY")
    end
end

-- Create the 911 and Stay Safe buttons
local function create911Button()
    if _G["911Frame"] then
        return -- Prevent duplicate creation
    end

    local frame = CreateFrame("Frame", "911Frame", UIParent)
    frame:SetSize(120, 60) -- Adjust the frame size to fit two buttons
    restoreFramePosition(frame) -- Restore position on creation
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        saveFramePosition(self) -- Save position after dragging
    end)

    -- Create the 911 button
    local button911 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button911:SetSize(80, 30)
    button911:SetPoint("TOP", frame, "TOP", 0, 0)
    button911:SetText("911")
    button911:SetScript("OnClick", function()
        -- Whisper to the target player
        local whisperMessage = "HELP! I am next to you"
        whisperTarget(whisperMessage)

        -- Send the message to the group chat
        local groupMessage = "Guys save me"
        if IsInGroup() then
            SendChatMessage(groupMessage, "PARTY")
        else
            print("Not in a group to send help message.")
        end

        -- Yell "HELP!"
        SendChatMessage("HELP!", "YELL")
    end)

    -- Create the Stay Safe button
    local buttonStaySafe = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    buttonStaySafe:SetSize(80, 30)
    buttonStaySafe:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
    buttonStaySafe:SetText("Stay Safe")
    buttonStaySafe:SetScript("OnClick", sendStaySafeMessage)
end

-- Listen for the PLAYER_LOGIN event to initialize the button properly
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", create911Button)
