class X2Ability_SitRepAbilitySet_CI extends X2Ability config(GameCore);

var config int INFORMATION_WAR_HACK_DEBUFF;
var config string HackDefenseDecreasedFriendlyName;
var config string HackDefenseDecreasedFriendlyDesc;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(InformationWarDebuff_CI());
    Templates.AddItem(FamiliarTerrainBuff_CI());
    Templates.AddItem(PhysicalConditioningBuff_CI());
    Templates.AddItem(MentalReadinessBuff_CI());

    return Templates;
}

static function X2AbilityTemplate InformationWarDebuff_CI()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'InformationWarDebuff_CI');
    Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;
    
    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_HackDefense, -default.INFORMATION_WAR_HACK_DEBUFF);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, default.HackDefenseDecreasedFriendlyName, default.HackDefenseDecreasedFriendlyDesc, "");
    Template.AddTargetEffect(StatEffect);
    
    //Template.AddTargetEffect(class'X2StatusEffects'.static.CreateHackDefenseChangeStatusEffect(-default.INFORMATION_WAR_HACK_DEBUFF/*, UnitCondition*/));

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate FamiliarTerrainBuff_CI()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'FamiliarTerrainBuff_CI');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_escape";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_Mobility, 1); //TODO: config this
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, "MOB + 1", "CUZ REASONS", Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate PhysicalConditioningBuff_CI()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'PhysicalConditioningBuff_CI');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_escape";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_Dodge, 10); //TODO: config this
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, "DODGE + 10", "CUZ REASONS", Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate MentalReadinessBuff_CI()
{
    local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'MentalReadinessBuff_CI');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_escape";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    StatEffect = new class'X2Effect_PersistentStatChange';
    StatEffect.BuildPersistentEffect(1, true, false, true);
    StatEffect.AddPersistentStatChange(eStat_Will, 10); //TODO: config this
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, "Will + 10", "CUZ REASONS", Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(StatEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}