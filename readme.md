## It's Z#

Design:
- [Zellij](https://zellij.dev/) is used as UI, learn it's bindings for better user experience.
- Main file is `layout_template.nix` - it describes the view of processes.
- A process usually is `nix-shell` command with interactive prompt. 

Conventions:
- Folder name is used as default for db name.
- Artifacts are persisted in directory `$HOME/.cache/zsharp/`.

Usage:
- system has a single dependency - [nix](https://nixos.org/download/)
- ensure minimum required nix configuration:

```
echo experimental-features = nix-command flakes >> ~/.config/nix/nix.conf
```

- `nix run github:talbergs/zsharp -- <opts>` - cutting edge release
- `nix run github:talbergs/zsharp/<tag> -- <opts>` - suggested to pin to a stable tag
- `nix run ~/local-copy-of-zsharp -- <opts>` - maintain own fork

Advanced usage:

- run tools by themselves not via Zellij UI:
    - build server specifying
```
    DST=~/.cache/zsharp/server-fix-ZBX-25756 \
    SRC=~/repos/zabbix/_wt/fix-ZBX-25756/ \
    nix-shell <path-to-repo>/tool/builders/zabbix_server.nix --run 'tput bold && build && tput sgr0'
```
