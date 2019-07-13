module Style.Shadow exposing (dp1, dp12, dp16, dp2, dp24, dp3, dp4, dp6, dp8, dp9)

import Css exposing (..)



-- /* Shadow 1dp */


dp1 : Style
dp1 =
    property "box-shadow" "0 1px 1px 0 rgba(0, 0, 0, 0.14), 0 2px 1px -1px rgba(0, 0, 0, 0.12), 0 1px 3px 0 rgba(0 0 0 0.2)"



-- /* Shadow 2dp */


dp2 : Style
dp2 =
    property "box-shadow" "0px 2px 2px 0px rgba(0, 0, 0, 0.14), 0px 3px 1px -2px rgba(0, 0, 0, 0.12), 0px 1px 5px 0px rgba(0, 0, 0, 0.2)"



-- /* Shadow 3dp */


dp3 : Style
dp3 =
    property "box-shadow" "0px 3px 4px 0px rgba(0, 0, 0, 0.14), 0px 3px 3px -2px rgba(0, 0, 0, 0.12), 0px 1px 8px 0px rgba(0, 0, 0, 0.2)"



-- /* Shadow 4dp */


dp4 : Style
dp4 =
    property "box-shadow" "0px 4px 5px 0px rgba(0, 0, 0, 0.14), 0px 1px 10px 0px rgba(0, 0, 0, 0.12), 0px 2px 4px -1px rgba(0, 0, 0, 0.2)"



-- /* Shadow 6dp */


dp6 : Style
dp6 =
    property "box-shadow" "0px 6px 10px 0px rgba(0, 0, 0, 0.14), 0px 1px 18px 0px rgba(0, 0, 0, 0.12), 0px 3px 5px -1px rgba(0, 0, 0, 0.2)"



-- /* Shadow 8dp */


dp8 : Style
dp8 =
    property "box-shadow" "0px 8px 10px 1px rgba(0, 0, 0, 0.14), 0px 3px 14px 2px rgba(0, 0, 0, 0.12), 0px 5px 5px -3px rgba(0, 0, 0, 0.2)"



-- /* Shadow 9dp */


dp9 : Style
dp9 =
    property "box-shadow" "0px 9px 12px 1px rgba(0, 0, 0, 0.14), 0px 3px 16px 2px rgba(0, 0, 0, 0.12), 0px 5px 6px -3px rgba(0, 0, 0, 0.2)"



-- /* Shadow 12dp */


dp12 : Style
dp12 =
    property "box-shadow" "0px 1px 17px 2px rgba(0, 0, 0, 0.14), 0px 5px 22px 4px rgba(0, 0, 0, 0.12), 0px 7px 8px -4px rgba(0, 0, 0, 0.2)"



-- /* Shadow 16dp */


dp16 : Style
dp16 =
    property "box-shadow" "0px 1px 24px 2px rgba(0, 0, 0, 0.14), 0px 6px 30px 5px rgba(0, 0, 0, 0.12), 0px 8px 10px -5px rgba(0, 0, 0, 0.2)"



-- /* Shadow 24dp */


dp24 : Style
dp24 =
    property "box-shadow" "0px 2px 38px 3px rgba(0, 0, 0, 0.14), 0px 9px 46px 8px rgba(0, 0, 0, 0.12), 0px 1px1 15px -7px rgba(0, 0, 0, 0.2)"
