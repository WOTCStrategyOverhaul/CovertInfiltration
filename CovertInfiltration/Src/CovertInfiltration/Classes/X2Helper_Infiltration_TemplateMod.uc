//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and statusNone
//  PURPOSE: Handles various template changes. Split from DLCInfo to prevent poluting it
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration_TemplateMod extends Object config(Game);

struct TradingPostValueModifier
{
	var name ItemName;
	var int NewValue;
};

struct ItemCostOverride
{
	var name ItemName;
	var array<int> Difficulties;
	var StrategyCost NewCost;
};

var config(StrategyTuning) array<name> arrDataSetsToForceVariants;

var config(StrategyTuning) array<name> arrMakeItemBuildable;
var config(StrategyTuning) array<name> arrKillItems;
var config(StrategyTuning) array<TradingPostValueModifier> arrTradingPostModifiers;

var config(StrategyTuning) array<name> arrPrototypesToDisable;
var config(StrategyTuning) bool PrototypePrimaries;
var config(StrategyTuning) bool PrototypeSecondaries;
var config(StrategyTuning) bool PrototypeArmorsets;

var config(StrategyTuning) array<ItemCostOverride> arrItemCostOverrides;

var config(GameData) array<name> arrRemoveFactionCard;
var config(GameData) int LiveFireTrainingRanksIncrease;
var config(GameData) array<name> arrSabotagesToRemove;
var config(GameData) array<name> arrPointsOfInterestToRemove;

var localized string strSoldiers;
var localized string strReady;
var localized string strTired;
var localized string strWounded;
var localized string strInfiltrating;
var localized string strOnCovertAction;
var localized string strUnavailable;

/////////////
/// Items ///
/////////////

static function ForceDifficultyVariants()
{
	local name DataSetToPatch;
	local X2DataSet DataSetCDO;

	foreach default.arrDataSetsToForceVariants(DataSetToPatch)
	{
		DataSetCDO = X2DataSet(class'XComEngine'.static.GetClassDefaultObjectByName(DataSetToPatch));

		if (DataSetCDO == none)
		{
			`CI_Warn(DataSetToPatch @ "is not a valid X2DataSet class");
		}
		else
		{
			DataSetCDO.bShouldCreateDifficultyVariants = true;
		}
	}
}

static function MakeItemsBuildable()
{
	local X2EventListener_Infiltration_UI UIEventListener;
	local ItemAvaliableImageReplacement ImageReplacement;
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2WeaponTemplate WeaponTemplate;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;
	
	UIEventListener = X2EventListener_Infiltration_UI(class'XComEngine'.static.GetClassDefaultObject(class'X2EventListener_Infiltration_UI'));
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`CI_Log("Making items buildable");

	foreach default.arrMakeItemBuildable(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`CI_Warn(DataTemplate.Name @ "is not an X2ItemTemplate");
				continue;
			}

			// Check if we need to replace the image on "ItemAvaliable" screen
			// Do this before we nuke the schematic ref
			WeaponTemplate = X2WeaponTemplate(ItemTemplate);
			if (
				// If this item/weapon has attachments
				WeaponTemplate != none && WeaponTemplate.DefaultAttachments.Length > 0

				// And it has a creator schematic (although it should, otherwise why is it in this code at all?)
				&& ItemTemplate.CreatorTemplateName != ''

				// And we haven't added the replacement already (due to difficulty variants)
				&& UIEventListener.ItemAvaliableImageReplacementsAutomatic.Find('TargetItem', ItemTemplate.DataName) == INDEX_NONE
			)
			{
				ImageReplacement.TargetItem = ItemTemplate.DataName;
				ImageReplacement.ImageSourceItem = ItemTemplate.CreatorTemplateName;

				UIEventListener.ItemAvaliableImageReplacementsAutomatic.AddItem(ImageReplacement);
				`CI_Trace("Added image replacement for" @ ItemTemplate.DataName);
			}

			ItemTemplate.CanBeBuilt = true;
			ItemTemplate.bInfiniteItem = false;
			ItemTemplate.CreatorTemplateName = '';

			`CI_Trace(ItemTemplate.Name @ "was made single-buildable" @ `showvar(ItemTemplate.Requirements.RequiredTechs.Length));
		}
	}
}

static function ApplyTradingPostModifiers()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local TradingPostValueModifier ValueModifier;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrTradingPostModifiers(ValueModifier)
	{
		ItemTemplate = ItemTemplateManager.FindItemTemplate(ValueModifier.ItemName);

		ItemTemplate.TradingPostValue = ValueModifier.NewValue;
	}
}

