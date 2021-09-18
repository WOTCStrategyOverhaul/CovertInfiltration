//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Disables non-compliant campaign start options 
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_CampaignStartMenu extends UIScreenListener;

var localized string strDisabledTutorialTooltip;
var localized string strDisabledNarrativeContentTooltip;

event OnInit(UIScreen Screen)
{
    local UIShellDifficulty ShellDifficulty;
    local UIShellNarrativeContent ShellNarrativeContent;
    
    if (UIShellDifficulty(Screen) != none)
    {
        ShellDifficulty = UIShellDifficulty(Screen);

		// Do not show "are you sure you want to start without tutorial?" popup if fresh profile
		ShellDifficulty.m_bShowedFirstTimeTutorialNotice = true;

		// Set tutorial to disabled - skip the default callback and call UpdateTutorial directly as 
		// otherwise we will get "are you sure you want to disable the tutorial?" popup if fresh profile
        ShellDifficulty.m_TutorialMechaItem.Checkbox.SetChecked(false, false);
		ShellDifficulty.UpdateTutorial(ShellDifficulty.m_TutorialMechaItem.Checkbox);

		// Disable the checkbox - must be after UpdateTutorial() above as that will set it to enabled
        ShellDifficulty.m_TutorialMechaItem.SetDisabled(true, strDisabledTutorialTooltip);
    }

    if (UIShellNarrativeContent(Screen) != none)
    {
        ShellNarrativeContent = UIShellNarrativeContent(Screen);
		ShellNarrativeContent.m_bShowedXpackNarrtiveNotice = true;
        ShellNarrativeContent.m_XpacknarrativeMechaItem.Checkbox.SetChecked(false);
        ShellNarrativeContent.m_XpacknarrativeMechaItem.SetDisabled(true, strDisabledNarrativeContentTooltip);
    }
}