" Configuration file for vim

filetype plugin indent on	" allow intelligent auto-indenting and plugins for each filetype
syntax on					" enable syntax highlighting
set number					" display line numbers on the left
"set ruler					" show the cursor position on status line
set showcmd					" show partial commands in the last line of the screen
set cursorline				" underline current line
"set autoindent				
set showmode
"set hlsearch				" highlight searches
"set wildmenu				" make command-line completion bash like + menu
"set wildmode=longest:full	

" Tab setting, by default is 4 spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
" for sh files, 2 spaces
autocmd filetype sh setlocal tabstop=2 softtabstop=0 shiftwidth=2
" for awk files, 2 spaces
autocmd filetype awk setlocal tabstop=2 softtabstop=0 shiftwidth=2

" statusline
" format markers:
"   %t File name (tail) of file in the buffer
"   %m Modified flag, text is " [+]"; " [-]" if 'modifiable' is off.
"   %r Readonly flag, text is " [RO]".
"   %y Type of file in the buffer, e.g., " [vim]".
"   %= Separation point between left and right aligned items.
"   %l Line number.
"   %L Number of lines in buffer.
"   %c Column number.
"   %o Number of byte on the file.
"   %P percentage through buffer
set statusline=%t\ %m%r%y%=[ascii=\%03.3b,hex=\%02.2B][l:%l/%L,c:%c][#Byte:%o][%P]
set laststatus=2			" Always display the status line

" Extra for statusline
if v:version >= 700
	" Enable spell check for text files
	autocmd BufNewFile,BufRead *.txt setlocal spell spelllang=en,it
	" Change highlighting based on mode
	"highlight statusLine cterm=bold ctermfg=black ctermbg=red
	"autocmd InsertLeave * highlight StatusLine cterm=bold ctermbg=red
	"autocmd InsertEnter * highlight StatusLine cterm=bold ctermbg=green
endif
