local _, ns = ...

local NodeDatabase = {}
ns.Nodes.NodeDatabase = NodeDatabase

function NodeDatabase:Initialize(db)
    self.nodes = db.profiles.nodes

    if self.nodes == nil then
        db.profiles.nodes = {}
        self.nodes = db.profiles.nodes
    end
end

function NodeDatabase:GetNodes()
    return self.nodes
end

function NodeDatabase:GetNode(guid)
    return self.nodes[guid]
end

function NodeDatabase:AddNode(node)
    self.nodes[node.guid] = node
end

function NodeDatabase:RemoveNode(guid)
    self.nodes[guid] = nil
end

