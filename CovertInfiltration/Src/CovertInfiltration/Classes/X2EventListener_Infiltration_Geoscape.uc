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
	Template.AddCHEvent('Geoscape_ResInfoButtonVisiblie', ResistanceButtonVisible, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn ResistanceButtonVisible(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_FacilityXCom FacilityState;
	local UIStrategyMap StrategyMap;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'Geoscape_ResInfoButtonVisiblie') return ELR_NoInterrupt;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	StrategyMap = UIStrategyMap(`SCREENSTACK.GetFirstInstanceOf(class'UIStrategyMap'));

	Tuple.Data[0].b = FacilityState != none && !StrategyMap.IsInFlightMode();
	
	return ELR_NoInterrupt;
}