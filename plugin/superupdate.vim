" superupdate.vim

if exists("g:superupdate_included") || (v:version < 700) || &cp
    finish
endif
let g:superupdate_included = 1

runtime ./vim-logger/logger.vim
runtime ./vim-vimvar/vimvar.vim

" ======================================================================= vars =
" warn - print a message instead of updating plugins
if !exists("g:superupdate_warn")
    let g:superupdate_warn = 0
endif

" interval - the number of days between updates
if !exists("g:superupdate_interval")
    let g:superupdate_interval = 7
endif

" days - list of days when updates are allowed (empty should be the same as all)
" NOTE: lists require Vim7+
if !exists("g:superupdate_days")
    let g:superupdate_days = []
endif

" skip_first - when non-zero don't attempt to update plugins on the first run of
" superupdate
if !exists("g:superupdate_skip_first")
    let g:superupdate_skip_first = 0
endif

" ==================================================================== autocmd =

augroup superupdate_autocmds
    autocmd!
    "check for updates when Vim starts
    autocmd VimEnter * call superupdate#CheckForUpdate()

    "save update date if user runs an update manually
    autocmd BufDelete * if &previewwindow && &ft == "vundle" |
                \ call superupdate#SaveLastUpdate() | endif
    autocmd BufDelete,BufWinLeave * if &ft == "vim-plug" |
                \ call superupdate#SaveLastUpdate() | endif
augroup END

" =================================================================== commands =
" user accessible commands

command SuperUpdateGetLastUpdate call superupdate#PrintLastUpdate()
command SuperUpdateRunNow call superupdate#UpdatePlugins()
