import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class BeersEarnedApp extends Application.AppBase {

    private var _view as BeersEarnedView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new BeersEarnedView();
        return [ _view ];
    }

    // On-device settings, reachable from the activity's data screen settings.
    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        var menu = new BeerSettingsMenu();
        return [menu, new BeerSettingsDelegate(menu)] as [Views, InputDelegates];
    }

    // Settings changed in Garmin Connect / Express, or in the on-device menu.
    function onSettingsChanged() as Void {
        if (_view != null) {
            _view.reloadSettings();
        }
    }

}

function getApp() as BeersEarnedApp {
    return Application.getApp() as BeersEarnedApp;
}
