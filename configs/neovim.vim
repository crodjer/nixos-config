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

"" Tree-sitter based folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable                     " Disable folding at startup.

lua << END
-----------------------------
-- Lua start
-----------------------------
require('mini.align').setup()                 -- Align text, `ga` / `gA`
require('mini.bracketed').setup()
require('mini.comment').setup()				        -- Comments: `gc`, `gcc`
require('mini.completion').setup()            -- Autocompletion
require('mini.cursorword').setup()            -- Highlight word under cursor!
require('mini.pairs').setup()				          -- Auto Pairs
require('mini.statusline').setup()			      -- A bit nicer status line.
require('mini.surround').setup()			        -- Surround tricks
require('mini.trailspace').setup()            -- Highlight trailing white space.
require('mini.notify').setup({                      -- Show notifications
  window = {
    max_width_share = 0.75,
  }
})
require('mini.move').setup({                  -- Move selections | M-< | M->
  mappings = {
    -- Visual selection
    left = '<', right = '>', up = '', down = '',
    -- Move current line in Normal mode
    line_left = '<', line_right = '>', line_up = '', line_down = ''
  },
})

require('mini.indentscope').setup({
  delay = 30,
  symbol = "│",
})

-----------------------------
-- Mapping Functions
-----------------------------
local function nmap(binding, mapping, desc)
  -- Helper function to map in normal mode.
  vim.keymap.set('n', binding, mapping, {
    noremap = true, silent = true, desc = desc
  })
end

local function nlmap(binding, mapping, desc)
  -- Helper function specifically for leader mappings.
  nmap('<leader>' .. binding, mapping, desc)
end

-----------------------------
--- File Picker
-----------------------------
local fzf = require('fzf-lua')
if (vim.fn.executable('sk') == 1) then
  -- Prefer skim if available.
  fzf.setup({'skim'})
end

local find_files = function()
  local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ";")
  if git_dir == '' then fzf.files()
  else fzf.git_files()
  end
end

local package_files = function()
  local package_indicators = {
    'Cargo.toml', 'Pipfile', 'Gemfile', 'package.json', '.git', 'shell.nix'
  }
  local parent_dir = vim.fs.dirname(vim.fn.resolve(vim.fn.expand("%:p")))
  for _, file in pairs(package_indicators) do
    local project_dir = vim.fs.dirname(vim.fs.find(file, {
      path = parent_dir,
      upward = true
    })[1])

    if project_dir then
      fzf.files({ cwd= project_dir })
      return
    end
  end

  fzf.files({ cwd = parent_dir })
end

nlmap('f', find_files, "Search [F]iles")
nlmap('e', package_files, "Search Files in packag[e].")
nlmap('b', fzf.buffers, "Search [B]uffers")
nlmap('h', fzf.oldfiles, "Search [H]istory")
nlmap('sl', fzf.live_grep, "[S]earch [L]ive Grep")
nlmap('sh', fzf.command_history, "[S]earch Command [H]istory")
nlmap('sc', fzf.commands, "[S]earch [C]ommands")


-----------------------------
--- LSP
-----------------------------
local lspconfig = require('lspconfig');
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
  vtsls = {
    settings = {
      typescript = {
        tsserver = {
          maxTsServerMemory = 20480
        }
      }
    }
  }
}

for server, config in pairs(servers) do
  lspconfig[server].setup(config)
end

-----------------------------
--- Tree-sitter
-----------------------------
require('nvim-treesitter.configs').setup {
  ensure_installed = {},
  highlight = { enable = true },
  indent = { enable = true, disable = { "ledger" } },
  ignore_install = {},
  modules = {},
  sync_install = false,
  auto_install = false,
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

-----------------------------
-- Lua ends
-----------------------------
END
