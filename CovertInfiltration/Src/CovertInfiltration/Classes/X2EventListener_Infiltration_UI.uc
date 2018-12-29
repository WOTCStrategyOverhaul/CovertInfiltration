//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Listeners for various UI events (mostly CHL hooks)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration_UI extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeoscapeListeners());

	return Templates;
}

static function CHEventListenerTemplate CreateGeoscapeListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Geoscape');
	Template.AddCHEvent('Geoscape_ResInfoButtonVisible', ResistanceButtonVisible, ELD_Immediate); // Relies on CHL #365, will be avaliable in v1.17
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn ResistanceButtonVisible(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_FacilityXCom FacilityState;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'Geoscape_ResInfoButtonVisible') return ELR_NoInterrupt;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	Tuple.Data[0].b = FacilityState != none && !Tuple.Data[1].b;
	
	return ELR_NoInterrupt;
}