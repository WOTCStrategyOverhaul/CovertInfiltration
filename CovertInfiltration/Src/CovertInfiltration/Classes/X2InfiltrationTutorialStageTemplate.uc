class X2InfiltrationTutorialStageTemplate extends X2EventListenerTemplate;

var name TriggerEvent;
var EventListenerDeferral Defferal;
var array<name> PrecedingStages; // Do not trigger if these are not yet shown

var string ImagePath;

var localized string strHeader;
var localized string strDescription;

delegate bool FilterEventArguments (Object EventData, Object EventSource, X2InfiltrationTutorialStageTemplate Template);

function bool ValidateTemplate (out string strError)
{
	local X2EventListenerTemplateManager TemplateManager;
	local name RequiredStageName;

	if (Defferal != ELD_Immediate || Defferal == ELD_OnStateSubmitted)
	{
		strError = "Only ELD_Immediate and ELD_OnStateSubmitted are supported";
		return false;
	}

	TemplateManager = class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager();

	foreach PrecedingStages(RequiredStageName)
	{
		if (X2InfiltrationTutorialStageTemplate(TemplateManager.FindEventListenerTemplate(RequiredStageName)) == none)
		{
			strError = RequiredStageName @ " in PrecedingStages wasn't found";
			return false;
		}
	}

	return true;
}

function RegisterForEvents ()
{
	local X2EventManager EventManager;
	local Object selfObject;

	super.RegisterForEvents();

	EventManager = `XEVENTMGR;
	selfObject = self;

	EventManager.RegisterForEvent(selfObject, TriggerEvent, OnTriggerEvent, Defferal);
}

protected function EventListenerReturn OnTriggerEvent (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;
	local name RequiredStageName;
	local bool bSubmitLocally;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	// Check if this tutorial stage has been shown already
	if (CIInfo.TutorialStagesShown.Find(DataName) != INDEX_NONE) return ELR_NoInterrupt;

	// Check if all prerequisites have been met
	foreach PrecedingStages(RequiredStageName)
	{
		if (CIInfo.TutorialStagesShown.Find(RequiredStageName) == INDEX_NONE) return ELR_NoInterrupt;
	}

	// If the FilterEventArguments delegate is set, check it
	if (FilterEventArguments != none && !FilterEventArguments(EventData, EventSource, self)) return ELR_NoInterrupt;

	// Record the stage as completed
	if (Defferal == ELD_Immediate && GameState != none)
	{
		NewGameState = GameState;
	}
	else
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Marking tutorial stage complete");
		bSubmitLocally = true;
	}

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	CIInfo.TutorialStagesShown.AddItem(DataName);

	if (bSubmitLocally) `SubmitGameState(NewGameState);

	// Show the popup
	`PRESBASE.UITutorialBox(strHeader, strDescription, ImagePath);

	return ELR_NoInterrupt;
}

defaultproperties
{
	RegisterInStrategy = true
}