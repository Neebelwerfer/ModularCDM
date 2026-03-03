local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local Type = "PreviewCanvas"
local Version = 1
local previewNode = ns.Editor.Preview.PreviewNode
local previewDataProvider = ns.Editor.Preview.PreviewDataProvider


local function BuildCanvas(widget, frame)
    local canvas = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    canvas:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 1
    })
    canvas:SetBackdropColor(0, 0, 0, 0.8)
    -- canvas:SetSize(height, width * 0.7)
    canvas:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    canvas:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    widget.canvas = canvas

    local viewport = CreateFrame("Frame", nil, canvas)
    viewport:SetClipsChildren(true)
    widget.viewport = viewport

    local scaleSlider = CreateFrame("Slider", nil, viewport, "OptionsSliderTemplate")
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

    local offsetYLabel = viewport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    offsetYLabel:SetText("Offset Y")
    offsetYLabel:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", -5, 25)

    local offsetYEditBox = CreateFrame("EditBox", nil, viewport, "InputBoxTemplate")
    offsetYEditBox:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", -5, 5)
    offsetYEditBox:SetSize(50, 20)
    offsetYEditBox:SetAutoFocus(false)
    offsetYEditBox:SetText("0")
    offsetYEditBox:SetNumericFullRange(true)
    offsetYEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        widget:SetComponentTransform(widget.frameDescriptor.transform.offsetX, self:GetNumber())
    end)
    
    local offsetXLabel = viewport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    offsetXLabel:SetText("Offset X")
    offsetXLabel:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", -65, 25)
    
    local offsetXEditBox = CreateFrame("EditBox", nil, viewport, "InputBoxTemplate")
    offsetXEditBox:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", -65, 5)
    offsetXEditBox:SetSize(50, 20)
    offsetXEditBox:SetAutoFocus(false)
    offsetXEditBox:SetText("0")
    offsetXEditBox:SetNumericFullRange(true)
    offsetXEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        widget:SetComponentTransform(self:GetNumber(), widget.frameDescriptor.transform.offsetY)
    end)

    widget.offsetYEditBox = offsetYEditBox
    widget.offsetXEditBox = offsetXEditBox
    
    -- Update loop for the previewEngine
    canvas:SetScript("OnUpdate", function(self, deltaTime)
        previewDataProvider.Update(deltaTime)

        if widget.node then
            widget.node:Update(deltaTime)
        end
    end)


    local overlayFrame = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
    overlayFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    overlayFrame:SetBackdropColor(0, 0, 0, 0.3)
    overlayFrame:SetBackdropBorderColor(0, 1, 0, 0.8)
    overlayFrame:Hide()
    overlayFrame:SetParent(viewport)
    overlayFrame:EnableMouse(true)
    overlayFrame:SetMovable(true)
    overlayFrame:RegisterForDrag("LeftButton")
    overlayFrame:SetFrameStrata("TOOLTIP")
    overlayFrame:SetFrameLevel(100)
    overlayFrame.isMoving = false

    overlayFrame:SetScript("OnMouseDown", function(overlay)
        overlay.isMoving = true
        local cursorX, cursorY = GetCursorPosition()

        overlay.cursorX = cursorX
        overlay.cursorY = cursorY
    end)

    overlayFrame:SetScript("OnMouseUp", function(overlay)
        overlay.isMoving = false
    end)
    overlayFrame:SetScript("OnDragStop", function(overlay)
        overlay.isMoving = false
    end)

    overlayFrame:SetScript("OnUpdate", function(overlay, deltaTime)
        if not overlay.isMoving then return end

        local cursorX, cursorY = GetCursorPosition()
        local deltaX = cursorX - overlay.cursorX
        local deltyY = cursorY - overlay.cursorY

        overlay.cursorX = cursorX
        overlay.cursorY = cursorY

        local offsetX = widget.frameDescriptor.transform.offsetX + deltaX
        local offsetY = widget.frameDescriptor.transform.offsetY + deltyY
        widget:SetComponentTransform(offsetX, offsetY)
    end)
    widget.overlayFrame = overlayFrame
end

