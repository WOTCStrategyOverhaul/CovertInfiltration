//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Activity chains that are introduced by this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_DefaultActivityChains extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Activites;
	
	Activites.AddItem(CreateCounterDarkEventTemplate());
	Activites.AddItem(CreateSupplyRaidTemplate());
	Activites.AddItem(CreateCaptureVIPTemplate());
	Activites.AddItem(CreateRescueScientistTemplate());
	Activites.AddItem(CreateRescueEngineerTemplate());
	Activites.AddItem(CreateJailbreakFactionSoldierTemplate());
	Activites.AddItem(CreateJailbreakCapturedSoldierTemplate());
	Activites.AddItem(CreateGatherSuppliesTemplate());
	Activites.AddItem(CreateGatherIntelTemplate());
	Activites.AddItem(CreateLandedUFOTemplate());
	//Activites.AddItem(CreateHuntChosenTemplate());
	Activites.AddItem(CreateDestroyFacilityTemplate());

	return Activites;
}

static function X2DataTemplate CreateCounterDarkEventTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_CounterDarkEvent');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = false;
	
	Template.SetupChain = SetupDarkEventChain;
	Template.CleanupChain = CleanupDarkEventChain;

	// TODO: Spawn 3 of these then despawn the other two when one is selected
	Template.Stages.AddItem('Activity_PrepareCounterDE');
	Template.Stages.AddItem('Activity_CounterDarkEvent');
	// TODO: attach Dark Event to stage two's missionsite
	// TODO: resume the Dark Event when stage one expires
	// TODO: trigger the Dark Event when stage two expires
	
	return Template;
}

static function SetupDarkEventChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	ChainState.PauseChainDarkEvent(NewGameState);
}

static function CleanupDarkEventChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	ChainState.CounterChainDarkEvent(NewGameState);
}

static function X2DataTemplate CreateSupplyRaidTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_SupplyRaid');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	
	Template.Stages.AddItem('Activity_CommanderSupply');
	Template.Stages.AddItem('Activity_SupplyRaid');

	return Template;
}

static function X2DataTemplate CreateCaptureVIPTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_CaptureInformant');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;

	Template.Stages.AddItem('Activity_RecoverInformant');
	Template.Stages.AddItem('Activity_CaptureInformant');

	return Template;
}

static function X2DataTemplate CreateRescueScientistTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_RescueScientist');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;

	Template.Stages.AddItem('Activity_RecoverPersonnel');
	Template.Stages.AddItem('Activity_RescueScientist');

	return Template;
}

static function X2DataTemplate CreateRescueEngineerTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_RescueEngineer');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;

	Template.Stages.AddItem('Activity_RecoverPersonnel');
	Template.Stages.AddItem('Activity_RescueEngineer');

	return Template;
}

static function X2DataTemplate CreateJailbreakFactionSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakFactionSoldier');
	
	Template.ChooseFaction = ChooseMetFaction; // TODO: Pick faction that has high influence and hasn't already had this chain
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = false;

	Template.Stages.AddItem('Activity_PrepareFactionJB');
	Template.Stages.AddItem('Activity_JailbreakSoldier');

	return Template;
}

static function X2DataTemplate CreateJailbreakCapturedSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakCapturedSoldier');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = false;

	Template.Stages.AddItem('Activity_JailbreakSoldier');

	return Template;
}

static function X2DataTemplate CreateGatherSuppliesTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_GatherSupplies');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;

	Template.Stages.AddItem('Activity_GatherSupplies');

	return Template;
}

static function X2DataTemplate CreateGatherIntelTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_GatherIntel');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;

	Template.Stages.AddItem('Activity_GatherIntel');

	return Template;
}

static function X2DataTemplate CreateLandedUFOTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_LandedUFO');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	
	Template.Stages.AddItem('Activity_RecoverUFO');
	Template.Stages.AddItem('Activity_PrepareUFO');
	Template.Stages.AddItem('Activity_LandedUFO');

	return Template;
}
/*
static function X2DataTemplate CreateHuntChosenTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_HuntChosen');
	
	Template.ChooseFaction = ChooseMetFaction; // TODO: spawn immediately when contacting faction
	Template.ChooseRegions = ChooseRandomContactedRegion; // TODO: choose region that the chosen is at
	Template.SpawnInDeck = false;
	
	Template.Stages.AddItem('Activity_PrepareChosen');
	Template.Stages.AddItem('Activity_RecoverChosen');
	Template.Stages.AddItem('Activity_CommanderChosen');
	//Template.Stages.AddItem('Activity_ChosenBase');
	// TODO: when done, reveal chosen base

	return Template;
}
*/
static function X2DataTemplate CreateDestroyFacilityTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_DestroyFacility');
	
	Template.ChooseFaction = ChooseMetFaction; // TODO: spawn immediately when facility is built
	Template.ChooseRegions = ChooseRandomContactedRegion; // TODO: choose region where a facility is
	Template.SpawnInDeck = false;
	
	Template.Stages.AddItem('Activity_PrepareFacility');
	Template.Stages.AddItem('Activity_FacilityInformant');
	//Template.Stages.AddItem('Activity_AvatarFacility');
	// TODO: when done, unlock facility

	return Template;
}

//////////////////////////////////////////////////////
//                    Helpers                       //
//////////////////////////////////////////////////////

static function StateObjectReference ChooseMetFaction (XComGameState_ActivityChain ChainState)
{
	local XComGameState_ResistanceFaction FactionState;
	local array<StateObjectReference> FactionRefs;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom)
		{
			FactionRefs.AddItem(FactionState.GetReference());
		}
	}

	return FactionRefs[`SYNC_RAND_STATIC(FactionRefs.Length)];
}

static function ChooseRandomContactedRegion (XComGameState_ActivityChain ChainState, out StateObjectReference PrimaryRegionRef, out StateObjectReference SecondaryRegionRef)
{
	local array<StateObjectReference> RegionRefs;
	local XComGameState_WorldRegion RegionState;
	local StateObjectReference SelectedRegion;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if (RegionState.HaveMadeContact())
		{
			RegionRefs.AddItem(RegionState.GetReference());
		}
	}

	SelectedRegion = RegionRefs[`SYNC_RAND_STATIC(RegionRefs.Length)];

	PrimaryRegionRef = SelectedRegion;
	SecondaryRegionRef = SelectedRegion;
}