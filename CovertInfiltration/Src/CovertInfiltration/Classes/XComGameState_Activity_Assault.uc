class XComGameState_Activity_Assault extends XComGameState_Activity;

var bool bExpiring;
var bool bAlreadyWarnedOfExpiration;
var TDateTime ExpiryTimerStart, ExpiryTimerEnd;

`include(CovertInfiltration/Src/CovertInfiltration/MCM_API_CfgHelpersStatic.uci)
`MCM_CH_VersionCheckerStatic(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

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

	local TDateTime AdjustedTime;
	local bool WarnBeforeExpiration;
	local int HoursBeforeWarning;

	WarnBeforeExpiration = `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.WARN_BEFORE_EXPIRATION_DEFAULT, class'UIListener_ModConfigMenu'.default.WARN_BEFORE_EXPIRATION);

	if (bExpiring && class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpiryTimerEnd, GetCurrentTime()))
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Activity" @ m_TemplateName @ "(assault mission) has expired");
		NewMissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', PrimaryObjectRef.ObjectID));
		NewActivityState = XComGameState_Activity_Assault(NewGameState.ModifyStateObject(class'XComGameState_Activity_Assault', ObjectID));

		NewActivityState.MarkExpired(NewGameState);
		NewMissionState.RemoveEntity(NewGameState);

		`SubmitGameState(NewGameState);

		// Remove the expired mission from geoscape HUD
		`HQPRES.StrategyMap2D.UpdateMissions();
	}
	else if (WarnBeforeExpiration && bExpiring && !bAlreadyWarnedOfExpiration)
	{
		HoursBeforeWarning = `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.HOURS_BEFORE_WARNING_DEFAULT, class'UIListener_ModConfigMenu'.default.HOURS_BEFORE_WARNING);
		AdjustedTime = GetCurrentTime();
		class'X2StrategyGameRulesetDataStructures'.static.AddHours(AdjustedTime, HoursBeforeWarning);

		if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpiryTimerEnd, AdjustedTime))
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Activity" @ m_TemplateName @ "(assault mission) expiration warning triggered");
			NewActivityState = XComGameState_Activity_Assault(NewGameState.ModifyStateObject(class'XComGameState_Activity_Assault', ObjectID));
			
			NewActivityState.bAlreadyWarnedOfExpiration = true;

			`SubmitGameState(NewGameState);

			class'UIUtilities_Infiltration'.static.AssaultMissionExpiring(class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(self));
		}
	}
}