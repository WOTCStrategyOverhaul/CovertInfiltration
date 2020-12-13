
class X2StrategyElement_DefaultComplications extends X2StrategyElement config(Infiltration);

// Missions that feature lootcrates or other rewards not in its X2RewardTemplates
var config array<name> InterceptMissions;

// Items that can have their quantity halved by interception complications
var config array<name> InterceptableItems;

// Chains that are of great importance to ADVENT and can have Open Provocation complications
var config array<name> ImportantChains;

// Various values for the complications
var config float REWARD_INTERCEPTION_TAKENLOOT;
var config int CHOSEN_SURVEILLANCE_KNOWLEDGE;
var config int OPEN_PROVOCATION_DAYSREDUCED;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Complications;
	
	Complications.AddItem(CreateRewardInterceptionTemplate());
	Complications.AddItem(CreateChosenSurveillanceTemplate());
	Complications.AddItem(CreateOpenProvocationTemplate());

	return Complications;
}

static function X2DataTemplate CreateRewardInterceptionTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_RewardInterception');

	Template.StateClass = class'XComGameState_Complication_RewardInterception';
	Template.bExclusiveOnChain = true;
	Template.bNoSimultaneous = true;

	Template.OnChainComplete = SpawnRescueMission;
	Template.CanBeChosen = SupplyAndIntelChains;

	Template.OnExitPostMissionSequence = TriggerRewardInterceptionPopup;

	return Template;
}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_Complication ComplicationState)
{
	local XComGameState_Complication_RewardInterception ActualComplicationState;
	local XComGameState_ActivityChain InterceptedChainState, SpawnedChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState_Activity ActivityState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_ResourceContainer TotalResContainer;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	InterceptedChainState = ComplicationState.GetActivityChain();
	ActivityState = InterceptedChainState.GetLastActivity();
	if (!ActivityState.IsSuccessfullAtLeastPartially())
	{
		// Failed or expired. No rewards in any case
		return;
	}

	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (ActivityTemplate == none)
	{
		`RedScreen("Failed to find source activity!");
		return;
	}

	// At times we fail to collect anything :(
	// If that happens, do not spawn the rescue chain/mission (it will be empty)
	ActualComplicationState = XComGameState_Complication_RewardInterception(ComplicationState);
	TotalResContainer = XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(ActualComplicationState.ResourceContainerRef.ObjectID));
	if (TotalResContainer.Packages.Length < 1)
	{
		`RedScreen("Cannot spawn reward interception mission - nothing was intercepted");
		return;	
	}

	// All checks passed - spawn the mission

	if (ActivityTemplate.MissionRewards.Find('Reward_Intel') > INDEX_NONE || ActivityTemplate.MissionRewards.Find('Reward_SmallIntel') > INDEX_NONE)
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_IntelIntercept'));
	}
	else
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_SupplyIntercept'));
	}

	SpawnedChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	SpawnedChainState.FactionRef = InterceptedChainState.FactionRef;
	SpawnedChainState.PrimaryRegionRef = InterceptedChainState.PrimaryRegionRef;

	TotalResContainer = XComGameState_ResourceContainer(NewGameState.ModifyStateObject(class'XComGameState_ResourceContainer', TotalResContainer.ObjectID));
	TotalResContainer.CombineLoot();

	SpawnedChainState.ChainObjectRefs.AddItem(TotalResContainer.GetReference());
	SpawnedChainState.StartNextStage(NewGameState);
}

function bool SupplyAndIntelChains(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate_Mission ActivityTemplate;

	ActivityState = ChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none) return false;
	
	// and if there is a supply or intel rewarding chain
	if (IsInterceptableActivity(ActivityTemplate))
	{
		return true;
	}

	return false;
}

static function bool IsInterceptableActivity(X2ActivityTemplate Template)
{
	return default.InterceptMissions.Find(Template.DataName) > INDEX_NONE;
}

static function bool IsInterceptableItem(name TemplateName)
{
	return default.InterceptableItems.Find(TemplateName) > INDEX_NONE;
}