static function KillItems()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`CI_Log("Killing items");

	foreach default.arrKillItems(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`CI_Warn(DataTemplate.Name @ "is not an X2ItemTemplate");
				continue;
			}

			// "Killing" inspired by LW2
			ItemTemplate.CanBeBuilt = false;
			ItemTemplate.PointsToComplete = 999999;
			ItemTemplate.Requirements.RequiredEngineeringScore = 999999;
			ItemTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
			ItemTemplate.OnBuiltFn = none;
			ItemTemplate.Cost.ResourceCosts.Length = 0;
			ItemTemplate.Cost.ArtifactCosts.Length = 0;

			`CI_Trace(ItemTemplate.Name @ "was killed");
		}
	}
}

static function PatchTLPArmorsets()
{
	PatchTLPRanger();
	PatchTLPGrenadier();
	PatchTLPSpecialist();
	PatchTLPSharpshooter();
	PatchTLPPsiOperative();
}

static function PatchTLPRanger()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('RangerKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('RangerPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('RangerPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static function PatchTLPGrenadier()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('GrenadierKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('GrenadierPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('GrenadierPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static function PatchTLPSpecialist()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SpecialistKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SpecialistPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SpecialistPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static function PatchTLPSharpshooter()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SharpshooterKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SharpshooterPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SharpshooterPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static function PatchTLPPsiOperative()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('PsiOperativeKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('PsiOperativePlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('PsiOperativePoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static function PatchTLPWeapons()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2WeaponTemplate				Template;
	local name							ItemName;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrPrototypesToDisable(ItemName)
	{
		Template = X2WeaponTemplate(TemplateManager.FindItemTemplate(name(ItemName $ '_MG')));
		if(Template != none)
		{
			Template.CreatorTemplateName = 'none';
		}
		Template = X2WeaponTemplate(TemplateManager.FindItemTemplate(name(ItemName $ '_BM')));
		if(Template != none)
		{
			Template.CreatorTemplateName = 'none';
		}
	}
}

static function PatchUtilityItems ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local ItemCostOverride ItemCostOverrideEntry;
	local int TemplateDifficulty;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`CI_Log("Overriding item costs");

	foreach default.arrItemCostOverrides(ItemCostOverrideEntry)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(ItemCostOverrideEntry.ItemName, DifficulityVariants);
		
		if (DifficulityVariants.Length == 0)
		{
			`CI_Warn(ItemCostOverrideEntry.ItemName @ "is not an X2ItemTemplate, cannot override cost");
			continue;
		}
		else if (DifficulityVariants.Length == 1 && ItemCostOverrideEntry.Difficulties.Find(3) > -1)
		{
			ItemTemplate = X2ItemTemplate(DifficulityVariants[0]);
			`CI_Trace(ItemTemplate.DataName $ " has had its cost overridden to non-legend values");
			ItemTemplate.Cost = ItemCostOverrideEntry.NewCost;
			continue;
		}

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Rookie))
			{
				TemplateDifficulty = 0; // Rookie
			}
			else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Veteran))
			{
				TemplateDifficulty = 1; // Veteran
			}
			else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Commander))
			{
				TemplateDifficulty = 2; // Commander
			}
			else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Legend))
			{
				TemplateDifficulty = 3; // Legend
			}
			else
			{
				TemplateDifficulty = -1; // Untranslatable Bitfield
			}
			
			if (ItemCostOverrideEntry.Difficulties.Find(TemplateDifficulty) > -1)
			{
				`CI_Trace(ItemTemplate.DataName $ " on difficulty " $ TemplateDifficulty $ " has had its cost overridden");
				ItemTemplate.Cost = ItemCostOverrideEntry.NewCost;
			}
		}
	}
}

////////////////
/// Research ///
////////////////

static function DisableLockAndBreakthrough()
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties('BreakthroughReuseWeaponUpgrades', DifficulityVariants);
	
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if (TechTemplate != none)
		{
			TechTemplate.bBreakthrough = false;
			TechTemplate.Requirements.RequiredScienceScore = 999999;
			TechTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
			TechTemplate.Requirements.SpecialRequirementsFn = class'X2Helper_Infiltration'.static.ReturnFalse;
		}
	}
}

static function PatchWeaponTechs()
{
	if(default.PrototypePrimaries)
	{
		AddPrototypeItem('MagnetizedWeapons', 'TLE_AssaultRifle_MG');
		AddPrototypeItem('PlasmaRifle', 'TLE_AssaultRifle_BM');
		AddPrototypeItem('MagnetizedWeapons', 'TLE_Shotgun_MG');
		AddPrototypeItem('AlloyCannon', 'TLE_Shotgun_BM');
		AddPrototypeItem('GaussWeapons', 'TLE_SniperRifle_MG');
		AddPrototypeItem('PlasmaSniper', 'TLE_SniperRifle_BM');
		AddPrototypeItem('GaussWeapons', 'TLE_Cannon_MG');
		AddPrototypeItem('HeavyPlasma', 'TLE_Cannon_BM');
	}

	if(default.PrototypeSecondaries)
	{
		AddPrototypeItem('MagnetizedWeapons', 'TLE_Pistol_MG');
		AddPrototypeItem('PlasmaRifle', 'TLE_Pistol_BM');
		AddPrototypeItem('AutopsyArchon', 'TLE_Sword_BM');
		AddPrototypeItem('AutopsyAdventStunLancer', 'TLE_Sword_MG');
	}

	if(default.PrototypeArmorsets)
	{
		AddPrototypeItem('PlatedArmor', 'TLE_PlatedArmor');
		AddPrototypeItem('PoweredArmor', 'TLE_PoweredArmor');
	}
}

static function AddPrototypeItem(name TechName, name Prototype)
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties(TechName, DifficulityVariants);
	
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if(TechTemplate != none)
		{
			TechTemplate.ItemRewards.AddItem(Prototype);
		}
	}
}

static protected function PatchGoldenPathTechs ()
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;
	local int i;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	// ResistanceCommunications
	Manager.FindDataTemplateAllDifficulties('ResistanceCommunications', DifficulityVariants);
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if (TechTemplate != none)
		{
			// Replace T2_M0_CompleteGuerillaOps with the blacksite reveal
			i = TechTemplate.Requirements.RequiredObjectives.Find('T2_M0_CompleteGuerillaOps');

			if (i != INDEX_NONE) TechTemplate.Requirements.RequiredObjectives[i] = 'T2_M0_L0_BlacksiteReveal';
			else TechTemplate.Requirements.RequiredObjectives.AddItem('T2_M0_L0_BlacksiteReveal');
		}
	}
}

////////////////
/// Missions ///
////////////////

static function PatchRetailationMissionSource()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	StratMgr.FindDataTemplateAllDifficulties('MissionSource_Retaliation', DifficultyVariants);

	foreach DifficultyVariants(DataTemplate)
	{
		MissionSource = X2MissionSourceTemplate(DataTemplate);
		MissionSource.SpawnMissionsFn = SpawnRetaliationMission;
		MissionSource.GetSitrepsFn = class'X2Helper_Infiltration'.static.GetSitrepsForAssaultMission;

		MissionSource.DifficultyValue = 3;
		MissionSource.GetMissionDifficultyFn = GetMissionDifficultyFromMonthPlusTemplate;
	}
}

static protected function SpawnRetaliationMission(XComGameState NewGameState, int MissionMonthIndex)
{
	local XComGameState_Objective ObjectiveState; // Added
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local array<XComGameState_WorldRegion> PossibleRegions;
	local float MissionDuration;
	local int iReward;
	local XComGameState_MissionCalendar CalendarState;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_HeadquartersXCom XComHQ;

	CalendarState = class'X2StrategyElement_DefaultMissionSources'.static.GetMissionCalendar(NewGameState);

	// Set Popup flag
	CalendarState.MissionPopupSources.AddItem('MissionSource_Retaliation');

	// Calculate Mission Expiration timer
	MissionDuration = float((class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultMissionSources'.default.MissionMaxDuration - class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + 1)) * 3600);

	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', CalendarState.CurrentMissionMonth[MissionMonthIndex].Missions[0].ObjectID));
	MissionState.Available = true;
	MissionState.Expiring = true;
	MissionState.TimeUntilDespawn = MissionDuration;
	MissionState.TimerStartDateTime = `STRATEGYRULES.GameTime;
	MissionState.SetProjectedExpirationDateTime(MissionState.TimerStartDateTime);
	PossibleRegions = MissionState.GetMissionSource().GetMissionRegionFn(NewGameState);
	RegionState = PossibleRegions[0];
	MissionState.Region = RegionState.GetReference();
	MissionState.Location = RegionState.GetRandomLocationInRegion();

	// Generate Rewards
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	for(iReward = 0; iReward < MissionState.Rewards.Length; iReward++)
	{
		RewardState = XComGameState_Reward(NewGameState.ModifyStateObject(class'XComGameState_Reward', MissionState.Rewards[iReward].ObjectID));
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), MissionState.Region);
	}

	// Changed: If first on non-narrative
	if(!(XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings')).bXPackNarrativeEnabled) &&
	   !CalendarState.HasCreatedMissionOfSource('MissionSource_Retaliation'))
	{
		// Change 1: force chosen even if no ResistanceOps were completed yet
		ObjectiveState = class'XComGameState_HeadquartersXCom'.static.GetObjective('XP1_M0_ActivateChosen');
		if (ObjectiveState != none && ObjectiveState.GetStateOfObjective() == eObjectiveState_InProgress)
		{
			ObjectiveState.CompleteObjective(NewGameState);
		}

		// Change 2: force the xpack retal instead of vanilla one
		// xymanek - I want the first retal not to be so penalizing (first chosen is very hard)
		MissionState.ExcludeMissionFamilies.AddItem("Terror");
	}

	// Set Mission Data
	MissionState.SetMissionData(MissionState.GetRewardType(), false, 0);

	MissionState.PickPOI(NewGameState);

	// Flag AlienHQ as having spawned a Retaliation mission
	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersAlien', AlienHQ)
	{
		break;
	}

	if (AlienHQ == none)
	{
		AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
		AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
	}

	AlienHQ.bHasSeenRetaliation = true;
	CalendarState.CreatedMissionSources.AddItem('MissionSource_Retaliation');

	// Add tactical tags to upgrade the civilian militia if the force level has been met and the tags have not been previously added
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	if (AlienHQ.ForceLevel >= 14 && XComHQ.TacticalGameplayTags.Find('UseTier3Militia') == INDEX_NONE)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.TacticalGameplayTags.AddItem('UseTier3Militia');
	}
	else if (AlienHQ.ForceLevel >= 8 && XComHQ.TacticalGameplayTags.Find('UseTier2Militia') == INDEX_NONE)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.TacticalGameplayTags.AddItem('UseTier2Militia');
	}

	`XEVENTMGR.TriggerEvent('RetaliationMissionSpawned', MissionState, MissionState, NewGameState);
}

static function PatchNewRetaliationNarrative()
{
	local X2MissionNarrativeTemplateManager TemplateManager;
	local X2MissionNarrativeTemplate Template;

	TemplateManager = class'X2MissionNarrativeTemplateManager'.static.GetMissionNarrativeTemplateManager();
	Template = TemplateManager.FindMissionNarrativeTemplate("ChosenRetaliation");

	// This is the intro VO which refers to "chosen leading the assault". We don't want that since
	// (1) it will be played before player meets the first chosen
	// (2) it plays if there is no chosen on this mission
	// (3) it plays even after all chosen are defated
	Template.NarrativeMoments[10] = "";
}

static function PatchGatecrasher()
{
	local X2StrategyElementTemplateManager StratMgr;
	local XComTacticalMissionManager MissionManager;
	local array<X2DataTemplate> DifficultyVariants;
	local X2MissionSourceTemplate MissionSource;
	local X2DataTemplate DataTemplate;
	local int i;

	// Bump alert level by one

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	StratMgr.FindDataTemplateAllDifficulties('MissionSource_Start', DifficultyVariants);

	foreach DifficultyVariants(DataTemplate)
	{
		MissionSource = X2MissionSourceTemplate(DataTemplate);
		MissionSource.DifficultyValue = 2;
	}

	// Add the new schedule

	MissionManager = `TACTICALMISSIONMGR;
	i = MissionManager.arrMissions.Find('MissionName', 'SabotageAdventMonument');

	if (i == INDEX_NONE)
	{
		`CI_Warn("Failed to find SabotageAdventMonument mission def to add new schedule");
		return;
	}

	MissionManager.arrMissions[i].MissionSchedules.AddItem('SabotageCC_D4_Standard');
}

static function PatchQuestItems ()
{
	local array<X2DataTemplate> DifficulityVariants;
	local X2ItemTemplateManager TemplateManager;
	local X2QuestItemTemplate QuestItemTemplate;
	local X2DataTemplate DataTemplate;
	local array<name> TemplateNames;
	local name TemplateName;

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	TemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		DifficulityVariants.Length = 0;
		TemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			QuestItemTemplate = X2QuestItemTemplate(DataTemplate);
			if (QuestItemTemplate == none) break; // All variants will be of same type, so just skip to next entry in TemplateNames

			if (QuestItemTemplate.DataName == 'FlightDevice')
			{
				 // This will prevent FlightDevice from being selected for missions other than the tutorial one
				QuestItemTemplate.MissionSource.AddItem('MissionSource_RecoverFlightDevice');
			}

			if (QuestItemTemplate.RewardType.Length > 0)
			{
				QuestItemTemplate.RewardType.AddItem('Reward_Rumor');
			}
		}
	}
}

static protected function int GetMissionDifficultyFromMonthPlusTemplate (XComGameState_MissionSite MissionState)
{
	local TDateTime StartDate;
	local array<int> MonthlyDifficultyAdd;
	local int Difficulty, MonthDiff;

	class'X2StrategyGameRulesetDataStructures'.static.SetTime(StartDate, 0, 0, 0, class'X2StrategyGameRulesetDataStructures'.default.START_MONTH,
		class'X2StrategyGameRulesetDataStructures'.default.START_DAY, class'X2StrategyGameRulesetDataStructures'.default.START_YEAR);

	Difficulty = MissionState.GetMissionSource().DifficultyValue;
	MonthDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMonths(class'XComGameState_GeoscapeEntity'.static.GetCurrentTime(), StartDate);
	MonthlyDifficultyAdd = class'X2StrategyElement_DefaultMissionSources'.static.GetMonthlyDifficultyAdd();

	if(MonthDiff >= MonthlyDifficultyAdd.Length)
	{
		MonthDiff = MonthlyDifficultyAdd.Length - 1;
	}

	Difficulty += MonthlyDifficultyAdd[MonthDiff];

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty,
						class'X2StrategyGameRulesetDataStructures'.default.MaxMissionDifficulty);

	return Difficulty;
}

//////////////////
/// Objectives ///
//////////////////

static function RemoveNoCovertActionNags()
{
	// Remove the warning about no covert action running since those refernce the ring

	local X2StrategyElementTemplateManager TemplateManager;
	local X2ObjectiveTemplate Template;
	local int i;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Template = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('CEN_ToDoWarnings'));

	if (Template == none)
	{
		`REDSCREEN("CI: Failed to find CEN_ToDoWarnings template - cannot remove no covert action nags");
		return;
	}

	for (i = 0; i < Template.NarrativeTriggers.Length; i++)
	{
		if (Template.NarrativeTriggers[i].NarrativeDeck == 'CentralCovertActionNags')
		{
			Template.NarrativeTriggers.Remove(i, 1);
			i--; // The array is shifted, so we need to account for that
		}
	}
}

