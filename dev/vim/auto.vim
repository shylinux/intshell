" 基础函数{{{
func! DevDefine(name, value)
	if !exists(a:name) | exec "let" a:name "=" "\"".a:value."\"" | endif
endfunc
call DevDefine("s:ctx_sid", $ish_sys_dev_sid)
call DevDefine("s:ctx_url", (len($ctx_ops) > 1? $ctx_ops: "http://127.0.0.1:9020") . "/code/vim/")
func! DevSend(cmd, arg)
    if has_key(a:arg, "sub") && a:arg["sub"] != "" | let temp = tempname()
        call writefile(split(a:arg["sub"], "\n"), temp, "b") | let a:arg["sub"] = "@" . temp
    endif
    let a:arg["sid"] = s:ctx_sid
    let a:arg["pwd"] = getcwd() | let a:arg["buf"] = bufname("%") | let a:arg["row"] = line(".") | let a:arg["col"] = col(".")
    let args = "" | for k in sort(keys(a:arg)) | let args = args . " -F '" . k . "=" .  substitute(a:arg[k], "'", "\\\"", "g") . "' " | endfor
    return system("curl -s " . s:ctx_url . a:cmd . args . " 2>/dev/null")
endfunc
func! DevSends(cmd, arg)
	return split(trim(DevSend(a:cmd, a:arg)), "\n")
endfunc
func! DevInput(pre, def)
	return input(a:pre, a:def)
endfunc
func! DevInputList(list)
    let show = [] | for i in range(1, len(a:list))
        let show = show + [printf("%d. %s", i, a:list[i-1])]
    endfor
	return a:list[inputlist(show)-1]
endfunc
" }}}
" 功能函数{{{
" 输入补全
func! DevComplete(firststart, base)
	if a:firststart | let line = getline('.') | let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\a' | let start -= 1 | endwhile
		return start
	endif
	let list = DevSends("input", {"cmds": a:base, "pre": getline(".")})
   	if len(list) == 0 || trim(list[0]) != "func" | return list | endif
	let res = [] | for i in range(1, len(list)-1, 2)
		if i+1 < len(list)
			let res = res + [{"word": list[i], "info": list[i+1]}]
		else
			let res = res + [{"word": list[i]}]
		endif
	endfor | return res
endfunc | set completefunc=DevComplete

" 收藏列表
call DevDefine("s:favor_name", "")
call DevDefine("s:favor_zone", "数据结构")
func! DevFavor()
	let zone_list = ["add zone"] + DevSends("favor/action/select", {}) | if len(zone_list) > 1
		let zone = DevInputList(zone_list) | if zone == "add zone" | let zone = DevInput("zone: ", s:favor_zone) | end
	else
		let zone = DevInput("zone: ", s:favor_zone)
	endif | let s:favor_zone = zone | let s:favor_name = DevInput("name: ", s:favor_name)
    echo DevSend("favor/action/insert", {"zone": s:favor_zone, "type": "file", "name": s:favor_name, "text": getline("."), "file": bufname("%"), "line": getpos(".")[1]})
endfunc
func! DevFavors()
	let zone_list = DevSends("favor/action/select", {}) | let zone = DevInputList(zone_list) | let res = DevSends("favor/", {"zone": zone})
	let view = DevInputList(["默认", "列表", "垂直", "水平"])
	let page = "" | let name = "" | for i in range(0, len(res)-1, 2)
		if res[i] != page
		   	silent exec exists(":TabooOpen")? "TabooOpen " . res[i]: "tabnew"
		endif
	   	let page = res[i] | let name .= res[i+1] . "\n"
	endfor
	if name != ""
		lexpr name
		let name = ""
		lopen
	endif
	return
	for i in range(0, len(res)-1, 2)
		if i > 5 | continue | endif
		if view == "水平"
			split
			" if i < 2 | lnext | endif
		elseif view == "垂直"
			vsplit
			" if i < 2 | lnext | endif
		endif
   	endfor
   	botright lopen
   	if view  == "列表"
	   	only
   	endif
endfunc

" 文件搜索
call DevDefine("s:grep_dir", "./")
func! DevGrep(word)
    let s:grep_dir = input("dir: ", s:grep_dir, "file")
	silent exec "grep -rn --exclude='*/.git/*' '\\<" . input("word: ", a:word) . "\\>' " . s:grep_dir | copen
	" silent exec "grep --exclude-dir='.git' --exclude='*.swo'  --exclude='*.swp' --exclude='*.tags' -rn '\\<" . input("word: ", a:word) . "\\>' " . s:grep_dir | copen
endfunc
func! DevTags(pattern)
    let line = getline(".")
    let end = col(".") | while end > 0 && line[end] =~ '\w' | let end -= 1 | endwhile
    let begin = end - 1 | while begin > 0 && line[begin] =~ '\w' | let begin -= 1 | endwhile
    let ends = col(".") | while ends < len(line)+1 && line[ends] =~ '\w' | let ends += 1 | endwhile
	let back = bufname("%")
	let list = DevSends("tags/", {"zone": line[begin+1:end-1], "name": line[end+1:ends-1], "pre": getline(".")})
	echo list
	for file in list 
		exec "vi +1 " . file
		if search('\<'.line[end+1:ends-1].': func') > 0 
			return
		endif
		if search('\<'.line[end+1:ends-1].': shy') > 0 
			return
		endif
	endfor
	exec "open ". back
endfunc
" 数据同步
func! DevSync(target)
    if bufname("%") == "ControlP" | return | end

    if a:target == "read" || a:target == "write"
        call DevSend("sync", {"cmds": a:target, "arg": expand("<afile>")})
    elseif a:target == "insert"
        call DevSend("sync", {"cmds": a:target, "sub": getreg(".")})
    elseif a:target == "exec"
        call DevSend("sync", {"cmds": a:target, "arg": getcmdline()})
    else
        let cmd = {"bufs": "buffers", "regs": "registers", "marks": "marks", "tags": "tags", "fixs": "clist"}
        call DevSend("sync", {"cmds": a:target, "sub": execute(cmd[a:target])})
    endif
endfunc
" }}}
" 事件回调{{{
" autocmd! BufReadPost * call DevSync("read")
" autocmd! BufWritePre * call DevSync("write")
" autocmd! InsertLeave * call DevSync("insert")
" autocmd! CmdlineLeave * call DevSync("exec")
"}}}
" 按键映射{{{
nnoremap <C-G><C-G> :call DevGrep(expand("<cword>"))<CR>
nnoremap <C-G><C-F> :call DevFavor()<CR>
nnoremap <C-G>f :call DevFavors()<CR>
inoremap <C-K> <C-X><C-U>
"}}}

func! DevTagsSource()
	let ext = expand("%:e") | if ext == "go"
		GoDef
	elseif ext == "js"
		call DevTags("")
	else
		exec DevSend("tags/action/source", {"pre": getline(".")})
	endif
endfunc
func! DevTagsServer()
	let ext = expand("%:e") | if ext == "go"
		GoImplements
	else
		exec DevSend("tags/action/server", {"pre": getline(".")})
	endif
endfunc
nnoremap <C-]> :call DevTagsSource()<CR>
nnoremap <C-[> :call DevTagsServer()<CR>
