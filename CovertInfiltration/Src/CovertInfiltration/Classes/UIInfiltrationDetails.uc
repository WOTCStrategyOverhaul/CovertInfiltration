class UIInfiltrationDetails extends UIScreen;

struct ChosenModifierDisplay
{
	var int Progress;

	var UIText ProgressText;
	var bool bProgressPositioned;

	var UIText ModifierText;
	var bool bModifierPositioned;
};

var UIPanel ModalBackdrop;

var UIPanel MainGroupContainer;
var UIBGBox MainGroupBG;

var UIX2PanelHeader ScreenHeader;
var UIPanel HeaderMilestonesSeparator;

var UIList MilestonesList;
var UIPanel MilestonesChosenSeparator;

var UIPanel ChosenSectionContainer;
var UIImage ChosenLogo;
var UIText ChosenHelpText;
var UIText ChosenInfilLabel;
var UIBGBox ChosenInfilBGBar;
var UIBGBox ChosenInfilFillBar;
var UIText ChosenModifierLabel;
var array<ChosenModifierDisplay> ChosenMods;

// Even if currently the infil state is not supposed to change while this screen is up, store it like this just in case
var StateObjectReference InfiltrationRef;

var localized string strHeader;
var localized string strOperationText;
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
	UpdateNavHelp();

	// TODO: Animate in
}

simulated protected function BuildScreen ()
{
	ModalBackdrop = Spawn(class'UIPanel', self);
	ModalBackdrop.bAnimateOnInit = false;
	ModalBackdrop.InitPanel('ModalBackdrop', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ModalBackdrop.SetPosition(0, 0);
	ModalBackdrop.SetSize(Movie.UI_RES_X, Movie.UI_RES_Y);
	ModalBackdrop.SetColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
	ModalBackdrop.SetAlpha(30);

	// TODO: Try anchoring mid-center
	MainGroupContainer = Spawn(class'UIPanel', self);
	MainGroupContainer.bAnimateOnInit = false;
	MainGroupContainer.InitPanel('MainGroupContainer');
	MainGroupContainer.SetPosition(670, 150);
	MainGroupContainer.SetSize(550, 820);

	MainGroupBG = Spawn(class'UIBGBox', MainGroupContainer);
	MainGroupBG.bAnimateOnInit = false;
	MainGroupBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	MainGroupBG.InitBG('MainGroupBG', 0, 0, MainGroupContainer.Width, MainGroupContainer.Height);
	MainGroupBG.MC.ChildSetNum("bgFill", "_alpha", 100);

	ScreenHeader = Spawn(class'UIX2PanelHeader', MainGroupContainer);
	ScreenHeader.bAnimateOnInit = false;
	ScreenHeader.InitPanelHeader('ScreenHeader', strHeader, GetOperationText());
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
	MilestonesList.bShrinkToFit = true;
	MilestonesList.ItemPadding = 10;
	MilestonesList.InitList('MilestonesList');
	MilestonesList.SetWidth(HeaderMilestonesSeparator.Width - MILESTONES_MARGIN * 2);
	MilestonesList.SetPosition(HeaderMilestonesSeparator.X + MILESTONES_MARGIN, HeaderMilestonesSeparator.Y + 10);

	BuildChosenSection();
}

simulated protected function BuildChosenSection ()
{
	// Do not show this section if there is no chosen theatening this mission
	//if (GetInfiltration().GetCurrentChosen() == none || !class'UIUtilities_Strategy'.static.GetAlienHQ().bChosenActive) return;

	MilestonesChosenSeparator = Spawn(class'UIPanel', MainGroupContainer);
	MilestonesChosenSeparator.bAnimateOnInit = false;
	MilestonesChosenSeparator.InitPanel('MilestonesChosenSeparator', class'UIUtilities_Controls'.const.MC_GenericPixel);
	MilestonesChosenSeparator.SetX(HeaderMilestonesSeparator.X);
	MilestonesChosenSeparator.SetSize(HeaderMilestonesSeparator.Width, 2);
	MilestonesChosenSeparator.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	MilestonesChosenSeparator.SetAlpha(30);

	ChosenSectionContainer = Spawn(class'UIPanel', MainGroupContainer);
	ChosenSectionContainer.bAnimateOnInit = false;
	ChosenSectionContainer.InitPanel('ChosenSectionContainer');
	ChosenSectionContainer.SetX(MilestonesList.X);
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

	ChosenInfilLabel = Spawn(class'UIText', ChosenSectionContainer);
	ChosenInfilLabel.OnTextSizeRealized = OnAnyChosenLeftLabelRealized;
	ChosenInfilLabel.bAnimateOnInit = false;
	ChosenInfilLabel.InitText('ChosenInfilLabel');
	ChosenInfilLabel.SetPosition(0, ChosenLogo.Height + 10);
	ChosenInfilLabel.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.AddFontInfo(strChosenProgressLeftLabel, bIsIn3D, true, true), eUIState_Header));

	ChosenInfilBGBar = Spawn(class'UIBGBox', ChosenSectionContainer);
	ChosenInfilBGBar.bAnimateOnInit = false;
	ChosenInfilBGBar.InitBG('ChosenInfilBGBar');
	ChosenInfilBGBar.SetBGColor("cyan");
	ChosenInfilBGBar.SetPosition(0, ChosenInfilLabel.Y + 32);
	ChosenInfilBGBar.SetSize(ChosenSectionContainer.Width, 20);

	ChosenInfilFillBar = Spawn(class'UIBGBox', ChosenSectionContainer);
	ChosenInfilFillBar.bAnimateOnInit = false;
	ChosenInfilFillBar.InitBG('ChosenInfilFillBar');
	ChosenInfilFillBar.SetPosition(ChosenInfilBGBar.X, ChosenInfilBGBar.Y);
	ChosenInfilFillBar.SetBGColor("cyan_highlight");
	ChosenInfilFillBar.SetHeight(ChosenInfilBGBar.Height);

	ChosenModifierLabel = Spawn(class'UIText', ChosenSectionContainer);
	ChosenModifierLabel.OnTextSizeRealized = OnAnyChosenLeftLabelRealized;
	ChosenModifierLabel.bAnimateOnInit = false;
	ChosenModifierLabel.InitText('ChosenModifierLabel');
	ChosenModifierLabel.SetY(ChosenInfilBGBar.Y + ChosenInfilBGBar.Height + 3);
	ChosenModifierLabel.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.AddFontInfo(strChosenModifierLeftLabel, bIsIn3D, true, true), eUIState_Header));
}

