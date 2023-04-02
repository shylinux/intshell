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
syntax match shyKeyword "let"
syntax match shyKeyword "if"
syntax match shyKeyword "else"
syntax match shyKeyword "for"
syntax match shyKeyword "break"
syntax match shyKeyword "continue"
syntax match shyKeyword "switch"
syntax match shyKeyword "case"
syntax match shyKeyword "default"
syntax match shyKeyword "func"
syntax match shyKeyword "return"
syntax match shyKeyword "source"

highlight shyFunction   ctermfg=green
syntax match shyFunction "info"
syntax match shyFunction "pwd"

