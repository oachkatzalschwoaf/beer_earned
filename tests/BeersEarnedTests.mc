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
function testNextPreset(logger as Logger) as Boolean {
    var presets = [100, 150, 200] as Array<Number>;
    var ok = TestKit.expect(logger, BeerSettings.nextPreset(presets, 150.0f), 200.0f, "next");
    ok = TestKit.expect(logger, BeerSettings.nextPreset(presets, 165.0f), 200.0f, "custom value") && ok;
    ok = TestKit.expect(logger, BeerSettings.nextPreset(presets, 200.0f), 100.0f, "wraps") && ok;
    return ok;
}

(:test)
function testInvalidSettingsFallBack(logger as Logger) as Boolean {
    TestKit.defaults();
    Application.Properties.setValue(BeerSettings.KEY_CALORIES, 0.0f);
    Application.Properties.setValue(BeerSettings.KEY_STYLE, 99);
    var cfg = new BeerSettings.Config();
    TestKit.defaults();
    var ok = TestKit.expect(logger, cfg.caloriesPerBeer, 150.0f, "calories");
    return TestKit.expect(logger, cfg.style, BeerSettings.STYLE_AMBER, "style") && ok;
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
    Application.Properties.setValue(BeerSettings.KEY_START, 5.0f);
    view.reloadSettings();
    TestKit.feed(view, [110, 160] as Array<Number>);
    TestKit.defaults();
    // 0.67 -> 5.73 by the setting: no alert; 5.73 -> 6.07 by burning calories: alert.
    return TestKit.expect(logger, view.celebrated.toString(), "[6]", "offset change re-baselines");
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

    static function defaults() as Void {
        Application.Properties.setValue(BeerSettings.KEY_CALORIES, 150.0f);
        Application.Properties.setValue(BeerSettings.KEY_START, 0.0f);
        Application.Properties.setValue(BeerSettings.KEY_STYLE, BeerSettings.STYLE_AMBER);
    }

    static function expect(logger as Logger, actual as Object?, expected as Object?, what as String) as Boolean {
        var ok = (actual == null) ? expected == null : actual.equals(expected);
        if (!ok) {
            logger.error(what + ": expected " + expected + ", got " + actual);
        }
        return ok;
    }
}
