let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
let TabbyTabNames = "[]"
silent only
silent tabonly
cd ~/MT/repos/talbergs/zashboard
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +1 ./proc/php.sh
badd +206 ~/MT/repos/talbergs/editor/plugins.nix
badd +1 wireframe2.kdl
badd +17 ~/MT/repos/talbergs/zashboard/flake.nix
badd +8 default.nix
badd +21 ~/MT/repos/talbergs/zashboard/main.kdl.nix
argglobal
%argdel
$argadd ./proc/php.sh
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit ./proc/php.sh
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 1resize ' . ((&columns * 240 + 180) / 360)
exe '2resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 2resize ' . ((&columns * 240 + 180) / 360)
exe '3resize ' . ((&lines * 39 + 41) / 82)
exe 'vert 3resize ' . ((&columns * 120 + 180) / 360)
exe '4resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 4resize ' . ((&columns * 119 + 180) / 360)
exe '5resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 5resize ' . ((&columns * 119 + 180) / 360)
exe 'vert 6resize ' . ((&columns * 119 + 180) / 360)
argglobal
balt ~/MT/repos/talbergs/zashboard/proc/default.nix
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 1 - ((0 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 05|
wincmd w
argglobal
if bufexists(fnamemodify("~/MT/repos/talbergs/zashboard/flake.nix", ":p")) | buffer ~/MT/repos/talbergs/zashboard/flake.nix | else | edit ~/MT/repos/talbergs/zashboard/flake.nix | endif
if &buftype ==# 'terminal'
  silent file ~/MT/repos/talbergs/zashboard/flake.nix
endif
balt ~/MT/repos/talbergs/zashboard/proc/default.nix
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 18 - ((12 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 18
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("default.nix", ":p")) | buffer default.nix | else | edit default.nix | endif
if &buftype ==# 'terminal'
  silent file default.nix
endif
balt ~/MT/repos/talbergs/zashboard/flake.nix
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 26 - ((25 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 26
normal! 049|
wincmd w
argglobal
if bufexists(fnamemodify("wireframe2.kdl", ":p")) | buffer wireframe2.kdl | else | edit wireframe2.kdl | endif
if &buftype ==# 'terminal'
  silent file wireframe2.kdl
endif
balt wireframe.kdl
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 2 - ((1 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 025|
wincmd w
argglobal
if bufexists(fnamemodify("~/MT/repos/talbergs/zashboard/main.kdl.nix", ":p")) | buffer ~/MT/repos/talbergs/zashboard/main.kdl.nix | else | edit ~/MT/repos/talbergs/zashboard/main.kdl.nix | endif
if &buftype ==# 'terminal'
  silent file ~/MT/repos/talbergs/zashboard/main.kdl.nix
endif
balt ~/MT/repos/talbergs/zashboard/run.sh
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 14 - ((7 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 14
normal! 07|
wincmd w
argglobal
if bufexists(fnamemodify("~/MT/repos/talbergs/zashboard/main.kdl.nix", ":p")) | buffer ~/MT/repos/talbergs/zashboard/main.kdl.nix | else | edit ~/MT/repos/talbergs/zashboard/main.kdl.nix | endif
if &buftype ==# 'terminal'
  silent file ~/MT/repos/talbergs/zashboard/main.kdl.nix
endif
balt ./proc/php.sh
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 21 - ((20 * winheight(0) + 39) / 78)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 21
normal! 040|
wincmd w
6wincmd w
exe '1resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 1resize ' . ((&columns * 240 + 180) / 360)
exe '2resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 2resize ' . ((&columns * 240 + 180) / 360)
exe '3resize ' . ((&lines * 39 + 41) / 82)
exe 'vert 3resize ' . ((&columns * 120 + 180) / 360)
exe '4resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 4resize ' . ((&columns * 119 + 180) / 360)
exe '5resize ' . ((&lines * 19 + 41) / 82)
exe 'vert 5resize ' . ((&columns * 119 + 180) / 360)
exe 'vert 6resize ' . ((&columns * 119 + 180) / 360)
tabnext
edit ~/MT/repos/talbergs/editor/plugins.nix
argglobal
balt ~/MT/repos/talbergs/editor/flake.nix
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 217 - ((49 * winheight(0) + 39) / 78)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 217
normal! 019|
tabnext 1
set stal=1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
