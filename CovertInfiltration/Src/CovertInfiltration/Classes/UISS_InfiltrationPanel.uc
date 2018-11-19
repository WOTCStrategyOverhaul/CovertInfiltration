//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and ArcaneData
//  PURPOSE: Displays covert action risks on the squad select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_InfiltrationPanel extends UIPanel;

//var UIMask InfiltrationMask;

var UISS_InfiltrationItem TotalDurationTitle;
var UISS_InfiltrationItem TotalDurationDisplay;

var UISS_InfiltrationItem BaseDurationTitle;
var UISS_InfiltrationItem BaseDurationDisplay;

var UISS_InfiltrationItem SquadDurationTitle;
var UISS_InfiltrationItem SquadDurationDisplay;

var UISS_InfiltrationItem RisksLabel;

simulated function InitRisks()
{
	InitPanel('UISS_InfiltrationPanel');
	AnchorTopRight();
	SetSize(375, 450);
	SetPosition(-375, 0);

	TotalDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(0, 123.5);
	BaseDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(20, 196);
	SquadDurationDisplay = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(20, 262);
	RisksLabel = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(12, 310);

	TotalDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(-29, 82);
	TotalDurationTitle.SetSubTitle("TOTAL DURATION:", "FAF0C8");

	BaseDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(20, 168);
	BaseDurationTitle.SetSubTitle("BASE DURATION:");

	SquadDurationTitle = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(20, 234);
	SquadDurationTitle.SetSubTitle("INFILTRATION MODIFIER:");

	//InfiltrationMask = Spawn(class'UIMask', self).InitMask('TacticalMask', self);
	//InfiltrationMask.SetPosition(6, 0);
	//InfiltrationMask.SetSize(375, 450);
		
	MCName = 'SquadSelect_InfiltrationInfo';
}

simulated function MoveUnderResourceBar(bool NewValue)
{
	SetY(NewValue ? 100 : 0);
}

simulated function UpdateData(XComGameState_CovertAction CurrentAction)
{	
	local string strPlusDaysAndHours;
	local int BaseDuration, SquadDuration;

	strPlusDaysAndHours = "+ <XGParam:IntValue0> Days, <XGParam:IntValue1> Hours";
	BaseDuration = 105;
	SquadDuration = 62;

	UpdateRisksLabel(CurrentAction);

	TotalDurationDisplay.SetInfoValue(GetDaysAndHoursString(BaseDuration + SquadDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	BaseDurationDisplay.SetInfoValue(GetDaysAndHoursString(BaseDuration), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	SquadDurationDisplay.SetInfoValue(GetDaysAndHoursString(SquadDuration, strPlusDaysAndHours), class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
}

simulated function UpdateRisksLabel(XComGameState_CovertAction CurrentAction)
{
	local array<string> Labels, Values; 
	local string strRisks;
	local int idx; 

	CurrentAction.GetRisksStrings(Labels, Values);

	for (idx = 0; idx < Labels.Length; idx++)
	{
		strRisks $= "<p>" $ class'UIUtilities_Text'.static.AddFontInfo(Values[idx] $ " - " $ Labels[idx], Screen.bIsIn3D) $ "</p>";
	}

	RisksLabel.SetText(strRisks);
}

static function string GetDaysAndHoursString(int iHours, optional string locString)
{
	local int ActualHours, ActualDays;
	local XGParamTag ParamTag;
	local string ReturnString;

	if(locString == "")
		locString = "<XGParam:IntValue0> Days, <XGParam:IntValue1> Hours";

	ActualDays = iHours / 24;
	ActualHours = iHours - 24 * ActualDays;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = ActualDays;
	ParamTag.IntValue1 = ActualHours;
	ReturnString = `XEXPAND.ExpandString(locString);

	return ReturnString;
}

defaultproperties
{
	bAnimateOnInit = false;
	bIsNavigable = false;
}