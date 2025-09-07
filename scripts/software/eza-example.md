# https://github.com/eza-community/eza

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

<div align="center">
<div align="center" markdown="1">
   <sup>Special thanks to:</sup>
   <br>
   <br>
   <a href="https://www.warp.dev/eza">
      <img alt="Warp sponsorship" width="400" src="https://github.com/user-attachments/assets/ab8dd143-b0fd-4904-bdc5-dd7ecac94eae">
   </a>

### [Warp, the AI terminal for developers](https://www.warp.dev/eza)
[Available for MacOS, Linux, & Windows](https://www.warp.dev/eza)<br>

</div>

# eza

A modern replacement for ls.



---

**eza** is a modern alternative for the venerable file-listing command-line program `ls` that ships with Unix and Linux operating systems, giving it more features and better defaults.
It uses colours to distinguish file types and metadata.
It knows about symlinks, extended attributes, and Git.
And it’s **small**, **fast**, and just **one single binary**.

By deliberately making some decisions differently, eza attempts to be a more featureful, more user-friendly version of `ls`.

---

**eza** features not in exa (non-exhaustive):


### Nix ❄️

If you already have Nix setup with flake support, you can try out eza with the `nix run` command:

    nix run github:eza-community/eza

Nix will build eza and run it.

If you want to pass arguments this way, use e.g. `nix run github:eza-community/eza -- -ol`.

# Installation

eza is available for Windows, macOS and Linux. Platform and distribution
specific installation instructions can be found in [INSTALL.md](INSTALL.md).

[![Packaging status](https://repology.org/badge/vertical-allrepos/eza.svg?columns=3)](https://repology.org/project/eza/versions)

---

<a id="options">
<h1>Command-line options</h1>
</a>

eza’s options are almost, but not quite, entirely unlike `ls`’s. Quick overview:

## Display options

<details>
<summary>Click to expand</summary>

- **-1**, **--oneline**: display one entry per line
- **-G**, **--grid**: display entries as a grid (default)
- **-l**, **--long**: display extended details and attributes
- **-R**, **--recurse**: recurse into directories
- **-T**, **--tree**: recurse into directories as a tree
- **-x**, **--across**: sort the grid across, rather than downwards
- **-F**, **--classify=(when)**: display type indicator by file names (always, auto, never)
- **--colo[u]r=(when)**: when to use terminal colours (always, auto, never)
- **--colo[u]r-scale=(field)**: highlight levels of `field` distinctly(all, age, size)
- **--color-scale-mode=(mode)**: use gradient or fixed colors in --color-scale. valid options are `fixed` or `gradient`
- **--icons=(when)**: when to display icons (always, auto, never)
- **--hyperlink**: display entries as hyperlinks
- **--absolute=(mode)**: display entries with their absolute path (on, follow, off)
- **-w**, **--width=(columns)**: set screen width in columns

</details>

## Filtering options

<details>
<summary>Click to expand</summary>

- **-a**, **--all**: show hidden and 'dot' files
- **-d**, **--list-dirs**: list directories like regular files
- **-L**, **--level=(depth)**: limit the depth of recursion
- **-r**, **--reverse**: reverse the sort order
- **-s**, **--sort=(field)**: which field to sort by
- **--group-directories-first**: list directories before other files
- **--group-directories-last**: list directories after other files
- **-D**, **--only-dirs**: list only directories
- **-f**, **--only-files**: list only files
- **--no-symlinks**: don't show symbolic links
- **--show-symlinks**: explicitly show links (with `--only-dirs`, `--only-files`, to show symlinks that match the filter)
- **--git-ignore**: ignore files mentioned in `.gitignore`
- **-I**, **--ignore-glob=(globs)**: glob patterns (pipe-separated) of files to ignore

Pass the `--all` option twice to also show the `.` and `..` directories.

</details>

## Long view options

<details>
<summary>Click to expand</summary>

These options are available when running with `--long` (`-l`):

- **-b**, **--binary**: list file sizes with binary prefixes
- **-B**, **--bytes**: list file sizes in bytes, without any prefixes
- **-g**, **--group**: list each file’s group
- **--smart-group**: only show group if it has a different name from owner
- **-h**, **--header**: add a header row to each column
- **-H**, **--links**: list each file’s number of hard links
- **-i**, **--inode**: list each file’s inode number
- **-m**, **--modified**: use the modified timestamp field
- **-M**, **--mounts**: Show mount details (Linux and MacOS only).
- **-S**, **--blocksize**: show size of allocated file system blocks
- **-t**, **--time=(field)**: which timestamp field to use
- **-u**, **--accessed**: use the accessed timestamp field
- **-U**, **--created**: use the created timestamp field
- **-X**, **--dereference**: dereference symlinks for file information
- **-Z**, **--context**: list each file’s security context
- **-@**, **--extended**: list each file’s extended attributes and sizes
- **--changed**: use the changed timestamp field
- **--git**: list each file’s Git status, if tracked or ignored
- **--git-repos**: list each directory’s Git status, if tracked
- **--git-repos-no-status**: list whether a directory is a Git repository, but not its status (faster)
- **--no-git**: suppress Git status (always overrides `--git`, `--git-repos`, `--git-repos-no-status`)
- **--time-style**: how to format timestamps. valid timestamp styles are ‘`default`’, ‘`iso`’, ‘`long-iso`’, ‘`full-iso`’, ‘`relative`’, or a custom style ‘`+<FORMAT>`’ (E.g., ‘`+%Y-%m-%d %H:%M`’ => ‘`2023-09-30 13:00`’. For more specifications on the format string, see the _`eza(1)` manual page_ and [chrono documentation](https://docs.rs/chrono/latest/chrono/format/strftime/index.html).).
- **--total-size**: show recursive directory size
- **--no-permissions**: suppress the permissions field
- **-o**, **--octal-permissions**: list each file's permission in octal format
- **--no-filesize**: suppress the filesize field
- **--no-user**: suppress the user field
- **--no-time**: suppress the time field
- **--stdin**: read file names from stdin

Some of the options accept parameters:

- Valid **--colo\[u\]r** options are **always**, **automatic** (or **auto** for short), and **never**.
- Valid sort fields are **accessed**, **changed**, **created**, **extension**, **Extension**, **inode**, **modified**, **name**, **Name**, **size**, **type**, and **none**. Fields starting with a capital letter sort uppercase before lowercase. The modified field has the aliases **date**, **time**, and **newest**, while its reverse has the aliases **age** and **oldest**.
- Valid time fields are **modified**, **changed**, **accessed**, and **created**.
- Valid time styles are **default**, **iso**, **long-iso**, **full-iso**, and **relative**.



See the `man` pages for further documentation of usage. They are available
- online [in the repo](https://github.com/eza-community/eza/tree/main/man)
- in your terminal via `man eza`, as of version [`[0.18.13] - 2024-04-25`](https://github.com/eza-community/eza/blob/main/CHANGELOG.md#01813---2024-04-25)
</details>


## Custom Themes
<details>
<summary>Click to expand</summary>

**Eza** has recently added support for a `theme.yml` file, where you can specify all of the existing theme-ing options
available for the `LS_COLORS` and `EXA_COLORS` environment variables, as well as the option to specify different icons
for different file types and extensions. Any existing environment variables set will continue to work and will take
precedence for backwards compatibility.

#### **New** Pre-made themes
Check out the themes available in the official [eza-themes](https://github.com/eza-community/eza-themes) repository, or contribute your own.

An example theme file is available in `docs/theme.yml`, and needs to either be placed in a directory specified by the
environment variable `EZA_CONFIG_DIR`, or will looked for by default in `$XDG_CONFIG_HOME/eza`.

Full details are available on the [man page](https://github.com/eza-community/eza/tree/main/man/eza_colors-explanation.5.md) and an example theme file is included [here](https://github.com/eza-community/eza/tree/main/docs/theme.yml)

</details>


theme.yml


filekinds:
  normal:
    foreground: Blue
  directory:
    foreground: Blue
  symlink:
    foreground: Cyan
  executable:
    foreground: Green
perms:
  user_read:
    foreground: Yellow
    is_bold: true
  user_write:
    foreground: Red
    is_bold: true
  user_execute_file:
    foreground: Green
    is_bold: true
  user_execute_other:
    foreground: Green
    is_bold: true
  group_read:
    foreground: Yellow
  group_write:
    foreground: Red
  group_execute:
    foreground: Green
  other_read:
    foreground: Yellow
  other_write:
    foreground: Red
  other_execute:
    foreground: Green
filenames:
  # Just change the icon glyph
  Cargo.toml: {icon: {glyph: 🦀}}
  Cargo.lock: {icon: {glyph: 🦀}}
extensions:
  # Change the filename color and icon
  # NOTE: not all unicode glyphs support color changes
  rs: {filename: {foreground: Red}, icon: {glyph: 🦀}}
  # Change the icon glyph and color
  nix: {icon: {glyph: ❄, style: {foreground: White}}}

  % eza(1) $version

<!-- This is the eza(1) man page, written in Markdown. -->
<!-- To generate the roff version, run `just man`, -->
<!-- and the man page will appear in the ‘target’ directory. -->


NAME
====

eza — a modern replacement for ls


SYNOPSIS
========

`eza [options] [files...]`

**eza** is a modern replacement for `ls`.
It uses colours for information by default, helping you distinguish between many types of files, such as whether you are the owner, or in the owning group.

It also has extra features not present in the original `ls`, such as viewing the Git status for a directory, or recursing into directories with a tree view.


EXAMPLES
========

`eza`
: Lists the contents of the current directory in a grid.

`eza --oneline --reverse --sort=size`
: Displays a list of files with the largest at the top.

`eza --long --header --inode --git`
: Displays a table of files with a header, showing each file’s metadata, inode, and Git status.

`eza --long --tree --level=3`
: Displays a tree of files, three levels deep, as well as each file’s metadata.


META OPTIONS
===============

`--help`
: Show list of command-line options.

`-v`, `--version`
: Show version of eza.

DISPLAY OPTIONS
===============

`-1`, `--oneline`
: Display one entry per line.

`--absolute=WHEN`
: Display entries with their absolute path.

Valid settings are '`on`', '`follow`', and '`off`'.
When used without a value, defaults to '`on`'.

'`on`': Show absolute paths for all entries.
'`follow`': Show absolute paths and resolve symbolic links to their targets.
'`off`': Show relative paths (default behavior).

`-F`, `--classify=WHEN`
: Display file kind indicators next to file names.

Valid settings are ‘`always`’, ‘`automatic`’ (or ‘`auto`’ for short), and ‘`never`’.
When used without a value, defaults to ‘`automatic`’.

`automatic` or `auto` will display file kind indicators only when the standard output is connected to a real terminal. If `eza` is ran while in a `tty`, or the output of `eza` is either redirected to a file or piped into another program, file kind indicators will not be used. Setting this option to ‘`always`’ causes `eza` to always display file kind indicators, while ‘`never`’ disables the use of file kind indicators.

`-G`, `--grid`
: Display entries as a grid (default).

`-l`, `--long`
: Display extended file metadata as a table.

`-R`, `--recurse`
: Recurse into directories.

`-T`, `--tree`
: Recurse into directories as a tree.

`--follow-symlinks`
: Drill down into symbolic links that point to directories.

`-X`, `--dereference`
: Dereference symbolic links when displaying information.

`-x`, `--across`
: Sort the grid across, rather than downwards.

`--color=WHEN`, `--colour=WHEN`
: When to use terminal colours (using ANSI escape code to colorize the output).

Valid settings are ‘`always`’, ‘`automatic`’ (or ‘`auto`’ for short), and ‘`never`’.
When used without a value, defaults to ‘`automatic`’.

The default behavior (‘`automatic`’ or ‘`auto`’) is to colorize the output only when the standard output is connected to a real terminal. If the output of `eza` is redirected to a file or piped into another program, terminal colors will not be used. Setting this option to ‘`always`’ causes `eza` to always output terminal color, while ‘`never`’ disables the use of terminal color.

Manually setting this option overrides `NO_COLOR` environment.

`--color-scale`, `--colour-scale`
: highlight levels of `field` distinctly.
Use comma(,) separated list of all, age, size

`--color-scale-mode=MODE`, `--colour-scale-mode=MODE`
: Use gradient or fixed colors in `--color-scale`.

Valid options are `fixed` or `gradient`.
When used without a value, defaults to `gradient`.

`--icons=WHEN`
: Display icons next to file names.

Valid settings are ‘`always`’, ‘`automatic`’ (‘`auto`’ for short), and ‘`never`’.
When used without a value, defaults to ‘`automatic`’.

`automatic` or `auto` will display icons only when the standard output is connected to a real terminal. If `eza` is ran while in a `tty`, or the output of `eza` is either redirected to a file or piped into another program, icons will not be used. Setting this option to ‘`always`’ causes `eza` to always display icons, while ‘`never`’ disables the use of icons.

`--no-quotes`
: Don't quote file names with spaces.

`--hyperlink`
: Display entries as hyperlinks

`-w`, `--width=COLS`
: Set screen width in columns.

FILTERING AND SORTING OPTIONS
=============================

`-a`, `--all`
: Show hidden and “dot” files.
Use this twice to also show the ‘`.`’ and ‘`..`’ directories.

`-A`, `--almost-all`
: Equivalent to --all; included for compatibility with `ls -A`.

`-d`, `--treat-dirs-as-files`
: This flag, inherited from `ls`, changes how `eza` handles directory arguments.

: Instead of recursing into directories and listing their contents (the default behavior), it treats directories as regular files and lists information about the directory entry itself.

: This is useful when you want to see metadata about the directory (e.g., permissions, size, modification time) rather than its contents.

: For simply listing only directories and not files, consider using the `--only-dirs` (`-D`) option as an alternative.

`-L`, `--level=DEPTH`
: Limit the depth of recursion.

`-r`, `--reverse`
: Reverse the sort order.

`-s`, `--sort=SORT_FIELD`
: Which field to sort by.

Valid sort fields are ‘`name`’, ‘`Name`’, ‘`extension`’, ‘`Extension`’, ‘`size`’, ‘`modified`’, ‘`changed`’, ‘`accessed`’, ‘`created`’, ‘`inode`’, ‘`type`’, and ‘`none`’.

The `modified` sort field has the aliases ‘`date`’, ‘`time`’, and ‘`newest`’, and its reverse order has the aliases ‘`age`’ and ‘`oldest`’.

Sort fields starting with a capital letter will sort uppercase before lowercase: ‘A’ then ‘B’ then ‘a’ then ‘b’. Fields starting with a lowercase letter will mix them: ‘A’ then ‘a’ then ‘B’ then ‘b’.

`-I`, `--ignore-glob=GLOBS`
: Glob patterns, pipe-separated, of files to ignore.

`--git-ignore` [if eza was built with git support]
: Do not list files that are ignored by Git.

`--group-directories-first`
: List directories before other files.

`--group-directories-last`
: List directories after other files.

`-D`, `--only-dirs`
: List only directories, not files.

`-f`, `--only-files`
: List only files, not directories.

`--show-symlinks`
: Explicitly show symbolic links (when used with `--only-files` | `--only-dirs`)

`--no-symlinks`
: Do not show symbolic links

LONG VIEW OPTIONS
=================

These options are available when running with `--long` (`-l`):

`-b`, `--binary`
: List file sizes with binary prefixes.

`-B`, `--bytes`
: List file sizes in bytes, without any prefixes.

`--changed`
: Use the changed timestamp field.

`-g`, `--group`
: List each file’s group.

`--smart-group`
: Only show group if it has a different name from owner

`-h`, `--header`
: Add a header row to each column.

`-H`, `--links`
: List each file’s number of hard links.

`-i`, `--inode`
: List each file’s inode number.

`-m`, `--modified`
: Use the modified timestamp field.

`-M`, `--mounts`
: Show mount details (Linux and Mac only)

`-n`, `--numeric`
: List numeric user and group IDs.

`-O`, `--flags`
: List file flags on Mac and BSD systems and file attributes on Windows systems.  By default, Windows attributes are displayed in a long form.  To display in attributes as single character set the environment variable `EZA_WINDOWS_ATTRIBUTES=short`.  On BSD systems see chflags(1) for a list of file flags and their meanings.

`-S`, `--blocksize`
: List each file’s size of allocated file system blocks.

`-t`, `--time=WORD`
: Which timestamp field to list.

: Valid timestamp fields are ‘`modified`’, ‘`changed`’, ‘`accessed`’, and ‘`created`’.

`--time-style=STYLE`
: How to format timestamps.

: Valid timestamp styles are ‘`default`’, ‘`iso`’, ‘`long-iso`’, ‘`full-iso`’, ‘`relative`’, or a custom style ‘`+<FORMAT>`’ (e.g., ‘`+%Y-%m-%d %H:%M`’ => ‘`2023-09-30 13:00`’).

`<FORMAT>` should be a chrono format string.  For details on the chrono format syntax, please read: https://docs.rs/chrono/latest/chrono/format/strftime/index.html .

Alternatively, `<FORMAT>` can be a two line string, the first line will be used for non-recent files and the second for recent files.  E.g., if `<FORMAT>` is "`%Y-%m-%d %H<newline>--%m-%d %H:%M`", non-recent files => "`2022-12-30 13`", recent files => "`--09-30 13:34`".

`--total-size`
: Show recursive directory size (unix only).

`-u`, `--accessed`
: Use the accessed timestamp field.

`-U`, `--created`
: Use the created timestamp field.

`--no-permissions`
: Suppress the permissions field.

`-o`, `--octal-permissions`
: List each file's permissions in octal format.

`--no-filesize`
: Suppress the file size field.

`--no-user`
: Suppress the user field.

`--no-time`
: Suppress the time field.

`--stdin`
: When you wish to pipe directories to eza/read from stdin. Separate one per line or define custom separation char in `EZA_STDIN_SEPARATOR` env variable.

`-@`, `--extended`
: List each file’s extended attributes and sizes.

`-Z`, `--context`
: List each file's security context.

`--git`  [if eza was built with git support]
: List each file’s Git status, if tracked.
This adds a two-character column indicating the staged and unstaged statuses respectively. The status character can be ‘`-`’ for not modified, ‘`M`’ for a modified file, ‘`N`’ for a new file, ‘`D`’ for deleted, ‘`R`’ for renamed, ‘`T`’ for type-change, ‘`I`’ for ignored, and ‘`U`’ for conflicted. Directories will be shown to have the status of their contents, which is how ‘deleted’ is possible if a directory contains a file that has a certain status, it will be shown to have that status.

`--git-repos` [if eza was built with git support]
: List each directory’s Git status, if tracked.
Symbols shown are `|`= clean, `+`= dirty, and `~`= for unknown.

`--git-repos-no-status` [if eza was built with git support]
: List if a directory is a Git repository, but not its status.
All Git repository directories will be shown as (themed) `-` without status indicated.


`--no-git`
: Don't show Git status (always overrides `--git`, `--git-repos`, `--git-repos-no-status`)


ENVIRONMENT VARIABLES
=====================

If an environment variable prefixed with `EZA_` is not set, for backward compatibility, it will default to its counterpart starting with `EXA_`.

eza responds to the following environment variables:

## `COLUMNS`

Overrides the width of the terminal, in characters, however, `-w` takes precedence.

For example, ‘`COLUMNS=80 eza`’ will show a grid view with a maximum width of 80 characters.

This option won’t do anything when eza’s output doesn’t wrap, such as when using the `--long` view.

## `EZA_STRICT`

Enables _strict mode_, which will make eza error when two command-line options are incompatible.

Usually, options can override each other going right-to-left on the command line, so that eza can be given aliases: creating an alias ‘`eza=eza --sort=ext`’ then running ‘`eza --sort=size`’ with that alias will run ‘`eza --sort=ext --sort=size`’, and the sorting specified by the user will override the sorting specified by the alias.

In strict mode, the two options will not co-operate, and eza will error.

This option is intended for use with automated scripts and other situations where you want to be certain you’re typing in the right command.

## `EZA_GRID_ROWS`

Limits the grid-details view (‘`eza --grid --long`’) so it’s only activated when at least the given number of rows of output would be generated.

With widescreen displays, it’s possible for the grid to look very wide and sparse, on just one or two lines with none of the columns lining up.
By specifying a minimum number of rows, you can only use the view if it’s going to be worth using.

## `EZA_ICON_SPACING`

Specifies the number of spaces to print between an icon (see the ‘`--icons`’ option) and its file name.

Different terminals display icons differently, as they usually take up more than one character width on screen, so there’s no “standard” number of spaces that eza can use to separate an icon from text. One space may place the icon too close to the text, and two spaces may place it too far away. So the choice is left up to the user to configure depending on their terminal emulator.

## `NO_COLOR`

Disables colours in the output (regardless of its value). Can be overridden by `--color` option.

See `https://no-color.org/` for details.

## `LS_COLORS`, `EZA_COLORS`

Specifies the colour scheme used to highlight files based on their name and kind, as well as highlighting metadata and parts of the UI.

For more information on the format of these environment variables, see the [eza_colors.5.md](eza_colors.5.md) manual page.

## `EZA_OVERRIDE_GIT`

Overrides any `--git` or `--git-repos` argument

## `EZA_MIN_LUMINANCE`
Specifies the minimum luminance to use when color-scale is active. It's value can be between -100 to 100.

## `EZA_ICONS_AUTO`

If set, automates the same behavior as using `--icons` or `--icons=auto`. Useful for if you always want to have icons enabled.

Any explicit use of the `--icons=WHEN` flag overrides this behavior.

## `EZA_STDIN_SEPARATOR`

Specifies the separator to use when file names are piped from stdin. Defaults to newline.

## `EZA_CONFIG_DIR`

Specifies the directory where eza will look for its configuration and theme files. Defaults to `$XDG_CONFIG_HOME/eza` or `$HOME/.config/eza` if `XDG_CONFIG_HOME` is not set.

EXIT STATUSES
=============

0
: If everything goes OK.

1
: If there was an I/O error during operation.

3
: If there was a problem with the command-line arguments.

13
: If permission is denied to access a path.


AUTHOR
======

eza is maintained by Christina Sørensen and many other contributors.

**Source code:** `https://github.com/eza-community/eza` \
**Contributors:** `https://github.com/eza-community/eza/graphs/contributors`

Our infinite thanks to Benjamin ‘ogham’ Sago and all the other contributors of exa, from which eza was forked.

SEE ALSO
========

- [**eza_colors**(5)](eza_colors.5.md)
- [**eza_colors-explanation**(5)](eza_colors-explanation.5.md)


% eza_colors-explanation(5) $version

<!-- This is the eza_colors-explanation(5) man page, written in Markdown. -->
<!-- To generate the roff version, run `just man`, -->
<!-- and the man page will appear in the ‘target’ directory. -->

# Name

eza_colors-explanation — more details on customizing eza colors

# Eza Color Explanation

eza provides its own built\-in set of file extension mappings that cover a large range of common file extensions, including documents, archives, media, and temporary files.
Any mappings in the environment variables will override this default set: running eza with `LS_COLORS="*.zip=32"` will turn zip files green but leave the colours of other compressed files alone.

You can also disable this built\-in set entirely by including a
`reset` entry at the beginning of `EZA_COLORS`.
So setting `EZA_COLORS="reset:*.txt=31"` will highlight only text
files; setting `EZA_COLORS="reset"` will highlight nothing.

## Examples

- Disable the "current user" highlighting: `EZA_COLORS="uu=0:gu=0"`
- Turn the date column green: `EZA_COLORS="da=32"`
- Highlight Vagrantfiles: `EZA_COLORS="Vagrantfile=1;4;33"`
- Override the existing zip colour: `EZA_COLORS="*.zip=38;5;125"`
- Markdown files a shade of green, log files a shade of grey:
`EZA_COLORS="*.md=38;5;121:*.log=38;5;248"`

## BUILT\-IN EXTENSIONS

- eza now supports bright colours! As supported by most modern 256\-colour terminals, you can now choose from `bright` colour codes when selecting your custom colours in your `#EZA_COLORS` environment variable.

- Build (Makefile, Cargo.toml, package.json) are yellow and underlined.
- Images (png, jpeg, gif) are purple.
- Videos (mp4, ogv, m2ts) are a slightly purpler purple.
- Music (mp3, m4a, ogg) is a faint blue.
- Lossless music (flac, alac, wav) is a less faint blue.
- Cryptographic files (asc, enc, p12) are bright green.
- Documents (pdf, doc, dvi) are a fainter green.
- Compressed files (zip, tgz, Z) are red.
- Temporary files (tmp, swp, ~) are dimmed default foreground color.
- Compiled files (class, o, pyc) are yellow. A file is also counted as compiled if it uses a common extension and is
in the same directory as one of its source files: styles.css will count as compiled when next to styles.less or styles.sass, and scripts.js when next to scripts.ts or scripts.coffee.
- Source files (cpp, js, java) are bright yellow.


## Theme Configuration file

Now you can specify these options and more in a `theme.yml` file with convenient syntax for defining your styles.

Set `EZA_CONFIG_DIR` to specify which directory you would like eza to look for your `theme.yml` file,
otherwise eza will look for `$XDG_CONFIG_HOME/eza/theme.yml`.


These are the available options:

LIST OF THEME OPTIONS
=====================

```yaml
filekinds:
  normal
  directory
  symlink
  pipe
  block_device
  char_device
  socket
  special
  executable
  mount_point

perms:
  user_read
  user_write
  user_execute_file
  user_execute_other
  group_read
  group_write
  group_execute
  other_read
  other_write
  other_execute
  special_user_file
  special_other
  attribute

size:
  major
  minor
  number_byte
  number_kilo
  number_mega
  number_giga
  number_huge
  unit_byte
  unit_kilo
  unit_mega
  unit_giga
  unit_huge

users:
  user_you
  user_root
  user_other
  group_yours
  group_other
  group_root

links:
  normal
  multi_link_file

git:
  new
  modified
  deleted
  renamed
  ignored
  conflicted

git_repo:
  branch_main
  branch_other
  git_clean
  git_dirty

security_context:
  none:
  selinux:
    colon
    user
    role
    typ
    range

file_type:
  image
  video
  music
  crypto
  document
  compressed
  temp
  compiled
  build
  source

punctuation:

date:

inode:

blocks:

header:

octal:

flags:

control_char:

broken_symlink:

broken_path_overlay:

```

Each of those fields/sub fields can have the following styling properties defined beneath it

```yaml
    foreground: Blue
    background: null
    is_bold: false
    is_dimmed: false
    is_italic: false
    is_underline: false
    is_blink: false
    is_reverse: false
    is_hidden: false
    is_strikethrough: true
    prefix_with_reset: false
```

Example:

```yaml

file_type:
  image:
    foreground: Blue
    is_italic: true
date:
  foreground: White

security_context:
  selinux:
    role:
      is_hidden: true
```

Icons can now be customized as well in the `filenames` and `extensions` fields

```yaml

filenames:
  # Just change the icon glyph
  Cargo.toml: {icon: {glyph: 🦀}}
  Cargo.lock: {icon: {glyph: 🦀}}

extensions:
  rs: {  filename: {foreground: Red}, icon: {glyph: 🦀}}

```

**NOTES:**

Not all glyphs support changing colors.

If your theme is not working properly, double check the syntax in the config file, as
a syntax issue can cause multiple properties to not be applied.

You must name the file `theme.yml`, no matter the directory you specify.


## See also

- [**eza**(1)](eza.1.md)
- [**eza_colors**(5)](eza_colors.5.md)
