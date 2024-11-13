{ pkgs, layout_template, ... }:
pkgs.writeShellApplication {
  name = "layout_generator";
  runtimeInputs = with pkgs; [
    gnused
  ];
  text = ''
    set +o nounset

    for i in "$@"; do
        declare "$i";
    done

    # Prefix all double quotes and "$" with backslash, then unwrap mustaches.
    prep-tmpl() {
        sed -e 's/"/\\"/g' -e 's/\$/\\$/g' -e 's/{{\s*\\\(\$\w*\)\s*}}/\1/g' "$1"
    }

    eval "echo \"$(prep-tmpl "${layout_template}")\""
  '';
}
