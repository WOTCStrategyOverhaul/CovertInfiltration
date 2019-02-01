class X2TemplateModifier extends Object config (SingleBuildItems);

struct SingleBuildItem
{
	var name SchematicName;
	var int TradingPostValue;
	
	var array<StrategyCost> Costs;
};

var config array<SingleBuildItem> SingleBuildItems;

const BITFIELD_GAMEAREA_Rookie				= 32;   // WARNING: Do NOT edit this value!

function ModifyTemplates()
{
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

		if (Schematic != none && Schematic.bShouldCreateDifficultyVariants)
		{
			// cycle through and modify each difficulty variant for this template
			for (index = 0; index < 4; index++)
			{
				Schematic = X2SchematicTemplate(FindDifficultyVariant(TemplateManager, Item.SchematicName, index));
				Template = FindDifficultyVariant(TemplateManager, Schematic.ReferenceItemTemplate, index);

				Schematic.bSquadUpgrade = false;
				Schematic.OnBuiltFn = BuildItem;
				Schematic.HideIfPurchased = '';
				Schematic.bOneTimeBuild = false;
				Schematic.Cost = Item.Costs[index];
			
				Template.HideInInventory = false;
				Template.bInfiniteItem = false;
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
				`log(string(Item.SchematicName) @ "schematic created",, 'CI');
			}
		}
	}
}

function X2ItemTemplate FindDifficultyVariant(X2ItemTemplateManager TemplateManager, Name DataName, int index)
{
	local array<X2DataTemplate> Templates;
	local X2DataTemplate Template;
	local int Bitfield;

	Bitfield = BITFIELD_GAMEAREA_Rookie * (1 << index);
	TemplateManager.FindDataTemplateAllDifficulties(DataName, Templates);

	foreach Templates(Template)
	{
		if((Template.TemplateAvailability & Bitfield) != 0)
		{
			return X2ItemTemplate(Template);
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
