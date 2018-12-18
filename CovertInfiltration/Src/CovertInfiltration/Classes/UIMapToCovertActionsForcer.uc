//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Screen listener for UIStrategyMap to force open new covert ops screen
//           when the map opens
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIMapToCovertActionsForcer extends UIScreenListener;

var protected bool ForceCovertActions;
var protected StateObjectReference ActionRef;

static function ForceCAOnNextMapInit(StateObjectReference InActionRef)
{
	local UIMapToCovertActionsForcer CDO;

	CDO = UIMapToCovertActionsForcer(class'XComEngine'.static.GetClassDefaultObject(class'UIMapToCovertActionsForcer'));

	CDO.ForceCovertActions = true;
	CDO.ActionRef = InActionRef;
}

event OnInit(UIScreen Screen)
{
	if (!ForceCovertActions) return;
	if (!Screen.IsA(class'UIStrategyMap'.name)) return;

	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(ActionRef);

	ForceCovertActions = false;
	ActionRef.ObjectID = 0;
}