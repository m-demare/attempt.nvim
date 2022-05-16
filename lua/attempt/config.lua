local M = {}

local unix = vim.fn.has 'unix' == 1
local path_separator = unix and '/' or '\\'

local cpp_compiler = "g++"
local c_compiler = "gcc"

local function initial_content_fn(ext)
	return require('attempt.initial_content.' .. ext)
end

local defaults = {
	dir = (unix and '/tmp/' or vim.fn.expand '$TEMP\\') .. 'attempt.nvim' .. path_separator,
	autosave = false,
	list_buffers = false,
	initial_content = {
		py = initial_content_fn,
		c = initial_content_fn,
		cpp = initial_content_fn,
		java = initial_content_fn,
		rs = initial_content_fn,
		go = initial_content_fn,
		sh = initial_content_fn
	},
	ext_options = { 'lua', 'js', 'py', 'cpp', 'c', '' },
	format_opts = { [''] = '[None]' },
	run = {
		py = { 'w !python' },
		js = { 'w !node' },
		lua = { 'w', 'luafile %' },
		sh = { 'w !bash' },
		pl = { 'w !perl' },
		cpp = { "w" , '!'.. cpp_compiler ..'% -o %:p:r.out && echo "" && %:p:r.out'},
		c = { "w" , '!'.. c_compiler ..'% -o %:p:r.out && echo "" && %:p:r.out'},
	}
}

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})
	if not string.find(M.opts.dir, path_separator .. '$') then
		M.opts.dir = M.opts.dir .. path_separator
	end
end

return M
