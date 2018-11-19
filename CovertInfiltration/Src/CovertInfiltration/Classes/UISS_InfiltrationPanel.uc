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
	RisksLabel = Spawn(class'UISS_InfiltrationItem', self).InitObjectiveListItem(26, 320);

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
	/*
	local array<string> Labels, Values; 
	local string strRisks;
	local int idx; 

	CurrentAction.GetRisksStrings(Labels, Values);

	for (idx = 0; idx < Labels.Length; idx++)
	{
		strRisks $= "<p>" $ class'UIUtilities_Text'.static.AddFontInfo(Values[idx] $ " - " $ Labels[idx], Screen.bIsIn3D) $ "</p>";
	}

	Text.SetHtmlText(strRisks);
	*/

	UpdateRisksLabel(CurrentAction);

	TotalDurationDisplay.SetInfoValue("6 Days, 18 Hours", class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	BaseDurationDisplay.SetInfoValue("3 Days, 7 Hours", class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	SquadDurationDisplay.SetInfoValue("+2 Days, 11 Hours", class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	//RisksLabel.SetInfoValue("MODERATE - Soldier Wounded", class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
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

	//Text.SetHtmlText(strRisks);
	RisksLabel.SetText(strRisks);
}

defaultproperties
{
	bAnimateOnInit = false;
	bIsNavigable = false;
}