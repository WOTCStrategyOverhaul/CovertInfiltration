
class X2StrategyElement_DefaultComplications extends X2StrategyElement config(Infiltration);

// Missions that feature lootcrates or other rewards not in its X2RewardTemplates
var config array<name> LootcrateMissions;

// Items that can have their quantity halved by interception complications
var config array<name> InterceptableItems;

// Chains that are of great importance to ADVENT and can have Open Provocation complications
var config array<name> ImportantChains;

// Various values for the complications
var config int REWARDINTERCEPTION_MIN;
var config int REWARDINTERCEPTION_MAX;
var config bool REWARDINTERCEPTION_GUARANTEED;
var config float REWARDINTERCEPTION_TAKENLOOT;

var config int CHOSENSURVEILLANCE_MIN;
var config int CHOSENSURVEILLANCE_MAX;
var config bool CHOSENSURVEILLANCE_GUARANTEED;
var config int CHOSENSURVEILLANCE_KNOWLEDGE;

var config int OPENPROVOCATION_MIN;
var config int OPENPROVOCATION_MAX;
var config bool OPENPROVOCATION_GUARANTEED;
var config int OPENPROVOCATION_DAYSREDUCED;

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

	Template.MinChance = default.REWARDINTERCEPTION_MIN;
	Template.MaxChance = default.REWARDINTERCEPTION_MAX;
	Template.AlwaysSelect = default.REWARDINTERCEPTION_GUARANTEED;

	//Template.OnChainComplete = SpawnRescueMission;
	//Template.OnChainBlocked = DoNothing;
	//Template.OnManualTrigger = SpawnRescueMission;
	Template.CanBeChosen = SupplyAndIntelChains;

	return Template;
}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain InterceptedChainState)
{
	local XComGameState_ActivityChain SpawnedChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState_Activity ActivityState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local array<XComGameState_Item> SavedItems;
	local XComGameState_ResourceContainer ResContainer;
	local XComGameState_ResourceContainer TotalResContainer;
	local XComGameState_Complication ComplicationState;
	local int i, j;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	ActivityState = InterceptedChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none)
	{
		`RedScreen("Failed to find source activity!");
		return;
	}

	if (ActivityTemplate.MissionRewards.Find('Reward_Intel') > -1)
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

	ComplicationState = InterceptedChainState.FindComplication('Complication_RewardInterception');
	TotalResContainer = XComGameState_ResourceContainer(NewGameState.CreateStateObject(class'XComGameState_ResourceContainer'));

	if (ComplicationState != none)
	{
		`CI_Log("Output CompState:" @ ComplicationState.ComplicationObjectRefs.Length);
		for (i = 0; i < ComplicationState.ComplicationObjectRefs.Length; i++)
		{
			ResContainer = XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(ComplicationState.ComplicationObjectRefs[i].ObjectID));

			if (ResContainer != none)
			{
				for (j = 0; j < ResContainer.Packages.Length; j++)
				{
					`CI_Log("Adding package:" @ ResContainer.Packages[j].ItemType @ ResContainer.Packages[j].ItemAmount);
					TotalResContainer.Packages.AddItem(ResContainer.Packages[j]);
				}
			}
			else
			{
				`RedScreen("Failed to get container from ComplicationState!");
			}
		}
		if (ComplicationState.ComplicationObjectRefs.Length == 0)
		{
			// This is triggered, complicationobjectrefs is empty
			`RedScreen("ComplicationState has no stored objects!");
		}
	}
	else
	{
		`RedScreen("Failed to get ComplicationState!");
	}

	TotalResContainer.CombineLoot();
	SpawnedChainState.ChainObjectRefs.AddItem(TotalResContainer.GetReference());
	SpawnedChainState.StartNextStage(NewGameState);
}

