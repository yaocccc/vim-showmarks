hi Marks ctermfg=80
let s:mark_ns_id = get(g:, 'mark_ns_id', 9898)
let s:mark_priority = get(g:, 'mark_priority', 999)

func! s:parseMarkOut(mark)
    let sign = substitute(a:mark, '\v\s+(.)\s+(\d+)\s+(\d+)\s+(.*)$', '\1', 'g')
    let lnum = substitute(a:mark, '\v\s+(.)\s+(\d+)\s+(\d+)\s+(.*)$', '\2', 'g')
    let col = substitute(a:mark, '\v\s+(.)\s+(\d+)\s+(\d+)\s+(.*)$', '\3', 'g')
    let fileortext = substitute(a:mark, '\v\s+(.)\s+(\d+)\s+(\d+)\s+(.*)$', '\4', 'g')
    return [sign, lnum, col, fileortext]
endf

func! s:getMarks()
    redir => cout
        silent marks
    redir END
    let marksByLnum = {}
    let list = sort(filter(split(cout, "\n")[1:], 'v:val[1] =~# "[A-Za-z]"'))
    for line in list
        let [sign, lnum, col, fileortext] = s:parseMarkOut(line)
        if sign =~# "[A-Z]" && !(getline(lnum) ==# fileortext) | continue | endif
        let marksOflnum = get(marksByLnum, lnum, [])
        let marksOflnum = marksOflnum + [sign]
        let marksByLnum[lnum] = marksOflnum
    endfor
    return marksByLnum
endf

func! s:showMarks(...)
    call sign_unplace('*', {'id': s:mark_ns_id})
    let bufnr = bufnr()
    if bufname() == "" || !buflisted(bufnr) | return | endif
    let marksByLnum = s:getMarks()
    for lnum in keys(marksByLnum)
        let text = join(marksByLnum[lnum], '')
        if len(text) > 2 | let text = marksByLnum[lnum][0] . '…' | endif
        call sign_define('mark_' . text, {'text': text, 'texthl': 'Marks'})
        call sign_place(s:mark_ns_id, '', 'mark_' . text, bufnr, {'lnum': lnum, 'priority': s:mark_priority})
    endfor
endf

noremap <unique> <script> \sm m
noremap <silent> m :exe 'norm \sm'.nr2char(getchar())<bar>call <SID>showMarks()<CR>
au VimEnter,WinEnter,BufWinEnter,CursorHold * call <SID>showMarks()
