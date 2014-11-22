au BufNewFile,BufRead *.spider setf spider

fun! s:SelectSpider()
  if getline(1) =~# '^#!.*/bin/env\s\+spider\>'
    set ft=spider
  endif
endfun
au BufNewFile,BufRead * call s:SelectSpider()
