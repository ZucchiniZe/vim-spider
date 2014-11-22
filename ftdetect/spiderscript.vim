au BufNewFile,BufRead *.spider setf spiderscript

fun! s:SelectSpiderscript()
  if getline(1) =~# '^#!.*/bin/env\s\+spider\>'
    set ft=spiderscript
  endif
endfun
au BufNewFile,BufRead * call s:SelectSpiderscript()