static function PatchGoldenPath ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ObjectiveTemplate ObjectiveTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('T2_M0_L0_BlacksiteReveal'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find T2_M0_L0_BlacksiteReveal template");
	}
	else
	{
		ObjectiveTemplate.CompletionEvent = 'NonFactionMissionExit';
		ObjectiveTemplate.NextObjectives.AddItem('T2_M1_ContactBlacksiteRegion');
	}

	// Get rid of T2_M0_CompleteGuerillaOps (it's forced complete at the start of the campaign, should do nothing)
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('T2_M0_CompleteGuerillaOps'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find T2_M0_CompleteGuerillaOps template");
	}
	else
	{
		ObjectiveTemplate.CompletionEvent = '_______';
		ObjectiveTemplate.NextObjectives.Length = 0;
	}

	// Get rid of MissionExpired listener for T2_M1_L1_RevealBlacksiteObjective, it's fine to skip missions in CI
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('T2_M1_L1_RevealBlacksiteObjective'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find T2_M1_L1_RevealBlacksiteObjective template");
	}
	else
	{
		RemoveNarrativeTriggerByEvent(ObjectiveTemplate, 'MissionExpired');
		RemoveNarrativeTriggerByEvent(ObjectiveTemplate, 'WelcomeToResistanceComplete');
	}

	// Edit the associated researches
	PatchGoldenPathTechs();
}

