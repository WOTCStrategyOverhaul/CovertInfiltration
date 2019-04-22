class UIListener_ItemAvaliable extends UIScreenListener config(UI);

struct ItemAvaliableImageReplacement
{
	var name TargetItem;
	var name ImageSourceItem;
};

var config array<ItemAvaliableImageReplacement> ImageReplacemenes;

event OnInit(UIScreen Screen)
{
	local X2ItemTemplateManager TemplateManager;
	local X2ItemTemplate ImageSourceTemplate;
	local name TemplateName;
	local UIAlert Alert;
	local int i;

	Alert = UIAlert(Screen);
	if (Alert == none) return;
	if (Alert.eAlertName != 'eAlert_ItemAvailable') return;

	TemplateName = class'X2StrategyGameRulesetDataStructures'.static.GetDynamicNameProperty(Alert.DisplayPropertySet, 'ItemTemplate');
	i = ImageReplacemenes.Find('TargetItem', TemplateName);

	if (i != INDEX_NONE)
	{
		TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
		ImageSourceTemplate = TemplateManager.FindItemTemplate(ImageReplacemenes[i].ImageSourceItem);

		if (ImageSourceTemplate != none && ImageSourceTemplate.strImage != "")
		{
			Alert.LibraryPanel.MC.ChildFunctionString("alertImage", "loadImage", ImageSourceTemplate.strImage);

			// TODO: For some reason the size is too big, gotta fix

			Alert.LibraryPanel.MC.BeginChildFunctionOp("alertImage", "setImageSize");
			Alert.LibraryPanel.MC.QueueNumber(533);
			Alert.LibraryPanel.MC.QueueNumber(300);
			Alert.LibraryPanel.MC.EndOp();

			Alert.LibraryPanel.MC.FunctionVoid("AnimateIn");
		}
	}
}