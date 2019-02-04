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

		// look for a SchematicTemplate from the config array
		if (Schematic != none)
		{
			// check if this schematic is flagged to require difficulty variants
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

				// only modify item template varaints on first pass or if nessecary
				if (Template.bShouldCreateDifficultyVariants || index == 0)
				{
					Template = TemplateManager.FindItemTemplate(Schematic.ReferenceItemTemplate);

					Template.HideInInventory = false;
					Template.bInfiniteItem = false;
				}
			}
		}
		// didn't find a SchematicTemplate, check for an ItemTemplate (faction armors & spark bits)
		// also check if it has a CreatorTemplateName (we need this to make it buildable in workshop)
		else if (Template != none && Template.CreatorTemplateName != '')
		{
			Schematic = X2SchematicTemplate(TemplateManager.FindItemTemplate(Template.CreatorTemplateName));
			
			// double check CreatorTemplate was properly assigned as the Schematic
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
		else
		{
			`log(string(Item.SchematicName) $ ": unable to find a Template with this name, skipping..",, 'CI');
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

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

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