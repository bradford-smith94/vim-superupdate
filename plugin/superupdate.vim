" superupdate.vim

augroup plugin_updating
    "clear this autocmd group to protect from re-sourcing this file
    autocmd!
    autocmd VimEnter * call AutoupdatePlugins()
    autocmd BufDelete * if &previewwindow && &ft == "vundle" |
                \ call SaveLastUpdate() | endif
augroup END

function! SaveLastUpdate()
    let g:LAST_UPDATE = str2nr(strftime("%Y%m%d"))
endfunction

"function to check when the last time plugins were automatically updated and
"update them if it has been more than a week and it is currently the weekend
function! AutoupdatePlugins()
"sohua.xyz/questions/2190412/how-do-i-get-vim-to-test-if-user-input-is-an-integer
    if exists("g:LAST_UPDATE")
        if ((str2nr(strftime("%Y%m%d")) - g:LAST_UPDATE) >= 7)
            if (strftime("%a") == "Fri" ||
                        \ strftime("%a") == "Sat" ||
                        \ strftime("%a") == "Sun")
                PluginUpdate
                "save today's date as YYYYMMDD
                call SaveLastUpdate()
            endif
        endif
    else
        call SaveLastUpdate()
    endif
endfunction
