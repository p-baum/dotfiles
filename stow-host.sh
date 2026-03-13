
#!/usr/bin/env bash

set -e
shopt -s nullglob

HOST_DIR=host-${1:-$HOSTNAME}

[[ -d "$HOST_DIR" ]] || {
    echo "Host directory not found: $HOST_DIR" 1>&2
    exit 1
}

shift || true
args=("$@")

for dir in common "$HOST_DIR"; do
    find "$dir" -mindepth 1 -maxdepth 1 -type d | read || continue
    pushd "$dir" &>/dev/null
    echo "Stowing $dir files..."
    [[ "${#args[@]}" -gt 0 ]] || set -- *
    stow -t "$HOME" "$@"
    popd &>/dev/null
done
 