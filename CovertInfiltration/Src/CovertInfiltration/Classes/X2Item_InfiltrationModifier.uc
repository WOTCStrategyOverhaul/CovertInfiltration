//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class expands X2Item, adding a new attribute
//           that controls infiltration time, as well as some
//           functions to manipulate and retrieve those values.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Item_InfiltrationModifier extends X2ItemTemplate;

struct X2ItemInfiltrationData
{
    var name TemplateName;
    var int InfilMod;
};

var config array<X2ItemInfiltrationData> InfilData;

function AddInfilMod(name Template, int Modifier)
{
	local X2ItemInfiltrationData NewInfil;

	NewInfil.TemplateName = Template;
	NewInfil.InfilMod = Modifier;

	default.InfilData.AddItem(NewInfil);
}

function int GetInfilMod(name Template)
{
	local int i;
	local int x;
	i = default.InfilData.Find('TemplateName', Template);
	x = default.InfilData[i].InfilMod;
	return x;
}

/*
function ExampleFunction()
{
	local int i;
	local X2ItemTemplate Template;

	// grab a soldier's item here and put it into Template

	i = default.InfilData.Find('TemplateName', Template.DataName);
	if (default.InfilData[i].InfilMod != 0)
	{
		// calculate stuff based on the InfilMod here
	}
}
*/
