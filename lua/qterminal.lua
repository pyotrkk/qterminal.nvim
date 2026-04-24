local M = {}

-- Global state
local terminal_win = nil
local terminal_buf = nil

function M.toggle()
    if not terminal_win or not vim.api.nvim_win_is_valid(terminal_win) then
        return M.open_terminal()
    end
    
    return M.close_terminal()
end

function M.open_terminal()
    -- Create floating window
    local win_height = math.floor(vim.o.lines * 0.4)
    local win_width = vim.o.columns
    terminal_win = vim.api.nvim_open_win(0, true, {
        relative = 'editor', row = 0, col = 0,
        width = win_width, height = win_height,
        style = 'minimal', border = '', zindex = 110,
    })

    -- Reuse existing terminal buffer if valid
    if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
        -- Reuse existing buffer
        vim.api.nvim_set_current_buf(terminal_buf)
    else
        -- Create new terminal buffer if needed
        vim.cmd('terminal')
        terminal_buf = vim.api.nvim_get_current_buf()
    end

    vim.cmd.startinsert()
end

function M.close_terminal()
    if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
        vim.api.nvim_win_close(terminal_win, false)
        terminal_win = nil
    end
end

function M.setup()
    vim.api.nvim_create_user_command('Qterminal', function()
        M.toggle()
    end, { range = true })

    -- Close terminal when we lose focus on it
    vim.api.nvim_create_autocmd('WinLeave', {
        callback = function()
            if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
                M.close_terminal()
            end
        end,
    })
end

return M
