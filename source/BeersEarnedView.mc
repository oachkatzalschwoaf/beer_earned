import Toybox.Activity;
import Toybox.Attention;
import Toybox.FitContributor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

//! The data field: converts the activity's calories into beers, draws the vessel
//! filling up toward the next beer, celebrates each whole beer and records the
//! count into the activity's FIT file.
class BeersEarnedView extends WatchUi.DataField {

    // FIT developer field ids. Garmin Connect labels and charts them through
    // resources/fitcontributions; once published, never renumber or retype them.
    private const FIELD_BEERS = 0; // RECORD: running count (smooth) -> chart
    private const FIELD_TOTAL = 1; // SESSION: final count as displayed -> activity summary
    private const FIELD_LAP = 2;   // LAP: beers earned within the lap -> laps table

    private var _cfg as BeerSettings.Config;

    private var _calories as Float = 0.0f;         // kcal burned so far in this activity
    private var _lapStartCalories as Float = 0.0f;
    private var _rawBeers as Float = 0.0f;         // unrounded count incl. the starting offset
    private var _lastWhole as Number = -1;         // whole beers at the last check; -1 = no baseline yet
    private var _tick as Number = 0;               // advances the bubble animation

    private var _beersField as FitContributor.Field?;
    private var _totalField as FitContributor.Field?;
    private var _lapField as FitContributor.Field?;

    function initialize() {
        DataField.initialize();
        _cfg = new BeerSettings.Config();
        _rawBeers = _cfg.startingBeers;
        _createFitFields();
    }

    // Protected so the unit tests, which run outside an activity, can skip it.
    protected function _createFitFields() as Void {
        _beersField = createField("beers", FIELD_BEERS, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "beers" });
        _totalField = createField("total_beers", FIELD_TOTAL, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "beers" });
        _lapField = createField("lap_beers", FIELD_LAP, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "beers" });
    }

    // Called once per second. For a DataField the return value is ignored; the FIT
    // fields below are what ends up in the activity.
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var cal = info.calories;
        if (cal != null) {
            _calories = cal.toFloat();
        }
        _rawBeers = _cfg.startingBeers + _calories / _cfg.caloriesPerBeer;
        if (cal != null) {
            _checkMilestone();
        }

        if (_beersField != null) {
            _beersField.setData(_rawBeers);
        }
        if (_totalField != null) {
            _totalField.setData(BeerMath.displayValue(_rawBeers, _cfg.rounding));
        }
        if (_lapField != null) {
            _lapField.setData((_calories - _lapStartCalories) / _cfg.caloriesPerBeer);
        }
        return null;
    }

    function onTimerLap() as Void {
        _lapStartCalories = _calories;
    }

    // The activity was saved or discarded: start over for the next one.
    function onTimerReset() as Void {
        _calories = 0.0f;
        _lapStartCalories = 0.0f;
        _rawBeers = _cfg.startingBeers;
        _lastWhole = -1;
    }

    function onUpdate(dc as Dc) as Void {
        _tick += 1;
        var s = _scene();
        dc.setColor(s.bg, s.bg);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = 0;
        var cy = 0;
        var r = 0;
        var ds = System.getDeviceSettings();
        if (ds.screenShape == System.SCREEN_SHAPE_ROUND) {
            // Locate this slot on the round screen from the bezel edges it touches,
            // so the renderer can keep the drawing clear of the bezel.
            var flags = getObscurityFlags() as Number;
            r = ds.screenWidth / 2;
            cx = r - _slotOffset(flags & OBSCURE_LEFT, flags & OBSCURE_RIGHT, ds.screenWidth, w);
            cy = ds.screenHeight / 2 - _slotOffset(flags & OBSCURE_TOP, flags & OBSCURE_BOTTOM, ds.screenHeight, h);
        }
        new BeerPainter(dc, s).drawField(0, 0, w, h, cx, cy, r);
    }

    // The data screen is visible again, e.g. after leaving the on-device settings menu,
    // which may run in its own app instance that can't notify this one.
    function onShow() as Void {
        reloadSettings();
    }

    //! Re-read the settings after they changed on the phone or on the watch.
    function reloadSettings() as Void {
        var oldCalories = _cfg.caloriesPerBeer;
        var oldStart = _cfg.startingBeers;
        _cfg.load();
        if (oldCalories != _cfg.caloriesPerBeer || oldStart != _cfg.startingBeers) {
            _lastWhole = -1; // re-baseline so the jump in the count doesn't fire alerts
        }
        _rawBeers = _cfg.startingBeers + _calories / _cfg.caloriesPerBeer;
        WatchUi.requestUpdate();
    }

    // Offset of the slot from the screen's start edge along one axis: a slot touching
    // only the start (or end) bezel sits flush against it, otherwise assume centred.
    private function _slotOffset(startEdge as Number, endEdge as Number, screen as Number, size as Number) as Number {
        if (startEdge != 0 && endEdge == 0) {
            return 0;
        }
        if (endEdge != 0 && startEdge == 0) {
            return screen - size;
        }
        return (screen - size) / 2;
    }

    private function _scene() as BeerScene {
        var s = new BeerScene();
        s.text = BeerMath.countText(_rawBeers, _cfg.rounding);
        s.frac = BeerMath.fillFraction(_rawBeers);
        s.style = _cfg.style;
        s.shape = _cfg.shape;
        var bg = Graphics.COLOR_BLACK;
        if (_cfg.background == BeerSettings.BG_WHITE) {
            bg = Graphics.COLOR_WHITE;
        } else if (_cfg.background == BeerSettings.BG_AUTO) {
            var sys = getBackgroundColor() as Number;
            if (sys != Graphics.COLOR_TRANSPARENT) {
                bg = sys;
            }
        }
        s.bg = bg;
        s.fg = BeerRenderer.contrastColor(bg);
        s.tick = _tick;
        return s;
    }

    // Celebrate each time the count crosses a whole beer. The first sample only sets
    // the baseline, so adding the field mid-activity doesn't fire stale alerts.
    private function _checkMilestone() as Void {
        var whole = Math.floor(_rawBeers).toNumber();
        if (_lastWhole >= 0 && whole > _lastWhole) {
            _celebrate(whole);
        }
        _lastWhole = whole;
    }

    // Protected so the unit tests can observe it.
    protected function _celebrate(count as Number) as Void {
        if (_cfg.alertPopup && (WatchUi.DataField has :showAlert)) {
            var s = _scene();
            s.frac = 1.0f;
            s.text = count.format("%d");
            WatchUi.DataField.showAlert(new BeerAlertView(s));
        }
        var ds = System.getDeviceSettings();
        if (_cfg.alertVibrate && (Attention has :vibrate) && ds.vibrateOn) {
            // Two short pulses: clink, clink.
            Attention.vibrate([
                new Attention.VibeProfile(80, 180),
                new Attention.VibeProfile(0, 120),
                new Attention.VibeProfile(80, 180)
            ] as Array<Attention.VibeProfile>);
        }
        if (_cfg.alertTone && (Attention has :playTone) && ds.tonesOn) {
            Attention.playTone(Attention.TONE_SUCCESS);
        }
    }
}
