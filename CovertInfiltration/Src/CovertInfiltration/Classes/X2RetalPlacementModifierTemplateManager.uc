class X2RetalPlacementModifierTemplateManager extends X2DataTemplateManager;

static function X2RetalPlacementModifierTemplateManager GetRetalPlacementModifierTemplateManager()
{
    return X2RetalPlacementModifierTemplateManager(class'Engine'.static.GetTemplateManager(class'X2RetalPlacementModifierTemplateManager'));
}

defaultProperties
{
	TemplateDefinitionClass = class'X2RetalPlacementModifierSet'
	ManagedTemplateClass = class'X2RetalPlacementModifierTemplate'
}