static protected function RemoveNarrativeTriggerByEvent (X2ObjectiveTemplate ObjectiveTemplate, name EventName)
{
	local int i;

	for (i = 0; i < ObjectiveTemplate.NarrativeTriggers.Length; i++)
	{
		if (ObjectiveTemplate.NarrativeTriggers[i].TriggeringEvent == EventName)
		{
			ObjectiveTemplate.NarrativeTriggers.Remove(i, 1);
			i--;
		}
	}
}

//////////////////
/// Facilities ///
//////////////////

static function PatchResistanceRing()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate RingTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RingTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('ResistanceRing'));

	if (RingTemplate == none)
	{
		`REDSCREEN("CI: Failed to find resistance ring template");
		return;
	}

	RingTemplate.OnFacilityBuiltFn = OnResistanceRingBuilt;
	RingTemplate.GetQueueMessageFn = GetRingQueueMessage;
	RingTemplate.NeedsAttentionFn = ResistanceRingNeedsAttention;
	RingTemplate.UIFacilityClass = class'UIFacility_ResitanceRing';
}

static protected function OnResistanceRingBuilt(StateObjectReference FacilityRef)
{
	// Removed action-generating things since the ring is now about orders

	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("On Resistance Ring Built");
	FacilityState = XComGameState_FacilityXCom(NewGameState.ModifyStateObject(class'XComGameState_FacilityXCom', FacilityRef.ObjectID));

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom)
		{
			// Turn on the Faction plaque in the Ring if they have already been met
			if (!FacilityState.ActivateUpgrade(NewGameState, FactionState.GetRingPlaqueUpgradeName()))
			{
				`RedScreen("@jweinhoffer Tried to activate Faction Plaque in the Ring, but failed.");
			}
		}
	}
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static protected function string GetRingQueueMessage(StateObjectReference FacilityRef)
{
	if (ResistanceRingNeedsAttention(FacilityRef))
	{
		return class'UIUtilities_Text'.static.GetColoredText(class'UIFacility_ResitanceRing'.default.strAssingOrdersOverlay, eUIState_Bad);
	}

	return "";
}

