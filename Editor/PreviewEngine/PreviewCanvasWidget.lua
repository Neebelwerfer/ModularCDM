local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local Type = "PreviewCanvas"
local Version = 1
local previewNode = ns.Editor.Preview.PreviewNode
local previewDataProvider = ns.Editor.Preview.PreviewDataProvider

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:EnableMouse(true)

    local widget = {
        type = Type,
        frame = frame,
    }
    
    frame:SetWidth(300)
    frame:SetHeight(300)

    local canvas = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    canvas:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
    canvas:SetBackdropColor(0, 0, 0, 0.8)
    canvas:SetAllPoints()
    widget.canvas = canvas

    local scaleSlider = CreateFrame("Slider", nil, canvas, "OptionsSliderTemplate")
    scaleSlider:SetPoint("BOTTOMLEFT", 10, 10)
    scaleSlider:SetMinMaxValues(0.5, 3)
    scaleSlider:SetValue(1)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetObeyStepOnDrag(true)
    scaleSlider:SetScript("OnValueChanged", function(self, value)
            widget:SetNodeScale(value)
            widget.scaleNumber.scaleText:SetText(string.format("%.1f", value))
    end)
    widget.scaleSlider = scaleSlider

    local scaleNumber = CreateFrame("Frame", nil, scaleSlider)
    local scaleText = scaleNumber:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scaleText:SetText("1")
    scaleNumber.scaleText = scaleText
    local scaleSliderWidth = scaleSlider:GetWidth()
    scaleNumber:SetSize(scaleSliderWidth, 20)
    scaleNumber:SetPoint("CENTER", scaleSlider, "CENTER", scaleSliderWidth / 2 + 12, 0)
    scaleNumber.scaleText:SetAllPoints(scaleNumber)
    widget.scaleNumber = scaleNumber


    -- Update loop for the previewEngine

    canvas:SetScript("OnUpdate", function(self, deltaTime)
        previewDataProvider.Update(deltaTime)

        if widget.node then
            widget.node:Update(deltaTime)
        end
    end)

    function widget:SetWidth(width)
        self.frame:SetWidth(width)
    end

    function widget:SetHeight(height)
        self.frame:SetHeight(height)
    end

    function widget:ClearNode()
        widget.node:Destroy()
        widget.node = nil
    end

    function widget:SetNode(node)
        if widget.node then
            widget:ClearNode()
        end
        widget.node = previewNode:new(node, self.canvas)
        previewDataProvider.Restart()
    end

    function widget:SetNodeScale(scale)
        if widget.node then
            widget.node.rootFrame:SetScale(scale)
        end
    end

    -- widget:SetNodes(nodeDefinitions)
    -- widget:SelectNode(nodeId)
    -- widget:SetEditMode(enabled)
    -- widget:SetPreviewContext(context)
    -- widget:Clear()

    -- widget:Fire("OnComponentSelected", component)
    -- widget:Fire("OnNodeMoved", node)
    

    -- Required by AceGUI
    widget.OnAcquire = function(self)
        self.frame:Show()
        self.canvas:Show()
    end

    widget.OnRelease = function(self)
        self.frame:Hide()
        self.canvas:Hide()
        self:ClearNode()
        self.scaleNumber.scaleText:SetText("1")
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)