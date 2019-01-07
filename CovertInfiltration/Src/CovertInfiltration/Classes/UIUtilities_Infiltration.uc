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
	local array<CovertActionRisk> Risks;
	local CovertActionRisk Risk;
	local X2CovertActionRiskTemplate RiskTemplate;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Risks = CovertAction.Risks;
	Risks.Sort(SortRisksByDifficulty);

	foreach Risks(Risk)
	{
		RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(Risk.RiskTemplateName));	

		if (RiskTemplate == none || CovertAction.NegatedRisks.Find(Risk.RiskTemplateName) != INDEX_NONE)
		{
			continue;
		}

		RiskStrings.AddItem(GetRiskDifficultyColouredString(GetAltRiskLevel(Risk)) $ " - " $ RiskTemplate.RiskName);
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

protected static function int SortRisksByDifficulty(CovertActionRisk a, CovertActionRisk b)
{
	if (a.Level > b.Level)
		return 1;
	else if (a.Level < b.Level)
		return -1;
	else
		return 0;
}

protected static function int GetAltRiskLevel(CovertActionRisk Risk)
{
	local XComGameState_HeadquartersXCom XComHQ;
	
	local array<int> RiskThresholds;
	local int TotalChanceToOccur, Threshold;
	local int SquadDeterrence, iThreshold;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadDeterrence = class'X2Helper_Infiltration'.static.GetSquadDeterrence(XComHQ.Squad);
	RiskThresholds = class'X2StrategyGameRulesetDataStructures'.default.RiskThresholds;
	TotalChanceToOccur = Risk.ChanceToOccur + Risk.ChanceToOccurModifier - SquadDeterrence;

	foreach RiskThresholds(Threshold, iThreshold)
	{
		if (TotalChanceToOccur <= Threshold)
		{
			break;
		}
	}

	return iThreshold;
}

// Does same thing as UIUtilities_Strategy::GetStrategyCostString but doesn't colour the text
static function String GetStrategyCostStringNoColors(StrategyCost StratCost, array<StrategyCostScalar> CostScalars, optional float DiscountPercent)
{
	local int iResource, iArtifact, Quantity;
	local String strCost, strResourceCost, strArtifactCost;
	local StrategyCost ScaledStratCost;
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	ScaledStratCost = XComHQ.GetScaledStrategyCost(StratCost, CostScalars, DiscountPercent);

	for (iArtifact = 0; iArtifact < ScaledStratCost.ArtifactCosts.Length; iArtifact++)
	{
		Quantity = ScaledStratCost.ArtifactCosts[iArtifact].Quantity;
		strArtifactCost = String(Quantity) @ class'UIUtilities_Strategy'.static.GetResourceDisplayName(ScaledStratCost.ArtifactCosts[iArtifact].ItemTemplateName, Quantity);

		if (iArtifact < ScaledStratCost.ArtifactCosts.Length - 1)
		{
			strArtifactCost $= ",";
		}
		else if (ScaledStratCost.ResourceCosts.Length > 0)
		{
			strArtifactCost $= ",";
		}

		if (strCost == "")
		{
			strCost $= strArtifactCost; 
		}
		else
		{
			strCost @= strArtifactCost;
		}
	}

	for (iResource = 0; iResource < ScaledStratCost.ResourceCosts.Length; iResource++)
	{
		Quantity = ScaledStratCost.ResourceCosts[iResource].Quantity;
		strResourceCost = String(Quantity) @ class'UIUtilities_Strategy'.static.GetResourceDisplayName(ScaledStratCost.ResourceCosts[iResource].ItemTemplateName, Quantity);

		if (iResource < ScaledStratCost.ResourceCosts.Length - 1)
		{
			strResourceCost $= ",";
		}

		if (strCost == "")
		{
			strCost $= strResourceCost;
		}
		else
		{
			strCost @= strResourceCost;
		}
	}

	return class'UIUtilities_Text'.static.FormatCommaSeparatedNouns(strCost);
}

static function CamRingView(float InterpTime)
{
	local XComGameState_FacilityXCom FacilityState;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	if (FacilityState == none) return;

	`HQPRES.CAMLookAtRoom(FacilityState.GetRoom(), InterpTime);
}