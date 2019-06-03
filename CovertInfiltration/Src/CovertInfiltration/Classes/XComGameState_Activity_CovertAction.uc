//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Activity state for X2ActivityTemplate_CovertAction. Listens for changes in
//           the CA's state
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_Activity_CovertAction extends XComGameState_Activity;

function UpdateGameBoard ()
{
	local XComGameState_Activity_CovertAction NewActivityState;
	local XComGameState_CovertAction ActionState;
	local XComGameState NewGameState;

	super.UpdateGameBoard();

	ActionState = GetAction();

	if (IsOngoing() && ActionState.bRemoved) // If it was expired, then the activity is marked completed already
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Activity" @ m_TemplateName @ "registered that action was removed");
		NewActivityState = XComGameState_Activity_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_Activity_CovertAction', ObjectID));

		if (ActionState.bCompleted)
		{
			NewActivityState.MarkSuccess(NewGameState);
		}
		else
		{
			NewActivityState.MarkFailed(NewGameState);
		}

		`SubmitGameState(NewGameState);
	}
}

protected function EventListenerReturn OnActionExpired (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Activity_CovertAction NewActivityState;

	NewActivityState = XComGameState_Activity_CovertAction(GameState.ModifyStateObject(class'XComGameState_Activity_CovertAction', ObjectID));
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

	//EventManger.RegisterForEvent(SelfObject, 'CovertActionCompleted', OnActionCompleted, ELD_Immediate,, ActionState);
	EventManger.RegisterForEvent(SelfObject, 'CovertActionExpired', OnActionExpired, ELD_Immediate,, ActionState);

	// Cannot use the CovertActionCompleted event as the popup of next stage will spawn before the UICovertActionReport does
	// due to the weird way the latter is wired up. Instead we check in UpdateGameBoard if the action was removed
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