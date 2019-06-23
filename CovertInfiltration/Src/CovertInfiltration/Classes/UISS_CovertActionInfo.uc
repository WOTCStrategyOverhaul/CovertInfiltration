//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Displays covert action info (such as title and objective) on the squad
//           select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_CovertActionInfo extends UIPanel;

simulated function InitCovertActionInfo(optional name InitName)
{
	InitPanel(InitName);
	SetAnchor(class'UIUtilities'.const.ANCHOR_TOP_LEFT);
}

simulated function UpdateData(XComGameState_CovertAction Action)
{
	local XComGameState_MissionSite MissionSite;

	MissionSite = class'X2Helper_Infiltration'.static.GetMissionSiteFromAction(Action);

	if (MissionSite != none)
	{
		// If we have an underlying mission, show that instead
		mc.BeginFunctionOp("UpdateData");
		mc.QueueString(MissionSite.GeneratedMission.BattleOpName);
		mc.QueueString(class'UISquadSelectMissionInfo'.default.m_strObjectives);
		mc.QueueString(MissionSite.GetMissionObjectiveText());
		mc.QueueString(class'UISquadSelectMissionInfo'.default.m_strDifficulty);
		mc.QueueString(MissionSite.GetMissionDifficultyLabel());
		mc.QueueString(class'UISquadSelectMissionInfo'.default.m_strRewards);
		mc.QueueString(MissionSite.GetRewardAmountString());
		mc.EndOp();
	}
	else
	{
		mc.BeginFunctionOp("UpdateData");
		mc.QueueString(Action.GetDisplayName());
		mc.QueueString("Objectives");
		mc.QueueString(Action.GetObjective());
		mc.QueueString("Reward:"); // "Difficulty"
		mc.QueueString(Action.GetRewardDescriptionString()); // eg. Easy
		mc.QueueString(" "); // "Reward"
		mc.QueueString(Action.GetRewardDetailsString());
		mc.EndOp();
	}
}

defaultproperties
{
	LibID = "MissionInfo";
	bIsNavigable = false;
	bProcessesMouseEvents = false;
}
