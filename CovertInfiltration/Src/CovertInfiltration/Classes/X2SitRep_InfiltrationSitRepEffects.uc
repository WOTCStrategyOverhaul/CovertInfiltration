//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone and Xymanek
//  PURPOSE: Class to add custom SitReps Templates
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2SitRep_InfiltrationSitRepEffects extends X2SitRepEffect config(GameData);

struct CharacterAppearanceDensity
{
	var name ID;
	var int Count;
};

var config bool EmplaceFollower_AllowEncountersWithFollowerOverride;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	// granted abilities
	Templates.AddItem(CreateUpdatedFirewallsBuffEffect());
	Templates.AddItem(CreateMentalReadinessEffectTemplate());
	Templates.AddItem(CreateLightningStrikeEffect());
	Templates.AddItem(CreateIntelligenceLeakDebuffEffect());
	Templates.AddItem(CreateTacticalAnalysisAbilityTemplate());
	Templates.AddItem(CreateFoxholesBuffEffect());
	Templates.AddItem(CreateOpportuneMoment1Effect());
	Templates.AddItem(CreateOpportuneMoment2Effect());

	// podsize & encounters
	Templates.AddItem(CreateGunneryEmplacementsEffectTemplate());
	Templates.AddItem(CreatePhalanxEffectTemplate_CI());
	Templates.AddItem(CreateCongregationEffectTemplate());

	// kismet variables
	Templates.AddItem(CreateShoddyIntelEffectTemplate());
	Templates.AddItem(CreateWellRehearsedEffectTemplate());
	
	// tactical startstate
	Templates.AddItem(CreateNoSquadConcealmentEffectTemplate());
	Templates.AddItem(CreateVolunteerArmyEffectTemplate());
	Templates.AddItem(CreateTacticalAnalysisEffectTemplate());
	
	// misc
	Templates.AddItem(CreateUpdatedFirewallsEffect());
	Templates.AddItem(CreatePodSizeIncreaseByOneEffectTemplate());

	return Templates;
}

/////////////////////////
/// Granted Abilities ///
/////////////////////////

static function X2SitRepEffectTemplate CreateUpdatedFirewallsBuffEffect()
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'UpdatedFirewallsBuffEffect');
	
	Template.AbilityTemplateNames.AddItem('UpdatedFirewallsBuff');

	Template.Teams.AddItem(eTeam_Alien);
	Template.RequireRobotic = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateMentalReadinessEffectTemplate()
{
	local X2SitRepEffect_GrantAbilities Template;
	
	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'MentalReadinessEffect')

	Template.AbilityTemplateNames.AddItem('MentalReadinessBuff');
	Template.GrantToSoldiers = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateLightningStrikeEffect()
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'LightningStrikeEffect')

	Template.AbilityTemplateNames.AddItem('LightningStrike');
	Template.GrantToSoldiers = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateIntelligenceLeakDebuffEffect()
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'IntelligenceLeakDebuffEffect')

	Template.AbilityTemplateNames.AddItem('IntelligenceLeakDebuff');
	Template.GrantToSoldiers = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateTacticalAnalysisAbilityTemplate()
{
	local X2SitRepEffect_GrantAbilities  Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'TacticalAnalysisAbility');

	Template.AbilityTemplateNames.AddItem('TacticalAnalysis');

	return Template;
}

static function X2SitRepEffectTemplate CreateFoxholesBuffEffect()
{
	local X2SitRepEffect_GrantAbilities  Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'FoxholesBuffEffect');

	Template.AbilityTemplateNames.AddItem('FoxholesBuff');
	Template.GrantToSoldiers = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateOpportuneMoment1Effect()
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'OpportuneMoment1Effect');

	Template.AbilityTemplateNames.AddItem('OpportuneMoment1');
	Template.GrantToSoldiers = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateOpportuneMoment2Effect()
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'OpportuneMoment2Effect');

	Template.AbilityTemplateNames.AddItem('OpportuneMoment2');
	Template.GrantToSoldiers = true;

	return Template;
}

