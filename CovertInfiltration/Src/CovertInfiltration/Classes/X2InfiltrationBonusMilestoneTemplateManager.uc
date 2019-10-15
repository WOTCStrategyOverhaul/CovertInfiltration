class X2InfiltrationBonusMilestoneTemplateManager extends X2DataTemplateManager;

static function X2InfiltrationBonusMilestoneTemplateManager GetMilestoneTemplateManager()
{
    return X2InfiltrationBonusMilestoneTemplateManager(class'Engine'.static.GetTemplateManager(class'X2InfiltrationBonusMilestoneTemplateManager'));
}

function X2InfiltrationBonusMilestoneTemplate GetMilestoneTemplate (name TemplateName, optional bool ErrorIfNotFound = true)
{
	local X2InfiltrationBonusMilestoneTemplate Template;

	Template = X2InfiltrationBonusMilestoneTemplate(FindDataTemplate(TemplateName));

	if (Template == none && ErrorIfNotFound)
	{
		`RedScreen("CI: X2InfiltrationBonusMilestoneTemplate" @ TemplateName @ "does not exist");
	}

	return Template;
}

function array<X2InfiltrationBonusMilestoneTemplate> GetSortedBonusMilestones ()
{
	local array<X2InfiltrationBonusMilestoneTemplate> SortedMilestones;
	local X2InfiltrationBonusMilestoneTemplate MilestoneTemplate;
	local X2DataTemplate DataTemplate;

	foreach IterateTemplates(DataTemplate)
	{
		MilestoneTemplate = X2InfiltrationBonusMilestoneTemplate(DataTemplate);
		SortedMilestones.AddItem(MilestoneTemplate);
	}

	SortedMilestones.Sort(CompareBonusMilestones);
	return SortedMilestones;
}

protected static function int CompareBonusMilestones (X2InfiltrationBonusMilestoneTemplate A, X2InfiltrationBonusMilestoneTemplate B)
{
	if (A.ActivateAtProgress == B.ActivateAtProgress) return 0;

	return A.ActivateAtProgress < B.ActivateAtProgress ? 1 : -1;
}

protected event ValidateTemplatesEvent ()
{
	local array<X2InfiltrationBonusMilestoneTemplate> SortedMilestones;
	local int i;

	super.ValidateTemplatesEvent();

	// Make sure that we don't have duplicated milestones by progress
	SortedMilestones = GetSortedBonusMilestones();
	for (i = 1; i < SortedMilestones.Length; i++)
	{
		if (SortedMilestones[i - 1].ActivateAtProgress == SortedMilestones[i].ActivateAtProgress)
		{
			`RedScreen("X2InfiltrationBonusMilestoneTemplate" @ SortedMilestones[i - 1].DataName @ "and" @ SortedMilestones[i].DataName @ "have same ActivateAtProgress value, THIS WILL CAUSE UNDEFINED BEHAVIOUR");
		}
	}
}

defaultProperties
{
	TemplateDefinitionClass=class'X2InfiltrationBonusMilestoneSet'
	ManagedTemplateClass=class'X2InfiltrationBonusMilestoneTemplate'
}