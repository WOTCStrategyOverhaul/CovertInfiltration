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

var config array<int> RANKS_DETER;

static function int GetSquadInfiltration(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int					TotalInfiltration;

	TotalInfiltration = 0;
	foreach Soldiers(UnitRef)
	{
		TotalInfiltration += GetSoldierInfiltration(UnitRef);
	}

	return TotalInfiltration;
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

		UnitInfiltration += (float(Template.InfilModifier) * GetUnitInfiltrationMultiplierForCategory(UnitState, InventoryItem.GetMyTemplate().ItemCat));
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
