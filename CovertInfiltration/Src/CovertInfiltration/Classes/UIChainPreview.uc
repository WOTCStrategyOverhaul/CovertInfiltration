// Note about the positioning: UE3 requires all textures to be power of 2, including the UI ones.
// So, in order to avoid resizing (and losing quality), the textures are padded to closest
// pow2 size with transparency. This works as long as the code doesn't call UIImage::SetSize
// as that will resize including the extra transparency.
// A side effect of the above is that the Width and Height properties on images are bogus
// and ****can not be used for layouting****. If you need a reference, check the UI mockups

class UIChainPreview extends UIPanel;

////////////////////
/// UI tree vars ///
////////////////////

var protectedwrite UIPanel CenterSection;
var protectedwrite UIImage CenterBacklight;

var protectedwrite UIText ChainNameText;
var protectedwrite UIButton OverviewScreenButton;
var protectedwrite UIImage OverviewScreenControllerIcon;

var protectedwrite UIDags ChainNameDagsLeft;
var protectedwrite UIDags ChainNameDagsRight;

// We support at most 3 now, any more we simply show the counts.
// For sake of simplicity, all 3 are pre-created (and not created on-demand)
var protectedwrite UIChainPreview_Stage Stages[3];
var protectedwrite UIText LeftExtraCountText;
var protectedwrite UIText RightExtraCountText;

var protectedwrite UIPanel ComplicationsSection;
var protectedwrite UIImage ComplicationsBacklight;
var protectedwrite UIText ComplicationsFluffHeader;
var protectedwrite UIImage ComplicationsWarnIcon;
var protectedwrite UIText ComplicationsFluffDescription;
var protectedwrite UIScrollingText ComplicationsNamesText;

/////////////////////
/// UI param vars ///
/////////////////////

var string strControllerIcon;
var int ControllerIconWidthToHeight;

//////////////////
/// State vars ///
//////////////////

var protectedwrite StateObjectReference FocusedActivityRef;

////////////////
/// Loc vars ///
////////////////

var localized string strSingleComplicationFluff;
var localized string strMultipleComplicationsFluff;

////////////////////////
/// Layout constants ///
////////////////////////

