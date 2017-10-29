set rtp+=/usr/local/opt/fzf

set nocompatible                " choose no compatibility with legacy vi
syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

let mapleader = "\<Space>"

set number
set relativenumber

function! NumberToggle()
	if(&relativenumber == 1)
		set norelativenumber
		set number
	else
		set relativenumber
		set number
	endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>

Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'mileszs/ack.vim'
Plug 'kien/ctrlp.vim'
Plug 'thoughtbot/vim-rspec'

call plug#end()

map <Leader>p :CtrlP<CR>
map <Leader>bb PlugInstall<CR>
" Quickly hide highlighted search results
nmap <Leader>h :nohlsearch<CR>
