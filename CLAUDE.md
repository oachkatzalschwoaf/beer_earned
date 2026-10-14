# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Garmin Connect IQ **DataField** in Monkey C. It converts the activity's calories into "beers
earned", draws a vessel filling toward the next beer, pops up "Cheers!" for each whole beer, and
records the count as FIT developer fields that Garmin Connect charts. It's a free continuation of
the discontinued store app *Beers Earned Plus* by brewer_midwest (store id
`cb51f0b9-6836-4856-a4f0-4c18e61cf08c`). That app's source was never shared, so nothing here derives
from it. The goal is a free release in the Connect IQ store; see `STORE.md`.

`manifest.xml` targets 92 products (colour watches and Edge units with ≥ 64 KB for data
fields), `minApiLevel` 3.2.0. The priority device is the fēnix 8X MIP/solar = `fenix8solar51mm`.
32 KB devices are excluded on purpose: the field uses about 24 of their 28 KB.

## Build / run / test

Tooling is the Connect IQ SDK plus the VS Code Monkey C extension; there's no npm or make. The SDK
`bin/` is at `%APPDATA%\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-<version>\bin`. The developer key lives
outside the repo at `W:\Code\coding\ConnectIQDevKEy\developer_key`. Never commit it.

- **One device (Git Bash):**
  `"$SDK/monkeyc.bat" -f monkey.jungle -d fenix8solar51mm -o build/out.prg -y "$KEY" -w -l 3`
  `-l 3` is the strict type check. The code is clean at that level, so keep it that way.
- **All devices / store package:**
  `"$SDK/monkeyc.bat" -e -r -f monkey.jungle -o bin/BeersEarned.iq -y "$KEY" -w -l 3`
  This runs 143 builds in about 6 minutes. That's far faster than a loop of `-d` builds, which pay
  JVM start-up each time. The only warnings are launcher-icon scaling, which is harmless for an SVG.
- **Unit tests:** add `--unit-test` to a single-device build, start the simulator
  (`connectiq.bat`), then run `MSYS_NO_PATHCONV=1 "$SDK/monkeydo.bat" build/test.prg fenix8solar51mm /t`.
  Without `MSYS_NO_PATHCONV`, Git Bash rewrites `/t` into a path.
- **Simulator:** `monkeydo.bat <prg> <deviceId>`. Useful menus:
  - *Simulation > Activity Data > Start* feeds calories.
  - *Data Fields > Layout* switches between 1 and 8 fields, with real obscurity flags.
  - *Data Fields > Background Color* toggles black and white.
  - *Settings > Trigger App Settings* opens the on-device settings menu.
  - *File > Reset All App Data* clears stored properties. The simulator keeps them across
    reinstalls, so a changed default won't show until you clear them.

`bin/` and `build/` are generated output and git-ignored (so is anything key-like, see
`.gitignore`). The store upload `bin/BeersEarned.iq` therefore never lands in the repo.

## Architecture

- `BeersEarnedApp.mc`: entry point. `getSettingsView()` returns the on-device menu, and
  `onSettingsChanged()` forwards to `view.reloadSettings()`.
- `BeersEarnedView.mc` (`DataField`): `compute()` runs once a second and does
  `raw = startingBeers + calories / caloriesPerBeer`. It writes three FIT fields and detects
  whole-beer crossings in `_checkMilestone()`. The first sample only sets the baseline, and a
  settings change re-baselines. Those crossings call `_celebrate()`: a `DataFieldAlert` pop-up,
  vibration and tone.
  - `compute()`'s return value is **ignored** for a full `DataField`. Only the FIT fields get recorded.
  - `onUpdate()` builds a `BeerScene` and hands it to `BeerPainter`.
  - `onShow()` reloads settings, because the on-device menu may run in a separate app instance.
- `BeerRenderer.mc`: holds two classes and a module.
  - `BeerScene` is the per-frame state.
  - `BeerPainter` does the layout and drawing.
  - The `BeerRenderer` module holds colours, glass profiles and font picking.
  - There are three layouts: a big vessel with the count inside, a vessel beside the count for
    wide slots, and the count alone for tiny slots. On round screens the view turns
    `getObscurityFlags()` into the slot's position, and the painter shrinks and slides content
    until it fits inside the bezel circle.
  - The mug is a rounded rectangle plus a handle ellipse. The other glasses are half-width profiles
    filled with `fillPolygon`.
- `BeerSettings.mc`: property keys, enum values, a validated `Config` snapshot and `nextPreset()`.
- `BeerSettingsMenu.mc`: the on-device `Menu2`. Selecting an item cycles to its next value.
  `choiceLabels()` maps list values to their string ids.
- `BeerAlertView.mc`: the "Cheers!" `DataFieldAlert`.
- `BeerMath.mc`: rounding, count text and fill level. These are pure functions and unit-tested.
- `tests/BeersEarnedTests.mc`: `(:test)` functions plus two helper classes.
  - `RecordingView` overrides the protected `_createFitFields()`, because `createField` fails
    outside an activity. It also overrides `_celebrate()`.
  - `TestKit` holds the helpers. They live in a class because any `(:test)` *function* is run as
    a test.

### Constraints that bite

- **Tiny call stack.** A data field overflows at roughly 8 frames deep, or with about 10
  parameters. That's why `BeerPainter` keeps geometry in members and its `_fit*` methods only
  measure. `drawField` then draws at shallow depth. Keep new drawing code flat, and test
  any change in the simulator, because the compiler won't catch this.
- **Colours** are palette-exact (components 00/55/AA/FF) so 64-colour MIP screens don't dither.
- **FIT fields** `beers` (record), `total_beers` (session) and `lap_beers` (lap), ids 0 to 2, are
  labelled by `resources/fitcontributions/fitcontributions.xml`. Never renumber or retype them after
  release. Garmin Connect only shows them for store installs.
- **App id** in `manifest.xml` is the permanent store identity. `STORE.md` has a separate beta id.

### Settings

Each setting lives in four places that must stay in sync:

- `resources/properties.xml`: the default value.
- `resources/settings.xml`: the phone UI.
- `BeerSettings.mc`: the key constant plus `Config.load()` with validation.
- `BeerSettingsMenu.mc`: the on-device item.

It also needs `@Strings` labels in `resources/strings/strings.xml` and `resources-deu/strings/strings.xml`.
List values are numbered in display order, light to dark with "automatic" first, because the
on-device menu cycles in value order.

| Key | Type | Values (default) |
|---|---|---|
| `caloriesPerBeer` | float | 10–5000 (150) |
| `beerStyle` | number | 0 Pils, 1 Hefeweizen, 2 Amber (2), 3 Red Ale, 4 Stout |
| `glassShape` | number | 0 Mug (0), 1 Weizen, 2 Pint, 3 Bottle |
| `background` | number | 0 Auto (0), 1 Black, 2 White |
| `roundingMode` | number | 0 Down (0), 1 Nearest, 2 Up, 3 One decimal |
| `startingBeers` | float | 0–1000 (0) |
| `alertPopup` / `alertVibrate` / `alertTone` | boolean | true / false / false |

## Other docs

- `README.md`: features, settings and the device list, for users and contributors.
- `STORE.md`: the publishing steps and the EN/DE listing texts.
- `SIDELOAD.md`: USB install.
- `store/`: the store icon and screenshots.
- `requirements.md`: an old wish list. Still not built from it: daily totals, streaks and a can
  shape. Its file names don't match the code.