const ChainNameSectionMostLeft = 168.5;
const ChainNameSectionMostRight = 933.5;
const ChainNameSectionPreButtonSpacing = 10;
const ChainNameSectionButtonWidth = 23;
const ChainNameSectionPreIconSpacing = 7;
const ChainNameSectionMargin = 20;

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
	CenterSection = Spawn(class'UIPanel', self);
	CenterSection.bAnimateOnInit = false;
	CenterSection.InitPanel('CenterSection');
	CenterSection.SetPosition(-543, 0);

	CenterBacklight = Spawn(class'UIImage', CenterSection);
	CenterBacklight.bAnimateOnInit = false;
	CenterBacklight.InitImage('CenterBacklight', "img:///UILibrary_CI_ChainPreview.chains_main_highlight");
	CenterBacklight.SetPosition(178, 0);
	CenterBacklight.SetAlpha(20);

	ChainNameText = Spawn(class'UIText', CenterSection);
	ChainNameText.bAnimateOnInit = false;
	ChainNameText.OnTextSizeRealized = OnChainNameRealized;
	ChainNameText.InitText('ChainNameText');
	ChainNameText.SetY(11);

	OverviewScreenButton = Spawn(class'UIButton', CenterSection);
	OverviewScreenButton.bAnimateOnInit = false;
	OverviewScreenButton.LibID = 'X2InfoButton';
	OverviewScreenButton.InitButton('OverviewScreenButton');
	OverviewScreenButton.OnClickedDelegate = OpenOverview;
	OverviewScreenButton.SetY(16);

	OverviewScreenControllerIcon = Spawn(class'UIImage', CenterSection);
	OverviewScreenControllerIcon.bAnimateOnInit = false;
	OverviewScreenControllerIcon.InitImage('OverviewScreenControllerIcon', "img:///gfxGamepadIcons." $ class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ strControllerIcon);
	OverviewScreenControllerIcon.SetPosition(OverviewScreenButton.X + 30, OverviewScreenButton.Y + 1);
	OverviewScreenControllerIcon.SetHeight(25); // 2px smaller than the OverviewScreenButton
	OverviewScreenControllerIcon.SetWidth(OverviewScreenControllerIcon.Height * ControllerIconWidthToHeight);

	ChainNameDagsLeft = Spawn(class'UIDags', CenterSection);
	ChainNameDagsLeft.bAnimateOnInit = false;
	ChainNameDagsLeft.InitPanel('ChainNameDagsLeft');
	ChainNameDagsLeft.SetColor("98C8C8");
	ChainNameDagsLeft.SetAlpha(15);
	ChainNameDagsLeft.SetPosition(ChainNameSectionMostLeft, 20);
	//ChainNameDagsLeft.SetWidth(142); // TODO
	ChainNameDagsLeft.SetHeight(20);
	ChainNameDagsLeft.SetDagsScaleX(60); // TODO: Reverse

	ChainNameDagsRight = Spawn(class'UIDags', CenterSection);
	ChainNameDagsRight.bAnimateOnInit = false;
	ChainNameDagsRight.InitPanel('ChainNameDagsRight');
	ChainNameDagsRight.SetColor("98C8C8");
	ChainNameDagsRight.SetAlpha(15);
	ChainNameDagsRight.SetY(20);
	//ChainNameDagsRight.SetX(644);
	//ChainNameDagsRight.SetWidth(142); // TODO
	ChainNameDagsRight.SetHeight(20);
	ChainNameDagsRight.SetDagsScaleX(60);

	LeftExtraCountText = Spawn(class'UIText', CenterSection);
	LeftExtraCountText.bAnimateOnInit = false;
	LeftExtraCountText.InitText('LeftExtraCountText');
	LeftExtraCountText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Infiltration'.static.ColourText("+2", "249182"), Screen.bIsIn3D, true,, 22)
	);
	LeftExtraCountText.SetPosition(168.5, 48);

	RightExtraCountText = Spawn(class'UIText', CenterSection);
	RightExtraCountText.bAnimateOnInit = false;
	RightExtraCountText.InitText('RightExtraCountText');
	RightExtraCountText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Infiltration'.static.ColourText("+5", "7A7A6E"), Screen.bIsIn3D, true,, 22)
	);
	RightExtraCountText.SetPosition(899.5, 48);

	Stages[0] = Spawn(class'UIChainPreview_Stage', CenterSection);
	Stages[0].InitChainStage('ChainStage0', false, true);
	Stages[0].SetPosition(210, 41);
	Stages[0].ArrowImage.LoadImage("img:///UILibrary_CI_ChainPreview.Arrows.LotsBefore_Completed_More");

	Stages[1] = Spawn(class'UIChainPreview_Stage', CenterSection);
	Stages[1].InitChainStage('ChainStage1', true, true);
	Stages[1].SetPosition(438, 41);
	Stages[1].ArrowImage.LoadImage("img:///UILibrary_CI_ChainPreview.Arrows.Following_Current_More");

	Stages[2] = Spawn(class'UIChainPreview_Stage', CenterSection);
	Stages[2].InitChainStage('ChainStage2', true, false);
	Stages[2].SetPosition(665, 41);
	Stages[2].ArrowImage.LoadImage("img:///UILibrary_CI_ChainPreview.Arrows.Following_Future_LotsMore");

	
}

