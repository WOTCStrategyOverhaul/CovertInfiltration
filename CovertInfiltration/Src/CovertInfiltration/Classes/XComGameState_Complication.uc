//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Allows transfer of data objects through the lifetime of a complication
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_Complication extends XComGameState_BaseObject;

var protected name m_TemplateName;
var protected X2ComplicationTemplate m_Template;

var array<StateObjectReference> ComplicationObjectRefs;

var int TriggerChance;

static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

simulated function name GetMyTemplateName()
{
	if (m_TemplateName == '')
	{
		`RedScreen("ComplicationState has missing TemplateName!");
	}

	return m_TemplateName;
}

simulated function X2ComplicationTemplate GetMyTemplate()
{
	if (m_Template == none)
	{
		m_Template = X2ComplicationTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
	}

	return m_Template;
}

event OnCreation(optional X2DataTemplate Template)
{
	super.OnCreation( Template );

	m_Template = X2ComplicationTemplate(Template);
	m_TemplateName = Template.DataName;
}
