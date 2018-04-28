" ViM configuration file

" ======== Options ========
set nocompatible                " be iMproved (default)
filetype plugin indent on       " allow intelligent auto-indenting and plugins for each filetype
syntax on                       " enable syntax highlighting
set term=xterm-256color
set number                      " display line numbers on the left
set showcmd                     " show partial commands in the last line of the screen
set showmatch                   " show matching braces
set foldmethod=syntax           " folding method depending from the current syntax
"set noshowmode                 " do not show mode in the last line
set hlsearch                    " highlight searches
set mouse=a                     " enable mouse in all modes
set wildmenu                    " make command mode (:) completion bash-like
set wildmode=longest:full       " complete only until point of ambiguity
set cryptmethod=blowfish2       " strongest encryption method for writing a locked file (using ':X')
set backspace=indent,eol,start " backspace anything
set scrolloff=4                 " number of lines above and below cursor

" display tabs and trailing spaces
" :set list/list! to toggle
set list listchars=tab:▸\ ,trail:·,extends:›,precedes:‹,eol:¬

" ======== Theme ========
syntax enable
set background=dark             " for solarized DARK
let g:solarized_visibility="low"  " special chars defined in listchars now have LOW visibility
colorscheme solarized


" ======== Tab settings ========
" default: 1 hard <tab>
" using Smart Tabs plugin: tabs for indentation, spaces for alignment
set tabstop=4       " width in spaces of a hard tabstop
set shiftwidth=4    " width in spaces of an indentation (usually same as tabstop)
set softtabstop=0   " number of spaces that a <tab> counts inserting a tab or backspace
"set expandtab      " use <space> instead of <tab> character
"set smarttab       " a <Tab> in front of a line insert blanks according to shiftwidth

" for sh files, 2 <space> chars
autocmd filetype sh setlocal tabstop=2 shiftwidth=2
" for awk files, 2 <space> chars
autocmd filetype awk setlocal tabstop= 2 shiftwidth=2
" for Make files, 1 hard <tab> chars with 8 spaces width
autocmd filetype make setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab


" ======== statusline ========
" format markers:
"   %t File name (tail) of file in the buffer
"   %m Modified flag, text is " [+]"; " [-]" if 'modifiable' is off
"   %r Readonly flag, text is " [RO]".
"   %y Type of file in the buffer, e.g. " [vim]"
"   %= Separation point between left and right aligned items
"   %l Line number
"   %L Number of lines in buffer
"   %c Column number
"   %o Number of byte on the file
"   %P percentage through buffer
set statusline=%t\ %m%r%y%=[ascii=\%03.3b,hex=\%02.2B][l:%l/%L,c:%c][#Byte:%o][%P]%<
set laststatus=2    " Always display the status line


" ======== Autocmds ========
" Enable spell check for text files
autocmd BufNewFile,BufRead *.txt setlocal spell spelllang=en,it

" Underlining current line based on mode
autocmd InsertLeave * set nocursorline
autocmd InsertEnter * set cursorline
