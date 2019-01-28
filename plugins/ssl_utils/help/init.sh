#!/bin/sh

PLUGIN_DESCRIPTION="Help for $CLI_MAIN_COMMAND"
PLUGIN_AUTHORS="Greg"
PLUGIN_VERSION="0.0.1"
PLUGIN_NOT_REMOVABLE=1

plugin_help() {
  VIEW=$1
  PREVIEW="DATA=\"$(cat "$VIEW" | sed -e 's/"/\\"/g' | sed -e 's/${\([^}]*\)}/$\1/g')\""
  eval "$PREVIEW"
  echo "$DATA"
}

help() {
  HELP_RC=1
  while [ "$1" ] ; do
    case "$1" in
      "--plugin")
        shift ; HELP_PLUGIN=$1 ;
        shift ;;
      "--exit")
        shift ; HELP_RC=$1
        shift ;;
      "--msg")
        shift ; HELP_MSG=$1
        shift ;;
      *) 
        shift ;;
    esac
  done

  echo "$CLI_MAIN_COMMAND v$CLI_VERSION"
  echo
  echo "Usage: $CLI_MAIN_COMMAND <command> [args]"
  [ "z$HELP_MSG" = "z" ] || echo "$HELP_MSG"

  PLUGIN_HELP_PATH="$CLI_PLUGINS_PATH/$HELP_PLUGIN" 
  PLUGIN_HELP_FILE="$PLUGIN_HELP_PATH/help.txt" 
  if [ -n "$HELP_PLUGIN" ] && [ -d "$PLUGIN_HELP_PATH" ] ; then
    echo 
    if [ -f "$PLUGIN_HELP_FILE" ] ; then
      command "init" "$HELP_PLUGIN"
      plugin_help "$PLUGIN_HELP_FILE"
    else
      echo "No help available for $HELP_PLUGIN"
    fi
  else
    [ -n "$HELP_PLUGIN" ] && echo "Plugin $HELP_PLUGIN not installed!"
    echo 
    command "init" "plugins"

    echo "Available commands:"
    echo
    list_plugins
  fi

  
  exit "$HELP_RC"
}
