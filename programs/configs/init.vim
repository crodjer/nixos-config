scriptencoding utf-8

"" Basic behaviour
set noswapfile              "disable swapfiles
set hidden                  "hide buffers when not displayed
set textwidth=80            "maximum width of text that can be inserted
set nofoldenable            "don't fold by default
set clipboard+=unnamedplus  "use system clipboard
set mouse-=a
set cursorline
set updatetime=500

" Format options
set formatoptions-=o    "disable auto comment leader insertion with o/O
set formatoptions+=c    "enable auto wrapping and formatting in comments
set formatoptions-=t    "disable autowrapping using textwidth
set undofile

" Indentation / syntax highlighting
syntax enable
filetype plugin on
filetype indent on
set autoindent
set smartindent

"command line configuration
set showcmd                 "display incomplete commands
set wildmode=list           "make cmd line tab completion similar to bash
set wildmenu                "enable C-n and C-p to scroll through matches
"stuff to ignore when tab completing
set wildignore=*.o,*~,*.pyc,*.hi,*.class

"" Looks
set colorcolumn=+1                      "mark the ideal max text width
set relativenumber                      "show relative line numbers
set number                              "show absolute current line number
set showmode                            "show current mode down the bottom
set laststatus=2

set ruler

colorscheme default
set background=light
highlight Visual ctermbg=003 cterm=bold
highlight Search ctermbg=003
highlight CursorLine cterm=None
highlight CursorLineNR cterm=None ctermbg=gray ctermfg=black
highlight ColorColumn ctermbg=black
highlight SpellBad ctermbg=black cterm=undercurl,italic

"display tabs and trailing spaces
set list
set listchars=tab:\ \ ,trail:⋅,nbsp:⋅

"disable paste mode
set nopaste
augroup paste
  autocmd InsertLeave * set nopaste
augroup END

"" Handling whitespace
set expandtab                   "use spaces for tabs and set it to 4 spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set nowrap                      "don't wrap lines
set backspace=indent,eol,start  "backspace through everything in insert mode

"" Searching
set hlsearch        "highlight search by default
set incsearch       "incremental search
set ignorecase      "ignore cases while searching
set smartcase       "consider case for search patterns with uppercase letters


"" Mappings
"Set comma as my leader
let mapleader = ','

"Open file relative to current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"<C-l> - Clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>

"reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

"toggle spell check
nnoremap <leader>z :setlocal spell! spelllang=en<CR>

"close preview windows
nnoremap <leader>x :pclose<CR>

"go into paste mode
nnoremap <leader>mp :set paste<CR>a


"" Custom commands
" Strip white spaces!
command! STW %s/\s\+$//e

" Ale
let g:ale_lint_on_text_changed = 'never'
" let g:ale_open_list = 1
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_sign_column_always = 0
let g:ale_hover_cursor=1
let g:ale_set_balloons=1
let g:ale_hover_to_floating_preview = 1
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']

set omnifunc=ale#completion#OmniFunc
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_fixers = {
			\		'*': ['remove_trailing_lines', 'trim_whitespace'],
			\ 	'nix': ['statix'],
			\ }
nmap <silent> <leader>n :ALENext<cr>
nmap <silent> <leader>p :ALEPrevious<cr>
nmap <silent> <leader>d :ALEHover<cr>
nmap <silent> <leader>D :ALEGoToDefinition<cr>
nmap <silent> <leader>r :ALEFindReferences<cr>
nmap <silent> <leader>j :ALEImport<cr>
nmap <silent> <leader>F :ALEFix<cr>

augroup CloseLoclistWindowGroup
    autocmd!
    autocmd QuitPre * if empty(&buftype) | lclose | endif
augroup END

"" Language configurations

" FZF
augroup fzf
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END
nnoremap <leader>s :GFiles<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>

" Git commit
augroup git
    autocmd FileType gitcommit setlocal spell spelllang=en
augroup END

"" Ledger
let g:ledger_default_commodity = '₹ '
augroup ledger
    autocmd FileType ledger inoremap <silent> <Tab> <C-R>=ledger#autocomplete_and_align()<CR>
    autocmd FileType ledger inoremap <silent> <Esc> <Esc>:LedgerAlign<CR>
    autocmd FileType ledger vnoremap <silent> <Tab> :LedgerAlign<CR>
    autocmd FileType ledger nnoremap <silent> <Tab> :LedgerAlign<CR>
    autocmd FileType ledger noremap { ?^\d<CR>
    autocmd FileType ledger noremap } /^\d<CR>
augroup END

let g:lightline = {}
let g:lightline.component_expand = {
            \  'linter_checking': 'lightline#ale#checking',
            \  'linter_infos': 'lightline#ale#infos',
            \  'linter_warnings': 'lightline#ale#warnings',
            \  'linter_errors': 'lightline#ale#errors',
            \  'linter_ok': 'lightline#ale#ok',
            \ }
let g:lightline.component_type = {
      \     'linter_checking': 'right',
      \     'linter_infos': 'tabsel',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'tabsel',
      \ }

let g:lightline#ale#indicator_checking = '…'
let g:lightline#ale#indicator_infos = 'i'
let g:lightline#ale#indicator_warnings = '⚠'
let g:lightline#ale#indicator_errors = '✗'
let g:lightline#ale#indicator_ok = '✓'

let g:lightline.active = {
    \ 'left': [ [ 'mode', 'paste' ],
	\           [ 'readonly', 'filename', 'modified' ] ],
	\ 'right': [ [ 'lineinfo' ],
	\            [ 'percent' ],
	\            [ 'filetype' ],
    \            [ 'linter_checking', 'linter_errors', 'linter_warnings',
    \              'linter_infos', 'linter_ok' ]] }

call lightline#init()
call lightline#colorscheme()
call lightline#update()

" Markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript']
let g:vim_markdown_new_list_item_indent = 2
augroup markdown
    autocmd FileType markdown,rst setlocal sw=2 sts=2 et textwidth=70 conceallevel=0
    autocmd FileType markdown,rst,text setlocal spell spelllang=en wrap
augroup END


" Rust
let g:rustfmt_autosave = 1

augroup rust
    autocmd FileType rust setlocal textwidth=80
    autocmd FileType rust map <buffer> <leader>rt :RustTest<CR>
augroup END

" XML
augroup xml
    autocmd FileType xml setlocal iskeyword+=.,-
augroup END

" Tagbar
let g:tagbar_width = 30
nnoremap <leader>t :TagbarToggle<CR>
