//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains a variety of tools
//           for this mod and others to interact with
//           the infiltration template system.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration extends Object config(Infiltration);

var config int PERSONNEL_INFIL;
var config int PERSONNEL_DETER;
var config float OVERLOADED_MULT_1;
var config float OVERLOADED_MULT_2;

var config array<int> RANKS_DETER;

// useful when squad is not in HQ
static function array<StateObjectReference> GetCovertActionSquad(XComGameState_CovertAction CovertAction)
{
	local array<StateObjectReference> CurrentSquad;
	local CovertActionStaffSlot CovertActionSlot;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit UnitState;
	
	foreach CovertAction.StaffSlots(CovertActionSlot)
	{
		SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		if (SlotState.IsSlotFilled())
		{
			UnitState = SlotState.GetAssignedStaff();
			if (UnitState.IsSoldier())	
			{
				CurrentSquad.AddItem(UnitState.GetReference());
			}
		}
	}

	return CurrentSquad;
}

static function int GetSquadInfiltration(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int	TotalInfiltration, FinalInfiltration, SquadSize, i;
	
	`LOG(" --- ");

	SquadSize = 0;
	TotalInfiltration = 0;
	foreach Soldiers(UnitRef)
	{
		if(UnitRef.ObjectID != 0) SquadSize += 1;
		TotalInfiltration += GetSoldierInfiltration(UnitRef);
	}
	
	`LOG("INFILTRATION DURATION:");
	`LOG(TotalInfiltration);
	
	FinalInfiltration = TotalInfiltration;

	if(SquadSize > 5)
	{
		// 6 soldiers in the squad, if infil size 2 is not purchased then...
		if(!`XCOMHQ.HasSoldierUnlockTemplate('InfiltrationSize2'))
		{
			if(!`XCOMHQ.HasSoldierUnlockTemplate('InfiltrationSize1'))
			{
				// Player has neither upgrade so combine both mults
				FinalInfiltration = TotalInfiltration * (default.OVERLOADED_MULT_1 + default.OVERLOADED_MULT_2 - 1);
				`LOG("Applying both Mults");
			}
			else
			{
				// Player has the first upgrade so apply mult 2 only
				FinalInfiltration = TotalInfiltration * default.OVERLOADED_MULT_2;
				`LOG("Applying Mult2");
			}
		}
	}
	else if(SquadSize > 4)
	{
		// 5 soldiers in the squad, if infil size 1 is not purchased then...
		if(!`XCOMHQ.HasSoldierUnlockTemplate('InfiltrationSize1'))
		{
			// Player doesn't have the upgrade so apply mult 1
			FinalInfiltration = TotalInfiltration * default.OVERLOADED_MULT_1;
			`LOG("Applying Mult1");
		}
	}

	`LOG(FinalInfiltration);
	`LOG(" --- ");

	return FinalInfiltration;
}

static function int GetSoldierInfiltration(StateObjectReference UnitRef)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item		InventoryItem;
	local X2InfiltrationModTemplate Template;
	local float						UnitInfiltration; // using float until value is returned to prevent casting inaccuracy

	local X2InfiltrationModTemplateManager InfilMgr;
	InfilMgr = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	History = `XCOMHISTORY;

	if(UnitRef.ObjectID <= 0)
		return 0;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

	if(!UnitState.IsSoldier())
		return default.PERSONNEL_INFIL;

	UnitInfiltration = 0;

	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		Template = InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName());

		if (Template == none)
			continue;

		UnitInfiltration += (float(Template.HoursAdded) * GetUnitInfiltrationMultiplierForCategory(UnitState, InventoryItem.GetMyTemplate().ItemCat));
	}

	return int(UnitInfiltration);
}

static function float GetUnitInfiltrationMultiplierForCategory(XComGameState_Unit Unit, name category)
{
	local float InfiltrationMultiplier;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2InfiltrationModTemplate Template;
	local X2InfiltrationModTemplateManager InfiltrationManager;

	InfiltrationManager = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	InfiltrationMultiplier = 1.0;

	CurrentInventory = Unit.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		Template = InfiltrationManager.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName());

		if (Template == none)
			continue;

		if (Template.MultCategory == category)
			InfiltrationMultiplier *= Template.InfilMultiplier;
	}

	return InfiltrationMultiplier;
}

static function int GetSquadDeterrence(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int					TotalDeterrence;

	TotalDeterrence = 0;
	foreach Soldiers(UnitRef)
	{
		TotalDeterrence += GetSoldierDeterrence(Soldiers, UnitRef);
	}

	return TotalDeterrence;
}

static function int GetSoldierDeterrence(array<StateObjectReference> Soldiers, StateObjectReference UnitRef)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item		InventoryItem;
	local int						UnitDeterrence;

	local X2InfiltrationModTemplateManager InfilMgr;
	InfilMgr = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	History = `XCOMHISTORY;

	if(UnitRef.ObjectID <= 0)
		return 0;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

	if(!UnitState.IsSoldier())
		return default.PERSONNEL_DETER;

	UnitDeterrence = 0;

	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		if(InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()) != none)
		{
			UnitDeterrence += InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()).Deterrence;
		}
	}

	UnitDeterrence += default.RANKS_DETER[UnitState.GetSoldierRank()];

	return UnitDeterrence;
}

static function DestroyWillRecoveryProject(XComGameState NewGameState, StateObjectReference UnitRef)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;

	History = `XCOMHISTORY;
	XComHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddXComHQ(NewGameState);
	
	foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
	{
		if(WillProject.ProjectFocus == UnitRef)
		{
			XComHQ.Projects.RemoveItem(WillProject.GetReference());
			NewGameState.RemoveStateObject(WillProject.ObjectID);
		}
	}
}

static function CreateWillRecoveryProject(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddXComHQ(NewGameState);
	WillProject = XComGameState_HeadquartersProjectRecoverWill(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectRecoverWill'));
	WillProject.SetProjectFocus(UnitState.GetReference(), NewGameState);

	XComHQ.Projects.AddItem(WillProject.GetReference());
}

static function X2MissionSourceTemplate GetCovertMissionSource(X2CovertMissionInfoTemplate MissionInfo)
{
	local X2StrategyElementTemplateManager StratMgr;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	return X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate(MissionInfo.MissionSource));
}

static function array<X2RewardTemplate> GetCovertMissionRewards(X2CovertMissionInfoTemplate MissionInfo)
{
	local array<X2RewardTemplate> Rewards;
	local int i;
	local X2StrategyElementTemplateManager StratMgr;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	for(i = 0; i < MissionInfo.MissionRewards.Length; i++)
	{
		Rewards.AddItem(X2RewardTemplate(StratMgr.FindStrategyElementTemplate(MissionInfo.MissionRewards[i])));
	}

	return Rewards;
}

static function bool IsInfiltrationAction(XComGameState_CovertAction Action)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());

	return MissionInfo != none;
}

static function bool ReturnFalse()
{
	return false;
}

static function RecalculateActionRisks(StateObjectReference ActionRef)
{
	local XComGameState_CovertAction ActionState;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: recalculate action risk chances");
	ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
	ActionState.RecalculateRiskChanceToOccurModifiers();

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}