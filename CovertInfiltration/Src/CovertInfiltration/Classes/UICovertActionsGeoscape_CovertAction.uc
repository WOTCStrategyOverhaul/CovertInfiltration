//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a single entry for a CA in the UICovertActionsGeoscape screen's list
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_CovertAction extends UIListItemString;

var protectedwrite XComGameState_CovertAction Action;

simulated function InitCovertAction(XComGameState_CovertAction InAction)
{
	Action = InAction;
	InitListItem(GetActionLocString());

	NeedsAttention(
		class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(InAction) != none ||
		class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(InAction) != none
	);
}

simulated function String GetActionLocString()
{
	local string PrefixStr, MainStr;

	if (Action.bNewAction)
	{
		PrefixStr = class'UICovertActions'.default.CovertActions_NewAction;
	}

	MainStr = class'UIUtilities_Infiltration'.static.GetActionObjective(Action);

	return PrefixStr $ MainStr;
}

defaultproperties
{
	bAnimateOnInit = false; // Animated by the whole list
}