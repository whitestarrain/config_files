Plug 'kyazdani42/nvim-tree.lua'

" NOTE: f977e5c05a87c865 导致写入文件时会有一个wait(message中的[w])，如果保存时有延时，可以暂时使用 f977e5 ~1

autocmd User LoadPluginConfig call PlugConfigNvimTree()

function PlugConfigNvimTree()

" let g:nvim_tree_gitignore = 1 " 0 by default
" let g:nvim_tree_quit_on_open = 0 " 0 by default, closes the tree when you open a file
" let g:nvim_tree_indent_markers = 1 " 0 by default, this option shows indent markers when folders are open
let g:nvim_tree_git_hl = 1 " 0 by default, will enable file highlight for git attributes (can be used without the icons).
let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
let g:nvim_tree_icon_padding = ' ' "one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
" let g:nvim_tree_symlink_arrow = ' >> ' " defaults to ' ➛ '. used as a separator between symlinks' source and target.
let g:nvim_tree_respect_buf_cwd = 1 "0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
let g:nvim_tree_create_in_closed_folder = 0 "1 by default, When creating files, sets the path of a file when cursor is on a closed folder to the parent folder when 0, and inside the folder when 1.
" let g:nvim_tree_refresh_wait = 500 "1000 by default, control how often the tree can be refreshed, 1000 means the tree can be refresh once per 1000ms.

" Dictionary of buffer option names mapped to a list of option values that
" indicates to the window picker that the buffer's window should not be
" selectable.
let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1, 'readme.md': 1} " List of filenames that gets highlighted with NvimTreeSpecialFile
let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 1,
    \ 'files': 1,
    \ 'folder_arrows': 1,
    \ }
"If 0, do not show the icons for one of 'git' 'folder' and 'files'
"1 by default, notice that if 'files' is 1, it will only display
"if nvim-web-devicons is installed and on your runtimepath.
"if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
"but this will not work when you set indent_markers (because of UI conflict)

" default will show icon by default if no icon is provided
" default shows no icon by default
let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★",
    \   'deleted': "",
    \   'ignored': "◌"
    \   },
    \ 'folder': {
    \   'arrow_open': "",
    \   'arrow_closed': "",
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   },
    \   'lsp': {
    \     'hint': "",
    \     'info': "",
    \     'warning': "",
    \     'error': "",
    \   }
    \ }

" set termguicolors " this variable must be enabled for colors to be applied properly

" a list of groups can be found at `:help nvim_tree_highlight`
" highlight NvimTreeFolderIcon guibg=blue

noremap <silent><C-n> :NvimTreeToggle<CR>
nnoremap <silent><leader>v :NvimTreeFindFile<cr>
let g:which_key_map.v = 'NvimTreeFindFile'

" starify，seesion关闭时执行操作
if exists("g:startify_session_before_save")
  let g:startify_session_before_save +=  ['silent! NvimTreeClose']
endif

" 自动打开侧边栏
if exists("g:startify_session_savecmds")
  " let g:startify_session_savecmds += ["silent! NvimTreeOpen"]
endif



lua << EOF
    local tree_cb = require'nvim-tree.config'.nvim_tree_callback
    -- following options are the default
    require'nvim-tree'.setup {
        -- disables netrw completely
        disable_netrw       = true,
        -- hijack netrw window on startup
        hijack_netrw        = true,
        -- open the tree when running this setup function
        open_on_setup       = false,
        -- will not open on setup if the filetype is in this list
        ignore_ft_on_setup  = {},
        -- closes neovim automatically when the tree is the last **WINDOW** in the view
        auto_close          = false,
        -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
        open_on_tab         = false,
        -- hijacks new directory buffers when they are opened.
        update_to_buf_dir   = {
            enable = true,
            auto_open = true,
        },
        -- hijack the cursor in the tree to put it at the start of the filename
        hijack_cursor       = false,
        -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
        update_cwd          = true,
        -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
        update_focused_file = {
            -- enables the feature
            enable      = true,
            -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
            -- only relevant when `update_focused_file.enable` is true
            update_cwd  = false,
            -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
            -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
            ignore_list = {}
        },
        -- configuration options for the system open command (`s` in the tree by default)
        system_open = {
            -- the command to run this, leaving nil should work in most cases
            cmd  = nil,  -- windows default is cmd \c start
            -- the command arguments as a list
            args = {}
        },
        filters = {
            -- hides files and folders starting with a dot `.`
            dotfiles = false,
            custom = {}
        },
        git = {
          ignore = false,
        },
        view = {
            -- width of the window, can be either a number (columns) or a string in `%`
            width = 35,
            -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
            side = 'left',
            -- if true the tree will resize itself after opening a file
            auto_resize = false,
            mappings = {
                -- custom only false will merge the list with the default mappings
                -- if true, it will only use your list to set the mappings
                custom_only = false,
                -- list of mappings to set on the tree manually
                list = {
                          { key = {"O"},                          action = "edit" },
                          { key = {"<CR>","o","l"},               action = "edit_no_picker" },
                          { key = "<C-e>",                        action = "edit_in_place" },
                          -- { key = {"<C-]>"},                      action = "cd" },
                          { key = "<C-v>",                        action = "vsplit" },
                          { key = "<C-s>",                        action = "split" },
                          { key = "t",                            action = "tabnew" },
                          { key = "<",                            action = "prev_sibling" },
                          { key = ">",                            action = "next_sibling" },
                          { key = "p",                            action = "parent_node" },
                          { key = {"h","x"},                      action = "close_node" },
                          { key = "<Tab>",                        action = "preview" },
                          { key = "K",                            action = "first_sibling" },
                          { key = "J",                            action = "last_sibling" },
                          { key = "I",                            action = "toggle_git_ignored" },
                          { key = ".",                            action = "toggle_dotfiles" },
                          { key = "r",                            action = "refresh" },
                          { key = "a",                            action = "create" },
                          { key = "D",                            action = "trash" },
                          { key = "<C-r>",                        action = "full_rename" },
                          { key = "R",                            action = "rename" },
                          { key = "X",                            action = "cut" },
                          { key = "C",                            action = "copy" },
                          { key = "P",                            action = "paste" },
                          { key = "D",                            action = "remove" },
                          { key = "y",                            action = "copy_name" },
                          { key = "Y",                            action = "copy_path" },
                          { key = "gy",                           action = "copy_absolute_path" },
                          { key = "[c",                           action = "prev_git_item" },
                          { key = "]c",                           action = "next_git_item" },
                          { key = "-",                            action = "dir_up" },
                          { key = {"s","S"},                      action = "system_open" },
                          { key = "q",                            action = "close" },
                          { key = "?",                            action = "toggle_help" },
                          { key = "W",                            action = "collapse_all" },
                          -- { key = "S",                            action = "search_node" },
                          { key = "<C-k>",                        action = "toggle_file_info" },
                          -- { key = ".",                            action = "run_file_command" }
                }
            }
        }
    }
EOF

endfunction
