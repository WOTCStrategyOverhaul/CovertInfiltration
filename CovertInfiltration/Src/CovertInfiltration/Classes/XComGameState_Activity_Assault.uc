class XComGameState_Activity_Assault extends XComGameState_Activity;

var bool bExpiring;
var TDateTime ExpiryTimerStart, ExpiryTimerEnd;

function SetupExpiry ()
{
	local X2ActivityTemplate_Assault Template;

	Template = X2ActivityTemplate_Assault(GetMyTemplate());

	bExpiring = Template.bExpires;
	if (bExpiring)
	{
		ExpiryTimerStart = GetCurrentTime();
		
		ExpiryTimerEnd = ExpiryTimerStart;
		class'X2StrategyGameRulesetDataStructures'.static.AddHours(ExpiryTimerEnd, Template.RollExpiry());
	}
}

protected function UpdateActivity ()
{
	local XComGameState_Activity_Assault NewActivityState;
	local XComGameState_MissionSite NewMissionState;
	local XComGameState NewGameState;

	if (bExpiring && class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpiryTimerEnd, GetCurrentTime()))
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Activity" @ m_TemplateName @ "(assault mission) has expired");
		NewMissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', PrimaryObjectRef.ObjectID));
		NewActivityState = XComGameState_Activity_Assault(NewGameState.ModifyStateObject(class'XComGameState_Activity_Assault', ObjectID));

		NewActivityState.MarkExpired(NewGameState);
		NewMissionState.RemoveEntity(NewGameState);

		`SubmitGameState(NewGameState);
	}
}