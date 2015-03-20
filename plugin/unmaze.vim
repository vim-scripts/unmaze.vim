" Tool to find out which macro conditions need to be met for the current line
"   to be used after preprocessing. (C, C++)
" Creator: Alicia, http://ion.nu/
" Last Change: 2014 Oct 03

function! FindIfMacros()
  let s:conditions=[]
  for s:lnum in range(1,line('.')) " Check lines from the start until the current line
    let s:line=getline(s:lnum)
    if match(s:line, '^[ \t]*#')>-1 " Only care about macro lines
      let s:op=matchstr(s:line, '[^ \t#].*')
      " Remove potential comments from s:op, e.g. '#ifdef SOMETHING // stuff', would get messy with #elif
      let s:op=substitute(s:op, '[ \t]*\(//\|/\*\).*', '', '')
      if match(s:op, '^if')>-1
        call insert(s:conditions, s:op)
      elseif match(s:op, '^else')>-1 " Negate the last condition
        if match(s:conditions[0], '^ifdef[ \t]')>-1
          let s:conditions[0]=substitute(s:conditions[0], '^ifdef[ \t]', 'ifndef ', '')
        elseif match(s:conditions[0], '^ifndef[ \t]')>-1
          let s:conditions[0]=substitute(s:conditions[0], '^ifndef[ \t]', 'ifdef ', '')
        elseif match(s:conditions[0], '^if[ \t]')>-1
          let s:conditions[0]=substitute(s:conditions[0], '[ \t]\(.*\)', ' !(\1)', '')
        endif
      elseif match(s:op, '^elif[ \t]')>-1 " Negate and add to
        let s:op=substitute(s:op, '^elif[ \t]*', '', '')
        if match(s:conditions[0], '^ifdef[ \t]')>-1
          let s:conditions[0]=substitute(s:conditions[0], '^ifdef[ \t]\([^/]*\)', 'if !defined \1 \&\& '.s:op, '')
        elseif match(s:conditions[0], '^ifndef[ \t]')>-1
          let s:conditions[0]=substitute(s:conditions[0], '^ifndef[ \t]\([^/]*\)', 'if defined \1 \&\& '.s:op, '')
        elseif match(s:conditions[0], '^if[ \t]')>-1
          let s:conditions[0]=substitute(s:conditions[0], '[ \t]\(.*\)', ' !(\1) \&\& '.s:op, '')
        endif
      elseif match(s:op, '^endif')>-1
        call remove(s:conditions, 0)
      endif
    endif
  endfor
  " Display the results
  for s:condition in reverse(s:conditions)
    echo '#'.s:condition
  endfor
endfunction
nmap M :call FindIfMacros()<CR>
