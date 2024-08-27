local handler = require("nvimawscli.commands")

---@class ProfileHandler
local M = {}

---Fetch the list of profiles
---@param on_result OnResult
function M.list_profiles(on_result)
	handler.async("aws configure list-profiles", on_result)
end

---Set the current profile
---@param profile_name string
---@param on_result OnResult
function M.choose_profile(profile_name, on_result)
	os.execute("export AWS_PROFILE=" .. profile_name)
	handler.async("Changed to profile " .. profile_name, on_result)
end

return M
