set filetype=shy
set commentstring=#%s
" set foldmethod=indent

set foldmethod=marker
set foldmarker={,}


syntax match Comment	    "#.*$"
syntax match Comment	    "\"[^\"]*\""

highlight shyString     ctermfg=magenta
syntax region shyString	start="`" end="`"
syntax match shyString	    "\`[^\`]*\`"
syntax match shyString	    "false"
syntax match shyString	    "true"

highlight shyContext    ctermfg=red
syntax match shyContext "\~[a-z\.]\+"

highlight shyCommand    ctermfg=green
syntax match shyCommand "^\t*[a-zA-Z0-9:._]\+"

highlight shyConfig    ctermfg=yellow
syntax match shyConfig "^    config"


highlight shyTitle    ctermbg=darkred ctermfg=white
highlight shySection    ctermbg=darkgreen ctermfg=white
syntax match shyTitle "^title"
syntax match shyTitle "^chapter"
syntax match shySection "^section"
