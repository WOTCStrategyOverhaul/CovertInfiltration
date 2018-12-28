class X2EventListener_Infiltration_Geoscape extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateUIListeners());

	return Templates;
}

static function CHEventListenerTemplate CreateUIListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_Geoscape_UI');
	Template.AddCHEvent('Geoscape_ResInfoButtonVisible', ResistanceButtonVisible, ELD_Immediate);
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