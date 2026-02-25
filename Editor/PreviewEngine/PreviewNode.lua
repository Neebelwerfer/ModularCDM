local _, ns = ...
local Core = ns.Core
local PreviewDataProvider = ns.Editor.Preview.PreviewDataProvider

local PreviewNode = {}
PreviewNode.__index = PreviewNode
ns.Editor.Preview.PreviewNode = PreviewNode

---comment
---@param node Node
---@param parentFrame Frame
---@return table
function PreviewNode:new(node, parentFrame)
    local previewNode = setmetatable({}, PreviewNode)
    previewNode.node = node

    previewNode.rootFrame = FrameBuilder.BuildRootFrame(node, parentFrame)
    previewNode.rootFrame:SetPoint("CENTER", parentFrame, "CENTER", 0, 0)

    for _, frameContext in pairs(previewNode.rootFrame.frames) do
        local descriptor = frameContext.descriptor
        frameContext.frame:SetSize(node.layout.size.width, node.layout.size.height)
        frameContext.frame:SetPoint("CENTER", previewNode.rootFrame, descriptor.transform.relativePoint, descriptor.transform.offsetX, descriptor.transform.offsetY)
    end

    return previewNode
end

function PreviewNode:Update()
    for _, frameContext in pairs(self.rootFrame.frames) do
        self:UpdateFrame(frameContext)
    end
end

function PreviewNode:UpdateTransforms()
    local parentFrame = self.parentRuntimeNode and self.parentRuntimeNode.rootFrame or UIParent

    self.rootFrame:ClearAllPoints()
    self.rootFrame:SetSize(self.node.layout.size.width, self.node.layout.size.height)
    self.rootFrame:SetPoint(self.node.transform.point, parentFrame, self.node.transform.relativePoint, self.node.transform.offsetX, self.node.transform.offsetY)
    self.rootFrame:SetScale(self.node.transform.scale)

    for _, frameContext in pairs(self.rootFrame.frames) do
        frameContext:UpdateTransform(self.node.layout)
    end
end

function PreviewNode:Destroy()
    self.rootFrame:Destroy()
end


function PreviewNode:Rebuild()
    local parentFrame = self.rootFrame:GetParent()
    assert(parentFrame, "Parent frame not found")

    self.rootFrame:Destroy()
    self.rootFrame = FrameBuilder.BuildRootFrame(self.node, parentFrame)
end


--- Updates a frame
---@param frameContext PropertyFrame
function PreviewNode:UpdateFrame(frameContext)
    local resolvedProps = self:ResolvePropsForFrame(frameContext.descriptor)
    frameContext:UpdateProperties(resolvedProps)
end

--- Updates all properties for a frame
function PreviewNode:ResolvePropsForFrame(frameDescription)
    local resolvedProps = {}
    for propName, prop in pairs(frameDescription.props) do
        resolvedProps[propName] = self:ResolveProp(prop)
    end
    return resolvedProps
end

--- Recursively resolve a prop (handles nested structures)
function PreviewNode:ResolveProp(prop)
    if prop.resolveType == "static" then
        return prop.value
    elseif prop.resolveType == "binding" then
        if prop.value then
            local binding = self:FindBinding(prop.value.binding)
            if binding then
                local field = prop.value.field
                local value = PreviewDataProvider.ResolveBinding(binding.type, binding.key, field)
                return value
            end
        end
        return nil
    elseif prop.resolveType == "template" then --TODO: Look into caching here!!        
        local bindings = {}
        -- find bindings from the template indicated by {binding:field}

        for alias, field in string.gmatch(prop.value, "{([^}:]+):([^}]+)}") do
            local binding = self:FindBinding(alias)
            if binding then
                if not bindings[alias..":"..field] then
                    bindings[alias..":"..field] = PreviewDataProvider.ResolveBinding(binding.type, binding.key, field)
                end
            end
        end

        local text = prop.value
        for key, value in pairs(bindings) do 
            if value and type(value) ~= "table" then
                local pattern = "{"..key.."}"
                local parts = ns.Core.SplitPlainText(text, pattern)
                
                -- Rebuild text with value inserted between parts
                local result = ""
                for i, part in ipairs(parts) do
                    result = result .. part
                    if i < #parts then  -- Don't add value after last part
                        result = result .. tostring(value)
                    end
                end
                
                text = result
            end
        end 
        return text
    end
    
    -- Handle nested objects (like CooldownDescriptor)
    if type(prop) == "table" and prop.resolveType == nil then
        local resolved = {}
        for key, val in pairs(prop) do
            resolved[key] = self:ResolveProp(val)
        end
        return resolved
    end
    
    return prop
end

---Find a binding with specific alias
---@param alias string
---@return BindingDescriptor?
function PreviewNode:FindBinding(alias)
    for _, binding in ipairs(self.node.bindings) do
        if binding.alias == alias then
            return binding
        end
    end
    return nil
end