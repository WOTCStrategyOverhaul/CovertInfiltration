class X2SitRep_CustomSitRepEffects extends X2SitRepEffect config(GameData);

var config array<int> InformationWarReduction;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    
    Templates.AddItem(CreateInformationWarEffectTemplate_CI());
    Templates.AddItem(CreateInformationWarUnitEffectTemplate_CI());
    Templates.AddItem(CreateFamiliarTerrainEffectTemplate_CI());
    Templates.AddItem(CreatePhysicalConditioningEffectTemplate_CI());
    Templates.AddItem(CreateMentalReadinessEffectTemplate_CI());
    Templates.AddItem(CreateLightningStrikeEffect_CI());
    Templates.AddItem(CreatePodSizeIncreasedByOneEffectTemplate_CI());
    Templates.AddItem(CreateNoSquadConcealmentEffectTemplate_CI());
    Templates.AddItem(CreateGunneryEmplacementsEffectTemplate_CI());
    Templates.AddItem(CreateShoddyIntelEffectTemplate_CI());
    Templates.AddItem(CreateWellRehearsedEffectTemplate_CI());
    
    
    return Templates;
}

static function X2SitRepEffectTemplate CreateInformationWarEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyHackDefenses Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyHackDefenses', Template, 'InformationWarEffect_CI');
    Template.DefenseDeltaFn = InformationWarModFunction;

    return Template;
}

static function InformationWarModFunction(out int ModValue)
{
    ModValue = 7;
    //ModValue = `ScaleStrategyArrayInt(default.InformationWarReduction);
}

static function X2SitRepEffectTemplate CreateInformationWarUnitEffectTemplate_CI()
{
   local X2SitRepEffect_GrantAbilities_CI Template;

   `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities_CI', Template, 'InformationWarUnitEffect_CI');
   
   Template.AbilityTemplateNames.AddItem('InformationWarDebuff_CI');
   Template.Teams.AddItem(eTeam_Alien);
   Template.ExcludeOrganic = true;

   return Template;
}

static function X2SitRepEffectTemplate CreateFamiliarTerrainEffectTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities_CI Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities_CI', Template, 'FamiliarTerrainEffect_CI')

    Template.AbilityTemplateNames.AddItem('FamiliarTerrainBuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreatePhysicalConditioningEffectTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities_CI Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities_CI', Template, 'PhysicalConditioningEffect_CI')

    Template.AbilityTemplateNames.AddItem('PhysicalConditioningBuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreateMentalReadinessEffectTemplate_CI()
{
    local X2SitRepEffect_GrantAbilities_CI Template;
    
    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities_CI', Template, 'MentalReadinessEffect_CI')

    Template.AbilityTemplateNames.AddItem('MentalReadinessBuff_CI');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreateLightningStrikeEffect_CI()
{
    local X2SitRepEffect_GrantAbilities_CI Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities_CI', Template, 'LightningStrikeEffect_CI')

    Template.AbilityTemplateNames.AddItem('LightningStrike');
    Template.GrantToSoldiers = true;

    return Template;
}

static function X2SitRepEffectTemplate CreatePodSizeIncreasedByOneEffectTemplate_CI()
{
	local X2SitRepEffect_ModifyPodSize Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyPodSize', Template, 'PodSizeIncreaseByOneEffect_CI');

	Template.PodSizeDelta = 1;

	return Template;
}

static function X2SitRepEffectTemplate CreateNoSquadConcealmentEffectTemplate_CI()
{
    local X2SitRepEffect_ModifyKismetVariable Template;

    `CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyKismetVariable', Template, 'NoSquadConcealmentEffect_CI');

    //Template.VariableNames.AddItem("bForceNoSquadConcealment");

    return  Template;
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

