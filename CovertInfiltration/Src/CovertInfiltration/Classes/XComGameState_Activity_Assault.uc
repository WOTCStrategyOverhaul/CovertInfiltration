class XComGameState_Activity_Assault extends XComGameState_Activity;

var bool bExpiring;
var bool bAlreadyWarnedOfExpiration;
var TDateTime ExpiryTimerStart, ExpiryTimerEnd;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

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
	local XComGameState_MissionSite MissionState;
	local XComGameState NewGameState;
	local bool bDirty;

	local TDateTime AdjustedTime;
	local bool WarnBeforeExpiration;
	local int HoursBeforeWarning;

	WarnBeforeExpiration = `GETMCMVAR(WARN_BEFORE_EXPIRATION);

	if (bExpiring
	 && class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpiryTimerEnd, GetCurrentTime())
	 && class'X2Helper_Infiltration'.static.GeoscapeReadyForUpdate())
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Activity" @ m_TemplateName @ "(assault mission) has expired");
		MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(PrimaryObjectRef.ObjectID));

		if (MissionState != none)
		{
			if (MissionState.GetMissionSource().OnExpireFn != none)
			{
				MissionState.GetMissionSource().OnExpireFn(NewGameState, MissionState);
				bDirty = true;
			}
		}
		
		if (bDirty)
		{
			`SubmitGameState(NewGameState);

			// Remove the expired mission from geoscape HUD
			`HQPRES.StrategyMap2D.UpdateMissions();
		}
		else
		{
			`CleanupGameState(NewGameState);
		}
	}
	else if (WarnBeforeExpiration && bExpiring && !bAlreadyWarnedOfExpiration)
	{
		HoursBeforeWarning = `GETMCMVAR(HOURS_BEFORE_WARNING);
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

function int GetHoursRemaining()
{
	return class'X2StrategyGameRulesetDataStructures'.static.DifferenceInHours(ExpiryTimerEnd, GetCurrentTime());
}