simulated protected function string GetOperationText()
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local XGParamTag ParamTag;

	InfiltrationState = GetInfiltration();
	
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = InfiltrationState.GeneratedMission.BattleOpName;
	ParamTag.IntValue0 = InfiltrationState.GetCurrentInfilInt();
	
	return `XEXPAND.ExpandString(strOperationText);
}

simulated protected function OnAnyChosenLeftLabelRealized ()
{
	local float OverInfilStartX, OverInfilPercentToMax;
	local ChosenModifierDisplay ChosenMod;
	local int i;

	// Wait for the other one
	if (!ChosenInfilLabel.TextSizeRealized || !ChosenModifierLabel.TextSizeRealized) return;

	OverInfilStartX = GetChosenModsX();
	OverInfilPercentToMax = GetInfiltration().GetCurrentOverInfilPercentToMax();
	ChosenInfilFillBar.SetWidth(OverInfilStartX + (GetChosenOverInfilWidth() * OverInfilPercentToMax));

	for (i = 0; i < ChosenMods.Length; i++)
	{
		ChosenMod = ChosenMods[i];

		if (ChosenMods[i].ProgressText.TextSizeRealized) PositionChosenModProgress(ChosenMod);
		if (ChosenMods[i].ModifierText.TextSizeRealized) PositionChosenModModifer(ChosenMod);

		ChosenMods[i] = ChosenMod;
	}
}

simulated protected function ChosenModifierDisplay SpawnChosenMod (int Progress, float Multiplier)
{
	local ChosenModifierDisplay ChosenMod;

	ChosenMod.Progress = Progress;

	ChosenMod.ProgressText = Spawn(class'UIText', ChosenSectionContainer);
	ChosenMod.ProgressText.OnTextSizeRealized = AnyChosenModProgressRealized;
	ChosenMod.ProgressText.bAnimateOnInit = false;
	ChosenMod.ProgressText.InitText();
	ChosenMod.ProgressText.SetY(ChosenInfilLabel.Y);
	ChosenMod.ProgressText.SetText(Progress $ "%");

	ChosenMod.ModifierText = Spawn(class'UIText', ChosenSectionContainer);
	ChosenMod.ModifierText.OnTextSizeRealized = AnyChosenModModifierRealized;
	ChosenMod.ModifierText.bAnimateOnInit = false;
	ChosenMod.ModifierText.InitText();
	ChosenMod.ModifierText.SetY(ChosenModifierLabel.Y);
	ChosenMod.ModifierText.SetText(string(Round(Multiplier * 100)) $ "%");

	return ChosenMod;
}

simulated protected function AnyChosenModProgressRealized ()
{
	local ChosenModifierDisplay ChosenMod;
	local int i;
	
	if (!IsChosenBarReadyForPositioning()) return;

	for (i = 0; i < ChosenMods.Length; i++)
	{
		if (!ChosenMods[i].bProgressPositioned && ChosenMods[i].ProgressText.TextSizeRealized)
		{
			ChosenMod = ChosenMods[i];
			PositionChosenModProgress(ChosenMod);
			ChosenMods[i] = ChosenMod;
		}
	}
}

simulated protected function AnyChosenModModifierRealized ()
{
	local ChosenModifierDisplay ChosenMod;
	local int i;
	
	if (!IsChosenBarReadyForPositioning()) return;

	for (i = 0; i < ChosenMods.Length; i++)
	{
		if (!ChosenMods[i].bModifierPositioned && ChosenMods[i].ModifierText.TextSizeRealized)
		{
			ChosenMod = ChosenMods[i];
			PositionChosenModProgress(ChosenMod);
			ChosenMods[i] = ChosenMod;
		}
	}
}

simulated protected function PositionChosenModProgress (out ChosenModifierDisplay ChosenMod)
{
	ChosenMod.bProgressPositioned = PositionChosenModText(ChosenMod.Progress, ChosenMod.ProgressText, ChosenMod.bProgressPositioned);
}

simulated protected function PositionChosenModModifer (out ChosenModifierDisplay ChosenMod)
{
	ChosenMod.bModifierPositioned = PositionChosenModText(ChosenMod.Progress, ChosenMod.ModifierText, ChosenMod.bModifierPositioned);
}

simulated protected function bool PositionChosenModText (int AtProgress, UIText Text, bool bPositioned)
{
	local float RelativeX, StartX, OverInfilWdith;

	if (bPositioned) return bPositioned;
	
	if (!IsChosenBarReadyForPositioning() || !Text.TextSizeRealized)
	{
		`RedScreen(nameof(PositionChosenModText) @ "called before text was realized - bailing");
		`RedScreen(GetScriptTrace());
		return bPositioned;
	}

	StartX = GetChosenModsX();
	OverInfilWdith = GetChosenOverInfilWidth();
	RelativeX = OverInfilWdith * GetInfiltration().GetOverInfilPercentToMaxAtOverInfil(float(AtProgress - 100) / 100);
	RelativeX -= Text.Width / 2;

	Text.SetX(FClamp(
		StartX + RelativeX, // Value
		StartX, // From
		ChosenInfilBGBar.X + ChosenInfilBGBar.Width - Text.Width // To
	));

	return true;
}

simulated protected function bool IsChosenBarReadyForPositioning ()
{
	return ChosenInfilLabel.TextSizeRealized && ChosenModifierLabel.TextSizeRealized;
}

simulated protected function float GetChosenModsX ()
{
	return FMax(ChosenInfilLabel.X + ChosenInfilLabel.Width, ChosenModifierLabel.X + ChosenModifierLabel.Width) + 3;
}

// Currently assumes that the X  of ChosenInfilBGBar and ChosenInfilFillBar are same
simulated protected function float GetChosenOverInfilWidth ()
{
	return ChosenInfilBGBar.Width - GetChosenModsX();
}

///////////////
/// Navhelp ///
///////////////

simulated protected function UpdateNavHelp ()
{
	local UINavigationHelp NavHelp;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;

	NavHelp.ClearButtonHelp();
	NavHelp.AddBackButton(CloseScreen);
}

///////////////////////
/// Populating data ///
///////////////////////

simulated protected function PopulateMilestones ()
{
	local X2InfiltrationBonusMilestoneTemplateManager MilestoneTemplateManager;
	local X2StrategyElementTemplateManager StrategyTemplateManager;
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local X2InfiltrationBonusMilestoneTemplate MilestoneTemplate;
	local array<InfilBonusMilestoneSelection> SelectedBonuses;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local UIInfiltrationDetails_Milestone MilestoneUI;
	local int i, CurrentProgress, MilestoneStartAt;

	MilestoneTemplateManager = class'X2InfiltrationBonusMilestoneTemplateManager'.static.GetMilestoneTemplateManager();
	StrategyTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	InfiltrationState = GetInfiltration();
	CurrentProgress = InfiltrationState.GetCurrentInfilInt();
	SelectedBonuses = InfiltrationState.GetSortedBonusSelection();

	// Need to iterate backwards so that last milestone ends up on top (first in list)
	for (i = SelectedBonuses.Length - 1; i >= 0; i--)
	{
		// Do not show if there is nothing to be granted here
		if (SelectedBonuses[i].BonusName == '') continue;

		if (i == 0)
		{
			MilestoneStartAt = 101;
		}
		else
		{
			MilestoneTemplate = MilestoneTemplateManager.GetMilestoneTemplate(SelectedBonuses[i - 1].MilestoneName);
			MilestoneStartAt = MilestoneTemplate.ActivateAtProgress + 1;
		}

		BonusTemplate = X2OverInfiltrationBonusTemplate(StrategyTemplateManager.FindStrategyElementTemplate(SelectedBonuses[i].BonusName));
		MilestoneTemplate = MilestoneTemplateManager.GetMilestoneTemplate(SelectedBonuses[i].MilestoneName);

		// Do not show the row if the player cannot attain it
		if (MilestoneTemplate.ActivateAtProgress > InfiltrationState.MaxAllowedInfil) continue;

		MilestoneUI = Spawn(class'UIInfiltrationDetails_Milestone', MilestonesList.ItemContainer);
		MilestoneUI.InitMilestone();
		MilestoneUI.SetProgressInfo(MilestoneStartAt, MilestoneTemplate.ActivateAtProgress, CurrentProgress);

		if (SelectedBonuses[i].bGranted)
		{
			MilestoneUI.SetUnlocked(BonusTemplate.GetBonusName(), BonusTemplate.GetBonusDescription());
		}
		else if (InfiltrationState.GetNextOverInfiltrationBonus() == BonusTemplate)
		{
			MilestoneUI.SetInProgress(BonusTemplate.GetBonusName(), BonusTemplate.GetBonusDescription(), GetHoursUntilPercentInfil(MilestoneTemplate.ActivateAtProgress));
		}
		else
		{
			MilestoneUI.SetLocked(MilestoneTemplate.strName, GetHoursUntilPercentInfil(MilestoneTemplate.ActivateAtProgress));
		}
	}

	MilestonesList.RealizeItems();
	MilestonesList.RealizeList();

	MilestonesChosenSeparator.SetY(MilestonesList.Y + MilestonesList.TotalItemSize + 10);
	ChosenSectionContainer.SetY(MilestonesChosenSeparator.Y + 5);
}

simulated protected function int GetHoursUntilPercentInfil (int TargetInfi)
{
	local float Seconds;

	Seconds = GetInfiltration().GetSecondsUntilPercentInfil(TargetInfi);

	return Round(Seconds / 3600);
}

simulated protected function CreateChosenMods ()
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local ChosenModifierDisplay ChosenMod;
	local InfilChosenModifer ModDef;

	InfiltrationState = GetInfiltration();

	foreach class'XComGameState_MissionSiteInfiltration'.default.ChosenAppearenceMods(ModDef)
	{
		if (ModDef.Progress > InfiltrationState.MaxAllowedInfil) continue;

		ChosenMods.AddItem(SpawnChosenMod(ModDef.Progress, ModDef.Multiplier));
	}

	// See if we have the final one
	foreach ChosenMods(ChosenMod)
	{
		if (ChosenMod.Progress == InfiltrationState.MaxAllowedInfil) return;
	}

	// We don't have a final one, make it
	ChosenMods.AddItem(SpawnChosenMod(
		InfiltrationState.MaxAllowedInfil,
		class'XComGameState_MissionSiteInfiltration'.static.GetChosenInfilScalarForInfilInt(InfiltrationState.MaxAllowedInfil)
	));
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

///////////////
/// Helpers ///
///////////////

simulated function XComGameState_MissionSiteInfiltration GetInfiltration()
{
	return XComGameState_MissionSiteInfiltration(`XCOMHISTORY.GetGameStateForObjectId(InfiltrationRef.ObjectID));
}

defaultproperties
{
	InputState = eInputState_Consume
	bConsumeMouseEvents = true;
}