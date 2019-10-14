class X2OverInfiltrationBonusTemplate extends X2StrategyElementTemplate;

var name MetatdataName;
var bool bSitRep; // If true, then this bonus adds a sitrep to the mission. MetatdataName must be the template name of the sitrep
var array<name> SitRepsToRemove; // Only takes effect if bSitRep is true

var name Milestone;
var int Weight;
var bool DoNotMarkUsed;

var protected localized string BonusName;
var protected localized string BonusDescription;

delegate bool IsAvaliableFn(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration);
delegate ApplyFn(XComGameState NewGameState, X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration);

delegate string GetBonusNameFn(X2OverInfiltrationBonusTemplate BonusTemplate);
delegate string GetBonusDescriptionFn(X2OverInfiltrationBonusTemplate BonusTemplate);

function bool ValidateTemplate (out string strError)
{
	local X2SitRepTemplateManager SitRepTemplateManager;
	local array<name> ExistingSitReps;
	local name SitRep;

	if (!super.ValidateTemplate(strError))
	{
		return false;
	}

	if (class'X2InfiltrationBonusMilestoneTemplateManager'.static.GetMilestoneTemplateManager().GetMilestoneTemplate(Milestone, false) == none)
	{
		strError = "milestone doesn't exist";
		return false;
	}

	if (bSitRep)
	{
		SitRepTemplateManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
		SitRepTemplateManager.GetTemplateNames(ExistingSitReps); // Use an array since FindSitRepTemplate will throw excess redscreens

		if (ExistingSitReps.Find(MetatdataName) == INDEX_NONE)
		{
			strError = "SitRep to be granted doesn't exist";
			return false;
		}

		foreach SitRepsToRemove(SitRep)
		{
			if (ExistingSitReps.Find(SitRep) == INDEX_NONE)
			{
				strError = "SitRep to be removed (" $ SitRep $ ") doesn't exist";
				return false;
			}
		}
	}

	return true;
}

function string GetBonusName()
{
	if (GetBonusNameFn != none)
	{
		return GetBonusNameFn(self);
	}

	return BonusName;
}

function string GetBonusDescription()
{
	if (GetBonusDescriptionFn != none)
	{
		return GetBonusDescriptionFn(self);
	}

	return BonusDescription;
}