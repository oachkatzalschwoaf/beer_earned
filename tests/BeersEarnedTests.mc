import Toybox.Activity;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;

// Unit tests (Run No Evil). They only exist in builds made with --unit-test and run
// inside the simulator: see "Tests" in CLAUDE.md. Every (:test) function is a test;
// shared helpers live in the (:test) class TestKit.

(:test)
function testDisplayValueRounding(logger as Logger) as Boolean {
    var ok = TestKit.expect(logger, BeerMath.displayValue(2.7f, BeerSettings.ROUND_DOWN), 2.0f, "down");
    ok = TestKit.expect(logger, BeerMath.displayValue(2.7f, BeerSettings.ROUND_NEAREST), 3.0f, "nearest") && ok;
    ok = TestKit.expect(logger, BeerMath.displayValue(2.2f, BeerSettings.ROUND_NEAREST), 2.0f, "nearest low") && ok;
    ok = TestKit.expect(logger, BeerMath.displayValue(2.2f, BeerSettings.ROUND_UP), 3.0f, "up") && ok;
    ok = TestKit.expect(logger, BeerMath.displayValue(2.0f, BeerSettings.ROUND_UP), 2.0f, "up exact") && ok;
    ok = TestKit.expect(logger, BeerMath.displayValue(2.79f, BeerSettings.ROUND_EXACT), 2.7f, "exact truncates") && ok;
    // 405 kcal / 150 is 2.7 within float error and must not show as 2.6.
    ok = TestKit.expect(logger, BeerMath.displayValue(405.0f / 150.0f, BeerSettings.ROUND_EXACT), 2.7f, "exact float error") && ok;
    return ok;
}

(:test)
function testCountText(logger as Logger) as Boolean {
    var ok = TestKit.expect(logger, BeerMath.countText(3.0f, BeerSettings.ROUND_DOWN), "3", "whole");
    ok = TestKit.expect(logger, BeerMath.countText(0.4f, BeerSettings.ROUND_DOWN), "0", "zero") && ok;
    ok = TestKit.expect(logger, BeerMath.countText(12.96f, BeerSettings.ROUND_EXACT), "12.9", "one decimal") && ok;
    ok = TestKit.expect(logger, BeerMath.countText(2.0f, BeerSettings.ROUND_EXACT), "2.0", "decimal of whole") && ok;
    return ok;
}

(:test)
function testFillFraction(logger as Logger) as Boolean {
    var ok = TestKit.expect(logger, BeerMath.fillFraction(2.25f), 0.25f, "quarter");
    ok = TestKit.expect(logger, BeerMath.fillFraction(3.0f), 0.0f, "empty on a whole beer") && ok;
    ok = TestKit.expect(logger, BeerMath.fillFraction(0.0f), 0.0f, "start") && ok;
    return ok;
}

(:test)
function testInvalidSettingsFallBack(logger as Logger) as Boolean {
    TestKit.defaults();
    TestKit.set(BeerSettings.KEY_DRINK, 99);
    TestKit.set(BeerSettings.KEY_CALORIES, 0.0f);
    var cfg = new BeerSettings.Config();
    TestKit.defaults();
    var ok = TestKit.expect(logger, cfg.drink, BeerSettings.DRINK_MUG, "drink");
    return TestKit.expect(logger, cfg.caloriesPerBeer, 150.0f, "calories") && ok;
}

(:test)
function testDrinkTables(logger as Logger) as Boolean {
    var n = BeerSettings.DRINK_COUNT;
    var ok = TestKit.expect(logger, BeerSettings.DRINK_SHAPES.size(), n, "shapes");
    ok = TestKit.expect(logger, BeerSettings.DRINK_CALORIES.size(), n, "calories") && ok;
    ok = TestKit.expect(logger, BeerRenderer.BEER_COLORS.size(), n, "colours") && ok;
    ok = TestKit.expect(logger, BeerRenderer.HIGHLIGHT_COLORS.size(), n, "highlights") && ok;
    return TestKit.expect(logger, (choiceLabels(BeerSettings.KEY_DRINK) as Array).size(), n, "labels") && ok;
}

(:test)
function testNewDrinkBringsItsCalories(logger as Logger) as Boolean {
    TestKit.defaults();
    TestKit.set(BeerSettings.KEY_DRINK, BeerSettings.DRINK_COLA);
    BeerSettings.sync();
    var cola = new BeerSettings.Config().caloriesPerBeer;
    // The user's own value stays while the drink does.
    TestKit.set(BeerSettings.KEY_CALORIES, 200.0f);
    BeerSettings.sync();
    BeerSettings.sync();
    var own = new BeerSettings.Config().caloriesPerBeer;
    // Another drink goes back to a default.
    TestKit.set(BeerSettings.KEY_DRINK, BeerSettings.DRINK_PILS);
    BeerSettings.sync();
    var pils = new BeerSettings.Config().caloriesPerBeer;
    TestKit.defaults();
    var ok = TestKit.expect(logger, cola, 139.0f, "cola default");
    ok = TestKit.expect(logger, own, 200.0f, "own value kept") && ok;
    return TestKit.expect(logger, pils, 140.0f, "pils default") && ok;
}

(:test)
function testCaloriesSetWithTheDrinkAreKept(logger as Logger) as Boolean {
    TestKit.defaults();
    TestKit.set(BeerSettings.KEY_DRINK, BeerSettings.DRINK_COLA);
    TestKit.set(BeerSettings.KEY_CALORIES, 210.0f);
    BeerSettings.sync();
    var cfg = new BeerSettings.Config();
    TestKit.defaults();
    return TestKit.expect(logger, cfg.caloriesPerBeer, 210.0f, "one change, both settings");
}

