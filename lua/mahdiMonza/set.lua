-- [[ Setting options ]]
-- See `:help vim.o`
local v = vim

-- Set number and relative number
v.o.nu = true
v.o.rnu = true
-- Disable netrw
v.g.loaded_netrw = 1
v.g.loaded_netrwPlugin = 1

-- Show matching brackets/braces
v.o.showmatch = true

-- Tabwidths set to 4 while maintaining classical tabwidths
v.o.ts = 8
v.o.sw = 4
v.o.sts = 4
v.o.expandtab = true
v.o.smarttab = true
v.o.autoindent = true
v.o.smartindent = true
v.o.cindent = true

-- Set highlight on search
v.o.hlsearch = false
v.o.incsearch = true

-- Enable mouse mode
v.o.mouse = 'a'

-- Enable break indent
v.o.breakindent = true

-- Save undo history
v.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
v.o.ignorecase = true
v.o.smartcase = true

-- Decrease update time
v.o.updatetime = 250
v.wo.signcolumn = 'yes'

-- Set scrolloff
v.o.scrolloff = 12

-- Set colorscheme
v.o.termguicolors = true

-- Better autocompletion
v.o.completeopt = 'menuone,noselect'

-- Turn off swapfile
v.o.swapfile = false