//////////////////
/// Encounters ///
//////////////////

static function X2SitRepEffectTemplate CreateGunneryEmplacementsEffectTemplate()
{
	local X2SitRepEffect_ModifyTurretCount Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTurretCount', Template, 'GunneryEmplacementsEffect');

	Template.CountDelta = 2;
	Template.ZoneWidthDelta = 999;
	//Template.ZoneOffsetDelta = -16;

	return Template;
}

static function X2SitRepEffectTemplate CreatePhalanxEffectTemplate_CI()
{
	local X2SitRepEffect_ModifyEncounter Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyEncounter', Template, 'PhalanxEffect_CI');

	Template.ProcessEncounter = PhalanxProcessEncounter;
	Template.bApplyToPreplaced = true;

	return Template;
}

static function X2SitRepEffectTemplate CreateCongregationEffectTemplate()
{
	local X2SitRepEffect_ModifyEncounter Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyEncounter', Template, 'CongregationEffect');

	Template.ProcessEncounter = CongregationProcessEncounter;
	Template.bApplyToPreplaced = true;

	return Template;
}

static protected function PhalanxProcessEncounter (
	out name EncounterName, out PodSpawnInfo Encounter,
	int ForceLevel, int AlertLevel,
	XComGameState_MissionSite MissionState, XComGameState_BaseObject ReinforcementState
)
{
	EmplaceFollowerIntoEncounter(
		'AdvShieldBearerM2', // TODO: Decide based on FL
		EncounterName, Encounter,
		ForceLevel, AlertLevel,
		MissionState, ReinforcementState
	);
}

static protected function CongregationProcessEncounter (
	out name EncounterName, out PodSpawnInfo Encounter,
	int ForceLevel, int AlertLevel,
	XComGameState_MissionSite MissionState, XComGameState_BaseObject ReinforcementState
)
{
	EmplaceFollowerIntoEncounter(
		'AdvPriestM1', // TODO: Decide based on FL
		EncounterName, Encounter,
		ForceLevel, AlertLevel,
		MissionState, ReinforcementState
	);
}

