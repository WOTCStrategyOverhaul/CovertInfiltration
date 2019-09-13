class UIChainsOverview_ListSectionHeader extends UIPanel;

var UIBGBox BG;
var UIText Text;

var protected GFxObject DagsMask;
var protected GFxObject Dags;

simulated function InitHeader (optional name InitName)
{
	InitPanel(InitName);
	Width = GetParent(class'UIList', true).Width;

	BG = Spawn(class'UIBGBox', self);
	BG.InitBG('BG');
	BG.SetSize(Width, Height - 5);
	BG.SetOutline(false, class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR);
	BG.SetAlpha(30);

	Text = Spawn(class'UIText', self);
	Text.InitText('Text');
	Text.SetPosition(3, 0);
	Text.SetWidth(Width - 3 * 2);
	Text.SetAlpha(50);
}

simulated function OnInit()
{
	super.OnInit();

	SpawnDags();
}

simulated protected function SpawnDags ()
{
	local GFxObject gfxSelf;
	local ASColorTransform Colour;

	gfxSelf = Movie.GetVariableObject(string(MCPath));

	DagsMask = gfxSelf.AttachMovie("dagMask", "dagMask", 100);
	DagsMask.SetPosition(3, 15 / 2 /* Half of height */ + 30);
	DagsMask.SetFloat("_height", 15);
	DagsMask.SetFloat("_width", Text.Width);

	Colour.Multiply.A = 0.149;
	Colour.Add.R = 154;
	Colour.Add.G = 203;
	Colour.Add.B = 203;

	Dags = gfxSelf.AttachMovie("dags", "dags", 101);
	Dags.SetPosition(-30, 15 / 2 /* Half of height */ + 30);
	Dags.SetFloat("_height", 15);
	Dags.SetColorTransform(Colour);
	Dags.SetFloat("_xscale", 50);

	DagsSetMask(DagsMask);

	// Positioning - x is is left offset, y is the center (from origin to height/2)
}

simulated protected function DagsSetMask (GFxObject Mask)
{
	Dags.ActionScriptVoid("setMask");
}

simulated function SetText (string strValue)
{
	Text.SetHTMLText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Infiltration'.static.ColourText(
				strValue,
				class'UIUtilities_Colors'.const.PERK_HTML_COLOR
			),
			Screen.bIsIn3D, true,, 24
		)
	);
}

defaultproperties
{
	bIsNavigable = false
	Height = 55
}