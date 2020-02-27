// TODO: Localise all strings!!!

class UIInfiltrationDetails extends UIScreen;

var UIPanel MainGroupContainer;
var UIBGBox MainGroupBG;

var UIX2PanelHeader ScreenHeader;
var UIPanel HeaderMilestonesSeparator;
var UIList MilestonesList;

// Even if currently the infil state is not supposed to change while this screen is up, store it like this just in case
var StateObjectReference InfiltrationRef;

// TODO: Investigate applying this margin on everything, not only the list  (also header and the separator)
const MILESTONES_MARGIN = 10;

simulated function InitScreen (XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	BuildScreen();
	PopulateMilestones();

	// TODO: Navbar
	// TODO: Animate in
}

simulated protected function BuildScreen ()
{
	// TODO: Try anchoring mid-center
	MainGroupContainer = Spawn(class'UIPanel', self);
	MainGroupContainer.bAnimateOnInit = false;
	MainGroupContainer.InitPanel('MainGroupContainer');
	MainGroupContainer.SetPosition(670, 185);
	MainGroupContainer.SetSize(550, 720);

	MainGroupBG = Spawn(class'UIBGBox', MainGroupContainer);
	MainGroupBG.bAnimateOnInit = false;
	MainGroupBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	MainGroupBG.InitBG('MainGroupBG', 0, 0, MainGroupContainer.Width, MainGroupContainer.Height);

	ScreenHeader = Spawn(class'UIX2PanelHeader', MainGroupContainer);
	ScreenHeader.bAnimateOnInit = false;
	ScreenHeader.InitPanelHeader('ScreenHeader', "OVER INFILTRATION", "Operation Bang Boom (123%)");
	ScreenHeader.SetHeaderWidth(MainGroupBG.Width - 20);
	ScreenHeader.SetPosition(MainGroupBG.X + 10, MainGroupBG.Y + 10);

	// Slightly modified version of class'UIUtilities_Controls'.static.CreateDividerLineBeneathControl
	HeaderMilestonesSeparator = Spawn(class'UIPanel', MainGroupContainer);
	HeaderMilestonesSeparator.bAnimateOnInit = false;
	HeaderMilestonesSeparator.InitPanel('HeaderMilestonesSeparator', class'UIUtilities_Controls'.const.MC_GenericPixel);
	HeaderMilestonesSeparator.SetPosition(ScreenHeader.X, ScreenHeader.Y + ScreenHeader.height - 4); 
	HeaderMilestonesSeparator.SetSize(ScreenHeader.headerWidth, 2);
	HeaderMilestonesSeparator.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	HeaderMilestonesSeparator.SetAlpha(30);

	MilestonesList = Spawn(class'UIList', MainGroupContainer);
	MilestonesList.bAnimateOnInit = false;
	MilestonesList.ItemPadding = 10;
	MilestonesList.InitList('MilestonesList');
	MilestonesList.SetWidth(HeaderMilestonesSeparator.Width - MILESTONES_MARGIN * 2);
	MilestonesList.SetPosition(HeaderMilestonesSeparator.X + MILESTONES_MARGIN, HeaderMilestonesSeparator.Y + 10);
}

simulated protected function PopulateMilestones ()
{
	local UIInfiltrationDetails_Milestone Milestone;

	Milestone = Spawn(class'UIInfiltrationDetails_Milestone', MilestonesList.ItemContainer);
	Milestone.InitMilestone();
	Milestone.SetProgressInfo(201, 300, 200);
	Milestone.SetLocked("So far away");

	Milestone = Spawn(class'UIInfiltrationDetails_Milestone', MilestonesList.ItemContainer);
	Milestone.InitMilestone();
	Milestone.SetProgressInfo(151, 200, 178);
	Milestone.SetInProgress("Almost there", "All enemies die when you look at them sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");

	Milestone = Spawn(class'UIInfiltrationDetails_Milestone', MilestonesList.ItemContainer);
	Milestone.InitMilestone();
	Milestone.SetProgressInfo(100, 150, 150);
	Milestone.SetUnlocked("Unlocked milestone", "+30 player damage output dsddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
}

/////////////
/// Input ///
/////////////

simulated function bool OnUnrealCommand (int cmd, int arg)
{
	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			CloseScreen();
			return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}

defaultproperties
{
	InputState = eInputState_Consume
}