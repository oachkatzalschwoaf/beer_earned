# Beers Earned

A free Garmin Connect IQ data field that turns the calories you burn into beers.
A glass fills up as you go, every whole beer gets a "Cheers!" pop-up, and the count is
saved with the activity so Garmin Connect can chart it.

It continues the idea of the discontinued store app *Beers Earned Plus* by brewer_midwest.
It's an independent re-implementation: no original code or artwork is used.

> Just for fun: calories on a watch are an estimate. Please drink responsibly.

## Features

- **Live count**: kcal burned ÷ kcal per beer (default 150, roughly a 0.33 l lager), plus
  optional beers at start.
- **Animated glass**: a mug, wheat-beer glass, pint glass or bottle fills toward the next
  beer, with a head of foam and rising bubbles.
- **Five beers**: Pilsner / Helles, Hefeweizen, Amber / Lager, Red Ale, Stout / Porter.
- **Every data-screen layout**: 1 to 8 fields, round and rectangular screens. On round
  screens the drawing stays clear of the bezel. Wide slots show a small glass next to the
  number, tiny slots just the number.
- **Background**: automatic (follows the activity's dark or light setting), black or white.
- **An alert for each beer**: pop-up (on by default), vibration and tone (off by default).
- **Counting**: whole beers (default), rounded, rounded up, or one decimal.
- **Garmin Connect**: a "Beers Earned" chart, the total in the activity summary, and beers
  per lap in the laps table.
- **Settings** in the Connect IQ / Garmin Connect app or right on the watch.
- English, German, French, Spanish, Italian, Dutch, Czech, Polish and Portuguese.

## Settings

| Setting | Options | Default |
|---|---|---|
| kcal per beer | 10–5000 (watch menu: 100–300) | 150 |
| Beer | Pilsner / Helles, Hefeweizen, Amber / Lager, Red Ale, Stout / Porter | Amber / Lager |
| Glass | Mug, Wheat beer glass, Pint glass, Bottle | Mug |
| Background | Automatic, Black, White | Automatic |
| Counting | Whole beers, Rounded, Rounded up, One decimal | Whole beers |
| Beers at start | 0–1000 (watch menu: 0–10) | 0 |
| Pop-up per beer | on / off | on |
| Vibrate per beer | on / off | off |
| Tone per beer | on / off | off |

On the watch, the same settings live in the activity's settings, under this data field. The
exact menu path depends on the model. Selecting an item moves it to its next value.

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
AMOLED and Crossover AMOLED, Descent, D2 and Approach, Edge 530 through 1060 and Explore 2 and 3,
and the GPSMAP 67 / H1, Montana 7 and eTrex Touch handhelds.

These are left out on purpose:

- Models with only 32 KB for data fields, such as fēnix 6 / 6S (non-Pro), vívoactive 4,
  Venu (1st gen) and Forerunner 245. The field already needs about 24 of their 28 KB.
- Monochrome Instincts.

## Building

You need the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (built with 9.1),
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
| `source/BeerSettingsMenu.mc` | On-device settings menu |
| `source/BeerAlertView.mc` | "Cheers!" pop-up |
| `source/BeerMath.mc` | Rounding and fill-level maths |
| `tests/` | Unit tests |
| `resources/` | Strings, settings, FIT labels, launcher icon (`resources-<lang>/` for the translations) |
| `store/` | Store icon and screenshots |
