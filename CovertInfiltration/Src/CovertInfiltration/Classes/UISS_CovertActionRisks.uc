//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Displays covert action risks on the squad select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_CovertActionRisks extends UIPanel;

var UIText Text;

simulated function InitRisks()
{
	InitPanel('UISS_CovertActionRisks');
	AnchorTopRight();
	SetPosition(-400, 0);
	
	Text = Spawn(class'UIText', self);
	Text.bAnimateOnInit = false;
	Text.InitText('Text');
	Text.SetWidth(-X);
}

simulated function MoveUnderResourceBar(bool NewValue)
{
	SetY(NewValue ? 100 : 0);
}

simulated function UpdateData(XComGameState_CovertAction CurrentAction)
{
	local array<string> Labels, Values; 
	local string strRisks;
	local int idx; 

	CurrentAction.GetRisksStrings(Labels, Values);

	for (idx = 0; idx < Labels.Length; idx++)
	{
		strRisks $= "<p>" $ class'UIUtilities_Text'.static.AddFontInfo(Values[idx] $ " - " $ Labels[idx], Screen.bIsIn3D) $ "</p>";
	}

	Text.SetHtmlText(strRisks);
}

defaultproperties
{
	bAnimateOnInit = false;
	bIsNavigable = false;
}