static protected function EmplaceFollowerIntoEncounter (
	name UnitToEmplace,
	out name EncounterName, out PodSpawnInfo Encounter,
	int ForceLevel, int AlertLevel,
	XComGameState_MissionSite MissionState, XComGameState_BaseObject ReinforcementState
)
{
	local array<CharacterAppearanceDensity> CharacterTemplateCounts, CharacterGroupCounts;
	local CharacterAppearanceDensity CharacterAppearanceDensityPair;
	local X2CharacterTemplateManager CharacterTemplateManager;
	local X2CharacterTemplate CharacterTemplate;
	local int i, NumClosedSlots, NumOpenSlots;
	local ConfigurableEncounter EncounterDef;
	local name CharacterName;

	// Do not edit the pod if the unit that we want it to have already is included
	if (Encounter.SelectedCharacterTemplateNames.Find(UnitToEmplace) != INDEX_NONE) return;

	// Do not edit non-alien pods
    if (Encounter.Team != eTeam_Alien) return;

	// Find the encounter's config definition
	i = class'XComTacticalMissionManager'.default.ConfigurableEncounters.Find('EncounterID', EncounterName);
	if (i != INDEX_NONE) EncounterDef = class'XComTacticalMissionManager'.default.ConfigurableEncounters[i];
	else
	{
		`CI_Warn("EmplaceFollowerIntoEncounter got EncounterName that doesn't exist - aborting");
		return;
	}

	// Skip encounters with follower override if we aren't allowed to touch those
	if (EncounterDef.EncounterFollowerSpawnList != '' && !default.EmplaceFollower_AllowEncountersWithFollowerOverride) return;

	// Get number of slots that cannot accept random followers
	// Note that the first slot is always the pod leader, even if not forced
	NumClosedSlots = Max(EncounterDef.ForceSpawnTemplateNames.Length, 1);

	// Get the number of slots that are open to any followers
	NumOpenSlots = Encounter.SelectedCharacterTemplateNames.Length - NumClosedSlots;

	// If there are no slots that accept random followers, do nothing
	if (NumOpenSlots < 1) return;

	// All checks passed, we are ready to edit the slot
	// Note that we will try replace the most occuring character to ensure pod varienty

	CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach Encounter.SelectedCharacterTemplateNames(CharacterName)
	{
		CharacterTemplate = CharacterTemplateManager.FindCharacterTemplate(CharacterName);

		i = CharacterTemplateCounts.Find('ID', CharacterTemplate.DataName);
		if (i != INDEX_NONE) CharacterTemplateCounts[i].Count++;
		else 
		{
			CharacterAppearanceDensityPair.ID = CharacterTemplate.DataName;
			CharacterAppearanceDensityPair.Count = 1;

			CharacterTemplateCounts.AddItem(CharacterAppearanceDensityPair);
		}

		i = CharacterGroupCounts.Find('ID', CharacterTemplate.CharacterGroupName);
		if (i != INDEX_NONE) CharacterGroupCounts[i].Count++;
		else 
		{
			CharacterAppearanceDensityPair.ID = CharacterTemplate.CharacterGroupName;
			CharacterAppearanceDensityPair.Count = 1;

			CharacterGroupCounts.AddItem(CharacterAppearanceDensityPair);
		}
	}

	// Attempt to replace based on character name
	CharacterTemplateCounts.Sort(SortCharacterAppearanceDensity);
	foreach CharacterTemplateCounts(CharacterAppearanceDensityPair)
	{
		// Skip the characters which show up once, try to replace by group instead
		// (since the CharacterTemplateCounts array is sorted, all next iteractions will have Count == 1 as well)
		if (CharacterAppearanceDensityPair.Count == 1) break;

		for (i = NumClosedSlots - 1; i < Encounter.SelectedCharacterTemplateNames.Length; i++)
		{
			if (Encounter.SelectedCharacterTemplateNames[i] == CharacterAppearanceDensityPair.ID)
			{
				Encounter.SelectedCharacterTemplateNames[i] = UnitToEmplace;
				return;
			}
		}
	}

	// Attempt to replace based on character group
	CharacterGroupCounts.Sort(SortCharacterAppearanceDensity);
	foreach CharacterGroupCounts(CharacterAppearanceDensityPair)
	{
		// Skip the groups which show up once, fallback to default instead
		// (since the CharacterTemplateCounts array is sorted, all next iteractions will have Count == 1 as well)
		if (CharacterAppearanceDensityPair.Count == 1) break;

		for (i = NumClosedSlots - 1; i < Encounter.SelectedCharacterTemplateNames.Length; i++)
		{
			CharacterTemplate = CharacterTemplateManager.FindCharacterTemplate(Encounter.SelectedCharacterTemplateNames[i]);

			if (CharacterTemplate.CharacterGroupName == CharacterAppearanceDensityPair.ID)
			{
				Encounter.SelectedCharacterTemplateNames[i] = UnitToEmplace;
				return;
			}
		}
	}

	// Failed to diversify the pod, just replace the last unit
	Encounter.SelectedCharacterTemplateNames[Encounter.SelectedCharacterTemplateNames.Length - 1] = UnitToEmplace;
}

// TODO: is this in correct direction? We want the higher to be first
static protected function int SortCharacterAppearanceDensity (CharacterAppearanceDensity A, CharacterAppearanceDensity B)
{
	if (A.Count == B.Count) return 0;

	return A.Count < B.Count ? 1 : -1;
}

////////////////////////
/// Kismet Variables ///
////////////////////////

static function X2SitRepEffectTemplate CreateShoddyIntelEffectTemplate()
{
	local X2SitRepEffect_ModifyKismetVariable Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyKismetVariable', Template, 'ShoddyIntelEffect');

	Template.VariableNames.AddItem("Timer.DefaultTurns");
	Template.VariableNames.AddItem("Timer.LengthDelta");
	Template.VariableNames.AddItem("Mission.TimerLengthDelta");
	Template.ValueAdjustment = -1;

	return Template;
}

static function X2SitRepEffectTemplate CreateWellRehearsedEffectTemplate()
{
	local X2SitRepEffect_ModifyKismetVariable Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyKismetVariable', Template, 'WellRehearsedEffect');

	Template.VariableNames.AddItem("Timer.DefaultTurns");
	Template.VariableNames.AddItem("Timer.LengthDelta");
	Template.VariableNames.AddItem("Mission.TimerLengthDelta");
	Template.ValueAdjustment = 1;

	return Template;
}

///////////////////////////
/// Tactical StartState ///
///////////////////////////

static function X2SitRepEffectTemplate CreateNoSquadConcealmentEffectTemplate()
{
	local X2SitRepEffect_ModifyTacticalStartState Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'NoSquadConcealmentEffect');

	Template.ModifyTacticalStartStateFn = RemoveSquadConcealment;

	return Template;
}

static function RemoveSquadConcealment(XComGameSTate StartState)
{
	local XComGameState_BattleData BattleData;
	
	foreach StartState.IterateByClassType(class'XComGameState_BattleData', BattleData)
	{
		break;
	}
	`assert(BattleData != none);

	BattleData.bForceNoSquadConcealment = true;
}

static function X2SitRepEffectTemplate CreateVolunteerArmyEffectTemplate()
{
	local X2SitRepEffect_ModifyTacticalStartState Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'VolunteerArmyEffect');

	Template.ModifyTacticalStartStateFn = VolunteerArmyTacticalStartModifier;
	
	return Template;
}

