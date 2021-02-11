" Vim Serenade
" https://github.com/b4skyx/serenade
" Using sainnhe/forest-night as template

function! serenade#get_configuration() "{{{
  return {
        \ 'transparent_background': get(g:, 'serenade_transparent_background', 0),
        \ 'disable_italic_comment': get(g:, 'serenade_disable_italic_comment', 0),
        \ 'enable_italic': get(g:, 'serenade_enable_italic', 0),
        \ 'cursor': get(g:, 'serenade_cursor', 'auto'),
        \ 'menu_selection_background': get(g:, 'serenade_menu_selection_background', 'white'),
        \ 'sign_column_background': get(g:, 'serenade_sign_column_background', 'default'),
        \ 'current_word': get(g:, 'serenade_current_word', get(g:, 'serenade_transparent_background', 0) == 0 ? 'grey background' : 'bold'),
        \ 'lightline_disable_bold': get(g:, 'serenade_lightline_disable_bold', 0),
        \ 'diagnostic_text_highlight': get(g:, 'serenade_diagnostic_text_highlight', 0),
        \ 'diagnostic_line_highlight': get(g:, 'serenade_diagnostic_line_highlight', 0),
        \ 'better_performance': get(g:, 'serenade_better_performance', 0),
        \ }
endfunction "}}}
function! serenade#get_palette() "{{{
  return {
        \ 'bg0':        ['#2A2F33',   '235',  'Black'],
        \ 'bg1':        ['#2E3338',   '236',  'DarkGrey'],
        \ 'bg2':        ['#31363B',   '237',  'DarkGrey'],
        \ 'bg3':        ['#373D41',   '238',  'DarkGrey'],
        \ 'bg4':        ['#3F464B',   '239',  'DarkGrey'],
        \ 'bg_visual':  ['#474F54',   '52',   'DarkRed'],
        \ 'bg_red':     ['#614b51',   '52',   'DarkRed'],
        \ 'bg_green':   ['#474f54',   '22',   'DarkGreen'],
        \ 'bg_blue':    ['#415c6d',   '17',   'DarkBlue'],
        \ 'bg_yellow':  ['#5d5c50',   '136',  'DarkBlue'],
        \ 'fg':         ['#bfddb2',   '223',  'White'],
        \ 'red':        ['#d76e6e',   '167',  'Red'],
        \ 'orange':     ['#e5a46b',   '208',  'Red'],
        \ 'yellow':     ['#c1bf89',   '214',  'Yellow'],
        \ 'green':      ['#ACB765',   '142',  'Green'],
        \ 'aqua':       ['#87c095',   '108',  'Cyan'],
        \ 'blue':       ['#82abbc',   '109',  'Blue'],
        \ 'purple':     ['#d39bb6',   '175',  'Magenta'],
        \ 'grey0':      ['#767b82',   '243',  'DarkGrey'],
        \ 'grey1':      ['#7f868c',   '245',  'Grey'],
        \ 'grey2':      ['#9aa1a8',   '247',  'LightGrey'],
        \ 'none':       ['NONE',      'NONE', 'NONE']
        \ }
endfunction "}}}
function! serenade#highlight(group, fg, bg, ...) "{{{
  execute 'highlight' a:group
        \ 'guifg=' . a:fg[0]
        \ 'guibg=' . a:bg[0]
        \ 'ctermfg=' . a:fg[1]
        \ 'ctermbg=' . a:bg[1]
        \ 'gui=' . (a:0 >= 1 ?
          \ (a:1 ==# 'undercurl' ?
            \ (executable('tmux') && $TMUX !=# '' ?
              \ 'underline' :
              \ 'undercurl') :
            \ a:1) :
          \ 'NONE')
        \ 'cterm=' . (a:0 >= 1 ?
          \ (a:1 ==# 'undercurl' ?
            \ 'underline' :
            \ a:1) :
          \ 'NONE')
        \ 'guisp=' . (a:0 >= 2 ?
          \ a:2[0] :
          \ 'NONE')
