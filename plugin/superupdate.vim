" superupdate.vim

if exists("g:superupdate#included")
    finish
endif
let g:superupdate#included = 1

runtime ./vim-logger/logger.vim
runtime ./vim-vimvar/vimvar.vim

" ====================================================================== const =
let s:INTEGER = 0
let s:SHORT = 1
let s:LONG = 2

let s:SECOND = 1
let s:MINUTE = 60 * s:SECOND
let s:HOUR = 60 * s:MINUTE
let s:DAY = 24 * s:HOUR
let s:WEEK = 7 * s:DAY

let s:UPDATE_KEY = "superupdate#last_update"

" ======================================================================= vars =
" warn - print a message instead of updating plugins
if !exists("g:superupdate#warn")
    let g:superupdate#warn = 0
endif

" interval - the number of days between updates
if !exists("g:superupdate#interval")
    let g:superupdate#interval = 7
endif
let s:UPDATE_INTERVAL = g:superupdate#interval * s:DAY

" days - list of days when updates are allowed (empty should be the same as all)
" NOTE: lists require Vim7+
if !exists("g:superupdate#days")
    let g:superupdate#days = []
endif


" ==================================================================== helpers =

" ----------------------------------------- ( type = s:INTEGER ) - s:DayOfWeek -
" obtain the day of week as an integer, three letter abbreviation or full name
function! s:DayOfWeek ( ... )
    if a:0 > 1
        call WARN("DayOfWeek expects one or no parameters; found", a:0)
    endif
    let l:type = a:0 > 0 ? a:1 : s:INTEGER
    if l:type == s:INTEGER
        return strftime("%u") - 1
    elseif l:type == s:SHORT
        return strftime("%a")
    elseif l:type == s:LONG
        return strftime("%A")
    endif
    call WARN("DayOfWeek unknown type", l:type)
    return -1
endfunction

" ---------------------------------------------------------- ( ) - s:Timestamp -
" retrieve timestamp in seconds from epoch
function! s:Timestamp ( )
    return str2nr(strftime("%s"))
endfunction

" ==================================================================== autocmd =

augroup superupdate_autocmds
    autocmd!
    "check for updates when Vim starts
    autocmd VimEnter * call g:superupdate#CheckForUpdate()

    "save update date if user runs an update manually
    autocmd BufDelete * if &previewwindow && &ft == "vundle" |
                \ call g:superupdate#SaveLastUpdate() | endif
augroup END

" ----------------------------------------- ( ) - g:superupdate#SaveLastUpdate -
" save current timestamp
function! g:superupdate#SaveLastUpdate()
    if g:superupdate#warn == 0
        call INFO("SuperUpdate: update complete")
        call VarSave(s:UPDATE_KEY, s:Timestamp())
    endif
endfunction

" ------------------------------------------ ( ) - g:superupdate#UpdatePlugins -
" update plugins
function! g:superupdate#UpdatePlugins()
    if g:superupdate#warn == 0
        call INFO("SuperUpdate: update starting")
        "Vundle
        PluginUpdate
    else
        echom "SuperUpdate: Plugins have not been updated in: " . g:superupdate#interval . " day(s)"
    endif
endfunction

" ----------------------------------------- ( ) - g:superupdate#CheckForUpdate -
" check when the last time plugins were automatically updated and
" update them if it has been more than a week and it is currently the weekend
function! g:superupdate#CheckForUpdate()
    let l:last_update = VarRead(s:UPDATE_KEY)
    if l:last_update != 0 &&
     \ s:Timestamp() - l:last_update < s:UPDATE_INTERVAL ||
     \ s:DayOfWeek() < 4
        " only run after update interval and on Fri, Sat or Sun
        " or if never updated (no update timestamp exists)
        return
    endif

    call g:superupdate#UpdatePlugins()
    call g:superupdate#SaveLastUpdate()
endfunction

