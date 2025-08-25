{ pkgs }:
with pkgs.lib;
pkgs.writeShellScriptBin "git-patches" ''
  then="$1"
  now="$2"

  usage() {
    echo "Prints git patches between revisions in format <file>:<line>"
    echo "Usage: $(basename $0) <FROM> <TO>"
    exit 7
  }

  if [ -z "$now" ]
  then usage
  fi

  ${getExe pkgs.git} status 2&> /dev/null
  if (( $? != 0 ))
  then echo "Must be run from git repository." && exit 7
  fi

  patch_to_lines='
  while ($p = trim(fgets(STDIN), " +")) {
     [$start, $len] = explode(",", $p . ",1");
     if ($len == 0) continue;
     $end = $start + $len - 1;
     foreach (range($start, $end) as $lineno) {
       echo $argv[1] . ":" . $lineno . PHP_EOL;
     }
  }
  '

  while read file
  do
    ${getExe pkgs.git} diff -U0 "$then".."$now" -- "$file" \
      | rg "^@@" \
      | cut -d ' ' -f 3 \
      | ${getExe pkgs.php} -r "$patch_to_lines" -- "$file"
  done < <(${getExe pkgs.git} diff \
    --no-renames \
    --name-only \
    --diff-filter=AM "$then".."$now" \
  )
''
