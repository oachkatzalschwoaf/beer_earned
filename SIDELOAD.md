# Sideloading Beers Earned onto a watch

Use this for testing your own build over USB. For normal use, install the field from the
Connect IQ store instead (see [STORE.md](STORE.md)): only store installs get settings in the
Connect IQ phone app and charts in Garmin Connect.

## 1. Build

In VS Code with the Monkey C extension, run **Monkey C: Build for Device** and pick your
model, for example *fēnix 8 Solar 51mm* (`fenix8solar51mm`) for the fēnix 8 MIP/solar 51 mm.
The `.prg` file lands in `bin/`.

## 2. Copy it to the watch

1. Connect the watch by USB. Newer models show up as a media device (MTP) in Explorer.
2. Open `GARMIN\Apps\` (on MTP devices: *Internal Storage → GARMIN → Apps*).
3. Copy the `.prg` there and disconnect the watch.

To remove it later, delete the file again. Do this before installing the store version,
or the field shows up twice.

## 3. Add the field to an activity

1. Choose an activity (e.g. Run), open its settings (hold MENU), then *Data Screens*.
2. Edit a screen, select a field slot, and choose **Connect IQ → Beers Earned**.

Any layout works, from 1 to 8 fields. Bigger slots show the full animated glass.

## 4. Settings

A sideloaded field doesn't appear in the Connect IQ phone app. Change its settings on the
watch instead: they're in the activity settings, under the Connect IQ field. The exact
path depends on the model. The [README](README.md#settings) lists all options.

## Simulator instead of a watch

Run **Run > Run Without Debugging** in VS Code, then in the simulator:

- *Simulation > Activity Data > Start* produces calories.
- *Data Fields > Layout* switches between screen layouts.
- *Data Fields > Background Color* toggles black and white.
- *Settings > Trigger App Settings* opens the on-device settings menu.
