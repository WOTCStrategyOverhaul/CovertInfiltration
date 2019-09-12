//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and ArcaneData
//  PURPOSE: This class houses static helper methods that are used by
//           different UI classes
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIUtilities_Infiltration extends Object;

var localized string strDropUpgrade;

var localized string strStripUpgrades;
var localized string strStripUpgradesTooltip;
var localized string strStripUpgradesConfirm;
var localized string strStripUpgradesConfirmDesc;

var localized string strReinforcementsBodyWarning;
var localized string strReinforcementsBodyImminent;

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

static function UIChainsOverview (optional StateObjectReference ChainToFocus)
{
	local XComHQPresentationLayer HQPres;
	local UIChainsOverview TheScreen;

	HQPres = `HQPRES;
	if (HQPres.ScreenStack.GetFirstInstanceOf(class'UIChainsOverview') != none) return;

	TheScreen = HQPres.Spawn(class'UIChainsOverview', HQPres);
	TheScreen.ChainToFocusOnInit = ChainToFocus;
	HQPres.ScreenStack.Push(TheScreen);
}

static function UIPersonnel_PreSetList(array<StateObjectReference> UnitRefs, optional string Header)
{
	local XComHQPresentationLayer HQPres;
	local UIPersonnel_PreSetList TheScreen;

	HQPres = `HQPRES;
	TheScreen = HQPres.Spawn(class'UIPersonnel_PreSetList', HQPres);
	TheScreen.PrepareFromArray(UnitRefs);
	
	HQPres.ScreenStack.Push(TheScreen);

	if (Header != "")
	{
		TheScreen.SetScreenHeader(Header);
	}
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
	local int RiskChance;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Risks = CovertAction.Risks;
	Risks.Sort(SortRisksByDifficulty);

	foreach Risks(Risk)
	{
		RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(Risk.RiskTemplateName));
		RiskChance = Risk.ChanceToOccur + Risk.ChanceToOccurModifier;

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
	case 0: TextColor = "fdce2b";   break; // yellow
	case 1: TextColor = "e6af31";   break; // yellow-orange
	case 2: TextColor = "e69831";   break; // orange
	case 3: TextColor = "e66d31";   break; // orange-red
	case 4: TextColor = "bf1e2e";   break; // red
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

static function InfiltrationActionAvaliable(optional StateObjectReference ActionRef, optional XComGameState NewGameState)
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

static function bool SetCountdownTextAndColor(int Turns, XComLWTuple Tuple)
{
	local XGParamTag kTag;

	if (Turns > 2)
	{
		kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		kTag.StrValue0 = string(Turns);

		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Good);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(`XEXPAND.ExpandString(default.strReinforcementsBodyWarning), eUIState_Good);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Good);
	}
	else if (Turns > 1)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Warning);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(default.strReinforcementsBodyImminent, eUIState_Warning);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Warning);
	}
	else if (Turns > 0)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Bad);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsBody, eUIState_Bad);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Bad);
	}
	else
	{
		return false;
	}

	return true;
}

////////////////////////////////
/// Removing weapon upgrades ///
////////////////////////////////
// Code "inspired" by BG's RemoveWeaponUpgradesWOTC

static function RemoveWeaponUpgrade(UIArmory_WeaponUpgradeItem Slot)
{
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
}

static function OnStripWeaponUpgrades()
{
	local TDialogueBoxData DialogData;
	
	DialogData.eType = eDialog_Normal;
	DialogData.strTitle = default.strStripUpgradesConfirm;
	DialogData.strText = default.strStripUpgradesConfirmDesc;
	DialogData.fnCallback = OnStripUpgradesDialogCallback;
	DialogData.strAccept = class'UIDialogueBox'.default.m_strDefaultAcceptLabel;
	DialogData.strCancel = class'UIDialogueBox'.default.m_strDefaultCancelLabel;

	`HQPRES.UIRaiseDialog(DialogData);
}

static function OnStripUpgradesDialogCallback(Name eAction)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Item ItemState, UpgradeItem;
	local int idx;
	local array<X2WeaponUpgradeTemplate> EquippedUpgrades;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local array<StateObjectReference> Inventory;
	local StateObjectReference ItemRef;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2WeaponTemplate WeaponTemplate;

	if(eAction == 'eUIAction_Accept')
	{
		History = `XCOMHISTORY;
		UpdateState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Strip Upgrades");
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class' XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(UpdateState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

		Inventory = XComHQ.Inventory;

		foreach Inventory(ItemRef)
		{
			ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ItemRef.ObjectID));
			WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
			if (WeaponTemplate != none && ItemState.GetMyTemplate().iItemSize > 0 && 
				WeaponTemplate.InventorySlot == eInvSlot_PrimaryWeapon && 
				WeaponTemplate.NumUpgradeSlots > 0 && ItemState.HasBeenModified())
			{
				ItemState = XComGameState_Item(UpdateState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
				EquippedUpgrades = ItemState.GetMyWeaponUpgradeTemplates();
				ItemState.WipeUpgradeTemplates();
				foreach EquippedUpgrades(UpgradeTemplate)
				{
					UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(UpdateState);
					XComHQ.PutItemInInventory(UpdateState, UpgradeItem);
				}

				if (!ItemState.HasBeenModified() && !WeaponTemplate.bAlwaysUnique)
				{
					if (WeaponTemplate.bInfiniteItem)
					{
						XComHQ.Inventory.RemoveItem(ItemRef);
					}
				}
			}
		}

		Soldiers = XComHQ.GetSoldiers(true, true);

		for(idx = 0; idx < Soldiers.Length; idx++)
		{
			UnitState = XComGameState_Unit(UpdateState.ModifyStateObject(class'XComGameState_Unit', Soldiers[idx].ObjectID));
			if (UnitState != none)
			{
				ItemState = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
				WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
				if (WeaponTemplate != none && WeaponTemplate.NumUpgradeSlots > 0)
				{
					ItemState = XComGameState_Item(UpdateState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
					EquippedUpgrades = ItemState.GetMyWeaponUpgradeTemplates();
					ItemState.WipeUpgradeTemplates();
					foreach EquippedUpgrades(UpgradeTemplate)
					{
						UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(UpdateState);
						XComHQ.PutItemInInventory(UpdateState, UpgradeItem);
					}
				}
			}
		}

		`GAMERULES.SubmitGameState(UpdateState);
	}
}