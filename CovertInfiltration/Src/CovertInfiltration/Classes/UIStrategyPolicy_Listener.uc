//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to change the camera view for resistance orders screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStrategyPolicy_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local XComGameState_FacilityXCom FacilityState;
	local UIStrategyPolicy StrategyPolicy;

	StrategyPolicy = UIStrategyPolicy(Screen);
	if (StrategyPolicy == none) return;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	if (FacilityState == none) return;

	`HQPRES.CAMLookAtRoom(FacilityState.GetRoom(), StrategyPolicy.bInstantInterp ? float(0) : `HQINTERPTIME);
}