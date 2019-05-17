class XComGameState_Activity extends XComGameState_BaseObject;

var protected name m_TemplateName;
var protected X2ActivityTemplate m_Template;

var StateObjectReference ChainRef;

// XCGS objects that this activity controls. For example, mission site, covert action, etc
var StateObjectReference PrimaryObjectRef;
var StateObjectReference SecondaryObjectRef;

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

simulated function X2ActivityTemplate GetMyTemplate()
{
	if (m_Template == none)
	{
		m_Template = X2ActivityTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
	}

	return m_Template;
}

////////////////
/// Creation ///
////////////////

event OnCreation (optional X2DataTemplate Template)
{
	super.OnCreation(Template);

	m_Template = X2ActivityTemplate(Template);
	m_TemplateName = Template.DataName;
}

/////////////
/// Chain ///
/////////////

function XComGameState_ActivityChain GetActivityChain ()
{
	return XComGameState_ActivityChain(`XCOMHISTORY.GetGameStateForObjectID(ChainRef));
}