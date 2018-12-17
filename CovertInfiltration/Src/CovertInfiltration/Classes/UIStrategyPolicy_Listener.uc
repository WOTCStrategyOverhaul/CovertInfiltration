//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to change the camera view for resistance orders screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStrategyPolicy_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIStrategyPolicy StrategyPolicy;

	StrategyPolicy = UIStrategyPolicy(Screen);
	if (StrategyPolicy == none) return;

	class'UIUtilities_Infiltration'.static.ForceRingViewIfPossible(StrategyPolicy.bInstantInterp ? float(0) : `HQINTERPTIME);
}

