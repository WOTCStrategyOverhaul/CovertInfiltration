//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData, NotSoLonewWolf and Xymanek
//  PURPOSE: Displays covert action info on the squad select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_InfiltrationReadout extends UIPanel;

var UIList DurationBreadownItems;

var UISS_InfiltrationItem TotalDurationLabel, TotalDurationValue;
var UISS_InfiltrationItem BaseDurationLabel, BaseDurationValue;
var UISS_InfiltrationItem SquadDurationLabel, SquadDurationValue;
var UISS_InfiltrationItem OverloadPenaltyLabel, OverloadPenaltyValue;

var UISS_InfiltrationItem RisksLabel;
var UIList RiskEntries;

var localized string strTotalDurationTitle;
var localized string strBaseDurationTitle;
var localized string strSquadDurationTitle;
var localized string strOverloadPenaltyTitle;
var localized string strRisksTitle;

var localized string strDaysAndHours;
var localized string strPlusDaysAndHours;

simulated function InitReadout(XComGameState_CovertAction Action)
{
	InitPanel('UISS_InfiltrationPanel');
	AnchorTopRight();
	SetPosition(-375, 0);

	// Total duration

	TotalDurationLabel = Spawn(class'UISS_InfiltrationItem', self);
	TotalDurationLabel.InitObjectiveListItem('TotalDurationLabel', -29, 73);
	TotalDurationLabel.SetSubTitle(strTotalDurationTitle, "FAF0C8");

	TotalDurationValue = Spawn(class'UISS_InfiltrationItem', self);
	TotalDurationValue.InitObjectiveListItem('TotalDurationValue', 0, 107.5);

	// Duration details

	DurationBreadownItems = Spawn(class'UIList', self);
	DurationBreadownItems.InitList('DurationBreadownItems');
	DurationBreadownItems.SetPosition(20, 153);

	if (Action.HoursToComplete > 0)
	{
		BaseDurationLabel = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		BaseDurationLabel.InitObjectiveListItem('BaseDurationLabel');
		BaseDurationLabel.SetSubTitle(strBaseDurationTitle);

		BaseDurationValue = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		BaseDurationValue.InitObjectiveListItem('BaseDurationValue');
	}

	SquadDurationLabel = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
	SquadDurationLabel.InitObjectiveListItem('SquadDurationLabel');
	SquadDurationLabel.SetSubTitle(strSquadDurationTitle);

	SquadDurationValue = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
	SquadDurationValue.InitObjectiveListItem('SquadDurationValue');

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		OverloadPenaltyLabel = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		OverloadPenaltyLabel.InitObjectiveListItem('OverloadPenaltyLabel');
		OverloadPenaltyLabel.SetSubTitle(strOverloadPenaltyTitle);

		OverloadPenaltyValue = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		OverloadPenaltyValue.InitObjectiveListItem('OverloadPenaltyValue');
	}

	// For reasons unknown this doesn't happen automatically
	DurationBreadownItems.RealizeItems();
	DurationBreadownItems.RealizeList();

	// Risks
	RisksLabel = Spawn(class'UISS_InfiltrationItem', self);
	RisksLabel.InitObjectiveListItem('RisksLabel', -29, DurationBreadownItems.Y + DurationBreadownItems.TotalItemSize);
	RisksLabel.SetSubTitle(class'UICovertActions'.default.CovertActions_RiskTitle, "FAF0C8");

	RiskEntries = Spawn(class'UIList', self);
	RiskEntries.InitList('RiskEntries');
	RiskEntries.SetPosition(0, RisksLabel.Y + 32);
}

simulated function UpdateData(XComGameState_CovertAction CurrentAction)
{	
	local XComGameState_HeadquartersXCom XComHQ;
	local int BaseDuration, SquadDuration, OverloadPenalty;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	BaseDuration = CurrentAction.HoursToComplete;
	SquadDuration = class'X2Helper_Infiltration'.static.GetSquadInfilWithoutPenalty(XComHQ.Squad);

	TotalDurationValue.SetInfoValue(GetDaysAndHoursString(BaseDuration + SquadDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	SquadDurationValue.SetInfoValue(GetDaysAndHoursString(SquadDuration, strPlusDaysAndHours), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);

	if (BaseDurationValue != none)
	{
		BaseDurationValue.SetInfoValue(GetDaysAndHoursString(BaseDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	}
	
	if (OverloadPenaltyValue != none)
	{
		OverloadPenalty = class'X2Helper_Infiltration'.static.GetSquadOverloadPenalty(XComHQ.Squad, CurrentAction, SquadDuration);

		OverloadPenaltyValue.SetInfoValue(GetDaysAndHoursString(OverloadPenalty, default.strPlusDaysAndHours), class'UIUtilities_Colors'.const.BAD_HTML_COLOR);
	}
	
	UpdateRiskLabels(CurrentAction);
}

simulated function UpdateRiskLabels(XComGameState_CovertAction CurrentAction)
{
	local UISS_InfiltrationItem Item;
	local array<string> RiskStrings;
	local int idx;

	RiskStrings = class'UIUtilities_Infiltration'.static.GetRisksStringsFor(CurrentAction);
	RisksLabel.SetVisible(RiskStrings.Length > 0);

	for (idx = 0; idx < RiskStrings.Length; idx++)
	{
		Item = GetRiskLabel(idx);
		Item.SetText(RiskStrings[idx]);
		Item.Show();
	}

	for (idx = idx /* Keep going but help the compiler understand what we want to do */; idx < RiskEntries.GetItemCount(); idx++)
	{
		GetRiskLabel(idx).Hide();
	}
}

static function string GetDaysAndHoursString(int iHours, optional string locString)
{
	local int ActualHours, ActualDays;
	local XGParamTag ParamTag;
	local string ReturnString;

	if(locString == "")
		locString = default.strDaysAndHours;

	ActualDays = iHours / 24;
	ActualHours = iHours % 24;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = ActualDays;
	ParamTag.IntValue1 = ActualHours;
	ReturnString = `XEXPAND.ExpandString(locString);

	return ReturnString;
}

simulated function UISS_InfiltrationItem GetRiskLabel(int Index)
{
	local UISS_InfiltrationItem NewEntry;

	if (Index < RiskEntries.GetItemCount())
	{
		return UISS_InfiltrationItem(RiskEntries.GetItem(Index));
	}

	NewEntry = Spawn(class'UISS_InfiltrationItem', RiskEntries.ItemContainer);
	NewEntry.InitObjectiveListItem();

	// For reasons unknown this doesn't happen automatically
	RiskEntries.RealizeItems(RiskEntries.ItemCount - 1);
	RiskEntries.RealizeList();

	return NewEntry;
}

simulated function AnimateIn(optional float Delay = 0.0)
{
	local int PanelsAnimated;
	local UIPanel Panel;

	TotalDurationLabel.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);
	TotalDurationValue.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);

	foreach DurationBreadownItems.ItemContainer.ChildPanels(Panel)
	{
		Panel.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);
	}

	if (RisksLabel != none)
	{
		RisksLabel.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);
	}

	if (RiskEntries != none)
	{
		foreach RiskEntries.ItemContainer.ChildPanels(Panel)
		{
			Panel.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);
		}
	}
}

defaultproperties
{
	bAnimateOnInit = false;
	bIsNavigable = false;
}