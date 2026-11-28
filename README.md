# Beers Earned

A free Garmin Connect IQ data field that turns the calories you burn into beers.
A glass fills up as you go, every whole beer gets a "Cheers!" pop-up, and the count is
saved with the activity so Garmin Connect can chart it.

**[Get it free in the Connect IQ Store](https://apps.garmin.com/apps/1bf68dd1-f096-4186-8b7d-24ba8c07c7cf)**

It continues the idea of the discontinued store app *Beers Earned Plus* by brewer_midwest.
It's an independent re-implementation: no original code or artwork is used.

> Just for fun: calories on a watch are an estimate. Please drink responsibly.

## Features

- **Live count**: kcal burned ÷ kcal per drink. Every activity starts at zero.
- **Eight drinks**: mug, Pilsner, wheat beer, bottled beer, stout, cola, Spezi (cola mix)
  and herbal soda. Each has its own vessel and default calories, which you can overwrite.
- **Animated vessel**: it fills toward the next drink, with foam or fizz and rising bubbles.
- **Every data-screen layout**: 1 to 8 fields, round and rectangular screens. On round
  screens the drawing stays clear of the bezel. Wide slots show a small glass next to the
  number, tiny slots just the number.
- **Background**: automatic (follows the activity's dark or light setting), black or white.
- **An alert for each drink**: pop-up (on by default), vibration and tone (off by default).
- **Counting**: one decimal (default), whole drinks, rounded, or rounded up.
- **Garmin Connect**: a "Beers Earned" chart, the total in the activity summary, and beers
  per lap in the laps table.
- **Settings** in the Connect IQ / Garmin Connect app or right on the watch.
- English, German, French, Spanish, Italian, Dutch, Czech, Polish and Portuguese.

## Settings

| Setting | Options | Default |
|---|---|---|
| Drink | see below | Mug |
| kcal per drink | 10–5000 | the drink's default |
| Background | Automatic, Black, White | Automatic |
| Counting | Whole drinks, Rounded, Rounded up, One decimal | One decimal |
| Pop-up per drink | on / off | on |
| Vibrate per drink | on / off | off |
| Tone per drink | on / off | off |

Choosing another drink sets *kcal per drink* to that drink's default (per 0.33 l):

| Drink | Vessel | kcal |
|---|---|---|
| Mug | handled mug | 150 |
| Pilsner | pint glass | 140 |
| Wheat beer | wheat-beer glass | 150 |
| Bottle | beer bottle | 140 |
| Stout | pint glass | 150 |
| Cola | cola bottle | 139 |
| Spezi | labelled bottle | 132 |
| Herbal soda | bottle | 109 |

The field still calls its count "beers" in Garmin Connect, whatever the drink.

On the watch, the same settings live in the activity's settings, under this data field. The
exact menu path depends on the model. *Drink* opens a list and *kcal per drink* a number pad:
tap the keys, or move with up / down and press select. Selecting any other item moves it to
its next value.

Updating from 1.1 or older keeps your calories and counting mode, and picks the drink closest
to your former beer and glass.

## Garmin Connect

The field writes three values into the activity's FIT file:

| FIT field | Shown in Garmin Connect as |
|---|---|
| `beers` (every second, unrounded) | Chart "Beers Earned" |
| `total_beers` (session, as displayed) | Activity summary |
| `lap_beers` (per lap) | Laps table |

Garmin Connect only labels and charts these for apps installed from the Connect IQ store.
With a sideloaded build the values are still in the FIT file, but Garmin Connect doesn't
show them.

## Supported devices

There are 114 products in [manifest.xml](manifest.xml), including fēnix 5 Plus, 6 Pro, 7, 8, 9 and
E, epix (Gen 2), Enduro 3 and 4, Forerunner 70, 165, 170, 245 Music, 255, 265, 570, 645 Music, 745,
945, 955, 965 and 970, Venu 2, 3, 4, X1 and Sq 2, vívoactive 5 and 6, MARQ (Gen 1 to 3), Instinct 3
AMOLED and Crossover AMOLED, Descent, D2 and Approach, Edge 530 through 1060, MTB and Explore 2
and 3, and the GPSMAP 67 / H1, Montana 7 and eTrex Touch handhelds.

These are left out on purpose:

- Models with only 32 KB for data fields, such as fēnix 6 / 6S (non-Pro), vívoactive 4,
  Venu (1st gen) and Forerunner 245. The field already needs about 24 of their 28 KB.
- Monochrome Instincts.

## Building

You need the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (built with 9.3),
the VS Code *Monkey C* extension and a developer key.

- **Run in the simulator:** open the folder in VS Code, then *Run > Run Without Debugging*.
  In the simulator, *Simulation > Activity Data > Start* produces calories, and
  *Data Fields > Layout* switches between screen layouts.
- **Build for a device:** run *Monkey C: Build for Device*. To install the result, see
  [SIDELOAD.md](SIDELOAD.md).
- **Export for the store:** run *Monkey C: Export Project*. The upload steps are in
  [STORE.md](STORE.md).
- **Unit tests:** build with `--unit-test`, then run in the simulator:

  ```sh
  monkeyc -f monkey.jungle -d fenix8solar51mm -o bin/test.prg -y <developer_key> --unit-test
  monkeydo bin/test.prg fenix8solar51mm /t
  ```

## Code

| File | Purpose |
|---|---|
| `source/BeersEarnedApp.mc` | App entry; settings views and change notifications |
| `source/BeersEarnedView.mc` | The data field: calories to beers, alerts, FIT fields |
| `source/BeerRenderer.mc` | Drawing: glasses, foam, bubbles, layout per slot size |
| `source/BeerSettings.mc` | Setting keys, values and validated loading |
| `source/BeerSettingsMenu.mc` | On-device settings menu and drink list |
| `source/BeerKeypad.mc` | Number pad for the calories |
| `source/BeerAlertView.mc` | "Cheers!" pop-up |
| `source/BeerMath.mc` | Rounding and fill-level maths |
| `tests/` | Unit tests |
| `resources/` | Strings, settings, FIT labels, launcher icon (`resources-<lang>/` for the translations) |
| `store/` | Store icon and screenshots |
