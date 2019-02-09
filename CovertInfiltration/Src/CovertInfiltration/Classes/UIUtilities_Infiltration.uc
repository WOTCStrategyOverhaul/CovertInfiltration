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

static function array<string> GetRisksStringsFor(XComGameState_CovertAction CovertAction, bool ApplySquadDeterrence = false)
{
	local X2StrategyElementTemplateManager StratMgr;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<string> RiskStrings;
	local array<CovertActionRisk> Risks;
	local CovertActionRisk Risk;
	local X2CovertActionRiskTemplate RiskTemplate;
	local int SquadDeterrence, RiskChance;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadDeterrence = ApplySquadDeterrence ? class'X2Helper_Infiltration'.static.GetSquadDeterrence(XComHQ.Squad) : 0;

	Risks = CovertAction.Risks;
	Risks.Sort(SortRisksByDifficulty);

	foreach Risks(Risk)
	{
		RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(Risk.RiskTemplateName));
		RiskChance = Risk.ChanceToOccur + Risk.ChanceToOccurModifier - SquadDeterrence;

		if (RiskChance <= 0 || RiskTemplate == none || CovertAction.NegatedRisks.Find(Risk.RiskTemplateName) != INDEX_NONE)
		{
			continue;
		}

		RiskStrings.AddItem(GetRiskDifficultyColouredString(ConvertChanceToRiskLevel(RiskChance)) $ " - " $ RiskTemplate.RiskName);
	}

	return RiskStrings;
}

static function string GetRiskDifficultyColouredString(int RiskLevel)
{
	local string Text, TextColor;

	Text = class'X2StrategyGameRulesetDataStructures'.default.CovertActionRiskLabels[RiskLevel];
	
	switch (RiskLevel)
	{
	case 0: TextColor = "fdce2b";	break; // yellow
	case 1: TextColor = "e6af31";   break; // yellow-orange
	case 2: TextColor = "e69831";	break; // orange
	case 3: TextColor = "e66d31";   break; // orange-red
	case 4: TextColor = "bf1e2e";	break; // red
	}
	
	return ColourText(Text, TextColor);
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

protected static function int ConvertChanceToRiskLevel(int chanceToOccur)
{
	local array<int> RiskThresholds;
	local int Threshold, iRiskLevel;

	RiskThresholds = class'X2StrategyGameRulesetDataStructures'.default.RiskThresholds;

	foreach RiskThresholds(Threshold, iRiskLevel)
	{
		if (chanceToOccur <= Threshold)
		{
			break;
		}
	}
	
	return iRiskLevel;
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

static function InfiltrationActionAvaliable(StateObjectReference ActionRef, optional XComGameState NewGameState)
{
	local XComHQPresentationLayer HQPres;
	local DynamicPropertySet PropertySet;

	HQPres = `HQPRES;

	HQPres.BuildUIAlert(PropertySet, 'eAlert_CovertActions', InfiltrationActionAvaliableCB, 'NewInfiltrationPopup', "Geoscape_NewResistOpsMissions", NewGameState == none);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'ActionObjectID', ActionRef.ObjectID);
	HQPres.QueueDynamicPopup(PropertySet, NewGameState);
}

simulated protected function InfiltrationActionAvaliableCB(Name eAction, out DynamicPropertySet AlertData, optional bool bInstant = false)
{
	local XComHQPresentationLayer HQPres;
	local StateObjectReference ActionRef;

	ActionRef.ObjectID = class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(AlertData, 'ActionObjectID');
	HQPres = `HQPRES;

	if (eAction == 'eUIAction_Accept')
	{
		UICovertActionsGeoscape(ActionRef);

		if (`GAME.GetGeoscape().IsScanning())
		{
			HQPres.StrategyMap2D.ToggleScan();
		}
	}
}

static function RemoveWeaponUpgrade(UIArmory_WeaponUpgradeItem Slot)
{
	// Code "inspired" by BG's RemoveWeaponUpgradesWOTC

	local UIArmory_WeaponUpgrade UpgradeScreen;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local XComGameState_Item Weapon;

	local XComGameState_Item UpgradeItem;
	local XComGameState_Item NewWeapon;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	local XComGameState ChangeState;
	local array<X2WeaponUpgradeTemplate> EquippedUpgrades;
	local int i;

	UpgradeScreen = UIArmory_WeaponUpgrade(Slot.Screen);
	UpgradeTemplate = Slot.UpgradeTemplate;
	Weapon = Slot.Weapon;

	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("CI: Remove weapon upgrade");
	ChangeState = `XCOMHISTORY.CreateNewGameState(true, ChangeContainer);
	NewWeapon = XComGameState_Item(ChangeState.ModifyStateObject(class'XComGameState_Item', Weapon.ObjectID));
	EquippedUpgrades = NewWeapon.GetMyWeaponUpgradeTemplates();
	
	for (i = 0; i < EquippedUpgrades.Length; i++)
	{
		if (EquippedUpgrades[i].DataName == UpgradeTemplate.DataName)
		{
			EquippedUpgrades.Remove(i, 1);
			break;
		}
	}
	
	NewWeapon.WipeUpgradeTemplates();
	for (i = 0; i < EquippedUpgrades.Length; i++)
	{
		NewWeapon.ApplyWeaponUpgradeTemplate(EquippedUpgrades[i], i);
	}
	
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(ChangeState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(ChangeState);
	XComHQ.PutItemInInventory(ChangeState, UpgradeItem);
	
	`GAMERULES.SubmitGameState(ChangeState);

	UpgradeScreen.UpdateSlots();
	UpgradeScreen.WeaponStats.PopulateData(Slot.Weapon);

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Weapon_Attachement_Upgrade_Select");
}