" superupdate.vim

if exists("g:superupdate_included") || (v:version < 700) || &cp
    finish
endif
let g:superupdate_included = 1

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

let s:UPDATE_KEY = "superupdate_last_update"

" ======================================================================= vars =
" warn - print a message instead of updating plugins
if !exists("g:superupdate_warn")
    let g:superupdate_warn = 0
endif

" interval - the number of days between updates
if !exists("g:superupdate_interval")
    let g:superupdate_interval = 7
endif
let s:UPDATE_INTERVAL = g:superupdate_interval * s:DAY

" days - list of days when updates are allowed (empty should be the same as all)
" NOTE: lists require Vim7+
if !exists("g:superupdate_days")
    let g:superupdate_days = []
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
    autocmd VimEnter * call <SID>superupdate_CheckForUpdate()

    "save update date if user runs an update manually
    autocmd BufDelete * if &previewwindow && &ft == "vundle" |
                \ call <SID>superupdate_SaveLastUpdate() | endif
augroup END

" ----------------------------------------- ( ) - s:superupdate_SaveLastUpdate -
" save current timestamp
function! s:superupdate_SaveLastUpdate()
    if g:superupdate_warn == 0
        call INFO("SuperUpdate: update complete")
        call VarSave(s:UPDATE_KEY, s:Timestamp())
    endif
endfunction

" print the last update timestamp
function! s:superupdate_PrintLastUpdate()
    let l:last_update = VarRead(s:UPDATE_KEY)
    echo strftime("%c", l:last_update)
endfunction

" ------------------------------------------ ( ) - s:superupdate_UpdatePlugins -
" update plugins
function! s:superupdate_UpdatePlugins()
    if g:superupdate_warn == 0
        call INFO("SuperUpdate: update starting")
        if exists("g:superupdate_command")
            execute g:superupdate_command
        else
            "TODO: detect plugin manager
            "Vundle
            PluginUpdate
        endif
    else
        echom "SuperUpdate: Plugins have not been updated in more than: " .
                    \ g:superupdate_interval . " day(s)"
    endif

    call <SID>superupdate_SaveLastUpdate()
endfunction

" ----------------------------------------- ( ) - s:superupdate_CheckForUpdate -
" check when the last time plugins were automatically updated and
" update them if it has been more than a week and it is currently the weekend
function! s:superupdate_CheckForUpdate()
    let l:last_update = VarRead(s:UPDATE_KEY)
    if l:last_update != 0 &&
     \ s:Timestamp() - l:last_update < s:UPDATE_INTERVAL ||
     \ (len(g:superupdate_days) > 0 &&
     \ index(g:superupdate_days, s:DayOfWeek()) < 0)
        " only run after update interval and on a day in g:superupdate_days if
        " g:superupdate_days is not empty
        " OR if never updated (no update timestamp exists)
        return
    endif

    call <SID>superupdate_UpdatePlugins()
endfunction

" =================================================================== commands =
" user accessible commands

command SuperUpdateGetLastUpdate call <SID>superupdate_PrintLastUpdate()
