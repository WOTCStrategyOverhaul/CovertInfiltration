//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Class to add abilities to be used by X2SitRep_InfiltrationSitRepEffects
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Ability_SitRepAbilitySet_CI extends X2Ability config(GameCore);

var config int FAMILIAR_TERRAIN_VALUE;
var config int PHYSICAL_CONDITIONING_VALUE;
var config int MENTAL_READINESS_VALUE;
var config int INTELLIGENCE_LEAK_DEBUFF;

var localized string FamiliarTerrainFriendlyName;
var localized string FamiliarTerrainFriendlyDesc;
var localized string PhysicalConditioningFriendlyName;
var localized string PhysicalConditioningFriendlyDesc;
var localized string MentalReadinessFriendlyName;
var localized string MentalReadinessFriendlyDesc;
var localized string IntelligenceLeakFriendlyName;
var localized string IntelligenceLeakFriendlyDesc;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(InformationWarDebuff_CI());
    Templates.AddItem(FamiliarTerrainBuff());
    Templates.AddItem(PhysicalConditioningBuff());
    Templates.AddItem(MentalReadinessBuff());
    Templates.AddItem(IntelligenceLeakDebuff());

    return Templates;
}

static function X2AbilityTemplate InformationWarDebuff_CI()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;
    local string HackDefenseDecreasedFriendlyName, HackDefenseDecreasedFriendlyDesc;

    HackDefenseDecreasedFriendlyName = class'X2StatusEffects'.default.HackDefenseDecreasedFriendlyName;
    HackDefenseDecreasedFriendlyDesc = class'X2StatusEffects'.default.HackDefenseDecreasedFriendlyDesc;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'InformationWarDebuff_CI');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_hack";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_HackDefense, -class'X2Ability_XPackAbilitySet'.default.INFORMATION_WAR_HACK_DEBUFF);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, HackDefenseDecreasedFriendlyName, HackDefenseDecreasedFriendlyDesc, Template.IconImage, true, ,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate FamiliarTerrainBuff()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'FamiliarTerrainBuff');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_runandgun";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_Mobility, default.FAMILIAR_TERRAIN_VALUE);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, default.FamiliarTerrainFriendlyName, default.FamiliarTerrainFriendlyDesc, Template.IconImage, true, ,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate PhysicalConditioningBuff()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'PhysicalConditioningBuff');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_implacable";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_Dodge, default.PHYSICAL_CONDITIONING_VALUE);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, default.PhysicalConditioningFriendlyName, default.PhysicalConditioningFriendlyDesc, Template.IconImage, true, ,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate MentalReadinessBuff()
{
    local X2AbilityTemplate Template;
    local X2Effect_MentalReadiness ReadinessEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'MentalReadinessBuff');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mentalfortress";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    ReadinessEffect = new class'X2Effect_MentalReadiness';
    ReadinessEffect.BuildPersistentEffect(1, true, false, true);
    ReadinessEffect.Hitmod = -default.MENTAL_READINESS_VALUE;
    ReadinessEffect.SetDisplayInfo(ePerkBuff_Passive, default.MentalReadinessFriendlyName, default.MentalReadinessFriendlyDesc, Template.IconImage, true, ,Template.AbilitySourceName);
    Template.AddTargetEffect(ReadinessEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate IntelligenceLeakDebuff()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'IntelligenceLeakDebuff');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_slow";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_DetectionModifier, -default.INTELLIGENCE_LEAK_DEBUFF);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, default.IntelligenceLeakFriendlyName, default.IntelligenceLeakFriendlyDesc, Template.IconImage, true, ,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}