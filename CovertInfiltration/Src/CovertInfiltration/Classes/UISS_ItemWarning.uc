//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Notify the player if they have useless items equipped on a Covert Action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

// TODO: Localize this
// TODO: Make it update as you change loadouts
// TODO: Find a new screen location for it

class UISS_ItemWarning extends UIPanel;

var protectedwrite UIPanel BG;
var protectedwrite UIScrollingText Text;

simulated function InitItemWarning (XComGameState_CovertAction Action)
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
	if (class'X2Helper_Infiltration'.static.SquadHasIrrelevantItems(`XCOMHQ.Squad))
	{
		return "Irrelevant Items Equipped";
	}
	else
	{
		return "Ready to Deploy";
	}
}

defaultproperties
{
	MCName = "UISS_ItemWarning"
}