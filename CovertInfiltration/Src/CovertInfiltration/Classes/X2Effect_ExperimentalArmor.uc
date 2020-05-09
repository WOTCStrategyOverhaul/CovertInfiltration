
class X2Effect_ExperimentalArmor extends X2Effect_Persistent;

var int CritModifier;
var float ExplosiveResistance;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local Object EffectObj, TargetObj;

	EffectObj = EffectGameState;
	TargetObj = `XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

	`XEVENTMGR.RegisterForEvent(EffectObj, 'UnitTakeEffectDamage', RemoveEffectWhenDamaged, ELD_OnStateSubmitted,,TargetObj,, EffectObj);
}

static function EventListenerReturn RemoveEffectWhenDamaged(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID, Object CallbackData)
{
	local XComGameState_Effect               EffectState;
	local XComGameStateContext_EffectRemoved EffectRemovedContext;
	local XComGameState	                     EffectRemovedGameState;

	`CI_Trace("RemoveEffectWhenDamaged - Event Fired");

	EffectState = XComGameState_Effect(CallbackData);

	EffectRemovedContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);	
	EffectRemovedGameState = `XCOMHISTORY.CreateNewGameState(true, EffectRemovedContext);
	EffectState.RemoveEffect(EffectRemovedGameState, EffectRemovedGameState);
	`TACTICALRULES.SubmitGameState(EffectRemovedGameState);	

	return ELR_NoInterrupt;
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotInfo;

	ShotInfo.ModType = eHit_Crit;
	ShotInfo.Value = CritModifier;
	ShotInfo.Reason = FriendlyName;

	ShotModifiers.AddItem(ShotInfo);
}

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local int DamageMod;

	if (WeaponDamageEffect.bExplosiveDamage)
	{
		DamageMod = -int(float(CurrentDamage) * ExplosiveResistance);
	}

	return DamageMod;
}

defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
