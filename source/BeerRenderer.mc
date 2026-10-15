import Toybox.Graphics;
import Toybox.Lang;

//! Everything one frame of the field shows. Built by the view, drawn by BeerPainter.
class BeerScene {
    var text as String = "0";                       // the count as displayed
    var frac as Float = 0.0f;                       // fill level: progress toward the next beer, 0..1
    var style as Number = BeerSettings.STYLE_AMBER;
    var shape as Number = BeerSettings.SHAPE_MUG;
    var bg as Number = Graphics.COLOR_BLACK;
    var fg as Number = Graphics.COLOR_WHITE;
    var tick as Number = 0;                         // animation phase for the rising bubbles

    function initialize() {
    }
}

//! Colours, vessel profiles and stateless helpers used by BeerPainter.
module BeerRenderer {

    // Palette-exact colours (components 00/55/AA/FF) so 64-colour MIP screens show
    // them undithered. Indexed by BeerSettings.STYLE_*.
    const BEER_COLORS = [0xFFFF55, 0xFFAA55, 0xFFAA00, 0xAA0000, 0x550000] as Array<Number>;
    const HIGHLIGHT_COLORS = [0xFFFFAA, 0xFFFFAA, 0xFFFF55, 0xFF5500, 0xAA5500] as Array<Number>;

    // Half-width profiles of the glass shapes as (t, f) pairs with strictly increasing
    // t: 0 at the rim to 1 at the base, f = fraction of the maximum half-width.
    const PROFILE_WEIZEN = [0.0f, 0.86f, 0.12f, 1.0f, 0.45f, 0.80f, 0.70f, 0.60f, 0.90f, 0.48f, 1.0f, 0.54f] as Array<Float>;
    const PROFILE_PINT = [0.0f, 0.94f, 0.07f, 1.0f, 0.16f, 0.93f, 1.0f, 0.72f] as Array<Float>;
    const PROFILE_BOTTLE = [0.0f, 0.42f, 0.06f, 0.42f, 0.07f, 0.34f, 0.30f, 0.34f, 0.45f, 0.92f, 0.53f, 1.0f, 0.96f, 1.0f, 1.0f, 0.92f] as Array<Float>;
    const BOTTLE_CAP = 0.07f; // the top 7% of the bottle is its solid cap

    // Candidate fonts for the count; the largest one that fits wins.
    const FONTS = [
        Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM,
        Graphics.FONT_NUMBER_MILD, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM,
        Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY
    ] as Array<FontDefinition>;

    //! Width / height of a vessel's bounding box.
    function aspect(shape as Number) as Float {
        if (shape == BeerSettings.SHAPE_WEIZEN) { return 0.46f; }
        if (shape == BeerSettings.SHAPE_PINT) { return 0.66f; }
        if (shape == BeerSettings.SHAPE_BOTTLE) { return 0.42f; }
        return 0.92f; // mug including its handle
    }

    //! Largest font (by rendered height) whose box for `text` fits maxW x maxH, or null.
    function pickFont(dc as Dc, text as String, maxW as Numeric, maxH as Numeric) as FontDefinition? {
        var best = null;
        var bestH = 0;
        for (var i = 0; i < FONTS.size(); i++) {
            var d = dc.getTextDimensions(text, FONTS[i]);
            if (d[0] <= maxW && d[1] <= maxH && d[1] > bestH) {
                best = FONTS[i];
                bestH = d[1];
            }
        }
        return best;
    }

    function isLight(color as Number) as Boolean {
        return ((color >> 16) & 0xFF) + ((color >> 8) & 0xFF) + (color & 0xFF) > 384;
    }

    //! Foreground colour that contrasts with `bg`.
    function contrastColor(bg as Number) as Number {
        return isLight(bg) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function sign(v as Numeric) as Number {
        return v > 0 ? 1 : (v < 0 ? -1 : 0);
    }
}

//! Draws a BeerScene: the vessel filling up and the count, laid out for a data-field
//! slot. All geometry derives from the slot size, so one code path serves every
//! device and every data-screen layout.
//!
//! Monkey C's call stack is tiny (a data field overflows it ~8 calls deep), so shared
//! geometry lives in members instead of parameters, the layout step only measures
//! and the drawing calls stay shallow.
class BeerPainter {

    private var _dc as Dc;
    private var _s as BeerScene;

    // Bezel circle in dc coordinates, radius shrunk by a margin; 0 = rectangular screen.
    private var _cx as Number = 0;
    private var _cy as Number = 0;
    private var _r as Number = 0;

