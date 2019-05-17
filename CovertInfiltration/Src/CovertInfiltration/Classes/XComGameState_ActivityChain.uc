class XComGameState_ActivityChain extends XComGameState_BaseObject;

var protected name m_TemplateName;
var protected X2ActivityChainTemplate m_Template;

// Matches 1:1 with X2ActivityChainTemplate::Stages
// Note that all stages are created when the chain is created
var array<StateObjectReference> StageRefs;

// References to objects that this chain is about
// For example: reward units, dark event, etc
var array<StateObjectReference> ChainObjectRefs;

////////////////
/// Template ///
////////////////

static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

simulated function name GetMyTemplateName()
{
	return m_TemplateName;
}

simulated function X2ActivityChainTemplate GetMyTemplate()
{
	if (m_Template == none)
	{
		m_Template = X2ActivityChainTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
	}

	return m_Template;
}

////////////////
/// Creation ///
////////////////

event OnCreation (optional X2DataTemplate Template)
{
	super.OnCreation(Template);

	m_Template = X2ActivityChainTemplate(Template);
	m_TemplateName = Template.DataName;
}