let javaScript_fold=1
set foldmethod=marker
set foldmarker={,}

syntax match Comment "\<shy(\"[^\"]*\""
syntax match Comment "\<name: \"[^\"]*\""
syntax match Comment "\<help: \"[^\"]*\""
syntax match Comment "\<Volcanos([^,{ ]*"

highlight canConst    ctermfg=yellow
syntax match canConst "\<can\>"
syntax match canConst "\<sub\>"
syntax match canConst "\<sup\>"
syntax match canConst "\<msg\>"
syntax match canConst "\<res\>"
syntax match canConst "\<target\>"
syntax match canConst "\<kit\>"
syntax match canConst "\<ice\>"

highlight kitConst    ctermfg=yellow
syntax match kitConst "\<kit\.[a-z0-9A-Z_.]*"


highlight msgConst    ctermfg=cyan
syntax match msgConst "\<m\.[a-z0-9A-Z_.]*"
syntax match msgConst "\<msg\.[a-z0-9A-Z_.]*"
syntax match msgConst "\<res\.[a-z0-9A-Z_.]*"
syntax match msgConst "\<can\.[a-z0-9A-Z_]*"
syntax match msgConst "\<sub\.[a-z0-9A-Z_.]*"
syntax match msgConst "\<cb\>"
syntax match msgConst "\<cbs\>"

syntax match canConst "\<can\.base"
syntax match canConst "\<can\.core"
syntax match canConst "\<can\.misc"
syntax match canConst "\<can\.page"
syntax match canConst "\<can\.user"