simulated protected function OnChainNameRealized ()
{
	local float RequiredSpace, DagsWidth;

	// Text + button
	RequiredSpace = ChainNameText.Width + ChainNameSectionPreButtonSpacing + ChainNameSectionButtonWidth;

	// Add the controller hint icon
	if (OverviewScreenControllerIcon != none)
	{
		RequiredSpace += ChainNameSectionPreIconSpacing + OverviewScreenControllerIcon.Width;
	}

	// Add side margin
	RequiredSpace += ChainNameSectionMargin * 2;

	// How wide are the dags?
	DagsWidth = ChainNameSectionMostRight - ChainNameSectionMostLeft - RequiredSpace; 

	// Distrubute dags on both sides
	DagsWidth /= 2;

	// Position dags
	ChainNameDagsLeft.SetWidth(DagsWidth);
	ChainNameDagsRight.SetWidth(DagsWidth);
	ChainNameDagsRight.SetX(ChainNameSectionMostRight - DagsWidth);

	// Position text
	ChainNameText.SetX(ChainNameSectionMostLeft + DagsWidth + ChainNameSectionMargin);

	// Position button
	OverviewScreenButton.SetX(ChainNameText.X + ChainNameText.Width + ChainNameSectionPreButtonSpacing);

	// Position controller hint icon
	if (OverviewScreenControllerIcon != none)
	{
		OverviewScreenControllerIcon.SetX(OverviewScreenButton.X + ChainNameSectionButtonWidth + ChainNameSectionPreIconSpacing);
	}

	// Force everything we touched to update this frame
	ChainNameText.MC.ProcessCommands(true);
	if (ChainNameDagsLeft.bIsInited) ChainNameDagsLeft.MC.ProcessCommands(true);
	if (ChainNameDagsRight.bIsInited) ChainNameDagsRight.MC.ProcessCommands(true);
	if (OverviewScreenControllerIcon.bIsInited) OverviewScreenControllerIcon.MC.ProcessCommands(true);
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
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Text'.static.GetColoredText(class'UIMission'.default.m_strChosenWarning2, eUIState_Bad), Screen.bIsIn3D, true,, 18)
	);
	ComplicationsFluffHeader.SetPosition(0, 0);

	ComplicationsWarnIcon = Spawn(class'UIImage', ComplicationsSection);
	ComplicationsWarnIcon.bAnimateOnInit = false;
	ComplicationsWarnIcon.InitImage('ComplicationsWarnIcon', "img:///UILibrary_CI_ChainPreview.warning_icon");
	ComplicationsWarnIcon.SetPosition(83, 2); // TODO: Different lang size of ComplicationsFluffHeader

	ComplicationsFluffDescription = Spawn(class'UIText', ComplicationsSection);
	ComplicationsFluffDescription.bAnimateOnInit = false;
	ComplicationsFluffDescription.InitText('ComplicationsFluffDescription');
	/*ComplicationsFluffDescription.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Text'.static.GetColoredText(strSingleComplicationFluff, eUIState_Bad), Screen.bIsIn3D, true,, 18)
	);*/
	ComplicationsFluffDescription.SetPosition(112, 0);

	ComplicationsNamesText = Spawn(class'UIScrollingText', ComplicationsSection);
	ComplicationsNamesText.bAnimateOnInit = false;
	ComplicationsNamesText.InitScrollingText('ComplicationsNamesText');
	//ComplicationsNamesText.SetTitle(class'UIUtilities_Text'.static.GetColoredText("Reward Interception", eUIState_Bad)); // TODO: Temp
	ComplicationsNamesText.SetPosition(0, 28);
	ComplicationsNamesText.SetWidth(330);
}

simulated function OnInit ()
{
	super.OnInit();

	ChainNameText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Infiltration'.static.ColourText("Raid Alien UFO", "90BDBD"), Screen.bIsIn3D, false,, 28)
	);
}

//////////////////////////
/// Player interaction ///
//////////////////////////

simulated function OpenOverview (UIButton Button)
{
	class'UIUtilities_Infiltration'.static.UIChainsOverview(GetFocusedActivity().ChainRef, false /* TODO */);
}

////////////////
/// Updating ///
////////////////

