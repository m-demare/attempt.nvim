# attempt.nvim

Manage your temporary buffers

## Preview
![preview](https://user-images.githubusercontent.com/34817965/167322611-cd4d7b8c-e041-4c57-a2ba-9c214c250411.gif)

## Features
- Quickly create scratch files for any filetype, using vim.ui.select, vim.ui.input or
  any other method
- Scratch files are saved in a temporary directory for later use, and can be accessed
  across neovim instances
- Files are initialized with all the necessary boilerplate to be runnable
- Reopen closed attempts with Telescope
- Autosave attempts
- Run the scratch files
- Every file operation is asynchronous

## Dependencies
This plugin depends on [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation
This plugin is for [neovim](https://neovim.io/) only. Version 0.7+ is required.

[lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
    'm-demare/attempt.nvim', -- No need to specify plenary as dependency
}
```

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
    py = initial_content_fn, -- Either string or function that returns the initial content
    c = initial_content_fn,
    cpp = initial_content_fn,
    java = initial_content_fn,
    rs = initial_content_fn,
    go = initial_content_fn,
    sh = initial_content_fn
  },
  ext_options = { 'lua', 'js', 'py', 'cpp', 'c', '' },  -- Options to choose from
  format_opts = { [''] = '[None]' },                    -- How they'll look
  run = {
    py = { 'w !python' },      -- Either table of strings or lua functions
    js = { 'w !node' },
    ts = { 'w !deno run -' },
    lua = { 'w' , 'luafile %' },
    sh = { 'w !bash' },
    pl = { 'w !perl' },
    cpp = { 'w' , '!'.. cpp_compiler ..' %:p -o %:p:r.out && echo "" && %:p:r.out && rm %:p:r.out '},
    c = { 'w' , '!'.. c_compiler ..' %:p -o %:p:r.out && echo "" && %:p:r.out && rm %:p:r.out'},
  }
}
-- (You may omit the settings whose defaults you're ok with)
```

It's recommended to use either the telescope or the snacks.picker for opening your
attempts, since they allow previewing the files' contents

### Telescope picker
To use the telescope picker for opening your attempts, add this somewhere after your
`telescope.setup()` call:
```lua
require('telescope').load_extension 'attempt'
```
You can customize this picker in the usual [telescope way](https://github.com/nvim-telescope/telescope.nvim#customization)

### Snacks picker
To use the snacks.nvim picker for opening your attempts, you can use the following mapping:
```lua
vim.keymap.set('n', '<leader>al', require('attempt.snacks').picker)
```

### Keymaps
By default, no keymaps are created. To use the basic presets, you can do:

```lua
local attempt = require('attempt')
local map = vim.keymap.set

map('n', '<leader>an', attempt.new_select)        -- new attempt, selecting extension
map('n', '<leader>ai', attempt.new_input_ext)     -- new attempt, inputing extension
map('n', '<leader>ar', attempt.run)               -- run attempt
map('n', '<leader>ad', attempt.delete_buf)        -- delete attempt from current buffer
map('n', '<leader>ac', attempt.rename_buf)        -- rename attempt from current buffer
map('n', '<leader>al', 'Telescope attempt')       -- search through attempts
--or: map('n', '<leader>al', require('attempt.snacks').picker)
--or: map('n', '<leader>al', attempt.open_select) -- use ui.select instead of telescope/snacks.nvim
```

See [`:h
attempt-interface`](https://github.com/m-demare/attempt.nvim/tree/main/doc/attempt.txt)
for more customized setups


