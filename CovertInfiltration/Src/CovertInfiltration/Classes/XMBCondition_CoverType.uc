class XMBCondition_CoverType extends X2Condition;

var array<ECoverType> AllowedCoverTypes;
var array<ECoverType> ExcludedCoverTypes;
var bool bRequireCanTakeCover;
var bool bCheckRelativeToSource;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local GameRulesCache_VisibilityInfo VisInfo;
	local XComGameState_Unit TargetUnit;
	local int HistoryIndex;
	local XComGameStateHistory History;
	local ECoverType CoverType;

	History = `XCOMHISTORY;
	HistoryIndex = History.GetCurrentHistoryIndex();

	if (!bCheckRelativeToSource)
		return 'AA_Success';

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit != none && !TargetUnit.IsAlive())
	{
		kTarget = History.GetPreviousGameStateForObject(kTarget);
		HistoryIndex = kTarget.GetParentGameState().HistoryIndex;
		TargetUnit = XComGameState_Unit(kTarget);
	}

	if (AllowedCoverTypes.Length > 0 || ExcludedCoverTypes.Length > 0)
	{
		if (kTarget == none)
			return 'AA_NoTargets';
		if (!`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(kSource.ObjectID, kTarget.ObjectID, VisInfo, HistoryIndex))
			return 'AA_NotInRange';
		CoverType = VisInfo.TargetCover;
	}

	if (AllowedCoverTypes.Length > 0)
	{
		if (AllowedCoverTypes.Find(CoverType) == INDEX_NONE)
			return 'AA_InvalidTargetCoverType';
	}

	if (ExcludedCoverTypes.Length > 0)
	{
		if (ExcludedCoverTypes.Find(CoverType) != INDEX_NONE)
			return 'AA_InvalidTargetCoverType';
	}

	return 'AA_Success';
}

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;
	local XComGameStateHistory History;
	local ECoverType CoverType;

	History = `XCOMHISTORY;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit != none && !TargetUnit.IsAlive())
	{
		kTarget = History.GetPreviousGameStateForObject(kTarget);
		TargetUnit = XComGameState_Unit(kTarget);
	}

	if (bRequireCanTakeCover)
	{
		if (TargetUnit == none)
			return 'AA_NotAUnit';
		if (!TargetUnit.GetMyTemplate().bCanTakeCover)
			return 'AA_InvalidTargetCoverType';
	}
	
	if (bCheckRelativeToSource)
		return 'AA_Success';

	if (AllowedCoverTypes.Length > 0 || ExcludedCoverTypes.Length > 0)
	{
		if (kTarget == none)
			return 'AA_NoTargets';
		CoverType = TargetUnit.GetCoverTypeFromLocation();
	}

	if (AllowedCoverTypes.Length > 0)
	{
		if (AllowedCoverTypes.Find(CoverType) == INDEX_NONE)
			return 'AA_InvalidTargetCoverType';
	}

	if (ExcludedCoverTypes.Length > 0)
	{
		if (ExcludedCoverTypes.Find(CoverType) != INDEX_NONE)
			return 'AA_InvalidTargetCoverType';
	}

	return 'AA_Success';
}

defaultproperties
{
	bCheckRelativeToSource = true
}