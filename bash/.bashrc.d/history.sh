#!/usr/bin/env bash

# history format
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "

# command history limit
export HISTFILESIZE=10000                            # HISTFILE limit
export HISTSIZE=1000                                 # shell session history limit
export HISTIGNORE="&:[ ]*:exit:clear:ls:pwd:nvim:sp" # ignore command pattern, separated by :

# history append
shopt -s histappend

# realtime update history file
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