    // Layout result: vessel box (left, top, height) and where the count goes.
    private var _gx as Float = 0.0f;
    private var _top as Float = 0.0f;
    private var _gh as Float = 0.0f;
    private var _font as FontDefinition = Graphics.FONT_XTINY;
    private var _tx as Float = 0.0f;
    private var _ty as Float = 0.0f;
    private var _tw as Float = 0.0f; // max text box when the count goes inside the vessel
    private var _th as Float = 0.0f;

    // Vessel geometry: centre line and wall thickness. Glasses use a half-width
    // profile scaled to _maxHalf; the mug (_prof == null) a rounded-rectangle interior
    // _iL/_iW/_iR. _iT/_iB bound the interior vertically for both.
    private var _mid as Float = 0.0f;
    private var _wall as Float = 2.0f;
    private var _prof as Array<Float>? = null;
    private var _maxHalf as Float = 0.0f;
    private var _iL as Float = 0.0f;
    private var _iW as Float = 0.0f;
    private var _iR as Float = 0.0f;
    private var _iT as Float = 0.0f;
    private var _iB as Float = 0.0f;

    function initialize(dc as Dc, scene as BeerScene) {
        _dc = dc;
        _s = scene;
    }

    //! Draw the field into the slot (x, y, w, h) of the dc. (cx, cy, r) is the round
    //! screen's circle in dc coordinates, r = 0 on rectangular screens: content shrinks
    //! until it lies inside that circle, so the bezel never cuts it off.
    function drawField(x as Number, y as Number, w as Number, h as Number, cx as Number, cy as Number, r as Number) as Void {
        _cx = cx;
        _cy = cy;
        _r = r > 0 ? r - 3 - r / 25 : 0; // keep a little air between drawing and bezel
        var mode = 0; // 0: count only, 1: count inside a big vessel, 2: vessel left of the count
        if (w >= 56 && h >= 56 && 2 * w < 3 * h) {
            mode = _fitStacked(x, y, w, h) ? 1 : 0;
        } else if (w >= 90 && h >= 30) {
            mode = _fitSideBySide(x, y, w, h) ? 2 : 0;
        }
        if (mode == 0) {
            _fitCount(x, y, w, h);
        } else {
            var ty = _ty;
            drawVessel(_gx, _top, _gh, mode == 1);
            _ty = ty; // the shell moved it to the in-vessel text position
        }
        if (mode != 1) {
            _dc.setColor(_s.fg, Graphics.COLOR_TRANSPARENT);
            _dc.drawText(_tx, _ty, _font, _s.text, Graphics.TEXT_JUSTIFY_VCENTER
                | (mode == 2 ? Graphics.TEXT_JUSTIFY_LEFT : Graphics.TEXT_JUSTIFY_CENTER));
        }
    }

    //! Draw the vessel whose bounding box has its top-left at (gx, gy) and height gh,
    //! optionally with the count written inside it.
    function drawVessel(gx as Float, gy as Float, gh as Float, withText as Boolean) as Void {
        _top = gy;
        _gh = gh;
        _wall = gh * 0.035f;
        if (_wall < 2.0f) {
            _wall = 2.0f;
        }
        if (_s.shape == BeerSettings.SHAPE_MUG) {
            _mugShell(gx);
        } else {
            _glassShell(gx);
        }
        _drawContents();
        if (withText) {
            _countInside();
        }
    }

    // ---- Layout: measure only, results go to the members ---------------------------

    private function _fitStacked(x as Number, y as Number, w as Number, h as Number) as Boolean {
        var a = BeerRenderer.aspect(_s.shape);
        var gh = (h - 6).toFloat();
        if (gh * a > w - 6) {
            gh = (w - 6) / a;
        }
        // When the slot touches the bezel, slide toward the screen centre before shrinking.
        var dx = BeerRenderer.sign(_cx - (x + w / 2)) * w * 0.05f;
        var dy = BeerRenderer.sign(_cy - (y + h / 2)) * h * 0.06f;
        var tries = (_r > 0 && (dx != 0 || dy != 0)) ? 4 : 1;
        while (gh >= 40.0f) {
            var gw = gh * a;
            for (var k = 0; k < tries; k++) {
                _gx = x + (w - gw) / 2 + dx * k;
                _top = y + (h - gh) / 2 + dy * k;
                if (_gx < x || _top < y || _gx + gw > x + w || _top + gh > y + h) {
                    break;
                }
                if (_inside(_gx, _top, _gx + gw, _top + gh)) {
                    _gh = gh;
                    return true;
                }
            }
            gh *= 0.92f;
        }
        return false;
    }

