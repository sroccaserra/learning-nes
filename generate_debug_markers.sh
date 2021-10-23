#!/usr/bin/env bash

rg '^sym.*val=' "$1" \
    | cut -d"$(printf '\t')" -f2- \
    | sed -e 's/=/":"/g' -e 's/,/","/g' -e 's/""/"/g' -e 's/$/"/' -e 's/0x//g' \
    | awk '{print "{\""$0"}"}' \
    | jq -r '. | "$\(.val)#\(.name)#"'
