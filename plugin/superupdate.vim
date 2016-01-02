" superupdate.vim

if exists("g:loaded_superupdate")
    finish
endif
let g:loaded_superupdate = 1

augroup superupdate_autocmds
    autocmd!
    "check for updates when Vim starts
    autocmd VimEnter * call CheckForUpdate()

    "save update date if user runs an update manually
    autocmd BufDelete * if &previewwindow && &ft == "vundle" |
                \ call SaveLastUpdate() | endif
augroup END

"function to save today's date as YYYYMMDD
function! SaveLastUpdate()
    let g:LAST_UPDATE = str2nr(strftime("%Y%m%d"))
endfunction

"function to update plugins
function! UpdatePlugins()
    "Vundle
    PluginUpdate
endfunction

"function to check when the last time plugins were automatically updated and
"update them if it has been more than a week and it is currently the weekend
function! CheckForUpdate()
    if exists("g:LAST_UPDATE")
        if ((str2nr(strftime("%Y%m%d")) - g:LAST_UPDATE) >= 7)
            if (strftime("%a") == "Fri" ||
                        \ strftime("%a") == "Sat" ||
                        \ strftime("%a") == "Sun")
                call UpdatePlugins()
                call SaveLastUpdate()
            endif
        endif
    else
        call UpdatePlugins()
        call SaveLastUpdate()
    endif
endfunction
