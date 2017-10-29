call plug#begin('~/.local/share/nvim/plugged')

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
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

let mapleader = ","

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

set hlsearch!
nnoremap <F3> :set hlsearch!<CR>

Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'mileszs/ack.vim'
Plug 'vim-ruby/vim-ruby'
Plug 'kien/ctrlp.vim'
Plug 'thoughtbot/vim-rspec'
Plug 'jgdavey/tslime.vim'
Plug 'lifepillar/vim-solarized8'

call plug#end()

map <Leader>p :CtrlP<CR>
map <Leader>bb PlugInstall<CR>
map <Leader>cc Ack! <cword><CR>

"" enable full colors
set termguicolors

set background = "dark"

"" use ag with ack.vim
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

set t_Co=256
set t_8f=^[[38;2;%lu;%lu;%lum  " Needed in tmux
set t_8b=^[[48;2;%lu;%lu;%lum  " Ditto
colorscheme solarized8_dark_flat

" Make CtrlP use ag for listing the files. Way faster and no useless files.
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
let g:ctrlp_use_caching = 0

" Use send to tmux to run selected specs
let g:rspec_command = 'call Send_to_Tmux("bin/rspec {spec}\n")'

" vim-rspec mappings
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

set t_8f=^[[38;2;%lu;%lu;%lum  " Needed in tmux
set t_8b=^[[48;2;%lu;%lu;%lum  " Ditto
