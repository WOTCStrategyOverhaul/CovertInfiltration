//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: DLCInfo with the DLCIdentifier mapped to a non-existent value. This allows
//           us to exploit OnLoadedSavedGame to always run when any save is opened
//           (not just once) before the ruleset is initialized. We use it to update state
//           (when changes are required) of the campaign to mod's new version
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CovertInfiltration_Fake extends X2DownloadableContentInfo;

static event OnLoadedSavedGame ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	// Do nothing if we are adding CI to an existing campaign or if we already updated the state
	if (CIInfo == none || CIInfo.ModVersion >= class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating CI state from" @ CIInfo.ModVersion @ "to" @ class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION);

	// State fix-up changes go here
	`CI_Log("X2DownloadableContentInfo_CovertInfiltration_Fake");

	// Save that the state was updated.
	// Do this last, so that the state update code can access the previous version
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));
	CIInfo.ModVersion = class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION;

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

