class X2SitRepEffect_GrantAbilities_CI extends X2SitRepEffect_GrantAbilities;

var bool ExcludeOrganic;

function GetAbilitiesToGrant(XComGameState_Unit UnitState, out array<name> AbilityTemplates)
{
	AbilityTemplates.Length = 0;

    if ((GrantToSoldiers && !UnitState.IsSoldier()) || (ExcludeOrganic && !UnitState.IsRobotic()))
    {
        return;
    }
    
    if (CharacterTemplateNames.Length > 0 && CharacterTemplateNames.Find(UnitState.GetMyTemplateName()) == INDEX_NONE)
	{
		return;
	}

	if (Teams.Length > 0 && Teams.Find(UnitState.GetTeam()) == INDEX_NONE)
	{
		return;
	}

    AbilityTemplates = AbilityTemplateNames;
}