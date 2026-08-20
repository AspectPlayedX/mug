# MUG

A small Windows utility toolkit, pick apps from a list, install them all in
one go. Terminal-styled, keyboard driven, no installer.

## Run it

Paste this into **PowerShell**:

```powershell
irm https://raw.githubusercontent.com/AspectPlayedX/mug/main/run.ps1 | iex
```

Or from **Command Prompt**:

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/AspectPlayedX/mug/main/run.ps1 | iex"
```

That downloads the latest build to `%LOCALAPPDATA%\MUG` and launches it.
Nothing is installed until you choose something.

You can also grab `mug-loader.exe` straight from
[Releases](../../releases/latest) and double-click it, it's a single
self-contained file.

> **Windows will warn you.** The app isn't code-signed, so SmartScreen shows
> "Windows protected your PC". Click **More info → Run anyway**.

## Using it

| Key | Does |
|---|---|
| `W` `A` `S` `D` | move / fold |
| `Space` | tick a row |
| `I` | install everything ticked |
| `U` | uninstall (press twice to confirm) |
| `R` | retry anything that failed |
| `O` | show/hide live output |
| `P` | cycle presets — new pc / dev / media |
| `/` | search, `Tab` searches all of winget |
| `,` | settings |
| `Esc` | back, then quit |

Rows already on your machine show a dimmed tick; ones with an update
available show the version change instead of a description.

Installs run one at a time on purpose, parallel package installs fight each
other and fail in confusing ways.

## Customising the list

The app list lives in `%LOCALAPPDATA%\MUG\catalog.json`, written on first
run. Edit it and restart, no rebuild needed. A `catalog.json` next to the
exe takes priority, which is handy for a portable copy.

If the file has a syntax error, the app keeps working with its built-in list
and tells you which line is wrong. It won't overwrite your edits.

## Where it puts things

Everything lives in `%LOCALAPPDATA%\MUG`:

- `catalog.json` — the app list
- `config.txt` — settings
- `selection.txt` — exported selections
- `log.txt` — what happened, including install failures

Delete that folder to reset.

## What it uses

Most entries install through [winget](https://learn.microsoft.com/en-us/windows/package-manager/),
which handles downloads, hash verification and later upgrades. If winget is
missing the app tries to install it. A few apps winget doesn't carry are
fetched from the vendor or from GitHub releases — each row is tagged so you
can see which is which before running it.
