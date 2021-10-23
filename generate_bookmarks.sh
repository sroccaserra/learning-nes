#!/usr/bin/env bash

# Generates fceux bookmarks from compiler symbols

rg '^sym.*val=' "$1".nes.dbg \
    | cut -d"$(printf '\t')" -f2- \
    | cut -d, -f2- \
    | sed -e 's/=/":"/g' -e 's/,/","/g' -e 's/""/"/g' -e 's/$/"/' -e 's/0x//g' \
    | awk '{print "{\""$0"}"}' \
    | jq -r '. | "Bookmark: addr=\(.val)  desc=\"\(.name)\""' > "$1".dbg
