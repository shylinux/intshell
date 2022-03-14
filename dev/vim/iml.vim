syntax match Comment "#.*$"
syntax match Comment "\"[^\"]*\""

highlight shyRiver    ctermfg=red
syntax match shyRiver "^[a-zA-Z0-9.]\+"

highlight shyStorm    ctermfg=yellow
syntax match shyStorm "^	[a-zA-Z0-9:._]\+"

highlight shyCommand    ctermfg=green
syntax match shyCommand "^		[a-zA-Z0-9:._/-]\+"

highlight shyArgs    ctermfg=cyan
syntax match shyArgs "name"
syntax match shyArgs "args"