static protected function bool ResistanceRingNeedsAttention(StateObjectReference FacilityRef)
{	
	// Highlight the ring if it was just built and the player needs to assign orders
	return !class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment;
}

static function PatchGuerillaTacticsSchool()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate GTSTemplate;
	local StaffSlotDefinition StaffSlotDef;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	GTSTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	if (GTSTemplate == none)
	{
		`REDSCREEN("CI: Failed to find GTS template");
		return;
	}
	
	GTSTemplate.IsFacilityProjectActiveFn = IsAcademyProjectActive;
	GTSTemplate.GetQueueMessageFn = GetAcademyQueueMessage;

	// Add 2nd training slot
	StaffSlotDef.StaffSlotTemplateName = 'OTSStaffSlot';
	GTSTemplate.StaffSlotDefs.AddItem(StaffSlotDef);
	
	// Remove squad size upgrades
	GTSTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIUnlock');
	GTSTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIIUnlock');

	// Add infiltration size upgrades
	GTSTemplate.SoldierUnlockTemplates.AddItem('InfiltrationSize1');
	GTSTemplate.SoldierUnlockTemplates.AddItem('InfiltrationSize2');

	// Add training target rank unlock
	GTSTemplate.SoldierUnlockTemplates.AddItem('AcademyTrainingRankUnlock');
}

static function bool IsAcademyProjectActive(StateObjectReference FacilityRef)
{
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local int idx;

	FacilityState = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));

	for (idx = 0; idx < FacilityState.StaffSlots.Length; idx++)
	{
		StaffSlot = FacilityState.GetStaffSlot(idx);
		if (StaffSlot.IsSlotFilled())
		{
			AcademyProject = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(StaffSlot.GetAssignedStaffRef());
			if (AcademyProject != none)
			{
				return true;
			}
		}
	}
	return false;
}

static function string GetAcademyQueueMessage(StateObjectReference FacilityRef)
{
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local string strSoldierClass, Message;
	local int i, iCurrentHoursRemaining, iLowestHoursRemaining;

	FacilityState = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));
	iLowestHoursRemaining = 0;

	for (i = 0; i < FacilityState.StaffSlots.Length; i++)
	{
		StaffSlot = FacilityState.GetStaffSlot(i);
		if (StaffSlot.IsSlotFilled())
		{
			AcademyProject = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(StaffSlot.GetAssignedStaffRef());
			if (AcademyProject != none)
			{
				iCurrentHoursRemaining = AcademyProject.GetCurrentNumHoursRemaining();
				if (iCurrentHoursRemaining < 0)
				{
					Message = class'UIUtilities_Text'.static.GetColoredText(class'UIFacility_Powercore'.default.m_strStalledResearch, eUIState_Warning);
					break;
				}
				else if (iLowestHoursRemaining == 0 || iCurrentHoursRemaining < iLowestHoursRemaining)
				{
					iLowestHoursRemaining = iCurrentHoursRemaining;
					strSoldierClass = StaffSlot.GetBonusDisplayString();
				}
			}
			
			Message = class'UIUtilities_Text'.static.GetTimeRemainingString(iLowestHoursRemaining);
		}
	}

	return strSoldierClass $ ":" @ Message;
}

static function PatchLivingQuarters()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate FacilityTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	FacilityTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('LivingQuarters'));
	
	// add crew size limit upgrades
	FacilityTemplate.Upgrades.AddItem('LivingQuarters_CrewSizeI');
	FacilityTemplate.Upgrades.AddItem('LivingQuarters_CrewSizeII');
}

static function PatchHangar()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate HangarTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	HangarTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('Hangar'));

	HangarTemplate.GetQueueMessageFn = GetPatchedHangarQueueMessage;
}

static function string GetPatchedHangarQueueMessage(StateObjectReference FacilityRef)
{
	local BarracksStatusReport CurrentBarracksStatus;
	local string strStatus;

	CurrentBarracksStatus = class'X2Helper_Infiltration'.static.GetBarracksStatusReport();

	strStatus = default.strSoldiers $ ": ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strReady $ ":" @ CurrentBarracksStatus.Ready, "53b45e") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strTired $ ":" @ CurrentBarracksStatus.Tired, "fdce2b") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strWounded $ ":" @ CurrentBarracksStatus.Wounded, "bf1e2e") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strInfiltrating $ ":" @ CurrentBarracksStatus.Infiltrating, "2ed1b6") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strOnCovertAction $ ":" @ CurrentBarracksStatus.OnCovertAction, "219481") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strUnavailable $ ":" @ CurrentBarracksStatus.Unavailable, "828282");

	return strStatus;
}

///////////////////
/// Staff slots ///
///////////////////

static function PatchAcademyStaffSlot ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2StaffSlotTemplate SlotTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	SlotTemplate = X2StaffSlotTemplate(TemplateManager.FindStrategyElementTemplate('OTSStaffSlot'));

	SlotTemplate.UIStaffSlotClass = class'UIFacility_AcademySlot_CI';
	SlotTemplate.FillFn = FillAcademySlot;
	SlotTemplate.EmptyStopProjectFn = EmptyStopProjectAcademySlot;
	SlotTemplate.IsUnitValidForSlotFn = IsUnitValidForAcademySlot;
	SlotTemplate.GetBonusDisplayStringFn = GetAcademySlotBonusDisplayString;
}

static protected function FillAcademySlot (XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo, optional bool bTemporary = false)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_HeadquartersXCom NewXComHQ;
	local XComGameState_HeadquartersProjectTrainAcademy ProjectState;
	local StateObjectReference EmptyRef;
	local int SquadIndex;

	local UIChooseClass ChooseClassScreen;
	local UIScreenStack ScreenStack;

	class'X2StrategyElement_DefaultStaffSlots'.static.FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);
	NewXComHQ = class'X2StrategyElement_DefaultStaffSlots'.static.GetNewXComHQState(NewGameState);
	
	ProjectState = XComGameState_HeadquartersProjectTrainAcademy(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectTrainAcademy'));
	ProjectState.SetProjectFocus(UnitInfo.UnitRef, NewGameState, NewSlotState.Facility);

	NewUnitState.SetStatus(eStatus_Training);
	NewXComHQ.Projects.AddItem(ProjectState.GetReference());

	// Remove their gear
	NewUnitState.MakeItemsAvailable(NewGameState, false);
	
	// If the unit undergoing training is in the squad, remove them
	SquadIndex = NewXComHQ.Squad.Find('ObjectID', UnitInfo.UnitRef.ObjectID);
	if (SquadIndex != INDEX_NONE) NewXComHQ.Squad[SquadIndex] = EmptyRef;

	// Assaign the new soldier class if rookie (if coming from UIChooseClass)
	ScreenStack = `SCREENSTACK;
	ChooseClassScreen = UIChooseClass(ScreenStack.GetCurrentScreen());

	if (ChooseClassScreen != none)
	{
		ProjectState.NewClassName = ChooseClassScreen.m_arrClasses[ChooseClassScreen.iSelectedItem].DataName;
	}
}

