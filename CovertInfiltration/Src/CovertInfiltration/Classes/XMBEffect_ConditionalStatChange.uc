class XMBEffect_ConditionalStatChange extends X2Effect_PersistentStatChange;

var array<X2Condition> Conditions;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local XComGameState_Unit UnitState;
	local X2EventManager EventMgr;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	ListenerObj = EffectGameState;

	// Register to tick after EVERY action.
	EventMgr.RegisterForEvent(ListenerObj, 'OnUnitBeginPlay', EventHandler, ELD_OnStateSubmitted, 25, UnitState,, EffectGameState);	
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', EventHandler, ELD_OnStateSubmitted, 25,,, EffectGameState);	
}

static function EventListenerReturn EventHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit UnitState, SourceUnitState, NewUnitState;
	local XComGameState_Effect NewEffectState;
	local XComGameState_Ability AbilityState;
	local XComGameState NewGameState;
	local XMBEffect_ConditionalStatChange EffectTemplate;
	local XComGameState_Effect EffectState;
	local bool bOldApplicable, bNewApplicable;

	EffectState = XComGameState_Effect(CallbackData);
	if (EffectState == none)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	SourceUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	EffectTemplate = XMBEffect_ConditionalStatChange(EffectState.GetX2Effect());

	bOldApplicable = EffectState.StatChanges.Length > 0;
	bNewApplicable = CheckTargetConditions(EffectTemplate.Conditions, EffectState, SourceUnitState, UnitState, AbilityState) == 'AA_Success';

	if (bOldApplicable != bNewApplicable)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Conditional Stat Change");

		NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		NewEffectState = XComGameState_Effect(NewGameState.ModifyStateObject(class'XComGameState_Effect', EffectState.ObjectID));

		if (bNewApplicable)
		{
			NewEffectState.StatChanges = EffectTemplate.m_aStatChanges;

			// Note: ApplyEffectToStats crashes the game if the state objects aren't added to the game state yet
			NewUnitState.ApplyEffectToStats(NewEffectState, NewGameState);
		}
		else
		{
			NewUnitState.UnApplyEffectFromStats(NewEffectState, NewGameState);
			NewEffectState.StatChanges.Length = 0;
		}

		`GAMERULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

// From X2Effect_Persistent.
function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
	return EffectGameState.StatChanges.Length > 0;
}


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super(X2Effect_Persistent).OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

///////////////////////////////
/// From XMBEffectUtilities ///
///////////////////////////////

function static name CheckTargetConditions(out array<X2Condition> AbilityTargetConditions, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	foreach AbilityTargetConditions(kCondition)
	{
		if (kCondition.IsA('XMBCondition_MatchingWeapon'))
		{
			SourceWeapon = AbilityState.GetSourceWeapon();
			if (SourceWeapon == none || EffectState == none)
				return 'AA_WeaponIncompatible';

			ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
			if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
				return 'AA_WeaponIncompatible';
		}

		AvailableCode = kCondition.AbilityMeetsCondition(AbilityState, Target);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;

		AvailableCode = kCondition.MeetsCondition(Target);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
		
		AvailableCode = kCondition.MeetsConditionWithSource(Target, Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	return 'AA_Success';
}