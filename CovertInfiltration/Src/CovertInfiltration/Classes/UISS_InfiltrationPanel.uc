//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and ArcaneData
//  PURPOSE: Displays covert action risks on the squad select screen
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

simulated function InitRisks(optional int InitWidth = 375, optional int InitHeight = 450, optional int InitX = -375, optional int InitY = 0)
{
	InitPanel('UISS_InfiltrationPanel');
	AnchorTopRight();
	SetSize(InitWidth, InitHeight);
	SetPosition(InitX, InitY);

	TotalDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 0, 107.5);
	BaseDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 23, 181);
	SquadDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 23, 247);

	TotalDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, -29, 73);
	TotalDurationTitle.SetSubTitle("TOTAL DURATION:", "FAF0C8");

	BaseDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 20, 153);
	BaseDurationTitle.SetSubTitle("BASE DURATION:");

	SquadDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 20, 219);
	SquadDurationTitle.SetSubTitle("INFILTRATION MODIFIER:");

	RisksTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 20, 285);
	RisksTitle.SetSubTitle("RISKS:", "FAF0C8");

	RiskLabelsOffsetY = 32;
	RiskLabels.AddItem(Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(, 23, 316));
}

simulated function UpdateData(XComGameState_CovertAction CurrentAction)
{	
	local string strPlusDaysAndHours;
	local int BaseDuration, SquadDuration;

	strPlusDaysAndHours = "+<XGParam:IntValue0> Days, <XGParam:IntValue1> Hours";
	BaseDuration = 105;
	SquadDuration = 62;

	UpdateRiskLabels(CurrentAction);

	TotalDurationDisplay.SetInfoValue(GetDaysAndHoursString(BaseDuration + SquadDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	BaseDurationDisplay.SetInfoValue(GetDaysAndHoursString(BaseDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	SquadDurationDisplay.SetInfoValue(GetDaysAndHoursString(SquadDuration, strPlusDaysAndHours), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
}

simulated function UpdateRiskLabels(XComGameState_CovertAction CurrentAction)
{
	local array<string> RiskStrings;
	local int idx;

	RiskStrings = class'UIUtilities_Infiltration'.static.GetRisksStringsFor(CurrentAction);

	for (idx = 0; idx < RiskStrings.Length; idx++)
	{
		GetRiskLabel(idx).SetText(RiskStrings[idx]);
	}
}

static function string GetDaysAndHoursString(int iHours, optional string locString)
{
	local int ActualHours, ActualDays;
	local XGParamTag ParamTag;
	local string ReturnString;

	if(locString == "")
		locString = "<XGParam:IntValue0> Days, <XGParam:IntValue1> Hours";

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