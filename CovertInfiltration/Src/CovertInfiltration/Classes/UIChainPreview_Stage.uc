class UIChainPreview_Stage extends UIPanel;

var protectedwrite UIImage ArrowImage;
var protectedwrite UIImage BGImage;
var protectedwrite UIText StageNameText;

var protectedwrite XComGameState_Activity ActivityState;
var protectedwrite bool bSiblingLeft;
var protectedwrite bool bSiblingRight;

////////////
/// Init ///
////////////

simulated function InitChainStage (name InitName, bool bInitSiblingLeft, bool bInitSiblingRight)
{
	InitPanel(InitName);

	bSiblingLeft = bInitSiblingLeft;
	bSiblingRight = bInitSiblingRight;

	ArrowImage = Spawn(class'UIImage', self);
	ArrowImage.bAnimateOnInit = false;
	ArrowImage.InitImage('ArrowImage');
	ArrowImage.SetPosition(0, 8);

	BGImage = Spawn(class'UIImage', self);
	BGImage.bAnimateOnInit = false;
	BGImage.InitImage('BGImage', "img:///UILibrary_CI_ChainPreview.chains_single_highlight");
	//BGImage.SetPosition(0, 0);
	BGImage.SetAlpha(35);

	// TODO: Vertical text scroll
	StageNameText = Spawn(class'UIText', self);
	StageNameText.bAnimateOnInit = false;
	StageNameText.InitText('StageNameText');
	StageNameText.SetPosition(15, 37);
	StageNameText.SetSize(200, 60);

	StageNameText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Infiltration'.static.ColourText(
				class'UIUtilities_Text'.static.AlignCenter(
					class'UIUtilities_Infiltration'.static.SetTextLeading("Prepare UFO Takedown", -2)
				),
				"3AE7CF"
			),
			Screen.bIsIn3D, true,, 22
		)
	);
}

////////////////
/// Updating ///
////////////////

//

protected function string GetArrowImageUrl ()
{
	local string LeftState, MiddleState, RightState;
	local XComGameState_ActivityChain ChainState;
	local int StageIndex;

	ChainState = ActivityState.GetActivityChain();
	StageIndex = ActivityState.GetStageIndex();

	// Left part
	if (StageIndex == 0)
	{
		LeftState = "First";
	}
	else
	{
		if (bSiblingLeft) LeftState = "Following";
		else LeftState = "LotsBefore";
	}

	// Middle part
	if (ChainState.iCurrentStage > StageIndex) 
	{
		// Our stage is completed (left of ongoing)
		MiddleState = "Completed";
	}
	else if (ChainState.iCurrentStage == StageIndex)
	{
		// Our stage is ongoing
		MiddleState = "Current";
	}
	else
	{
		// Our stage is not started (right of ongoing)
		MiddleState = "Future";
	}

	// Right part
	if (StageIndex == ChainState.StageRefs.Length - 1)
	{
		RightState = "Last";
	}
	else
	{
		if (bSiblingRight) RightState = "More";
		else RightState = "LotsMore";
	}

	return "img:///UILibrary_CI_ChainPreview.Arrows." $ LeftState $ "_" $ MiddleState $ "_" $ RightState;
}

/////////////////////////
/// defaultproperties ///
/////////////////////////

defaultproperties
{
	Width = 230
	bAnimateOnInit = false
}
