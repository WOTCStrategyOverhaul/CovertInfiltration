//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: MCO for covert action items on strategy map
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class CI_UIStrategyMapItem_CovertAction extends UIStrategyMapItem_CovertAction;

var UIScanButton ScanButton;
var UIText PercentLabel;
var UIText ProgressLabel;

var UIProgressBar ProgressBar;

var int ColorState;

var transient bool bScanButtonResized;
var transient float CachedScanButtonWidth;

var localized string strProgress;
var localized string strCovertAction;
var localized string strCovertInfiltration;

simulated function UIStrategyMapItem InitMapItem(out XComGameState_GeoscapeEntity Entity)
{
	super.InitMapItem(Entity);

	ScanButton = Spawn(class'UIScanButton', self).InitScanButton();
	ScanButton.SetButtonIcon("");
	ScanButton.SetDefaultDelegate(OpenCovertActionsScreen);
	ScanButton.SetButtonType(eUIScanButtonType_Default);
	
	PercentLabel = Spawn(class'UIText', ScanButton).InitText('PercentLabel', "");
	PercentLabel.SetWidth(60); 
	PercentLabel.SetPosition(154, 3);

	ProgressLabel = Spawn(class'UIText', ScanButton).InitText('ProgressLabel', "");
	ProgressLabel.SetWidth(60); 
	ProgressLabel.SetPosition(154, 23);

	ProgressBar = Spawn(class'UIProgressBar', self).InitProgressBar('MissionInfiltrationProgress', -32, 5, 64, 8, 0.5, eUIState_Normal);
		
	bScanButtonResized = false;

	ColorState = eUIState_Normal;

	return self;
}

function UpdateFromGeoscapeEntity(const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	local XComGameState_CovertAction CovertAction;

	if (!bIsInited) return;

	super.UpdateFromGeoscapeEntity(GeoscapeEntity);

	CovertAction = GetAction();

	if (CovertAction.bStarted)
	{
		UpdateLaunchedActionBox(CovertAction);
		ProgressBar.Hide();
	}
	else
	{
		UpdateExpiringActionProgressBar(CovertAction);
		ScanButton.Hide();
	}	
}

simulated function UpdateLaunchedActionBox(XComGameState_CovertAction CovertAction)
{
	local float TotalDuration, RemainingDuration;
	local int InfilPercent;
	local float ScanWidth;
	
	TotalDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CovertAction.EndDateTime, CovertAction.StartDateTime);
	RemainingDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CovertAction.EndDateTime, CovertAction.GetCurrentTime());

	InfilPercent = (1 - (RemainingDuration / TotalDuration)) * 100;

	PercentLabel.SetHTMLText(class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.AddFontInfo(string(InfilPercent) $ "%", false, true,, 20), ColorState,, "CENTER"));
	ProgressLabel.SetHTMLText(class'UIUtilities_Text'.static.GetColoredText(strProgress, ColorState, 12));
	
	if (!bScanButtonResized)
	{
		if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction))
		{
			ScanButton.SetText(Caps(CovertAction.GetDisplayName()), strCovertInfiltration, " ", " ");
		}
		else
		{
			ScanButton.SetText(Caps(CovertAction.GetDisplayName()), strCovertAction, " ", " ");
		}
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
		ProgressLabel.SetX(ScanWidth - 60);
		ScanButton.SetX(-(ScanWidth / 2));
			
		CachedScanButtonWidth = ScanWidth;
	}	
}

simulated function UpdateExpiringActionProgressBar(XComGameState_CovertAction CovertAction)
{
	local bool FoundAction;
	local ActionExpirationInfo ActionInfo;
	local float TotalDuration, RemainingDuration;
	local float Percent;
	
	FoundAction = class'XComGameState_CovertActionExpirationManager'.static.GetActionExpirationInfo(CovertAction.GetReference(), ActionInfo);

	if (!FoundAction || ActionInfo.Expiration.m_iYear > 2100)
	{
		ProgressBar.Hide();
		return;
	}	
	
	TotalDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(ActionInfo.Expiration, ActionInfo.OriginTime);
	RemainingDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(ActionInfo.Expiration, class'XComGameState_GeoscapeEntity'.static.GetCurrentTime());

	Percent = RemainingDuration / TotalDuration;
	ProgressBar.SetPercent(Percent);
	SetProgressBarColor(Percent);

	ProgressBar.Show();
}

simulated function SetProgressBarColor(float percent)
{
	if (percent > 0.75)
	{
		ProgressBar.SetColor(class'UIUtilities_Colors'.const.GOOD_HTML_COLOR);
	}
	else if (percent > 0.5)
	{
		ProgressBar.SetColor(class'UIUtilities_Colors'.const.WARNING_HTML_COLOR);
	}
	else if (percent > 0.25)
	{
		ProgressBar.SetColor(class'UIUtilities_Colors'.const.WARNING2_HTML_COLOR);
	}
	else
	{
		ProgressBar.SetColor(class'UIUtilities_Colors'.const.BAD_HTML_COLOR);
	}
}

function OpenCovertActionsScreen()
{
	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(GetAction().GetReference());
}

simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID));
}

simulated function bool IsSelectable()
{
	return true;
}

simulated function OnMouseEvent(int cmd, array<string> args)
{
	if(GetStrategyMap().m_eUIState == eSMS_Flight)
		return;

	switch(cmd) 
	{ 
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
			OnMouseIn();
			break;
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
			OnMouseOut();
			break;
	}
}

simulated function OnMouseIn()
{
	ColorState = -1;
	super(UIStrategyMapItem).OnMouseIn();
}

simulated function OnMouseOut()
{
	ColorState = eUIState_Normal;
	super(UIStrategyMapItem).OnMouseOut();
}

defaultproperties
{
	bProcessesMouseEvents = false;
}