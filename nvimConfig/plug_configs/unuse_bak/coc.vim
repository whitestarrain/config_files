" TODO 改为使用lsp

"-----------------------------------coc插件--------------------------------------
" coc 插件
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"-----------------------------------coc插件--------------------------------------
"------------------------------------coc-------------------------------------
autocmd vimenter * call PlugConfigCoc()
function! PlugConfigCoc()
  " " 解决启动稍微延迟问题： 让coc服务，在neovim启动后，500ms后才启动
  " let g:coc_start_at_startup=0
  " function! CocTimerStart(timer)
  "     exec "CocStart"
  " endfunction
  " call timer_start(500,'CocTimerStart',{'repeat':1})
  " 
  " "解决coc.nvim大文件卡死状况。超过0.02m的文件，禁用coc补全。我们很多时候要打开log文件，tag文件等嘛！
  let g:trigger_size = 0.02 * 1048576
  augroup hugefile_coc
    autocmd!
    autocmd BufReadPre *
          \ let size = getfsize(expand('<afile>')) |
          \ if (size > g:trigger_size) || (size == -2) |
          \   echohl WarningMsg | echomsg 'WARNING: altering options for this huge file!' | echohl None |
          \   exec 'CocDisable' |
          \ else |
          \   exec 'CocEnable' |
          \ endif |
          \ unlet size
  augroup END
  " markmap
  command! -range=% Markmap CocCommand markmap.create <line1> <line2>

  " help <Plug>(coc 查看更多
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  nnoremap <silent> gh :call CocActionAsync('doHover')<CR>
  inoremap <C-P> <C-\><C-O>:call CocActionAsync('showSignatureHelp')<cr>

  nmap <silent> ,f <plug>(coc-format)
  vmap <silent> ,f <plug>(coc-format-selected)

  " refactor help:
    " https://github.com/neoclide/coc.nvim/wiki/Multiple-cursors-support
    " https://zhuanlan.zhihu.com/p/272119909

  nmap <leader>rn <Plug>(coc-rename)
  nmap <leader>rf <Plug>(coc-refactor)

" TODO
" coc插件列表，可根据需要进行删减
" let g:coc_global_extensions = [
"     \ 'coc-vimlsp',
"     \ 'coc-xml',
"     \ 'coc-yank',
"     \ 'coc-sh',
"     \ 'coc-yaml',
"     \ 'coc-cmake',
"     \ 'coc-snippets',
"     \ 'coc-clangd',
"     \ 'coc-json',
"     \ 'coc-lists',
"     \ 'coc-word',
"     \ 'coc-ci',
"     \ 'coc-zi',
"     \ 'coc-just-complete',
"     \ 'coc-python',
"     \ 'coc-marketplace',
"   \ ]

endfunction
"------------------------------------coc-------------------------------------
