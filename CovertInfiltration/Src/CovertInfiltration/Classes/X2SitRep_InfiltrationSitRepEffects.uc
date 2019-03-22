//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Class to add custom SitReps Templates
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2SitRep_InfiltrationSitRepEffects extends X2SitRepEffect;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    
    // granted abilities
    Templates.AddItem(CreateInformationWarDebuffEffect_CI());
    Templates.AddItem(CreateFamiliarTerrainEffectTemplate());
    Templates.AddItem(CreatePhysicalConditioningEffectTemplate());
    Templates.AddItem(CreateMentalReadinessEffectTemplate());
    Templates.AddItem(CreateLightningStrikeEffect());
    Templates.AddItem(CreateIntelligenceLeakDebuffEffect());
    Templates.AddItem(CreateTacticalAnalysisAbilityTemplate());

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
    Templates.AddItem(CreateDoubleAgentEffectTemplate());
    Templates.AddItem(CreateTacticalAnalysisEffectTemplate());

    // misc
    Templates.AddItem(CreateInformationWarEffectTemplate_CI());

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

static function X2SitRepEffectTemplate CreateFamiliarTerrainEffectTemplate()
{
    local X2SitRepEffect_GrantAbilities Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'FamiliarTerrainEffect')

    Template.AbilityTemplateNames.AddItem('FamiliarTerrainBuff');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreatePhysicalConditioningEffectTemplate()
{
    local X2SitRepEffect_GrantAbilities Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, 'PhysicalConditioningEffect')

    Template.AbilityTemplateNames.AddItem('PhysicalConditioningBuff');
    Template.GrantToSoldiers = true;

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

//////////////////
/// Encounters ///
//////////////////

static function X2SitRepEffectTemplate CreateGunneryEmplacementsEffectTemplate()
{
    local X2SitRepEffect_ModifyTurretCount Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTurretCount', Template, 'GunneryEmplacementsEffect');

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

static function X2SitRepEffectTemplate CreateCongregationEffectTemplate()
{
    local X2SitRepEffect_ModifyDefaultEncounterLists Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyDefaultEncounterLists', Template, 'CongregationEffect');

    Template.DefaultLeaderListOverride = 'CongregationLeaders';

    return Template;
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

static function X2SitRepEffectTemplate CreateDoubleAgentEffectTemplate()
{
    local X2SitRepEffect_ModifyTacticalStartState Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'DoubleAgentEffect');

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

static function X2SitRepEffectTemplate CreateInformationWarEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyHackDefenses Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyHackDefenses', Template, 'InformationWarEffect_CI');

    Template.DefenseDeltaFn = InformationWarModFunction;

    return Template;
}

static function InformationWarModFunction(out int ModValue)
{
    ModValue += `ScaleStrategyArrayInt(class'X2StrategyElement_XpackResistanceActions'.default.InformationWarReduction);
}