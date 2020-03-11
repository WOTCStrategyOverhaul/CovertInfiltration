// TODO: Localise all strings!!!

class UIInfiltrationDetails extends UIScreen;

struct ChosenModifierDisplay
{
	var int Progress;
	var UIText Text;
	var bool bPositioned;
};

var UIPanel MainGroupContainer;
var UIBGBox MainGroupBG;

var UIX2PanelHeader ScreenHeader;
var UIPanel HeaderMilestonesSeparator;

var UIList MilestonesList;
var UIPanel MilestonesChosenSeparator;

var UIPanel ChosenSectionContainer;
var UIImage ChosenLogo;
var UIText ChosenHelpText;
var UIBGBox ChosenInfilBGBar;
var UIBGBox ChosenInfilFillBar;
var UIText ChosenLeftLabels;
var array<ChosenModifierDisplay> ChosenMods;

// Even if currently the infil state is not supposed to change while this screen is up, store it like this just in case
var StateObjectReference InfiltrationRef;

var localized string strHeader;
var localized string strChosenHelpText;

var localized string strChosenProgressLeftLabel;
var localized string strChosenModifierLeftLabel;

const MILESTONES_MARGIN = 10;

simulated function InitScreen (XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	BuildScreen();
	PopulateMilestones();
	CreateChosenMods();

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
	ScreenHeader.InitPanelHeader('ScreenHeader', strHeader, "Operation Bang Boom (123%)");
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

	MilestonesChosenSeparator = Spawn(class'UIPanel', MainGroupContainer);
	MilestonesChosenSeparator.bAnimateOnInit = false;
	MilestonesChosenSeparator.InitPanel('MilestonesChosenSeparator', class'UIUtilities_Controls'.const.MC_GenericPixel);
	MilestonesChosenSeparator.SetX(HeaderMilestonesSeparator.X); // TODO: Y
	MilestonesChosenSeparator.SetSize(HeaderMilestonesSeparator.Width, 2);
	MilestonesChosenSeparator.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	MilestonesChosenSeparator.SetAlpha(30);

	ChosenSectionContainer = Spawn(class'UIPanel', MainGroupContainer);
	ChosenSectionContainer.bAnimateOnInit = false;
	ChosenSectionContainer.InitPanel('ChosenSectionContainer');
	ChosenSectionContainer.SetX(MilestonesList.X); // TODO: Y
	ChosenSectionContainer.SetWidth(MilestonesList.Width);

	ChosenLogo = Spawn(class'UIImage', ChosenSectionContainer);
	ChosenLogo.bAnimateOnInit = false;
	ChosenLogo.InitImage('ChosenLogo', "img:///gfxTacticalHUD.chosen_logo");
	ChosenLogo.SetSize(128, 128);

	ChosenHelpText = Spawn(class'UIText', ChosenSectionContainer);
	ChosenHelpText.bAnimateOnInit = false;
	ChosenHelpText.InitText('ChosenHelpText');
	ChosenHelpText.SetX(ChosenLogo.X + ChosenLogo.Width + 5);
	ChosenHelpText.SetWidth(ChosenSectionContainer.Width - ChosenHelpText.X);
	ChosenHelpText.SetCenteredText(strChosenHelpText);

	ChosenInfilBGBar = Spawn(class'UIBGBox', ChosenSectionContainer);
	ChosenInfilBGBar.bAnimateOnInit = false;
	ChosenInfilBGBar.InitBG('ChosenInfilBGBar');
	ChosenInfilBGBar.SetBGColor("cyan");
	ChosenInfilBGBar.SetY(ChosenLogo.Height + 10);
	ChosenInfilBGBar.SetSize(ChosenSectionContainer.Width, 20);

	ChosenInfilFillBar = Spawn(class'UIBGBox', ChosenSectionContainer);
	ChosenInfilFillBar.bAnimateOnInit = false;
	ChosenInfilFillBar.InitBG('ChosenInfilFillBar');
	ChosenInfilFillBar.SetY(ChosenInfilBGBar.Y);
	ChosenInfilFillBar.SetBGColor("cyan_highlight");
	ChosenInfilFillBar.SetX(ChosenInfilBGBar.X);
	ChosenInfilFillBar.SetWidth(150); //
	ChosenInfilFillBar.SetHeight(ChosenInfilBGBar.Height);

	ChosenLeftLabels = Spawn(class'UIText', ChosenSectionContainer);
	ChosenLeftLabels.OnTextSizeRealized = OnChosenLeftLabelsRealized;
	ChosenLeftLabels.bAnimateOnInit = false;
	ChosenLeftLabels.InitText('ChosenLeftLabels');
	ChosenLeftLabels.SetY(ChosenInfilBGBar.Y + ChosenInfilBGBar.Height + 3);
	ChosenLeftLabels.SetText(strChosenProgressLeftLabel $ "<br/>" $ strChosenModifierLeftLabel);
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

	MilestonesList.RealizeItems();
	MilestonesList.RealizeList();

	MilestonesChosenSeparator.SetY(MilestonesList.Y + /*MilestonesList.GetTotalHeight()*/ 250 + 5); // TODO
	ChosenSectionContainer.SetY(MilestonesChosenSeparator.Y + 5);
}

