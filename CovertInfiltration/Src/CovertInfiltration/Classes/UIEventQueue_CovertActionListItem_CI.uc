//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and statusNone
//  PURPOSE: (1) Open our new covert ops screen on click
//           (2) Integrate mod that shows hours when the event is close
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIEventQueue_CovertActionListItem_CI extends UIEventQueue_CovertActionListItem;

`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var StateObjectReference ActionRef;

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

simulated function UpdateData(HQEvent Event)
{
	local string TimeValue, TimeLabel, Desc;
	
	local bool DaysToHours;
	local int DaysBeforeHours;

	Desc = Event.Data;
	ActionRef = Event.ActionRef;

	DaysToHours = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, class'UIListener_ModConfigMenu'.default.DAYS_TO_HOURS);
	DaysBeforeHours = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, class'UIListener_ModConfigMenu'.default.DAYS_BEFORE_HOURS);

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
		// Do not open the CA screen if the first faction reveal wasn't seen
		// The screen will open before the faction reveal triggers and therefore their CAs will not be visible in the list
		if (HasSeenStartingFactionReveal())
		{
			class'UIMapToCovertActionsForcer'.static.ForceCAOnNextMapTick(ActionRef);
		}

		XComHQPresentationLayer(Movie.Pres).m_kAvengerHUD.NavHelp.HotlinkToGeoscape();
	}
}

protected static function bool HasSeenStartingFactionReveal ()
{
	local array<XComGameState_ResistanceFaction> AllFactions;
	local XComGameState_ResistanceFaction FactionState;

	AllFactions = class'UIUtilities_Strategy'.static.GetResistanceHQ().GetAllFactions();

	foreach AllFactions(FactionState)
	{
		if (FactionState.bFirstFaction) 
		{
			return FactionState.bSeenFactionHQReveal;
		}
	}

	`RedScreen("CI: Failed to find starting faction - this should not be possible. Assuming the reveal was seen already");
	return true;
}