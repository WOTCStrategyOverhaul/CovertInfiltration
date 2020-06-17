//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This sequence action is used in kismet to override an object's hack rewards,
//           removing all strategic resource rewards and editing hack defense
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SeqAct_ForceInteractiveObjectTacticalHack extends SequenceAction;

var XComGameState_InteractiveObject InteractiveObject;
var int HackDefense;

event Activated()
{
    local XComGameState NewGameState;
    local XComGameState_InteractiveObject NewInteractiveObject;
	local array<name> OldHackRewards, NewHackRewards;
	
    if (InteractiveObject != none)
    {
		OldHackRewards = InteractiveObject.GetHackRewards('');
		`TACTICALMISSIONMGR.SelectHackRewards('PureTacticalHackRewards', '', NewHackRewards);
		NewHackRewards.InsertItem(0, OldHackRewards[0]);
		
        NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SeqAct_ForceInteractiveObjectTacticalHack: " @ InteractiveObject.GetVisualizer() @ " (" @ InteractiveObject.ObjectID @ ")");
        NewInteractiveObject = XComGameState_InteractiveObject(NewGameState.CreateStateObject(class'XComGameState_InteractiveObject', InteractiveObject.ObjectID));
        
		NewInteractiveObject.SetLocked(HackDefense);
		NewInteractiveObject.bOffersStrategyHackRewards = false;
		NewInteractiveObject.bOffersTacticalHackRewards = true;
		NewInteractiveObject.SetHackRewards(class'X2HackRewardTemplateManager'.static.SelectHackRewards(NewHackRewards));

		NewGameState.AddStateObject(NewInteractiveObject);
        `TACTICALRULES.SubmitGameState(NewGameState);
    }
}

defaultproperties
{
    ObjName="Force Interactive Object Tactical Hack"
    ObjCategory="CovertInfiltration"
    bConvertedForReplaySystem=true
    bCanBeUsedForGameplaySequence=true

    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_InteractiveObject',LinkDesc="Interactive Object",PropertyName=InteractiveObject,bWriteable=false)
    VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Hack Defense",PropertyName=HackDefense,bWriteable=false)
}
