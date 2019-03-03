class X2StrategyElement_InfiltrationRewards extends X2StrategyElement config(Infiltration);

var config int P2_EXPIRATION_BASE_TIME;
var config int P2_EXPIRATION_VARIANCE;

var localized string GatherLeadText;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	// P1 dummy action rewards
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P1SupplyRaid'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P1DarkEvent'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P1Jailbreak'));

	// P2 dummy action rewards
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2DarkVIP'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2DarkEvent'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2Engineer'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2Scientist'));

	// P1 actual rewards
	Rewards.AddItem(CreateGatherLeadActivityReward());
	Rewards.AddItem(CreateGatherLeadTargetReward());
	Rewards.AddItem(CreateGatherLeadPersonnelReward());
	
	// P2 actual rewards
	Rewards.AddItem(CreateP2SupplyRaidReward());

	return Rewards;
}

/////////////////////
/// Dummy rewards ///
/////////////////////
// Used to show something in CA UI

static function X2DataTemplate CreateDummyActionRewardTemplate(name TemplateName)
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, TemplateName);
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static protected function bool RewardNotAvaliable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	// Since these rewards are only used for display purposes, we flag them as unavaliable to prevent P1/P2 CAs from randomly spawning
	return false;
}

//////////////////////
/// Actual rewards ///
//////////////////////
// Granted when the mission is completed

static function X2RewardTemplate CreateGatherLeadActivityReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadActivity');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadActivity;

	return Template;
}

static function X2RewardTemplate CreateGatherLeadTargetReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadTarget');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadTarget;

	return Template;
}

static function X2RewardTemplate CreateGatherLeadPersonnelReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadPersonnel');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadPersonnel;

	return Template;
}

static protected function string GatherLeadString(XComGameState_Reward RewardState)
{
	return default.GatherLeadText;
}

static protected function GiveGatherLeadActivity(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_CovertAction ActionState;
	local XComGameState_Reward NewRewardState;
	local array<StateObjectReference> DarkEvents;
	local int idx;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));
	DarkEvents = GetRandomDarkEvents(2);

	for (idx = 0; idx < DarkEvents.Length; idx++)
	{
		ActionState = SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkEvent');
		NewRewardState = XComGameState_Reward(NewGameState.GetGameStateForObjectID(ActionState.RewardRefs[0].ObjectID));
		NewRewardState.RewardObjectReference = DarkEvents[idx];
	}
	
	if(DarkEvents.Length == 0)
	{
		`RedScreen("CI: NO PENDING DARK EVENTS TO COUNTER, CANNOT SPAWN P2s");
		return;
	}
	else if(DarkEvents.Length == 1)
	{
		`RedScreen("CI: ONLY ONE DARK EVENT TO COUNTER, CANNOT SPAWN SECOND P2");
	}

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(, NewGameState);
}

static protected function GiveGatherLeadTarget(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));

	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2SupplyRaid');
	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkVIP');

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(, NewGameState);
}

static protected function GiveGatherLeadPersonnel(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));

	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2Engineer');
	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2Scientist');

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(, NewGameState);
}

static function StateObjectReference FindRandomMetFaction()
{
	local array<XComGameState_ResistanceFaction> MetFactions;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	
	// Find all met factions
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom)
		{
			MetFactions.AddItem(FactionState);
		}
	}

	// Pick one faction
	FactionState = MetFactions[`SYNC_RAND_STATIC(MetFactions.Length)];

	return FactionState.GetReference();
}

static protected function XComGameState_CovertAction SpawnCovertAction(XComGameState NewGameState, XComGameState_ResistanceFaction FactionState, name ActionTemplateName, optional bool bExpire = true)
{
	local X2StrategyElementTemplateManager StrategyTemplateManager;
	local X2CovertActionTemplate ActionTemplate;
	local StateObjectReference ActionRef;
	
	StrategyTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(StrategyTemplateManager.FindStrategyElementTemplate(ActionTemplateName));
	
	ActionRef = FactionState.CreateCovertAction(NewGameState, ActionTemplate, eFactionInfluence_Minimal);
	FactionState.CovertActions.AddItem(ActionRef);

	if (bExpire)
	{
		AddExpiration(NewGameState, ActionRef);
	}

	return XComGameState_CovertAction(NewGameState.GetGameStateForObjectID(ActionRef.ObjectID));
}

static protected function AddExpiration(XComGameState NewGameState, StateObjectReference ActionRef)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local TDateTime Expiration;

	Expiration = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	ActionExpirationManager = class'XComGameState_CovertActionExpirationManager'.static.GetExpirationManager();
	ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

	class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, default.P2_EXPIRATION_BASE_TIME * 24 + CreateExpirationVariance());

	ActionExpirationManager.AddActionExpirationInfo(ActionRef, Expiration);
}

static protected function int CreateExpirationVariance()
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND_STATIC(default.P2_EXPIRATION_VARIANCE);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND_STATIC(2) < 1;
	if (bNegVariance) Variance *= -1;

	return Variance;
}

static function array<StateObjectReference> GetRandomDarkEvents(int NumToSelect)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local array<StateObjectReference> DarkEvents;
	local array<StateObjectReference> Results;
	local int Index, RandIndex;

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	DarkEvents = AlienHQ.ChosenDarkEvents;

	// Favored Chosen Dark Event can't be cancelled, appears at end of ChosenDarkEvents list
	if(AlienHQ.HaveChosenActionDarkEvent())
	{
		DarkEvents.Remove((DarkEvents.Length - 1), 1);
	}

	for(Index = 0; Index < NumToSelect; Index++)
	{
		if(DarkEvents.Length > 0)
		{
			RandIndex = `SYNC_RAND_STATIC(DarkEvents.Length);
			Results.AddItem(DarkEvents[RandIndex]);
			DarkEvents.Remove(RandIndex, 1);
		}
	}

	return Results;
}

static function X2RewardTemplate CreateP2SupplyRaidReward()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2SupplyRaid');

	Template.GiveRewardFn = GiveSupplyRaidReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;
	
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function GiveSupplyRaidReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_CovertAction ActionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(ActionState.Region.ObjectID));	

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SupplyRaid'));
	
	MissionDuration = float((class'X2StrategyElement_DefaultRewards'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultRewards'.default.MissionMaxDuration - class'X2StrategyElement_DefaultRewards'.default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	RewardState.RewardObjectReference = MissionState.GetReference();
}

static function string GetMissionRewardString(XComGameState_Reward RewardState)
{
	return RewardState.GetMyTemplate().DisplayName;
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
