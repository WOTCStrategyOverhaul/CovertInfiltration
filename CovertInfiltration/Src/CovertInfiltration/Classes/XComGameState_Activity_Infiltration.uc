//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Activity state for X2ActivityTemplate_Infiltration. Listens for expiry of
//           mission-spawning covert action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_Activity_Infiltration extends XComGameState_Activity;

protected function EventListenerReturn OnActionExpired (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Activity_Infiltration NewActivityState;

	NewActivityState = XComGameState_Activity_Infiltration(GameState.ModifyStateObject(class'XComGameState_Activity_Infiltration', ObjectID));
	NewActivityState.MarkExpired(GameState);

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
	local X2EventManager EventManger;
	local Object SelfObject;

	EventManger = class'X2EventManager'.static.GetEventManager();
	ActionState = GetAction();
	SelfObject = self;

	EventManger.RegisterForEvent(SelfObject, 'CovertActionExpired', OnActionExpired, ELD_Immediate,, ActionState, true);
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