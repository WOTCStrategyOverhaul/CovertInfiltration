class X2StrategyElement_InfiltrationRewards extends X2StrategyElement_DefaultRewards
	dependson(X2RewardTemplate)
	config(CovertMissions);

	
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	// Mission Rewards
	Rewards.AddItem(CreateSoldierRescueMissionRewardTemplate()); //this is so we can rescue soldiers just captured by ADVENT
	// Mission Rewards
	Rewards.AddItem(CreateCAGuerillaOpMissionRewardTemplate());
	Rewards.AddItem(CreateCASupplyRaidMissionRewardTemplate());
	Rewards.AddItem(CreateResOpMissionRewardTemplate());

	return Rewards;
}

// #######################################################################################
// -------------------- MISSION REWARDS --------------------------------------------------
// #######################################################################################
static function X2DataTemplate CreateResOpMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_PrepResOp');

	//Template.GiveRewardFn = GiveResistanceOpReward;
	Template.GenerateRewardFn = StoreActionState;
	Template.GetRewardStringFn = GetMissionRewardString;
	//Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}

static function StoreActionState(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference ActionRef)
{
	RewardState.RewardObjectReference = ActionRef; //we store this so we can get the faction state later on
}

static function X2DataTemplate CreateCASupplyRaidMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_CASupplyRaid');

	//Template.GiveRewardFn = GiveCASupplyRaidReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	//Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}


static function X2DataTemplate CreateCAGuerillaOpMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_CAGuerillaOp');

	Template.GiveRewardFn = GiveCAGuerillaOpReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}

static function GiveResistanceOpReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local X2StrategyElementTemplateManager StratMgr;
	local XComGameState_MissionSite MissionState;
	local XComGameState_ResistanceFaction FactionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_CovertAction ActionState;

	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	FactionState = ActionState.GetFaction();

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_ResistanceOp'));
	
	MissionState = BuildResOpMission(NewGameState, MissionSource);
	MissionState.ResistanceFaction = FactionState.GetReference();
	

	RewardState.RewardObjectReference = MissionState.GetReference(); //then we make the final reward this one
}


static function GiveCASupplyRaidReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local XComGameState_CovertAction ActionState;
	local XComGameState_HeadquartersResistance ResHQ;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();

	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SupplyRaid'));
	
	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	RewardState.RewardObjectReference = MissionState.GetReference();
}

static function GiveCAGuerillaOpReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_MissionSite MissionState, DarkEventMissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local XComGameState_DarkEvent DarkEventState;
	local XComGameState_MissionCalendar CalendarState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local array<StateObjectReference> DarkEvents, PossibleDarkEvents;
	local array<int> OnMissionDarkEventIDs;
	local StateObjectReference DarkEventRef;
	local float MissionDuration;
	local XComGameState_CovertAction ActionState;
	local array<name> ExcludeList;
	local XComGameState_HeadquartersResistance ResHQ;

	History = `XCOMHISTORY;
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	CalendarState = XComGameState_MissionCalendar(History.GetSingleGameStateObjectForClass(class'XComGameState_MissionCalendar'));
	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(class'X2StrategyElement_DefaultMissionSources'.static.SelectGuerillaOpRewardType(ExcludeList, CalendarState)));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(MissionRewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_GuerillaOp'));

	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	MissionState.PickPOI(NewGameState);
	
	// Find out if there are any missions on the board which are paired with Dark Events
	foreach History.IterateByClassType(class'XComGameState_MissionSite', DarkEventMissionState)
	{
		if (DarkEventMissionState.DarkEvent.ObjectID != 0)
		{
			OnMissionDarkEventIDs.AddItem(DarkEventMissionState.DarkEvent.ObjectID);
		}
	}

	// See if there are any Dark Events left over after comparing the mission Dark Event list with the Alien HQ Chosen Events
	DarkEvents = AlienHQ.ChosenDarkEvents;
	foreach DarkEvents(DarkEventRef)
	{		
		if (OnMissionDarkEventIDs.Find(DarkEventRef.ObjectID) == INDEX_NONE)
		{
			PossibleDarkEvents.AddItem(DarkEventRef);
		}
	}

	// If there are Dark Events that this mission can counter, pick a random one and ensure it won't activate before the mission expires
	if (PossibleDarkEvents.Length > 0)
	{
		DarkEventRef = PossibleDarkEvents[`SYNC_RAND_STATIC(PossibleDarkEvents.Length)];		
		DarkEventState = XComGameState_DarkEvent(History.GetGameStateForObjectID(DarkEventRef.ObjectID));
		if (DarkEventState.TimeRemaining < MissionDuration)
		{
			DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
			DarkEventState.ExtendActivationTimer(default.MissionMaxDuration);
		}

		MissionState.DarkEvent = DarkEventRef;
	}

	RewardState.RewardObjectReference = MissionState.GetReference();
}



static function X2DataTemplate CreateSoldierRescueMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_NormalRescue');

	Template.IsRewardAvailableFn = IsRescueSoldierRewardAvailable;
	//Template.GenerateRewardFn = GenerateRescueSoldierReward;
	Template.GiveRewardFn = GiveRescueSoldierReward;
	//Template.GetRewardPreviewStringFn = GetRescueSoldierRewardString;
	Template.GetRewardStringFn = GetMissionRewardString;
	//Template.CleanUpRewardFn = CleanUpRewardWithoutRemoval;
	Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}


static function bool IsRescueSoldierRewardAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;

	// we can only rescue a soldier if there are soldiers to rescue
	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	return AlienHQ.CapturedSoldiers.Length > 0;
}

