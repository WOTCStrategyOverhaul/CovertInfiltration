//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Small behaviour change to open our new covert ops screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIEventQueue_CovertActionListItem_CI extends UIEventQueue_CovertActionListItem;

var StateObjectReference ActionRef;

simulated function UpdateData(HQEvent Event)
{
	super.UpdateData(Event);
	ActionRef = Event.ActionRef;
}

simulated function OpenCovertActionScreen()
{
	if (Movie.Stack.HasInstanceOf(class'UIStrategyMap'))
	{
		if (Movie.Stack.IsCurrentScreen(class'UIStrategyMap'.Name))
		{
			class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(ActionRef);
		}
	}
	else
	{
		class'UIMapToCovertActionsForcer'.static.ForceCAOnNextMapInit(ActionRef);
		XComHQPresentationLayer(Movie.Pres).m_kAvengerHUD.NavHelp.HotlinkToGeoscape();
	}
}