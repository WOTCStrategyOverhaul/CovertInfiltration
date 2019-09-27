//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData original, refactor by Xymanek
//  PURPOSE: 
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStrategyMapItem_OpportunityCI extends UIPanel;

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

delegate OnScanButtonClicked ();

simulated function InitOpportunityPanel (optional name InitName)
{
	InitPanel(InitName);

	ScanButton = Spawn(class'UIScanButton', self).InitScanButton();
	ScanButton.SetButtonIcon("");
	ScanButton.SetDefaultDelegate(OnScanButtonClick);
	ScanButton.SetButtonType(eUIScanButtonType_Default);
	ScanButton.OnMouseEventDelegate = OnScanButtonMouseEvent;
	
	PercentLabel = Spawn(class'UIText', ScanButton).InitText('PercentLabel', "");
	PercentLabel.SetWidth(60); 
	PercentLabel.SetPosition(154, 3);

	ProgressLabel = Spawn(class'UIText', ScanButton).InitText('ProgressLabel', "");
	ProgressLabel.SetWidth(60); 
	ProgressLabel.SetPosition(154, 23);

	ProgressBar = Spawn(class'UIProgressBar', self).InitProgressBar('MissionInfiltrationProgress', -32, 5, 64, 8, 0.5, eUIState_Normal);
}

// Data

simulated function UpdateLaunchedActionBox (int InfilPercent, string MissionName, bool IsInfiltration)
{
	local float ScanWidth;

	PercentLabel.SetHTMLText(class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.AddFontInfo(string(InfilPercent) $ "%", false, true,, 20), ColorState,, "CENTER"));
	ProgressLabel.SetHTMLText(class'UIUtilities_Text'.static.GetColoredText(strProgress, ColorState, 12));
	
	if (!bScanButtonResized)
	{
		ScanButton.SetText(Caps(MissionName), (IsInfiltration ? strCovertInfiltration : strCovertAction), " ", " ");
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

	ProgressBar.Hide();
	ScanButton.Show();
}

simulated function UpdateExpiringActionProgressBar (TDateTime TimerStart, TDateTime TimerEnd)
{
	local float TotalDuration, RemainingDuration;
	local float Percent;
	
	TotalDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(TimerEnd, TimerStart);
	RemainingDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(TimerEnd, class'XComGameState_GeoscapeEntity'.static.GetCurrentTime());

	Percent = RemainingDuration / TotalDuration;
	ProgressBar.SetPercent(Percent);
	SetProgressBarColor(Percent);

	ProgressBar.Show();
	ScanButton.Hide();
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

// Scan button mouse

function protected OnScanButtonClick ()
{
	ColorState = eUIState_Normal;

	if (OnScanButtonClicked != none)
	{
		OnScanButtonClicked();
	}
}

simulated function OnScanButtonMouseEvent(UIPanel Panel, int Cmd)
{
	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
			ColorState = -1;
			OnReceiveFocus();
			break;

		case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
			ColorState = eUIState_Normal;
			OnLoseFocus();
			break;
	}
}

// Scan button controller

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	if (`ISCONTROLLERACTIVE)
	{
		ColorState = -1;
	}
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();

	if (`ISCONTROLLERACTIVE)
	{
		ColorState = eUIState_Normal;
	}
}

defaultproperties
{
	MCName = "OpportunityPanel"
	ColorState = eUIState_Normal;

	bProcessesMouseEvents = false;
	bAnimateOnInit = false;
}