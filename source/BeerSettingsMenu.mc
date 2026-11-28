import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! On-device settings, opened from the activity's settings on the watch; they mirror
//! the Garmin Connect settings. The drink opens a list and the calories a number pad;
//! selecting any other list item cycles it to its next value.
class BeerSettingsMenu extends WatchUi.Menu2 {

    // The two items that change together.
    private var _drink as WatchUi.MenuItem;
    private var _calories as WatchUi.MenuItem;

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.AppName });
        BeerSettings.sync();
        var cfg = new BeerSettings.Config();

        _drink = new WatchUi.MenuItem(Rez.Strings.SettingsDrink, "", BeerSettings.KEY_DRINK, null);
        addItem(_drink);
        _calories = new WatchUi.MenuItem(Rez.Strings.SettingsCaloriesPerBeer, "",
            BeerSettings.KEY_CALORIES, null);
        addItem(_calories);
        showDrink(cfg);
        _addChoice(Rez.Strings.SettingsBackground, BeerSettings.KEY_BACKGROUND, cfg.background);
        _addChoice(Rez.Strings.SettingsRounding, BeerSettings.KEY_ROUNDING, cfg.rounding);
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SettingsAlertPopup, null,
            BeerSettings.KEY_POPUP, cfg.alertPopup, null));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SettingsAlertVibrate, null,
            BeerSettings.KEY_VIBRATE, cfg.alertVibrate, null));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SettingsAlertTone, null,
            BeerSettings.KEY_TONE, cfg.alertTone, null));
    }

    //! Show the chosen drink and its calories.
    function showDrink(cfg as BeerSettings.Config) as Void {
        var labels = choiceLabels(BeerSettings.KEY_DRINK) as Array<ResourceId>;
        _drink.setSubLabel(labels[cfg.drink]);
        _calories.setSubLabel(caloriesText(cfg.caloriesPerBeer));
    }

    private function _addChoice(title as ResourceId, key as String, value as Number) as Void {
        var labels = choiceLabels(key) as Array<ResourceId>;
        addItem(new WatchUi.MenuItem(title, labels[value], key, null));
    }
}

class BeerSettingsDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as BeerSettingsMenu;

    function initialize(menu as BeerSettingsMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId();
        if (!(key instanceof String)) {
            return;
        }
        if (item instanceof WatchUi.ToggleMenuItem) {
            // The menu has already flipped the toggle.
            Application.Properties.setValue(key, item.isEnabled());
        } else if (key.equals(BeerSettings.KEY_DRINK)) {
            var current = BeerSettings.readNumber(key, BeerSettings.DRINK_MUG, BeerSettings.DRINK_COUNT);
            WatchUi.pushView(new BeerDrinkMenu(current), new BeerDrinkDelegate(_menu), WatchUi.SLIDE_LEFT);
            return;
        } else if (key.equals(BeerSettings.KEY_CALORIES)) {
            var cfg = new BeerSettings.Config();
            var pad = new BeerKeypad(cfg.caloriesPerBeer.toNumber());
            WatchUi.pushView(pad, new BeerKeypadDelegate(pad, _menu), WatchUi.SLIDE_LEFT);
            return;
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

//! The list of drinks, opened on the current one.
class BeerDrinkMenu extends WatchUi.Menu2 {

    function initialize(current as Number) {
        Menu2.initialize({ :title => Rez.Strings.SettingsDrink, :focus => current });
        var labels = choiceLabels(BeerSettings.KEY_DRINK) as Array<ResourceId>;
        for (var i = 0; i < labels.size(); i++) {
            addItem(new WatchUi.MenuItem(labels[i], null, i, null));
        }
    }
}

class BeerDrinkDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as BeerSettingsMenu;

    function initialize(menu as BeerSettingsMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        Application.Properties.setValue(BeerSettings.KEY_DRINK, item.getId() as Number);
        BeerSettings.sync(); // the new drink's calories
        _menu.showDrink(new BeerSettings.Config());
        getApp().onSettingsChanged();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

//! Labels of a list setting, indexed by its value; null for other keys.
function choiceLabels(key as String) as Array<ResourceId>? {
    if (key.equals(BeerSettings.KEY_DRINK)) {
        return [Rez.Strings.DrinkMug, Rez.Strings.DrinkPils, Rez.Strings.DrinkWheat,
            Rez.Strings.DrinkBottle, Rez.Strings.DrinkStout, Rez.Strings.DrinkCola,
            Rez.Strings.DrinkSpezi, Rez.Strings.DrinkHerbal] as Array<ResourceId>;
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