static function VolunteerArmyTacticalStartModifier(XComGameState StartState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local name VolunteerCharacterTemplate;

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}
	`assert(XComHQ != none);

	if (XComHQ.IsTechResearched('PlasmaRifle'))
	{
		VolunteerCharacterTemplate = class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplateM3;
	}
	else if (XComHQ.IsTechResearched('MagnetizedWeapons'))
	{
		VolunteerCharacterTemplate = class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplateM2;
	}
	else
	{
		VolunteerCharacterTemplate = class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplate;
	}

	XComTeamSoldierSpawnTacticalStartModifier(VolunteerCharacterTemplate, StartState);
}

static function XComTeamSoldierSpawnTacticalStartModifier(name CharTemplateName, XComGameState StartState)
{
	local X2CharacterTemplate CharacterTemplate;
	local array<X2AbilityTemplate> Abilities;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Unit SoldierState;
	local XGCharacterGenerator CharacterGenerator;
	local XComGameState_Player PlayerState;
	local TSoldier Soldier;
	local XComGameState_HeadquartersXCom XComHQ;

	// generate a basic resistance soldier unit
	CharacterTemplate = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(CharTemplateName);
	`assert(CharacterTemplate != none);

	SoldierState = CharacterTemplate.CreateInstanceFromTemplate(StartState);
	SoldierState.bMissionProvided = true;
	Abilities = GetTempSoldierAbilities();

	if (CharacterTemplate.bAppearanceDefinesPawn)
	{
		CharacterGenerator = `XCOMGRI.Spawn(CharacterTemplate.CharacterGeneratorClass);
		`assert(CharacterGenerator != none);

		Soldier = CharacterGenerator.CreateTSoldier();
		SoldierState.SetTAppearance(Soldier.kAppearance);
		SoldierState.SetCharacterName(Soldier.strFirstName, Soldier.strLastName, Soldier.strNickName);
		SoldierState.SetCountry(Soldier.nmCountry);
	}
	
	foreach StartState.IterateByClassType(class'XComGameState_Player', PlayerState)
	{
		if(PlayerState.GetTeam() == eTeam_XCom)
		{
			SoldierState.SetControllingPlayer(PlayerState.GetReference());
			break;
		}
	}

	SoldierState.ApplyInventoryLoadout(StartState);

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (!SoldierState.IsSoldier())
	{
		foreach Abilities(AbilityTemplate)
		{
			class'X2TacticalGameRuleset'.static.InitAbilityForUnit(AbilityTemplate, SoldierState, StartState);			
		}
	}

	XComHQ.Squad.AddItem(SoldierState.GetReference());
	XComHQ.AllSquads[0].SquadMembers.AddItem(SoldierState.GetReference());
}

