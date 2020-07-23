class SeqAct_GetUnitPawnTemplateName extends SequenceAction;

var string CharacterTemplateString;
var XComUnitPawn UnitPawn;

event Activated()
{
	local XComGameState_Unit UnitState;
	if (UnitPawn == none) return;
	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitPawn.ObjectID));
	if (UnitState == none)
	{
		`RedScreen("SeqAct_GetUnitPawnTemplateName fail to fetch unit state. ObjectID:" @ UnitPawn.ObjectID);
		return;
	}

	CharacterTemplateString = string(UnitState.GetMyTemplateName());
}

defaultproperties
{
	ObjName="Get Character Template name from Unit Pawn"
	ObjCategory="Covert Infiltration"
	bCallHandler=false
	bAutoActivateOutputLinks=true

	VariableLinks.Empty;
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="UnitPawn",PropertyName=UnitPawn,bWriteable=false)
	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="TemplateString",PropertyName=CharacterTemplateString,bWriteable=true)
}