static function GenerateRescueSoldierReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference ActionRef)
{
	//local XComGameStateHistory History;
	//local XComGameState_HeadquartersAlien AlienHQ;
	//local int CapturedSoldierIndex;
//
	//History = `XCOMHISTORY;
//
	//AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
//
	//// first check if the aliens have captured one of our soldiers. If so, then they get to be the reward
	//if(AlienHQ.CapturedSoldiers.Length > 0)
	//{
		//// pick a soldier to rescue and save them as the reward state
		//CapturedSoldierIndex = class'Engine'.static.GetEngine().SyncRand(AlienHQ.CapturedSoldiers.Length, "GenerateSoldierReward");
		//RewardState.RewardObjectReference = AlienHQ.CapturedSoldiers[CapturedSoldierIndex];
		//RewardState.RewardString = UnitState.GetName(eNameType_RankFull);
//
		//// remove the soldier from the captured unit list so they don't show up again later in the playthrough
		//AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
		//AlienHQ.CapturedSoldiers.Remove(CapturedSoldierIndex, 1);
	//}
	//else
	//{
		//// somehow the soldier to be rescued has been pulled out from under us! Generate one as a fallback.
		//class'X2StrategyElement_DefaultRewards'.static.GeneratePersonnelReward(RewardState, NewGameState, RewardScalar, RegionRef);
	//}
}

static function GiveRescueSoldierReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local XComGameState_CovertAction ActionState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local bool bExpire;
	local XComGameState_HeadquartersResistance ResHQ;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_SoldierCaptured'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(MissionRewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	
	// If the mission is designed to Rescue Mox, don't let it expire
	bExpire = false;

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_RescueSoldier'));
	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, bExpire, , MissionDuration);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	MissionState.ResistanceFaction = ActionState.Faction;

	// Then overwrite the reward reference so the mission is properly awarded when the Action completes
	RewardState.RewardObjectReference = MissionState.GetReference();
}

static function string GetRescueSoldierRewardString(XComGameState_Reward RewardState)
{
	return RewardState.GetMyTemplate().DisplayName;
}


// #######################################################################################
// ---------------------- DELEGATE HELPERS -----------------------------------------------
// #######################################################################################
static function CleanUpRewardWithoutRemoval(XComGameState NewGameState, XComGameState_Reward RewardState)
{
	// Blank Clean Up function so the RewardObjectReference is not removed, which is the default behavior
}

static function MissionRewardPopup(XComGameState_Reward RewardState)
{
	local XComGameState_MissionSite MissionSite;

	MissionSite = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (MissionSite != none && MissionSite.GetMissionSource().MissionPopupFn != none)
	{
		MissionSite.GetMissionSource().MissionPopupFn(MissionSite);
	}
}


private static function XComGameState_MissionSite BuildResOpMission(XComGameState NewGameState, X2MissionSourceTemplate MissionSource, optional bool bNoPOI)
{
	local X2StrategyElementTemplateManager StratMgr;
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_MissionCalendar CalendarState;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local array<XComGameState_Reward> MissionRewards;
	local array<XComGameState_WorldRegion> PossibleRegions;
	local float MissionDuration;
	local XComGameState_HeadquartersResistance ResHQ;
	
	// Calculate Mission Expiration timer
	MissionDuration = float((class'X2StrategyElement_XpackMissionSources'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_XpackMissionSources'.default.MissionMaxDuration - class'X2StrategyElement_XpackMissionSources'.default.MissionMinDuration + 1)) * 3600);

	PossibleRegions = MissionSource.GetMissionRegionFn(NewGameState);
	RegionState = PossibleRegions[0];

	// Generate the mission reward (either Scientist or Engineer)
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CalendarState = class'X2StrategyElement_XpackMissionSources'.static.GetMissionCalendar(NewGameState);
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(class'X2StrategyElement_XpackMissionSources'.static.SelectResistanceOpRewardType(CalendarState)));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	AddTacticalTagToRewardUnit(NewGameState, RewardState, 'VIPReward');
	MissionRewards.AddItem(RewardState);

	// All Resistance Op missions also give an Intel reward
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Intel'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(RewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));

	// If first on non-narrative, do not allow Swarm Defense since the reinforcement groups will be too strong
	if (!(XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings')).bXPackNarrativeEnabled) &&
		!CalendarState.HasCreatedMissionOfSource('MissionSource_ResistanceOp'))
	{
		MissionState.ExcludeMissionFamilies.AddItem("SwarmDefense");
	}

	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	
	if (!bNoPOI)
	{
		MissionState.PickPOI(NewGameState);
	}

	if (MissionState.GeneratedMission.Mission.MissionFamily == "GatherSurvivors" ||	MissionState.GeneratedMission.Mission.MissionFamily == "RecoverExpedition")
	{
		// Gather Survivors and Recover Expedition have an optional soldier reward
		RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Soldier'));
		RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
		AddTacticalTagToRewardUnit(NewGameState, RewardState, 'SoldierRewardA');
		MissionState.Rewards.AddItem(RewardState.GetReference());
	}

	if (MissionState.GeneratedMission.Mission.MissionFamily == "GatherSurvivors")
	{
		// Gather Survivors missions also have a second optional soldier to rescue
		RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Soldier'));
		RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
		AddTacticalTagToRewardUnit(NewGameState, RewardState, 'SoldierRewardB');
		MissionState.Rewards.AddItem(RewardState.GetReference());
	}

	return MissionState;
}


private static function AddTacticalTagToRewardUnit(XComGameState NewGameState, XComGameState_Reward RewardState, name TacticalTag)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (UnitState != none)
	{
		UnitState.TacticalTag = TacticalTag;
	}
}