function bool SupplyAndIntelChains(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain OtherChainState;
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate_Mission ActivityTemplate;

	ActivityState = ChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none) return false;
	
	// if this chain doesn't have any other complications

	if(ChainState.ComplicationRefs.Length != 0)
	{
		return false;
	}
	
	// and if there is a supply or intel rewarding chain
	if (IsLootcrateActivity(ActivityTemplate) || ActivityTemplate.MissionRewards.Find('Reward_Intel') > -1)
	{
		// and if no other chains already have this complication
		/*
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
		{
			if (OtherChainState.bEnded == false && OtherChainState.HasComplication('Complication_RewardInterception'))
			{
				return false;
			}
		}
		*/
		// then add this complication to the chain
		return true;
	}

	return false;
}

static function bool IsLootcrateActivity(X2ActivityTemplate Template)
{
	return default.LootcrateMissions.Find(Template.DataName) > -1;
}

static function bool IsInterceptableItem(X2ItemTemplate Template)
{
	return default.InterceptableItems.Find(Template.DataName) > -1;
}

static function X2DataTemplate CreateChosenSurveillanceTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_ChosenSurveillance');

	// Guaranteed to happen
	Template.MinChance = default.CHOSENSURVEILLANCE_MIN;
	Template.MaxChance = default.CHOSENSURVEILLANCE_MAX;
	Template.AlwaysSelect = default.CHOSENSURVEILLANCE_GUARANTEED;

	Template.OnChainComplete = IncreaseRandomChosenKnowledge;
	Template.CanBeChosen = IfChosenActivated;

	return Template;
}

function bool IfChosenActivated(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_ActivityChain OtherChainState;

	// if no other chains already have this complication
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
	{
		if (OtherChainState.bEnded == false && OtherChainState.HasComplication('Complication_ChosenSurveillance'))
		{
			return false;
		}
	}

	// and if this chain doesn't have any other complications

	if(ChainState.ComplicationRefs.Length != 0)
	{
		return false;
	}
	
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	// then add this complication to the chain
	return AlienHQ.bChosenActive;
}

function IncreaseRandomChosenKnowledge(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen Chosen;
	local StateObjectReference ChosenRef;
	local XComGameStateHistory History;
	local int ActiveChosen, Roll;

	History = `XCOMHISTORY;
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
		Chosen = XComGameState_AdventChosen(History.GetGameStateForObjectID(AlienHQ.AdventChosen[Roll].ObjectID));
		Roll++;
		if(Roll >= AlienHQ.AdventChosen.Length)
		{
			`RedScreen("NO CHOSEN TO SELECT");
			return;
		}
	}
	until(Chosen.bMetXCom);

	Chosen.ModifyKnowledgeScore(NewGameState, default.CHOSENSURVEILLANCE_KNOWLEDGE);
}

static function X2DataTemplate CreateOpenProvocationTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_ChosenSurveillance');

	// Guaranteed to happen
	Template.MinChance = default.OPENPROVOCATION_MIN;
	Template.MaxChance = default.OPENPROVOCATION_MAX;
	Template.AlwaysSelect = default.OPENPROVOCATION_GUARANTEED;

	Template.OnChainComplete = ReduceRetaliationTimer;
	Template.CanBeChosen = AnyImportantChain;

	return Template;
}

function bool IfChosenActivated(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain OtherChainState;

	// if no other chains already have this complication
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
	{
		if (OtherChainState.bEnded == false && OtherChainState.HasComplication('Complication_ChosenSurveillance'))
		{
			return false;
		}
	}

	// and if this chain doesn't have any other complications

	if(ChainState.ComplicationRefs.Length != 0)
	{
		return false;
	}
	
	// then add this complication to the chain
	return true;
}

static function ReduceRetaliationTimer(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameStateHistory History;
	local XComGameState_MissionCalendar CalendarState;
	local float TimeToRemove;
	local TDateTime SpawnDate;
	local int Index;

	History = `XCOMHISTORY;
	CalendarState = XComGameState_MissionCalendar(History.GetSingleGameStateObjectForClass(class'XComGameState_MissionCalendar'));
	CalendarState = XComGameState_MissionCalendar(NewGameState.ModifyStateObject(class'XComGameState_MissionCalendar', CalendarState.ObjectID));
	TimeToRemove = float(default.OPENPROVOCATION_REDUCTION * 24 * 60 * 60);

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