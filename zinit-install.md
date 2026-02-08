# Zinit



[![MIT License](./zinit-install.assets/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c6963656e73652d4d49542d626c75652e737667.svg+xml)](https://github.com/zdharma-continuum/zinit/blob/main/LICENSE) [![zinit version](./zinit-install.assets/68747470733a2f2f696d672e736869656c64732e696f2f6769746875622f7461672f7a646861726d612d636f6e74696e75756d2f7a696e69742e737667.svg+xml)](https://github.com/zdharma-continuum/zinit/releases) [![zunit tests](./zinit-install.assets/badge.svg+xml)](https://github.com/zdharma-continuum/zinit/actions/workflows/tests.yaml) [![Join the chat at https://matrix.to/#/#zdharma-continuum_community:gitter.im](./zinit-install.assets/68747470733a2f2f6261646765732e6769747465722e696d2f7a646861726d612d636f6e74696e75756d2f7a696e69742e737667.svg+xml)](https://matrix.to/#/#zdharma-continuum_community:gitter.im)

- [Zinit Wiki](https://github.com/zdharma-continuum/zinit#zinit-wiki)
- Install
  - [Automatic](https://github.com/zdharma-continuum/zinit#automatic)
  - [Manual](https://github.com/zdharma-continuum/zinit#manual)
- Usage
  - [Introduction](https://github.com/zdharma-continuum/zinit#introduction)
  - [Plugins and snippets](https://github.com/zdharma-continuum/zinit#plugins-and-snippets)
  - [Upgrade Zinit and plugins](https://github.com/zdharma-continuum/zinit#upgrade-zinit-and-plugins)
  - [Turbo and lucid](https://github.com/zdharma-continuum/zinit#turbo-and-lucid)
  - [Migration](https://github.com/zdharma-continuum/zinit#migration)
- Frequently Asked Questions
  - [Use `zi ice svn` if a plugin/snippet requires an entire subdirectory](https://github.com/zdharma-continuum/zinit#use-zi-ice-svn-if-a-pluginsnippet-requires-an-entire-subdirectory)
  - [Use `zi ice as'completion'` to directly add single file completion snippets](https://github.com/zdharma-continuum/zinit#use-zi-ice-ascompletion-to-directly-add-single-file-completion-snippets)
  - [More Examples](https://github.com/zdharma-continuum/zinit#more-examples)
- Ice Modifiers
  - [Cloning Options](https://github.com/zdharma-continuum/zinit#cloning-options)
  - [Selection of Files (To Source, …)](https://github.com/zdharma-continuum/zinit#selection-of-files-to-source-…)
  - [Conditional Loading](https://github.com/zdharma-continuum/zinit#conditional-loading)
  - [Plugin Output](https://github.com/zdharma-continuum/zinit#plugin-output)
  - [Completions](https://github.com/zdharma-continuum/zinit#completions)
  - [Command Execution After Cloning, Updating or Loading](https://github.com/zdharma-continuum/zinit#command-execution-after-cloning-updating-or-loading)
  - [Sticky-Emulation Of Other Shells](https://github.com/zdharma-continuum/zinit#sticky-emulation-of-other-shells)
  - [Others](https://github.com/zdharma-continuum/zinit#others)
  - [Order of Execution](https://github.com/zdharma-continuum/zinit#order-of-execution)
- Zinit Commands
  - [Help](https://github.com/zdharma-continuum/zinit#help)
  - [Loading and Unloading](https://github.com/zdharma-continuum/zinit#loading-and-unloading)
  - [Completions](https://github.com/zdharma-continuum/zinit#completions-1)
  - [Tracking of the Active Session](https://github.com/zdharma-continuum/zinit#tracking-of-the-active-session)
  - [Reports and Statistics](https://github.com/zdharma-continuum/zinit#reports-and-statistics)
  - [Compiling](https://github.com/zdharma-continuum/zinit#compiling)
  - [Other](https://github.com/zdharma-continuum/zinit#other)
- [Updating Zinit and Plugins](https://github.com/zdharma-continuum/zinit#updating-zinit-and-plugins)
- Completions
  - [Calling `compinit` Without Turbo Mode](https://github.com/zdharma-continuum/zinit#calling-compinit-without-turbo-mode)
  - [Calling `compinit` With Turbo Mode](https://github.com/zdharma-continuum/zinit#calling-compinit-with-turbo-mode)
  - [Ignoring Compdefs](https://github.com/zdharma-continuum/zinit#ignoring-compdefs)
  - Disabling System-Wide `compinit` Call
    - [Ubuntu](https://github.com/zdharma-continuum/zinit#disabling-system-wide-compinit-call-ubuntu)
    - [NixOS](https://github.com/zdharma-continuum/zinit#disabling-system-wide-compinit-call-nixos)
- [Zinit Module](https://github.com/zdharma-continuum/zinit#zinit-module)
- Hints and Tips
  - [Using ZPFX variable](https://github.com/zdharma-continuum/zinit#using-zpfx-variable)
  - [Customizing Paths](https://github.com/zdharma-continuum/zinit#customizing-paths)
  - [Non-GitHub (Local) Plugins](https://github.com/zdharma-continuum/zinit#non-github-local-plugins)
  - [Extending Git](https://github.com/zdharma-continuum/zinit#extending-git)
- [Changelog](https://github.com/zdharma-continuum/zinit#changelog)
- [Support](https://github.com/zdharma-continuum/zinit#support)
- [Getting Help and Community](https://github.com/zdharma-continuum/zinit#getting-help-and-community)

[![startup times graph](./zinit-install.assets/startup-times.png)](https://github.com/zdharma-continuum/pm-perf-test)

Zinit is a flexible and fast Zshell plugin manager that will allow you to install everything from GitHub and other sites. Its characteristics are:

1. Zinit is currently the only plugin manager that provides Turbo mode, which yields **50-80% faster Zsh startup** (i.e., the shell will start up to **5** times faster!). Check out a speed comparison with other popular plugin managers [here](https://github.com/zdharma-continuum/pm-perf-test).
2. The plugin manager gives **reports** from plugin loadings describing what **aliases**, functions, **bindkeys**, Zle widgets, zstyles, **completions**, variables, `PATH` and `FPATH` elements a plugin has set up. This allows one to quickly familiarize oneself with a new plugin and provides rich and easy-to-digest information which might be helpful on various occasions.
3. Supported is the unloading of plugin and ability to list, (un)install and **selectively disable**, **enable** plugin's completions.
4. The plugin manager supports loading plugins and libraries from Oh My Zsh or Prezto. However, the implementation isn't framework-specific and doesn't bloat the plugin manager with such code (more on this topic can be found on the Wiki, in the [Introduction](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#oh_my_zsh_prezto)).
5. The system does not use `$FPATH`, loading multiple plugins doesn't clutter `$FPATH` with the same number of entries (e.g. `10`, `15` or more). Code is immune to `KSH_ARRAYS` and other options typically causing compatibility problems.
6. Zinit supports special, dedicated **packages** that offload the user from providing long and complex commands. See the [zinit-packages repository](https://github.com/zdharma-continuum/zinit-packages) for a growing, complete list of Zinit packages and the [Wiki page](https://zdharma-continuum.github.io/zinit/wiki/Zinit-Packages/) for an article about the feature.
7. Also, specialized Zinit extensions — called **annexes** — have the ability to extend the plugin manager with new commands, URL-preprocessors (used by e.g.: [zinit-annex-readurl](https://github.com/zdharma-continuum/zinit-annex-readurl) annex), post-install and post-update hooks, and much more. See the [zdharma-continuum](https://github.com/zdharma-continuum) organization for a growing, complete list of available Zinit extensions and refer to the [Wiki article](https://zdharma-continuum.github.io/zinit/wiki/Annexes/) for an introduction on creating your annex.

## Zinit Wiki



The information in this README is complemented by the [Zinit Wiki](https://zdharma-continuum.github.io/zinit/wiki/). The README is an introductory overview of Zinit, while the Wiki gives complete information with examples. Make sure to read it to get the most out of Zinit.

## Install



### Automatic



The easiest way to install Zinit is to execute:

```
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```



This will install Zinit in `~/.local/share/zinit/zinit.git`. `.zshrc` will be updated with three lines of code that will be added to the bottom. The lines will be sourcing `zinit.zsh` and setting up completion for command `zinit`.

After installing and reloading the shell, compile Zinit via:

```
zinit self-update
```



### Manual



In your `.zshrc`, add the following snippet

```
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
```



[compinit](http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Initialization):

If you source `zinit.zsh` after `compinit`, add the following snippet after sourcing `zinit.zsh`:

```
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
```



Reload Zsh to install Zinit:

```
exec zsh
```



Various paths can be customized; see section [Customizing Paths](https://github.com/zdharma-continuum/zinit#customizing-paths).

## Usage



### Introduction



[Click here to read the introduction to Zinit](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/). It explains basic usage and some of the more unique features of Zinit, such as the Turbo mode. If you're new to Zinit, we recommend you read it at least once.

### Plugins and snippets



Plugins can be loaded using `load` or `light`.

```
zinit load  <repo/plugin> # Load with reporting/investigating.
zinit light <repo/plugin> # Load without reporting/investigating.
```



If you want to source local or remote files (using direct URL), you can do so with `snippet`.

```
zinit snippet <URL>
```



Such lines should be added to `.zshrc`. Snippets are cached locally. Use the `-f` option to download a new version of a snippet or `zinit update {URL}`. You can also use `zinit update --all` to update all snippets (and plugins).

**Example**

```
# Plugin history-search-multi-word loaded with investigating.
zinit load zdharma-continuum/history-search-multi-word

# Two regular plugins loaded without investigating.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# Snippet
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/
```



**Prompt(Theme) Example**

This is [powerlevel10k](https://github.com/romkatv/powerlevel10k), [pure](https://github.com/sindresorhus/pure), [starship](https://github.com/starship/starship) sample:

```
# Load powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k

# Load pure theme
zinit ice pick"async.zsh" src"pure.zsh" # with zsh-async library that's bundled with it.
zinit light sindresorhus/pure

# Load starship theme
# line 1: `starship` binary as command, from github release
# line 2: starship setup at clone(create init.zsh, completion)
# line 3: pull behavior same as clone, source init.zsh
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship
```



### Upgrade Zinit and plugins



Zinit can be updated to `self-update` and plugins to `update`.

```
# Self update
zinit self-update

# Plugin update
zinit update

# Plugin parallel update
zinit update --parallel

# Increase the number of jobs in a concurrent-set to 40
zinit update --parallel 40
```



### Turbo and lucid



Turbo and lucid are the most used options.

<details style="box-sizing: border-box; display: block; margin-top: 0px; margin-bottom: 16px; color: rgb(31, 35, 40); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, &quot;Noto Sans&quot;, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><summary style="box-sizing: border-box; display: list-item; cursor: pointer;"><b style="box-sizing: border-box; font-weight: 600;">Turbo Mode</b></summary>Turbo mode is the key to performance. It can be loaded asynchronously, which makes a huge difference when the amount of plugins increases.<p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Usually used as<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zinit ice wait"&lt;SECONDS&gt;"</code>, let's use the previous example:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zinit ice <span class="pl-c1" style="box-sizing: border-box; color: rgb(5, 80, 174);">wait</span>    <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> wait is the same as wait"0"</span>
zinit load zdharma-continuum/history-search-multi-word

zinit ice wait<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>2<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span> <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> load after 2 seconds</span>
zinit load zdharma-continuum/history-search-multi-word

zinit ice <span class="pl-c1" style="box-sizing: border-box; color: rgb(5, 80, 174);">wait</span>    <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> also be used in `light` and `snippet`</span>
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zinit ice wait    # wait is the same as wait&quot;0&quot;
zinit load zdharma-continuum/history-search-multi-word

zinit ice wait&quot;2&quot; # load after 2 seconds
zinit load zdharma-continuum/history-search-multi-word

zinit ice wait    # also be used in `light` and `snippet`
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div></details>

<details style="box-sizing: border-box; display: block; margin-top: 0px; margin-bottom: 16px; color: rgb(31, 35, 40); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, &quot;Noto Sans&quot;, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><summary style="box-sizing: border-box; display: list-item; cursor: pointer;"><b style="box-sizing: border-box; font-weight: 600;">Lucid</b></summary><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Turbo mode is verbose, so you need an option for quiet.</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">You can use<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">lucid</code>:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zinit ice <span class="pl-c1" style="box-sizing: border-box; color: rgb(5, 80, 174);">wait</span> lucid
zinit load zdharma-continuum/history-search-multi-word</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zinit ice wait lucid
zinit load zdharma-continuum/history-search-multi-word" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div></details>

***F&A:\*** What is `ice`?

`ice` is zinit's options command. The option melts like ice and is used only once. (more: [Ice Modifiers](https://github.com/zdharma-continuum/zinit#ice-modifiers))

### Migration



<details open="" style="box-sizing: border-box; display: block; margin-top: 0px; margin-bottom: 16px; color: rgb(31, 35, 40); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, &quot;Noto Sans&quot;, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><summary class="" style="box-sizing: border-box; display: list-item; cursor: pointer;"><b style="box-sizing: border-box; font-weight: 600;">Migration from Oh-My-ZSH</b></summary><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Basic</strong></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zinit snippet <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>URL<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>        <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Raw Syntax with URL</span>
zinit snippet OMZ::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>  <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Shorthand OMZ/ (https://github.com/ohmyzsh/ohmyzsh/raw/master/)</span>
zinit snippet OMZL::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span> <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Shorthand OMZ/lib/</span>
zinit snippet OMZT::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span> <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Shorthand OMZ/themes/</span>
zinit snippet OMZP::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span> <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Shorthand OMZ/plugins/</span></pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zinit snippet <URL>        # Raw Syntax with URL
zinit snippet OMZ::<PATH>  # Shorthand OMZ/ (https://github.com/ohmyzsh/ohmyzsh/raw/master/)
zinit snippet OMZL::<PATH> # Shorthand OMZ/lib/
zinit snippet OMZT::<PATH> # Shorthand OMZ/themes/
zinit snippet OMZP::<PATH> # Shorthand OMZ/plugins/" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Library</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Importing the<span>&nbsp;</span><a href="https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/clipboard.zsh" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">clipboard</a><span>&nbsp;</span>and<span>&nbsp;</span><a href="https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/termsupport.zsh" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">termsupport</a><span>&nbsp;</span>Oh-My-Zsh Library Sample:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Raw Syntax</span>
zi snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/clipboard.zsh
zi snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/termsupport.zsh

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> OMZ Shorthand Syntax</span>
zi snippet OMZ::lib/clipboard.zsh
zi snippet OMZ::lib/termsupport.zsh

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> OMZL Shorthand Syntax</span>
zi snippet OMZL::clipboard.zsh
zi snippet OMZL::termsupport.zsh</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="# Raw Syntax
zi snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/clipboard.zsh
zi snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/termsupport.zsh

# OMZ Shorthand Syntax
zi snippet OMZ::lib/clipboard.zsh
zi snippet OMZ::lib/termsupport.zsh

# OMZL Shorthand Syntax
zi snippet OMZL::clipboard.zsh
zi snippet OMZL::termsupport.zsh" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Theme</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">To use<span>&nbsp;</span><strong style="box-sizing: border-box; font-weight: 600;">themes</strong><span>&nbsp;</span>created for Oh My Zsh you might want to first source the<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">git</code><span>&nbsp;</span>library there.</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Then you can use the themes as snippets (<code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zinit snippet &lt;file path or GitHub URL&gt;</code>). Some themes require not only Oh My Zsh's Git<span>&nbsp;</span><strong style="box-sizing: border-box; font-weight: 600;">library</strong>, but also Git<span>&nbsp;</span><strong style="box-sizing: border-box; font-weight: 600;">plugin</strong><span>&nbsp;</span>(error about<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">current_branch</code><span>&nbsp;</span>may appear). Load this Git-plugin as single-file snippet directly from OMZ.</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Most themes require<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">promptsubst</code><span>&nbsp;</span>option (<code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">setopt promptsubst</code><span>&nbsp;</span>in<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zshrc</code>), if it isn't set, then prompt will appear as something like:<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">... $(build_prompt) ...</code>.</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">You might want to suppress completions provided by the git plugin by issuing<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zinit cdclear -q</code><span>&nbsp;</span>(<code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">-q</code><span>&nbsp;</span>is for quiet) – see below<span>&nbsp;</span><strong style="box-sizing: border-box; font-weight: 600;">Ignoring Compdefs</strong>.</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">To summarize:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Oh My Zsh Setting</span>
ZSH_THEME=<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>robbyrussell<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Zinit Setting</span>
<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Must Load OMZ Git library</span>
zi snippet OMZL::git.zsh

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Must Load OMZ Async prompt library</span>
zi snippet OMZL::async_prompt.zsh&nbsp;

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load Git plugin from OMZ</span>
zi snippet OMZP::git
zi cdclear -q <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> &lt;- forget completions provided up to this moment</span>

setopt promptsubst

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load Prompt</span>
zi snippet OMZT::robbyrussell</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="## Oh My Zsh Setting
ZSH_THEME=&quot;robbyrussell&quot;

## Zinit Setting
# Must Load OMZ Git library
zi snippet OMZL::git.zsh

# Must Load OMZ Async prompt library
zi snippet OMZL::async_prompt.zsh&nbsp;

# Load Git plugin from OMZ
zi snippet OMZP::git
zi cdclear -q # <- forget completions provided up to this moment

setopt promptsubst

# Load Prompt
zi snippet OMZT::robbyrussell" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">External Theme Sample:<span>&nbsp;</span><a href="https://github.com/nicosantangelo/Alpharized" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">NicoSantangelo/Alpharized</a></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Oh My Zsh Setting</span>
ZSH_THEME=<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>alpharized<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Zinit Setting</span>
<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Must Load OMZ Git library</span>
zi snippet OMZL::git.zsh

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load Git plugin from OMZ</span>
zi snippet OMZP::git
zi cdclear -q <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> &lt;- forget completions provided up to this moment</span>

setopt promptsubst

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load Prompt</span>
zi light NicoSantangelo/Alpharized</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="## Oh My Zsh Setting
ZSH_THEME=&quot;alpharized&quot;

## Zinit Setting
# Must Load OMZ Git library
zi snippet OMZL::git.zsh

# Load Git plugin from OMZ
zi snippet OMZP::git
zi cdclear -q # <- forget completions provided up to this moment

setopt promptsubst

# Load Prompt
zi light NicoSantangelo/Alpharized" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><div class="markdown-heading" dir="auto" style="box-sizing: border-box; position: relative;"><h2 tabindex="-1" class="heading-element" dir="auto" style="box-sizing: border-box; margin-top: 24px; margin-bottom: 16px; font-size: 1.5em; font-weight: 600; line-height: 1.25; border-bottom: 0.761905px solid rgba(209, 217, 224, 0.7); padding-bottom: 0.3em;">Frequently Asked Questions<a name="user-content-frequently-asked-questions" style="box-sizing: border-box; background-color: transparent; color: inherit; text-decoration: none; text-underline-offset: 0.2rem;"></a></h2><a id="user-content-frequently-asked-questions" class="anchor" aria-label="Permalink: Frequently Asked Questions" href="https://github.com/zdharma-continuum/zinit#frequently-asked-questions" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; float: left; padding-right: 4px; margin: auto; line-height: 1; border-radius: 6px; opacity: 0; justify-content: center; align-items: center; width: 28px; height: 28px; display: flex; position: absolute; top: 18.9762px; left: -28px; transform: translateY(calc(-50% - 0.3rem)); text-underline-offset: 0.2rem;"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Error occurs when loading OMZ's theme.</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">If the<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">git</code><span>&nbsp;</span>library will not be loaded, the following errors will appear:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">........:1: <span class="pl-c1" style="box-sizing: border-box; color: rgb(5, 80, 174);">command</span> not found: git_prompt_status
........:1: <span class="pl-c1" style="box-sizing: border-box; color: rgb(5, 80, 174);">command</span> not found: git_prompt_short_sha</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="........:1: command not found: git_prompt_status
........:1: command not found: git_prompt_short_sha" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Plugin</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">If it consists of a single file, you can just load it.</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Oh-My-Zsh Setting</span>
plugins=(
  git
  dotenv
  rake
  rbenv
  ruby
)

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Zinit Setting</span>
zi snippet OMZP::git
zi snippet OMZP::dotenv
zi snippet OMZP::rake
zi snippet OMZP::rbenv
zi snippet OMZP::ruby</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="## Oh-My-Zsh Setting
plugins=(
  git
  dotenv
  rake
  rbenv
  ruby
)

## Zinit Setting
zi snippet OMZP::git
zi snippet OMZP::dotenv
zi snippet OMZP::rake
zi snippet OMZP::rbenv
zi snippet OMZP::ruby" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><div class="markdown-heading" dir="auto" style="box-sizing: border-box; position: relative;"><h3 tabindex="-1" class="heading-element" dir="auto" style="box-sizing: border-box; margin-top: 24px; margin-bottom: 16px; font-size: 1.25em; font-weight: 600; line-height: 1.25;">Use<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: inherit; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0px 0.2em;">zi ice svn</code><span>&nbsp;</span>if a plugin/snippet requires an entire subdirectory<a name="user-content-use-zi-ice-svn-if-a-pluginsnippet-requires-an-entire-subdirectory" style="box-sizing: border-box; background-color: transparent; color: inherit; text-decoration: none; text-underline-offset: 0.2rem;"></a></h3><a id="user-content-use-zi-ice-svn-if-a-pluginsnippet-requires-an-entire-subdirectory" class="anchor" aria-label="Permalink: Use zi ice svn if a plugin/snippet requires an entire subdirectory" href="https://github.com/zdharma-continuum/zinit#use-zi-ice-svn-if-a-pluginsnippet-requires-an-entire-subdirectory" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; float: left; padding-right: 4px; margin: auto; line-height: 1; border-radius: 6px; opacity: 0; justify-content: center; align-items: center; width: 28px; height: 28px; display: flex; position: absolute; top: 13.8333px; left: -28px; transform: translateY(-50%); text-underline-offset: 0.2rem;"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></div><ol dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px; padding-left: 2em;"><li style="box-sizing: border-box;"><a href="https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitfast" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">gitfast</a></li><li style="box-sizing: border-box; margin-top: 0.25em;"><a href="https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/osx" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">osx</a></li></ol><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zi ice svn
zi snippet OMZP::gitfast

zi ice svn
zi snippet OMZP::osx</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zi ice svn
zi snippet OMZP::gitfast

zi ice svn
zi snippet OMZP::osx" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><div class="markdown-heading" dir="auto" style="box-sizing: border-box; position: relative;"><h3 tabindex="-1" class="heading-element" dir="auto" style="box-sizing: border-box; margin-top: 24px; margin-bottom: 16px; font-size: 1.25em; font-weight: 600; line-height: 1.25;">Use<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: inherit; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0px 0.2em;">zi ice as'completion'</code><span>&nbsp;</span>to directly add single file completion snippets<a name="user-content-use-zi-ice-ascompletion-to-directly-add-single-file-completion-snippets" style="box-sizing: border-box; background-color: transparent; color: inherit; text-decoration: none; text-underline-offset: 0.2rem;"></a></h3><a id="user-content-use-zi-ice-ascompletion-to-directly-add-single-file-completion-snippets" class="anchor" aria-label="Permalink: Use zi ice as'completion' to directly add single file completion snippets" href="https://github.com/zdharma-continuum/zinit#use-zi-ice-ascompletion-to-directly-add-single-file-completion-snippets" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; float: left; padding-right: 4px; margin: auto; line-height: 1; border-radius: 6px; opacity: 0; justify-content: center; align-items: center; width: 28px; height: 28px; display: flex; position: absolute; top: 13.8333px; left: -28px; transform: translateY(-50%); text-underline-offset: 0.2rem;"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></div><ol dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px; padding-left: 2em;"><li style="box-sizing: border-box;"><a href="https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">docker</a></li><li style="box-sizing: border-box; margin-top: 0.25em;"><a href="https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fd" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">fd</a></li></ol><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zi ice as<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>completion<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>
zi snippet OMZP::docker/_docker

zi ice as<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>completion<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>
zi snippet OMZP::fd/_fd</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zi ice as&quot;completion&quot;
zi snippet OMZP::docker/_docker

zi ice as&quot;completion&quot;
zi snippet OMZP::fd/_fd" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><a href="https://zdharma-continuum.github.io/zinit/wiki/Example-Oh-My-Zsh-setup/" rel="nofollow" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">Find more information on Oh-My-Zsh + Zinit on the Wiki</a></p></details>

<details style="box-sizing: border-box; display: block; margin-top: 0px; margin-bottom: 16px; color: rgb(31, 35, 40); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, &quot;Noto Sans&quot;, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><summary style="box-sizing: border-box; display: list-item; cursor: pointer;"><b style="box-sizing: border-box; font-weight: 600;">Migration from Prezto</b></summary><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Basic</strong></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zi snippet <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>URL<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>        <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Raw Syntax with URL</span>
zi snippet PZT::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>  <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Shorthand PZT/ (https://github.com/sorin-ionescu/prezto/tree/master/)</span>
zi snippet PZTM::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span> <span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Shorthand PZT/modules/</span></pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zi snippet <URL>        # Raw Syntax with URL
zi snippet PZT::<PATH>  # Shorthand PZT/ (https://github.com/sorin-ionescu/prezto/tree/master/)
zi snippet PZTM::<PATH> # Shorthand PZT/modules/" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Modules</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Importing the<span>&nbsp;</span><a href="https://github.com/sorin-ionescu/prezto/tree/master/modules/environment" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">environment</a><span>&nbsp;</span>and<span>&nbsp;</span><a href="https://github.com/sorin-ionescu/prezto/tree/master/modules/terminal" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">terminal</a><span>&nbsp;</span>Prezto Modules Sample:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Prezto Setting</span>
zstyle <span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span>:prezto:load<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span></span> pmodule <span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span>environment<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span></span> <span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span>terminal<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span></span>

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span># Zinit Setting</span>
<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Raw Syntax</span>
zi snippet https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh
zi snippet https://github.com/sorin-ionescu/prezto/blob/master/modules/terminal/init.zsh

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> PZT Shorthand Syntax</span>
zi snippet PZT::modules/environment
zi snippet PZT::modules/terminal

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> PZTM Shorthand Syntax</span>
zi snippet PZTM::environment
zi snippet PZTM::terminal</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="## Prezto Setting
zstyle ':prezto:load' pmodule 'environment' 'terminal'

## Zinit Setting
# Raw Syntax
zi snippet https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh
zi snippet https://github.com/sorin-ionescu/prezto/blob/master/modules/terminal/init.zsh

# PZT Shorthand Syntax
zi snippet PZT::modules/environment
zi snippet PZT::modules/terminal

# PZTM Shorthand Syntax
zi snippet PZTM::environment
zi snippet PZTM::terminal" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Use<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zinit ice svn</code><span>&nbsp;</span>if multiple files require an entire subdirectory. Like<span>&nbsp;</span><a href="https://github.com/sorin-ionescu/prezto/tree/master/modules/docker" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">docker</a>,<span>&nbsp;</span><a href="https://github.com/sorin-ionescu/prezto/tree/master/modules/git" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">git</a>:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zi ice svn
zi snippet PZTM::docker

zi ice svn
zi snippet PZTM::git</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zi ice svn
zi snippet PZTM::docker

zi ice svn
zi snippet PZTM::git" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Use<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zinit ice as"null"</code><span>&nbsp;</span>if don't exist<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">*.plugin.zsh</code>,<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">init.zsh</code>,<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">*.zsh-theme*</code><span>&nbsp;</span>files in module. Like<span>&nbsp;</span><a href="https://github.com/sorin-ionescu/prezto/tree/master/modules/archive" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">archive</a>:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zi ice svn as<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>null<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>
zi snippet PZTM::archive</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zi ice svn as&quot;null&quot;
zi snippet PZTM::archive" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Use<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zinit ice atclone"git clone &lt;repo&gt; &lt;location&gt;"</code><span>&nbsp;</span>if module have external module. Like<span>&nbsp;</span><a href="https://github.com/sorin-ionescu/prezto/tree/master/modules/completion" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">completion</a>:</p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zi ice \
  atclone<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>git clone --recursive https://github.com/zsh-users/zsh-completions.git external<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span> \
  blockf <span class="pl-cce" style="box-sizing: border-box;">\ </span><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> use blockf to prevent any unnecessary additions to fpath, as zinit manages fpath</span>
  svn

zi snippet PZTM::completion</pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zi ice \
  atclone&quot;git clone --recursive https://github.com/zsh-users/zsh-completions.git external&quot; \
  blockf \ # use blockf to prevent any unnecessary additions to fpath, as zinit manages fpath
  svn

zi snippet PZTM::completion" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;"><em style="box-sizing: border-box;">F&amp;A:</em></strong><span>&nbsp;</span>What is<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zstyle</code>?</p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">Read<span>&nbsp;</span><a href="http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html#The-zsh_002fzutil-Module" rel="nofollow" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">zstyle</a><span>&nbsp;</span>doc (more:<span>&nbsp;</span><a href="https://unix.stackexchange.com/questions/214657/what-does-zstyle-do" rel="nofollow" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">What does<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">zstyle</code><span>&nbsp;</span>do?</a>).</p></details>

<details style="box-sizing: border-box; display: block; margin-top: 0px; margin-bottom: 16px; color: rgb(31, 35, 40); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, &quot;Noto Sans&quot;, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><summary style="box-sizing: border-box; display: list-item; cursor: pointer;"><b style="box-sizing: border-box; font-weight: 600;">Migration from Zgen</b></summary><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Oh My Zsh</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">More reference: check<span>&nbsp;</span><strong style="box-sizing: border-box; font-weight: 600;">Migration from Oh-My-ZSH</strong></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load ohmyzsh base</span>
zgen oh-my-zsh
zi snippet OMZL::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>ALL OF THEM<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>

<span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load ohmyzsh plugins</span>
zgen oh-my-zsh <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>
zi snippet OMZ::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>PATH<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span></pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="# Load ohmyzsh base
zgen oh-my-zsh
zi snippet OMZL::<ALL OF THEM>

# Load ohmyzsh plugins
zgen oh-my-zsh <PATH>
zi snippet OMZ::<PATH>" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Prezto</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;">More reference: check<span>&nbsp;</span><strong style="box-sizing: border-box; font-weight: 600;">Migration from Prezto</strong></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);"><span class="pl-c" style="box-sizing: border-box; color: rgb(89, 99, 110);">#</span> Load Prezto</span>
zgen prezto
zi snippet PZTM::<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>COMMENT<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span>s List&gt; # environment terminal editor history directory spectrum utility completion prompt</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"></span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"># Load prezto plugins</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zgen prezto &lt;modulename&gt;</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zi snippet PZTM::&lt;modulename&gt;</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"></span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"># Load a repo as Prezto plugins</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zgen pmodule &lt;reponame&gt; &lt;branch&gt;</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zi ice ver"&lt;branch&gt;"</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zi load &lt;repo/plugin&gt;</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"></span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"># Set prezto options</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zgen prezto &lt;modulename&gt; &lt;option&gt; &lt;value(s)&gt;</span>
<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);">zstyle <span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span></span>:prezto:<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>modulename<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>:<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">'</span> &lt;option&gt; &lt;values(s)&gt; # Set original prezto style</span></pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="# Load Prezto
zgen prezto
zi snippet PZTM::<COMMENT's List> # environment terminal editor history directory spectrum utility completion prompt

# Load prezto plugins
zgen prezto <modulename>
zi snippet PZTM::<modulename>

# Load a repo as Prezto plugins
zgen pmodule <reponame> <branch>
zi ice ver&quot;<branch>&quot;
zi load <repo/plugin>

# Set prezto options
zgen prezto <modulename> <option> <value(s)>
zstyle ':prezto:<modulename>:' <option> <values(s)> # Set original prezto style" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">General</strong></p><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">location</code>: refer<span>&nbsp;</span><a href="https://github.com/zdharma-continuum/zinit#selection-of-files-to-source-" style="box-sizing: border-box; background-color: transparent; color: rgb(9, 105, 218); text-decoration: underline; text-underline-offset: 0.2rem;">Selection of Files</a></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zgen load <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>repo<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span> [location] [branch]

zi ice ver<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>[branch]<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>
zi load <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>repo<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span></pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zgen load <repo> [location] [branch]

zi ice ver&quot;[branch]&quot;
zi load <repo>" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div></details>

<details style="box-sizing: border-box; display: block; margin-top: 0px; margin-bottom: 16px; color: rgb(31, 35, 40); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, &quot;Noto Sans&quot;, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><summary style="box-sizing: border-box; display: list-item; cursor: pointer;"><b style="box-sizing: border-box; font-weight: 600;">Migration from Zplug</b></summary><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Basic</strong></p><div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto" style="box-sizing: border-box; position: relative !important; overflow: auto !important; margin-bottom: 16px; background-color: rgb(246, 248, 250); justify-content: space-between; display: flex;"><pre style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; margin-top: 0px; margin-bottom: 0px; tab-size: 4; overflow-wrap: normal; padding: 16px; color: rgb(31, 35, 40); background-color: rgb(246, 248, 250); border-radius: 6px; line-height: 1.45; overflow: auto; word-break: normal; min-height: 52px;">zplug <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>repo/plugin<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span>, tag1:<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>option<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">1&gt;</span>, tag2:<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>option<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">2&gt;</span>

zi ice tag1<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>&lt;option1&gt;<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span> tag2<span class="pl-s" style="box-sizing: border-box; color: rgb(10, 48, 105);"><span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span>&lt;option2&gt;<span class="pl-pds" style="box-sizing: border-box; color: rgb(10, 48, 105);">"</span></span>
zi load <span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&lt;</span>repo/plugin<span class="pl-k" style="box-sizing: border-box; color: rgb(207, 34, 46);">&gt;</span></pre><div class="zeroclipboard-container" style="box-sizing: border-box; animation: auto ease 0s 1 normal none running none; display: block;"><clipboard-copy aria-label="Copy" class="ClipboardButton btn btn-invisible js-clipboard-copy m-2 p-0 d-flex flex-justify-center flex-items-center" data-copy-feedback="Copied!" data-tooltip-direction="w" value="zplug <repo/plugin>, tag1:<option1>, tag2:<option2>

zi ice tag1&quot;<option1>&quot; tag2&quot;<option2>&quot;
zi load <repo/plugin>" tabindex="0" role="button" style="box-sizing: border-box; padding: 0px !important; font-size: 14px; font-weight: 500; white-space: nowrap; vertical-align: middle; cursor: pointer; user-select: none; appearance: none; border: 0px; border-radius: 6px; line-height: 20px; display: flex !important; position: relative; color: rgb(9, 105, 218); background-color: transparent; box-shadow: none; transition: color 80ms cubic-bezier(0.33, 1, 0.68, 1), background-color 80ms cubic-bezier(0.33, 1, 0.68, 1), box-shadow 80ms cubic-bezier(0.33, 1, 0.68, 1), border-color 80ms cubic-bezier(0.33, 1, 0.68, 1); justify-content: center !important; align-items: center !important; margin: 8px !important; width: 28px; height: 28px;"><svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon"></svg></clipboard-copy></div></div><p dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px;"><strong style="box-sizing: border-box; font-weight: 600;">Tag comparison</strong></p><ul dir="auto" style="box-sizing: border-box; margin-top: 0px; margin-bottom: 16px; padding-left: 2em;"><li style="box-sizing: border-box;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">as</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">as</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">use</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">pick</code>,<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">src</code>,<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">multisrc</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">ignore</code><span>&nbsp;</span>=&gt; None</li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">from</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">from</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">at</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">ver</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">rename-to</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">mv</code>,<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">cp</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">dir</code><span>&nbsp;</span>=&gt; Selection(<code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">pick</code>, ...) with rename</li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">if</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">if</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">hook-build</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">atclone</code>,<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">atpull</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">hook-load</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">atload</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">frozen</code><span>&nbsp;</span>=&gt; None</li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">on</code><span>&nbsp;</span>=&gt; None</li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">defer</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">wait</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">lazy</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">autoload</code></li><li style="box-sizing: border-box; margin-top: 0.25em;"><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">depth</code><span>&nbsp;</span>=&gt;<span>&nbsp;</span><code style="box-sizing: border-box; font-family: &quot;Monaspace Neon&quot;, ui-monospace, SFMono-Regular, &quot;SF Mono&quot;, Menlo, Consolas, &quot;Liberation Mono&quot;, monospace; font-size: 13.6px; tab-size: 4; white-space: break-spaces; background-color: rgba(129, 139, 152, 0.12); border-radius: 6px; margin: 0px; padding: 0.2em 0.4em;">depth</code></li></ul></details>

### More Examples



After installing Zinit you can start adding some actions (load some plugins) to `~/.zshrc`, at bottom. Some examples:

```
# Load the pure theme, with zsh-async library that's bundled with it.
zi ice pick"async.zsh" src"pure.zsh"
zi light sindresorhus/pure

# A glance at the new for-syntax – load all of the above
# plugins with a single command. For more information see:
# https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/
zinit for \
    light-mode \
  zsh-users/zsh-autosuggestions \
    light-mode \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
    light-mode \
    pick"async.zsh" \
    src"pure.zsh" \
  sindresorhus/pure

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zi ice from"gh-r" as"program"
zi light junegunn/fzf

# One other binary release, it needs renaming from `docker-compose-Linux-x86_64`.
# This is done by ice-mod `mv'{from} -> {to}'. There are multiple packages per
# single version, for OS X, Linux and Windows – so ice-mod `bpick' is used to
# select Linux package – in this case this is actually not needed, Zinit will
# grep operating system name and architecture automatically when there's no `bpick'.
zi ice from"gh-r" as"program" mv"docker* -> docker-compose" bpick"*linux*"
zi load docker/compose

# Vim repository on GitHub – a typical source code that needs compilation – Zinit
# can manage it for you if you like, run `./configure` and other `make`, etc.
# Ice-mod `pick` selects a binary program to add to $PATH. You could also install the
# package under the path $ZPFX, see: https://zdharma-continuum.github.io/zinit/wiki/Compiling-programs
zi ice \
  as"program" \
  atclone"rm -f src/auto/config.cache; ./configure" \
  atpull"%atclone" \
  make \
  pick"src/vim"
zi light vim/vim

# Scripts built at install (there's single default make target, "install",
# and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
# `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only default target.
zi ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zi light tj/git-extras

# Handle completions without loading any plugin; see "completions" command.
# This one is to be ran just once, in interactive session.
zi creinstall %HOME/my_completions
```



```
# For GNU ls (the binaries can be gls, gdircolors, e.g. on OS X when installing the
# coreutils package from Homebrew; you can also use https://github.com/ogham/exa)
zi ice atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
zi light trapd00r/LS_COLORS
```



[You can see an extended explanation of LS_COLORS in the Wiki.](https://zdharma-continuum.github.io/zinit/wiki/LS_COLORS-explanation/)

```
# make'!...' -> run make before atclone & atpull
zi ice as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' src"zhook.zsh"
zi light direnv/direnv
```



[You can see an extended explanation of direnv in the Wiki.](https://zdharma-continuum.github.io/zinit/wiki/Direnv-explanation/)

If you're interested in more examples, then check out the [zinit-configs repository](https://github.com/zdharma-continuum/zinit-configs), where users have uploaded their `~/.zshrc` and Zinit configurations. Feel free to [submit](https://github.com/zdharma-continuum/zinit-configs/issues/new?template=request-to-add-zshrc-to-the-zinit-configs-repo.md) your `~/.zshrc` there if it contains Zinit commands.

You can also check out the [Gallery of Zinit Invocations](https://zdharma-continuum.github.io/zinit/wiki/GALLERY/) for some additional examples.

Also, two articles on the Wiki present a [Minimal Setup](https://zdharma-continuum.github.io/zinit/wiki/Example-Minimal-Setup/) and [Oh-My-Zsh Setup](https://zdharma-continuum.github.io/zinit/wiki/Example-Oh-My-Zsh-setup/).

# How to Use



## Ice Modifiers



Following `ice` modifiers are to be [passed](https://zdharma-continuum.github.io/zinit/wiki/Alternate-Ice-Syntax/) to `zinit ice ...` to obtain described effects. The word `ice` means something that's added (like ice to a drink) – and in Zinit it means adding modifier to a next `zinit` command, and also something that's temporary because it melts – and this means that the modification will last only for a **single** next `zinit` command.

Some Ice-modifiers are highlighted and clicking on them will take you to the appropriate Wiki page for an extended explanation.

You may safely assume a given ice works with both plugins and snippets unless explicitly stated otherwise.

### Cloning Options



| Modifier    | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `bpick`     | Used to select which release from GitHub Releases to download, e.g. `zini ice from"gh-r" as"program" bpick"*Darwin*"; zini load docker/compose`. **Does not work with snippets.** |
| `cloneopts` | Pass the contents of `cloneopts` to `git clone`. Defaults to `--recursive`. I.e.: change cloning options. Pass empty ice to disable recursive cloning. **Does not work with snippets.** |
| `depth`     | Pass `--depth` to `git`, i.e. limit how much of history to download. **Does not work with snippets.** |
| `from`      | Clone plugin from given site. Supported are `from"github"` (default), `..."github-rel"`, `..."gitlab"`, `..."bitbucket"`, `..."notabug"` (short names: `gh`, `gh-r`, `gl`, `bb`, `nb`). Can also be a full domain name (e.g. for GitHub enterprise). **Does not work with snippets.** |
| `proto`     | Change protocol to `git`,`ftp`,`ftps`,`ssh`, `rsync`, etc. Default is `https`. **Does not work with snippets.** |
| `pullopts`  | Pass the contents of `pullopts` to `git pull` used when updating plugins. **Does not work with snippets.** |
| `svn`       | Use Subversion for downloading snippet. GitHub supports `SVN` protocol, this allows to clone subdirectories as snippets, e.g. `zinit ice svn; zinit snippet OMZP::git`. Other ice `pick` can be used to select file to source (default are: `*.plugin.zsh`, `init.zsh`, `*.zsh-theme`). **Does not work with plugins.** |
| `ver`       | Used with `from"gh-r"` (i.e. downloading a binary release, e.g. for use with `as"program"`) – selects which version to download. Default is latest, can also be explicitly `ver"latest"`. Works also with regular plugins and packages (`pack` ice) checkouts e.g. `ver"abranch"`, i.e. a specific version. **Does not work with snippets.** |

### Selection of Files (To Source, …)



| Modifier   | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `multisrc` | Allows to specify multiple files for sourcing, enumerated with spaces as the separators (e.g. `multisrc'misc.zsh grep.zsh'`) and also using brace-expansion syntax (e.g. `multisrc'{misc,grep}.zsh'`). Supports patterns. |
| `pick`     | Select the file to source, or the file to set as command (when using `snippet --command` or the ice `as"program"`); it is a pattern, alphabetically first matched file is being chosen; e.g. `zinit ice pick"*.plugin.zsh"; zinit load …`. |
| `src`      | Specify additional file to source after sourcing main file or after setting up command (via `as"program"`). It is not a pattern but a plain file name. |

### Conditional Loading



| Modifier                     | Description                                                  |
| ---------------------------- | ------------------------------------------------------------ |
| `cloneonly`                  | Don't load the plugin / snippet, only download it            |
| `has`                        | Load plugin or snippet only when given command is available (in $PATH), e.g. `zinit ice has'git' ...` |
| `if`                         | Load plugin or snippet only when given condition is fulfilled, for example: `zinit ice if'[[ -n "$commands[otool]" ]]'; zinit load ...`. |
| `load`                       | A condition to check which should cause plugin to load. It will load once, the condition can be still true, but will not trigger second load (unless plugin is unloaded earlier, see `unload` below). E.g.: `load'[[ $PWD = */github* ]]'`. |
| `subscribe` / `on-update-of` | Postpone loading of a plugin or snippet until the given file(s) get updated, e.g. `subscribe'{~/files-*,/tmp/files-*}'` |
| `trigger-load`               | Creates a function that loads the associated plugin/snippet, with an option (to use it, precede the ice content with `!`) to automatically forward the call afterwards, to a command of the same name as the function. Can obtain multiple functions to create – separate with `;`. |
| `unload`                     | A condition to check causing plugin to unload. It will unload once, then only if loaded again. E.g.: `unload'[[ $PWD != */github* ]]'`. |
| `wait`                       | Postpone loading a plugin or snippet. For `wait'1'`, loading is done `1` second after prompt. For `wait'[[ ... ]]'`, `wait'(( ... ))'`, loading is done when given condition is meet. For `wait'!...'`, prompt is reset after load. Zsh can start 80% (i.e.: 5x) faster thanks to postponed loading. **Fact:** when `wait` is used without value, it works as `wait'0'`. |

### Plugin Output



| Modifier | Description                                                  |
| -------- | ------------------------------------------------------------ |
| `lucid`  | Skip `Loaded ...` message under prompt for `wait`, etc. loaded plugins (a subset of `silent`). |
| `notify` | Output given message under-prompt after successfully loading a plugin/snippet. In case of problems with the loading, output a warning message and the return code. If starts with `!` it will then always output the given message. Hint: if the message is empty, then it will just notify about problems. |
| `silent` | Mute plugin's or snippet's `stderr` & `stdout`. Also skip `Loaded ...` message under prompt for `wait`, etc. loaded plugins, and completion-installation messages. |

### Completions



| Modifier        | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| `blockf`        | Disallow plugin to modify `fpath`. Useful when a plugin wants to provide completions in traditional way. Zinit can manage completions and plugin can be blocked from exposing them. |
| `completions`   | Do detect, install and manage completions for this plugin. Overwrites `as'null'` or `nocompletions`. |
| `nocompletions` | Don't detect, install and manage completions for this plugin. Completions can be installed later with `zinit creinstall {plugin-spec}`. |

### Command Execution After Cloning, Updating or Loading



| Modifier     | Description                                                  |
| ------------ | ------------------------------------------------------------ |
| `atclone`    | Run command after cloning, within plugin's directory, e.g. `zinit ice atclone"echo Cloned"`. Ran also after downloading snippet. |
| `atinit`     | Run command after directory setup (cloning, checking it, etc.) of plugin/snippet but before loading. |
| `atload`     | Run command after loading, within plugin's directory. Can be also used with snippets. Passed code can be preceded with `!`, it will then be investigated (if using `load`, not `light`). |
| `atpull`     | Run command after updating (**only if new commits are waiting for download**), within plugin's directory. If starts with "!" then command will be ran before `mv` & `cp` ices and before `git pull` or `svn update`. Otherwise it is ran after them. Can be `atpull'%atclone'`, to repeat `atclone` Ice-mod. |
| `configure`  | Runs `./configure` script and by default changes the installation directory by passing `--prefix=$ZPFX` to the script. Runs before `make''` and after `make'!'`, you can pass `'!'` too to this ice (i.e.: `configure'!'`) to make it execute earlier – before `make'!'` and after `make'!!'`. If `#` given in the ice value then also executes script `./autogen.sh` first before running `./configure`. The script is run anyway if there is no `configure` script. Also, when there exist another build-system related files, then it is run if no `configure` script is found. Currently supported systems are: CMake, scons and meson, checked-for/run in this order |
| `countdown`  | Causes an interruptable (by Ctrl-C) countdown 5…4…3…2…1…0 to be displayed before executing `atclone''`,`atpull''` and `make` ices |
| `cp`         | Copy file after cloning or after update (then, only if new commits were downloaded). Example: `cp "docker-c* -> dcompose"`. Ran after `mv`. |
| `make`       | Run `make` command after cloning/updating and executing `mv`, `cp`, `atpull`, `atclone` Ice mods. Can obtain argument, e.g. `make"install PREFIX=/opt"`. If the value starts with `!` then `make` is ran before `atclone`/`atpull`, e.g. `make'!'`. |
| `mv`         | Move file after cloning or after update (then, only if new commits were downloaded). Example: `mv "fzf-* -> fzf"`. It uses `->` as separator for old and new file names. Works also with snippets. |
| `nocd`       | Don't switch the current directory into the plugin's directory when evaluating the above ice-mods `atinit''`,`atload''`, etc. |
| `reset`      | Invokes `git reset --hard HEAD` for plugins or `svn revert` for SVN snippets before pulling any new changes. This way `git` or `svn` will not report conflicts if some changes were done in e.g.: `atclone''` ice. For file snippets and `gh-r` plugins it invokes `rm -rf *`. |
| `run-atpull` | Always run the atpull hook (when updating), not only when there are new commits to be downloaded. |

### Sticky-Emulation Of Other Shells



| Modifier       | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `sh`/`!sh`     | Source the plugin's (or snippet's) script with `sh` emulation so that also all functions declared within the file will get a *sticky* emulation assigned – when invoked they'll execute also with the `sh` emulation set-up. The `!sh` version switches additional options that are rather not important from the portability perspective. |
| `csh`/`!csh`   | The same as `sh`, but emulating `csh` shell.                 |
| `ksh`/`!ksh`   | The same as `sh`, but emulating `ksh` shell.                 |
| `bash`/`!bash` | The same as `sh`, but with the `SH_GLOB` option disabled, so that Bash regular expressions work. |

### Others



| Modifier       | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `as`           | Can be `as"program"` (also the alias: `as"command"`), and will cause to add script/program to `$PATH` instead of sourcing (see `pick`). Can also be `as"completion"` – use with plugins or snippets in whose only underscore-starting `_*` files you are interested in. The third possible value is `as"null"` – a shorthand for `pick"/dev/null" nocompletions` – i.e.: it disables the default script-file sourcing and also the installation of completions. |
| `link`         | Use a symlink to cache a local snippet instead of copying into the snippets directory. Uses relative links if realpath >= 8.23 is found. ***Does not apply to URL-based snippets. Does not work with plugins.\*** |
| `id-as`        | Nickname a plugin or snippet, to e.g. create a short handler for long-url snippet. |
| `subst`        | Substitute the given string into another string when sourcing the plugin script, e.g.: `zinit subst'autoload → autoload -Uz' …`. |
| `aliases`      | Load the plugin with the aliases mechanism enabled. Use with plugins that define **and use** aliases in their scripts. |
| `autoload`     | Autoload the given functions (from their files). Equivalent to calling `atinit'autoload the-function'`. Supports renaming of the function – pass `'… → new-name'` or `'… -> new-name'`, e.g.: `zinit autoload'fun → my-fun; fun2 → my-fun2'`. |
| `bindmap`      | To hold `;`-separated strings like `Key(s)A -> Key(s)B`, e.g. `^R -> ^T; ^A -> ^B`. In general, `bindmap''`changes bindings (done with the `bindkey` builtin) the plugin does. The example would cause the plugin to map Ctrl-T instead of Ctrl-R, and Ctrl-B instead of Ctrl-A. **Does not work with snippets.** |
| `compile`      | Pattern (+ possible `{...}` expansion, like `{a/*,b*}`) to select additional files to compile, e.g. `compile'*.zsh'`. |
| `extract`      | Performs archive extraction supporting multiple formats like `zip`, `tar.gz`, etc. and also notably OS X `dmg` images. If it has no value, then it works in the *auto* mode – it automatically extracts all files of known archive extensions IF they aren't located deeper than in a sub-directory (this is to prevent extraction of some helper archive files, typically located somewhere deeper in the tree). If no such files will be found, then it extracts all found files of known **type** – the type is being read by the `file` Unix command. If not empty, then takes names of the files to extract. Refer to the Wiki page for further information. |
| `service`      | Make following plugin or snippet a *service*, which will be ran in background, and only in single Zshell instance. See [the zservice-* repositories](https://github.com/orgs/zdharma-continuum/repositories?q=zservice-). |
| `light-mode`   | Load the plugin without the investigating, i.e.: as if it would be loaded with the `light` command. Useful for the for-syntax, where there is no `load` nor `light` subcommand |
| `nocompile`    | Don't try to compile `pick`-pointed files. If passed the exclamation mark (i.e. `nocompile'!'`), then do compile, but after `make''` and `atclone''` (useful if Makefile installs some scripts, to point `pick''` at the location of their installation). |
| `trackbinds`   | Shadow but only `bindkey` calls even with `zinit light ...`, i.e. even with investigating disabled (fast loading), to allow `bindmap` to remap the key-binds. The same effect has `zinit light -b ...`, i.e. additional `-b` option to the `light`-subcommand. **Does not work with snippets.** |
| `wrap-track`   | Takes a `;`-separated list of function names that are to be investigated (meaning gathering report and unload data) **once** during execution. It works by wrapping the functions with a investigating-enabling and disabling snippet of code. In summary, `wrap-track` allows to extend the investigating beyond the moment of loading of a plugin. Example use is to `wrap-track` a precmd function of a prompt (like `_p9k_precmd()` of powerlevel10k) or other plugin that *postpones its initialization till the first prompt* (like e.g.: zsh-autosuggestions). **Does not work with snippets.** |
| `reset-prompt` | Reset the prompt after loading the plugin/snippet (by issuing `zle .reset-prompt`). Note: normally it's sufficient to precede the value of `wait''` ice with `!`. |

### Order of Execution



Order of execution of related Ice-mods: `atinit` -> `atpull!` -> `make'!!'` -> `mv` -> `cp` -> `make!` -> `atclone`/`atpull` -> `make` -> `(plugin script loading)` -> `src` -> `multisrc` -> `atload`.

## Zinit Commands



Following commands are passed to `zinit ...` to obtain described effects.

### Help



| Command   | Description           |
| --------- | --------------------- |
| `help`    | Usage information.    |
| `man`     | Manual.               |
| `version` | Display Zinit version |

### Loading and Unloading



| Command                  | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `load {plg-spec}`        | Load plugin, can also receive absolute local path.           |
| `snippet [-f] {url}`     | Source local or remote file (by direct URL). `-f` – don't use cache (force redownload). The URL can use the following shorthands: `PZT::` (Prezto), `PZTM::` (Prezto module), `OMZ::` (Oh My Zsh), `OMZP::` (OMZ plugin), `OMZL::` (OMZ library), `OMZT::` (OMZ theme), e.g.: `PZTM::environment`, `OMZP::git`, etc. |
| `light [-b] {plg-spec}`  | Light plugin load, without reporting/investigating. `-b` – investigate `bindkey`-calls only. There's also `light-mode` ice which can be used to induce the no-investigating (i.e.: *light*) loading, regardless of the command used. |
| `unload [-q] {plg-spec}` | Unload plugin loaded with `zinit load ...`. `-q` – quiet.    |

### Completions



| Command                           | Description                                                  |
| --------------------------------- | ------------------------------------------------------------ |
| `cclear`                          | Clear stray and improper completions.                        |
| `cdclear [-q]`                    | Clear compdef replay list. `-q` – quiet.                     |
| `cdisable {cname}`                | Disable completion `cname`.                                  |
| `cdlist`                          | Show compdef replay list.                                    |
| `cdreplay [-q]`                   | Replay compdefs (to be done after compinit). `-q` – quiet.   |
| `cenable {cname}`                 | Enable completion `cname`.                                   |
| `completions \[*columns*\]`       | List completions in use, with `columns` completions per line. `zpl clist 5` will for example print 5 completions per line. Default is 3. |
| `compinit`                        | Refresh installed completions.                               |
| `creinstall [-q] [-Q] {plg-spec}` | Install completions for plugin, can also receive absolute local path. `-q` – quiet. `-Q` - quiet all. |
| `csearch`                         | Search for available completions from any plugin.            |
| `cuninstall {plg-spec}`           | Uninstall completions for plugin.                            |

### Tracking of the Active Session



| Command          | Description                                       |
| ---------------- | ------------------------------------------------- |
| `dclear`         | Clear report of what was going on in session.     |
| `dstop`          | Stop investigating what's going on in session.    |
| `dreport`        | Report what was going on in session.              |
| `dunload`        | Revert changes recorded between dstart and dstop. |
| `dtrace, dstart` | Start investigating what's going on in session.   |

### Reports and Statistics



| Command                  | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `bindkeys`               | Lists bindkeys set up by each plugin.                        |
| `list-plugins [keyword]` | Show what plugins are loaded (filter with 'keyword').        |
| `list-snippets`          | List snippets in formatted and colorized manner. Requires `tree` program. |
| `recently [time-spec]`   | Show plugins that changed recently, argument is e.g. 1 month 2 days. |
| `report {plg-spec}`      | Show plugin report. `--all` – do it for all plugins.         |
| `status {plg-spec}`      | Git status for plugin or svn status for snippet. `--all` – do it for all plugins and snippets. |
| `zstatus`                | Display brief statistics for your Zinit installation.        |
| `times [-a] [-m] [-s]`   | Print load times for each plugin. `-s` – Times are printed in seconds. `-m` – Show plugin loading moments. `-a` - Times and loading moments are printed. |

### Compiling



#### compile



List plugins that are compiled.

```
zinit [options] compile PLUGIN
```



| Option        | Description               |
| ------------- | ------------------------- |
| `-a, --all`   | Compile all plugins       |
| `-h, --help`  | Print usage               |
| `-q, --quiet` | Suppress the build output |

#### compiled



List plugins that are compiled.

```
zinit compiled
```



#### uncompile



List plugins that are compiled.

```
zinit [options] uncompile PLUGIN
```



| Option        | Description                               |
| ------------- | ----------------------------------------- |
| `-a, --all`   | Remove any compiled files for all plugins |
| `-h, --help`  | Print usage                               |
| `-q, --quiet` | Suppress the output                       |

### Other



| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `module`                                                     | Manage binary Zsh module shipped with Zinit, see `zinit module help`. |
| `self-update`                                                | Updates and compiles Zinit.                                  |
| `cd {plg-spec}`                                              | Cd into plugin's directory. Also support snippets if fed with URL. |
| `edit {plg-spec}`                                            | Edit plugin's file with $EDITOR.                             |
| `changes {plg-spec}`                                         | View plugin's git log.                                       |
| `create {plg-spec}`                                          | Create plugin (also together with GitHub repository).        |
| `glance {plg-spec}`                                          | Look at plugin's source (pygmentize, {,source-}highlight).   |
| `stress {plg-spec}`                                          | Test plugin for compatibility with set of options.           |
| `recall {plg-spec}|URL`                                      | Fetch saved ice modifiers and construct `zinit ice ...` command. |
| `srv {service-id} [cmd]`                                     | Control a service, command can be: stop,start,restart,next,quit; `next` moves the service to another Zshell. |
| `ice <ice specification>`                                    | Add ice to next command, argument is e.g. from"gitlab".      |
| `env-whitelist [-v] [-h] {env..}`                            | Allows to specify names (also patterns) of variables left unchanged during an unload. `-v` – verbose. |
| `run` `[-l]` `[plugin]` `{command}`                          | Runs the given command in the given plugin's directory. If the option `-l` will be given then the plugin should be skipped – the option will cause the previous plugin to be reused. |
| `delete {plg-spec}|URL|--clean|--all`                        | Remove plugin or snippet from disk (good to forget wrongly passed ice-mods). `--all` – purge. `--clean` – delete plugins and snippets that are not loaded. |
| `update [-q] [-r] {plg-spec}|URL|--all`                      | Git update plugin or snippet. `--all` – update all plugins and snippets. `-q` – quiet. `-r` | `--reset` – run `git reset --hard` / `svn revert` before pulling changes. |
| `add-fpath|fpath` `[-f|--front]` `{plg-spec}` `[subdirectory]` | Adds given plugin (not yet snippet) directory to `$fpath`. If the second argument is given, it is appended to the directory path. If the option `-f`/`--front` is given, the directory path is prepended instead of appended to `$fpath`. The `{plg-spec}` can be absolute path, i.e.: it's possible to also add regular directories. |

## Updating Zinit and Plugins



To update Zinit issue `zinit self-update` in the command line.

To update all plugins and snippets, issue `zinit update`. If you wish to update only a single plugin/snippet instead issue `zinit update NAME_OF_PLUGIN`. A list of commits will be shown:

[![screenshot displaying zinit update tj/git-extras and its output](./zinit-install.assets/update.png)](https://github.com/zdharma-continuum/zinit/blob/main/doc/img/update.png)

Some plugins require performing an action each time they're updated. One way you can do this is by using the `atpull` ice modifier. For example, writing `zinit ice atpull'./configure'` before loading a plugin will execute `./configure` after a successful update. Refer to [Ice Modifiers](https://github.com/zdharma-continuum/zinit#ice-modifiers) for more information.

The ice modifiers for any plugin or snippet are stored in their directory in a `._zinit` subdirectory, hence the plugin doesn't have to be loaded to be correctly updated. There's one other file created there, `.zinit_lstupd` – it holds the log of the new commits pulled-in in the last update.

## Completions



### Calling `compinit` Without Turbo Mode



With no Turbo mode in use, compinit can be called normally, i.e.: as `autoload compinit; compinit`. This should be done after loading of all plugins and before possibly calling `zinit cdreplay`.

The `cdreplay` subcommand is provided to re-play all caught `compdef` calls. The `compdef` calls are used to define a completion for a command. For example, `compdef _git git` defines that the `git` command should be completed by a `_git` function.

The `compdef` function is provided by `compinit` call. As it should be called later, after loading all of the plugins, Zinit provides its own `compdef` function that catches (i.e.: records in an array) the arguments of the call, so that the loaded plugins can freely call `compdef`. Then, the `cdreplay` (*compdef-replay*) can be used, after `compinit` will be called (and the original `compdef` function will become available), to execute all detected `compdef` calls. To summarize:

```
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

zinit load "some/plugin"
...
compdef _gnu_generic fd  # this will be intercepted by Zinit, because as the compinit
                         # isn't yet loaded, thus there's no such function `compdef'; yet
                         # Zinit provides its own `compdef' function which saves the
                         # completion-definition for later possible re-run with `zinit
                         # cdreplay' or `zicdreplay' (the second one can be used in hooks
                         # like atload'', atinit'', etc.)
...
zinit load "other/plugin"

autoload -Uz compinit
compinit

# -q is for quiet; actually run all the `compdef's saved before `compinit` call
# (`compinit' declares the `compdef' function, so it cannot be used until
# `compinit' is ran; Zinit solves this via intercepting the `compdef'-calls and
# storing them for later use with `zinit cdreplay')

zinit cdreplay -q
```



This allows to call compinit once. Performance gains are huge, example shell startup time with double `compinit`: **0.980** sec, with `cdreplay` and single `compinit`: **0.156** sec.

### Calling `compinit` With Turbo Mode



If you load completions using `wait''` Turbo mode then you can add `atinit'zicompinit'` to syntax-highlighting plugin (which should be the last one loaded, as their (2 projects, [z-sy-h](https://github.com/zsh-users/zsh-syntax-highlighting) & [f-sy-h](https://github.com/zdharma-continuum/fast-syntax-highlighting)) documentation state), or `atload'zicompinit'` to last completion-related plugin. `zicompinit` is a function that just runs `autoload compinit; compinit`, created for convenience. There's also `zicdreplay` which will replay any caught compdefs so you can also do: `atinit'zicompinit; zicdreplay'`, etc. Basically, the whole topic is the same as normal `compinit` call, but it is done in `atinit` or `atload` hook of the last related plugin with use of the helper functions (`zicompinit`,`zicdreplay` & `zicdclear` – see below for explanation of the last one). To summarize:

```
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share/zinit}"
source "${ZINIT_HOME}/zinit.zsh"

# Load using the for-syntax
zinit lucid wait for \
  "some/plugin"

zinit lucid wait for \
  "other/plugin"

zi for \
    atload"zicompinit; zicdreplay" \
    blockf \
    lucid \
    wait \
  zsh-users/zsh-completions
```



### Ignoring Compdefs



If you want to ignore compdefs provided by some plugins or snippets, place their load commands before commands loading other plugins or snippets, and issue `zinit cdclear` (or `zicdclear`, designed to be used in hooks like `atload''`):

```
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

zi snippet OMZP::git
zi cdclear -q # <- forget completions provided by Git plugin

zi load "some/plugin"
...
zi load "other/plugin"

autoload -Uz compinit
compinit
zi cdreplay -q # <- execute compdefs provided by rest of plugins
zi cdlist # look at gathered compdefs
```



The `cdreplay` is important if you use plugins like `OMZP::kubectl` or `asdf-vm/asdf`, because these plugins call `compdef`.

### Disabling System-Wide `compinit` Call



On some systems, users might be surprised to see that completions work even though they didn’t call `compinit` in their `~/.zshrc`. This happens because `compinit` is being called from `/etc/zshrc`. To disable this behavior -- which is recommended to avoid slow startup, especially if you load plugins that bring their own completions (which is almost always the case) -- follow the instructions for your system below:

#### Ubuntu



On Ubuntu, the global `compinit` call can be disabled on a per-user basis by adding the following lines to a users `~/.zshenv`:

```
# Skip the not really helping Ubuntu global compinit
skip_global_compinit=1
```



#### NixOS



On NixOS, the global `compinit` call can be disabled system-wide by setting the following option in your `/etc/nixos/configuration.nix`:

```
# Disable global completion init to speed up `compinit` call in `~/.zshrc`.
programs.zsh.enableGlobalCompInit = false;
```



Don't forget to add the `compinit` call to every user's `~/.zshrc`! Otherwise completions for system packages might not work.

## Zinit Module



The module is now hosted [in its own repository](https://github.com/zdharma-continuum/zinit-module)

## Hints and Tips



### Using ZPFX variable



Zinit uses a special, short named variable `$ZPFX` to denote a standard "prefix" for installing compiled software. Such, commonly used, prefixes are usually, e.g.: `/usr/`,`/usr/local` or `$HOME/.local`. Basically, when one would want to explain what a prefix-dir is in one sentence, it would be something like: a root directory, under which `…/bin`,`…/share`, `…/lib` sub-dirs are populated with installed binaries, data-files, libraries, etc.

How to use the variable? It is automatically exploited when using `configure''` and `make''` ices, and user doesn't have to take any actions. This means that the `configure` command that'll be run will be:

```
./configure --prefix=$ZPFX
```



The default location used for `$ZPFX` is: `~/.local/share/zinit/polaris`. You can, for example, set it to `$HOME/.local` to have the software installed with `configure''` and `make''` ices installed to that directory.

Typical use cases when working with `$ZPFX` are, e.g.:

```
ls $ZPFX
cd $ZPFX
cd $ZPFX/bin  # note: $ZPFX/bin is automatically prepended to $PATH
cd $ZPFX/share
```



Before the `configure''` ice appeared one would use `$ZPFX` as follows:

```
zinit atclone'./configure --prefix=$ZPFX` atpull'%atclone' make \
        for universal-ctags/ctags
```



but now it's sufficient to do:

```
# Will work for any build system
# (supported are: configure, cmake, scons and meson)
zinit configure make for universal-ctags/ctags
```



To set ZPFX, one should do (in `.zshrc` before loading `zinit`):

```
export ZPFX=$HOME/my-software # or: ZPFX=$HOME/.local, etc.
```



We encourage people to install compiled software with use of `$ZPFX` and `configure''` and `make''` ices, to have a nice, clean user-home dir based setup.

### Customizing Paths



Following variables can be set to custom values, before sourcing Zinit. The previous global variables like `$ZPLG_HOME` have been removed to not pollute the namespace – there's single `$ZINIT` hash instead of `8` string variables. Please update your dotfiles.

```
declare -A ZINIT  # initial Zinit's hash definition, if configuring before loading Zinit, and then:
```



| Hash Field                        | Description                                                  |
| --------------------------------- | ------------------------------------------------------------ |
| ZINIT[BIN_DIR]                    | Where Zinit code resides, e.g.: "~/.local/share/zinit/zinit.git" |
| ZINIT[HOME_DIR]                   | Where Zinit should create all working directories, e.g.: "~/.local/share/zinit" |
| ZINIT[MAN_DIR]                    | Directory where plugins can store their manpages (`atclone"cp -vf myplugin.1 $ZINIT[MAN_DIR]/man1"`). If overridden, this directory will not necessarily be used by `man` (See #8). Default: `$ZPFX/man` |
| ZINIT[PLUGINS_DIR]                | Override single working directory – for plugins, e.g. "/opt/zsh/zinit/plugins" |
| ZINIT[COMPLETIONS_DIR]            | As above, but for completion files, e.g. "/opt/zsh/zinit/root_completions" |
| ZINIT[SNIPPETS_DIR]               | As above, but for snippets                                   |
| ZINIT[LIST_COMMAND]               | Command to use for displaying a directory tree (e.g., `ls --tree`, `tree`, etc.) |
| ZINIT[ZCOMPDUMP_PATH]             | Path to `.zcompdump` file, with the file included (i.e. its name can be different) |
| ZINIT[COMPINIT_OPTS]              | Options for `compinit` call (i.e. done by `zicompinit`), use to pass -C to speed up loading |
| ZINIT[MUTE_WARNINGS]              | If set to `1`, then mutes some of the Zinit warnings, specifically the `plugin already registered` warning |
| ZINIT[OPTIMIZE_OUT_DISK_ACCESSES] | If set to `1`, then Zinit will skip checking if a Turbo-loaded object exists on the disk. By default Zinit skips Turbo for non-existing objects (plugins or snippets) to install them before the first prompt – without any delays, during the normal processing of `zshrc`. This option can give a performance gain of about 10 ms out of 150 ms (i.e.: Zsh will start up in 140 ms instead of 150 ms). |
| ZINIT[NO_ALIASES]                 | If set to `1`, then Zinit will not set aliases such as `zi` or `zini` |

There is also `$ZPFX`, set by default to `~/.local/share/zinit/polaris` – a directory where software with `Makefile`, etc. can be pointed to, by e.g. `atclone'./configure --prefix=$ZPFX'`.

### Non-GitHub (Local) Plugins



Use `create` subcommand with user name `_local` (the default) to create plugin's skeleton in `$ZINIT[PLUGINS_DIR]`. It will be not connected with GitHub repository (because of user name being `_local`). To enter the plugin's directory use `cd` command with just plugin's name (without `_local`, it's optional).

If user name will not be `_local`, then Zinit will create repository also on GitHub and setup correct repository origin.

### Extending Git



There are several projects that provide git extensions. Installing them with Zinit has many benefits:

- all files are under `$HOME` – no administrator rights needed,
- declarative setup (like Chef or Puppet) – copying `.zshrc` to different account brings also git-related setup,
- easy update by e.g. `zinit update --all`.

Below is a configuration that adds multiple git extensions, loaded in Turbo mode, 1 second after prompt, with use of the [Bin-Gem-Node](https://github.com/zdharma-continuum/zinit-annex-bin-gem-node) annex:

```
zi as'null' lucid sbin wait'1' for \
  Fakerr/git-recall \
  davidosomething/git-my \
  iwata/git-now \
  paulirish/git-open \
  paulirish/git-recent \
    atload'export _MENU_THEME=legacy' \
  arzzen/git-quick-stats \
    make'install' \
  tj/git-extras \
    make'GITURL_NO_CGITURL=1' \
    sbin'git-url;git-guclone' \
  zdharma-continuum/git-url
```



Target directory for installed files is `$ZPFX` (`~/.local/share/zinit/polaris` by default).



# Introduction[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#introduction)

In the document below you’ll find out how to:

- use Oh My Zsh and Prezto,
- manage completions,
- use the Turbo mode,
- use the ice-mods like `as"program"`,

and much more.

## Basic Plugin Loading[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#basic_plugin_loading)

```zsh
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-syntax-highlighting
```

Above commands show two ways of basic plugin loading. `load `causes reporting to be enabled – you can track what plugin does, view the information with `zinit report {plugin-spec}` and then also unload the plugin with `zinit unload {plugin-spec}`. `light` is a significantly faster loading without tracking and reporting, by using which user resigns of the ability to view the plugin report and to unload it.

Note

**In Turbo mode the slowdown caused by tracking is negligible.**

## Oh My Zsh, Prezto[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#oh_my_zsh_prezto)

To load Oh My Zsh and Prezto plugins, use `snippet` feature. Snippets are single files downloaded by `curl`, `wget`, etc. (an automatic detection of the download tool is being performed) directly from URL. For example:

```zsh
zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'
zinit snippet 'https://github.com/sorin-ionescu/prezto/blob/master/modules/helper/init.zsh'
```

Also, for Oh My Zsh and Prezto, you can use `OMZ::` and `PZT::` shorthands:

```zsh
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet PZT::modules/helper/init.zsh
```

Moreover, snippets support Subversion protocol, supported also by Github. This allows to load snippets that are multi-file (for example, a Prezto module can consist of two or more files, e.g. `init.zsh` and `alias.zsh`). Default files that will be sourced are: `*.plugin.zsh`, `init.zsh`, `*.zsh-theme`:

```zsh
# URL points to directory
zinit ice svn
zinit snippet PZT::modules/docker
```

## Snippets and Performance[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#snippets_and_performance)

Using `curl`, `wget`, etc. along with Subversion allows to almost completely avoid code dedicated to Oh My Zsh and Prezto, and also to other frameworks. This gives profits in performance of `Zinit`, it is really fast and also compact (causing low memory footprint and short loading time).

## Some Ice-Modifiers[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#some_ice-modifiers)

The command `zinit ice` provides ice-modifiers for single next command (see the README subsection [**ice-modifiers**](https://github.com/zdharma-continuum/zinit#ice-modifiers)). The logic is that "ice" is something something that’s added (e.g. to a drink or a coffee) – and in the Zinit sense this means that ice is a modifier added to the next Zinit command, and also something that melts (so it doesn’t last long) – and in the Zinit use it means that the modifier lasts for only single next Zinit command. Using one other ice-modifier "**pick**" user can explicitly **select the file to source**:

```zsh
zinit ice svn pick"init.zsh"
zinit snippet PZT::modules/git
```

Content of ice-modifier is simply put into `"…"`, `'…'`, or `$'…'`. No need for `":"` after ice-mod name (although it's allowed, so as the equal sign `=`, so e.g. `pick="init.zsh"` or `pick=init.zsh` are being correctly recognized) . This way editors like `vim` and `emacs` and also `zsh-users/zsh-syntax-highlighting` and `zdharma-continuum/fast-syntax-highlighting` will highlight contents of ice-modifiers.

## as"program"[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#asprogram)

A plugin might not be a file for sourcing, but a command to be added to `$PATH`. To obtain this effect, use ice-modifier `as` with value `program` (or an alias value `command`).

```zsh
zinit ice as"program" cp"httpstat.sh -> httpstat" pick"httpstat"
zinit light b4b4r07/httpstat
```

Above command will add plugin directory to `$PATH`, copy file `httpstat.sh` into `httpstat` and add execution rights (`+x`) to the file selected with `pick`, i.e. to `httpstat`. Other ice-mod exists, `mv`, which works like `cp` but **moves** a file instead of **copying** it. `mv` is ran before `cp`.

Note

**The `cp` and `mv` ices (and also as some other ones, like `atclone`) are being run when the plugin or snippet is being \*installed\*. To test them again first delete the plugin or snippet by `zinit delete PZT::modules/osx` (for example).**

## atpull"…"[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#atpull)

Copying file is safe for doing later updates – original files of repository are unmodified and `Git` will report no conflicts. However, `mv` also can be used, if a proper `atpull` (an ice–modifier ran at **update** of plugin) will be used:

```zsh
zinit ice as"program" mv"httpstat.sh -> httpstat" \
      pick"httpstat" atpull'!git reset --hard'
zinit light b4b4r07/httpstat
```

If `atpull` starts with exclamation mark, then it will be run before `git pull`, and before `mv`. Nevertheless, `atpull`, `mv`, `cp` are ran **only if new commits are to be fetched**. So in summary, when user runs `zinit update b4b4r07/httpstat` to update this plugin, and there are new commits, what happens first is that `git reset --hard` is ran – and it **restores** original `httpstat.sh`, **then** `git pull` is ran and it downloads new commits (doing fast-forward), **then** `mv` is ran again so that the command is `httpstat` not `httpstat.sh`. This way the `mv` ice can be used to induce a permanent changes into the plugin's contents without blocking the ability to update it with `git` (or with `subversion` in case of snippets, more on this below at [***\***](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#on_svn_revert)).

Note

**For exclamation mark to not be expanded by Zsh in interactive session, use `'…'` not `"…"` to enclose contents of `atpull` ice-mod.**

## Snippets-Commands[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#snippets-commands)

Commands can also be added to `$PATH` using **snippets**. For example:

```zsh
zinit ice mv"httpstat.sh -> httpstat" \
        pick"httpstat" as"program"
zinit snippet \
    https://github.com/b4b4r07/httpstat/blob/master/httpstat.sh
```

(***\***) Snippets also support `atpull` ice-mod, so it’s possible to do e.g. `atpull'!svn revert'`. There’s also `atinit` ice-mod, executed before each loading of plugin or snippet.

## Snippets-Completions[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#snippets-completions)

By using the `as''` ice-mod with value `completion` you can point the `snippet` subcommand directly to a completion file, e.g.:

```zsh
zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker
```

## Completion Management[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#completion_management)

Zinit allows to disable and enable each completion in every plugin. Try installing a popular plugin that provides completions:

```zsh
zinit ice blockf
zinit light zsh-users/zsh-completions
```

First command (the `blockf` ice) will block the traditional method of adding completions. Zinit uses own method (based on symlinks instead of adding a number of directories to `$fpath`). Zinit will automatically **install** completions of a newly downloaded plugin. To uninstall the completions and install them again, you would use:

```zsh
zinit cuninstall zsh-users/zsh-completions   # uninstall
zinit creinstall zsh-users/zsh-completions   # install
```

### Listing Completions[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#listing_completions)

Note

**`zi` is an alias that can be used in interactive sessions.**

To see what completions **all** plugins provide, in tabular formatting and with name of each plugin, use:

```zsh
zi clist
```

This command is specially adapted for plugins like `zsh-users/zsh-completions`, which provide many completions – listing will have `3` completions per line (so that a smaller number of terminal pages will be occupied) like this:

```zsh
...
atach, bitcoin-cli, bower    zsh-users/zsh-completions
bundle, caffeinate, cap      zsh-users/zsh-completions
cask, cf, chattr             zsh-users/zsh-completions
...
```

You can show more completions per line by providing an **argument** to `clist`, e.g. `zi clist 6`, will show:

```zsh
...
bundle, caffeinate, cap, cask, cf, chattr      zsh-users/zsh-completions
cheat, choc, cmake, coffee, column, composer   zsh-users/zsh-completions
console, dad, debuild, dget, dhcpcd, diana     zsh-users/zsh-completions
...
```

### Enabling and Disabling Completions[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#enabling_and_disabling_completions)

Completions can be disabled, so that e.g. original Zsh completion will be used. The commands are very basic, they only need completion **name**:

```zsh
$ zi cdisable cmake
Disabled cmake completion belonging to zsh-users/zsh-completions
$ zi cenable cmake
Enabled cmake completion belonging to zsh-users/zsh-completions
```

That’s all on completions. There’s one more command, `zinit csearch`, that will **search** all plugin directories for available completions, and show if they are installed:

![#csearch screenshot](./zinit-install.assets/csearch.png)

This sums up to complete control over completions.

## Subversion for Subdirectories[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#subversion_for_subdirectories)

In general, to use **subdirectories** of Github projects as snippets add `/trunk/{path-to-dir}` to URL, for example:

```zsh
zinit ice svn
zinit snippet https://github.com/zsh-users/zsh-completions/trunk/src

# For Oh My Zsh and Prezto, the OMZ:: and PZT:: prefixes work
# without the need to add the `/trunk/` infix (however the path
# should point to a directory, not to a file):
zinit ice svn; zinit snippet PZT::modules/docker
```

Snippets too have completions installed by default, like plugins.

## Turbo Mode (Zsh >= 5.3)[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#turbo_mode_zsh_53)

The ice-mod `wait` allows the user postponing loading of a plugin to the moment when the processing of `.zshrc` is finished and the first prompt is being shown. It is like Windows – during startup, it shows desktop even though it still loads data in background. This has drawbacks, but is for sure better than blank screen for 10 minutes. And here, in Zinit, there are no drawbacks of this approach – no lags, freezes, etc. – the command line is fully usable while the plugins are being loaded, for any number of plugins.

Note

**Turbo will speed up Zsh startup by 50%–80%. For example, instead of 200 ms, it'll be 40 ms (!)**

Zsh 5.3 or greater is required. To use this Turbo mode add `wait` ice to the target plugin in one of following ways:

```zsh
PS1="READY > "
zinit ice wait'!0' 
zinit load halfo/lambda-mod-zsh-theme
```

This sets plugin `halfo/lambda-mod-zsh-theme` to be loaded `0` seconds after `zshrc`. It will fire up after c.a. 1 ms of showing of the basic prompt `READY >`. You probably won't load the prompt in such a way, however it is a good example in which Turbo can be directly observed.

The exclamation mark causes Zinit to reset the prompt after loading plugin – it is needed for themes. The same with Prezto prompts, with a longer delay:

```zsh
zinit ice svn silent wait'!1' atload'prompt smiley'
zinit snippet PZT::modules/prompt
```

Using `zsh-users/zsh-autosuggestions` without any drawbacks:

```zsh
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
```

Explanation: Autosuggestions uses `precmd` hook, which is being called right after processing `zshrc` – `precmd` hooks are being called **right before displaying each prompt**. Turbo with the empty `wait` ice will postpone the loading `1` ms after that, so `precmd` will not be called at that first prompt. This makes autosuggestions inactive at the first prompt. **However** the given `atload` ice-mod fixes this, it calls the same function that `precmd` would, right after loading autosuggestions, resulting in exactly the same behavior of the plugin.

The ice `lucid` causes the under-prompt message saying `Loaded zsh-users/zsh-autosuggestions` that normally appears for every Turbo-loaded plugin to not show.

### A Quick Glance At The [For-Syntax](https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/)[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#a_quick_glance_at_the_for-syntax)

This introduction is based on the classic, two-command syntax (`zinit ice …; zinit load/light/snippet …`) of Zinit. However, there's also available a recently added so-called *for-syntax*. It is a right moment to take a glance at it, by rewriting the above autosuggestions invocation using it:

```zsh
zinit wait lucid atload'_zsh_autosuggest_start' light-mode for \
    zsh-users/zsh-autosuggestions
```

The syntax is a more concise one. The single command will work exactly the same as the previous classic-syntax invocation. It also allows solving some typical problems when using Zinit, like providing common/default ices for a set of plugins or [sourcing multiple files](https://zdharma-continuum.github.io/zinit/wiki/Sourcing-multiple-files/). For more information refer to the page dedicated to the new syntax ([here](https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/)).

### Turbo-Loading Sophisticated Prompts[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#turbo-loading_sophisticated_prompts)

For some, mostly advanced themes the initialization of the prompt is being done in a `precmd`-hook, i.e.; in a function that's gets called before each prompt. The hook is installed by the [add-zsh-hook](https://zdharma-continuum.github.io/zinit/wiki/zsh-plugin-standard/#use_of_add-zsh-hook_to_install_hooks) Zsh function by adding its name to the `$precmd_functions` array.

To make the prompt fully initialized after Turbo loading in the middle of the prompt (the same situation as with the `zsh-autosuggestions` plugin), the hook should be called from `atload''` ice.

First, find the name of the hook function by examining the `$precmd_functions` array. For example, for `robobenklein/zinc` theme, they'll be two functions: `prompt_zinc_setup` and `prompt_zinc_precmd`:

```zsh
root@sg > ~ > print $precmd_functions                       < ✔ < 22:21:33
_zsh_autosuggest_start prompt_zinc_setup prompt_zinc_precmd
```

Then, add them to the ice-list in the `atload''` ice:

```zsh
zinit ice wait'!' lucid nocd \
    atload'!prompt_zinc_setup; prompt_zinc_precmd'
zinit load robobenklein/zinc
```

The exclamation mark in `atload'!…'` is to track the functions allowing the plugin to be unloaded, as described [here](https://zdharma-continuum.github.io/zinit/wiki/atload-and-other-at-ices/). It might be useful for the multi-prompt setup described next.

## Automatic Load/Unload on Condition[#](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/#automatic_loadunload_on_condition)

Ices `load` and `unload` allow to define when you want plugins active or unactive. For example:

```zsh
# Load when in ~/tmp

zinit ice load'![[ $PWD = */tmp* ]]' unload'![[ $PWD != */tmp* ]]' \
    atload"!promptinit; prompt sprint3"
zinit load psprint/zprompts

# Load when NOT in ~/tmp

zinit ice load'![[ $PWD != */tmp* ]]' unload'![[ $PWD = */tmp* ]]'
zinit load russjohnson/angry-fly-zsh
```

Two prompts, each active in different directories. This technique can be used to have plugin-sets, e.g. by defining parameter `$PLUGINS` with possible values like `cpp`, `web`, `admin` and by setting `load` / `unload` conditions to activate different plugins on `cpp`, on `web`, etc.

Note

**The difference with `wait` is that `load` / `unload` are constantly active, not only till first activation.**

Note that for unloading of a plugin to work the plugin needs to be loaded with tracking (so `zinit load …`, not `zinit light …`). Tracking causes slight slowdown, however this doesn’t influence Zsh startup time when using Turbo mode.

**See also Wiki on [multiple prompts](https://zdharma-continuum.github.io/zinit/wiki/Multiple-prompts/).** It contains a more real-world examples of a multi-prompt setup, which is being close to what the author uses in own setup.





# Example Oh My Zsh Setup

## Using Turbo mode and for-syntax[#](https://zdharma-continuum.github.io/zinit/wiki/Example-Oh-My-Zsh-setup/#using_turbo_mode_and_for-syntax)

```zsh
# A.
setopt promptsubst

# B.
zinit wait lucid for \
        OMZL::git.zsh \
  atload"unalias grv" \
        OMZP::git

PS1="READY >" # provide a simple prompt till the theme loads

# C.
zinit wait'!' lucid for \
    OMZL::prompt_info_functions.zsh \
    OMZT::gnzh

# D.
zinit wait lucid for \
  atinit"zicompinit; zicdreplay"  \
        zdharma-continuum/fast-syntax-highlighting \
      OMZP::colored-man-pages \
  as"completion" \
        OMZP::docker/_docker
```

**A** - Most themes use this option.

**B** - OMZ themes use this library and some other use also the plugin. It provides many aliases – `atload''` shows how to disable some of them (e.g.: to use program `rgburke/grv`).

**C** - Set OMZ theme. Loaded separately because the theme needs the `!` passed to the `wait` ice to reset the prompt after loading the snippet in Turbo.

**D** - Some plugins: a) syntax-highlighting, loaded possibly early for a better user experience), b) example functional plugin, c) Docker completion.

Above setup loads everything after prompt, because of preceding `wait` ice. That is called **Turbo mode**, it shortens Zsh startup time by 50%-80%, so e.g. instead of 200 ms, it'll be getting your shell started up after **40 ms** (!).

It is using the for-syntax, which is a recent addition to Zinit and it's described in detail [on this page](https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/).

## Without using Turbo and for-syntax[#](https://zdharma-continuum.github.io/zinit/wiki/Example-Oh-My-Zsh-setup/#without_using_turbo_and_for-syntax)

The same setup using the classic syntax and without Turbo mode (prompt will be initially set like in typical, normal setup – **you can remove `wait` only from the theme plugin** and its dependencies to have the same effect while still using Turbo for everything remaining):

```zsh
# A.
setopt promptsubst

# B.
zinit snippet OMZL::git.zsh

# C.
zinit ice atload"unalias grv"
zinit snippet OMZP::git

# D.
zinit for OMZL::prompt_info_functions.zsh OMZT::gnzh

# E.
zinit snippet OMZP::colored-man-pages

# F.
zinit ice as"completion"
zinit snippet OMZP::docker/_docker

# G.
zinit ice atinit"zicompinit; zicdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting
```

In general, Turbo can be optionally enabled only for a subset of plugins or for all plugins. It needs Zsh >= 5.3.