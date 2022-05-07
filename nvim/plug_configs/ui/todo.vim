" DEPN: Plug 'nvim-lua/plenary.nvim'
" DEPN: scoop install ripgrep
Plug 'folke/todo-comments.nvim'

" 记得加冒号`:`
" 显示高亮时，屏幕滚动可能会有些卡顿，但是利大于弊

autocmd User LoadPluginConfig call PlugConfigTODOComments()

function! PlugConfigTODOComments()
lua << EOF

  require("todo-comments").setup {
      signs = true,
      sign_priority = 9,
      keywords = {
        FIX = {
          icon = ' ',
          color = 'error',
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        },
        TODO = { icon = ' ', color = '#ffbb00' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX', 'WARN' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        DEPN = { icon = ' ', color = '#1e90ff'},
      },
      merge_keywords = true,
      highlight = {
        before = '',
        keyword = 'wide',
        after = 'fg',
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      colors = {
        error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
        warning = { 'DiagnosticWarning', 'WarningMsg', '#FBBF24' },
        info = { 'DiagnosticInfo', '#ffbb00' },
        hint = { 'DiagnosticHint', '#10B981' },
        default = { 'Identifier', '#7C3AED' },
      },
      search = {
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },  
    }
EOF
endfunction

