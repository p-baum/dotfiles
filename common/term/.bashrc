#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

cold-store() {
  if [[ -z "$2" ]]; then
    echo "Provide SRC[/] and DST"
    return 1
  fi
  rsync --archive --hard-links --sparse --one-file-system --numeric-ids "$1" --itemize-changes --human-readable rsync://pi.lan/"$2"
}

PATH=$HOME/.local/bin:$PATH
export NEXTCLOUD_DIR="/mnt/E/sync/Nextcloud Paul"
. "${NEXTCLOUD_DIR}/.shell"


alias hibernate='/usr/bin/systemctl hibernate'
alias rs='python manage.py runserver'
alias dton='tp-switch pcplug on; sleep 2; wake xdesktop; while ! ping -c 1 xdesktop &>/dev/null; do echo -n .; sleep 1; done; echo " OK"'
alias dtoff='ssh -t xdesktop systemctl poweroff; (sleep 20 && tp-switch pcplug off &>/dev/null) &'
alias update='sudo update'
alias upoff='sudo update && poweroff'
alias btc='vpn-bypass -g -- chromium --app="https://www.binance.com/en/trade/BTC_USDT"'
alias off='update && poweroff'
alias rsynca='rsync --archive --hard-links --sparse --numeric-ids --human-readable --info=progress2 --no-inc-recursive -z'


pdfenc() {
  pdftk "$1" output "${1%.pdf}.enc.pdf" user_pw PROMPT allow AllFeatures
}
google() {
  vpn-bypass /usr/bin/chromium --password-store=gnome --user-data-dir='.config/chromium-vpnbypass' \
    https://www.google.de/search?q=$(echo $@ | tr ' ' '+')
}
alias g=google

# dotdrop ######################
#alias dotdrop='dotdrop -b -p common'
alias dotgit='git -C ~/.config/dotdrop'
#dotsync() {
#  [[ -z "$1" ]] && echo "Provide a commit message: dotsync \"msg\"" 1>&2 && return 1
#  dotgit pull && dotgit add -A && dotgit commit -m "$1" && dotgit push; dotdrop install
#}
#
#rootdotdrop() {(
#  export DOTDROP_CONFIG="$HOME/.config/dotdrop/root-config.yaml"
#  export DOTDROP_PROFILE='root'
#  sudo --preserve-env=DOTDROP_CONFIG,DOTDROP_PROFILE dotdrop -b "$@"
#)}
#alias sudodotdrop=rootdotdrop

github-init() {
  for req in git gh; do
    command -v $req &>/dev/null || \
      { echo "$req not available" 1>&2; return 1; }
  done
  [[ -z "$1" ]] && \
    local repo_name="$(basename "$PWD" | tr -cd '[:alnum:]_-')" || \
    local repo_name="$1"
  git init
  if [[ ! -e README.md ]]; then
    echo -e "# $repo_name\n" > README.md
    local executable="$(find . -path ./.git -prune -o -executable -type f -print -quit)"
    if [[ $? == 0 ]]; then
      echo '```' >> README.md
      $executable -h >> README.md
      echo '```' >> README.md
    fi
  fi
  git add .
  git commit -m "initial"
  gh repo create $repo_name
  local repo_user="$(basename "$(dirname "$(git remote get-url origin)")")"
  git remote set-url origin git@github.com:$repo_user/$repo_name.git
  git push --set-upstream origin master
}

gitea-init() {
  [[ -z "$(ls -A .)" ]] && echo "Add files first!" 1>&2 && return 1
  [[ -z "$1" ]] && \
    local repo_name="$(basename "$PWD" | tr -cd '[:alnum:]_-')" || \
    local repo_name="$1"
  git init
  git remote add origin git@gitea.lan:p-baum/$repo_name.git
  git add .
  git commit -m 'Initial commit'
  git push --set-upstream origin master
}

_trash_path() {
    local real_path="$(realpath "$1")"
    gio list -hna trash::orig-path,trash::deletion-date trash:// | \
        grep "trash::orig-path=$real_path " | \
        sed -e 's/trash::[a-z-]*=/\t/g' | \
        awk -F'\t' '{printf "%s\t%s\n",$6,$1}' | \
        sort -nr | head -n1 | awk -F'\t' '{print $2}' | tr '\\' '/'
}

untrash() {
    [[ -z "$1" ]] && echo "Provide the original path." 1>&2 && return 1
    local trash_path="$(_trash_path "$1")"
    [[ -z "$trash_path" ]] && echo "No trash found for '$1'." 1>&2 && return 1
    mv "$trash_path" "$1"
}

#export PIPENV_VENV_IN_PROJECT=1

#PS1="$(echo -n "$PS1" | sed 's/\\[$>] \?$//')\$(\$DIRENV_PLUGINS/ps1.sh 2>/dev/null)\$ "
PS1="$(echo -n "$PS1" | sed 's/\\[$>] \?$//')\$CUSTOM_PS1\$ "

export PATH="$PATH":"$HOME/.pub-cache/bin"
export CAPACITOR_ANDROID_STUDIO_PATH=/opt/android-studio/bin/studio.sh
