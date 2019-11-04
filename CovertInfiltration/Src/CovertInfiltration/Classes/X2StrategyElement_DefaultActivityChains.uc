//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Activity chains that are introduced by this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_DefaultActivityChains extends X2StrategyElement config(Infiltration);

var config EFactionInfluence MinFactionInfluenceForExtraSoldier;

var localized string strCounterDarkEventDescription;
var localized string strCounterHiddenDarkEventDescription;

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
	Activites.AddItem(CreateIntelInterceptionTemplate());
	Activites.AddItem(CreateSupplyInterceptionTemplate());

	return Activites;
}

static function X2DataTemplate CreateCounterDarkEventTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_CounterDarkEvent');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	
	Template.SetupChain = SetupDarkEventChain;
	Template.CleanupChain = CleanupDarkEventChain;

	Template.Stages.AddItem('Activity_WaitDE');
	Template.Stages.AddItem('Activity_PrepareCounterDE');
	Template.Stages.AddItem('Activity_CounterDarkEvent');
	
	Template.GetOverviewDescription = CounterDarkEventGetOverviewDescription;

	return Template;
}

static function SetupDarkEventChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	ChainState.PreventChainDarkEventFromCompleting(NewGameState);
}

static function CleanupDarkEventChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	if (ChainState.IsCompleted() && ChainState.GetLastActivity().CompletionStatus == eActivityCompletion_Success)
	{
		ChainState.CounterChainDarkEvent(NewGameState);
	}
	else
	{
		ChainState.RestoreChainDarkEventCompleting(NewGameState);
	}
}

static function string CounterDarkEventGetOverviewDescription (XComGameState_ActivityChain ChainState)
{
	local XComGameState_DarkEvent DarkEventState;
	local XGParamTag kTag;

	DarkEventState = ChainState.GetChainDarkEvent();

	if (DarkEventState.bSecretEvent)
	{
		return default.strCounterHiddenDarkEventDescription;
	}

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = DarkEventState.GetDisplayName();

	return `XEXPAND.ExpandString(default.strCounterDarkEventDescription);
}

static function X2DataTemplate CreateSupplyRaidTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_SupplyRaid');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomRelayedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsAdvancedChainAvailable;
	
	Template.Stages.AddItem('Activity_CommanderSupply');
	Template.Stages.AddItem('Activity_SupplyRaid');

	return Template;
}

static function X2DataTemplate CreateCaptureVIPTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_CaptureInformant');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomRelayedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsAdvancedChainAvailable;

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

static function StateObjectReference FindFactionForExtraSoldier (XComGameState NewGameState)
{
	local XComGameState_ResistanceFaction FactionState;
	local array<StateObjectReference> FactionRefs;
	local StateObjectReference EmptyRef;
	local int NumFactionSoldiers;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom && FactionState.GetInfluence() >= default.MinFactionInfluenceForExtraSoldier)
		{
			NumFactionSoldiers = FactionState.GetNumFactionSoldiers(NewGameState);

			if (
				NumFactionSoldiers > 0 && // If we currently have none, allow the normal recruit CA to spawn instead
				NumFactionSoldiers < class'XComGameState_ResistanceFaction'.default.MaxHeroesPerFaction
			)
			{
				FactionRefs.AddItem(FactionState.GetReference());
			}
		}
	}

	if (FactionRefs.Length == 0)
	{
		return EmptyRef;
	}

	return FactionRefs[`SYNC_RAND_STATIC(FactionRefs.Length)];
}

static function StateObjectReference ChooseExtraSoldierFaction (XComGameState_ActivityChain ChainState, XComGameState NewGameState)
{
	return FindFactionForExtraSoldier(NewGameState);
}

static function bool IsExtraSoldierChainAvailable (XComGameState NewGameState)
{
	return FindFactionForExtraSoldier(NewGameState).ObjectID > 0;
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

static function bool IsCapturedSoldierChainAvailable(XComGameState NewGameState)
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

static function bool IsChosenCapturedSoldierChainAvailable(XComGameState NewGameState)
{
	return class'X2StrategyElement_XpackRewards'.static.IsChosenCapturedSoldierRewardAvailable(NewGameState);
}

static function X2DataTemplate CreateGatherSuppliesTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_GatherSupplies');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;

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
	Template.NumInDeck = 1;

	Template.Stages.AddItem('Activity_GatherIntel');

	return Template;
}

static function X2DataTemplate CreateLandedUFOTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_LandedUFO');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomRelayedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsUFOChainAvailable;
	
	Template.Stages.AddItem('Activity_RecoverUFO');
	Template.Stages.AddItem('Activity_PrepareUFO');
	Template.Stages.AddItem('Activity_LandedUFO');

	return Template;
}

