Debian and Ubuntu
Eza is available from deb.gierens.de. The GPG public key is in this repo under deb.asc.

First make sure you have the gpg command, and otherwise install it via:

sudo apt update
sudo apt install -y gpg

Then install eza via:

sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
Note: In strict apt environments, you may need to add the target: echo "deb [arch=amd64 signed-by=...

Completions
For zsh:
Note Change ~/.zshrc to your preferred zsh config file.

Clone the repository:
git clone https://github.com/eza-community/eza.git
Add the completion path to your zsh configuration:
Replace <path_to_eza> with the actual path where you cloned the eza repository.

echo 'export FPATH="<path_to_eza>/completions/zsh:$FPATH"' >> ~/.zshrc
Reload your zsh configuration:
source ~/.zshrc

Command-line options
eza’s options are almost, but not quite, entirely unlike ls’s. Quick overview:

Display options
Click to expand
-1, --oneline: display one entry per line
-G, --grid: display entries as a grid (default)
-l, --long: display extended details and attributes
-R, --recurse: recurse into directories
-T, --tree: recurse into directories as a tree
-x, --across: sort the grid across, rather than downwards
-F, --classify=(when): display type indicator by file names (always, auto, never)
--colo[u]r=(when): when to use terminal colours (always, auto, never)
--colo[u]r-scale=(field): highlight levels of field distinctly(all, age, size)
--color-scale-mode=(mode): use gradient or fixed colors in --color-scale. valid options are fixed or gradient
--icons=(when): when to display icons (always, auto, never)
--hyperlink: display entries as hyperlinks
--absolute=(mode): display entries with their absolute path (on, follow, off)
-w, --width=(columns): set screen width in columns
Filtering options
Click to expand
-a, --all: show hidden and 'dot' files
-d, --treat-dirs-as-files: list directories like regular files
-L, --level=(depth): limit the depth of recursion
-r, --reverse: reverse the sort order
-s, --sort=(field): which field to sort by
--group-directories-first: list directories before other files
--group-directories-last: list directories after other files
-D, --only-dirs: list only directories
-f, --only-files: list only files
--no-symlinks: don't show symbolic links
--show-symlinks: explicitly show links (with --only-dirs, --only-files, to show symlinks that match the filter)
--git-ignore: ignore files mentioned in .gitignore
-I, --ignore-glob=(globs): glob patterns (pipe-separated) of files to ignore
Pass the --all option twice to also show the . and .. directories.

Long view options
Click to expand
These options are available when running with --long (-l):

-b, --binary: list file sizes with binary prefixes
-B, --bytes: list file sizes in bytes, without any prefixes
-g, --group: list each file’s group
--smart-group: only show group if it has a different name from owner
-h, --header: add a header row to each column
-H, --links: list each file’s number of hard links
-i, --inode: list each file’s inode number
-m, --modified: use the modified timestamp field
-M, --mounts: Show mount details (Linux and MacOS only).
-S, --blocksize: show size of allocated file system blocks
-t, --time=(field): which timestamp field to use
-u, --accessed: use the accessed timestamp field
-U, --created: use the created timestamp field
-X, --dereference: dereference symlinks for file information
-Z, --context: list each file’s security context
-@, --extended: list each file’s extended attributes and sizes
--changed: use the changed timestamp field
--git: list each file’s Git status, if tracked or ignored
--git-repos: list each directory’s Git status, if tracked
--git-repos-no-status: list whether a directory is a Git repository, but not its status (faster)
--no-git: suppress Git status (always overrides --git, --git-repos, --git-repos-no-status)
--time-style: how to format timestamps. valid timestamp styles are ‘default’, ‘iso’, ‘long-iso’, ‘full-iso’, ‘relative’, or a custom style ‘+<FORMAT>’ (E.g., ‘+%Y-%m-%d %H:%M’ => ‘2023-09-30 13:00’. For more specifications on the format string, see the eza(1) manual page and chrono documentation.).
--total-size: show recursive directory size
--no-permissions: suppress the permissions field
-o, --octal-permissions: list each file's permission in octal format
--no-filesize: suppress the filesize field
--no-user: suppress the user field
--no-time: suppress the time field
--stdin: read file names from stdin
Some of the options accept parameters:

Valid --colo[u]r options are always, automatic (or auto for short), and never.
Valid sort fields are accessed, changed, created, extension, Extension, inode, modified, name, Name, size, type, and none. Fields starting with a capital letter sort uppercase before lowercase. The modified field has the aliases date, time, and newest, while its reverse has the aliases age and oldest.
Valid time fields are modified, changed, accessed, and created.
Valid time styles are default, iso, long-iso, full-iso, and relative.
See the man pages for further documentation of usage. They are available

online in the repo
in your terminal via man eza, as of version [0.18.13] - 2024-04-25
Custom Themes
Click to expand
Eza has recently added support for a theme.yml file, where you can specify all of the existing theme-ing options available for the LS_COLORS and EXA_COLORS environment variables, as well as the option to specify different icons for different file types and extensions. Any existing environment variables set will continue to work and will take precedence for backwards compatibility.

New Pre-made themes
Check out the themes available in the official eza-themes repository, or contribute your own.

An example theme file is available in docs/theme.yml, and needs to either be placed in a directory specified by the environment variable EZA_CONFIG_DIR, or will looked for by default in $XDG_CONFIG_HOME/eza.

Full details are available on the man page and an example theme file is included here