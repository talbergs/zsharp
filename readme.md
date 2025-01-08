## It's Z#

Design:
- [Zellij](https://zellij.dev/) is used as UI, learn it's bindings for better user experience.
- Main file is `layout_template.nix` - it describes the view of processes.
- A process ussually is `nix-shell` command with interactive prompt. 

Conventions:
- Folder name is used as default for db name.
- In project root this application maintains `./zsharp` folder where artifacts will be organized.

Usage:
- system has a single dependency - [nix](https://nixos.org/download/)
- `nix run github:talbergs/zsharp -- <opts>`
