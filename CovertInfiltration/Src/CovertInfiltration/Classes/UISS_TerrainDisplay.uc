//---------------------------------------------------------------------------------------
//  AUTHOR:  Adapted from WOTC_ShowEnemiesonMissionPlanning by Xymanek
//  PURPOSE: Shows the plot type that the infiltration mission will use
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_TerrainDisplay extends UIPanel;

var protectedwrite UIPanel BG;
var protectedwrite UIScrollingText Text;

var localized string strAbandoned;
var localized string strAbandoned_Indoors;
var localized string strAbandoned_Occluded;
var localized string strCityCenter;
var localized string strDerelictFacility;
var localized string strLostTower;
var localized string strFacility;
var localized string strRooftops;
var localized string strSarcophagusRoom;
var localized string strSlums;
var localized string strShanty;
var localized string strSmallTown;
var localized string strStronghold;
var localized string strWilderness;
var localized string strTunnels_Reverb;
var localized string strTunnels_Sewer;
var localized string strTunnels_Subway;

simulated function InitTerrainDisplay (XComGameState_CovertAction Action)
{
	InitPanel();
	
	AnchorTopRight();
	SetSize(400, 50);
	SetPosition(-Width, 10);

	BG = Spawn(class'UIPanel', self);
	BG.bAnimateOnInit = false;
	BG.InitPanel('BG', class'UIUtilities_Controls'.const.MC_GenericPixel);
	BG.SetSize(Width + 10, Height);
	BG.SetColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
	BG.SetAlpha(80);

	Text = Spawn(class'UIScrollingText', self);
	Text.bAnimateOnInit = false;
	Text.InitScrollingText('Text', GenerateDisplayedText(Action));
	Text.SetWidth(Width - 5 * 2);
	Text.SetPosition(10, 10);
}

simulated function string GenerateDisplayedText (XComGameState_CovertAction Action)
{
	local string PlotType;

	PlotType = class'X2Helper_Infiltration'.static.GetMissionSiteFromAction(Action).GeneratedMission.Plot.strType;

	return "Plot type:" @ GetPlotFriendlyName(PlotType);
}

simulated function string GetPlotFriendlyName (string PlotString)
{
	switch (PlotString)
	{
		case "Abandoned":
			return strAbandoned;

		case "Abandoned_Indoors":
			return strAbandoned_Indoors;

		case "Abandoned_Occluded":
			return strAbandoned_Occluded;
		
		case "CityCenter":
			return strCityCenter;
		
		case "DerelictFacility":
			return strDerelictFacility;
		
		case "LostTower":
			return strLostTower;
		
		case "Facility":
			return strFacility;
		
		case "Rooftops":
			return strRooftops;
		
		case "SarcophagusRoom":
			return strSarcophagusRoom;
		
		case "Slums":
			return strSlums;
		
		case "Shanty":
			return strShanty;
		
		case "SmallTown":
			return strSmallTown;
		
		case "Stronghold":
			 return strStronghold;
		
		case "Wilderness":
			return strWilderness;
		
		case "Tunnels_Reverb":
			return strTunnels_Reverb;
		
		case "Tunnels_Sewer":
			return strTunnels_Sewer;
		
		case "Tunnels_Subway":
			return strTunnels_Subway;
		
		default:
			return PlotString;
	}
}

defaultproperties
{
	MCName = "UISS_TerrainDisplay"
}