class X2StrategyElement_DefaultActivities extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	//
	CreateNeutralizeCommander(Templates);
	
	return Templates;
}

static function CreateNeutralizeCommander (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;

	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_NeutralizeCommanderInfil', true);
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Infiltration', Activity, 'Activity_NeutralizeCommander');

	CovertAction.ChooseLocationFn = UseActivityPrimaryRegion;
	CovertAction.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	CovertAction.Narratives.AddItem('CovertActionNarrative_NeutralizeCommanderInfil');
	CovertAction.Rewards.AddItem('Reward_InfiltrationActivityProxy');

	Activity.CovertActionName = CovertAction.DataName;

	// Fill in the mission
}

static function UseActivityPrimaryRegion (XComGameState NewGameState, XComGameState_CovertAction ActionState, out array<StateObjectReference> ExcludeLocations)
{
	ActionState.LocationEntity = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(ActionState).GetActivityChain().PrimaryRegionRef;
}