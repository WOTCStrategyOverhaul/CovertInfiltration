//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Activity state for X2ActivityTemplate_Infiltration. Listens for expiry and 
//           and abort of mission-spawning covert action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_Activity_Infiltration extends XComGameState_Activity;

protected function EventListenerReturn OnActionExpired (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	OnInfilExpired(GameState);
	
	return ELR_NoInterrupt;
}

function OnInfilExpired (XComGameState NewGameState)
{
	local XComGameState_MissionSiteInfiltration MissionState;

	MissionState = XComGameState_MissionSiteInfiltration(`XCOMHISTORY.GetGameStateForObjectID(PrimaryObjectRef.ObjectID));

	if (MissionState != none)
	{
		if (MissionState.GetMissionSource().OnExpireFn != none)
		{
			MissionState.GetMissionSource().OnExpireFn(NewGameState, MissionState);
		}
	}
}

protected function EventListenerReturn OnActionAborted (Object EventData, Object EventSource, XComGameState NewGameState, Name EventID, Object CallbackData)
{
	local X2ActivityTemplate_Infiltration InfilTemplate;
	local XComGameState_Activity NewActivityState;

	InfilTemplate = X2ActivityTemplate_Infiltration(GetMyTemplate());
	NewActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ObjectID));
	
	if (InfilTemplate.OnAborted != none)
	{
		InfilTemplate.OnAborted(NewGameState, NewActivityState);
	}

	return ELR_NoInterrupt;
}

protected function PostMarkCompleted (XComGameState NewGameState)
{
	UnRegisterFromAllEvents();

	super.PostMarkCompleted(NewGameState);
}

////////////////////////
/// Event management ///
////////////////////////

function RegisterForActionEvents ()
{
	local XComGameState_CovertAction ActionState;
	local X2EventManager EventManager;
	local Object SelfObject;

	EventManager = class'X2EventManager'.static.GetEventManager();
	ActionState = GetAction();
	SelfObject = self;

	// These technically suffer from same issue as XComGameState_MissionSiteInfiltration::OnActionStarted
	// but since the self gets also deleted in response to these events, there is no point in manually unregistering
	EventManager.RegisterForEvent(SelfObject, 'CovertActionExpired', OnActionExpired, ELD_Immediate, 99, ActionState, true);
	EventManager.RegisterForEvent(SelfObject, 'CovertActionAborted', OnActionAborted, ELD_Immediate, 99, ActionState, true);
}

function UnRegisterFromAllEvents ()
{
	local Object SelfObject;
	SelfObject = self;

	class'X2EventManager'.static.GetEventManager().UnRegisterFromAllEvents(SelfObject);
}

///////////////
/// Helpers ///
///////////////

function XComGameState_CovertAction GetAction ()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(SecondaryObjectRef.ObjectID));
}