static protected function EmptyStopProjectAcademySlot (StateObjectReference SlotRef)
{
	local XComGameState_HeadquartersProjectTrainAcademy ProjectState;
	local HeadquartersOrderInputContext OrderInput;
	local XComGameState_StaffSlot SlotState;
	
	SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(SlotRef.ObjectID));
	ProjectState = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(SlotState.GetAssignedStaffRef());

	if (ProjectState != none)
	{
		// This will just cancel any project given to it, kick the unit out of the slot and set the status back to active
		// No need to write a custom implementation
		OrderInput.OrderType = eHeadquartersOrderType_CancelTrainRookie;
		OrderInput.AcquireObjectReference = ProjectState.GetReference();

		class'XComGameStateContext_HeadquartersOrder'.static.IssueHeadquartersOrder(OrderInput);
	}
	else
	{
		`RedScreen("CI: Failed to find XComGameState_HeadquartersProjectTrainAcademy for slot" @ SlotRef.ObjectID @ "with unit" @ SlotState.GetAssignedStaffRef().ObjectID);
	}
}

static protected function bool IsUnitValidForAcademySlot (XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));
	
	return Unit.CanBeStaffed()
		&& Unit.IsSoldier()
		&& Unit.IsActive()
		&& Unit.GetRank() < class'X2Helper_Infiltration'.static.GetAcademyTrainingTargetRank()
		&& !Unit.CanRankUpSoldier()
		&& SlotState.GetMyTemplate().ExcludeClasses.Find(Unit.GetSoldierClassTemplateName()) == INDEX_NONE;
}

static protected function string GetAcademySlotBonusDisplayString (XComGameState_StaffSlot SlotState, optional bool bPreview)
{
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local string Contribution;

	if (SlotState.IsSlotFilled())
	{
		AcademyProject = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(SlotState.GetAssignedStaffRef());

		if (AcademyProject.PromotingFromRookie())
		{
			Contribution = Caps(AcademyProject.GetNewClassTemplate().DisplayName);
		}
		else
		{
			Contribution = "GTS"; // TODO: loc
		}
	}

	return class'X2StrategyElement_DefaultStaffSlots'.static.GetBonusDisplayString(SlotState, "%SKILL", Contribution);
}

/////////////////////
/// Faction Cards ///
/////////////////////

static function RemoveFactionCards()
{
	local X2StrategyElementTemplateManager Manager;
	local X2StrategyCardTemplate CardTemplate;
	local name TemplateName;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	`CI_Log("Suffocating Faction Cards");

	foreach default.arrRemoveFactionCard(TemplateName)
	{
		CardTemplate = X2StrategyCardTemplate(Manager.FindStrategyElementTemplate(TemplateName));
		CardTemplate.Category = "__REMOVED__";
	}
}

