import Toybox.Application;
import Toybox.Lang;

//! Property keys, option values and the validated settings snapshot shared by
//! the data field, the on-device settings menu and the alert view.
//!
//! Every key must also exist in resources/properties.xml (default value) and
//! resources/settings.xml (Garmin Connect UI).
module BeerSettings {

    const KEY_CALORIES = "caloriesPerBeer";
    const KEY_START = "startingBeers";
    const KEY_ROUNDING = "roundingMode";
    const KEY_STYLE = "beerStyle";
    const KEY_SHAPE = "glassShape";
    const KEY_BACKGROUND = "background";
    const KEY_POPUP = "alertPopup";
    const KEY_VIBRATE = "alertVibrate";
    const KEY_TONE = "alertTone";

    // List values run in display order (light to dark, auto first): the on-device menu
    // cycles through them in value order.
    enum {
        STYLE_PILS = 0,    // Pilsner / Helles
        STYLE_WHEAT = 1,   // Hefeweizen
        STYLE_AMBER = 2,   // Amber / Lager
        STYLE_RED_ALE = 3, // Red Ale
        STYLE_STOUT = 4    // Stout / Porter
    }
    const STYLE_COUNT = 5;

    enum {
        SHAPE_MUG = 0,    // handled mug / stein
        SHAPE_WEIZEN = 1, // tall curved wheat-beer glass
        SHAPE_PINT = 2,   // tapered pint glass
        SHAPE_BOTTLE = 3  // stubby bottle
    }
    const SHAPE_COUNT = 4;

    enum {
        BG_AUTO = 0, // follow the activity's own background colour
        BG_BLACK = 1,
        BG_WHITE = 2
    }
    const BG_COUNT = 3;

    enum {
        ROUND_DOWN = 0,    // whole beers, only once fully earned
        ROUND_NEAREST = 1,
        ROUND_UP = 2,
        ROUND_EXACT = 3    // one decimal, truncated
    }
    const ROUNDING_COUNT = 4;

    // Choices offered by the on-device menu (the phone app accepts any value in range).
    const CALORIE_PRESETS = [100, 120, 140, 150, 175, 200, 250, 300] as Array<Number>;
    const START_PRESETS = [0, 1, 2, 3, 4, 5, 6, 8, 10] as Array<Number>;

    class Config {
        var caloriesPerBeer as Float = 150.0f;
        var startingBeers as Float = 0.0f;
        var rounding as Number = ROUND_DOWN;
        var style as Number = STYLE_AMBER;
        var shape as Number = SHAPE_MUG;
        var background as Number = BG_AUTO;
        var alertPopup as Boolean = true;
        var alertVibrate as Boolean = false;
        var alertTone as Boolean = false;

        function initialize() {
            load();
        }

        // Re-read all properties, falling back to defaults for missing or out-of-range values.
        function load() as Void {
            caloriesPerBeer = readFloat(KEY_CALORIES, 150.0f, 10.0f, 5000.0f);
            startingBeers = readFloat(KEY_START, 0.0f, 0.0f, 1000.0f);
            rounding = readNumber(KEY_ROUNDING, ROUND_DOWN, ROUNDING_COUNT);
            style = readNumber(KEY_STYLE, STYLE_AMBER, STYLE_COUNT);
            shape = readNumber(KEY_SHAPE, SHAPE_MUG, SHAPE_COUNT);
            background = readNumber(KEY_BACKGROUND, BG_AUTO, BG_COUNT);
            alertPopup = readBool(KEY_POPUP, true);
            alertVibrate = readBool(KEY_VIBRATE, false);
            alertTone = readBool(KEY_TONE, false);
        }
    }

    function readFloat(key as String, fallback as Float, min as Float, max as Float) as Float {
        var v = Application.Properties.getValue(key);
        if (v instanceof Number || v instanceof Float || v instanceof Long || v instanceof Double) {
            var f = (v as Numeric).toFloat();
            if (f >= min && f <= max) {
                return f;
            }
        }
        return fallback;
    }

    //! The smallest preset above `current`, wrapping around to the first one.
    function nextPreset(presets as Array<Number>, current as Float) as Float {
        for (var i = 0; i < presets.size(); i++) {
            if (presets[i] > current + 0.01f) {
                return presets[i].toFloat();
            }
        }
        return presets[0].toFloat();
    }

    // Reads a list setting whose valid values are 0..count-1.
    function readNumber(key as String, fallback as Number, count as Number) as Number {
        var v = Application.Properties.getValue(key);
        if (v instanceof Number && v >= 0 && v < count) {
            return v;
        }
        return fallback;
    }

    function readBool(key as String, fallback as Boolean) as Boolean {
        var v = Application.Properties.getValue(key);
        return (v instanceof Boolean) ? v : fallback;
    }
}
