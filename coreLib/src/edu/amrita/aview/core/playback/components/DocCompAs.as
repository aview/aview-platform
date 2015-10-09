// ActionScript file
// ActionScript file
import edu.amrita.aview.core.playback.DocumentPlayer;
import edu.amrita.aview.core.playback.events.AviewPlayerEvent;

import flash.events.Event;

import mx.collections.ArrayCollection;

public var documentPlayer:DocumentPlayer=new DocumentPlayer();
[Bindable]
private var docHeight:Number
[Bindable]
private var docWidth:Number
private function init():void
{
	
	documentPlayer.setUiReference(p2fLoader,docCanvas,ispringLoader,ispringCanvas,baseContainer,docHeight,docWidth);
	setDocLoader()
}

public function closeSlidePanel():void
{
	this.removeChild(slideWndw);
	baseContainer.percentHeight=100;  
	this.dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.SLIDE_PANNEL_CLOSSED));
	//(uploadFile,fileExtention,currentParentFolder+"/"+uploadFile));	 	      		 	
}
private function setDocLoader():void
{
	var tempWidth:Number;
	
	docHeight=baseContainer.height-10;				 
	tempWidth=(docHeight / 3) * 4;
	if (tempWidth >= baseContainer.width)
	{
		docWidth=baseContainer.width-10;
		docHeight=(docHeight/ 4) * 3;
	}
	else
	{
		docWidth=tempWidth;
	}	
}
public function slidelist_itemClickHandler(event:Event):void
{
//	documentPlayer.setContext(event.currentTarget.selectedItem.ctime)
	var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.SlideSlected);
	evnt.time=event.currentTarget.selectedItem.ctime
	this.dispatchEvent(evnt);
	
}