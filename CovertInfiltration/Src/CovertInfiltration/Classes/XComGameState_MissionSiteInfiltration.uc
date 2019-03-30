//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class contains the special logic used for
//           infiltration missions, such as autoselecting the
//           mission squad from the infiltration Covert Action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_MissionSiteInfiltration extends XComGameState_MissionSite config(Infiltration);

var StateObjectReference CorrespondingActionRef;
var array<name> AppliedFlatRisks;

var array<StateObjectReference> SoldiersOnMission;

var config array<int> OverInfiltartionThresholds;

var array<name> SelectedOverInfiltartionBonuses;
var int OverInfiltartionBonusesGranted;

/////////////
/// Setup ///
/////////////

function SetupFromAction(XComGameState NewGameState, XComGameState_CovertAction Action)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());
	
	if (MissionInfo.PreMissionSetup != none)
	{
		MissionInfo.PreMissionSetup(NewGameState, self, MissionInfo);
	}

	CopyDataFromAction(Action);
	Source = class'X2Helper_Infiltration'.static.GetCovertMissionSource(MissionInfo).DataName;
	Rewards = MissionInfo.InitializeRewards(NewGameState, self, MissionInfo);

	InitalizeGeneratedMission();
	SelectPlotAndBiome();
	ApplyFlatRisks();
	UpdateSitrepTags();
	SelectOverInfiltrationBonuses();

	SetSoldiersFromAction(Action);

	`HQPRES.NotifyBanner("Mission ready",, GetMissionObjectiveText(), GetMissionDescription(), eUIState_Good);
	`GAME.GetGeoscape().Pause();
}

protected function CopyDataFromAction(XComGameState_CovertAction Action)
{
	local CovertActionRisk Risk;

	// Copy over the location data
	Location.x = Action.Location.x;
	Location.y = Action.Location.y;
	Continent  = Action.Continent;
	Region = Action.Region;

	// Set the action ref and copy over the applied risks
	CorrespondingActionRef = Action.GetReference();
	AppliedFlatRisks.Length = 0;

	foreach ActionState.Risks(Risk)
	{
		if (Risk.bOccurs)
		{
			foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskSitRep)
			{
				if (FlatRiskSitRep.FlatRiskName == Risk.RiskTemplateName)
				{
					AppliedFlatRisks.AddItem(Risk.RiskTemplateName);
				}
			}
		}
	}

	// The mission phase starts once the action finishes (100%)
	ExpirationDateTime = TimerStartDateTime = Action.EndDateTime;

	// And ends at 200%
	class'X2StrategyGameRulesetDataStructures'.static.AddHours(ExpirationDateTime, Action.HoursToComplete);
}

protected function InitalizeGeneratedMission()
{
	local XComTacticalMissionManager MissionMgr;
	local X2RewardTemplate MissionReward;
	local GeneratedMissionData EmptyData;
	local string AdditionalTag;

	MissionMgr = `TACTICALMISSIONMGR;
	GeneratedMission = EmptyData;
	
	GeneratedMission.MissionID = ObjectID;
	GeneratedMission.LevelSeed = class'Engine'.static.GetEngine();
	
	GeneratedMission.Mission = MissionMgr.GetMissionDefinitionForSourceReward(Source, MissionReward.DataName, ExcludeMissionFamilies, ExcludeMissionTypes);
	GeneratedMission.SitReps = GeneratedMission.Mission.ForcedSitreps;

	if(GeneratedMission.Mission.sType == "")
	{
		`Redscreen("GetMissionDataForSourceReward() failed to generate a mission with: \n"
						$ " Source: " $ Source $ "\n RewardType: " $ MissionReward.DisplayName);
	}

	foreach AdditionalRequiredPlotObjectiveTags(AdditionalTag)
	{
		GeneratedMission.Mission.RequiredPlotObjectiveTags.AddItem(AdditionalTag);
	}

	MissionReward = X2RewardTemplate(`XCOMHISTORY.GetGameStateForObjectID(Rewards[0].ObjectID));
	GeneratedMission.MissionQuestItemTemplate = MissionMgr.ChooseQuestItemTemplate(Source, MissionReward, GeneratedMission.Mission, DarkEvent.ObjectID > 0);

	// Cosmetic stuff

	if(GetMissionSource().BattleOpName != "")
	{
		GeneratedMission.BattleOpName = GetMissionSource().BattleOpName;
	}
	else
	{
		GeneratedMission.BattleOpName = class'XGMission'.static.GenerateOpName(false);
	}

	GenerateMissionFlavorText();
}

protected function SelectPlotAndBiome()
{
	local PlotTypeDefinition PlotTypeDef;
	local XComParcelManager ParcelMgr;
	local string Biome;

	ParcelMgr = `PARCELMGR;

	// Find a plot that supports the biome and the mission
	// Note that here we only support sitrep plot filters for forced sitreps
	// As we cannot change the plot as sitreps are added/removed
	SelectBiomeAndPlotDefinition(GeneratedMission.Mission, Biome, GeneratedMission.Plot, GeneratedMission.SitReps);

	// Add SitReps forced by Plot Type
	PlotTypeDef = ParcelMgr.GetPlotTypeDefinition(GeneratedMission.Plot.strType);

	foreach PlotTypeDef.ForcedSitReps(SitRepName)
	{
		if (
			GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE &&
			(SitRepName != 'TheLost' || GeneratedMission.SitReps.Find('TheHorde') == INDEX_NONE)
		)
		{
			GeneratedMission.SitReps.AddItem(SitRepName);
		}
	}

	// At this point normall the CHL calls DLCInfo::PostSitRepCreation hook
	// TODO: decide what to do with that hook since we change sitreps later

	// the plot we find should either have no defined biomes, or the requested biome type
	if (GeneratedMission.Plot.ValidBiomes.Length > 0)
	{
		GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(Biome);
	}
}

