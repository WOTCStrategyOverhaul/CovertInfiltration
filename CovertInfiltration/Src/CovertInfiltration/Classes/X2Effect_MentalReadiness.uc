//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Effect to modify the result of psionic
//           mental-type attacks on a target
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Effect_MentalReadiness extends X2Effect_PersistentStatChange;

var int HitMod;

function GetToHitAsTargetModifiersForStatCheck(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotModifier;
	
	if (AbilityState.GetMyTemplate().AbilitySourceName == 'eAbilitySource_Psionic')
	{
		ShotModifier.ModType = eHit_Success;
		ShotModifier.Value = HitMod;
		ShotModifier.Reason = FriendlyName;
		ShotModifiers.AddItem(ShotModifier);
	}
}