static function array<X2AbilityTemplate> GetTempSoldierAbilities()
{
	local array<X2AbilityTemplate> Templates;
	local X2AbilityTemplateManager Manager;

	Manager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Templates.AddItem(Manager.FindAbilityTemplate('Evac'));
	Templates.AddItem(Manager.FindAbilityTemplate('PlaceEvacZone'));
	Templates.AddItem(Manager.FindAbilityTemplate('LiftOffAvenger'));

	Templates.AddItem(Manager.FindAbilityTemplate('Loot'));
	Templates.AddItem(Manager.FindAbilityTemplate('CarryUnit'));
	Templates.AddItem(Manager.FindAbilityTemplate('PutDownUnit'));

	Templates.AddItem(Manager.FindAbilityTemplate('Interact_PlantBomb'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_TakeVial'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_StasisTube'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_MarkSupplyCrate'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_ActivateAscensionGate'));

	Templates.AddItem(Manager.FindAbilityTemplate('DisableConsumeAllPoints'));

	Templates.AddItem(Manager.FindAbilityTemplate('Revive'));
	Templates.AddItem(Manager.FindAbilityTemplate('Panicked'));
	Templates.AddItem(Manager.FindAbilityTemplate('Berserk'));
	Templates.AddItem(Manager.FindAbilityTemplate('Obsessed'));
	Templates.AddItem(Manager.FindAbilityTemplate('Shattered'));

	return Templates;
}

static function X2SitRepEffectTemplate CreateTacticalAnalysisEffectTemplate()
{
	local X2SitRepEffect_ModifyTacticalStartState Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'TacticalAnalysisEffect');

	Template.ModifyTacticalStartStateFn = TacticalAnalysisStartModifier;

	return Template;
}

static function TacticalAnalysisStartModifier(XComGameState StartState)
{
	local XComGameState_Player Player;
	local Object PlayerObject;

	foreach StartState.IterateByClassType(class'XComGameState_Player', Player)
	{
		if (Player.GetTeam() == eTeam_XCom)
		{
			break;
		}
	}

	PlayerObject = Player;

	`XEVENTMGR.RegisterForEvent(PlayerObject, 'ScamperEnd', Player.TacticalAnalysisScamperResponse, ELD_OnStateSubmitted);
}

////////////
/// Misc ///
////////////

static function X2SitRepEffectTemplate CreateUpdatedFirewallsEffect()
{
	local X2SitRepEffect_ModifyHackDefenses Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyHackDefenses', Template, 'UpdatedFirewallsEffect');

	Template.DefenseDeltaFn = UpdatedFirewallsModFunction;

	return Template;
}

static function UpdatedFirewallsModFunction(out int ModValue)
{
	ModValue += class'X2Ability_SitRepAbilitySet_CI'.default.UPDATED_FIREWALLS_HACK_DEFENSE_BONUS;
}

static function X2SitRepEffectTemplate CreatePodSizeIncreaseByOneEffectTemplate()
{
	local X2SitRepEffect_ModifyPodSize Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyPodSize', Template, 'PodSizeIncreaseByOneEffect');

	Template.PodSizeDelta = 1;

	return Template;
}