static protected function TriggerRewardInterceptionPopup (XComGameState_Complication ComplicationState)
{
	local XComGameState_Complication_RewardInterception ActualComplicationState;
	local XComGameState_ResourceContainer TotalResContainer;
	local XComGameState NewGameState;

	ActualComplicationState = XComGameState_Complication_RewardInterception(ComplicationState);
	TotalResContainer = XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(ActualComplicationState.ResourceContainerRef.ObjectID));

	// Do nothing if we didn't collect anything yet (e.g. non-last mission in chain)
	if (TotalResContainer.Packages.Length < 1) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Combining intercepted loot for post mission popup");
	TotalResContainer = XComGameState_ResourceContainer(NewGameState.ModifyStateObject(class'XComGameState_ResourceContainer', TotalResContainer.ObjectID));
	TotalResContainer.CombineLoot();
	`SubmitGameState(NewGameState);
	
	// Queue the popup
	class'UIUtilities_Infiltration'.static.RewardsIntercepted(TotalResContainer.GetReference());
}

static function X2DataTemplate CreateChosenSurveillanceTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_ChosenSurveillance');

	Template.bExclusiveOnChain = true;
	Template.bNoSimultaneous = true;
	
	Template.OnChainComplete = IncreaseRandomChosenKnowledge;
	Template.CanBeChosen = IfChosenActivated;

	return Template;
}

function bool IfChosenActivated(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen ChosenState;
	local StateObjectReference ChosenRef;
	
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	if (AlienHQ.bChosenActive)
	{
		foreach AlienHQ.AdventChosen(ChosenRef)
		{
			ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(ChosenRef.ObjectID));
			
			if (!ChosenState.bDefeated)
			{
				return true;
			}
		}
	}

	return false;
}

function IncreaseRandomChosenKnowledge(XComGameState NewGameState, XComGameState_Complication ComplicationState)
{
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen Chosen;
	local StateObjectReference ChosenRef;
	local XComGameStateHistory History;
	local int ActiveChosen, Roll;

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ActiveChosen = 0;

	foreach AlienHQ.AdventChosen(ChosenRef)
	{
		Chosen = XComGameState_AdventChosen(History.GetGameStateForObjectID(ChosenRef.ObjectID));
		if(Chosen.bMetXCom)
		{
			ActiveChosen++;
		}
	}

	Roll = `SYNC_RAND_STATIC(ActiveChosen);

	do
	{
		if(Roll >= AlienHQ.AdventChosen.Length)
		{
			`RedScreen("NO CHOSEN TO SELECT");
			return;
		}
		Chosen = XComGameState_AdventChosen(History.GetGameStateForObjectID(AlienHQ.AdventChosen[Roll].ObjectID));
		Roll++;
	}
	until(Chosen.bMetXCom);

	Chosen.ModifyKnowledgeScore(NewGameState, default.CHOSEN_SURVEILLANCE_KNOWLEDGE);
}

static function X2DataTemplate CreateOpenProvocationTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_OpenProvocation');

	Template.bExclusiveOnChain = true;
	Template.bNoSimultaneous = true;

	Template.OnChainComplete = ReduceRetaliationTimer;
	Template.CanBeChosen = AnyImportantChain;

	return Template;
}

function bool AnyImportantChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	// and if this chain is super important to the ayys
	if(default.ImportantChains.Find(ChainState.GetMyTemplateName()) == INDEX_NONE)
	{
		return false;
	}
	
	// then add this complication to the chain
	return true;
}

static function ReduceRetaliationTimer(XComGameState NewGameState, XComGameState_Complication ComplicationState)
{
	local XComGameStateHistory History;
	local XComGameState_MissionCalendar CalendarState;
	local float TimeToRemove;
	local TDateTime SpawnDate;
	local int Index;

	History = `XCOMHISTORY;
	CalendarState = XComGameState_MissionCalendar(History.GetSingleGameStateObjectForClass(class'XComGameState_MissionCalendar'));
	CalendarState = XComGameState_MissionCalendar(NewGameState.ModifyStateObject(class'XComGameState_MissionCalendar', CalendarState.ObjectID));
	TimeToRemove = float(default.OPEN_PROVOCATION_DAYSREDUCED * 24 * 60 * 60);

	Index = CalendarState.CurrentMissionMonth.Find('MissionSource', 'MissionSource_Retaliation');

	if(Index != INDEX_NONE)
	{
		SpawnDate = CalendarState.CurrentMissionMonth[Index].SpawnDate;
		class'X2StrategyGameRulesetDataStructures'.static.RemoveTime(SpawnDate, TimeToRemove);
		CalendarState.CurrentMissionMonth[Index].SpawnDate = SpawnDate;
	}
	else
	{
		CalendarState.RetaliationSpawnTimeDecrease = TimeToRemove;
	}
}