protected function ApplyFlatRisks()
{
	local ActionFlatRiskSitRep FlatRiskMapping;
	local name SitRepName;
	local name RiskName;
	local int i;

	foreach AppliedFlatRisks(RiskName)
	{
		i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', RiskName);
		SitRepName = class'X2Helper_Infiltration'.default.FlatRiskSitReps;

		if (GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE)
		{
			GeneratedMission.SitReps.AddItem(SitRepName);
		}
	}
}

protected function SelectOverInfiltrationBonuses()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local X2CardManager CardManager;
	local X2DataTemplate Template;
	local string SelectedBonus;
	local name DeckName;
	local int i;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();

	// Build the decks
	foreach TemplateManager.IterateTemplates(Template, none)
	{
		BonusTemplate = X2OverInfiltrationBonusTemplate(Template);
		if (BonusTemplate == none) continue;

		CardManager.AddCardToDeck(
			name('OverInfiltrationBonusesT' $ BonusTemplate.Tier),
			string(BonusTemplate.DataName),
			BonusTemplate.Weight > 0 ? BonusTemplate.Weight : 1
		);
	}

	// Reset the bonuses just in case
	SelectedOverInfiltartionBonuses.Length = 0;
	SelectedOverInfiltartionBonuses.Length = OverInfiltartionThresholds.Length;

	for (i = 0; i < OverInfiltartionThresholds.Length; i++)
	{
		DeckName = name('OverInfiltrationBonusesT' $ i);

		if (CardManager.SelectNextCardFromDeck(DeckName, SelectedBonus, ValidateOverInfiltrationBonus,, false))
		{
			BonusTemplate = X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(name(SelectedBonus)));
			SelectedOverInfiltartionBonuses[i] = name(SelectedBonus);

			if (!BonusTemplate.DoNotMarkUsed)
			{
				CardManager.MarkCardUsed(DeckName, SelectedBonus);
			}
		}
	}
}

protected function bool ValidateOverInfiltrationBonus(string CardLabel, Object ValidationData)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;

	BonusTemplate = X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(name(CardLabel)));
	
	if (BonusTemplate == none)
	{
		return;
	}

	if (BonusTemplate.IsAvaliableFn != none && !BonusTemplate.IsAvaliableFn(BonusTemplate, self))
	{
		return false;
	}

	return true;
}

protected function SetSoldiersFromAction(XComGameState_CovertAction Action)
{
	local XComGameState_StaffSlot SlotState;
	local int idx;

	// Just in case somebody was here before
	SoldiersOnMission.Length = 0;

	for (idx = 0; idx < Action.StaffSlots.Length; idx++)
	{
		SlotState = Action.GetStaffSlot(idx);

		if (SlotState != none && SlotState.IsSoldierSlot() && SlotState.IsSlotFilled())
		{
			SoldiersOnMission.AddItem(SlotState.GetAssignedStaffRef());
		}
	}
}

function UpdateSitrepTags()
{
	// Reworked this function to remove tac tags if sitreps are removed

	local X2SitRepTemplateManager SitRepMgr;
	local X2SitRepTemplate SitRepTemplate;
	local name SitRepTemplateName, GameplayTag;
	local array<name> RequiredTags;
	local int i;

	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// Collect needed tags
	foreach GeneratedMission.SitReps(SitRepTemplateName)
	{
		SitRepTemplate = SitRepMgr.FindSitRepTemplate(SitRepTemplateName);

		foreach SitRepTemplate.TacticalGameplayTags(GameplayTag)
		{
			RequiredTags.AddItem(GameplayTag);
		}
	}

	// Remove obsolete tags
	for (i = 0; i < TacticalGameplayTags.Length; ++i) {
		if (RequiredTags.Find(TacticalGameplayTags[i]) == INDEX_NONE) {
			TacticalGameplayTags.Remove(i, 1);
			i--;
		}
	}

	// Add missing tags
	foreach RequiredTags(GameplayTag)
	{
		if(TacticalGameplayTags.Find(GameplayTag) == INDEX_NONE)
		{
			TacticalGameplayTags.AddItem(GameplayTag);
		}
	}
}

/////////////////
/// Overinfil ///
/////////////////

