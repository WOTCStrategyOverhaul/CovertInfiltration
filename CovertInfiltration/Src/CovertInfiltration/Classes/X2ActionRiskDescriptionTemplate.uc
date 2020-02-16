class X2ActionRiskDescriptionTemplate extends X2DataTemplate;

var localized string DescriptionText;

delegate string GetDescriptionText (X2ActionRiskDescriptionTemplate Template);

//////////////////
/// Validation ///
//////////////////

function bool ValidateTemplate (out string strError)
{
	local X2StrategyElementTemplateManager StrategyTemplateManager;
	
	if (!super.ValidateTemplate(strError))
	{
		return false;
	}

	StrategyTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	if (X2CovertActionRiskTemplate(StrategyTemplateManager.FindStrategyElementTemplate(DataName)) == none)
	{
		strError = "does not match an X2CovertActionRiskTemplate";
		return false;
	}

	if (GetDescriptionText == none)
	{
		strError = "no GetDescriptionText set";
		return false;
	}

	if (GetDescriptionText == static.DefaultGetDescriptionText && DescriptionText == "")
	{
		strError = "empty DescriptionText and no custom GetDescriptionText set";
		return false;
	}

	return true;
}

////////////////
/// Defaults ///
////////////////

static function string DefaultGetDescriptionText (X2ActionRiskDescriptionTemplate Template)
{
	return Template.DescriptionText;
}

defaultproperties
{
	GetDescriptionText = DefaultGetDescriptionText
}