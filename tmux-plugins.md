# tmux-continuum



Features:

- continuous saving of tmux environment
- automatic tmux start when computer/server is turned on
- automatic restore when tmux is started

Together, these features enable uninterrupted tmux usage. No matter the computer or server restarts, if the machine is on, tmux will be there how you left it off the last time it was used.

Tested and working on Linux, OSX and Cygwin.

#### Continuous saving



Tmux environment will be saved at an interval of 15 minutes. All the saving happens in the background without impact to your workflow.

This action starts automatically when the plugin is installed. Note it requires the status line to be `on` to run (since it uses a hook in status-right to run).

#### Automatic tmux start



Tmux is automatically started after the computer/server is turned on.

See the [instructions](https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/automatic_start.md) on how to enable this for your system.

#### Automatic restore



Last saved environment is automatically restored when tmux is started.

Put `set -g @continuum-restore 'on'` in `.tmux.conf` to enable this.

Note: automatic restore happens **exclusively** on tmux server start. No other action (e.g. sourcing `.tmux.conf`) triggers this.

#### Dependencies



`tmux 1.9` or higher, `bash`, [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) plugin.

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)



Please make sure you have [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) installed.

Add plugin to the list of TPM plugins in `.tmux.conf`:

```
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
```



Hit `prefix + I` to fetch the plugin and source it. The plugin will automatically start "working" in the background, no action required.

### Manual Installation



Please make sure you have [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) installed.

Clone the repo:

```
$ git clone https://github.com/tmux-plugins/tmux-continuum ~/clone/path
```



Add this line to the bottom of `.tmux.conf`:

```
run-shell ~/clone/path/continuum.tmux
```



Reload TMUX environment with: `$ tmux source-file ~/.tmux.conf`

The plugin will automatically start "working" in the background, no action required.

### Docs



- [frequently asked questions](https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/faq.md)
- [behavior when running multiple tmux servers](https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/multiple_tmux_servers.md) - this doc is safe to skip, but you might want to read it if you're using tmux with `-L` or `-S` flags
- [automatically start tmux after the computer is turned on](https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/automatic_start.md)
- [continuum status in tmux status line](https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/continuum_status.md)

### Other goodies



- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - a plugin for regex searches in tmux and fast match selection
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank) - enables copying highlighted text to system clipboard
- [tmux-open](https://github.com/tmux-plugins/tmux-open) - a plugin for quickly opening highlighted file or a url



# Tmux Resurrect



[![Build Status](./tmux-plugins.assets/68747470733a2f2f7472617669732d63692e6f72672f746d75782d706c7567696e732f746d75782d7265737572726563742e7376673f6272616e63683d6d6173746572.svg+xml)](https://travis-ci.org/tmux-plugins/tmux-resurrect)

Restore `tmux` environment after system restart.

Tmux is great, except when you have to restart the computer. You lose all the running programs, working directories, pane layouts etc. There are helpful management tools out there, but they require initial configuration and continuous updates as your workflow evolves or you start new projects.

`tmux-resurrect` saves all the little details from your tmux environment so it can be completely restored after a system restart (or when you feel like it). No configuration is required. You should feel like you never quit tmux.

It even (optionally) [restores vim and neovim sessions](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_vim_and_neovim_sessions.md)!

Automatic restoring and continuous saving of tmux env is also possible with [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) plugin.

### Screencast



[![screencast screenshot](./tmux-plugins.assets/screencast_img.png)](https://vimeo.com/104763018)

### Key bindings



- `prefix + Ctrl-s` - save
- `prefix + Ctrl-r` - restore

### About



This plugin goes to great lengths to save and restore all the details from your `tmux` environment. Here's what's been taken care of:

- all sessions, windows, panes and their order
- current working directory for each pane
- **exact pane layouts** within windows (even when zoomed)
- active and alternative session
- active and alternative window for each session
- windows with focus
- active pane for each window
- "grouped sessions" (useful feature when using tmux with multiple monitors)
- programs running within a pane! More details in the [restoring programs doc](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_programs.md).

Optional:

- [restoring vim and neovim sessions](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_vim_and_neovim_sessions.md)
- [restoring pane contents](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_pane_contents.md)
- [restoring a previously saved environment](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_previously_saved_environment.md)

Requirements / dependencies: `tmux 1.9` or higher, `bash`.

Tested and working on Linux, OSX and Cygwin.

`tmux-resurrect` is idempotent! It will not try to restore panes or windows that already exist.
The single exception to this is when tmux is started with only 1 pane in order to restore previous tmux env. Only in this case will this single pane be overwritten.

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)



Add plugin to the list of TPM plugins in `.tmux.conf`:

```
set -g @plugin 'tmux-plugins/tmux-resurrect'
```



Hit `prefix + I` to fetch the plugin and source it. You should now be able to use the plugin.

### Manual Installation



Clone the repo:

```
$ git clone https://github.com/tmux-plugins/tmux-resurrect ~/clone/path
```



Add this line to the bottom of `.tmux.conf`:

```
run-shell ~/clone/path/resurrect.tmux
```



Reload TMUX environment with: `$ tmux source-file ~/.tmux.conf`. You should now be able to use the plugin.

### Docs



- [Guide for migrating from tmuxinator](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/migrating_from_tmuxinator.md)

**Configuration**

- [Changing the default key bindings](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/custom_key_bindings.md).
- [Setting up hooks on save & restore](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/hooks.md).
- Only a conservative list of programs is restored by default:
  `vi vim nvim emacs man less more tail top htop irssi weechat mutt`.
  [Restoring programs doc](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_programs.md) explains how to restore additional programs.
- [Change a directory](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/save_dir.md) where `tmux-resurrect` saves tmux environment.

**Optional features**

- [Restoring vim and neovim sessions](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_vim_and_neovim_sessions.md) is nice if you're a vim/neovim user.
- [Restoring pane contents](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_pane_contents.md) feature.

### Other goodies



- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - a plugin for regex searches in tmux and fast match selection
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank) - enables copying highlighted text to system clipboard
- [tmux-open](https://github.com/tmux-plugins/tmux-open) - a plugin for quickly opening highlighted file or a url
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) - automatic restoring and continuous saving of tmux env