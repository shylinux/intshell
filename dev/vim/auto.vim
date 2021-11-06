" 基础函数{{{
" 变量定义
func! ShyDefine(name, value)
	if !exists(a:name) | exec "let " . a:name . " = \"" . a:value . "\"" | endif
endfunc

" 后端通信
call ShyDefine("g:ctx_sid", "")
call ShyDefine("g:ctx_url", (len($ctx_dev) > 1? $ctx_dev: "http://127.0.0.1:9020") . "/code/vim/")
func! ShySend(cmd, arg)
    if has_key(a:arg, "sub") && a:arg["sub"] != "" | let temp = tempname()
        call writefile(split(a:arg["sub"], "\n"), temp, "b") | let a:arg["sub"] = "@" . temp
    endif

    let a:arg["sid"] = g:ctx_sid
    let a:arg["pwd"] = getcwd() | let a:arg["buf"] = bufname("%") | let a:arg["row"] = line(".") | let a:arg["col"] = col(".")
    let args = "" | for k in sort(keys(a:arg)) | let args = args . " -F '" . k . "=" . a:arg[k] . "' " | endfor
    return system("curl -s " . g:ctx_url . a:cmd . args . " 2>/dev/null")
endfunc

func! ShyLogin()
    let g:ctx_sid = ShySend("sess", {"username": $USER, "hostname": hostname(), "pid": getpid()})
endfunc
func! ShyLogout()
    call ShySend("sess", {"cmds": "logout"}) | let g:ctx_sid = ""
endfunc
" }}}
" 功能函数{{{
" 数据同步
func! ShySync(target)
    if bufname("%") == "ControlP" | return | end

    if a:target == "read" || a:target == "write"
        call ShySend("sync", {"cmds": a:target, "arg": expand("<afile>")})
    elseif a:target == "insert"
        call ShySend("sync", {"cmds": a:target, "sub": getreg(".")})
    elseif a:target == "exec"
        call ShySend("sync", {"cmds": a:target, "arg": getcmdline()})
    else
        let cmd = {"bufs": "buffers", "regs": "registers", "marks": "marks", "tags": "tags", "fixs": "clist"}
        call ShySend("sync", {"cmds": a:target, "sub": execute(cmd[a:target])})
    endif
endfunc

" 输入补全
func! ShyInput(code)
    return split(ShySend("input", {"cmds": a:code, "pre": getline("."), "row": line("."), "col": col(".")}), "\n")
endfunc
func! ShyComplete(firststart, base)
    if a:firststart | let line = getline('.') | let start = col('.') - 1
        " 命令位置
        if match(line, '\s*ice ') >= 0 | return match(line, "ice ") | endif
        " 符号位置
        if line[start-1] !~ '\a' | return start - 1 | end
        " 单词位置
        while start > 0 && line[start - 1] =~ '\a' | let start -= 1 | endwhile
        return start
    endif

    " 符号转换
    if a:base == ":" | return ["：", ":"] | end
    if a:base == ";" | return ["；", ";"] | end
    if a:base == "," | return ["，", ","] | end
    if a:base == "." | return ["。", "."] | end
    if a:base == "\\" | return ["、", "\\"] | end

    " 单词转换
    let list = ShyInput(a:base)
    if len(list) > 0  && list[0] == "func"
        let res = [] | for i in range(1, len(list)-1, 2)
            let res = res + [ { "word": list[i], "info": list[i+1] } ]
        endfor
        return res
    endif
    return list
endfunc
set completefunc=ShyComplete

" 收藏列表
call ShyDefine("g:favor_name", "")
func! ShyFavor()
    let zone_list = ["add zone"] + split(ShySend("favor", {"cmds": "select"}), "\n")
    let zone_show = [] | for i in range(0, len(zone_list)-1)
        let zone_show = zone_show + [printf("%d. %s", i, zone_list[i])]
    endfor

    if len(zone_list) > 1
        let index = inputlist(zone_show) | let zone = zone_list[index]
        if index == 0 | let zone = input("zone: ", "数据结构") | end
    else
        let zone = input("zone: ", "数据结构")
    endif

    let g:favor_name = input("name: ", g:favor_name)
    call ShySend("favor", {"cmds": "insert", "zone": zone, "type": "file", "name": g:favor_name, "text": getline("."), "file": bufname("%"), "line": getpos(".")[1]})
endfunc
func! ShyFavors()
    let zone_list = split(ShySend("favor", {"cmds": "select"}), "\n")
    let zone_show = [] | for i in range(0, len(zone_list)-1)
        let zone_show = zone_show + [printf("%d. %s", i, zone_list[i])]
    endfor
    let index = inputlist(zone_show) | let zone = zone_list[index]

    let res = split(ShySend("favor", {"zone": zone}), "\n")
    let page = "" | let name = ""
    for i in range(0, len(res)-1, 2)
        if res[i] != page
            if name != "" | lexpr name | lopen | let name = "" | endif
            execute exists(":TabooOpen")? "TabooOpen " . res[i]: "tabnew"
        endif
        let page = res[i] | let name .= res[i+1] . "\n"
    endfor
    if name != "" | lexpr name | let name = "" | endif

    let view = inputlist(["列表", "默认", "垂直", "水平"])
    for i in range(0, len(res)-1, 2) | if i < 5
        if l:view == 4 | split | lnext | elseif l:view == 3 | vsplit | lnext | endif
    endif | endfor
    botright lopen | if l:view  == 1 | only | endif
endfunc

" 文件搜索
call ShyDefine("g:grep_dir", "./")
func! ShyGrep(word)
    let g:grep_dir = input("dir: ", g:grep_dir, "file")
    silent execute "grep --exclude-dir='.git'  --exclude='*.swo'  --exclude='*.swp' --exclude='*.tags' -rn '\\<" . input("word: ", a:word) . "\\>' " . g:grep_dir
    copen
endfunc
func! ShyTags(pattern, flags, info)
    let line = getline(".")
    let end = col(".") | while end > 0 && line[end] =~ '\w' | let end -= 1 | endwhile
    let begin = end - 1 | while begin > 0 && line[begin] =~ '\w' | let begin -= 1 | endwhile

    let tags_list = split(ShySend("tags", {"module": line[begin+1:end-1], "pre": getline("."), "pattern": a:pattern}), "\n")
    echo tags_list
    let list = [] | if len(tags_list) == 0 | return list | endif
    echo tags_list
    for i in range(0, len(tags_list)-1, 3)
        let list = list + [ { "name": tags_list[i], "filename": tags_list[i+1], "cmd": tags_list[i+2] } ]
    endfor
    return list
endfunc
" }}}
" 事件回调{{{
call ShyLogin()
autocmd! BufReadPost * call ShySync("read")
autocmd! BufWritePre * call ShySync("write")
autocmd! InsertLeave * call ShySync("insert")
autocmd! CmdlineLeave * call ShySync("exec")
autocmd! VimLeavePre * call ShyLogout()

autocmd BufNewFile,BufReadPost *.js set tagfunc=ShyTags
"}}}
" 按键映射{{{
nnoremap <C-G><C-G> :call ShyGrep(expand("<cword>"))<CR>
nnoremap <C-G><C-F> :call ShyFavor()<CR>
nnoremap <C-G>f :call ShyFavors()<CR>
inoremap <C-K> <C-X><C-U>
"}}}

