local utils = require("nvimawscli.utils.buffer")
local command = require("nvimawscli.commands.profiles")
local table_renderer = require("nvimawscli.utils.tables")
local config = require("nvimawscli.config")
local profile_actions = require("nvimawscli.services.profiles.actions")
local ui = require("nvimawscli.utils.ui")
local itertools = require("nvimawscli.utils.itertools")
---@class ProfileName
local M = {}

local column_headers = { "Name" }

---@class ProfileObject
---@field Name string

function M.show(profile_name, split)
	M.profile_name = profile_name
	if not M.bufnr then
		M.load()
	end

	if not M.winnr or not vim.api.nvim_win_is_valid(M.winnr) then
		M.winnr = utils.create_window(M.bufnr, split)
	end
	vim.api.nvim_set_current_win(M.winnr)
	M.fetch()
end

function M.load()
	M.bufnr = utils.create_buffer("profiles.names")

	vim.api.nvim_buf_set_keymap(M.bufnr, "n", "<CR>", "", {
		callback = function()
			if not M.ready then
				return
			end
			local position = vim.fn.getcursorcharpos()
			local line_number = position[2]
			local column_number = position[3]

			local item_number = table_renderer.get_item_number_from_row(line_number)

			if item_number > 0 and item_number <= #M.rows then
				local profile_object = M.rows[item_number]
				local available_actions = profile_actions.actions

				ui.create_floating_select_popup(nil, available_actions, config.table, function(selected_action)
					local action = available_actions[selected_action]
					if profile_actions[action].ask_for_confirmation then
						ui.create_floating_select_popup(
							action .. " profile action " .. profile_object.Key,
							{ "yes", "no" },
							config.table,
							function(confirmation)
								if confirmation == 1 then
									profile_actions[action].action(M.profile_name, { profile_object })
								end
							end
						)
					else
						profile_actions[action].action(M.profile_name, { profile_object })
					end
				end)
			elseif item_number == 0 then
				M.handle_sort_event(column_number)
			elseif item_number == #M.rows + 3 then
				local available_actions = profile_actions.actions
				ui.create_floating_select_popup(nil, available_actions, config.table, function(selected_action)
					local action = available_actions[selected_action]
					if profile_actions[action].ask_for_confirmation then
						ui.create_floating_select_popup(
							action .. " all",
							{ "yes", "no" },
							config.table,
							function(confirmation)
								if confirmation == 1 then
									profile_actions[action].action(M.profile_name, M.rows)
								end
							end
						)
					else
						profile_actions[action].action(M.profile_name, M.rows)
					end
				end)
			elseif M.next_token then
				print("get more content")
			end
		end,
	})
end

function M.handle_sort_event(column_number)
	local column_index = table_renderer.get_column_index_from_position(column_number, M.widths)
	if M.sorted_by_column_index == column_index then
		M.sorted_direction = M.sorted_direction * -1
	else
		M.sorted_by_column_index = column_index
		M.sorted_direction = 1
	end
	if column_index then
		local column_value = column_headers[column_index]

		table.sort(M.rows, function(a, b)
			if M.sorted_direction == 1 then
				return a[column_value] < b[column_value]
			end
			return a[column_value] > b[column_value]
		end)
		M.render(M.rows)
	end
end

function M.fetch()
	M.ready = false
	M.next_token = nil
	utils.write_lines(M.bufnr, { "Fetching content..." })
	command.list_profiles(function(result, error)
		if error then
			utils.write_lines_string(M.bufnr, error)
		elseif result then
			local response = vim.json.decode(result)
			M.rows = response.Contents
			M.next_token = response.NextToken
			local allowed_positions = M.render(M.rows, M.next_token)
			utils.set_allowed_positions(M.bufnr, allowed_positions)
		else
			utils.write_lines_string(M.bufnr, "Result was nil")
		end
		M.ready = true
	end)
end

function M.render(rows, next_token)
	local lines, allowed_positions, widths =
		table_renderer.render(column_headers, rows, M.sorted_by_column_index, M.sorted_direction, config.table)
	M.widths = widths

	lines[#lines + 1] = "---"
	lines[#lines + 1] = "Action on all objects"
	allowed_positions[#allowed_positions + 1] = {}
	allowed_positions[#allowed_positions][1] = { #lines, 1 }

	if next_token then
		lines[#lines + 1] = "---"
		lines[#lines + 1] = "Press <Enter> to fetch more content"
		allowed_positions[#allowed_positions + 1] = {}
		allowed_positions[#allowed_positions][1] = { #lines, 1 }
	end
	utils.write_lines(M.bufnr, lines)
	return allowed_positions
end

return M
