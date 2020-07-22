class X2RetalPlacementModifierSet extends X2DataSet dependson(X2RetalPlacementModifierTemplate);

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeneric('Base', Base_IsRelevantToRegion));

	return Templates;
}

static protected function X2RetalPlacementModifierTemplate CreateGeneric (name TemplateName, delegate<X2RetalPlacementModifierTemplate.IsRelevantToRegion> IsRelevantFn)
{
	local X2RetalPlacementModifierTemplate Template;

	`CREATE_X2TEMPLATE(class'X2RetalPlacementModifierTemplate', Template, TemplateName);
	Template.IsRelevantToRegion = IsRelevantFn;

	return Template;
}

static protected function bool Base_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true;
}


