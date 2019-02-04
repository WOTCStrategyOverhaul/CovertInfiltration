//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Modifies Templates in order to make infinite items single build instead
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class X2Helper_CI_OPTC extends Object config (SingleBuildItems);

struct SingleBuildItem
{
	var name SchematicName;
	var int TradingPostValue;
	
	var array<StrategyCost> Costs;
};

var config array<SingleBuildItem> SingleBuildItems;

static function ModifyTemplates()
{
	local array<X2DataTemplate> DifficultyVariants;
	local X2ItemTemplateManager TemplateManager;
	local X2SchematicTemplate Schematic;
	local X2ItemTemplate Template;
	local SingleBuildItem Item;
	local int index, ValidIndex;

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	foreach default.SingleBuildItems(Item)
	{
		Template = TemplateManager.FindItemTemplate(Item.SchematicName);
		Schematic = X2SchematicTemplate(Template);

		if (Schematic != none)
		{
			// cycle through and modify each difficulty variant for this template
			TemplateManager.FindDataTemplateAllDifficulties(Item.SchematicName, DifficultyVariants);
			for (index = 0; index < DifficultyVariants.Length - 1; index++)
			{
				Schematic = X2SchematicTemplate(DifficultyVariants[index]);
				
				ValidIndex = index;
				// if no cost value was set for this difficulty find the last useable value
				while (ValidIndex > 0 && Item.Costs[ValidIndex].ResourceCosts.Length == 0)
				{
					ValidIndex--;
				}
				
				Schematic.bSquadUpgrade = false;
				Schematic.OnBuiltFn = BuildItem;
				Schematic.HideIfPurchased = '';
				Schematic.bOneTimeBuild = false;
				Schematic.Cost = Item.Costs[ValidIndex];

				// only assign item template varaints on first pass or if nessecary
				if (Template.bShouldCreateDifficultyVariants || index == 0)
				{
					Template = TemplateManager.FindItemTemplate(Schematic.ReferenceItemTemplate);

					Template.HideInInventory = false;
					Template.bInfiniteItem = false;
				}
			}
		}
		else if (Template != none && Template.CreatorTemplateName != '')
		{
			// TODO: create difficulty variants for these schematics
			Schematic = X2SchematicTemplate(TemplateManager.FindItemTemplate(Template.CreatorTemplateName));
			
			// make sure we actually have a creator template for this schematic
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

static function BuildItem(XComGameState NewGameState, XComGameState_Item ItemState)
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
	
	// get the ItemTemplate by referencing from the SchematicTemplate
	// otherwise it won't add the item to the armory when you build it
	Schematic = X2SchematicTemplate(ItemState.GetMyTemplate());
	ItemTemplate = TemplateManager.FindItemTemplate(Schematic.ReferenceItemTemplate);

	if(XComHQ.GetNumItemInInventory(ItemTemplate.DataName) > 0)
	{
		NewItem = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', XComHQ.GetItemByName(ItemTemplate.DataName).ObjectID));
		NewItem.Quantity++;
	}
	else
	{
		NewItem = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		NewItem.Quantity = 1;
		XComHQ.PutItemInInventory(NewGameState, NewItem);
	}
}