filetype plugin indent on
set encoding=utf-8
set nocompatible
syntax enable

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
    " Themes
    " Plug 'ErichDonGubler/vim-sublime-monokai'
    Plug 'rose-pine/vim'

    Plug 'vim-airline/vim-airline'
    Plug 'ryanoasis/vim-devicons'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'christoomey/vim-tmux-navigator'

    " :Search :SearchBuffers :SearchReset :SearchBuffersReset
    " <Leader>*
    Plug 'vim-scripts/MultipleSearch'

    " Fast searching
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'

    " Syntaxes for a lot of languages
    Plug 'sheerun/vim-polyglot'

    Plug 'preservim/nerdtree'

    " Fast in-file search/jumps with f
    Plug 'easymotion/vim-easymotion'

    Plug 'vim-scripts/SpellCheck'
call plug#end()

let g:mapleader=" "
colorscheme rosepine
set background=dark

let g:airline_powerline_fonts=1
let g:airline#extensions#keymap#enabled=0
let g:airline_section_z="\ue0a1:%l/%L Col:%c"
let g:Powerline_symbols='unicode'
let g:airline#extensions#xkblayout#enabled = 0

set ttimeoutlen=10
let &t_SI.="\e[5 q"
let &t_SR.="\e[3 q"
let &t_EI.="\e[1 q"

set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0

set guifont=JetBrainsMono\ Nerd\ Font:h16
set guioptions=
set showtabline=2
set nowrap
set cursorline
set notitle
set hlsearch                "Highlight all search results
set smartcase               "Enable smart-case search
set ignorecase              "Always case-insensitive
set incsearch               "Searches for strings incrementally
set expandtab               "Use spaces instead of tabs
set shiftwidth=4            "Number of auto-indent spaces
set smartindent             "Enable smart-indent
set smarttab                "Enable smart-tabs
set softtabstop=4           "Number of spaces per Tab
set confirm                 " get a dialog when :q, :w, or :wq fails
set nobackup
set noswapfile
set spell
set spelllang=en
set list
set colorcolumn=80
set number
set viminfo='20,\"500       " remember copy registers after quitting in the .viminfo file -- 20 jump links, regs up to 500 lines'
set hidden                  " remember undo after quitting
set history=150             " keep 50 lines of command history
set mouse=a
set ttymouse=sgr
set clipboard=unnamedplus

set fillchars+=vert:│       " nicer vert split separator
set fillchars+=stlnc:-      " nicer separator for horizontal split


" Highlight trailing whitespace (red background)
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

vnoremap < <gv
vnoremap > >gv
nnoremap gv `[v`]               " This mapping allows you to reselect the text you just pasted
map L :tabnext<cr>
map H :tabprevious<cr>
map <leader>td :tabclose<cr>    " Close current tab only
map <leader>bd :tabclose<cr>

let g:netrw_banner=0

" NERDTree configuration (project explorer)
nnoremap <leader>e :NERDTreeToggle<CR>
let g:NERDTreeShowHidden=1  " Show hidden files
let g:NERDTreeQuitOnOpen=0  " Keep open after file selection

augroup NERDTreeCustom
    autocmd!
    autocmd FileType nerdtree nnoremap <buffer> <CR> :call CustomNerdOpen()<CR>
augroup end

function! CustomNerdOpen()
    let node = g:NERDTreeFileNode.GetSelected()
    if !empty(node)
        if node.path.isDirectory
            call node.activate()
        else
            call node.open({'where': 't', 'keepopen': 1, 'stay': 1})
        endif
    endif
endfunction

" Custom function to open file in existing tab if open, else new tab
function! OpenInTab(file)
    let bufnr = bufnr(a:file)
    if bufnr != -1
        for tab in range(1, tabpagenr('$'))
            if index(tabpagebuflist(tab), bufnr) >= 0
                execute 'tabnext ' . tab
                return
            endif
        endfor
    endif
    execute 'tabedit ' . fnameescape(a:file)
endfunction

" Custom sink for :Files to avoid duplicates
let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit',
    \ 'ctrl-e': 'edit' }
" For enter, use custom sink
nnoremap <leader>ff :call fzf#vim#files('', {'sink': function('OpenInTab')})<CR>

" Custom sink for :Rg to open in tab without duplicates, with line jump
function! RgSink(line)
    let original_tab = tabpagenr()
    let parts = split(a:line, ':')
    let file = parts[0]
    let lnum = parts[1]
    let bufnr = bufnr(file)
    if bufnr != -1
        for tab in range(1, tabpagenr('$'))
            if index(tabpagebuflist(tab), bufnr) >= 0
                execute 'tabnext ' . tab
                execute lnum
                return
            endif
        endfor
    endif
    execute 'tabedit ' . fnameescape(file)
    execute lnum
endfunction

" fzf.vim mappings (file search, grep) with custom sinks
" For :Rg, custom call with sink for tab open
" For :Rg, custom call with sink for tab open (interactive and arg-based)
command! -bang -nargs=* Rg call fzf#vim#grep(
    \ 'rg --column --line-number --no-heading --color=always --smart-case -- ' . shellescape(<q-args>),
    \ 1,
    \ fzf#vim#with_preview({'options': '--disabled --query "" --bind "change:reload:rg --column --line-number --no-heading --color=always --smart-case -- {q} || true"', 'sink': function('RgSink')}),
    \ <bang>0)
