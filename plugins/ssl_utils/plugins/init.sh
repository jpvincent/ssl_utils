#!/bin/sh

PLUGIN_DESCRIPTION="Manage plugins for the $CLI_MAIN_COMMAND CLI"
PLUGIN_AUTHORS="Greg"
PLUGIN_VERSION="0.0.1"
PLUGIN_NOT_REMOVABLE=1

list_plugins() {
  PLUGINS_INDEX=0
  MAX_SIZE=0
  for PLUGIN in $CLI_PLUGINS_PATH/* ; do
    if [ -d "$PLUGIN" ] ; then
      PLUGIN_NAME=$(echo "$PLUGIN" | sed -e "s/$(escape "$CLI_PLUGINS_PATH")\///")
      PLUGIN_DESCRIPTION="Missing description"
      PLUGIN_AUTHORS="Unknow"
      PLUGIN_VERSION="unknow"
      PLUGIN_HIDE="0"

      if [ -f "$PLUGIN/init.sh" ] ; then
        . "$PLUGIN/init.sh"
      fi

      if [ "$PLUGIN_HIDE" = "0" ] ; then
        SIZE=$(printf "%s" "$PLUGIN_NAME" | wc -c)
        eval PLUGIN_SIZE_${PLUGINS_INDEX}=\$SIZE
        [ "$MAX_SIZE" -lt "$SIZE" ] && MAX_SIZE=$SIZE

        for T in NAME DESCRIPTION AUTHORS ; do
          eval PLUGIN_${T}_${PLUGINS_INDEX}=\$PLUGIN_${T}
          eval PLUGIN_${T}_${PLUGINS_INDEX}=\$PLUGIN_${T}
          eval PLUGIN_${T}_${PLUGINS_INDEX}=\$PLUGIN_${T}
        done

        PLUGINS_INDEX=$((PLUGINS_INDEX + 1))
      fi
    fi
  done

  for I in $(seq 0 $((PLUGINS_INDEX - 1))) ; do
    eval SIZE=\$PLUGIN_SIZE_"$I"
    CMP=$((MAX_SIZE - SIZE + 1))
    eval printf "\$PLUGIN_NAME_$I"
    printf "%${CMP}s"
    eval echo " : \$PLUGIN_DESCRIPTION_$I \(by \$PLUGIN_AUTHORS_$I\)"
  done
}

create_plugin() {
  NEW_PLUGIN_VERSION="0.0.1"
  while [ "$1" ] ; do
    case "$1" in
      "--force" | "-f" )
        FORCE=1 ;
        shift 
        ;;
      "--version" | "-v" )
        shift
        NEW_PLUGIN_VERSION=$1
        shift 
        ;;
      "--desc" | "-D" )
        shift
        DESC=1
        while [ "$DESC" = "1" ] ; do
          case "$1" in 
            -*)
              DESC=0
              ;;
            *)
              if [ -n "$1" ] ; then
                NEW_PLUGIN_DESCRIPTION="${NEW_PLUGIN_DESCRIPTION}${1} "
                shift 
              else
                DESC=0
              fi
              ;;
          esac
        done 
        ;;
      "--authors" | "-A" )
        shift
        DESC=1
        while [ "$DESC" = "1" ] ; do
          case "$1" in 
            -*)
              DESC=0
              ;;
            *)
              if [ -n "$1" ] ; then
                NEW_PLUGIN_AUTHORS="${NEW_PLUGIN_AUTHORS}${1} "
                shift 
              else
                DESC=0
              fi
              ;;
          esac
        done 
        ;;
      "--help" | "-h")
        __help --plugin "$PLUGIN_NAME" --exit 0
        shift ;;
      "--")
        shift ;;
      -*)
        __help --plugin "$PLUGIN_NAME" --exit 1 --msg "$1: Invalid option"
        shift ;;
      *)
        NEW_PLUGIN_NAME="$1"
        NEW_PLUGIN_PATH="$CLI_PLUGINS_PATH/$NEW_PLUGIN_NAME"
        shift ;;
    esac
  done

  if [ "z$NEW_PLUGIN_NAME" = "z" ] ; then
    __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Plugin name missing!"
  fi

  if [ -d "$NEW_PLUGIN_PATH" ] && [ "z$FORCE" = "z" ] ; then
    echo "Plugin $NEW_PLUGIN_NAME already exist. Use --force" >&2
    exit 1
  fi

  echo "Create plugin $NEW_PLUGIN_NAME"
  echo "  | Version : $NEW_PLUGIN_VERSION"
  [ -z "$NEW_PLUGIN_DESCRIPTION" ] || echo "  | Description : $NEW_PLUGIN_DESCRIPTION"
  [ -z "$NEW_PLUGIN_AUTHORS" ] || echo "  | Authors : $NEW_PLUGIN_AUTHORS"


  echo " * Create plugin directory $NEW_PLUGIN_PATH"
  mkdir -p "$NEW_PLUGIN_PATH"
  echo " * Create init script"
  {
    echo "#!/bin/sh" 
    echo 
    echo "PLUGIN_VERSION=\"$NEW_PLUGIN_VERSION\""
    [ -z "$NEW_PLUGIN_DESCRIPTION" ] || echo "PLUGIN_DESCRIPTION=\"$NEW_PLUGIN_DESCRIPTION\""
    [ -z "$NEW_PLUGIN_AUTHORS" ] || echo "PLUGIN_AUTHORS=\"$NEW_PLUGIN_AUTHORS\""
  } > "$NEW_PLUGIN_PATH/init.sh"
  echo " * Create command script"
  {
    echo "#!/bin/sh" 
    echo 
    echo "echo \"Plugin \$PLUGIN_NAME\""
    echo "echo"
    echo "echo \"Environment:\""
    echo "echo \"  CLI_ROOT_PATH = \$CLI_ROOT_PATH\""
    echo "echo \"  CLI_MAIN_COMMAND = \$CLI_MAIN_COMMAND\""
    echo "echo \"  CLI_VERSION = \$CLI_VERSION\""
    echo "echo \"  CLI_PLUGINS_PATH = \$CLI_PLUGINS_PATH\""
    echo "echo"
    echo "echo \"Parameter : \$@\""
    echo "echo"
    echo "echo \"Edit the initialization file at \$CLI_PLUGINS_PATH/\$PLUGIN_NAME/init.sh\""
    echo "echo \"Edit the command file at \$CLI_PLUGINS_PATH/\$PLUGIN_NAME/cmd.sh\""
    echo "echo \"Edit the help file at \$CLI_PLUGINS_PATH/\$PLUGIN_NAME/help.txt\""
  } > "$NEW_PLUGIN_PATH/cmd.sh"
  echo " * Create help file"
  {
    echo "\${PLUGIN_NAME} version \${PLUGIN_VERSION} by \${PLUGIN_AUTHORS}"
    echo "\${PLUGIN_DESCRIPTION}."
  } > "$NEW_PLUGIN_PATH/help.txt"
}