local function BuildComponentList(widget, frame)
    local inspector = AceGUI:Create("InlineGroup")
    inspector:SetTitle("Inspector")
    inspector.frame:SetParent(frame)
    inspector.frame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, 0)
    inspector.frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 0)
    inspector:SetLayout("List")

    inspector.SetupNode = function(self, node)
        self:ReleaseChildren()
        inspector.selectedButton = nil

        local first = true
        for _, frameDescriptor in pairs(node.frames) do
            local button = AceGUI:Create("InspectorButton")
            button:SetText(frameDescriptor.name)
            button:SetFullWidth(true)

            button:SetCallback("OnClick", function(button)
                button:Disable()
                if inspector.selectedButton then
                    inspector.selectedButton:Enable()
                end
                widget:SelectComponent(frameDescriptor)
                inspector.selectedButton = button
            end)

            if first then
                widget:SelectComponent(frameDescriptor)
                inspector.selectedButton = button
                button:Disable()
                first = false
            end

            self:AddChild(button)
        end

        local addComponent = AceGUI:Create("InspectorButton")
        addComponent:SetText("Add Component")
        addComponent:SetFullWidth(true)
        addComponent:SetCallback("OnClick", function(button)
            widget:Fire("OnAddComponent")
        end)
        addComponent:SetBaseColor(0.1, 0.6, 0.1, 0.5)
        addComponent:SetHoverColor(0.05, 0.6, 0.05, 1)
        self:AddChild(addComponent)
    end

    widget.componentList = inspector
end


local function Constructor()
    local frame = CreateFrame("Frame", nil)
    frame:EnableMouse(true)

    local widget = {
        type = Type,
        frame = frame,
        frameDescriptor = nil
    }
    BuildCanvas(widget, frame)
    BuildComponentList(widget, frame)

    function widget:OnWidthSet(width)
        self.canvas:SetWidth(width)

        local inspectorWidth = math.max(200, width * 0.3)
        self.componentList:SetWidth(inspectorWidth)

        local viewportWidth = width - inspectorWidth - 10
        self.viewport:ClearAllPoints()
        self.viewport:SetPoint("TOPLEFT", self.canvas, "TOPLEFT", 0, 0)
        self.viewport:SetPoint("BOTTOMLEFT", self.canvas, "BOTTOMLEFT", 0, 0)
        self.viewport:SetWidth(viewportWidth)
    end

    function widget:OnHeightSet(height)
        self.frame:SetHeight(height)
        self.canvas:SetHeight(height)
        self.viewport:SetHeight(height)

        self.componentList:SetHeight(height)
    end

    function widget:ClearNode()
        if not widget.node then return end
        widget.node:Destroy()
        widget.node = nil
    end

    function widget:SetNode(runtimeNode)
        if widget.node then
            widget:ClearNode()
        end

        widget.node = previewNode:new(runtimeNode, self.viewport)
        widget.overlayFrame:SetSize(widget.node.rootFrame:GetSize())
        widget:SetNodeScale(1)

        widget.componentList:SetupNode(runtimeNode.node)
        previewDataProvider.Restart()
    end

    function widget:SetNodeScale(scale)
        if widget.node then
            widget.node.rootFrame:SetScale(scale)
            widget.overlayFrame:SetScale(scale)
        end
    end

    function widget:SetComponentTransform(x, y)
        x = math.floor(x * 100 + 0.5) / 100
        y = math.floor(y * 100 + 0.5) / 100
        self.overlayFrame:ClearAllPoints()
        self.overlayFrame:SetPoint("CENTER", self.node.rootFrame, "CENTER", x, y)

        self.offsetXEditBox:SetText(x)
        self.offsetYEditBox:SetText(y)

        self.frameDescriptor.transform.offsetX = x
        self.frameDescriptor.transform.offsetY = y
        self.node:MarkLayoutAsDirty()
    end

    function widget:SelectComponent(frameDescriptor)
        self.overlayFrame:ClearAllPoints()
        self.overlayFrame:SetPoint("CENTER", self.node.rootFrame, "CENTER", frameDescriptor.transform.offsetX, frameDescriptor.transform.offsetY)
        self.overlayFrame:Show()

        self.offsetXEditBox:SetText(frameDescriptor.transform.offsetX)
        self.offsetYEditBox:SetText(frameDescriptor.transform.offsetY)
        self.frameDescriptor = frameDescriptor

        widget:Fire("OnComponentSelected", frameDescriptor)
    end    

    -- Required by AceGUI
    widget.OnAcquire = function(self)
        self.frame:Show()
    end

    widget.OnRelease = function(self)
        self.frame:Hide()
        self:ClearNode()
        self.scaleNumber.scaleText:SetText("1")
        self.scaleSlider:SetValue(1)
        self.componentList:ReleaseChildren()
        self.overlayFrame:Hide()
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)