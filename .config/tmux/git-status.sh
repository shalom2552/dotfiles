#!/usr/bin/env sh
# tmux status-bar git segment: branch + dirty count + ahead/behind
cd "$1" 2>/dev/null || exit 0

out=$(git --no-optional-locks status --porcelain --branch 2>/dev/null) || exit 0
[ -n "$out" ] || exit 0

header=$(printf '%s\n' "$out" | head -1)
branch=$(printf '%s' "$header" | sed 's/^## //; s/\.\.\..*//; s/^No commits yet on //; s/^HEAD (no branch)$/detached/')
ahead=$(printf '%s' "$header" | sed -n 's/.*ahead \([0-9]*\).*/\1/p')
behind=$(printf '%s' "$header" | sed -n 's/.*behind \([0-9]*\).*/\1/p')
count=$(printf '%s\n' "$out" | tail -n +2 | grep -c .)

flags=""
[ "$count" -gt 0 ] && flags=" *"
[ -n "$ahead" ] && flags="$flags ↑$ahead"
[ -n "$behind" ] && flags="$flags ↓$behind"

if [ "$count" -gt 0 ]; then c=yellow; else c=magenta; fi

printf '#[fg=%s,bg=default,nobold]#[fg=black,bg=%s,bold]  %s%s#[fg=%s,bg=default,nobold]' \
  "$c" "$c" "$branch" "$flags" "$c"
