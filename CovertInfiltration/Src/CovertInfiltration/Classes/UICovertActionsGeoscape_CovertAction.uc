class UICovertActionsGeoscape_CovertAction extends UIListItemString;

var protectedwrite XComGameState_CovertAction Action;

simulated function InitCovertAction(XComGameState_CovertAction InAction)
{
	Action = InAction;
	InitListItem(GetActionLocString());
}

// Copied from UICovertActions
simulated function String GetActionLocString()
{
	local string PrefixStr;

	if(Action.bNewAction)
	{
		PrefixStr = class'UICovertActions'.default.CovertActions_NewAction;
	}

	return PrefixStr $ Action.GetObjective();
}

defaultproperties
{
	bAnimateOnInit = false; // Animated by the whole list
}