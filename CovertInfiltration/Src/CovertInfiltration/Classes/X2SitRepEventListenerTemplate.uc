class X2SitRepEventListenerTemplate extends CHEventListenerTemplate;

var name RequiredSitRep;

function RegisterForEvents()
{
	local XComGameState_MissionSite MissionSite;
	local XComGameState_BattleData BattleData;
	local XComGameStateHistory History;
	local array<name> ActiveSitReps;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	ActiveSitReps = BattleData.ActiveSitReps;

	if (ActiveSitReps.Length == 0 && !BattleData.DirectTransferInfo.IsDirectMissionTransfer)
	{
		// This can happen even if there are sitreps present and we are just creating the tactical mission
		// as the events are registered before XComGameState_BattleData is filled out.
		// Logic copied from XComTacticalMissionManager::InitMission

		if (BattleData.m_iMissionID > 0)
		{
			MissionSite = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));
			ActiveSitReps = MissionSite.GeneratedMission.SitReps;
		}
		else
		{
			// TQL
			ActiveSitReps = `TACTICALMISSIONMGR.arrMissions[BattleData.m_iMissionType].ForcedSitreps;
		}

		// A note about tactical->tactical transfers:
		// I don't think it's possible to have sitreps on non-first part of the mission.
		// If it is, I hope that the BattleData.ActiveSitReps will be filled together with 
		// BattleData.DirectTransferInfo (before we reach "create mission" stage and listeners are registered)
	}

	if (ActiveSitReps.Find(RequiredSitRep) != INDEX_NONE)
	{
		super.RegisterForEvents();
	}
}

function bool ValidateTemplate (out string strError)
{
	local X2SitRepTemplateManager TemplateManager;
	
	if (!super.ValidateTemplate(strError)) return false;

	TemplateManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	if (TemplateManager.FindSitRepTemplate(RequiredSitRep) == none)
	{
		strError = "SitRep" @ RequiredSitRep @ "does not exist";
		return false;
	}

	return true;
}

defaultproperties
{
	RegisterInTactical = true
}