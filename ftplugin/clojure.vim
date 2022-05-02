if exists('g:loaded_iced_neil')
  finish
endif

if !exists('g:vim_iced_version')
      \ || g:vim_iced_version < 30400
  echoe 'iced-multi-session requires vim-iced v3.4.0 or later.'
  finish
endif

let g:loaded_iced_neil = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=1 IcedNeil call iced_neil#search(<q-args>)

if !exists('g:iced#palette')
  let g:iced#palette = {}
endif
call extend(g:iced#palette, {
      \ 'Neil': ':IcedNeil {{name}}',
      \ })

let &cpo = s:save_cpo
unlet s:save_cpo

