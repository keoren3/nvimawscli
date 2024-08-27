local command = require("nvimawscli.commands.profiles")

---@class ProfilesActionsManage
local M = {}

M.actions = {
	"choose",
	"delete",
}

---@class ProfileAction
---@field ask_for_confirmation boolean
---@field action fun(profile_name: string)

---@type ProfileAction
M.choose = {
	ask_for_confirmation = false,
	action = function(profile_name)
		command.choose_profile(profile_name)
	end,
}

------@type ProfileAction
---M.delete = {
---	ask_for_confirmation = false,
---	action = function(profile_name)
---		command.choose_profile(profile_name, function(result, error)
---			if error then
---				vim.api.nvim_err_writeln(error)
---			elseif result then
---				vim.api.nvim_out_write(result)
---			end
---		end)
---	end,
---}

return M
