class X2RetalPlacementModifierSet extends X2DataSet;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeneric('Base', Base_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('StartingRegion', StartingRegion_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('HasRelay', HasRelay_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('HasRelayAndDoomFacility', HasRelayAndDoomFacility_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('HasGoldenPathMission', HasGoldenPathMission_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('AllContinentContacted', AllContinentContacted_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('Only1LiveConnection', Only1LiveConnection_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('Only2LiveConnections', Only2LiveConnections_IsRelevantToRegion));
	Templates.AddItem(CreateGeneric('OnlyContactedChosenRegion', OnlyContactedChosenRegion_IsRelevantToRegion));

	return Templates;
}

static protected function X2RetalPlacementModifierTemplate CreateGeneric (name TemplateName, delegate<CI_DataStructures.IsRelevantToRegion> IsRelevantFn)
{
	local X2RetalPlacementModifierTemplate Template;

	`CREATE_X2TEMPLATE(class'X2RetalPlacementModifierTemplate', Template, TemplateName);
	Template.IsRelevantToRegionFn = IsRelevantFn;

	return Template;
}

static protected function bool Base_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return true;
}

static protected function bool StartingRegion_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return RegionState.IsStartingRegion();
}

static protected function bool HasRelay_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return RegionState.ResistanceLevel == eResLevel_Outpost;
}

static protected function bool HasRelayAndDoomFacility_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	local XComGameState_MissionSite MissionState;
	local array<int> CheckedMissionIDs;
	
	if (RegionState.ResistanceLevel != eResLevel_Outpost)
	{
		return false;
	}

	foreach NewGameState.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (
			MissionState.Available &&
			MissionState.Region.ObjectID == RegionState.ObjectID &&
			MissionState.GetMissionSource().bAlienNetwork
		)
		{
			return true;
		}

		CheckedMissionIDs.AddItem(MissionState.ObjectID);
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (CheckedMissionIDs.Find(MissionState.ObjectID) != INDEX_NONE) continue;

		if (
			MissionState.Available &&
			MissionState.Region.ObjectID == RegionState.ObjectID &&
			MissionState.GetMissionSource().bAlienNetwork
		)
		{
			return true;
		}
	}

	return false;
}

static protected function bool HasGoldenPathMission_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	local XComGameState_MissionSite MissionState;
	local array<int> CheckedMissionIDs;
	
	foreach NewGameState.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (
			MissionState.Available &&
			MissionState.Region.ObjectID == RegionState.ObjectID &&
			MissionState.GetMissionSource().bGoldenPath
		)
		{
			return true;
		}

		CheckedMissionIDs.AddItem(MissionState.ObjectID);
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (CheckedMissionIDs.Find(MissionState.ObjectID) != INDEX_NONE) continue;

		if (
			MissionState.Available &&
			MissionState.Region.ObjectID == RegionState.ObjectID &&
			MissionState.GetMissionSource().bGoldenPath
		)
		{
			return true;
		}
	}

	return false;
}

static protected function bool AllContinentContacted_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	return RegionState.GetContinent().bContinentBonusActive;
}

static protected function bool Only1LiveConnection_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	// Disable this mod for starting region
	if (StartingRegion_IsRelevantToRegion(NewGameState, RegionState)) return false;

	return GetNumLiveLinks(NewGameState, RegionState) == 1;
}

static protected function bool Only2LiveConnections_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	// Disable this mod for starting region
	if (StartingRegion_IsRelevantToRegion(NewGameState, RegionState)) return false;
	
	return GetNumLiveLinks(NewGameState, RegionState) == 2;
}

static protected function int GetNumLiveLinks (XComGameState NewGameState, XComGameState_WorldRegion ReferenceRegionState)
{
	local XComGameState_WorldRegion OtherRegionState;
	local StateObjectReference OtherRegionRef;
	local XComGameStateHistory History;
	local int Count;

	History = `XCOMHISTORY;

	foreach ReferenceRegionState.LinkedRegions(OtherRegionRef)
	{
		OtherRegionState = XComGameState_WorldRegion(NewGameState.GetGameStateForObjectID(OtherRegionRef.ObjectID));

		if (OtherRegionState == none)
		{
			OtherRegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(OtherRegionRef.ObjectID));
		}

		if (OtherRegionState.ResistanceLevel >= eResLevel_Contact)
		{
			Count++;
		}
	}

	return Count;
}

static protected function bool OnlyContactedChosenRegion_IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	local array<XComGameState_AdventChosen> AliveChosen;
	local XComGameState_WorldRegion OtherRegionState;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen ChosenState;
	local StateObjectReference OtherRegionRef;
	local XComGameStateHistory History;
	
	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();

	// Skip this check if the chosen are not activated
	if (!AlienHQ.bChosenActive) return false;

	AliveChosen = AlienHQ.GetAllChosen(NewGameState, true);

	foreach AliveChosen(ChosenState)
	{
		if (ChosenState.ChosenControlsRegion(RegionState.GetReference())) 
		{
			break;
		}

		ChosenState = none;
	}

	if (ChosenState == none)
	{
		return false;
	}

	History = `XCOMHISTORY;

	foreach ChosenState.TerritoryRegions(OtherRegionRef)
	{
		if (OtherRegionRef.ObjectID == RegionState.ObjectID) continue;

		OtherRegionState = XComGameState_WorldRegion(NewGameState.GetGameStateForObjectID(OtherRegionRef.ObjectID));

		if (OtherRegionState == none)
		{
			OtherRegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(OtherRegionRef.ObjectID));
		}

		if (OtherRegionState.ResistanceLevel >= eResLevel_Contact)
		{
			return false;
		}
	}

	return true;
}

