//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Displays covert action info on the squad select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_InfiltrationPanel extends UIPanel;

var UISS_InfiltrationItem TotalDurationTitle;
var UISS_InfiltrationItem TotalDurationDisplay;

var UISS_InfiltrationItem BaseDurationTitle;
var UISS_InfiltrationItem BaseDurationDisplay;

var UISS_InfiltrationItem SquadDurationTitle;
var UISS_InfiltrationItem SquadDurationDisplay;

var UISS_InfiltrationItem RisksTitle;
var array<UISS_InfiltrationItem> RiskLabels;

var int RiskLabelsOffsetY;

var localized string strTotalDurationTitle;
var localized string strBaseDurationTitle;
var localized string strSquadDurationTitle;
var localized string strOverloadPenaltyTitle;
var localized string strRisksTitle;

var localized string strDaysAndHours;
var localized string strPlusDaysAndHours;

simulated function InitRisks(XComGameState_CovertAction Action, optional int InitWidth = 375, optional int InitHeight = 450, optional int InitX = -375, optional int InitY = 0)
{
	local bool Infil;
	local string str2, str3;

	InitPanel('UISS_InfiltrationPanel');
	AnchorTopRight();
	SetSize(InitWidth, InitHeight);
	SetPosition(InitX, InitY);

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		str2 = default.strSquadDurationTitle;
		str3 = default.strOverloadPenaltyTitle;
	}
	else
	{
		str2 = default.strBaseDurationTitle;
		str3 = default.strSquadDurationTitle;
	}

	TotalDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 0, 107.5);
	BaseDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 23, 181);
	SquadDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 23, 247);

	TotalDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, -29, 73);
	TotalDurationTitle.SetSubTitle(default.strTotalDurationTitle, "FAF0C8");

	BaseDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 20, 153);
	BaseDurationTitle.SetSubTitle(str2);

	SquadDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 20, 219);
	SquadDurationTitle.SetSubTitle(str3);

	RisksTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 20, 285);
	RisksTitle.SetSubTitle(class'UICovertActions'.default.CovertActions_RiskTitle, "FAF0C8");

	RiskLabelsOffsetY = 32;
	RiskLabels.AddItem(Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 23, 316));
}

simulated function UpdateData(XComGameState_CovertAction CurrentAction)
{	
	local XComGameState_HeadquartersXCom XComHQ;
	local int BaseDuration, SquadDuration, OverloadPenalty;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	BaseDuration = CurrentAction.HoursToComplete;

	SquadDuration = class'X2Helper_Infiltration'.static.GetSquadInfiltration(XComHQ.Squad, CurrentAction);

	TotalDurationDisplay.SetInfoValue(GetDaysAndHoursString(BaseDuration + SquadDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	BaseDurationDisplay.SetInfoValue(GetDaysAndHoursString(BaseDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	SquadDurationDisplay.SetInfoValue(GetDaysAndHoursString(SquadDuration, default.strPlusDaysAndHours), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CurrentAction))
	{
		RisksTitle.hide();
		
		SquadDuration = class'X2Helper_Infiltration'.static.GetSquadInfilExclusive(XComHQ.Squad, CurrentAction);
		OverloadPenalty = class'X2Helper_Infiltration'.static.GetSquadOverloadPenalty(XComHQ.Squad, CurrentAction);

		TotalDurationDisplay.SetInfoValue(GetDaysAndHoursString(OverloadPenalty + SquadDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		BaseDurationDisplay.SetInfoValue(GetDaysAndHoursString(SquadDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		SquadDurationDisplay.SetInfoValue(GetDaysAndHoursString(OverloadPenalty, default.strPlusDaysAndHours), class'UIUtilities_Colors'.const.BAD_HTML_COLOR);
	}
	
	UpdateRiskLabels(CurrentAction);
}

simulated function UpdateRiskLabels(XComGameState_CovertAction CurrentAction)
{
	local UISS_InfiltrationItem Item;
	local array<string> RiskStrings;
	local int idx;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CurrentAction))
	{
		RiskStrings.Length = 0;
	}
	else
	{
		RiskStrings = class'UIUtilities_Infiltration'.static.GetRisksStringsFor(CurrentAction);
	}

	for (idx = 0; idx < RiskStrings.Length; idx++)
	{
		Item = GetRiskLabel(idx);
		Item.SetText(RiskStrings[idx]);
		Item.Show();
	}

	for (idx = idx /* Keep going but help the compiler understand what we want to do */; idx < RiskLabels.Length; idx++)
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

simulated function UISS_InfiltrationItem GetRiskLabel(int index)
{
	local UISS_InfiltrationItem newLabel;

	if (index < RiskLabels.Length)
		return RiskLabels[index];

	newLabel = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, RiskLabels[RiskLabels.Length - 1].X, RiskLabels[RiskLabels.Length - 1].Y + RiskLabelsOffsetY);

	RiskLabels.AddItem(newLabel);

	return newLabel;
}

defaultproperties
{
	bAnimateOnInit = false;
	bIsNavigable = false;
}