//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and ArcaneData
//  PURPOSE: This class houses static helper methods that are used by
//           different UI classes
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIUtilities_Infiltration extends Object;

//////////////////
/// Game state ///
//////////////////
       
// Adapted from UICovertActions           
static function bool ShouldShowCovertAction(XComGameState_CovertAction ActionState)
{
	local XComGameState_ResistanceFaction FactionState;
	FactionState = ActionState.GetFaction();

	// Only display actions which are actually stored by the Faction. Safety check to prevent
	// actions which were supposed to have been deleted from showing up in the UI and being accessed.
	if (
		FactionState.CovertActions.Find('ObjectID', ActionState.ObjectID) == INDEX_NONE &&
		FactionState.GoldenPathActions.Find('ObjectID', ActionState.ObjectID) == INDEX_NONE
	) {
		return false;
	}
	
	// Always show in-progess actions
	if (ActionState.bStarted) return true;
	
	return ActionState.CanActionBeDisplayed() && (ActionState.GetMyTemplate().bGoldenPath || FactionState.bSeenFactionHQReveal);;
}

///////////////
/// UI/Text ///
///////////////

static function UICovertActionsGeoscape(optional StateObjectReference ActionToFocus)
{
	local XComHQPresentationLayer HQPres;
	local UICovertActionsGeoscape TheScreen;

	HQPres = `HQPRES;
	if (HQPres.ScreenStack.GetFirstInstanceOf(class'UICovertActionsGeoscape') != none) return;

	TheScreen = HQPres.Spawn(class'UICovertActionsGeoscape', HQPres);
	TheScreen.ActionToShowOnInitRef = ActionToFocus;
	
	HQPres.ScreenStack.Push(TheScreen);
}

static function string ColourText(string strValue, string strColour)
{
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}

static function string MakeFirstCharCapOnly(string strValue)
{
	return Caps(Left(strValue, 1)) $ Locs(Right(strValue, Len(strValue) - 1));
}

static function array<string> GetRisksStringsFor(XComGameState_CovertAction CovertAction)
{
	local X2StrategyElementTemplateManager StratMgr;
	local array<string> RiskStrings;
	local CovertActionRisk Risk;
	local X2CovertActionRiskTemplate RiskTemplate;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach CovertAction.Risks(Risk)
	{
		RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(Risk.RiskTemplateName));	

		if (RiskTemplate == none || CovertAction.NegatedRisks.Find(Risk.RiskTemplateName) != INDEX_NONE)
		{
			continue;
		}

		RiskStrings.AddItem(GetRiskDifficultyColouredString(Risk.Level) $ " - " $ RiskTemplate.RiskName);
	}

	return RiskStrings;
}

static function string GetRiskDifficultyColouredString(int RiskLevel)
{
	local string Text;
	local eUIState ColorState;

	Text = class'X2StrategyGameRulesetDataStructures'.default.CovertActionRiskLabels[RiskLevel];

	switch (RiskLevel)
	{
	case 0: ColorState = eUIState_Warning;     break;
	case 1: ColorState = eUIState_Warning2;   break;
	case 2: ColorState = eUIState_Bad;		break;
	}

	return class'UIUtilities_Text'.static.GetColoredText(Text, ColorState);
}