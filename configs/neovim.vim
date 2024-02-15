set background=light
set termguicolors
colorscheme catppuccin

set expandtab tabstop=2 softtabstop=2 shiftwidth=2
set relativenumber number cursorline signcolumn=yes
set clipboard+=unnamedplus
set showcmd modeline undofile updatetime=100 timeoutlen=300
set ignorecase smartcase
set completeopt=menuone,noselect
set breakindent termguicolors textwidth=80 colorcolumn=+1

let mapleader = ','

" FZF
nnoremap <leader>s :GFiles<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>c :Command<CR>

" ---------
" Lua start
" ---------
lua << END
require("ibl").setup()

require('lualine').setup({
  options = {
    theme = 'catppuccin',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
  }
})

require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  }
})

-- LSP
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

local on_lsp_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gd', vim.lsp.buf.definition, 'Go to Definition')
  nmap('gD', vim.lsp.buf.declaration, 'Go to Declaration')

  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
end

local lspconfig = require('lspconfig');
local servers = {
  ansiblels = {},
  lua_ls = {},
  nil_ls = {},
  ruff_lsp = {},
  rust_analyzer = {},
  solargraph = {},
  tsserver = {}
}

for server, config in pairs(servers) do
  config.on_attach = on_attach
  lspconfig[server].setup(config)
end

-- Treesitter
require('nvim-treesitter.configs').setup {
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
  },
  indent = { enable = true, disable = { "ledger", "ruby" } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}

-- Aerial
require("aerial").setup({
  nerd_font = true,
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
END
" --------
" Lua ends
" --------

" Treesitter based folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable                     " Disable folding at startup.