    private function _fitSideBySide(x as Number, y as Number, w as Number, h as Number) as Boolean {
        var a = BeerRenderer.aspect(_s.shape);
        var dx = BeerRenderer.sign(_cx - (x + w / 2)) * w * 0.04f;
        var dy = BeerRenderer.sign(_cy - (y + h / 2)) * h * 0.06f;
        var tries = (_r > 0 && (dx != 0 || dy != 0)) ? 4 : 1;
        var gh = (h - 6).toFloat();
        while (gh >= 24.0f) {
            var gap = gh * 0.15f;
            var font = BeerRenderer.pickFont(_dc, _s.text, w - 6 - gh * a - gap, gh);
            if (font != null) {
                var cw = gh * a + gap + _dc.getTextDimensions(_s.text, font)[0];
                var th = _dc.getFontHeight(font) / 2;
                for (var k = 0; k < tries; k++) {
                    _gx = x + (w - cw) / 2 + dx * k;
                    _top = y + (h - gh) / 2 + dy * k;
                    if (_gx < x || _top < y || _gx + cw > x + w || _top + gh > y + h) {
                        break;
                    }
                    _tx = _gx + gh * a + gap;
                    _ty = _top + gh / 2;
                    if (_inside(_gx, _top, _tx, _top + gh) && _inside(_tx, _ty - th, _gx + cw, _ty + th)) {
                        _gh = gh;
                        _font = font;
                        return true;
                    }
                }
            }
            gh *= 0.9f;
        }
        return false;
    }

    private function _fitCount(x as Number, y as Number, w as Number, h as Number) as Void {
        var maxW = w - 4;
        var maxH = h - 2;
        _tx = x + w / 2.0f;
        _ty = y + h / 2.0f;
        _font = Graphics.FONT_XTINY;
        while (true) {
            var f = BeerRenderer.pickFont(_dc, _s.text, maxW, maxH);
            if (f == null) {
                return;
            }
            _font = f;
            var d = _dc.getTextDimensions(_s.text, f);
            if (_inside(_tx - d[0] / 2, _ty - d[1] / 2, _tx + d[0] / 2, _ty + d[1] / 2)) {
                return;
            }
            // Doesn't clear the bezel: retry with the next smaller font.
            maxW = d[0] - 1;
            maxH = d[1] - 1;
        }
    }

    // True when the box lies inside the bezel circle (always on rectangular screens).
    private function _inside(x0 as Numeric, y0 as Numeric, x1 as Numeric, y1 as Numeric) as Boolean {
        if (_r <= 0) {
            return true;
        }
        var dx = (x0 - _cx).abs();
        var d1 = (x1 - _cx).abs();
        if (d1 > dx) { dx = d1; }
        var dy = (y0 - _cy).abs();
        d1 = (y1 - _cy).abs();
        if (d1 > dy) { dy = d1; }
        return dx * dx + dy * dy <= _r * _r;
    }

    // ---- Vessels --------------------------------------------------------------------

    // Mug: rounded body plus a D-shaped handle; the count sits in the middle of the body.
    private function _mugShell(gx as Float) as Void {
        var bodyW = _gh * 0.64f;
        var radius = _gh * 0.10f;
        _prof = null;
        _mid = gx + bodyW / 2;

        // Handle: an elliptic ring whose left half ends up hidden behind the body.
        var thick = _gh * 0.08f;
        if (thick < _wall + 1) { thick = _wall + 1; }
        var hy = _top + _gh * 0.47f;
        _dc.setColor(_s.fg, Graphics.COLOR_TRANSPARENT);
        _dc.fillEllipse(gx + bodyW - _wall, hy, _gh * 0.28f - 1, _gh * 0.27f);
        _dc.setColor(_s.bg, Graphics.COLOR_TRANSPARENT);
        _dc.fillEllipse(gx + bodyW - _wall, hy, _gh * 0.28f - 1 - thick, _gh * 0.27f - thick);

        // Body: solid outline, then the hollow interior.
        _dc.setColor(_s.fg, Graphics.COLOR_TRANSPARENT);
        _dc.fillRoundedRectangle(gx, _top, bodyW, _gh, radius);
        _iL = gx + _wall;
        _iW = bodyW - 2 * _wall;
        _iT = _top + _wall;
        _iB = _top + _gh - _wall;
        _iR = radius - _wall;
        if (_iR < 1) { _iR = 1.0f; }
        _dc.setColor(_s.bg, Graphics.COLOR_TRANSPARENT);
        _dc.fillRoundedRectangle(_iL, _iT, _iW, _iB - _iT, _iR);

        _ty = _top + _gh * 0.56f;
        _tw = _iW - 6;
        _th = _gh * 0.62f;
    }

