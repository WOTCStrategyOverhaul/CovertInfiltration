class UIChainPreview_Stage extends UIPanel;

var protectedwrite UIPanel Container;
var protectedwrite UIImage ArrowImage;
var protectedwrite UITextContainerImproved StageNameTextContainer;

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

	Container = Spawn(class'UIPanel', self);
	Container.bAnimateOnInit = false;
	Container.InitPanel('Container');
	//Container.SetSize(227, 87);
	Container.SetPosition(113.5, 43.5);

	ArrowImage = Spawn(class'UIImage', Container);
	ArrowImage.bAnimateOnInit = false;
	ArrowImage.InitImage('ArrowImage');
	//ArrowImage.SetPosition(0, 8);
	ArrowImage.OriginCenter();
	ArrowImage.SetPosition(14, -20);

	StageNameTextContainer = Spawn(class'UITextContainerImproved', Container);
	StageNameTextContainer.bAnimateOnInit = false;
	StageNameTextContainer.InitTextContainer('StageNameTextContainer');
	StageNameTextContainer.bAutoScroll = true;
	//StageNameTextContainer.SetPosition(15, 37);
	StageNameTextContainer.OriginCenter();
	StageNameTextContainer.SetPosition(-100, -4);
	StageNameTextContainer.SetSize(200, 54);
}

////////////////
/// Updating ///
////////////////

function UpdateForActivity (XComGameState_Activity ActivityState)
{
	local string LeftState, MiddleState, RightState;
	local XComGameState_ActivityChain ChainState;
	local string strNameColour, strName;
	local int StageIndex;

	ChainState = ActivityState.GetActivityChain();
	StageIndex = ActivityState.GetStageIndex();

	///////////////////
	/// Arrow image ///
	///////////////////

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

	ArrowImage.LoadImage("img:///UILibrary_CI_ChainPreview.Arrows." $ LeftState $ "_" $ MiddleState $ "_" $ RightState);

	////////////
	/// Text ///
	////////////

	if (ChainState.iCurrentStage > StageIndex) 
	{
		// Our stage is completed (left of ongoing)
		strNameColour = "249182";
	}
	else if (ChainState.iCurrentStage == StageIndex)
	{
		// Our stage is ongoing
		strNameColour = "3AE7CF";
	}
	else
	{
		// Our stage is not started (right of ongoing)
		strNameColour = "7A7A6E";
	}

	strName = ActivityState.GetOverviewHeader();

	strName = class'UIUtilities_Infiltration'.static.SetTextLeading(strName, -2);
	strName = class'UIUtilities_Text'.static.AlignCenter(strName);
	strName = class'UIUtilities_Infiltration'.static.ColourText(strName, strNameColour);
	strName = class'UIUtilities_Text'.static.AddFontInfo(strName, Screen.bIsIn3D, true,, 22);

	StageNameTextContainer.SetHTMLText(strName);
}

/////////////////
/// Animation ///
/////////////////

simulated function AnimateIn (optional float Delay = 0)
{
	Container.AddTweenBetween("_alpha", 0, Alpha, 0.3, Delay, "easeoutquad");

	Container.AddTweenBetween("_xscale", 150, 100, 0.3, Delay, "easeoutquad");
	Container.AddTweenBetween("_yscale", 150, 100, 0.3, Delay, "easeoutquad");
}

/////////////////////////
/// defaultproperties ///
/////////////////////////

defaultproperties
{
	Width = 230
	bAnimateOnInit = false
}
