# qterminal

A minimal Quake-style floating terminal for Neovim.

## Features

- **Floating window**: Opens a terminal at the top of the screen
- **Buffer reuse**: Reuses terminal buffers to prevent terminal spam
- **Starts in insert mode**: Ready to type immediately

## Installation

Add to your plugin manager:

**Plug:**
```vim
Plug 'pyotrkk/qterminal'
```

**Lazy:**
```lua
{ 'pyotrkk/qterminal' }
```

**Packer:**
```lua
use 'pyotrkk/qterminal'
```

## Setup

In your `init.lua` or equivalent:

```lua
local qterminal = require('qterminal')

-- Register the :Qterminal command
qterminal.setup()
```

## Usage

### Command

```
:Qterminal
```

Toggle the floating terminal on/off.

### Keymap (optional)

If you prefer a keybinding:

```lua
vim.keymap.set('n', '<leader>t', function()
    require('qterminal').toggle()
end, { noremap = true })
```

## API

| Function | Description |
|----------|-------------|
| `qterminal.setup()` | Registers `:Qterminal` command |
| `qterminal.toggle()` | Toggles terminal open/closed |
| `qterminal.open_terminal()` | Opens a new terminal |
| `qterminal.close_terminal()` | Closes current terminal |

## Notes

- The terminal opens in insert mode automatically
- To exit insert mode, press `C-\_C-n`, or use a keymap to call `:QTerminal` from insert mode
- The terminal uses the default terminal emulator (or `$TERM` environment variable)