endfunction "}}}
function! serenade#ft_gen(path, last_modified, msg) "{{{
  " Generate the `after/ftplugin` directory.
  let full_content = join(readfile(a:path), "\n") " Get the content of `colors/serenade.vim`
  let ft_content = []
  let rootpath = serenade#ft_rootpath(a:path) " Get the path to place the `after/ftplugin` directory.
  call substitute(full_content, '" ft_begin.\{-}ft_end', '\=add(ft_content, submatch(0))', 'g') " Search for 'ft_begin.\{-}ft_end' (non-greedy) and put all the search results into a list.
  for content in ft_content
    let ft_list = []
    call substitute(matchstr(matchstr(content, 'ft_begin:.\{-}{{{'), ':.\{-}{{{'), '\(\w\|-\)\+', '\=add(ft_list, submatch(0))', 'g') " Get the file types. }}}}}}
    for ft in ft_list
      call serenade#ft_write(rootpath, ft, content) " Write the content.
    endfor
  endfor
  call serenade#ft_write(rootpath, 'text', "let g:serenade_last_modified = '" . a:last_modified . "'") " Write the last modified time to `after/ftplugin/text/serenade.vim`
  if a:msg ==# 'update'
    echohl WarningMsg | echom '[serenade] Updated ' . rootpath . '/after/ftplugin' | echohl None
  else
    echohl WarningMsg | echom '[serenade] Generated ' . rootpath . '/after/ftplugin' | echohl None
  endif
endfunction "}}}
function! serenade#ft_write(rootpath, ft, content) "{{{
  " Write the content.
  let ft_path = a:rootpath . '/after/ftplugin/' . a:ft . '/serenade.vim' " The path of a ftplugin file.
  " create a new file if it doesn't exist
  if !filereadable(ft_path)
    call mkdir(a:rootpath . '/after/ftplugin/' . a:ft, 'p')
    call writefile([
          \ "if !exists('g:colors_name') || g:colors_name !=# 'serenade'",
          \ '    finish',
          \ 'endif'
          \ ], ft_path, 'a') " Abort if the current color scheme is not serenade.
    call writefile([
          \ "if index(g:serenade_loaded_file_types, '" . a:ft . "') ==# -1",
          \ "    call add(g:serenade_loaded_file_types, '" . a:ft . "')",
          \ 'else',
          \ '    finish',
          \ 'endif'
          \ ], ft_path, 'a') " Abort if this file type has already been loaded.
  endif
  " If there is something like `call serenade#highlight()`, then add
  " code to initialize the palette and configuration.
  if matchstr(a:content, 'serenade#highlight') !=# ''
    call writefile([
          \ 'let s:configuration = serenade#get_configuration()',
          \ 'let s:palette = serenade#get_palette()'
          \ ], ft_path, 'a')
  endif
  " Append the content.
  call writefile(split(a:content, "\n"), ft_path, 'a')
endfunction "}}}
function! serenade#ft_rootpath(path) "{{{
  " Get the directory where `after/ftplugin` is generated.
  if (matchstr(a:path, '^/usr/share') ==# '') || has('win32') " Return the plugin directory. The `after/ftplugin` directory should never be generated in `/usr/share`, even if you are a root user.
    return fnamemodify(a:path, ':p:h:h')
  else " Use vim home directory.
    if has('nvim')
      return stdpath('config')
    else
      if has('win32') || has ('win64')
        return $VIM . '/vimfiles'
      else
        return $HOME . '/.vim'
      endif
    endif
  endif
endfunction "}}}
function! serenade#ft_newest(path, last_modified) "{{{
  " Determine whether the current ftplugin files are up to date by comparing the last modified time in `colors/serenade.vim` and `after/ftplugin/text/serenade.vim`.
  let rootpath = serenade#ft_rootpath(a:path)
  execute 'source ' . rootpath . '/after/ftplugin/text/serenade.vim'
  return a:last_modified ==# g:serenade_last_modified ? 1 : 0
endfunction "}}}
function! serenade#ft_clean(path, msg) "{{{
  " Clean the `after/ftplugin` directory.
  let rootpath = serenade#ft_rootpath(a:path)
  " Remove `after/ftplugin/**/serenade.vim`.
  let file_list = split(globpath(rootpath, 'after/ftplugin/**/serenade.vim'), "\n")
  for file in file_list
    call delete(file)
  endfor
  " Remove empty directories.
  let dir_list = split(globpath(rootpath, 'after/ftplugin/*'), "\n")
  for dir in dir_list
    if globpath(dir, '*') ==# ''
      call delete(dir, 'd')
    endif
  endfor
  if globpath(rootpath . '/after/ftplugin', '*') ==# ''
    call delete(rootpath . '/after/ftplugin', 'd')
  endif
  if globpath(rootpath . '/after', '*') ==# ''
    call delete(rootpath . '/after', 'd')
  endif
  if a:msg
    echohl WarningMsg | echom '[serenade] Cleaned ' . rootpath . '/after/ftplugin' | echohl None
  endif
endfunction "}}}
function! serenade#ft_exists(path) "{{{
  return filereadable(serenade#ft_rootpath(a:path) . '/after/ftplugin/text/serenade.vim')
endfunction "}}}

" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:
