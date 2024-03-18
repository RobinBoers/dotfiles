" === Plugins === "

call plug#begin()

  Plug 'nvim-telescope/telescope.nvim'
  Plug 'junegunn/goyo.vim'
  Plug 'junegunn/limelight.vim'

call plug#end()

" ===  Appearance  === "

" Use terminal color scheme
colorscheme default
set notermguicolors

syntax on           " Turn syntax highlighting on
set ruler           " Show where cursor is
set showmatch       " Show brackets when text indicator is over them

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Proper line wrapping
set wrap
set linebreak

" STOP HARD WRAPPING MY TXT FILES!!
set formatoptions-=t

" CTRL-p

nnoremap <C-p> :Telescope find_files<cr>
vnoremap <C-p> :Telescope find_files<cr>
inoremap <C-p> <C-o>:Telescope find_files<cr>

" Write mode

function! s:goyo_enter()
  let g:limelight_conceal_ctermfg = 'darkgray'
  Limelight

  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  Limelight!

  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

" Homemade statusline
" See: https://shapeshed.com/vim-statuslines/

set cmdheight=1     " Height of the command area
set noshowmode      " Since I'll be displaying the current mode in the status line, I disable the native way vim does this.

function! StatuslineModeColor()
    let l:mode=mode()
    if l:mode==?"v"
        return "Search"
    elseif l:mode==#"i"
        return "Directory"
    elseif l:mode==#"R"
        return "DiffDelete"
    else
        return "PmenuThumb"
    endif
endfunction

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  elseif l:mode==?"s"
    return "SELECT"
  elseif l:mode==#"t"
    return "TERMINAL"
  elseif l:mode==#"c"
    return "COMMAND"
  elseif l:mode==#"!"
    return "SHELL"
  endif
endfunction

set statusline=
set statusline+=\ %#{StatuslineModeColor()}#
set statusline+=\ \ %{StatuslineMode()}\ \ 
set statusline+=%#ModeMsg#
set statusline+=%#LineNr#
set statusline+=\ %=			" Left-right seperator
set statusline+=\ %f                    " Current file
set statusline+=\ %#WarningMsg#
set statusline+=\ %m                    " Dirty buffer state

" ===  Editor  === "

set backspace=indent,eol,start  " Use backspace to delete automatic indent, end of lines and characters outside of insert mode.
set hidden                      " Don't discard unsaved buffers (and terminals)
"set so=15                      " Set the minimal number of lines below the cursor

" Use the best encoding
set encoding=UTF-8

" Intergrate system clipboard (needs xclip, wl-copy or similar)
set clipboard+=unnamedplus

" Show new content when editted from outside
set autoread        
au FocusGained,BufEnter * checktime " When you open a buffer or if vim gains focus

" Turn off swap files (because I use git)
set noswapfile
set nobackup
set nowb

set ignorecase smartcase  " Ignore case only when the pattern contains no capital letters

" Get rid of highlight after search
map <esc> :noh<cr>

" ===  CHEATS  === "

" Map Ctrl+S to save
nnoremap <C-s> :w<CR>
vnoremap <C-s> <C-c>:w<CR>
inoremap <C-s> <C-o>:w<CR>
