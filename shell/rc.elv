# aliases
fn ls { e:ls --color=auto $@ }
fn l { ls -alh $@ }
fn grep { e:grep --color $@ }
fn glog { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all $@ }

# bind
#edit:binding[insert][Alt+Backspace]=$edit:&kill-small-word-left
edit:binding[insert][Ctrl+A]=$edit:&move-dot-sol
edit:binding[insert][Ctrl+E]=$edit:&move-dot-eol
edit:binding[insert][Ctrl+L]={ clear > /dev/tty }
edit:binding[insert][Ctrl+/]=$edit:loc:&start
edit:binding[insert][Alt+Up]={ cd .. }
#edit:binding[navigation][h]=$edit:nav:&left
#edit:binding[navigation][l]=$edit:nav:&right
#edit:binding[navigation][j]=$edit:nav:&down
#edit:binding[navigation][k]=$edit:nav:&up

#E:LANG=en_US.UTF-8
#E:LANGUAGE=en_US.UTF-8
E:LS_COLORS=[(splits &sep="'" (dircolors | head -1))][1]

#edit:completer['']={ e:bash ~/.elvish/get-completion.bash $@args }
#if ==s 'root' `whoami`; then put ' # '; else put ' $ '; fi

edit:prompt={ edit:styled (put "╭─ ") white; edit:styled (tilde-abbr $pwd) "bold;lightyellow"; edit:styled (put " (") gray; edit:styled (put `whoami`) "lightgreen"; edit:styled (put "@") gray; edit:styled (put `hostname`) "lightblue"; edit:styled (put ")") gray; edit:styled (put "\n╰◉ ") white }
edit:rprompt={ edit:styled (put "(") gray; edit:styled (put `date +%H:%M:%S`) "gray"; edit:styled (put ")") gray }

edit:binding[insert][Down]={ }
