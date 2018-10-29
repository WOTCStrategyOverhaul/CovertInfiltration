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
var config int PERSONNEL_THREAT;

var config array<int> RANKS_THREAT;

function int GetSquadInfiltration(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int					TotalInfiltration;

	TotalInfiltration = 0;
	foreach Soldiers(UnitRef)
	{
		TotalInfiltration += GetSoldierInfiltration(Soldiers, UnitRef);
	}

	return TotalInfiltration;
}

function int GetSoldierInfiltration(array<StateObjectReference> Soldiers, StateObjectReference UnitRef)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item		InventoryItem, MultiplierItem;
	local int						UnitInfiltration;
	local int						TotalInfil;
	local name						ItemCategory, MultCategory;
	local float						Multiplier;

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
		if(InventoryItem != none)
		{
			TotalInfil = InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()).InfilModifier;
			ItemCategory = InventoryItem.GetMyTemplate().ItemCat;

			foreach CurrentInventory(MultiplierItem)
			{
				if(MultiplierItem != none)
				{
					MultCategory = InfilMgr.GetInfilTemplateFromItem(MultiplierItem.GetMyTemplateName()).MultCategory;
					Multiplier = InfilMgr.GetInfilTemplateFromItem(MultiplierItem.GetMyTemplateName()).InfilMultiplier;

					if(MultCategory == ItemCategory)
					{
						TotalInfil = TotalInfil * Multiplier;
					}
				}
			}
			UnitInfiltration += TotalInfil;
		}
	}

	return UnitInfiltration;
}

function int GetSquadThreat(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int					TotalThreat;

	TotalThreat = 0;
	foreach Soldiers(UnitRef)
	{
		TotalThreat += GetSoldierThreat(Soldiers, UnitRef);
	}

	return TotalThreat;
}

function int GetSoldierThreat(array<StateObjectReference> Soldiers, StateObjectReference UnitRef)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item		InventoryItem;
	local int						UnitThreat;

	local X2InfiltrationModTemplateManager InfilMgr;
	InfilMgr = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	History = `XCOMHISTORY;

	if(UnitRef.ObjectID <= 0)
		return 0;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

	if(!UnitState.IsSoldier())
		return default.PERSONNEL_THREAT;

	UnitThreat = 0;

	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		if(InventoryItem != none)
		{
			UnitThreat += InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()).InfilModifier;
		}
	}

	UnitThreat += default.RANKS_THREAT[UnitState.GetSoldierRank()];

	return UnitThreat;
}
