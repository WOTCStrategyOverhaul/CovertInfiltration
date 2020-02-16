class X2ActionRiskDescriptionTemplateManager extends X2DataTemplateManager;

static function X2ActionRiskDescriptionTemplateManager GetActionRiskDescriptionTemplateManager()
{
    return X2ActionRiskDescriptionTemplateManager(class'Engine'.static.GetTemplateManager(class'X2ActionRiskDescriptionTemplateManager'));
}

function X2ActionRiskDescriptionTemplate FindDescriptionTemplate (name RiskName, optional bool ErrorIfNotFound = true)
{
	local X2ActionRiskDescriptionTemplate Template;

	Template = X2ActionRiskDescriptionTemplate(FindDataTemplate(RiskName));

	if (Template == none && ErrorIfNotFound)
	{
		`RedScreen("CI: X2ActionRiskDescriptionTemplate" @ string(RiskName) @ "does not exist");
	}

	return Template;
}

defaultProperties
{
	TemplateDefinitionClass = class'X2ActionRiskDescriptionSet'
	ManagedTemplateClass = class'X2ActionRiskDescriptionTemplate'
}