//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Small behaviour change to open our new covert ops screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIEventQueue_CovertActionListItem_CI extends UIEventQueue_CovertActionListItem;

`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var StateObjectReference ActionRef;

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.VERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

simulated function UpdateData(HQEvent Event)
{
	local string TimeValue, TimeLabel, Desc;
	
	local bool DaysToHours;
	local int DaysBeforeHours;

	Desc = Event.Data;
	ActionRef = Event.ActionRef;

	DaysToHours = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, class'UIListener_ModConfigMenu'.default.DAYS_TO_HOURS);
	DaysBeforeHours = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, class'UIListener_ModConfigMenu'.default.DAYS_BEFORE_HOURS);;

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

	UpdateSlotData(ActionRef);
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