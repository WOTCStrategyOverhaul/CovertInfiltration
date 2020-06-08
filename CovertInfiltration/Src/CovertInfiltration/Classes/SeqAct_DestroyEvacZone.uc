//---------------------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    SeqAct_DestroyEvacZone.uc
//	AUTHOR:	 E3245
//  PURPOSE: Destroys an Evac zone by destroying its Visualizer and GameState
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//--------------------------------------------------------------------------------------- 

class SeqAct_DestroyEvacZone extends SequenceAction
	implements(X2KismetSeqOpVisualizer);

function Activated();
function BuildVisualization(XComGameState GameState);

function ModifyKismetGameState(out XComGameState GameState)
{
	local XComGameState_EvacZone	EvacZone;
	local X2Actor_EvacZone			EvacZoneActor;
		
	// if the evac zone already exists. Destroy it.
	EvacZone = class'XComGameState_EvacZone'.static.GetEvacZone();
	if (EvacZone != none)
	{
		EvacZoneActor = X2Actor_EvacZone(EvacZone.GetVisualizer());
		if (EvacZoneActor  != none)
		{
			EvacZoneActor.Destroy( );
			//Remove state from Gamestate
			GameState.RemoveStateObject(EvacZone.ObjectID);
			//EvacZoneFlares' Event ID
//			class'WorldInfo'.static.GetWorldInfo().PlayAkEvent(AkEvent'SoundEnvironment.Skyranger_Tactical_Stop');
		}
	}
}

static event int GetObjClassVersion()
{
	return super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjCategory="Level"
	ObjName="Destroy Evac Zone"
//	bCallHandler=false

    bConvertedForReplaySystem=true
    bCanBeUsedForGameplaySequence=true

	bAutoActivateOutputLinks=true
}