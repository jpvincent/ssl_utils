#!/bin/sh

case "$1" in 
  list) 
    echo "Installed plugins:"
    echo
    list_plugins
    ;;
  new)
    shift 
    create_plugin "$@"
    ;;
  search)
    shift
    TERM=$1
    echo "Search for plugins : $TERM"
    ;;
  install)
    shift
    PLUGIN=$1
    echo "Install plugin $PLUGIN"
    ;;
  update)
    shift
    PLUGIN=$1
    echo "Update plugin $PLUGIN"
    ;;
  remove)
    shift
    PLUGIN=$1
    echo "Remove plugin $PLUGIN"
    ;;
  *)
    if [ -z "$1" ] ; then 
      __help --msg "missing sub command" --plugin "$PLUGIN_NAME" --exit 1
    else
      __help --msg "invalid sub command $1" --plugin "$PLUGIN_NAME" --exit 1
    fi
esac