    // Weizen, pint and bottle: symmetric silhouettes described by a half-width profile.
    private function _glassShell(gx as Float) as Void {
        var textT = 0.45f;
        var capT = 0.0f;
        _prof = BeerRenderer.PROFILE_PINT;
        if (_s.shape == BeerSettings.SHAPE_WEIZEN) {
            _prof = BeerRenderer.PROFILE_WEIZEN;
            textT = 0.42f;
        } else if (_s.shape == BeerSettings.SHAPE_BOTTLE) {
            _prof = BeerRenderer.PROFILE_BOTTLE;
            textT = 0.74f;
            capT = BeerRenderer.BOTTLE_CAP;
        }
        _maxHalf = _gh * BeerRenderer.aspect(_s.shape) / 2;
        _mid = gx + _maxHalf;
        _iT = _top + capT * _gh + _wall;
        _iB = _top + _gh - _wall * 1.6f; // glass bases are thick

        _dc.setColor(_s.fg, Graphics.COLOR_TRANSPARENT);
        _dc.fillPolygon(_polygon(0.0f, _top, _top + _gh));
        _dc.setColor(_s.bg, Graphics.COLOR_TRANSPARENT);
        _dc.fillPolygon(_polygon(_wall, _iT, _iB));

        _ty = _top + _gh * textT;
        _tw = 2 * _halfAt(_ty) - 4;
        _th = _gh * 0.40f;
    }

    // Beer up to the fill level, a head of foam on top, bubbles and (mug) facets.
    private function _drawContents() as Void {
        var level = _iB - (_iB - _iT) * _s.frac;
        var beerH = _iB - level;
        if (beerH < 1) {
            return;
        }
        _dc.setColor(BeerRenderer.BEER_COLORS[_s.style], Graphics.COLOR_TRANSPARENT);
        _band(level, _iB);

        var foamH = _gh * 0.12f;
        var cap = beerH < 4 ? beerH : beerH * 0.45f;
        if (foamH > cap) { foamH = cap; }

        _dc.setColor(BeerRenderer.HIGHLIGHT_COLORS[_s.style], Graphics.COLOR_TRANSPARENT);
        if (_prof == null) {
            // Dimpled-glass facets on the mug.
            var y0 = level + foamH + _wall;
            var len = _iB - _wall - y0;
            if (len > 4) {
                var fw = _wall > 3 ? _wall - 1 : 2.0f;
                _dc.fillRectangle(_iL + _iW * 0.22f, y0, fw, len);
                _dc.fillRectangle(_iL + _iW * 0.78f - fw, y0, fw, len);
            }
        }
        _bubbles(level + foamH);

        // White head on dark backgrounds; cream for stouts and on light backgrounds.
        _dc.setColor((!BeerRenderer.isLight(_s.bg) && _s.style != BeerSettings.STYLE_STOUT) ? 0xFFFFFF : 0xFFFFAA,
            Graphics.COLOR_TRANSPARENT);
        _band(level, level + foamH);
        _crest(level, foamH);
    }

    // Fill the interior between heights y0 and y1 with the current colour.
    private function _band(y0 as Float, y1 as Float) as Void {
        if (_prof != null) {
            _dc.fillPolygon(_polygon(_wall, y0, y1));
        } else {
            // The mug's whole rounded interior, clipped to the band, so the corners
            // stay round however low or high the band sits.
            _dc.setClip(_iL, y0, _iW, y1 - y0 + 1);
            _dc.fillRoundedRectangle(_iL, _iT, _iW, _iB - _iT, _iR);
            _dc.clearClip();
        }
    }

