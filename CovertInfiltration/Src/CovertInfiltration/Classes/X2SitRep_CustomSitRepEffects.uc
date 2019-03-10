class X2SitRep_CustomSitRepEffects extends X2SitRepEffect;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    
    Templates.AddItem(CreateInformationWarEffectTemplate_CI());
    
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
    ModValue += class'X2StrategyElement_XpackResistanceActions'.static.GetValueInformationWar();
}
