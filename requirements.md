# Beers Earned Plus - Connect IQ DataField requirements

## Goal
Create a Garmin Connect IQ DataField app that counts "beers earned" based on calories burned (or calories from activities), draws an animated beer mug fill graphic, and stores the value in activity data so it is visible in Garmin Connect.

## Core features
1. **DataField mode**
   - The app runs as a datafield on supported devices (including Fenix 8 and newer).
   - Should show on activity screens and update in real-time while recording.

2. **Beer calculation**
   - Convert calories burned to beer count using a configurable calories-per-beer value (default e.g., 250 kcal per beer).
   - Support a configurable starting offset (initial beers already earned before activity), optional whole-beers-only mode.
   - Show decimal partial fill optionally.

3. **Beer mug UI**
   - Render a simple beer mug with fill-level based on earned beers.
   - Display a numeric beers counter.
   - Support both dark and light backgrounds (at least black background and contrast). Should be readable in night mode.

4. **Settings**
   - Calories per beer (numeric, default 250).
   - Beers per activity rounding mode: floor/round/ceil or fractional.
   - Option to reset or manual adjustment.
   - Option to style: beer color, label text.

5. **Fit file / Garmin Connect data**
   - Export earned beer as a custom data field in the activity fit data, so Garmin Connect can use it as field value.
   - Use the Connect IQ DataField API to set field value and persistence.

6. **Persistence**
   - Save settings using `Toybox.AppSettings` or `Toybox.Settings`.
   - Keep current beer count for the day if user chooses.

7. **Device compatibility**
   - Support Fenix 8 and other Connect IQ 4+ capable devices.
   - Data field should gracefully degrade on unsupported devices.

8. **Performance + battery**
   - Keep UI drawing and updates lightweight.
   - Only update when necessary (sample changes). Use low CPU usage.

## Project structure
- `project.properties`
- `manifest.xml`
- `source/BeersEarned.mc` (DataField)
- `source/Settings.mc`
- `resources/strings/en.strings`
- `resources/strings/de.strings`

## Future improvements
- Add daily totals and historical streak.
- Add custom beer sizes (can, pint, liter).
- Add alternative beer types and icons, plus dark beer mode.

## Updated requirement: beer type selection
- Add settings to choose beer display style:
  - Bierkrug (mug)
  - Bierflasche (bottle)
  - Stout glass (dark beer)
  - Weißbier glass
  - Dosenbier (can)
- Show style-specific icon in the field UI.
- Provide dark/light friendly text and background.
- Keep calories-to-beer conversion and fit-data export.
 