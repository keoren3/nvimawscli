local config = require("nvimawscli.config")
local itertools = require("nvimawscli.utils.itertools")
local handler = require("nvimawscli.commands")

---@class ProfileHandler
local M = {}

---Fetch the list of profiles
function M.get_all_profiles(on_result)
	local query_strings = itertools.imap_values(config.ec2.instances.preferred_attributes, function(value)
		return value.name .. ": " .. value.value
	end)
	local query_string = table.concat(query_strings, ", ")
	handler.async(
		"aws ec2 describe-instances " .. "--query 'Reservations[].Instances[].{" .. query_string .. "}'",
		on_result
	)
end
