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
		PrefixStr = "(NEW) ";
	}

	return PrefixStr $ Action.GetObjective();
}

simulated function AnimateIn(optional float Delay = 0)
{
	AddTweenBetween("_alpha", 0, Alpha, class'UICovertActionsGeoscape'.const.ANIMATE_IN_DURATION, Delay);
}
