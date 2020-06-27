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

	// TODO
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
