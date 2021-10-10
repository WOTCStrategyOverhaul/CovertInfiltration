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
var UISS_InfiltrationItem OverloadPenaltyLabel, OverloadPenaltyValue, MaxInfilValue;
var UISS_InfiltrationItem BondModifierLabel, BondModifierValue;

var UISS_InfiltrationItem RisksLabel;
var UIList RiskEntries;

var protected bool bForceFlushAfterUpdate; // After we update all the panels, instantly flush the movie command queue

var localized string strTotalDurationTitle;
var localized string strBaseDurationTitle;
var localized string strSquadDurationTitle;
var localized string strOverloadPenaltyTitle;
var localized string strBondModifierTitle;
var localized string strRisksTitle;

var localized string strDaysAndHours;
var localized string strPlusDaysAndHours;
var localized string strMinusDaysAndHours;
var localized string strMaxAllowedInfil;

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

	BondModifierLabel = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
	BondModifierLabel.InitObjectiveListItem('BondModifierLabel');
	BondModifierLabel.SetSubTitle(strBondModifierTitle);

	BondModifierValue = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
	BondModifierValue.InitObjectiveListItem('BondModifierValue');

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		OverloadPenaltyLabel = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		OverloadPenaltyLabel.InitObjectiveListItem('OverloadPenaltyLabel');
		OverloadPenaltyLabel.SetSubTitle(strOverloadPenaltyTitle);

		OverloadPenaltyValue = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		OverloadPenaltyValue.InitObjectiveListItem('OverloadPenaltyValue');

		MaxInfilValue = Spawn(class'UISS_InfiltrationItem', DurationBreadownItems.ItemContainer);
		MaxInfilValue.InitObjectiveListItem('MaxInfilValue');
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
	local int BaseDuration, SquadDuration, TotalDuration, OverloadPenalty, ExtraSoldiers, MaxInfil;
	local float BondingReduction;
	local XComGameState_HeadquartersXCom XComHQ;
	local string OverloadColour;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	bForceFlushAfterUpdate = false;

	BaseDuration = CurrentAction.HoursToComplete;
	SquadDuration = class'X2Helper_Infiltration'.static.GetSquadInfilWithoutPenalty(XComHQ.Squad);
	TotalDuration = CurrentAction.HoursToComplete + class'X2Helper_Infiltration'.static.GetSquadInfiltration(XComHQ.Squad, CurrentAction);

	if (!class'X2Helper_Infiltration'.static.IsInfiltrationAction(CurrentAction) && CurrentAction.bBondmateDurationBonusApplied)
	{
		// Vanilla bondmates logic subracts time from CurrentAction.HoursToComplete,
		// so fix the displayed value to stay consistent
		BaseDuration += CurrentAction.BondmateBonusHours;
	}

	TotalDurationValue.SetInfoValue(GetDaysAndHoursString(TotalDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	SquadDurationValue.SetInfoValue(GetDaysAndHoursString(SquadDuration, strPlusDaysAndHours), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);

	if (BaseDurationValue != none)
	{
		BaseDurationValue.SetInfoValue(GetDaysAndHoursString(BaseDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	}
	
	if (OverloadPenaltyValue != none)
	{
		OverloadPenalty = class'X2Helper_Infiltration'.static.GetSquadOverloadPenalty(XComHQ.Squad, CurrentAction, SquadDuration);
		ExtraSoldiers = class'X2Helper_Infiltration'.static.CountUnupgradedSlots(XComHQ.Squad, CurrentAction);
		MaxInfil = class'X2Helper_Infiltration'.static.GetMaxAllowedInfil(XComHQ.Squad, CurrentAction);

		OverloadColour = ExtraSoldiers > 0 ? class'UIUtilities_Colors'.const.BAD_HTML_COLOR : class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR;

		OverloadPenaltyValue.SetInfoValue(GetDaysAndHoursString(OverloadPenalty, default.strPlusDaysAndHours), OverloadColour);
		MaxInfilValue.SetInfoValue(GetMaxAllowedInfilString(MaxInfil), OverloadColour);
	}

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CurrentAction))
	{
		BondingReduction = class'X2Helper_Infiltration'.static.GetSquadBondingPercentReduction(XComHQ.Squad);
		BondModifierValue.SetInfoValue(
			GetDaysAndHoursString(SquadDuration * BondingReduction, default.strMinusDaysAndHours) @ "(" $ int(BondingReduction * 100) $ "%)",
			BondingReduction > 0 ? class'UIUtilities_Colors'.const.GOOD_HTML_COLOR : class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR
		);
	}
	else
	{
		// Vanilla bondmates logic
		if (CurrentAction.bBondmateDurationBonusApplied)
		{
			BondModifierValue.SetInfoValue(GetDaysAndHoursString(CurrentAction.BondmateBonusHours, default.strMinusDaysAndHours), class'UIUtilities_Colors'.const.GOOD_HTML_COLOR);
		}
		else
		{
			BondModifierValue.SetInfoValue(GetDaysAndHoursString(0), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		}
	}
		
	UpdateRiskLabels(CurrentAction);

	if (bForceFlushAfterUpdate)
	{
		Movie.ProcessQueuedCommands();
	}
}

simulated function UpdateRiskLabels(XComGameState_CovertAction CurrentAction)
{
	local array<ActionRiskDisplayInfo> RisksForDisplay;
	local bool bRealizePending;
	local UISS_Risk Item;
	local int idx;

	RisksForDisplay = class'UIUtilities_Infiltration'.static.GetRisksForDisplay(CurrentAction);
	RisksLabel.SetVisible(RisksForDisplay.Length > 0);

	for (idx = 0; idx < RisksForDisplay.Length; idx++)
	{
		Item = GetRiskLabel(idx);
		Item.UpdateFromInfo(RisksForDisplay[idx]);
		Item.Show();

		if (Item.bHeightRealizePending)
		{
			bRealizePending = true;
		}
	}

	for (idx = idx /* Keep going but help the compiler understand what we want to do */; idx < RiskEntries.GetItemCount(); idx++)
	{
		GetRiskLabel(idx).Hide();
	}

	if (bRealizePending) bForceFlushAfterUpdate = true;
	else RealizeRiskEntries();
}

simulated protected function OnRiskRealized (UISS_Risk RealizedRisk)
{
	local UISS_Risk Item;
	local int idx;

	for (idx = 0; idx < RiskEntries.GetItemCount(); idx++)
	{
		Item = GetRiskLabel(idx);
		
		// Don't care about the hidden ones
		if (!Item.bIsVisible) continue;

		// If any is still pending, bail
		if (Item.bHeightRealizePending) return;
	}

	// All are realized, finalize the list
	RealizeRiskEntries();
}

simulated protected function RealizeRiskEntries ()
{
	RiskEntries.RealizeItems();
	RiskEntries.RealizeList();
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

static function string GetMaxAllowedInfilString (int Value)
{
	local XGParamTag ParamTag;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = Value;

	return `XEXPAND.ExpandString(default.strMaxAllowedInfil);
}

simulated function UISS_Risk GetRiskLabel(int Index)
{
	local UISS_Risk NewEntry;

	if (Index < RiskEntries.GetItemCount())
	{
		return UISS_Risk(RiskEntries.GetItem(Index));
	}

	NewEntry = Spawn(class'UISS_Risk', RiskEntries.ItemContainer);
	NewEntry.OnHeightRealized = OnRiskRealized;
	NewEntry.InitRisk();

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