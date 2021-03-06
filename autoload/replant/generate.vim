fun! replant#generate#refresh()
  let msg = {'op': 'refresh'}
  let maybe_before = replant#detect_refresh_before()
  if type(maybe_before) == v:t_string
    let msg.before = maybe_before
  endif
  let maybe_after = replant#detect_refresh_after()
  if type(maybe_after) == v:t_string
    let msg.after = maybe_after
  endif

  return msg
endf

fun! replant#generate#refresh_all()
  let msg = replant#generate#refresh()
  let msg.op = 'refresh-all'
  return msg
endf

fun! replant#generate#find_symbol_under_cursor()
  let symbol = expand('<cword>')
  " Calculate symbol ns
  let info = replant#message#send_collect({'op': 'info', 'symbol': symbol, 'ns': fireplace#ns()})

  if !has_key(info, 'ns')
    echo "Couldn't find namespace for '".symbol."', maybe the namespace hasn't been loaded?"
    return 0
  endif

  let msg = {'op': 'find-symbol',
           \ 'ns': info['ns'],
           \ 'name': expand('<cword>'),
           \ 'file': expand('%:p'),
           \ 'line': line('.'),
           \ 'column': col('.'),
           \ 'serialization-format': 'bencode',
           \ 'ignore-errors': 1}
  return msg
endf

fun! replant#generate#resource_list()
  return {'op': 'resources-list'}
endf

fun! replant#generate#last_stacktrace()
  let msg = {'op': 'stacktrace',
           \ 'session': get(get(fireplace#client(), 'connection', {}), 'session')}

  return msg
endf

fun! replant#generate#test_project(args)
  let opts = a:args

  if get(a:args, 'load?')
    let opts['load?'] = 1
  endif

  let msg = extend({'op': 'test-all'}, opts)

  return msg
endf

fun! replant#generate#test_results_info(msgs)
  " TODO: Refactor the find_test_result_msg out
  let result_msg = replant#handle#find_test_results_msg(a:msgs)
  let status_msg = a:msgs[1]
  let results = get(result_msg, 'results', {})

  let msgs = []

  for [ns, vars] in items(results)
    for [var, assertions] in items(vars)
      " TODO: Filter to only where an assertion didn't pass
      call add(msgs, {'op': 'info', 'ns': 'clojure.core', 'symbol': ns.'/'.var})
    endfor
  endfor

  return msgs
endf

fun! replant#generate#test_stacktrace(ns,var,index)
  return {'op': 'test-stacktrace', 'ns': a:ns, 'var': a:var, 'index': a:index}
endf
