class X2ActionRiskDescriptionSet extends X2DataSet;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;
	local ActionFlatRiskSitRep FlatRiskDef;
	
	foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskDef)
	{
		Templates.AddItem(CreateForFlatRisk(FlatRiskDef.FlatRiskName));
	}

	return Templates;
}

static function X2ActionRiskDescriptionTemplate CreateForFlatRisk (name RiskName)
{
	local X2ActionRiskDescriptionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActionRiskDescriptionTemplate', Template, RiskName);
	Template.GetDescriptionText = GetFlatRiskDescription;

	return Template;
}

static function string GetFlatRiskDescription (X2ActionRiskDescriptionTemplate Template)
{
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate;
	local int i;

	i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', Template.DataName);
	
	if (i == INDEX_NONE)
	{
		`RedScreen("CI: GetFlatRiskDescription: Not a valid flat risk");
		return "";
	}

	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	SitRepTemplate = SitRepManager.FindSitRepTemplate(class'X2Helper_Infiltration'.default.FlatRiskSitReps[i].SitRepName);

	return SitRepTemplate.Description;
}