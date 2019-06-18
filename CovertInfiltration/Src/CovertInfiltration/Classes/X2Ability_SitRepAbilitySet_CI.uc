//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone and Xymanek
//  PURPOSE: Class to add abilities to be used by X2SitRep_InfiltrationSitRepEffects
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Ability_SitRepAbilitySet_CI extends X2Ability config(GameCore);

var config int UPDATED_FIREWALLS_HACK_DEFENSE_BONUS;
var config int MENTAL_READINESS_VALUE;
var config int INTELLIGENCE_LEAK_DEBUFF;

var localized string MentalReadinessFriendlyName;
var localized string MentalReadinessFriendlyDesc;
var localized string IntelligenceLeakFriendlyName;
var localized string IntelligenceLeakFriendlyDesc;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(UpdatedFirewallsBuff());
    Templates.AddItem(MentalReadinessBuff());
    Templates.AddItem(IntelligenceLeakDebuff());
    Templates.AddItem(FoxholesBuff());

    return Templates;
}

static function X2AbilityTemplate UpdatedFirewallsBuff()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;
    local string FriendlyName, FriendlyDesc;

    FriendlyName = class'X2StatusEffects'.default.HackDefenseIncreasedFriendlyName;
    FriendlyDesc = class'X2StatusEffects'.default.HackDefenseIncreasedFriendlyDesc;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'UpdatedFirewallsBuff');
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
    StatEffect.AddPersistentStatChange(eStat_HackDefense, default.UPDATED_FIREWALLS_HACK_DEFENSE_BONUS);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, FriendlyName, FriendlyDesc, Template.IconImage, true,, Template.AbilitySourceName);
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
	ReadinessEffect.AddPersistentStatChange(eStat_CritChance, default.MENTAL_READINESS_VALUE);
	ReadinessEffect.AddPersistentStatChange(eStat_Dodge, default.MENTAL_READINESS_VALUE);
	ReadinessEffect.AddPersistentStatChange(eStat_Hacking, default.MENTAL_READINESS_VALUE);
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

static function X2AbilityTemplate FoxholesBuff()
{
	local XMBEffect_ConditionalStatChange MobilityEffect;
	local X2Effect_CoverHitModifier HitModEffect;
	local XMBCondition_CoverType CoverCondition;
    local X2AbilityTemplate Template;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'FoxholesBuff');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_slow";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	HitModEffect = new class'X2Effect_CoverHitModifier';
    HitModEffect.BuildPersistentEffect(1, true, false, true);
    HitModEffect.SetDisplayInfo(ePerkBuff_Passive, "Foxholes", "+2 mobility and +5 defense while in low cover", Template.IconImage, true,, Template.AbilitySourceName);
	HitModEffect.RequiredCoverType = CT_MidLevel;
	HitModEffect.HitModValue = -5;
    Template.AddTargetEffect(HitModEffect);

	CoverCondition = new class'XMBCondition_CoverType';
	CoverCondition.AllowedCoverTypes.AddItem(CT_MidLevel);
	CoverCondition.bCheckRelativeToSource = false;

	MobilityEffect = new class'XMBEffect_ConditionalStatChange';
    MobilityEffect.BuildPersistentEffect(1, true, false, false);
	MobilityEffect.AddPersistentStatChange(eStat_Mobility, 2);
    MobilityEffect.SetDisplayInfo(ePerkBuff_Bonus, "Foxholes", "+2 mobility and +5 defense while in low cover", Template.IconImage, true,, Template.AbilitySourceName);
	MobilityEffect.Conditions.AddItem(CoverCondition);
    Template.AddTargetEffect(MobilityEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}