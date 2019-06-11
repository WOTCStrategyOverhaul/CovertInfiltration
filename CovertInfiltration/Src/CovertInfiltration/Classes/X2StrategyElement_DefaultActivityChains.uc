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
	
	Activites.AddItem(CreateCounterDETemplate());
	Activites.AddItem(CreateSupplyRaidTemplate());
	Activites.AddItem(CreateCaptureVIPTemplate());
	Activites.AddItem(CreateRescueScientistTemplate());
	Activites.AddItem(CreateRescueEngineerTemplate());
	Activites.AddItem(CreateJailbreakFactionSoldierTemplate());
	Activites.AddItem(CreateJailbreakCapturedSoldierTemplate());

	return Activites;
}

static function X2DataTemplate CreateCounterDETemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_CounterDarkEvent');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;

	Template.Stages.AddItem('Activity_PrepareCounterDE');
	Template.Stages.AddItem('Activity_CounterDarkEvent');

	return Template;
}

static function X2DataTemplate CreateSupplyRaidTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_SupplyRaid');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	
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

	Template.Stages.AddItem('Activity_RecoverSchedule');
	Template.Stages.AddItem('Activity_CaptureInformant');

	return Template;
}

static function X2DataTemplate CreateRescueScientistTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_RescueScientist');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;

	Template.Stages.AddItem('Activity_HackLocation');
	Template.Stages.AddItem('Activity_RescueScientist');

	return Template;
}

static function X2DataTemplate CreateRescueEngineerTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_RescueEngineer');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;

	Template.Stages.AddItem('Activity_HackLocation');
	Template.Stages.AddItem('Activity_RescueEngineer');

	return Template;
}

static function X2DataTemplate CreateJailbreakFactionSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakFactionSoldier');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;

	Template.Stages.AddItem('Activity_PrepareFactionJailbreak');
	Template.Stages.AddItem('Activity_JailbreakSoldier');

	return Template;
}

static function X2DataTemplate CreateJailbreakCapturedSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakCapturedSoldier');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;

	Template.Stages.AddItem('Activity_JailbreakSoldier');

	return Template;
}
///////////////////////////////////////////////////

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