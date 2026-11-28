import Toybox.Application;
import Toybox.Lang;

//! Property keys, option values and the validated settings snapshot shared by
//! the data field, the on-device settings menu and the alert view.
//!
//! Every key must also exist in resources/properties.xml (default value) and
//! resources/settings.xml (Garmin Connect UI).
module BeerSettings {

    const KEY_DRINK = "drink";
    const KEY_CALORIES = "caloriesPerBeer";
    const KEY_ROUNDING = "roundingMode";
    const KEY_BACKGROUND = "background";
    const KEY_POPUP = "alertPopup";
    const KEY_VIBRATE = "alertVibrate";
    const KEY_TONE = "alertTone";

    // Settings of the releases before 1.2.0, only read once to pick the drink.
    const KEY_OLD_STYLE = "beerStyle";  // 0 Pils, 1 Hefeweizen, 2 Amber, 3 Red Ale, 4 Stout
    const KEY_OLD_SHAPE = "glassShape"; // 0 Mug, 1 Weizen, 2 Pint, 3 Bottle

    // Application.Storage keys: drink and calories as last seen by sync().
    const SEEN_DRINK = "seenDrink";
    const SEEN_CALORIES = "seenCalories";

    // List values run in display order (the beers, then the soft drinks): the drink
    // menu lists them in value order.
    enum {
        DRINK_MUG = 0,       // lager in a handled mug
        DRINK_PILS = 1,
        DRINK_WHEAT = 2,
        DRINK_BOTTLE = 3,    // bottled beer
        DRINK_STOUT = 4,
        DRINK_COLA = 5,
        DRINK_SPEZI = 6,     // cola with orange soda, in a labelled bottle
        DRINK_HERBAL = 7     // herbal soda
    }
    const DRINK_COUNT = 8;
    const DRINK_FIRST_SOFT = 5; // this drink and all after it are soft drinks

    // Vessels. No brand logos or copied label artwork.
    enum {
        SHAPE_MUG = 0,        // handled mug / stein
        SHAPE_WEIZEN = 1,     // tall curved wheat-beer glass
        SHAPE_PINT = 2,       // tapered pint glass
        SHAPE_BOTTLE = 3,     // stubby bottle
        SHAPE_COLA_BOTTLE = 4 // waisted soda bottle
    }

    // What a drink brings along, both indexed by DRINK_*: its vessel, and the default
    // kcal per 0.33 l that the calorie setting starts from.
    const DRINK_SHAPES = [SHAPE_MUG, SHAPE_PINT, SHAPE_WEIZEN, SHAPE_BOTTLE, SHAPE_PINT,
        SHAPE_COLA_BOTTLE, SHAPE_BOTTLE, SHAPE_BOTTLE] as Array<Number>;
    const DRINK_CALORIES = [150.0f, 140.0f, 150.0f, 140.0f, 150.0f,
        139.0f, 132.0f, 109.0f] as Array<Float>;

    enum {
        BG_AUTO = 0, // follow the activity's own background colour
        BG_BLACK = 1,
        BG_WHITE = 2
    }
    const BG_COUNT = 3;

    enum {
        ROUND_DOWN = 0,    // whole drinks, only once fully earned
        ROUND_NEAREST = 1,
        ROUND_UP = 2,
        ROUND_EXACT = 3    // one decimal, truncated
    }
    const ROUNDING_COUNT = 4;

    // Range of the calories per drink.
    const MIN_CALORIES = 10;
    const MAX_CALORIES = 5000;

    class Config {
        var drink as Number = DRINK_MUG;
        var caloriesPerBeer as Float = 150.0f; // of whatever drink is chosen
        var rounding as Number = ROUND_EXACT;
        var background as Number = BG_AUTO;
        var alertPopup as Boolean = true;
        var alertVibrate as Boolean = false;
        var alertTone as Boolean = false;

        function initialize() {
            load();
        }

        // Re-read all properties, falling back to defaults for missing or out-of-range values.
        // Call sync() first where the drink may have changed.
        function load() as Void {
            drink = readNumber(KEY_DRINK, DRINK_MUG, DRINK_COUNT);
            caloriesPerBeer = readCalories(drink);
            rounding = readNumber(KEY_ROUNDING, ROUND_EXACT, ROUNDING_COUNT);
            background = readNumber(KEY_BACKGROUND, BG_AUTO, BG_COUNT);
            alertPopup = readBool(KEY_POPUP, true);
            alertVibrate = readBool(KEY_VIBRATE, false);
            alertTone = readBool(KEY_TONE, false);
        }
    }

    //! Keep the calories in step with the drink: another drink brings its own default,
    //! unless the same change also set the calories. The first run of 1.2.0 picks the
    //! drink from the old beer and glass settings and keeps the calories.
    //! Not part of Config.load() to keep the call stack shallow.
    function sync() as Void {
        var drink = readNumber(KEY_DRINK, DRINK_MUG, DRINK_COUNT);
        // Cast: equals() on the untyped storage values doesn't compile for older devices.
        var seen = Application.Storage.getValue(SEEN_DRINK) as Number?;
        var seenCalories = Application.Storage.getValue(SEEN_CALORIES) as Float?;
        var firstRun = seen == null;
        if (seen == null) {
            if (drink == DRINK_MUG) {
                drink = upgradedDrink();
                Application.Properties.setValue(KEY_DRINK, drink);
            } else {
                // Already chosen in the phone app before the first run.
                seen = DRINK_MUG;
                seenCalories = DRINK_CALORIES[DRINK_MUG];
            }
        }
        var calories = readCalories(drink);
        if (seen != null && seen != drink && seenCalories == calories) {
            calories = DRINK_CALORIES[drink];
            Application.Properties.setValue(KEY_CALORIES, calories);
        }
        // Runs on every onShow(), so only write what changed.
        if (firstRun || drink != seen || calories != seenCalories) {
            Application.Storage.setValue(SEEN_DRINK, drink);
            Application.Storage.setValue(SEEN_CALORIES, calories);
        }
    }

    // The drink closest to the beer and glass chosen before 1.2.0.
    function upgradedDrink() as Number {
        var style = readNumber(KEY_OLD_STYLE, 2, 5);
        var shape = readNumber(KEY_OLD_SHAPE, 0, 4);
        if (shape == SHAPE_WEIZEN) {
            return DRINK_WHEAT;
        } else if (shape == SHAPE_BOTTLE) {
            return DRINK_BOTTLE;
        } else if (style == 4 || (shape == SHAPE_PINT && style == 3)) {
            return DRINK_STOUT; // the dark ones
        }
        return shape == SHAPE_PINT ? DRINK_PILS : DRINK_MUG;
    }

    //! The calorie setting, or the drink's default if it is missing or out of range.
    function readCalories(drink as Number) as Float {
        var v = Application.Properties.getValue(KEY_CALORIES);
        if (v instanceof Number || v instanceof Float || v instanceof Long || v instanceof Double) {
            var f = (v as Numeric).toFloat();
            if (f >= MIN_CALORIES && f <= MAX_CALORIES) {
                return f;
            }
        }
        return DRINK_CALORIES[drink];
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
