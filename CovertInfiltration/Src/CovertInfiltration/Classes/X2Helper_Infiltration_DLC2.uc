//---------------------------------------------------------------------------------------
//  AUTHOR:    Xymanek
//  PURPOSE:   Houses functionality used for interacting with DLC2
//  IMPORTANT: DO NOT call any method on this class if DLC2 isn't loaded
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration_DLC2 extends Object config(Infiltration) abstract;

var config int RULER_APPEAR_CHANCE;

static function StateObjectReference GetRulerOnInfiltration (StateObjectReference InfiltrationRef)
{
    local XComGameState_AlienRulerManager RulerManager;
    local StateObjectReference EmptyRef;
    local int i;

    RulerManager = XComGameState_AlienRulerManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_AlienRulerManager'));
    if (RulerManager == none) return EmptyRef;

    i = RulerManager.AlienRulerLocations.Find('MissionRef', InfiltrationRef);
    return i != INDEX_NONE ? RulerManager.AlienRulerLocations[i].RulerRef : EmptyRef;
}

static function bool InfiltrationHasRuler (StateObjectReference InfiltrationRef)
{
    return GetRulerOnInfiltration(InfiltrationRef).ObjectID != 0;
}

static function PlaceRulerOnInfiltration (XComGameState NewGameState, XComGameState_MissionSiteInfiltration InfiltrationState)
{
    local XComGameState_AlienRulerManager RulerManager;
    local array<StateObjectReference> Candidates;
    local AlienRulerLocation RulerLocation;
    local StateObjectReference Candidate;
    local XComGameState_Unit RulerState;
    local XComGameStateHistory History;

    if (InfiltrationHasRuler(InfiltrationState.GetReference()))
    {
        `RedScreen("CI: PlaceRulerOnInfiltration called for infil that already has a ruler, skipping");
        return;
    }

    History = `XCOMHISTORY;
    RulerManager = XComGameState_AlienRulerManager(History.GetSingleGameStateObjectForClass(class'XComGameState_AlienRulerManager'));

    foreach RulerManager.ActiveAlienRulers(Candidate)
    {
        // Check that the ruler is not waiting on another mission
        if (RulerManager.AlienRulerLocations.Find('RulerRef', Candidate) == INDEX_NONE)
        {
			// TODO: XComGameState_AlienRulerManager::UpdateActiveAlienRulers
            // If we have DLC integration enabled, check that the ruler was seen once
            // We cannot rely on AlienRulerLocations here since the ruler might be waiting for a facility to be built
            if (class'X2Helpers_DLC_Day60'.static.IsXPackIntegrationEnabled())
            {
                RulerState = XComGameState_Unit(History.GetGameStateForObjectID(Candidate.ObjectID));
                
                if (class'X2Helpers_DLC_Day60'.static.GetRulerNumAppearances(RulerState) > 0)
                {
                    Candidates.AddItem(Candidate);
                }
            }
            else
            {
                Candidates.AddItem(Candidate);
            }
        }
    }

    foreach Candidates(Candidate)
    {
        RulerState = XComGameState_Unit(History.GetGameStateForObjectID(Candidate.ObjectID));

        if (RulerManager.RulerAppearRoll < default.RULER_APPEAR_CHANCE)
        {
            RulerLocation.RulerRef = Candidate;
            RulerLocation.MissionRef = InfiltrationState.GetReference();
            RulerLocation.bActivated = true;
            RulerLocation.bNeedsPopup = false;

            RulerManager = XComGameState_AlienRulerManager(NewGameState.ModifyStateObject(class'XComGameState_AlienRulerManager', RulerManager.ObjectID));
            RulerManager.AlienRulerLocations.AddItem(RulerLocation);

            // The ruler is ready and waiting bwahahaha
			`CI_Trace(RulerState.GetMyTemplateName() @ "is waiting on infiltration" @ InfiltrationState.ObjectID @ "-" @ InfiltrationState.GeneratedMission.BattleOpName);
            return;
        }
    }
}

static function RemoveRulerFromInfiltration (XComGameState NewGameState, XComGameState_MissionSiteInfiltration InfiltrationState)
{
    local XComGameState_AlienRulerManager RulerManager;
    local int i;

    RulerManager = XComGameState_AlienRulerManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_AlienRulerManager'));
    i = RulerManager.AlienRulerLocations.Find('MissionRef', InfiltrationState.GetReference());

    if (i != INDEX_NONE)
    {
        RulerManager = XComGameState_AlienRulerManager(NewGameState.ModifyStateObject(class'XComGameState_AlienRulerManager', RulerManager.ObjectID));
        RulerManager.AlienRulerLocations.Remove(i, 1);
    }
}

static function ClearRulerOnCurrentMission ()
{
	local XComGameState_AlienRulerManager RulerManager;
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference EmptyRef;
	local XComGameState NewGameState;

	RulerManager = XComGameState_AlienRulerManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_AlienRulerManager'));

	if (RulerManager != none && RulerManager.RulerOnCurrentMission.ObjectID > 0)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Clear RulerOnCurrentMission");
		RulerManager = XComGameState_AlienRulerManager(NewGameState.ModifyStateObject(class'XComGameState_AlienRulerManager', RulerManager.ObjectID));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

		RulerManager.ClearActiveRulerTags(XComHQ);
		RulerManager.RulerOnCurrentMission = EmptyRef;

		`GAMERULES.SubmitGameState(NewGameState);

		`CI_Trace("Cleared RulerOnCurrentMission and ruler tags from xcom hq");
	}
}