(:test)
function testUpgradeFromOldSettings(logger as Logger) as Boolean {
    TestKit.firstRun();
    TestKit.set(BeerSettings.KEY_OLD_STYLE, 4);
    TestKit.set(BeerSettings.KEY_OLD_SHAPE, BeerSettings.SHAPE_PINT);
    TestKit.set(BeerSettings.KEY_CALORIES, 180.0f);
    BeerSettings.sync();
    var cfg = new BeerSettings.Config();
    TestKit.defaults();
    var ok = TestKit.expect(logger, cfg.drink, BeerSettings.DRINK_STOUT, "stout");
    return TestKit.expect(logger, cfg.caloriesPerBeer, 180.0f, "calories kept") && ok;
}

(:test)
function testDrinkChosenBeforeFirstRun(logger as Logger) as Boolean {
    TestKit.firstRun();
    TestKit.set(BeerSettings.KEY_DRINK, BeerSettings.DRINK_COLA);
    BeerSettings.sync();
    var cfg = new BeerSettings.Config();
    TestKit.defaults();
    var ok = TestKit.expect(logger, cfg.drink, BeerSettings.DRINK_COLA, "choice kept");
    return TestKit.expect(logger, cfg.caloriesPerBeer, 139.0f, "cola calories") && ok;
}

(:test)
function testMilestonesFollowTheDrink(logger as Logger) as Boolean {
    TestKit.defaults();
    TestKit.set(BeerSettings.KEY_DRINK, BeerSettings.DRINK_COLA);
    var view = new RecordingView();
    TestKit.feed(view, [0, 138, 139, 278] as Array<Number>);
    TestKit.defaults();
    return TestKit.expect(logger, view.celebrated.toString(), "[1, 2]", "one alert per cola");
}

(:test)
function testMilestoneAlerts(logger as Logger) as Boolean {
    TestKit.defaults();
    var view = new RecordingView();
    TestKit.feed(view, [0, 100, 149, 150, 151, 299, 300, 460] as Array<Number>);
    return TestKit.expect(logger, view.celebrated.toString(), "[1, 2, 3]", "one alert per whole beer");
}

(:test)
function testNoAlertWhenAddedMidActivity(logger as Logger) as Boolean {
    TestKit.defaults();
    var view = new RecordingView();
    TestKit.feed(view, [320, 330, 450] as Array<Number>);
    return TestKit.expect(logger, view.celebrated.toString(), "[3]", "baseline from the first sample");
}

(:test)
function testNoAlertWhenSettingsJump(logger as Logger) as Boolean {
    TestKit.defaults();
    var view = new RecordingView();
    TestKit.feed(view, [0, 100] as Array<Number>);
    TestKit.set(BeerSettings.KEY_CALORIES, 20.0f);
    view.reloadSettings();
    TestKit.feed(view, [110, 160] as Array<Number>);
    TestKit.defaults();
    // 0.7 -> 5.5 by the setting: no alert; 5.5 -> 8.0 by burning calories: alert.
    return TestKit.expect(logger, view.celebrated.toString(), "[8]", "new calories re-baseline");
}

(:test)
function testTimerResetStartsOver(logger as Logger) as Boolean {
    TestKit.defaults();
    var view = new RecordingView();
    TestKit.feed(view, [0, 400] as Array<Number>);
    view.onTimerReset();
    TestKit.feed(view, [0, 160] as Array<Number>);
    return TestKit.expect(logger, view.celebrated.toString(), "[2, 1]", "second activity counts from zero");
}

//! The data field with its celebrations recorded instead of shown, and no FIT
//! fields (creating them needs a running activity).
(:test)
class RecordingView extends BeersEarnedView {
    var celebrated as Array<Number> = [] as Array<Number>;

    function initialize() {
        BeersEarnedView.initialize();
    }

    protected function _createFitFields() as Void {
    }

    protected function _celebrate(count as Number) as Void {
        celebrated.add(count);
    }
}

(:test)
class TestKit {

    static function feed(view as BeersEarnedView, calories as Array<Number>) as Void {
        var info = new Activity.Info();
        for (var i = 0; i < calories.size(); i++) {
            info.calories = calories[i];
            view.compute(info);
        }
    }

    static function set(key as String, value as Number or Float) as Void {
        Application.Properties.setValue(key, value);
    }

    // The shipped defaults, already seen by sync().
    static function defaults() as Void {
        set(BeerSettings.KEY_DRINK, BeerSettings.DRINK_MUG);
        set(BeerSettings.KEY_CALORIES, 150.0f);
        set(BeerSettings.KEY_OLD_STYLE, 2);
        set(BeerSettings.KEY_OLD_SHAPE, BeerSettings.SHAPE_MUG);
        Application.Storage.setValue(BeerSettings.SEEN_DRINK, BeerSettings.DRINK_MUG);
        Application.Storage.setValue(BeerSettings.SEEN_CALORIES, 150.0f);
    }

    // As right after installing or updating: sync() has never run.
    static function firstRun() as Void {
        defaults();
        Application.Storage.deleteValue(BeerSettings.SEEN_DRINK);
        Application.Storage.deleteValue(BeerSettings.SEEN_CALORIES);
    }

    static function expect(logger as Logger, actual as Object?, expected as Object?, what as String) as Boolean {
        var ok = (actual == null) ? expected == null : actual.equals(expected);
        if (!ok) {
            logger.error(what + ": expected " + expected + ", got " + actual);
        }
        return ok;
    }
}
