class UIListener_AvengerHUD extends UIScreenListener;

var localized string ChainsOverview_Label;
var localized string ChainsOverview_Description;

event OnInit (UIScreen Screen)
{
	local UIAvengerHUD AvengerHud;
	local UIAvengerShortcutSubMenuItem MenuItem;

	AvengerHud = UIAvengerHUD(Screen);
	if (AvengerHud == none) return;

	MenuItem.Id = 'ActivityChainsOverview';
	MenuItem.Message.Label = ChainsOverview_Label;
	//MenuItem.Message.Description = ChainsOverview_Description;
	MenuItem.Message.OnItemClicked = OnChainsOverviewClicked;

	AvengerHud.Shortcuts.AddSubMenu(eUIAvengerShortcutCat_CommandersQuarters, MenuItem);
}

static protected function OnChainsOverviewClicked (optional StateObjectReference Facility)
{
	class'UIUtilities_Infiltration'.static.UIChainsOverview();
}