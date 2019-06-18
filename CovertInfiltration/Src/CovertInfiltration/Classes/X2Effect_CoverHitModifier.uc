class X2Effect_CoverHitModifier extends X2Effect_Persistent;

var ECoverType RequiredCoverType;
var int HitModValue;

function GetToHitAsTargetModifiers (XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local GameRulesCache_VisibilityInfo VisInfo;
	local ShotModifierInfo ModInfo;

	`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo);

	if (!bIndirectFire && !bMelee && VisInfo.TargetCover == RequiredCoverType)
	{
		ModInfo.ModType = eHit_Success;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = HitModValue;

		ShotModifiers.AddItem(ModInfo);
	}
}