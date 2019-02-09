//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Class designed to flag items in order to give them difficulty variants,
//  make them single buildable from the ItemTemplate and kill their SchematicTemplate
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration_TemplateMod extends Object config(Game);

var config array<name> arrDataSetsToForceVariants;
var config(StrategyTuning) array<name> arrMakeItemBuildable;
var config(StrategyTuning) array<name> arrKillItems;

static function ForceDifficultyVariants()
{
	local name DataSetToPatch;
	local X2DataSet DataSetCDO;

	foreach default.arrDataSetsToForceVariants(DataSetToPatch)
	{
		DataSetCDO = X2DataSet(class'XComEngine'.static.GetClassDefaultObjectByName(DataSetToPatch));

		if (DataSetCDO == none)
		{
			`warn(DataSetToPatch @ "is not a valid X2DataSet class",, 'CI');
		}
		else
		{
			DataSetCDO.bShouldCreateDifficultyVariants = true;
		}
	}
}

static function MakeItemsBuildable()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`log("Making items buildable",, 'CI_SingleBuildItems');

	foreach default.arrMakeItemBuildable(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`warn(DataTemplate.Name @ "is not an X2ItemTemplate",, 'CI_SingleBuildItems');
				continue;
			}

			ItemTemplate.CanBeBuilt = true;
			ItemTemplate.bInfiniteItem = false;
			ItemTemplate.CreatorTemplateName = '';

			`log(ItemTemplate.Name @ "was made single-buildable" @ `showvar(ItemTemplate.Requirements.RequiredTechs.Length),, 'CI_SingleBuildItems');
		}
	}
}

static function KillItems()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`log("Killing items",, 'CI_SingleBuildItems');

	foreach default.arrKillItems(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`warn(DataTemplate.Name @ "is not an X2ItemTemplate",, 'CI_SingleBuildItems');
				continue;
			}

			// "Killing" inspired by LW2
			ItemTemplate.CanBeBuilt = false;
			ItemTemplate.PointsToComplete = 999999;
			ItemTemplate.Requirements.RequiredEngineeringScore = 999999;
			ItemTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
			ItemTemplate.OnBuiltFn = none;
			ItemTemplate.Cost.ResourceCosts.Length = 0;
			ItemTemplate.Cost.ArtifactCosts.Length = 0;

			`log(ItemTemplate.Name @ "was killed",, 'CI_SingleBuildItems');
		}
	}
}