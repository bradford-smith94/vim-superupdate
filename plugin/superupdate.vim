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
    call INFO("SuperUpdate: update complete")
    call VarSave(s:UPDATE_KEY, s:Timestamp())
endfunction

" ------------------------------------------ ( ) - g:superupdate#UpdatePlugins -
" update plugins
function! g:superupdate#UpdatePlugins()
    "Vundle
    call INFO("SuperUpdate: update starting")
    PluginUpdate
endfunction

" ----------------------------------------- ( ) - g:superupdate#CheckForUpdate -
" check when the last time plugins were automatically updated and
" update them if it has been more than a week and it is currently the weekend
function! g:superupdate#CheckForUpdate()
    let l:last_update = VarRead(s:UPDATE_KEY)
    if l:last_update != 0 &&
     \ s:Timestamp() - l:last_update < s:WEEK ||
     \ s:DayOfWeek() < 4
        " only run after 7 days and on Fri, Sat or Sun
        " or if never updated (no update timestamp exists)
        return
    endif

    call g:superupdate#UpdatePlugins()
    call g:superupdate#SaveLastUpdate()
endfunction