function UpdateGameBoard()
{
	local XComGameState NewGameState;
	local XComGameState_MissionSiteInfiltration NewMissionState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local array<int> SortedThresholds;

	// Check if we should give an overinfil bonus
	// Do this before showing the screen to support 200% rewards

	SortedThresholds = OverInfiltartionThresholds;
	SortedThresholds.Sort(CompareThresholds);

	if (
		OverInfiltartionBonusesGranted < SortedThresholds.Length && // Do we still have bonuses to grant?
		SortedThresholds[OverInfiltartionBonusesGranted] >= GetCurrentInfilInt() // Should we grant the next one
	)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Give over infiltartion bonus");
		NewMissionState = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', ObjectID));
		BonusTemplate = X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(SelectedOverInfiltartionBonuses[OverInfiltartionBonusesGranted]));

		BonusTemplate.ApplyFn(NewGameState, BonusTemplate, self);
		OverInfiltartionBonusesGranted++;

		`SubmitGamestate(NewGameState);
		`HQPRES.NotifyBanner("Overinfil bonus",, BonusTemplate.BonusName, BonusTemplate.BonusDescription, eUIState_Good);
		`GAME.GetGeoscape().Pause();
	}

	// TODO the chosen!!!

	if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpirationDateTime, GetCurrentTime()))
	{
		EnablePreventTick();
		MissionSelected();
	}
}

function float GetCurrentOverInfil()
{
	local float FullDurationDiff, CurrentDiff;

	// Use seconds so that we support 200% tiers
	FullDurationDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(ExpirationDateTime, TimerStartDateTime);
	CurrentDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(ExpirationDateTime, GetCurrentTime());

	return 1 - CurrentDiff / FullDurationDiff;
}

function float GetCurrentInfil()
{
	return 1 + GetCurrentOverInfil();
}

function int GetCurrentInfilInt()
{
	return Round(GetCurrentInfil() * 100);
}

protected function int CompareThresholds (int A, int B)
{
	if (A == B) return 0;

	return A < B ? 1 : -1;
}

protected function EventListenerReturn OnPreventGeoscapeTick(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIMission_Infiltrated MissionUI;
	local XComHQPresentationLayer HQPres;
	local UIStrategyMap StrategyMap;
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'PreventGeoscapeTick') return ELR_NoInterrupt;

	HQPres = `HQPRES;
	StrategyMap = HQPres.StrategyMap2D;
	
	// Don't popup anything while the Avenger or Skyranger are flying
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight)
	{
		MissionSelected();

		Tuple.Data[0].b = true;
		return ELR_InterruptListeners;
	}

	return ELR_NoInterrupt;
}

function MissionSelected()
{
	local UIMission_Infiltrated MissionUI;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	MissionUI = HQPres.Spawn(class'UIMission_Infiltrated', HQPres);
	MissionUI.MissionRef = GetReference();
	HQPres.ScreenStack.Push(MissionUI);
}

//////////////
/// Launch ///
//////////////

function bool RequiresAvenger()
{
	// Does not require the Avenger at the mission site
	return false;
}

function SelectSquad()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_StaffSlot SlotState;
	local StateObjectReference SoldierRef;
	local XComGameState_Unit Soldier;
	
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Set up infiltrating squad");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	
	// Soldiers are no longer on covert action
	foreach SoldiersOnMission(SoldierRef)
	{
		Soldier = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SoldierRef.ObjectID));
		SlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Soldier.StaffingSlot.ObjectID));
		SlotState.EmptySlot(NewGameState);
	}

	// Replace the squad with the soldiers who were on the Covert Action
	XComHQ.Squad = SoldiersOnMission;

	// This isn't needed to properly spawn units into battle, but without this
	// the transition screen shows last selection in streategy, not people on this mission
	XComHQ.AllSquads.Length = 1;
	XComHQ.AllSquads[0].SquadMembers = SoldiersOnMission;
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function StartMission()
{
	local XGStrategy StrategyGame;
	
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	
	// Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
	ConfirmMission();
}

////////////
/// Misc ///
////////////

function RemoveEntity(XComGameState NewGameState)
{
	super.RemoveEntity(NewGameState);
	UnRegisterFromEvents();
}

////////////////////////
/// Event management ///
////////////////////////

protected function EnablePreventTick()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'PreventGeoscapeTick', OnPreventGeoscapeTick);
}

protected function UnRegisterFromEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.UnRegisterFromAllEvents(ThisObj);
}

///////////////////////////////
/// Disabled base functions ///
///////////////////////////////

function BuildMission(X2MissionSourceTemplate MissionSource, Vector2D v2Loc, StateObjectReference RegionRef, array<XComGameState_Reward> MissionRewards, optional bool bAvailable=true, optional bool bExpiring=false, optional int iHours=-1, optional int iSeconds=-1, optional bool bUseSpecifiedLevelSeed=false, optional int LevelSeedOverride=0, optional bool bSetMissionData=true)
{
	FunctionNotSupported("BuildMission");
}

private function FunctionNotSupported(string CalledFunction)
{
	`RedScreen("XComGameState_MissionSiteInfiltration doesn't support" @ CalledFunction);
}

defaultproperties
{
	Available = true;
	Expiring = false;
}