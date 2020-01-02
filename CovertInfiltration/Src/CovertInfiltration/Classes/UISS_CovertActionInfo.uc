//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Displays covert action info (such as title and objective) on the squad
//           select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_CovertActionInfo extends UIPanel;

var UIPanel		m_kSitRep;

simulated function InitCovertActionInfo(optional name InitName)
{
	InitPanel(InitName);
	SetAnchor(class'UIUtilities'.const.ANCHOR_TOP_LEFT);

	m_kSitRep = Spawn(class'UIPanel', self);
	m_kSitRep.bAnimateOnInit = false;
	m_kSitRep.InitPanel('SitRep');
	m_kSitRep.ProcessMouseEvents();
	m_kSitRep.Hide();
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

		UpdateSitRep(MissionSite);
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

simulated function UpdateSitRep(XComGameState_MissionSite MissionState)
{
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate;
	local string SitRepInfo, SitRepTooltip;
	local name SitRepName;
	local EUIState eState;
	local int idx;
	local array<string> SitRepLines, SitRepTooltipLines;
	local GeneratedMissionData MissionData;

	MissionData = MissionState.GeneratedMission;
	
	if (MissionData.SitReps.Length > 0 && !MissionState.GetMissionSource().bBlockSitrepDisplay)
	{
		SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
		foreach MissionData.SitReps(SitRepName)
		{
			SitRepTemplate = SitRepManager.FindSitRepTemplate(SitRepName);

			if (SitRepTemplate != none)
			{
				if (SitRepTemplate.bExcludeFromStrategy)
					continue;

				if (SitRepTemplate.bNegativeEffect)
				{
					eState = eUIState_Bad;
				}
				else
				{
					eState = eUIState_Normal;
				}

				SitRepLines.AddItem(class'UIUtilities_Text'.static.GetColoredText(SitRepTemplate.GetFriendlyName(), eState));
				SitRepTooltipLines.AddItem(SitRepTemplate.Description);
			}
		}
	}

	for (idx = 0; idx < SitRepLines.Length; idx++)
	{
		SitRepInfo $= SitRepLines[idx];
		if (idx < SitRepLines.length - 1)
			SitRepInfo $= "\n";
		
		SitRepTooltip $= SitRepLines[idx] $ ":" @ SitRepTooltipLines[idx];
		if (idx < SitRepLines.length - 1)
			SitRepTooltip $= "\n";
	}

	//m_kMissionInfo.UpdateSitRep(SitRepInfo, SitRepTooltip);

	m_kSitRep.SetVisible(SitRepTooltip != "");
	m_kSitRep.SetTooltipText(SitRepTooltip);

	MC.BeginFunctionOp("UpdateSitRepPanel");
	MC.QueueString(class'UITacticalHUD'.default.m_strSitRepPanelHeader);
	MC.QueueString(SitRepInfo);
	MC.EndOp();
}

defaultproperties
{
	LibID = "MissionInfo";
	bIsNavigable = false;
	bProcessesMouseEvents = false;
}
