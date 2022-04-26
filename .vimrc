set number
set linebreak	
set showbreak=+++ 
set textwidth=100 
set showmatch	 
set visualbell	 
 
set hlsearch	 
set smartcase	 
set ignorecase	 
set incsearch	 
 
set autoindent	 
set expandtab	 
set shiftwidth=2 
set smartindent	 
set smarttab	 
set softtabstop=2 
 
set ruler	 

set termguicolors
 
set undolevels=1000	
set backspace=indent,eol,start	

call plug#begin('~/.vim/plugged')

Plug 'joshdick/onedark.vim'

Plug 'sheerun/vim-polyglot'

Plug 'vim-airline/vim-airline'

Plug 'jreybert/vimagit'

call plug#end()

colorscheme onedark
