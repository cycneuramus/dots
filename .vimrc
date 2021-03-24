""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
""""""""""""""""""""""""""""""""""""""""""""""""""

" Override color scheme background for system theme consistency
	augroup MyColors
		autocmd!
		autocmd ColorScheme * highlight Normal ctermbg=NONE
						  \ | highlight NonText ctermbg=NONE ctermfg=NONE
						  \ | highlight LineNr ctermbg=NONE
						  \ | highlight EndOfBuffer ctermbg=NONE ctermfg=NONE
	augroup END
	
" Better colors for the autocomplete menu
	highlight Pmenu ctermbg=gray guibg=gray
	
" Color scheme
	colorscheme OceanicNext

" Syntax highlighting
	syntax enable

" Line numbering
	set number "relativenumber

" Don't wrap lines in the middle of a word
	set linebreak
" Display as much text on-screen as possible, cutting off by visual line
	set display=lastline
	
" Case-insensitive search...
	set ignorecase
" ...unless search term contains upper case characters
	set smartcase
" Highlight search results
"	set hlsearch
" Search like in modern browsers 
	set incsearch	

" Tab autocompletion in command mode	
	set wildmenu
	set wildmode=list:longest,full

" Saner defaults for placement of splits
	set splitbelow splitright

" Shorter wait for keysequence completion
	set timeoutlen=200

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
""""""""""""""""""""""""""""""""""""""""""""""""""

" System clipboard compatibility
    set clipboard=unnamedplus

" Tab length
	set shiftwidth=4
	set tabstop=4

" Indentation
	set autoindent
	filetype plugin indent on

" Correct indentation behaviour for .yaml files
	augroup yaml_fix
    autocmd!
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>
	augroup END

" Spell checking
	set spelllang=sv

" Enables positioning the cursor past the end of the line in normal mode
" (helps placing footnotes)
	set virtualedit=onemore

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins 
""""""""""""""""""""""""""""""""""""""""""""""""""

" Install vim-plug if missing
	if empty(glob('~/.vim/autoload/plug.vim'))
	  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif

" Plugins to load
	call plug#begin() 
	"	Plug 'junegunn/goyo.vim' 
	"	Plug 'vim-pandoc/vim-markdownfootnotes'
		Plug 'takac/vim-hardtime'
		Plug 'vim-pandoc/vim-pandoc'
		Plug 'vim-pandoc/vim-pandoc-syntax'
		Plug '907th/vim-auto-save'
		Plug 'justinmk/vim-sneak'
		Plug 'isobit/vim-caddyfile'
	call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin configs
""""""""""""""""""""""""""""""""""""""""""""""""""

" Disable paren matching for .md files due to slowdowns
	augroup auFileTypes
		autocmd!
		autocmd FileType markdown NoMatchParen 
	augroup end

" Vim hard-mode default setting
	let g:hardtime_default_on = 0

" Enable autosave on Vim startup
	let g:auto_save = 1
" No autosave notification
	let g:auto_save_silent = 0

"" Ensure :q to quit even when Goyo is active
"	function! s:goyo_enter()
"		let b:quitting = 0
"		let b:quitting_bang = 0
"		autocmd QuitPre <buffer> let b:quitting = 1
"		cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
"	endfunction
"
"	function! s:goyo_leave()
"		" Quit Vim if this is the only remaining buffer
"		if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
"			if b:quitting_bang
"				qa!
"			else
"				qa
"			endif
"		endif
"		
"		" Workaround for Goyo messing up colors on leave
"		silent! set background=dark
"	endfunction
"
"	autocmd! User GoyoEnter call <SID>goyo_enter()
"	autocmd! User GoyoLeave call <SID>goyo_leave()
"
"" Open markdown files with Goyo
"	augroup auFileTypes
"		autocmd!
"		autocmd FileType markdown Goyo 
"	augroup end

" Customize vim-pandoc and vim-pandoc-syntax
	let g:pandoc#modules#enabled = ["bibliographies","completion"]
	let g:pandoc#biblio#sources = "bgy"
	let g:pandoc#biblio#bibs = ["/home/antsva/Nextcloud/Arbeten/Referensbibliotek.bib"]
	let g:pandoc#syntax#conceal#use = 0

" vim-sneak
	let g:sneak#label = 1
	let g:sneak#use_ic_scs = 1
"
"	" 2-character Sneak (default)
	nmap ö <Plug>Sneak_s
	nmap Ö <Plug>Sneak_S
"    " visual-mode
    xmap ö <Plug>Sneak_s
    xmap Ö <Plug>Sneak_S
"    " operator-pending-mode
    omap ö <Plug>Sneak_s
    omap Ö <Plug>Sneak_S

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings 
""""""""""""""""""""""""""""""""""""""""""""""""""

" Map leader key
	let mapleader = "\<Space>"

" Make Ctrl+C identical to Esc for compatibility with e.g. vim-auto-save
	inoremap <c-c> <Esc>
	vnoremap <c-c> <Esc>
	noremap <c-c> <Esc>

" Remap escape key
	" inoremap ii <Esc>
	" vnoremap ii <Esc>
	
" Map j and k to gj/gk, but only when no count is given
" However, for larger jumps like 6j add the current position to the jump list
" so that you can use <c-o>/<c-i> to jump to the previous position
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Render .md to .pdf
	nnoremap <leader>c :!source ~/.bashrc; pdoc "%"<CR><CR>
" Open corresponding .pdf
	nnoremap <leader>p :!if [[ -f "%:r.pdf" ]]; then okular "%:r.pdf" & disown; fi<CR><CR>

" Search functions
	noremap - /
	noremap _ :%s//g<Left><Left>

" More intuitive redo binding
	nnoremap U <c-r>

" Insert Markdown footnote
	nnoremap <leader>f i[^]<left>
	inoremap <C-r> i[^]<left>

" Markdown formatting
	inoremap <C-k> **<left>
	inoremap <C-f> ****<left><left>
	
" Shortcutting split navigation
"	noremap <C-h> <C-w>h
"	noremap <C-j> <C-w>j
"	noremap <C-k> <C-w>k
"	noremap <C-l> <C-w>l
	
" LaTeX helpers
	nnoremap <leader>tg i\textgreek{}<left>
	nnoremap <leader>tl i\textlatin{}<left>
