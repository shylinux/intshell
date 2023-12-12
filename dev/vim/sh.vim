set foldmethod=marker
set foldmarker={,}

highlight ishKey    ctermfg=yellow
highlight ishFunc    ctermfg=cyan

syntax match ishKey "make"
syntax match ishKey "require"
syntax match ishKey "request"
syntax match ishFunc "ish_miss_prepare"
syntax match ishFunc "ish_miss_make"
syntax match ishFunc "ish_miss_serve"

syntax match ishKey "local"
syntax match ishKey "white"

