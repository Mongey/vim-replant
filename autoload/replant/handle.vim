fun! replant#handle#quickfix_find_symbol(msgs)
  let qfs = []
  for msg in a:msgs
    if has_key(msg, 'occurrence')
      let occurrence = msg['occurrence']
      let d = {}
      let d.filename = fnamemodify(occurrence.file, ':~:.')
      let d.lnum = occurrence['line-beg']
      let d.col = occurrence['col-beg']
      let d.text = occurrence['match']
      call add(qfs, d)
    elseif has_key(msg, 'error')
      echo msg['error']
      return 0
    endif
  endfor

  call setqflist(qfs)
endf

fun! replant#handle#hotload(cmsg)
  if has_key(a:cmsg, 'dependency')
    echo 'Hotloaded '.a:cmsg.dependency
  endif
  if has_key(a:cmsg, 'error')
    echo a:cmsg.error
  endif
endf

fun! replant#handle#stacktraces(qfs, stacktraces)
  for stacktrace in a:stacktraces
    let d = {}
    let d.lnum = stacktrace['line']
    let d.text = stacktrace['name']


    if has_key(stacktrace, 'file-url') && type(stacktrace['file-url']) == v:t_string
      let file = replant#url_to_vim(stacktrace['file-url'])
      let d.filename = fnamemodify(file, ':~:.')
    else
      let d.text = '['.get(stacktrace, 'file').'] '.d.text
    endif

    let d.text .= ' '.join(map(stacktrace['flags'], {idx, val -> '#'.val}), ' ')
    call add(a:qfs, d)
  endfor
endf

fun! replant#handle#insert_top_level_messages(qfs, errors)
  for e in a:errors
    if has_key(e, 'message')
      let d = {}

      if has_key(e, 'file-url') && type(e['file-url']) == v:t_string
        let d.filename = replant#url_to_vim(e['file-url'])
      endif

      if has_key(e, 'line')
        let d.lnum = e.line
      endif

      if has_key(e, 'column')
        let d.col = e.column
      endif

      let d.text = e.message

      call insert(a:qfs, d)
    endif
  endfor
endf
