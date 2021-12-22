" 补全插件
Plug 'hrsh7th/nvim-cmp'

" 补全来源

if g:load_program 
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer' " 编辑文档比较多，一般还是别开buffer补全了
endif

Plug 'hrsh7th/cmp-path' "路径补全一定要加
Plug 'hrsh7th/cmp-cmdline' " 命令模式补全

Plug 'hrsh7th/cmp-vsnip' " snippet 补全

" snip

Plug 'hrsh7th/vim-vsnip' " snippet 引擎

Plug 'rafamadriz/friendly-snippets' "提供一堆snip

" 图标

Plug 'onsails/lspkind-nvim' "代码提示中，显示分类的小图标支持


autocmd vimenter * call PlugConfigCMP()

function! PlugConfigCMP()
  LoadLua ./plug_configs/lsp/auto_complete.lua
endfunction



