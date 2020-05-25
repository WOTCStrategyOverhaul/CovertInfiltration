//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used to call the tutorial popup when the player enters
//           the recruitment screen in the armoury
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_RecruitSoldiers extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIRecruitSoldiers RecruitSoldiers;
	
	RecruitSoldiers = UIRecruitSoldiers(Screen);
	if (RecruitSoldiers == none) return;

	class'UIUtilities_InfiltrationTutorial'.static.CrewLimit();
}