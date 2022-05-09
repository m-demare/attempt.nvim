# attempt.nvim

Manage your temporary buffers

## Preview
![preview](https://user-images.githubusercontent.com/34817965/167322611-cd4d7b8c-e041-4c57-a2ba-9c214c250411.gif)

## Features
- Quickly create scratch files for any filetype, using vim.ui.select, vim.ui.input or
  any other method
- Scratch files are saved in a temporary directory for later use, and can be accessed
  across neovim instances
- Reopen closed scratch file with Telescope
- Run the scratch files
- Every file operation is asynchronous

## Installation
This plugin is for [neovim](https://neovim.io/) only. Version 0.7+ is required.

[packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
  'm-demare/attempt.nvim',
  requires = 'nvim-lua/plenary.nvim',
}

-- Optional
use {
  { 'nvim-telescope/telescope.nvim' },
  { 'nvim-telescope/telescope-ui-select.nvim' }
}
```

[vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'm-demare/attempt.nvim'

" Optional
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
```

## Usage

If you are ok with the default settings:
```lua
require('attempt').setup()
```

To change them
```lua
require('attempt').setup{
  dir = (unix and '/tmp/' or vim.fn.expand '$TEMP\\') .. 'attempt.nvim' .. path_separator,
  autosave = false,
  list_buffers = false,     -- This will make them show on other pickers (like :Telescope buffers)
  initial_content = {
    py = initial_content_fn -- Either string or function that returns the initial content
  },
  ext_options = { 'lua', 'js', 'py', 'cpp', 'c', '' },  -- Options to choose from
  format_opts = { [''] = '[None]' },                    -- How they'll look
  run = {
    py = 'w !python',       -- Either strings or lua functions
    js = 'w !node',
    lua = 'w | luafile %'
  }
}
-- (You may omit the settings whose defaults you're ok with)
```

### Telescope picker
To use the telescope picker for opening your attempts (recommended, to have a nice
previewer), add this somewhere after your `telescope.setup()` call:
```lua
require('telescope').load_extension 'attempt'
```
You can customize this picker in the usual [telescope
way](https://github.com/nvim-telescope/telescope.nvim#customization)

### Keymaps
By default, no keymaps are created. To use the basic presets, you can do:

```lua
local attempt = require('attempt')

function M.map(mode, l, r, opts)
    opts = opts or {}
    opts = vim.tbl_extend('force', { silent=true }, opts)
    vim.keymap.set(mode, l, r, opts)
end

map('n', '<leader>an', attempt.new_select)        -- new attempt, selecting extension
map('n', '<leader>ai', attempt.new_input_ext)     -- new attempt, inputing extension
map('n', '<leader>ar', attempt.run)               -- run attempt
map('n', '<leader>al', 'Telescope attempt')       -- search through attempts
-- or: map('n', '<leader>al', attempt.open_select) -- use ui.select instead of telescope
```

See [`:h
attempt.nvim`](https://github.com/m-demare/attempt.nvim/tree/main/doc/attempt.txt)
for more customized setups


