class UIChainPreview extends UIPanel;

////////////////////
/// UI tree vars ///
////////////////////

var protectedwrite UIPanel CenterSection;
var protectedwrite UIImage CenterBacklight;
var protectedwrite UIButton OverviewScreenButton;
var protectedwrite UIText LeftExtraCountText;
var protectedwrite UIText RightExtraCountText;

// We support at most 3 now, any more we simply show the counts.
// For sake of simplicity, all 3 are pre-created (and not created on-demand)
var protectedwrite UIChainPreview_Stage Stages[3];

var protectedwrite UIPanel ComplicationsSection;
var protectedwrite UIImage ComplicationsBacklight;
var protectedwrite UIText ComplicationsFluffHeader;
var protectedwrite UIImage ComplicationsWarnIcon;
var protectedwrite UIText ComplicationsFluffDescription;
var protectedwrite UIScrollingText ComplicationsNamesText;

//////////////////
/// State vars ///
//////////////////

var protectedwrite StateObjectReference FocusedActivityRef;

////////////////
/// Loc vars ///
////////////////

var localized string strSingleComplicationFluff;
var localized string strMultipleComplicationsFluff;

////////////
/// Init ///
////////////

simulated function InitChainPreview (optional name InitName)
{
	InitPanel(InitName);
	AnchorTopCenter();

	BuildCenter();
	BuildComplications();
}

simulated protected function BuildCenter ()
{
	// TODO
}

simulated protected function BuildComplications ()
{
	ComplicationsSection = Spawn(class'UIPanel', self);
	ComplicationsSection.bAnimateOnInit = false;
	ComplicationsSection.InitPanel('ComplicationsSection');
	ComplicationsSection.SetPosition(-843, 17);

	ComplicationsBacklight = Spawn(class'UIImage', ComplicationsSection);
	ComplicationsBacklight.bAnimateOnInit = false;
	ComplicationsBacklight.InitImage('ComplicationsBacklight', "img:///UILibrary_CI_ChainPreview.complication_highlight");
	ComplicationsBacklight.SetPosition(-201, -17);
	ComplicationsBacklight.SetAlpha(40);

	ComplicationsFluffHeader = Spawn(class'UIText', ComplicationsSection);
	ComplicationsFluffHeader.bAnimateOnInit = false;
	ComplicationsFluffHeader.InitText('ComplicationsFluffHeader');
	ComplicationsFluffHeader.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Text'.static.GetColoredText(class'UIMission'.default.m_strChosenWarning, eUIState_Bad), Screen.bIsIn3D, true,, 18)
	);
	ComplicationsFluffHeader.SetPosition(0, 0);

	ComplicationsWarnIcon = Spawn(class'UIImage', ComplicationsSection);
	ComplicationsWarnIcon.bAnimateOnInit = false;
	ComplicationsWarnIcon.InitImage('ComplicationsWarnIcon', "img:///UILibrary_CI_ChainPreview.warning_icon");
	ComplicationsWarnIcon.SetPosition(83, 2); // TODO: Different lang size of ComplicationsFluffHeader

	ComplicationsFluffDescription = Spawn(class'UIText', ComplicationsSection);
	ComplicationsFluffDescription.bAnimateOnInit = false;
	ComplicationsFluffDescription.InitText('ComplicationsFluffDescription');
	ComplicationsFluffDescription.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Text'.static.GetColoredText(strSingleComplicationFluff, eUIState_Bad), Screen.bIsIn3D, true,, 18)
	);
	ComplicationsFluffDescription.SetPosition(112, 0);

	ComplicationsNamesText = Spawn(class'UIScrollingText', ComplicationsSection);
	ComplicationsNamesText.bAnimateOnInit = false;
	ComplicationsNamesText.InitScrollingText('ComplicationsNamesText');
	ComplicationsNamesText.SetTitle(class'UIUtilities_Text'.static.GetColoredText("Reward Interception", eUIState_Bad)); // TODO: Temp
	ComplicationsNamesText.SetPosition(0, 28);
	ComplicationsNamesText.SetWidth(330);
}

//////////////////////////
/// Player interaction ///
//////////////////////////

// On button click

////////////////
/// Updating ///
////////////////

//

/////////////////
/// Animation ///
/////////////////

//

///////////////
/// Helpers ///
///////////////

function XComGameState_Activity GetFocusedActivity ()
{
	return XComGameState_Activity(`XCOMHISTORY.GetGameStateForObjectID(FocusedActivityRef.ObjectID));
}

/////////////////////////
/// defaultproperties ///
/////////////////////////

defaultproperties
{
	bAnimateOnInit = false
}
