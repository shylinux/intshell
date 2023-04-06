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

" highlight shyCommand    ctermfg=green
" syntax match shyCommand "^    [a-zA-Z0-9:._]\+"
" syntax match shyCommand "^\t[a-zA-Z0-9:._]\+"
" syntax match shyCommand "^[a-zA-Z0-9:._]\+"

" highlight shyConfig    ctermfg=yellow
" syntax match shyConfig "^    config"


highlight shyTitle    ctermbg=darkred ctermfg=white
highlight shySection    ctermbg=darkgreen ctermfg=white
syntax match shyTitle "^title"
syntax match shyTitle "^chapter"
syntax match shySection "^section"

highlight shyKeyword   ctermfg=yellow
syntax keyword shyKeyword package import const type var
syntax keyword shyKeyword if else
syntax keyword shyKeyword for break continue
syntax keyword shyKeyword switch case default
syntax keyword shyKeyword func defer return
syntax keyword shyKeyword source

highlight shyFunction   ctermfg=green
syntax match shyFunction "info"
syntax match shyFunction "pwd"

