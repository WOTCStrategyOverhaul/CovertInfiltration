//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Allows transfer of a type and quantity of item between two missions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ResourceContainer extends XComGameState_BaseObject;

var array<ResourcePackage> Packages;

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