simulated protected function CreateChosenMods ()
{
	local InfilChosenModifer ModDef;

	foreach class'XComGameState_MissionSiteInfiltration'.default.ChosenAppearenceMods(ModDef)
	{
		ChosenMods.AddItem(SpawnChosenMod(ModDef.Progress, ModDef.Multiplier));
	}
}

simulated protected function OnChosenLeftLabelsRealized ()
{
	local ChosenModifierDisplay ChosenMod;

	ChosenInfilBGBar.SetX(ChosenLeftLabels.X + ChosenLeftLabels.Width + 5);
	ChosenInfilBGBar.SetWidth(ChosenSectionContainer.Width - ChosenInfilBGBar.X);

	ChosenInfilFillBar.SetX(ChosenInfilBGBar.X);
	// TODO: Update ChosenInfilFillBar.Width

	foreach ChosenMods(ChosenMod)
	{
		if (ChosenMod.Text.TextSizeRealized)
		{
			PositionChosenMod(ChosenMod);
		}
	}
}

simulated protected function ChosenModifierDisplay SpawnChosenMod (int Progress, float Multiplier)
{
	local ChosenModifierDisplay ChosenMod;

	ChosenMod.Progress = Progress;
	ChosenMod.Text = Spawn(class'UIText', ChosenSectionContainer);
	ChosenMod.Text.OnTextSizeRealized = ChosenModRealized;
	ChosenMod.Text.bAnimateOnInit = false;
	ChosenMod.Text.InitText();
	ChosenMod.Text.SetY(ChosenLeftLabels.Y);
	ChosenMod.Text.SetText(Progress $ "%<br/>" $ string(Round(Multiplier * 100)) $ "%");

	return ChosenMod;
}

simulated protected function ChosenModRealized ()
{
	local ChosenModifierDisplay ChosenMod;
	
	if (!ChosenLeftLabels.TextSizeRealized) return;

	foreach ChosenMods(ChosenMod)
	{
		if (!ChosenMod.bPositioned && ChosenMod.Text.TextSizeRealized)
		{
			PositionChosenMod(ChosenMod);
		}
	}
}

// Both ChosenMod.Text and ChosenLeftLabels must have been realized before calling this
simulated protected function PositionChosenMod (ChosenModifierDisplay ChosenMod)
{
	local float RelativeX;
	local int i;
	
	if (!ChosenLeftLabels.TextSizeRealized || !ChosenMod.Text.TextSizeRealized)
	{
		`RedScreen(nameof(PositionChosenMod) @ "called before text was realized - bailing");
		return;
	}

	RelativeX = (ChosenInfilBGBar.Width / 150) * (ChosenMod.Progress - 100);
	RelativeX -= ChosenMod.Text.Width / 2;

	ChosenMod.Text.SetX(FClamp(
		ChosenInfilBGBar.X + RelativeX,
		ChosenInfilBGBar.X,
		ChosenInfilBGBar.X + ChosenInfilBGBar.Width - ChosenMod.Text.Width
	));

	i = ChosenMods.Find('Text', ChosenMod.Text);
	ChosenMods[i].bPositioned = true;
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