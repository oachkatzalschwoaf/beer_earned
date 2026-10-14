import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Full-screen "Cheers!" pop-up the data field pushes over any data screen when a
//! whole beer is earned: a full vessel with the new count inside.
class BeerAlertView extends WatchUi.DataFieldAlert {

    private var _scene as BeerScene;

    function initialize(scene as BeerScene) {
        DataFieldAlert.initialize();
        _scene = scene;
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(_scene.bg, _scene.bg);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var just = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(_scene.fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.19f, Graphics.FONT_MEDIUM, WatchUi.loadResource(Rez.Strings.AlertTitle) as String, just);

        var gh = h * 0.50f;
        var gw = gh * BeerRenderer.aspect(_scene.shape);
        new BeerPainter(dc, _scene).drawVessel((w - gw) / 2, h * 0.30f, gh, true);

        dc.setColor(_scene.fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.88f, Graphics.FONT_TINY, WatchUi.loadResource(Rez.Strings.BeersLabel) as String, just);
    }
}