static function bool IsUFOChainAvailable(XComGameState NewGameState)
{
	local XComGameState_HeadquartersAlien AlienHQ;

	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	
	if (AlienHQ.bHasPlayerBeenIntercepted || AlienHQ.bHasGoldenPathUFOAppeared || AlienHQ.bHasPlayerAvoidedUFO)
	{
		return IsAdvancedChainAvailable(NewGameState);
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
	Template.ChooseRegions = ChooseFacilityRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 1;
	Template.DeckReq = IsFacilityChainAvailable;
	
	Template.Stages.AddItem('Activity_PrepareFacility');
	Template.Stages.AddItem('Activity_FacilityInformant');
	//Template.Stages.AddItem('Activity_AvatarFacility');

	// We can't really make the mission itself into an activity as the facility itself is THE mission
	// As such, we workaround by rewarding 2nd stage with a facility lead, so that the player can unlock the mission

	return Template;
}

static function ChooseFacilityRegion (XComGameState_ActivityChain ChainState, out StateObjectReference PrimaryRegionRef, out StateObjectReference SecondaryRegionRef)
{
	PrimaryRegionRef = FindRegionForFacilityChain();
}

static function bool IsFacilityChainAvailable(XComGameState NewGameState)
{
	return (IsAdvancedChainAvailable(NewGameState) && FindRegionForFacilityChain().ObjectID > 0);
}

static function StateObjectReference FindRegionForFacilityChain ()
{
	local array<XComGameState_MissionSite> Missions;
	local XComGameState_MissionSite FacilityMission;
	local XComGameState_ActivityChain ChainState;
	local StateObjectReference EmptyRef;
	local XComGameStateHistory History;
	local bool bOngoingChain;
	
	Missions = class'UIUtilities_Strategy'.static.GetAlienHQ().GetValidFacilityDoomMissions(true);
	History = `XCOMHISTORY;

	foreach Missions(FacilityMission)
	{
		bOngoingChain = false;

		foreach History.IterateByClassType(class'XComGameState_ActivityChain', ChainState)
		{
			if (ChainState.GetMyTemplateName() == 'ActivityChain_DestroyFacility' && ChainState.PrimaryRegionRef == FacilityMission.Region)
			{
				bOngoingChain = true;
				break;
			}
		}

		if (!bOngoingChain)
		{
			return FacilityMission.Region;
		}
	}

	return EmptyRef;
}

static function X2DataTemplate CreateIntelInterceptionTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_IntelIntercept');
	
	Template.Stages.AddItem('Activity_IntelRescue');

	Template.PostStageSetup = AttachResCon;

	return Template;
}

static function X2DataTemplate CreateSupplyInterceptionTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'ActivityChain_SupplyIntercept');
	
	Template.Stages.AddItem('Activity_SupplyRescue');

	Template.PostStageSetup = AttachResCon;

	return Template;
}

static function AttachResCon(XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_ResourceContainer ResourceContainerState;
	local XComGameState_MissionSite MissionState;
	local XComGameState_Reward MissionReward;
	local XComGameStateHistory History;
	local int x, y;
	
	// In theory, I should be checking if this is the correct stage here. But this chain only has a single stage

	History = `XCOMHISTORY;
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(ActivityState.PrimaryObjectRef.ObjectID));

	// Loop through all the activity's rewards
	for (x = 0; x < MissionState.Rewards.Length; x++)
	{
		MissionReward = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[x].ObjectID));
			
		// If this activity has a container reward
		if (MissionReward.GetMyTemplateName() == 'Reward_Container')
		{
			// Loop through the activity's refs
			for (y = 0; y < ActivityState.GetActivityChain().ChainObjectRefs.Length; y++)
			{
				ResourceContainerState = XComGameState_ResourceContainer(History.GetGameStateForObjectID(ActivityState.GetActivityChain().ChainObjectRefs[y].ObjectID));
					
				// Find the resource container in the activity's refs
				if (ResourceContainerState != none)
				{
					// Attach the container to the reward state for later use
					MissionReward.SetReward(ResourceContainerState.GetReference());
					return;
				}
			}
			`CI_Log("No containers in the chain" @ ActivityState.GetActivityChain().GetMyTemplateName());
			return;
		}
	}
	`CI_Log("No valid rewards in this mission!");
}

///////////////
/// Helpers ///
///////////////

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

static function bool IsAdvancedChainAvailable (XComGameState NewGameState)
{
	return FindRegionWithRelay().ObjectID > 0;
}

static function ChooseRandomRelayedRegion (XComGameState_ActivityChain ChainState, out StateObjectReference PrimaryRegionRef, out StateObjectReference SecondaryRegionRef)
{
	local StateObjectReference SelectedRegion;

	SelectedRegion = FindRegionWithRelay();
	
	if (SelectedRegion.ObjectID <= 0)
	{
		`RedScreen("There are no non-starting regions with Radio Relays! Chain has no region to spawn");
	}

	PrimaryRegionRef = SelectedRegion;
	SecondaryRegionRef = SelectedRegion;
}

static function StateObjectReference FindRegionWithRelay ()
{
	local array<StateObjectReference> RegionRefs;
	local XComGameState_WorldRegion RegionState;
	local StateObjectReference SelectedRegion;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if (RegionState.ResistanceLevel == eResLevel_Outpost && !RegionState.IsStartingRegion())
		{
			RegionRefs.AddItem(RegionState.GetReference());
		}
	}
	
	if (RegionRefs.Length > 0)
	{
		SelectedRegion = RegionRefs[`SYNC_RAND_STATIC(RegionRefs.Length)];
	}

	return SelectedRegion;
}