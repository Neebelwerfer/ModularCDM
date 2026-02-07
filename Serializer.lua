Serializer = {}

---@class StoredNode
---@field version number
---@field serialized string
---@field timeStamp number

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")


---@param node Node
---@return string
function Serializer.Export(node)
    local serialized = AceSerializer:Serialize(node)
    local compressed = LibDeflate:CompressDeflate(serialized)
    return LibDeflate:EncodeForPrint(compressed)
end

---@param encoded string
---@return boolean, Node | string
function Serializer.Import(encoded)
    local compressed = LibDeflate:DecodeForPrint(encoded)
    local decompressed = LibDeflate:DecompressDeflate(compressed)
    return AceSerializer:Deserialize(decompressed)
end