function SetFocusedActivity (StateObjectReference InFocusedActivityRef)
{
	FocusedActivityRef = InFocusedActivityRef;

	if (FocusedActivityRef.ObjectID != 0 && GetFocusedActivity() == none)
	{
		`RedScreen("UIChainPreview::SetFocusedActivity - bad ref passed. Setting to 0 (preview will be hidden)");
		`RedScreen(GetScriptTrace());

		FocusedActivityRef.ObjectID = 0;
	}

	UpdateStages();
	UpdateComplications();

	ChainNameText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Infiltration'.static.ColourText(
				GetFocusedActivity().GetActivityChain().GetOverviewTitle(),
				"90BDBD"
			),
			Screen.bIsIn3D, false,, 28
		)
	);
}

protected function UpdateStages ()
{
	local XComGameState_Activity FocusedActivityState, ActivityState;
	local XComGameState_ActivityChain ChainState;
	local int FocusedStageIndex;

	FocusedActivityState = GetFocusedActivity();
	if (FocusedActivityState == none)
	{
		CenterSection.Hide();
		return;
	}

	FocusedStageIndex = FocusedActivityState.GetStageIndex();
	ChainState = FocusedActivityState.GetActivityChain();

	CenterSection.Show();

	// The following code handles with figuring out which slots to assign to which stages.
	// The general logic is to keep the focused (current) activity in the center, unless
	// it is the first or the last one and moving it to a side will allow us to show more
	// activities (instead of wasting a slot and using the extra indicators)

	if (ChainState.StageRefs.Length == 1)
	{
		LeftExtraCountText.Hide();
		RightExtraCountText.Hide();
		
		Stages[0].Hide();
		Stages[2].Hide();

		Stages[1].Show();
		Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(0));
	}
	else if (ChainState.StageRefs.Length == 2)
	{
		LeftExtraCountText.Hide();
		RightExtraCountText.Hide();

		if (FocusedStageIndex == 0)
		{
			Stages[0].Hide();

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(0));

			Stages[2].Show();
			Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(1));
		}
		else
		{
			Stages[0].Show();
			Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(0));

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(1));

			Stages[2].Hide();
		}
	}
	else if (ChainState.StageRefs.Length == 3)
	{
		LeftExtraCountText.Hide();
		RightExtraCountText.Hide();
		
		Stages[0].Show();
		Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(0));

		Stages[1].Show();
		Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(1));

		Stages[2].Show();
		Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(2));
	}
	else // 4 and more
	{
		// TODO
	}
}

protected function UpdateComplications ()
{
	local XComGameState_Complication ComplicationState;
	local XComGameState_Activity FocusedActivityState;
	local XComGameState_ActivityChain ChainState;
	local StateObjectReference ComplicationRef;
	local array<string> ComplicationsNames;
	local XComGameStateHistory Histroy;
	local string strComplications;
	local int i;

	FocusedActivityState = GetFocusedActivity();
	if (FocusedActivityState == none)
	{
		ComplicationsSection.Hide();
		return;
	}

	ChainState = FocusedActivityState.GetActivityChain();
	if (ChainState.ComplicationRefs.Length < 1) 
	{
		ComplicationsSection.Hide();
		return;
	}

	Histroy = `XCOMHISTORY;
	ComplicationsNames.Length = ChainState.ComplicationRefs.Length;
	
	foreach ChainState.ComplicationRefs(ComplicationRef, i)
	{
		ComplicationState = XComGameState_Complication(Histroy.GetGameStateForObjectID(ComplicationRef.ObjectID));
		ComplicationsNames[i] = ComplicationState.GetMyTemplate().FriendlyName;
	}

	ComplicationsFluffDescription.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Text'.static.GetColoredText(
				ComplicationsNames.Length == 1 ? strSingleComplicationFluff : strMultipleComplicationsFluff,
				eUIState_Bad
			),
			Screen.bIsIn3D, true,, 18
		)
	);

	JoinArray(ComplicationsNames, strComplications, ", ");
	ComplicationsNamesText.SetTitle(class'UIUtilities_Text'.static.GetColoredText(strComplications, eUIState_Bad));

	ComplicationsSection.Show();
}

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
	bIsNavigable = false

	strControllerIcon = "Icon_RT_R2" // Right trigger
	ControllerIconWidthToHeight = 2 // The icon is 1:2 height:width
}
