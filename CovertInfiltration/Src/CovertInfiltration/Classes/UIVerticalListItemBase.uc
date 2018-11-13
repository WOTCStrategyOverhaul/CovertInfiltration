class UIVerticalListItemBase extends UIPanel abstract;

var privatewrite UIList ParentList;

simulated protected function InitListItemBase(optional name InitName)
{
	InitPanel(InitName);

	ParentList = UIList(GetParent(class'UIList')); // list items must be owned by UIList.ItemContainer

	if (ParentList == none)
	{
		ScriptTrace();
		`warn("UIVerticalListItemBase items must be owned by UIList.ItemContainer");
	}
	else
	{
		SetWidth(ParentList.Width);
	}
}