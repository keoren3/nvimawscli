local utils = {}

function utils.create_buffer()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    return bufnr
end

function utils.create_window(bufnr, config)
    local winnr = 0
    if config.split == "vertical" then
        winnr = vim.api.nvim_open_win(bufnr, true, {
            vertical = true,
            split = "right"
        })
    end
    return winnr
end

function utils.get_line(bufnr, line)
    local lines = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)
    if #lines > 0 then
        return lines[1]
    end
    return nil
end

function utils.write_lines(bufnr, lines)
    lines = vim.split(lines, "\n")
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

return utils