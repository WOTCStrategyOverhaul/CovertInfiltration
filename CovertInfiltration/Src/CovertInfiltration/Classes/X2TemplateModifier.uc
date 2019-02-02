//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Modifys Templates in order to make infinite items single build instead
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class X2TemplateModifier extends Object config (SingleBuildItems);

struct SingleBuildItem
{
	var name SchematicName;
	var int TradingPostValue;
	
	var array<StrategyCost> Costs;
};

var config array<SingleBuildItem> SingleBuildItems;

function ModifyTemplates()
{
	local array<X2DataTemplate> DifficultyVariants;
	local X2ItemTemplateManager TemplateManager;
	local X2SchematicTemplate Schematic;
	local X2ItemTemplate Template;
	local SingleBuildItem Item;
	local int index;

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	foreach default.SingleBuildItems(Item)
	{
		Schematic = X2SchematicTemplate(TemplateManager.FindItemTemplate(Item.SchematicName));
		Template = TemplateManager.FindItemTemplate(Item.SchematicName);

		if (Schematic != none)
		{
			// cycle through and modify each difficulty variant for this template
			TemplateManager.FindDataTemplateAllDifficulties(Item.SchematicName, DifficultyVariants);
			for (index = 0; index < DifficultyVariants.Length; index++)
			{
				Schematic = X2SchematicTemplate(DifficultyVariants[index]);
				
				Schematic.bSquadUpgrade = false;
				Schematic.OnBuiltFn = BuildItem;
				Schematic.HideIfPurchased = '';
				Schematic.bOneTimeBuild = false;
				Schematic.Cost = Item.Costs[index];

				// only assign item template varaints if nessecary
				if (Template.bShouldCreateDifficultyVariants || index == 0)
				{
					Template = TemplateManager.FindItemTemplate(Schematic.ReferenceItemTemplate);

					Template.HideInInventory = false;
					Template.bInfiniteItem = false;
				}

				// if we only need to modify one schematic stop here
				if (!Schematic.bShouldCreateDifficultyVariants)
				{
					break;
				}
			}
		}
		else if (Template != none && Template.CreatorTemplateName != '')
		{
			// TODO: create difficulty variants for these schematics
			Schematic = X2SchematicTemplate(TemplateManager.FindItemTemplate(Template.CreatorTemplateName));
			
			// make sure we actually have a creator schematic for this template
			if (Schematic != none)
			{
				Template.HideInInventory = false;
				Template.bInfiniteItem = false;
				Template.TradingPostValue = Item.TradingPostValue;
				Template.CanBeBuilt = true;
				Template.bInfiniteItem = false;
				Template.BaseItem = 'None';
				Template.UpgradeItem = 'None';
				Template.CreatorTemplateName = 'None';
				Template.Requirements = Schematic.Requirements;
				Template.Cost = Item.Costs[0];
			}
		}
	}
}

function BuildItem(XComGameState NewGameState, XComGameState_Item ItemState)
{
	local X2ItemTemplateManager TemplateManager;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2SchematicTemplate Schematic;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_Item NewItem;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}
	
	if (XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
	}

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	Schematic = X2SchematicTemplate(ItemState.GetMyTemplate());
	ItemTemplate = TemplateManager.FindItemTemplate(Schematic.ReferenceItemTemplate);

	if(XComHQ.GetNumItemInInventory(ItemTemplate.DataName) > 0)
	{
		NewItem = XComHQ.GetItemByName(ItemTemplate.DataName);
		NewItem.Quantity++;
	}
	else
	{
		NewItem = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		NewItem.Quantity = 1;
		XComHQ.PutItemInInventory(NewGameState, NewItem);
	}
	
	NewGameState.AddStateObject(NewItem);
}