    // Frothy crest of bumps above the head, in the current colour, clipped to the
    // interior width at and just above the beer line. A full vessel's head instead
    // swells over the rim, so it doesn't merge with the outline.
    private function _crest(level as Float, foamH as Float) as Void {
        var half = _halfAt(level);
        var rad = _halfAt(level - foamH);
        if (rad < half) { half = rad; }
        if (half < 4) {
            return;
        }
        var full = _s.frac >= 0.999f;
        if (full) {
            half += _wall;
        }
        var n = (2 * half / (_gh * 0.12f)).toNumber();
        if (n < 3) { n = 3; }
        var step = 2 * half / n;
        rad = step * 0.62f;
        if (rad > foamH * 1.2f + 1) { rad = foamH * 1.2f + 1; }
        var y = level + rad * 0.25f; // bump centres
        var top = level - rad;
        if (full) {
            y = _iT - _wall + rad * 0.3f;
            top = y - rad;
        } else if (top < _iT) {
            top = _iT;
        }
        _dc.setClip(_mid - half, top, 2 * half, level - top + 1);
        for (var i = 0; i < n; i++) {
            _dc.fillCircle(_mid - half + step * (i + 0.5f), y, rad);
        }
        _dc.clearClip();
    }

    // A few bubbles rising from the bottom to yTop in the current colour; they
    // advance with the scene's tick.
    private function _bubbles(yTop as Float) as Void {
        var rad = _gh / 45.0f;
        if (rad < 1.5f) { rad = 1.5f; }
        var span = _iB - yTop - 2 * rad;
        if (span < rad * 4) {
            return;
        }
        var lanes = [-0.55f, 0.15f, 0.6f, -0.15f, 0.35f] as Array<Float>;
        for (var i = 0; i < lanes.size(); i++) {
            var p = i * 0.37f + _s.tick * (0.11f + 0.03f * i);
            p = _iB - rad - (p - p.toNumber()) * span; // bubble centre y
            var hw = _halfAt(p) - rad - 1;
            if (hw > 0) {
                _dc.fillCircle(_mid + lanes[i] * hw, p, rad);
            }
        }
    }

    // The count inside the vessel, haloed in the background colour so it reads over
    // beer and foam alike.
    private function _countInside() as Void {
        var font = BeerRenderer.pickFont(_dc, _s.text, _tw, _th);
        if (font == null) {
            font = Graphics.FONT_XTINY;
        }
        var d = _dc.getFontHeight(font) > 50 ? 3 : 2;
        var j = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        _dc.setColor(_s.bg, Graphics.COLOR_TRANSPARENT);
        for (var ox = -d; ox <= d; ox += d) {
            for (var oy = -d; oy <= d; oy += d) {
                _dc.drawText(_mid + ox, _ty + oy, font, _s.text, j);
            }
        }
        _dc.setColor(_s.fg, Graphics.COLOR_TRANSPARENT);
        _dc.drawText(_mid, _ty, font, _s.text, j);
    }

    // ---- Geometry -------------------------------------------------------------------

    // Interior half-width at height y.
    private function _halfAt(y as Float) as Float {
        if (_prof == null) {
            return _iW / 2;
        }
        return _profile((y - _top) / _gh) * _maxHalf - _wall;
    }

    // The glass profile's half-width fraction at height fraction t (linear between knots).
    private function _profile(t as Float) as Float {
        var p = _prof as Array<Float>;
        var i = 2;
        if (t <= p[0]) {
            return p[1];
        }
        while (i < p.size()) {
            if (t <= p[i]) {
                return p[i - 1] + (p[i + 1] - p[i - 1]) * (t - p[i - 2]) / (p[i] - p[i - 2]);
            }
            i += 2;
        }
        return p[p.size() - 1];
    }

    // Polygon of the glass between heights y0 and y1, inset by `inset` px per side.
    private function _polygon(inset as Float, y0 as Float, y1 as Float) as Array<Point2D> {
        var p = _prof as Array<Float>;
        var ys = [y0] as Array<Float>;
        for (var i = 0; i < p.size(); i += 2) {
            var ky = _top + p[i] * _gh;
            if (ky > y0 && ky < y1) {
                ys.add(ky);
            }
        }
        ys.add(y1);
        var n = ys.size();
        var pts = new [2 * n] as Array<Point2D>;
        for (var i = 0; i < n; i++) {
            var hw = _profile((ys[i] - _top) / _gh) * _maxHalf - inset;
            if (hw < 0.5f) { hw = 0.5f; }
            pts[i] = [_mid - hw, ys[i]] as Point2D;
            pts[2 * n - 1 - i] = [_mid + hw, ys[i]] as Point2D;
        }
        return pts;
    }
}
