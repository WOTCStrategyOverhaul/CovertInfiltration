class X2RetalPlacementModifierSet extends X2DataSet dependson(X2RetalPlacementModifierTemplate);

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeneric('Base', Base_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('StartingRegion', StartingRegion_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('HasRelay', HasRelay_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('HasRelayAndDoomFacility', HasRelayAndDoomFacility_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('HasGoldenPathMission', HasGoldenPathMission_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('AllContinentContacted', AllContinentContacted_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('Only1LiveConnection', Only1LiveConnection_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('Only2LiveConnections', Only2LiveConnections_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('OnlyContactedChosenRegion', OnlyContactedChosenRegion_IsRelevantToRegion));

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

static protected function bool StartingRegion_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return RegionState.IsStartingRegion();
}

static protected function bool HasRelay_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return RegionState.ResistanceLevel == eResLevel_Outpost;
}

static protected function bool HasRelayAndDoomFacility_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true; // TODO
}

static protected function bool HasGoldenPathMission_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true; // TODO
}

static protected function bool AllContinentContacted_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return RegionState.GetContinent().bContinentBonusActive;
}

static protected function bool Only1LiveConnection_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true; // TODO
}

static protected function bool Only2LiveConnections_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true; // TODO
}

static protected function bool OnlyContactedChosenRegion_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true; // TODO
}

