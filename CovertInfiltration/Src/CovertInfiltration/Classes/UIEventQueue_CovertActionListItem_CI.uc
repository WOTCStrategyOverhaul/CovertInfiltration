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
	local string ActionLabel, TimeValue, TimeLabel, Desc;
	
	//TODO: mcm/config these?
	local int DaysBeforeHours;
	local bool ShowHours;

	Desc = Event.Data;
	ActionRef = Event.ActionRef;

	DaysBeforeHours = 0;
	ShowHours = True;

	if(ShowHours)
	{
		DaysBeforeHours = 2;
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
	AS_SetLabel(ActionLabel);
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