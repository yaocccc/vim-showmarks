hi Marks ctermfg=80
let s:mark_ns_id = get(g:, 'mark_ns_id', 9898)
let s:mark_priority = get(g:, 'mark_priority', 999)
let s:enabled_marks = get(g:, 'enabled_marks', '[a-zA-Z]')

func! s:showMarks(...)
    call sign_unplace('*', {'id': s:mark_ns_id})
    let bufnr = bufnr()
    if bufname() == "" || !buflisted(bufnr) | return | endif
    redir => cout
    silent marks
    redir END
    let list = sort(filter(split(cout, "\n")[1:], 'v:val[1] =~# "' . s:enabled_marks . '"'))
    let marksByLnum = {}
    for line in list
        let items=filter(split(line, " "), 'v:val != ""') + ['']
        let [text, lnum, col, fileortext] = items[0:3]
        if filereadable(fileortext) | continue | endif
        let marksOflnum = get(marksByLnum, lnum, [])
        let marksOflnum = marksOflnum + [text]
        let marksByLnum[lnum] = marksOflnum
    endfor
    for lnum in keys(marksByLnum)
        let text = join(marksByLnum[lnum], '')
        if len(text) > 2 | let text = marksByLnum[lnum][0] . '…' | endif
        call sign_define('mark_' . text, {'text': text, 'texthl': 'Marks'})
        call sign_place(s:mark_ns_id, '', 'mark_' . text, bufnr, {'lnum': lnum, 'priority': s:mark_priority})
    endfor
endf

noremap <unique> <script> \sm m
noremap <silent> m :exe 'norm \sm'.nr2char(getchar())<bar>call <SID>showMarks()<CR>
au WinEnter,BufWinEnter,CursorHold * call <SID>showMarks()
