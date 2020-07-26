class X2RetalPlacementModifierTemplateManager extends X2DataTemplateManager;

static function X2RetalPlacementModifierTemplateManager GetRetalPlacementModifierTemplateManager()
{
    return X2RetalPlacementModifierTemplateManager(class'Engine'.static.GetTemplateManager(class'X2RetalPlacementModifierTemplateManager'));
}

function int ScoreRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	local X2RetalPlacementModifierTemplate ModTemplate;
	local X2DataTemplate DataTemplate;
	local int Score, Delta;

	foreach IterateTemplates(DataTemplate)
	{
		ModTemplate = X2RetalPlacementModifierTemplate(DataTemplate);
		Delta = ModTemplate.GetDeltaForRegion(NewGameState, RegionState);
		Score += Delta;

		`CI_Trace("Region:" @ RegionState.GetMyTemplateName() $ "; Modifier:" @ ModTemplate.DataName $ "; Delta:" @ Delta $ "; Score:" @ Score);
	}
	
	return Score;
}

defaultProperties
{
	TemplateDefinitionClass = class'X2RetalPlacementModifierSet'
	ManagedTemplateClass = class'X2RetalPlacementModifierTemplate'
}
