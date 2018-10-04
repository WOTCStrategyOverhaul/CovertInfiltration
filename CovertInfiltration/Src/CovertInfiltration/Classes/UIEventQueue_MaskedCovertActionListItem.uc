class UIEventQueue_MaskedCovertActionListItem extends UIEventQueue_CovertActionListItem;

var UIEventQueue_CovertActionListItem InnerItem;
var UIMask Mask;

simulated function UIEventQueue_ListItem InitListItem()
{
	super(UIPanel).InitPanel();

	InnerItem = Spawn(class'UIEventQueue_CovertActionListItem', self);
	InnerItem.InitListItem();
	InnerItem.SetPosition(0, height - class'UIEventQueue_CovertActionListItem'.default.height);
	InnerItem.OnUpButtonClicked = OnInnerUpButtonClicked;
	InnerItem.OnDownButtonClicked = OnInnerDownButtonClicked;
	InnerItem.OnCancelButtonClicked = OnInnerCancelButtonClicked;

	Mask = Spawn(class'UIMask', self);
	Mask.bAnimateOnInit = false;
	Mask.InitMask('', InnerItem);
	Mask.SetPosition(0, 0);
	Mask.SetSize(10000, height);

	return self;
}

simulated function UpdateData(HQEvent Event)
{
	InnerItem.UpdateData(Event);
}

simulated function AS_SetButtonsEnabled(bool EnableUpButton, bool EnableDownButton, bool EnableCancelButton)
{
	InnerItem.AS_SetButtonsEnabled(EnableUpButton, EnableDownButton, EnableCancelButton);
}

simulated function OnInnerUpButtonClicked(int ItemIndex)
{
	OnUpButtonClicked(ItemIndex);
}

simulated function OnInnerDownButtonClicked(int ItemIndex)
{
	OnDownButtonClicked(ItemIndex);
}

simulated function OnInnerCancelButtonClicked(int ItemIndex)
{
	OnCancelButtonClicked(ItemIndex);
}

defaultproperties
{
	LibID = "EmptyControl"
	height = 64
}