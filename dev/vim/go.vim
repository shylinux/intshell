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

