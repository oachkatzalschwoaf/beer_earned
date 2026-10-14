import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! On-device settings, opened from the activity's settings on the watch; they mirror
//! the Garmin Connect settings. Selecting a list item cycles it to its next value.
class BeerSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.AppName });
        var cfg = new BeerSettings.Config();

        addItem(new WatchUi.MenuItem(Rez.Strings.SettingsCaloriesPerBeer,
            caloriesText(cfg.caloriesPerBeer), BeerSettings.KEY_CALORIES, null));
        _addChoice(Rez.Strings.SettingsBeerStyle, BeerSettings.KEY_STYLE, cfg.style);
        _addChoice(Rez.Strings.SettingsGlassShape, BeerSettings.KEY_SHAPE, cfg.shape);
        _addChoice(Rez.Strings.SettingsBackground, BeerSettings.KEY_BACKGROUND, cfg.background);
        _addChoice(Rez.Strings.SettingsRounding, BeerSettings.KEY_ROUNDING, cfg.rounding);
        addItem(new WatchUi.MenuItem(Rez.Strings.SettingsStartingBeers,
            beersText(cfg.startingBeers), BeerSettings.KEY_START, null));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SettingsAlertPopup, null,
            BeerSettings.KEY_POPUP, cfg.alertPopup, null));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SettingsAlertVibrate, null,
            BeerSettings.KEY_VIBRATE, cfg.alertVibrate, null));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SettingsAlertTone, null,
            BeerSettings.KEY_TONE, cfg.alertTone, null));
    }

    private function _addChoice(title as ResourceId, key as String, value as Number) as Void {
        var labels = choiceLabels(key) as Array<ResourceId>;
        addItem(new WatchUi.MenuItem(title, labels[value], key, null));
    }
}

class BeerSettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId();
        if (!(key instanceof String)) {
            return;
        }
        if (item instanceof WatchUi.ToggleMenuItem) {
            // The menu has already flipped the toggle.
            Application.Properties.setValue(key, item.isEnabled());
        } else if (key.equals(BeerSettings.KEY_CALORIES)) {
            var cal = BeerSettings.nextPreset(BeerSettings.CALORIE_PRESETS,
                BeerSettings.readFloat(key, 150.0f, 10.0f, 5000.0f));
            Application.Properties.setValue(key, cal);
            item.setSubLabel(caloriesText(cal));
        } else if (key.equals(BeerSettings.KEY_START)) {
            var start = BeerSettings.nextPreset(BeerSettings.START_PRESETS,
                BeerSettings.readFloat(key, 0.0f, 0.0f, 1000.0f));
            Application.Properties.setValue(key, start);
            item.setSubLabel(beersText(start));
        } else {
            var labels = choiceLabels(key);
            if (labels == null) {
                return;
            }
            var next = (BeerSettings.readNumber(key, 0, labels.size()) + 1) % labels.size();
            Application.Properties.setValue(key, next);
            item.setSubLabel(labels[next]);
        }
        getApp().onSettingsChanged();
    }
}

//! Labels of a list setting, indexed by its value; null for other keys.
function choiceLabels(key as String) as Array<ResourceId>? {
    if (key.equals(BeerSettings.KEY_STYLE)) {
        return [Rez.Strings.StylePils, Rez.Strings.StyleWheat, Rez.Strings.StyleAmber,
            Rez.Strings.StyleRedAle, Rez.Strings.StyleStout] as Array<ResourceId>;
    } else if (key.equals(BeerSettings.KEY_SHAPE)) {
        return [Rez.Strings.ShapeMug, Rez.Strings.ShapeWeizen, Rez.Strings.ShapePint,
            Rez.Strings.ShapeBottle] as Array<ResourceId>;
    } else if (key.equals(BeerSettings.KEY_BACKGROUND)) {
        return [Rez.Strings.BgAuto, Rez.Strings.BgBlack, Rez.Strings.BgWhite] as Array<ResourceId>;
    } else if (key.equals(BeerSettings.KEY_ROUNDING)) {
        return [Rez.Strings.RoundDown, Rez.Strings.RoundNearest, Rez.Strings.RoundUp,
            Rez.Strings.RoundExact] as Array<ResourceId>;
    }
    return null;
}

function caloriesText(cal as Float) as String {
    return cal.format("%d") + " kcal";
}

function beersText(beers as Float) as String {
    return beers == beers.toNumber() ? beers.format("%d") : beers.format("%.1f");
}
