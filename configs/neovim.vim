if system("dconf read '/org/gnome/desktop/interface/color-scheme'") =~ "dark"
  set background=dark
else
  set background=light
endif

set termguicolors
colorscheme catppuccin

set expandtab tabstop=2 softtabstop=2 shiftwidth=2
set formatoptions-=t
set relativenumber number cursorline signcolumn=yes
set clipboard+=unnamedplus
set showcmd modeline undofile updatetime=100 timeoutlen=300
set ignorecase smartcase
set completeopt=menuone,preview
set breakindent termguicolors textwidth=80 colorcolumn=+1
set spell spelllang=en spellfile=~/.local/share/nvim/spell/en.add

let mapleader = ','

"" Custom Bindings

"Open file relative to current file
nnoremap <leader>n :e <C-R>=expand("%:p:h") . "/" <CR>

"" Treesitter based folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable                     " Disable folding at startup.

"" Ledger
let g:ledger_default_commodity = '₹ '
augroup ledger
    autocmd FileType ledger inoremap <silent> <Tab> <C-R>=ledger#autocomplete_and_align()<CR>
    autocmd FileType ledger inoremap <silent> <C-J> <Esc>==:LedgerAlign<CR>
    autocmd FileType ledger vnoremap <silent> <Tab> ==:LedgerAlign<CR>
    autocmd FileType ledger nnoremap <silent> <Tab> ==:LedgerAlign<CR>
    autocmd FileType ledger noremap { ?^\d<CR>
    autocmd FileType ledger noremap } /^\d<CR>
augroup END

"" Auto-close quickfix buffer
autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>

lua << END
------------
-- Lua start
------------
require("ibl").setup()

-- fzf
local fzf = require('fzf-lua')
fzf.setup({'skim'})
fzf.register_ui_select()

local function nmapl(binding, mapping, desc)
  vim.keymap.set('n', '<leader>' .. binding, mapping, {
    noremap = true, silent = true, desc = desc
  })
end

local find_files = function()
  local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ";")
  if git_dir == '' then
    fzf.files()
  else
    fzf.git_files()
  end
end

local find_in_package = function()
  interesting_files = {
    'Cargo.toml',
    'Pipfile',
    'package.json',
    '.git',
    'shell.nix'
  }
  local parent_dir = vim.fn.expand("%:p:h")
  for _, file in pairs(interesting_files) do
    project_dir = vim.fs.dirname(vim.fs.find(file, {
      path = parent_dir,
      upward = true
    })[1])
    print(project_dir)

    if project_dir then
      fzf.files({ cwd=project_dir })
      return
    end
  end

  fzf.files({ cwd=parent_dir })
end

nmapl('f', find_files, "Search Files")
nmapl('e', find_in_package, "Search Files in package.")
nmapl('b', fzf.buffers, "Search Buffers")
nmapl('h', fzf.oldfiles, "Search History")
nmapl('sl', fzf.live_grep, "Search Live Grep")
nmapl('sh', fzf.command_history, "Search Command History")
nmapl('sc', fzf.commands, "Search Commands")

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

require("nvim-autopairs").setup()
-- Completion
local cmp = require'cmp'

-- UltiSnips
require("cmp_nvim_ultisnips").setup {}
local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(
      function(fallback)
        cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
      end,
      { "i", "s" }
    ),
    ["<S-Tab>"] = cmp.mapping(
      function(fallback)
        cmp_ultisnips_mappings.jump_backwards(fallback)
      end,
      { "i", "s" }
    ),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.filetype('ledger', {
  sources = cmp.config.sources()
})

-- LSP
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

local lspconfig = require('lspconfig');
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
  ansiblels = {},
  elixirls = {},
  gopls = {},
  html = {},
  jdtls = {},
  lua_ls = {},
  nil_ls = {},
  rust_analyzer = {},
  solargraph = {},
  vtsls = {}
}

for server, config in pairs(servers) do
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }

    local function map(modes, binding, mapping, desc)
      vim.keymap.set(modes, binding, mapping, {
        buffer = ev.buf, desc = "LSP: " .. desc
      })
    end

    map('n', 'gD', fzf.lsp_declarations, "Go to Declaration")
    map('n', 'gd', fzf.lsp_definitions, "Go to Definition")
    map('n', 'K', vim.lsp.buf.hover, "Hover")
    map('n', 'gi', fzf.lsp_implementations, "Go to Implementation")
    map('n', '<C-k>', vim.lsp.buf.signature_help, "Get Signature Help")
    map('n', '<leader>t', fzf.lsp_typedefs, "Get Type Definition")
    map('n', '<leader>rn', vim.lsp.buf.rename, "Rename")
    map({ 'n', 'v' }, '<leader>ca', fzf.lsp_code_actions, "Perform Code Action")
    map('n', 'gr', fzf.lsp_references, "Get Refernces")
    map('n', '<leader>cf', function()
      vim.lsp.buf.format { async = true }
    end, "Format Code")
  end,
})

-- Fidget
require("fidget").setup {}

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
      init_selection = "gnn",
      node_incremental = "n",
      scope_incremental = "s",
      node_decremental = "p",
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
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

-- Custom Functions
local rooter = function()
  local git_dir = vim.fn.finddir('.git', vim.fn.expand('%:p') .. ";")
  if git_dir then
    vim.cmd.tcd(new_dir)
  end
end
vim.keymap.set("n", "<leader>r", rooter)

----------
-- Lua ends
----------
END
