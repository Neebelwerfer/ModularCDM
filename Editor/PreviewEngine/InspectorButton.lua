local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local Type = "InspectorButton"
local Version = 1

local function Constructor()

    local button = CreateFrame("Button", nil, nil, "BackdropTemplate")
    button:SetSize(20, 20)
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.label:SetPoint("CENTER", button, "CENTER", 0, 0)

    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    local widget = {
        type = Type,
        frame = button,
    }

    function widget:SetBaseColor(r, g, b, a)
        widget.baseColor = { r, g, b, a }
        widget:SetBackdropColor(unpack(widget.baseColor))
    end

    function widget:SetHoverColor(r, g, b, a)
        widget.hoverColor = { r, g, b, a }
    end

    function widget:SetSelectedColor(r, g, b, a)
        widget.selectedColor = { r, g, b, a }
    end

    function widget:SetDisabledColor(r, g, b, a)
        widget.disabledColor = { r, g, b, a }
    end
    
    button:HookScript("OnMouseDown", function(self, button)
        widget:Fire("OnMouseDown", button)
    end)

    button:HookScript("OnEnter", function(self)
        widget:SetBackdropColor(unpack(widget.hoverColor))
    end)
    
    button:HookScript("OnLeave", function(self)
        widget:SetBackdropColor(unpack(widget.baseColor))
    end)
    
    function widget:Select()
        button:SetBackdropColor(unpack(widget.selectedColor))
    end

    function widget:SetBackdropColor(r, g, b, a)
        self.frame:SetBackdropColor(r, g, b, a)
    end
    

    button:HookScript("OnClick", function(self)
        widget:Fire("OnClick")
    end)
    
    function widget:SetText(text)
        button.label:SetText(text)
    end

    function widget:Disable()
        button:Disable()
        button:SetBackdropColor(unpack(widget.disabledColor))
    end

    function widget:Enable()
        button:Enable()
        button:SetBackdropColor(unpack(widget.baseColor))
    end

    function widget:OnAcquire()
        
        widget.baseColor = { 0.1, 0.1, 0.1, 0.9 }
        widget.hoverColor = { 0.05, 0.05, 0.05, 1 }
        widget.selectedColor = { 1, 1, 1, 0.1 }
        widget.disabledColor = { 0.5, 0.5, 0.5, 0.5 }
        button:SetBackdropColor(unpack(widget.baseColor))
        button:Enable()
        button:Show()
    end

    function widget:OnRelease()
        button:ClearAllPoints()
        button:Hide()
    end
    

    return AceGUI:RegisterAsWidget(widget)
end
AceGUI:RegisterWidgetType(Type, Constructor, Version)