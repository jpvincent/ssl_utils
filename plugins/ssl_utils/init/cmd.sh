#!/bin/sh

PRINT=0
[ "$1" = "-" ] && PRINT=1

USER_SHELL="$(basename "$SHELL")"

if [ "$PRINT" = "0" ] ; then
  case "$USER_SHELL" in
    bash)
      if [ -f "${HOME}/.bashrc" ] && [ ! -f "${HOME}/.bash_profile" ]; then
        profile="$HOME/.bashrc"
      else
        profile="$HOME/.bash_profile"
      fi
      ;;
    zsh )
      profile="$HOME/.zshrc"
      ;;
    ksh )
      profile="$HOME/.profile"
      ;;
    fish )
      profile="$HOME/.config/fish/config.fish"
      ;;
    * )
      profile='your profile'
      ;;
  esac

  { echo "# Load $CLI_MAIN_COMMAND automatically by appending"
    echo "# the following to ${profile}:"
    echo "eval \"\$($CLI_ROOT_PATH/$CLI_MAIN_COMMAND init -)\""
    echo
  } >&2

  exit 1
fi

echo "export PATH=\$PATH:$CLI_ROOT_PATH"