nnoremap <leader>sg :Rg<CR>

" EasyMotion for fast in-file search (enhanced f/t jumps)
let g:EasyMotion_do_mapping = 0  " Disable default mappings
let g:EasyMotion_smartcase = 1   " Smart case
nmap <leader>f <Plug>(easymotion-overwin-f2)    " Jump to 2-char sequences
nmap <leader>l <Plug>(easymotion-overwin-line)  " Jump to lines

" coc.nvim configuration (LSP for clangd)
let g:coc_global_extensions = ['coc-clangd', 'coc-pyright', 'coc-sh']  " Extensions for C/C++, Python, Bash
let g:coc_preferences_useQuickfixForLocations = 0
let g:clangd_command = ['clangd',
    \ '--clang-tidy',
    \ '--background-index',
    \ '--header-insertion-decorators=0',
    \ '--header-insertion=never',
    \ '--completion-style=detailed']

let g:ycm_clangd_uses_ycmd_caching = 0
let g:ycm_clangd_binary_path = exepath("clangd")

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use tab for navigation only if popup visible, else always insert tab/spaces
inoremap <silent><expr> <TAB> coc#pum#visible()
            \ ? coc#pum#next(1)
            \ : "\<Tab>"

inoremap <expr><S-TAB> coc#pum#visible()
            \ ? coc#pum#prev(1)
            \ : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
inoremap <silent><expr> <CR> coc#pum#visible()
            \ ? coc#pum#confirm()
            \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Diagnostics navigation
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

function! CustomJump(action)
    call CocAction(a:action, 'tabe')
endfunction

nmap <silent> gd :call CustomJump('jumpDefinition')<CR>
nmap <silent> gr :call CustomJump('jumpReferences')<CR>
nmap <silent> gi :call CustomJump('jumpImplementation')<CR>
nmap <silent> gy :call CustomJump('jumpTypeDefinition')<CR>

nnoremap <silent> K :call <sid>show_documentation()<cr>
function! s:show_documentation()
    if index(['vim', 'help'], &filetype) >= 0
        execute 'help ' . expand('<cword>')
    elseif &filetype ==# 'tex'
        VimtexDocPackage
    else
        call CocAction('doHover')
    endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>F <Plug>(coc-format-selected)
nmap <leader>F <Plug>(coc-format-selected)

function! ToggleDiagnostics()
    call CocAction('diagnosticToggleBuffer')
    if exists('b:coc_diagnostics_disable') && b:coc_diagnostics_disable
        echo 'Diagnostics disabled for this buffer'
    else
        echo 'Diagnostics enabled for this buffer'
    endif
endfunction
nnoremap <silent> <leader>du :call ToggleDiagnostics()<CR>

" For clangd: Automatically detect compile_commands.json in project root
let g:clangd_arguments = ['--compile-commands-dir=.', '--header-insertion=never']
nmap <silent> <leader>a <Plug> (coc-codeaction-cursor)

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Function to copy via OSC 52
function! Osc52Copy(text)
    let encoded_text = substitute(a:text, '\n', '\r', 'g')
    " Convert text in base64, remove newline sybmols
    let b64_text = system('echo ' . shellescape(encoded_text) . ' | base64 | tr -d "\n"')
    let b64_text = substitute(b64_text, '\n', '', 'g')
    " Create OSC 52 sequence
    let osc52_seq = "\e]52;c;" . b64_text . "\x07"

    " Wrap sequence when inside tmux
    if !empty($TMUX)
        let osc52_seq = "\ePtmux;\e" . osc52_seq . "\e\\"
    endif

    " Try to write down the sequence in the terminal
    silent call writefile([osc52_seq], "/dev/tty", "b")
    " Check if there is an utility called `pbcopy` (for macOS) to use as a fallback
    if has('macunix') && executable('pbcopy') && empty($SSH_CONNECTION)
        call system('pbcopy', a:text)
    endif
endfunction

" Automatically copy when yank
autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Copy(@0) | endif

" Past via OSC 52 (read from buffer)
function! Osc52Paste()
    echo "Запрос буфера через OSC 52..."
    " Send a request to read the buffer
    writefile(["\e]52;c;?\x07"], "/dev/tty", "b")
    " In terms with OSC 52 support the responce will be automatic
endfunction

" tmux configuration
if !empty($TMUX)
    " Tmux configuration to work with OSC 52
    function! TmuxOsc52Copy(text)
        let encoded_text = substitute(a:text, '\n', '\r', 'g')
        let b64_text = system('base64 | tr -d "\n"', encoded_text)
        let b64_text = substitute(b64_text, '\n', '', 'g')
        " Special format for tmux
        let osc52_seq = "\ePtmux;\e\e]52;c;" . b64_text . "\x07\e\\"
        call writefile([osc52_seq], "/dev/tty", "b")
    endfunction

    autocmd TextYankPost * if v:event.operator ==# 'y' | call TmuxOsc52Copy(@0) | endif
endif

" Paste with Ctrl+V
imap <C-V> <C-R>+
cmap <C-V> <C-R>+
