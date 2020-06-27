//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Allows transfer of a type and quantity of item between two missions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ResourceContainer extends XComGameState_BaseObject;

var array<ResourcePackage> Packages;

// This is idempotent - you can call it multiple times and it will result in same outcome
function CombineLoot()
{
	local array<ResourcePackage> NewPackages;
	local int p, n;
	local bool Merged;

	for(p = 0; p < Packages.Length; p++)
	{
		Merged = false;

		for(n = 0; n < NewPackages.Length; n++)
		{
			if(NewPackages[n].ItemType == Packages[p].ItemType)
			{
				NewPackages[n].ItemAmount += Packages[p].ItemAmount;
				Merged = true;
			}
		}

		if(!Merged)
		{
			NewPackages.AddItem(Packages[p]);
		}
	}

	Packages = NewPackages;
}

//////////
/// UI ///
//////////

function string GetCommaSeparatedContents ()
{
	local X2ItemTemplateManager ItemManager;
	local X2ItemTemplate ItemTemplate;
	local ResourcePackage Package;
	local string Result;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	if(Packages.Length == 0)
		`CI_Log("XComGameState_ResourceContainer::GetCommaSeparatedContents: No packages to read from!");

	foreach Packages(Package)
	{
		ItemTemplate = ItemManager.FindItemTemplate(Package.ItemType);
		if(ItemTemplate != none)
		{
			`CI_Log("Reading package:" @ Package.ItemType);
			if(Result == "")
			{
				Result = string(Package.ItemAmount) @ (Package.ItemAmount == 1 ? ItemTemplate.GetItemFriendlyName() : ItemTemplate.GetItemFriendlyNamePlural());
			}
			else
			{
				Result = Result $ "," @ string(Package.ItemAmount) @ (Package.ItemAmount == 1 ? ItemTemplate.GetItemFriendlyName() : ItemTemplate.GetItemFriendlyNamePlural());
			}
		}
	}

	if(Result == "")
		`CI_Log("XComGameState_ResourceContainer::GetCommaSeparatedContents: Something went wrong in reward string!");

	return Result;
}