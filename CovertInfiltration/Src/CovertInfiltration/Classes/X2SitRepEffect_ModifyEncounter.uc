class X2SitRepEffect_ModifyEncounter extends X2SitRepEffectTemplate;

var bool bApplyToPreplaced;
var bool bApplyToReinforcement;

// Note that for tactical->tactical transfers, the preplaced encounters for non-first-part of the mission
// are generated in native code within SpawnManager.SpawnAllAliens (I assume it duplicates what XCGS_MissonSite::CacheSelectedMissionData does).
// As such we cannot intercept it at the encounter layer.
// If changes are required, listen to PostAliensSpawned event and modfiy the gamestate directly

delegate ProcessEncounter (
	out name EncounterName, out PodSpawnInfo Encounter,
	int ForceLevel, int AlertLevel,
	XComGameState_MissionSite MissionState, XComGameState_BaseObject ReinforcementState
);

function bool ValidateTemplate (out string strError)
{
	if (!super.ValidateTemplate(strError))
	{
		return false;
	}

	if (ProcessEncounter == none)
	{
		strError = "ProcessEncounter is not set";
		return false;
	}

	if (!bApplyToPreplaced && !bApplyToReinforcement)
	{
		strError = "either bApplyToPreplaced or bApplyToReinforcement (or both) must be set to true";
		return false;
	}

	return true;
}