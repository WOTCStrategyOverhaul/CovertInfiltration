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

	Template.Stages.AddItem('Activity_PrepareCounterDE');
	Template.Stages.AddItem('Activity_CounterDarkEvent');
	
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
	Template.NumInDeck = 1;
	
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
	Template.NumInDeck = 1;

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
	Template.NumInDeck = 1;

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
	Template.NumInDeck = 1;

	Template.Stages.AddItem('Activity_RecoverPersonnel');
	Template.Stages.AddItem('Activity_RescueEngineer');

	return Template;
}

static function X2DataTemplate CreateJailbreakFactionSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakFactionSoldier');
	
	Template.ChooseFaction = ChooseExtraSoldierFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsExtraSoldierChainAvailable;

	Template.Stages.AddItem('Activity_PrepareFactionJB');
	Template.Stages.AddItem('Activity_JailbreakFactionSoldier');

	return Template;
}

static function StateObjectReference ChooseExtraSoldierFaction (XComGameState_ActivityChain ChainState, XComGameState NewGameState)
{
	local XComGameState_ResistanceFaction FactionState;
	local array<StateObjectReference> FactionRefs;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom && FactionState.GetInfluence() >= eFactionInfluence_Influential && FactionState.IsExtraFactionSoldierRewardAllowed(NewGameState))
		{
			FactionRefs.AddItem(FactionState.GetReference());
		}
	}

	return FactionRefs[`SYNC_RAND_STATIC(FactionRefs.Length)];
}

static function bool IsExtraSoldierChainAvailable (XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	local StateObjectReference FactionRef;

	FactionRef = ChooseExtraSoldierFaction(ChainState, NewGameState);

	if (FactionRef.ObjectID > 0)
	{
		return true;
	}

	return false;
}

static function X2DataTemplate CreateJailbreakCapturedSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakCapturedSoldier');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsCapturedSoldierChainAvailable;

	Template.Stages.AddItem('Activity_JailbreakSoldier');

	return Template;
}

static function bool IsCapturedSoldierChainAvailable(XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	return class'X2StrategyElement_DefaultRewards'.static.IsCapturedSoldierRewardAvailable(NewGameState);
}

static function X2DataTemplate CreateJailbreakChosenSoldierTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_JailbreakChosenSoldier');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsChosenCapturedSoldierChainAvailable;

	Template.Stages.AddItem('Activity_JailbreakChosenSoldier');

	return Template;
}

static function bool IsChosenCapturedSoldierChainAvailable(XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	return class'X2StrategyElement_XpackRewards'.static.IsChosenCapturedSoldierRewardAvailable(NewGameState);
}

static function X2DataTemplate CreateGatherSuppliesTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_GatherSupplies');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = false;

	Template.Stages.AddItem('Activity_GatherSupplies');

	return Template;
}

static function bool IsGatherSuppliesChainAvailable(XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain Chain;
	local XComGameState_HeadquartersXCom XComHQ;
	local name InProgress;

	foreach NewGameState.IterateByClassType(class'XComGameState_ActivityChain', Chain)
	{
		if (!Chain.bEnded)
		{
			foreach class'XComGameState_ActivityChainSpawner'.default.SupplyChains(InProgress)
			{
				if (InProgress == Chain.GetMyTemplate().DataName)
				{
					return false;
				}
			}
		}
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	if (class'XComGameState_ActivityChainSpawner'.default.MinSupplies > XComHQ.GetSupplies())
	{
		return true;
	}

	return false;
}

static function X2DataTemplate CreateGatherIntelTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_GatherIntel');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = false;

	Template.Stages.AddItem('Activity_GatherIntel');

	return Template;
}

static function bool IsGatherIntelChainAvailable(XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain Chain;
	local XComGameState_HeadquartersXCom XComHQ;
	local name InProgress;

	foreach NewGameState.IterateByClassType(class'XComGameState_ActivityChain', Chain)
	{
		if (!Chain.bEnded)
		{
			foreach class'XComGameState_ActivityChainSpawner'.default.IntelChains(InProgress)
			{
				if (InProgress == Chain.GetMyTemplate().DataName)
				{
					return false;
				}
			}
		}
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	if (class'XComGameState_ActivityChainSpawner'.default.MinSupplies > XComHQ.GetIntel())
	{
		return true;
	}

	return false;
}

static function X2DataTemplate CreateLandedUFOTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_LandedUFO');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsUFOChainAvailable;
	
	Template.Stages.AddItem('Activity_RecoverUFO');
	Template.Stages.AddItem('Activity_PrepareUFO');
	Template.Stages.AddItem('Activity_LandedUFO');

	return Template;
}

static function bool IsUFOChainAvailable(XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	local XComGameState_HeadquartersAlien AlienHQ;

	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	
	if (AlienHQ.bHasPlayerBeenIntercepted || AlienHQ.bHasGoldenPathUFOAppeared || AlienHQ.bHasPlayerAvoidedUFO)
	{
		return true;
	}

	return false;
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
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion; // TODO: choose region where a facility is
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsFacilityChainAvailable;
	
	Template.Stages.AddItem('Activity_PrepareFacility');
	Template.Stages.AddItem('Activity_FacilityInformant');
	//Template.Stages.AddItem('Activity_AvatarFacility');

	return Template;
}

static function bool IsFacilityChainAvailable(XComGameState NewGameState, optional XComGameState_ActivityChain ChainState)
{
	local XComGameState_FacilityAlien FacilityState;
	local XComGameState_WorldRegion RegionState;

	foreach NewGameState.IterateByClassType(class'XComGameState_FacilityAlien', FacilityState)
	{
		RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(FacilityState.Region.ObjectID));

		if (!RegionState.HaveMadeContact())
		{
			return true;
		}
	}

	return false;
}
// TODO: make something to remove this from the deck if these conditions are ever not met


//////////////////////////////////////////////////////
//                    Helpers                       //
//////////////////////////////////////////////////////

static function StateObjectReference ChooseMetFaction (XComGameState_ActivityChain ChainState, XComGameState NewGameState)
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