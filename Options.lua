local _, env = ...

NeebelCore.defaults = {
    profile = {
    },
}

NeebelCore.options = { 
	name = "NeebelCDM",
	handler = NeebelCore,
	type = "group",
	args = {
        general= {
            type = "group",
            name = "General",
            order = 1,
            args = {
                msg = {
                    type = "input",
                    name = "Message",
                    desc = "The message to be displayed when you get home.",
                    usage = "<Your message>",
                    get = "GetMessage",
                    set = "SetMessage",
                },
            }
        },
	},
}

function NeebelCore:GetMessage(info)
    return "Test"
end

function NeebelCore:SetMessage(info, msg)
    print(msg)
end


function NeebelCore:GetValue(info)
	return self.db.profile[info[#info]]
end

function NeebelCore:SetValue(info, value)
	self.db.profile[info[#info]] = value
end