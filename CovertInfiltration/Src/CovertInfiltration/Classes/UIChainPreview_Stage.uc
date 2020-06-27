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

//

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
