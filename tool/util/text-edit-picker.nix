{ pkgs }:
with pkgs.lib;
pkgs.writeShellScriptBin "text-edit-picker" ''
  if [ -z "$1" ]
  then
    echo "Usage: $(basename $0) <FILE>"
  fi

  file="$1"

  if [ -z "$EDITOR" ]
  then

    printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
      "1) vim?" \
      "2) nano?" \
      "3) mocro? (Modern and intuitive terminal-based text editor)"
    read -N 1 -e -p "[1][2][3]>:" var

    case "$var" in
      1) ${getExe pkgs.neovim} "$file" ;;
      2) ${getExe pkgs.nano} "$file" ;;
      3) ${getExe pkgs.micro} "$file" ;;
    esac
    
  else
    $EDITOR "$file"
  fi
''
