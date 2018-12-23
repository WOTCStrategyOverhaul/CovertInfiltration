class UIStrategyPolicy_CI extends UIStrategyPolicy;

var private bool RemoveDueNoFacility;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local XComGameState_FacilityXCom FacilityState;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	if (FacilityState == none)
	{
		`log("Disallowing UIStrategyPolicy because ResistanceRing was not built yet",, 'CI');
		RemoveDueNoFacility = true; // UI system cannot handle removing non-initialized screens so we need to do in OnInit
	
		// Skip all the UIStrategyPolicy setup - most importantly the camera
		super(UIScreen).InitScreen(InitController, InitMovie, InitName);
	}
	else
	{
		super.InitScreen(InitController, InitMovie, InitName);
		class'UIUtilities_Infiltration'.static.CamRingView(bInstantInterp ? float(0) : `HQINTERPTIME);
	}
}

simulated function OnInit()
{
	if (RemoveDueNoFacility)
	{
		super(UIScreen).OnInit();
		Movie.Stack.Pop(self);
		
		return;
	}

	super.OnInit();
}

simulated function CloseScreen()
{
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
	super(UIScreen).CloseScreen();

	// DO NOT show UICA under any conditions
}