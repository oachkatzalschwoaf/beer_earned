import Toybox.Lang;
import Toybox.Math;

//! Pure conversions from the raw (unrounded) beer count to what the field shows.
module BeerMath {

    //! The count as displayed, and stored as the session total, for a rounding mode.
    function displayValue(raw as Float, rounding as Number) as Float {
        if (rounding == BeerSettings.ROUND_NEAREST) {
            return Math.round(raw).toFloat();
        } else if (rounding == BeerSettings.ROUND_UP) {
            return Math.ceil(raw).toFloat();
        } else if (rounding == BeerSettings.ROUND_EXACT) {
            // Truncate rather than round, so "3.0" never shows before beer 3 is earned.
            return Math.floor(raw * 10.0f + 0.0001f).toFloat() / 10.0f;
        }
        return Math.floor(raw).toFloat();
    }

    function countText(raw as Float, rounding as Number) as String {
        var v = displayValue(raw, rounding);
        return rounding == BeerSettings.ROUND_EXACT ? v.format("%.1f") : v.toNumber().format("%d");
    }

    //! Progress toward the next whole beer, 0..1: how full the vessel is drawn.
    function fillFraction(raw as Float) as Float {
        var f = raw - Math.floor(raw).toFloat();
        return f < 0.0f ? 0.0f : (f > 1.0f ? 1.0f : f);
    }
}
