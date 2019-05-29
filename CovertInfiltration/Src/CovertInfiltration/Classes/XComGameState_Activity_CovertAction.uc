class XComGameState_Activity_CovertAction extends XComGameState_Activity;

protected function EventListenerReturn OnActionCompleted (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	MarkSuccess(GameState);
}

protected function EventListenerReturn OnActionExpired (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	MarkExpired(GameState);
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

	EventManger.RegisterForEvent(SelfObject, 'CovertActionCompleted', OnActionCompleted, ELD_Immediate,, ActionState);
	EventManger.RegisterForEvent(SelfObject, 'CovertActionExpired', OnActionExpired, ELD_Immediate,, ActionState);
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
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(PrimaryObjectRef.ObjectID));
}