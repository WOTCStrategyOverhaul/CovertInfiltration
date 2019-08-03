class XComGameState_Activity_Wait extends XComGameState_Activity;

var TDateTime ProgressAt;

function UpdateGameBoard ()
{
	local XComGameState_Activity_Wait NewActivityState;
	local XComGameState NewGameState;
	
	super.UpdateGameBoard();

	if (
		IsOngoing() &&
		ProgressAt.m_iYear >= class'X2StrategyGameRulesetDataStructures'.default.START_YEAR && // The value was set
		class'X2StrategyGameRulesetDataStructures'.static.LessThan(ProgressAt, GetCurrentTime())
	)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Wait activity progressing. Chain:" @ GetActivityChain().GetMyTemplateName());
		NewActivityState = XComGameState_Activity_Wait(NewGameState.ModifyStateObject(class'XComGameState_Activity_Wait', ObjectID));

		NewActivityState.MarkSuccess(NewGameState);
		`SubmitGameState(NewGameState);
	}
}