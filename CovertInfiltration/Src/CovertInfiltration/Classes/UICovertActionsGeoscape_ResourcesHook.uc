class UICovertActionsGeoscape_ResourcesHook extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateShowResourcesTemplate());

	return Templates;
}

static function X2EventListenerTemplate CreateShowResourcesTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'UICovertActionsGeoscape_ResourcesHook');

	Template.RegisterInStrategy = true;
	Template.AddCHEvent('UpdateResources', OnUpdateResources, ELD_Immediate);

	return Template;
}

static function EventListenerReturn OnUpdateResources(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local UIAvengerHUD AvengerHUD;
	AvengerHUD = `HQPRES.m_kAvengerHUD;

	// Check if we are in the UICovertActionsGeoscape
	if (UICovertActionsGeoscape(AvengerHUD.Movie.Pres.ScreenStack.GetCurrentScreen()) == none) return ELR_NoInterrupt;

	// Just do same thing as done for UICovertActions
	AvengerHUD.UpdateSupplies();
	AvengerHUD.UpdateIntel();
	AvengerHUD.UpdateAlienAlloys();
	AvengerHUD.UpdateEleriumCrystals();

	// Resource bar is hidden by default, show it
	AvengerHUD.ShowResources();

	return ELR_NoInterrupt;
}