//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains functions to control and
//           retrieve X2InfiltrationMod templates.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationModTemplateManager extends X2DataTemplateManager config(Infiltration);

var config int PERSONNEL_INFIL;

static function X2InfiltrationModTemplateManager GetInfilTemplateManager()
{
    return X2InfiltrationModTemplateManager(class'Engine'.static.GetTemplateManager(class'X2InfiltrationModTemplateManager'));
}

function X2InfiltrationModTemplate GetInfilTemplateFromItem(name ItemTemplate)
{
	local X2InfiltrationModTemplate InfilTemplate;
	InfilTemplate = X2InfiltrationModTemplate(FindDataTemplate(class'X2InfiltrationMod'.static.GetInfilName(ItemTemplate)));
	return InfilTemplate;
}

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
		TotalInfil = GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()).InfilModifier;
		ItemCategory = InventoryItem.GetMyTemplate().ItemCat;

		foreach CurrentInventory(MultiplierItem)
		{
			MultCategory = GetInfilTemplateFromItem(MultiplierItem.GetMyTemplateName()).MultCategory;
			Multiplier = GetInfilTemplateFromItem(MultiplierItem.GetMyTemplateName()).InfilMultiplier;

			if(MultCategory == ItemCategory)
			{
				TotalInfil = TotalInfil * Multiplier;
			}
		}

		UnitInfiltration += TotalInfil;
	}

	return UnitInfiltration;
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2InfiltrationMod'
	ManagedTemplateClass=class'X2InfiltrationModTemplate'
}