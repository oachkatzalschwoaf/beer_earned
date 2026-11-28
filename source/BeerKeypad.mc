import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Number pad for the calories per drink. Tap the keys on a touch screen, or move the
//! highlight with up / down and press it with select. Back leaves without saving.
class BeerKeypad extends WatchUi.View {

    const KEY_DELETE = 9;
    const KEY_OK = 11;
    const KEY_COUNT = 12;

    var focus as Number = 0;                // highlighted key

    private var _labels as Array<String> = ["1", "2", "3", "4", "5", "6", "7", "8", "9",
        "<", "0", "OK"] as Array<String>;
    private var _digits as String = "";     // typed so far
    private var _current as Number;         // shown until the first digit

    // Key grid, set by onUpdate().
    private var _x as Number = 0;
    private var _y as Number = 0;
    private var _kw as Number = 1;
    private var _kh as Number = 1;

    function initialize(current as Number) {
        View.initialize();
        _current = current;
    }

    //! The value typed, or null while nothing has been typed.
    function entry() as Number? {
        return _digits.toNumber();
    }

    //! The key under a tap, or -1.
    function keyAt(x as Number, y as Number) as Number {
        if (x < _x || y < _y || x >= _x + 3 * _kw || y >= _y + 4 * _kh) {
            return -1;
        }
        return (y - _y) / _kh * 3 + (x - _x) / _kw;
    }

    //! Press a key; true once the entry is finished.
    function press(key as Number) as Boolean {
        focus = key;
        if (key == KEY_OK) {
            var value = entry();
            // Nothing typed keeps the old value; an out-of-range entry stays open.
            return value == null
                || (value >= BeerSettings.MIN_CALORIES && value <= BeerSettings.MAX_CALORIES);
        }
        if (key == KEY_DELETE) {
            if (_digits.length() > 0) {
                _digits = _digits.substring(0, _digits.length() - 1) as String;
            }
        } else if (_digits.length() < 4 && !(_digits.length() == 0 && _labels[key].equals("0"))) {
            _digits += _labels[key];
        }
        WatchUi.requestUpdate();
        return false;
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        // On round screens the grid stays inside the bezel.
        var round = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND;
        _x = (w * (round ? 0.18f : 0.03f)).toNumber();
        _y = (h * (round ? 0.25f : 0.20f)).toNumber();
        _kw = (w - 2 * _x) / 3;
        _kh = (h * (round ? 0.62f : 0.78f)).toNumber() / 4;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        var just = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        var value = entry();
        var color = 0xAAAAAA; // the old value, not yet overwritten
        if (value != null) {
            color = value >= BeerSettings.MIN_CALORIES && value <= BeerSettings.MAX_CALORIES
                ? Graphics.COLOR_WHITE : 0xFF0000;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, _y / 2 + (round ? h / 40 : 0), Graphics.FONT_MEDIUM,
            (value == null ? _current.format("%d") : _digits) + " kcal", just);

        for (var i = 0; i < KEY_COUNT; i++) {
            var kx = _x + (i % 3) * _kw;
            var ky = _y + (i / 3) * _kh;
            if (i == focus) {
                dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(kx + 2, ky + 2, _kw - 4, _kh - 4, 6);
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(kx + 2, ky + 2, _kw - 4, _kh - 4, 6);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(kx + _kw / 2, ky + _kh / 2, Graphics.FONT_MEDIUM, _labels[i], just);
        }
    }
}

class BeerKeypadDelegate extends WatchUi.BehaviorDelegate {

    private var _pad as BeerKeypad;
    private var _menu as BeerSettingsMenu;

    function initialize(pad as BeerKeypad, menu as BeerSettingsMenu) {
        BehaviorDelegate.initialize();
        _pad = pad;
        _menu = menu;
    }

    function onTap(event as WatchUi.ClickEvent) as Boolean {
        var at = event.getCoordinates();
        var key = _pad.keyAt(at[0], at[1]);
        if (key >= 0) {
            _press(key);
        }
        return true;
    }

    // Select buttons. Taps never get here: they are handled by onTap().
    function onKey(event as WatchUi.KeyEvent) as Boolean {
        var key = event.getKey();
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            _press(_pad.focus);
            return true;
        }
        return false;
    }

    function onNextPage() as Boolean {
        _pad.focus = (_pad.focus + 1) % _pad.KEY_COUNT;
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        _pad.focus = (_pad.focus + _pad.KEY_COUNT - 1) % _pad.KEY_COUNT;
        WatchUi.requestUpdate();
        return true;
    }

    private function _press(key as Number) as Void {
        if (!_pad.press(key)) {
            WatchUi.requestUpdate();
            return;
        }
        var value = _pad.entry();
        if (value != null) {
            Application.Properties.setValue(BeerSettings.KEY_CALORIES, value.toFloat());
            BeerSettings.sync();
            _menu.showDrink(new BeerSettings.Config());
            getApp().onSettingsChanged();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
