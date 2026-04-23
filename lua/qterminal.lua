local M = {}

-- Global state
local terminal_win = nil
local terminal_buf = nil
local prev_win = nil
local original_win_state = {}

function M.toggle()
    if not terminal_win or not vim.api.nvim_win_is_valid(terminal_win) then
        return M.open_terminal()
    end
    
    local current_win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(current_win) ~= terminal_buf then
        return M.open_terminal()
    end
    
    return M.close_terminal()
end

function M.open_terminal()
    -- Clear old terminal state
    terminal_win = nil
    
    -- Save current window state BEFORE creating terminal
    local wins = vim.api.nvim_list_wins()
    local current_win = vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(current_win) then
        return M.open_terminal()
    end
    
    for _, win_id in ipairs(wins) do
        original_win_state[win_id] = {
            buf = vim.api.nvim_win_get_buf(win_id),
            config = vim.api.nvim_win_get_config(win_id),
        }
    end
    
    -- Reuse existing terminal buffer if valid
    local reuse = terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf)
    if not reuse then
        -- Create new terminal buffer
        vim.cmd('belowright terminal')
        local split_win = vim.api.nvim_get_current_win()
        terminal_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_win_close(split_win, false)
    else
        -- Buffer valid, just clear window reference and reuse
        terminal_win = nil
    end
    
    -- Create floating window
    local win_height = math.floor(vim.o.lines * 0.4)
    local win_width = vim.o.columns
    terminal_win = vim.api.nvim_open_win(terminal_buf, false, {
        relative = 'editor', row = 0, col = 0,
        width = win_width, height = win_height,
        style = 'minimal', border = '', zindex = 100,
    })
    
    vim.api.nvim_set_current_win(terminal_win)
    vim.cmd.startinsert()
    M.prev_win = current_win
end

function M.close_terminal()
    if not terminal_win or not vim.api.nvim_win_is_valid(terminal_win) then
        return M.open_terminal()
    end
    
    -- Restore state first (this will restore other windows)
    M.restore_state()
    if M.prev_win then
        vim.api.nvim_set_current_win(M.prev_win)
    end
    
    -- Close terminal window
    vim.api.nvim_win_close(terminal_win, false)
    terminal_win = nil
    M.prev_win = nil
end

function M.restore_state()
    local wins = vim.api.nvim_list_wins()
    
    for _, win_id in ipairs(wins) do
        local data = original_win_state[win_id]
        if data then
            vim.api.nvim_win_set_buf(win_id, data.buf)
            if data.config then
                vim.api.nvim_win_set_config(win_id, data.config)
            end
        end
    end
end

function M.setup()
    vim.api.nvim_create_user_command('Qterminal', function()
        M.toggle()
    end, { range = true })
end

return M
