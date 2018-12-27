//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Replaces several behavior aspects of orders screen - especially when
//           opening and closing. Could be lifted to CHL hooks in future
//  CHANGES: 1) If the Ring isn't built skip all setup and instantly close the screen
//           2) Change camera to look at the Ring facility
//           3) Allow changing orders if this is the first time the screen was opened
//           4) Do not show UICovertActions if supply drop and no CA is running
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

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
		return;
	}

	if (!bResistanceReport && !class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment)
	{
		bResistanceReport = true;
	}

	super.InitScreen(InitController, InitMovie, InitName);
	class'UIUtilities_Infiltration'.static.CamRingView(bInstantInterp ? float(0) : `HQINTERPTIME);
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
	local XComGameState_CovertInfiltrationInfo Info;
	local XComGameState NewGameState;	

	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
	super(UIScreen).CloseScreen();

	// DO NOT show UICA under any conditions

	if (!class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Completing first order assignment");
		
		Info = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
		Info = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', Info.ObjectID));
		Info.bCompletedFirstOrdersAssignment = true;
		
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}