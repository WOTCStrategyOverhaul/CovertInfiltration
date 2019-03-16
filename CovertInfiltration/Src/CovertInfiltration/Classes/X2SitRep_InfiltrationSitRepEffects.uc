class X2SitRep_InfiltrationSitRepEffects extends X2SitRepEffect config(GameData);

var config int InformationWarReduction;

var config name	VolunteerArmyCharacterTemplate;
var config name	VolunteerArmyCharacterTemplateM2;
var config name	VolunteerArmyCharacterTemplateM3;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    
    // granted abilities
    Templates.AddItem(CreateInformationWarDebuffEffect_CI());
    Templates.AddItem(CreateFamiliarTerrainEffectTemplate_CI());
    Templates.AddItem(CreatePhysicalConditioningEffectTemplate_CI());
    Templates.AddItem(CreateMentalReadinessEffectTemplate_CI());
    Templates.AddItem(CreateLightningStrikeEffect_CI());
    Templates.AddItem(CreateIntelligenceLeakDebuffEffect_CI());
    Templates.AddItem(CreateDoubleAgentAbilitiesTemplate_CI());

    // podsize & encounters
    Templates.AddItem(CreatePodSizeIncreasedByOneEffectTemplate_CI());
    Templates.AddItem(CreateGunneryEmplacementsEffectTemplate_CI());
    Templates.AddItem(CreatePhalanxEffectTemplate_CI());

    // kismet variables
    Templates.AddItem(CreateShoddyIntelEffectTemplate_CI());
    Templates.AddItem(CreateWellRehearsedEffectTemplate_CI());

    // misc
    Templates.AddItem(CreateInformationWarEffectTemplate_CI());
    
    // tactical startstate
    Templates.AddItem(CreateNoSquadConcealmentEffectTemplate_CI());
    Templates.AddItem(CreateVolunteerArmyEffectTemplate_CI());
    Templates.AddItem(CreateDoubleAgentEffectTemplate_CI());

    return Templates;
}

/////////////////////////
/// Granted Abilities ///
/////////////////////////