static function PatchLiveFireTraining ()
{
	local X2StrategyElementTemplateManager Manager;
	local X2StrategyCardTemplate CardTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardTemplate = X2StrategyCardTemplate(Manager.FindStrategyElementTemplate('ResCard_LiveFireTraining'));

	CardTemplate.OnActivatedFn = ActivateLiveFireTraining;
	CardTemplate.OnDeactivatedFn = DeactivateLiveFireTraining;
	CardTemplate.GetMutatorValueFn = GetLiveFireTrainingRanksIncrease;
	CardTemplate.GetSummaryTextFn = class'X2StrategyElement_XpackResistanceActions'.static.GetSummaryTextReplaceInt;
}

static function int GetLiveFireTrainingRanksIncrease ()
{
	return default.LiveFireTrainingRanksIncrease;
}

static protected function ActivateLiveFireTraining(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2StrategyElement_XpackResistanceActions'.static.GetNewXComHQState(NewGameState);
	XComHQ.BonusTrainingRanks += GetLiveFireTrainingRanksIncrease();
}

static protected function DeactivateLiveFireTraining(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2StrategyElement_XpackResistanceActions'.static.GetNewXComHQState(NewGameState);
	XComHQ.BonusTrainingRanks -= GetLiveFireTrainingRanksIncrease();
}

