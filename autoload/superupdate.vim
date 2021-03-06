" autoload/superupdate.vim

" ====================================================================== const =
let s:INTEGER = 0
let s:SHORT = 1
let s:LONG = 2

let s:SECOND = 1
let s:MINUTE = 60 * s:SECOND
let s:HOUR = 60 * s:MINUTE
let s:DAY = 24 * s:HOUR
let s:WEEK = 7 * s:DAY

let s:UPDATE_KEY = 'superupdate_last_update'

" ==================================================================== helpers =

" ------------------------------- ( type = s:INTEGER ) - superupdate#DayOfWeek -
" obtain the day of week as an integer, three letter abbreviation or full name
function! superupdate#DayOfWeek ( ... ) abort
    if a:0 > 1
        call WARN('DayOfWeek expects one or no parameters; found', a:0)
    endif
    let l:type = a:0 > 0 ? a:1 : s:INTEGER
    if l:type == s:INTEGER
        return strftime('%u') - 1
    elseif l:type == s:SHORT
        return strftime('%a')
    elseif l:type == s:LONG
        return strftime('%A')
    endif
    call WARN('DayOfWeek unknown type', l:type)
    return -1
endfunction

" ------------------------------------------------ ( ) - superupdate#Timestamp -
" retrieve timestamp in seconds from epoch
function! superupdate#Timestamp ( ) abort
    return str2nr(strftime('%s'))
endfunction

" ------------------------------------------- ( ) - superupdate#UpdateInterval -
" calculate update interval
function! superupdate#UpdateInterval ( ) abort
    return g:superupdate_interval * s:DAY
endfunction

" ================================================================== functions =
" abort

" ------------------------------------------- ( ) - superupdate#SaveLastUpdate -
" save current timestamp
function! superupdate#SaveLastUpdate() abort
    if g:superupdate_warn == 0
        call INFO('SuperUpdate: update complete')
        call VarSave(s:UPDATE_KEY, superupdate#Timestamp())
    endif
endfunction

" print the last update timestamp
function! superupdate#PrintLastUpdate() abort
    let l:last_update = VarRead(s:UPDATE_KEY)
    echo strftime('%c', l:last_update)
endfunction

" -------------------------------------------- ( ) - superupdate#UpdatePlugins -
" update plugins
function! superupdate#UpdatePlugins() abort
    let s:update_error = 0
    if g:superupdate_warn == 0
        call INFO('SuperUpdate: update starting')
        if exists('g:superupdate_command')
            execute g:superupdate_command
        elseif globpath(&rtp, 'autoload/vundle.vim', 1) !=# ''
            "Vundle
            PluginUpdate
        elseif globpath(&rtp, 'autoload/plug.vim', 1) !=# ''
            "vim-plug
            try
                PlugUpdate
            catch /^\$GIT_\w* detected\./
                let s:update_error = 1
                echom 'SuperUpdate: Cannot update using vim-plug in a git directory'
            endtry
        elseif globpath(&rtp, 'autoload/dein.vim', 1) !=# ''
            "dein
            call dein#update()
        elseif globpath(&rtp, 'autoload/neobundle.vim', 1) !=# ''
            "neobundle
            NeoBundleUpdate
        elseif globpath(&rtp, 'plugin/minpac.vim', 1) !=# ''
            "minpac
            call minpac#update()
        else
            echom 'SuperUpdate: Error no update command set/found!'
            let s:update_error = 1
        endif

        if s:update_error == 0
            call superupdate#SaveLastUpdate()
        endif
    else
        echom 'SuperUpdate: Plugins have not been updated in more than: ' .
                    \ g:superupdate_interval . ' day(s)'
    endif
endfunction

" ------------------------------------------- ( ) - superupdate#CheckForUpdate -
" check when the last time plugins were automatically updated and
" update them if it has been more than a week and it is currently the weekend
function! superupdate#CheckForUpdate() abort
    let l:last_update = VarRead(s:UPDATE_KEY)
    if l:last_update != 0 &&
     \ superupdate#Timestamp() - l:last_update < superupdate#UpdateInterval() ||
     \ (len(g:superupdate_days) > 0 &&
     \ index(g:superupdate_days, superupdate#DayOfWeek()) < 0)
        " only run after update interval and on a day in g:superupdate_days if
        " g:superupdate_days is not empty
        " OR if never updated (no update timestamp exists)
        return
    elseif l:last_update == 0 && g:superupdate_skip_first != 0
        call superupdate#SaveLastUpdate()
        return
    endif

    call superupdate#UpdatePlugins()
endfunction