static function X2SitRepEffectTemplate CreateInformationWarDebuffEffect_CI()
{
   local X2SitRepEffect_GrantAbilities Template;

   `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'InformationWarDebuffEffect_CI');
   
   Template.AbilityTemplateNames.AddItem('InformationWarDebuff_CI');

   Template.Teams.AddItem(eTeam_Alien);
   Template.RequireRobotic = true;

   return Template;
}

static function X2SitRepEffectTemplate CreateFamiliarTerrainEffectTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'FamiliarTerrainEffect_CI')

    Template.AbilityTemplateNames.AddItem('FamiliarTerrainBuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreatePhysicalConditioningEffectTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'PhysicalConditioningEffect_CI')

    Template.AbilityTemplateNames.AddItem('PhysicalConditioningBuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreateMentalReadinessEffectTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'MentalReadinessEffect_CI')

    Template.AbilityTemplateNames.AddItem('MentalReadinessBuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreateLightningStrikeEffect_CI()
{
    local X2SitRepEffect_GrantAbilities Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'LightningStrikeEffect_CI')

    Template.AbilityTemplateNames.AddItem('LightningStrike');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreateIntelligenceLeakDebuffEffect_CI()
{
    local X2SitRepEffect_GrantAbilities Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'IntelligenceLeakDebuffEffect_CI')

    Template.AbilityTemplateNames.AddItem('IntelligenceLeakDebuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreateDoubleAgentAbilitiesTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'DoubleAgentAbilities_CI')

    Template.Teams.AddItem(eTeam_XCom);
    Template.GrantToSoldiers = false;
    Template.AbilityTemplateNames.AddItem( 'Evac' );
	Template.AbilityTemplateNames.AddItem('PlaceEvacZone');
	Template.AbilityTemplateNames.AddItem('LiftOffAvenger');

	Template.AbilityTemplateNames.AddItem('Loot');
	Template.AbilityTemplateNames.AddItem('CarryUnit');
	Template.AbilityTemplateNames.AddItem('PutDownUnit');

	Template.AbilityTemplateNames.AddItem('Interact_PlantBomb');
	Template.AbilityTemplateNames.AddItem('Interact_TakeVial');
	Template.AbilityTemplateNames.AddItem('Interact_StasisTube');
	Template.AbilityTemplateNames.AddItem('Interact_MarkSupplyCrate');
	Template.AbilityTemplateNames.AddItem('Interact_ActivateAscensionGate');

	Template.AbilityTemplateNames.AddItem('DisableConsumeAllPoints');

	Template.AbilityTemplateNames.AddItem('Revive');
	Template.AbilityTemplateNames.AddItem('Panicked');
	Template.AbilityTemplateNames.AddItem('Berserk');
	Template.AbilityTemplateNames.AddItem('Obsessed');
	Template.AbilityTemplateNames.AddItem('Shattered');

    return Template;
}

////////////////////////////
/// Podsize & Encounters ///
////////////////////////////

static function X2SitRepEffectTemplate CreatePodSizeIncreasedByOneEffectTemplate_CI()
{
	local X2SitRepEffect_ModifyPodSize Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyPodSize', Template, 'PodSizeIncreaseByOneEffect_CI');

	Template.PodSizeDelta = 1;

	return Template;
}

static function X2SitRepEffectTemplate CreateGunneryEmplacementsEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyTurretCount Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTurretCount', Template, 'GunneryEmplacementsEffect_CI');

    Template.MinCount = 2;
    Template.MaxCount = 2;
    Template.CountDelta = 2;
    Template.ZoneWidthDelta = 16;
    Template.ZoneOffsetDelta = -16;

    return Template;
}

static function X2SitRepEffectTemplate CreatePhalanxEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyDefaultEncounterLists Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyDefaultEncounterLists', Template, 'PhalanxEffect_CI');
    Template.DefaultLeaderListOverride = 'PhalanxLeaders';

    return Template;
}

////////////////////////
/// Kismet Variables ///
////////////////////////

static function X2SitRepEffectTemplate CreateShoddyIntelEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyKismetVariable Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyKismetVariable', Template, 'ShoddyIntelEffect_CI');

	Template.VariableNames.AddItem("Timer.DefaultTurns");
	Template.VariableNames.AddItem("Timer.LengthDelta");
	Template.VariableNames.AddItem("Mission.TimerLengthDelta");
	Template.ValueAdjustment = -1;

	return Template;
}

static function X2SitRepEffectTemplate CreateWellRehearsedEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyKismetVariable Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyKismetVariable', Template, 'WellRehearsedEffect_CI');

	Template.VariableNames.AddItem("Timer.DefaultTurns");
	Template.VariableNames.AddItem("Timer.LengthDelta");
	Template.VariableNames.AddItem("Mission.TimerLengthDelta");
	Template.ValueAdjustment = 1;

	return Template;
}

////////////
/// Misc ///
////////////

static function X2SitRepEffectTemplate CreateInformationWarEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyHackDefenses Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyHackDefenses', Template, 'InformationWarEffect_CI');
    Template.DefenseDeltaFn = InformationWarModFunction;

    return Template;
}

static function InformationWarModFunction(out int ModValue)
{
    ModValue += default.InformationWarReduction;
}

///////////////////////////
/// Tactical StartState ///
///////////////////////////

static function X2SitRepEffectTemplate CreateNoSquadConcealmentEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyTacticalStartState Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'NoSquadConcealmentEffect_CI');

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

static function X2SitRepEffectTemplate CreateVolunteerArmyEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyTacticalStartState Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'VolunteerArmyEffect_CI');

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
        VolunteerCharacterTemplate = default.VolunteerArmyCharacterTemplateM3;
    }
    else if (XComHQ.IsTechResearched('MagnetizedWeapons'))
    {
        VolunteerCharacterTemplate = default.VolunteerArmyCharacterTemplateM2;
    }
    else
    {
        VolunteerCharacterTemplate = default.VolunteerArmyCharacterTemplate;
    }

    XComTeamSoldierSpawnTacticalStartModifier(VolunteerCharacterTemplate, StartState);
}

static function X2SitRepEffectTemplate CreateDoubleAgentEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyTacticalStartState Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'DoubleAgentEffect_CI');

    Template.ModifyTacticalStartStateFn = DoubleAgentTacticalStartModifier;
    
    return Template;
}

static function DoubleAgentTacticalStartModifier(XComGameState StartState)
{
    local array<DoubleAgentData> DoubleAgentPotentials;
    local XComGameState_BattleData BattleData;
	local XComGameState_HeadquartersXCom XComHQ;
	local DoubleAgentData DoubleAgent;
	local int CurrentForceLevel, Rand;

    DoubleAgentPotentials = class'X2StrategyElement_XpackResistanceActions'.default.DoubleAgentCharacterTemplates;

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
    {
		break;
    }
    `assert( XComHQ != none );

	foreach StartState.IterateByClassType(class'XComGameState_BattleData', BattleData)
	{
		break;
	}
	`assert( BattleData != none );

	CurrentForceLevel = BattleData.GetForceLevel();
	foreach DoubleAgentPotentials(DoubleAgent)
	{
		if ((CurrentForceLevel < DoubleAgent.MinForceLevel) || (CurrentForceLevel > DoubleAgent.MaxForceLevel))
		{
			DoubleAgentPotentials.RemoveItem(DoubleAgent);
		}
	}

	if (DoubleAgentPotentials.Length > 0)
	{
		Rand = `SYNC_RAND_STATIC(DoubleAgentPotentials.Length);
		XComTeamSoldierSpawnTacticalStartModifier(DoubleAgentPotentials[Rand].TemplateName, StartState);
	}
	else
	{
		DoubleAgentPotentials = class'X2StrategyElement_XpackResistanceActions'.default.DoubleAgentCharacterTemplates;
        Rand = `SYNC_RAND_STATIC(DoubleAgentPotentials.Length);
		XComTeamSoldierSpawnTacticalStartModifier(DoubleAgentPotentials[Rand].TemplateName, StartState);
	}
}

static function XComTeamSoldierSpawnTacticalStartModifier(name CharTemplateName, XComGameState StartState)
{
	local X2CharacterTemplate Template;
	local XComGameState_Unit SoldierState;
	local XGCharacterGenerator CharacterGenerator;
	local XComGameState_Player PlayerState;
	local TSoldier Soldier;
	local XComGameState_HeadquartersXCom XComHQ;

	// generate a basic resistance soldier unit
	Template = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(CharTemplateName);
	`assert(Template != none);

	SoldierState = Template.CreateInstanceFromTemplate(StartState);
	SoldierState.bMissionProvided = true;

	if (Template.bAppearanceDefinesPawn)
	{
		CharacterGenerator = `XCOMGRI.Spawn(Template.CharacterGeneratorClass);
		`assert(CharacterGenerator != none);

		Soldier = CharacterGenerator.CreateTSoldier();
		SoldierState.SetTAppearance(Soldier.kAppearance);
		SoldierState.SetCharacterName(Soldier.strFirstName, Soldier.strLastName, Soldier.strNickName);
		SoldierState.SetCountry(Soldier.nmCountry);
	}

	// assign the player to him
	foreach StartState.IterateByClassType(class'XComGameState_Player', PlayerState)
	{
		if(PlayerState.GetTeam() == eTeam_XCom)
		{
			SoldierState.SetControllingPlayer(PlayerState.GetReference());
			break;
		}
	}

	// give him a loadout
	SoldierState.ApplyInventoryLoadout(StartState);

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
    {
		break;
    }

	XComHQ.Squad.AddItem(SoldierState.GetReference());
	XComHQ.AllSquads[0].SquadMembers.AddItem(SoldierState.GetReference());
}