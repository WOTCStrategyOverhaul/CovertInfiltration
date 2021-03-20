//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Simple class to Override UIEventQueue_ListItem::UpdateData() in order to
//	show Event Queue items as hours instead of days
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIEventQueue_ListItem_CI extends UIEventQueue_ListItem;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

simulated function UIEventQueue_ListItem InitListItem()
{
	super.InitPanel(); // must do this before adding children or setting data
	return self; 
}

simulated function UpdateData(HQEvent Event)
{
	local string TimeValue, TimeLabel, Desc;
	
	local bool DaysToHours;
	local int DaysBeforeHours;

	Desc = Event.Data;

	DaysToHours = `GETMCMVAR(DAYS_TO_HOURS);
	DaysBeforeHours = `GETMCMVAR(DAYS_BEFORE_HOURS);

	if(!DaysToHours)
	{
		DaysBeforeHours = 0;
	}

	class'UIUtilities_Text'.static.GetTimeValueAndLabel(Event.Hours, TimeValue, TimeLabel, DaysBeforeHours);

	if (Event.Hours < 0)
	{
		Desc = class'UIUtilities_Text'.static.GetColoredText(Desc, eUIState_Warning);
		TimeLabel = " ";
		TimeValue = "--";
	}
	else if (Event.Hours < DaysBeforeHours * 24)
	{
		TimeLabel = class'UIUtilities_Text'.static.GetColoredText(TimeLabel, eUIState_Cash);
		TimeValue = class'UIUtilities_Text'.static.GetColoredText(TimeValue, eUIState_Cash);
	}

	SetTitle(Desc);
	SetDaysLabel(TimeLabel);
	SetDaysValue(TimeValue);
	SetIconImage(Event.ImagePath);
}