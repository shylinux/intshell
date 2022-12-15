set foldnestmax=3
set foldmethod=syntax
let g:tagbar_ctags_bin = "gotags"

let g:go_updatetime = 300
let g:go_auto_type_info = 1
let g:go_version_warning = 0

let g:go_fmt_autosave = 1
let g:go_imports_autosave = 1

let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1

syntax match Comment "#.*$"
syntax match Comment "\<Name: \"[^\"]*\""
syntax match Comment "\<Help: \"[^\"]*\""

highlight kitType    ctermfg=lightgreen
syntax match kitType "\<Any\>"
syntax match kitType "\<Map\>"
syntax match kitType "\<Maps\>"
syntax match kitType "\<List\>"
syntax match kitType "\<Hash\>"
syntax match kitType "\<Zone\>"
syntax match kitType "\<Handler\>"
syntax match kitType "\<Commands\>"
syntax match kitType "\<Actions\>"
syntax match kitType "\<Configs\>"

highlight kitConst    ctermfg=yellow
syntax match kitConst "\<kit\.[a-z0-9A-Z_.]*"

highlight iceFunc    ctermfg=cyan
syntax match iceFunc "\<ice\.[a-z0-9A-Z_.]*"
syntax match iceFunc "\<msg\.[a-z0-9A-Z_.]*"
syntax match iceFunc "\<m\.[a-z0-9A-Z_.]*"