//////////////
/// Chosen ///
//////////////

static function RemoveSabotages ()
{
	local X2StrategyElementTemplateManager Manager;
	local X2SabotageTemplate SabotageTemplate;
	local name TemplateName;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	`CI_Log("Disabling Chosen sabotages");

	foreach default.arrSabotagesToRemove(TemplateName)
	{
		SabotageTemplate = X2SabotageTemplate(Manager.FindStrategyElementTemplate(TemplateName));
		SabotageTemplate.CanActivateDelegate = class'X2Helper_Infiltration'.static.ReturnFalse;
	}
}

//////////////////////////
/// Points of Interest ///
//////////////////////////

static function RemovePointsOfInterest ()
{
	local X2StrategyElementTemplateManager Manager;
	local X2PointOfInterestTemplate POITemplate;
	local name TemplateName;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	`CI_Log("Disabling Points of Interest");

	foreach default.arrPointsOfInterestToRemove(TemplateName)
	{
		POITemplate = X2PointOfInterestTemplate(Manager.FindStrategyElementTemplate(TemplateName));

		if(POITemplate != none)
		{
			POITemplate.CanAppearFn = NeverAppear;
		}
		else
		{
			`CI_Warn(TemplateName $ " is not a POI template, cannot disable!");
		}
	}
}

static function bool NeverAppear(XComGameState_PointOfInterest POIState)
{
	return false;
}
