//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: MCO for covert action items on strategy map, adding the infiltration nameplate
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class CI_UIStrategyMapItem_CovertAction extends UIStrategyMapItem_CovertAction;

var UIScanButton ScanButton;
var UIText PercentLabel;
var UIText ProgressLabel;

var transient bool bScanButtonResized;
var transient float CachedScanButtonWidth;

var localized string strProgress;
var localized string strCovertAction;

simulated function UIStrategyMapItem InitMapItem(out XComGameState_GeoscapeEntity Entity)
{
	local float ScanWidth;

	super.InitMapItem(Entity);

	ScanButton = Spawn(class'UIScanButton', self).InitScanButton();
	ScanButton.SetButtonIcon("");
	//ScanButton.SetDefaultDelegate(OpenInfiltrationMissionScreen);
	ScanButton.SetButtonType(eUIScanButtonType_Default);

	PercentLabel = Spawn(class'UIText', ScanButton).InitText('PercentLabel', "");
	PercentLabel.SetWidth(60); 
	PercentLabel.SetPosition(154, 3);

	ProgressLabel = Spawn(class'UIText', ScanButton).InitText('ProgressLabel', class'UIUtilities_Text'.static.GetSizedText(strProgress, 12));
	ProgressLabel.SetWidth(60); 
	ProgressLabel.SetPosition(154 + 15, 23);
	
	bScanButtonResized = false;

	return self;
}

function UpdateFromGeoscapeEntity(const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	local int InfilPercent;
	local float ScanWidth;
	local XComGameState_CovertAction CovertAction;
	local float TotalDuration, RemainingDuration;

	if( !bIsInited ) return;

	super(UIStrategyMapItem).UpdateFromGeoscapeEntity(GeoscapeEntity);

	CovertAction = GetAction();

	if (CovertAction.bStarted)
	{
		TotalDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CovertAction.EndDateTime, CovertAction.StartDateTime);
		RemainingDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CovertAction.EndDateTime, CovertAction.GetCurrentTime());

		InfilPercent = (1 - (RemainingDuration / TotalDuration)) * 100;

		PercentLabel.SetHTMLText(class'UIUtilities_Text'.static.AlignCenter(class'UIUtilities_Text'.static.AddFontInfo(string(InfilPercent) $ "%", false, true,, 20)));

		if (!bScanButtonResized)
		{
			ScanButton.SetText(Caps(CovertAction.GetDisplayName()), strCovertAction, " ", " ");
		
			bScanButtonResized = true;
		}

		ScanButton.DefaultState();
		ScanButton.PulseScanner(false);
		ScanButton.ShowScanIcon(false);
		ScanButton.Realize();

		ScanWidth = ScanButton.MC.GetNum("bg._width"); 

		if (ScanWidth != CachedScanButtonWidth)
		{
			PercentLabel.SetX(ScanWidth - 60);
			ProgressLabel.SetX(ScanWidth - 65);
			ScanButton.SetX(-(ScanWidth / 2));
			
			CachedScanButtonWidth = ScanWidth;
		}
	}
	else
	{
		ScanButton.Hide();
	}	
}

simulated function bool IsSelectable()
{
	return true;
}

simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID));
}