//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is an event listener which shows the resource bar 
//           on UICovertActionsGeoscape
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

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
	local UIScreenStack ScreenStack;

	local UIScreen CurrentScreen;
	local UICovertActionsGeoscape CovertActions;

	AvengerHUD = `HQPRES.m_kAvengerHUD;
	ScreenStack = AvengerHUD.Movie.Pres.ScreenStack;

	CurrentScreen = ScreenStack.GetCurrentScreen();
	CovertActions = UICovertActionsGeoscape(ScreenStack.GetFirstInstanceOf(class'UICovertActionsGeoscape'));

	if (CovertActions == none) return ELR_NoInterrupt;

	if (
		CurrentScreen == CovertActions ||
		(CovertActions.SSManager != none && CovertActions.SSManager.ShouldShowResourceBar() && CurrentScreen.IsA(class'UISquadSelect'.Name))
	) {
		// Just do same thing as done for UICovertActions
		AvengerHUD.UpdateSupplies();
		AvengerHUD.UpdateIntel();
		AvengerHUD.UpdateAlienAlloys();
		AvengerHUD.UpdateEleriumCrystals();

		// Resource bar is hidden by default, show it
		AvengerHUD.ShowResources();
	}

	return ELR_NoInterrupt;
}