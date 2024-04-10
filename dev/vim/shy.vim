set filetype=shy
set commentstring=#%s
set foldmethod=indent
" set foldmethod=marker
" set foldmarker={,}

syntax match Comment	    "#.*$"
syntax match Comment	    "\"[^\"]*\""

highlight shyString     ctermfg=magenta
syntax region shyString	start="`" end="`"
syntax match shyString	    "\`[^\`]*\`"
syntax match shyString	    "false"
syntax match shyString	    "true"

highlight shyContext    ctermfg=red
syntax match shyContext "\~[a-z0-9\.]\+"

highlight shyCommand    ctermfg=green
syntax match shyCommand "^\t*[a-zA-Z0-9:._]\+"
syntax match shyCommand "\<header\>"
syntax match shyCommand "\<dream\>"
syntax match shyCommand "\<amap\>"
syntax match shyCommand "\<bmap\>"
syntax match shyCommand "\<tmap\>"

highlight shyAction    ctermfg=cyan
syntax match shyAction "\<default\>"
syntax match shyAction "\<action\>"
syntax match shyAction "\<config\>"
syntax match shyAction "\<create\>"
syntax match shyAction "\<insert\>"
syntax match shyAction "\<modify\>"
syntax match shyAction "\<listen\>"
syntax match shyAction "\<start\>"
syntax match shyAction "\<login\>"
syntax match shyAction "\<white\>"

highlight shyConfig    ctermfg=yellow
syntax match shyConfig "^\tconfig"
syntax match shyConfig "return"
syntax match shyConfig "^\tsource"

highlight shyTitle    ctermbg=darkred ctermfg=white
highlight shySection    ctermbg=darkgreen ctermfg=white
syntax match shyTitle "^title"
syntax match shyTitle "^chapter"
syntax match shySection "^section"
