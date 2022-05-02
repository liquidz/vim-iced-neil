let s:save_cpo = &cpo
set cpo&vim

function! s:parse(line) abort
  let k = ''
  let res = {}
  for x in split(a:line, ':\w\+\zs')
    let idx = match(x, ':\w\+')
    if idx == 0
      let k = x
    elseif idx == -1
      let res[k] = trim(x)
    else
      let res[k] = trim(strpart(x, 0, idx))
      let k = trim(strpart(x, idx))
    endif
  endfor

  return res
endfunction

function! s:ver_accept(lib, _, candidate) abort
  call system(printf('neil dep add :lib %s :version %s', a:lib, a:candidate))
  call iced#message#info_str(printf('Added %s %s', a:lib, a:candidate))
  if expand('%') ==# 'deps.edn'
    silent exe 'e'
  endif
endfunction

function! s:lib_accept(_, candidate) abort
  let arr = split(a:candidate, "\t")
  if len(arr) != 2
    return
  endif

  let lib = arr[0]

  call iced#message#info_str(printf('Start to search versions: %s', lib))
  let out = systemlist(printf('neil dep versions :lib %s', lib))
  let out = filter(out, {_, v -> stridx(v, ':lib') == 0})
  let versions = map(out, {_, v -> s:parse(v)})

  let candidates = map(versions, {_, v -> get(v, ':version')})
  return iced#selector({'candidates': candidates, 'accept': funcref('s:ver_accept', [lib])})
endfunction

function! iced_neil#search(kw) abort
  call iced#message#info_str(printf('Start to search libraries: %s', a:kw))

  let out = systemlist(printf('neil dep search "%s"', a:kw))
  let out = filter(out, {_, v -> stridx(v, ':lib') == 0})
  let libs = map(out, {_, v -> s:parse(v)})

  let candidates = map(libs, {_, v -> printf("%s\t%s",
        \ get(v, ':lib'),
        \ (get(v, ':description') ==# 'nil') ? ' ' : get(v, ':description'),
        \ )})
  return iced#selector({'candidates': candidates, 'accept': funcref('s:lib_accept')})
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
