// A copy of UITextContainer with some improvements
// to get vertical autoscroll properly working

class UITextContainerImproved extends UIPanel;

// UIText member variables
var UIBGBox  	bg;
var UIText       text;
var UIMask       mask;
var UIScrollbar	scrollbar;

var int							scrollbarPadding;
var int							bgPadding;
var bool						bAutoScroll; 

simulated function UITextContainerImproved InitTextContainer(optional name InitName, optional string initText,
															 optional float initX, optional float initY, 
															 optional float initWidth, optional float initHeight,
															 optional bool addBG, optional name bgLibID, optional bool initAutoScroll = false)
{
	InitPanel(InitName);

	if(addBG)
	{
		// bg must be added before itemContainer so it draws underneath it
		bg = Spawn(class'UIBGBox', self);
		if(bgLibID != '') bg.LibID = bgLibID;
		bg.InitBG('', 0, 0, initWidth, initHeight);
		bg.ProcessMouseEvents(OnChildMouseEvent);
	}

	bAutoScroll = initAutoScroll; 

	text = Spawn(class'UIText', self).InitText('text', initText, true);
	text.onTextSizeRealized = RealizeTextSize;
	//text.OnMouseEventDelegate = OnChildMouseEvent;
	//text.ProcessMouseEvents(OnChildMouseEvent);

	SetPosition(initX, initY);
	SetSize(initWidth, initHeight);
	
	// text starts off hidden, show after text sizing information is obtained
	text.Hide();
	return self;
}

simulated function UITextContainerImproved SetText(string txt)
{
	text.SetText(txt);
	return self;
}

simulated function UITextContainerImproved SetHTMLText(string txt)
{
	text.SetHTMLText(txt);
	return self;
}

// Sizing this control really means sizing its mask
simulated function SetWidth(float newWidth)
{
	if(width != newWidth)
	{
		width = newWidth;
		text.SetWidth(newWidth);

		if(mask != none && scrollbar != none)
		{
			mask.SetWidth(width);
			scrollbar.SnapToControl(mask);
		}
	}
}

// This is changed
simulated function SetHeight(float newHeight)
{
	if(height != newHeight)
	{
		height = newHeight;
		//text.SetHeight(newHeight);

		if(mask != none)
		{
			mask.SetHeight(height);

			if (scrollbar != none)
			{
				scrollbar.SnapToControl(mask);
			}
		}
	}
}
simulated function UIPanel SetSize(float newWidth, float newHeight)
{
	SetWidth(newWidth);
	SetHeight(newHeight);
	return self;
}

simulated function RealizeTextSize()
{
	local int textPosOffset, textSizeOffset;

	if(bg != none)
	{
		textPosOffset = bgPadding * 0.5;
		textSizeOffset = bgPadding;
	}

	text.ClearScroll();
	if(text.Height > height)
	{
		if(mask == none)
		{
			mask = Spawn(class'UIMask', self).InitMask();
		}
		mask.SetMask(text);
		mask.SetSize(width - textSizeOffset, height - textSizeOffset);
		mask.SetPosition(textPosOffset, textPosOffset);


		if( bAutoScroll )
		{
			text.AnimateScroll( text.Height, height);
		}
		else
		{
			if(scrollbar == none)
			{
				scrollbar = Spawn(class'UIScrollbar', self).InitScrollbar();
			}
			scrollbar.SnapToControl(mask, -scrollbarPadding);
			scrollbar.NotifyPercentChange(text.SetScroll); 
			textSizeOffset += scrollbarPadding;
		}
	}
	else if(mask != none)
	{
		mask.Remove();
		mask = none;

		if(scrollbar != none)
		{
			scrollbar.Remove();
			scrollbar = none;
		}
	}

	// offset text size and location by the bg offset
	text.SetWidth(width - textSizeOffset);
	text.SetPosition(textPosOffset, textPosOffset);
	text.Show();
}

simulated function OnChildMouseEvent( UIPanel control, int cmd )
{
	if(scrollbar != none && cmd == class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_UP)
		scrollbar.OnMouseScrollEvent(-1);
	else if(scrollbar != none && cmd == class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_DOWN)
		scrollbar.OnMouseScrollEvent(1);
}

defaultproperties
{
	bIsNavigable = false;
	scrollbarPadding = 20;
	bgPadding = 20;
}
