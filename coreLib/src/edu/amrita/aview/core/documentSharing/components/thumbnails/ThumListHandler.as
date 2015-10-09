// ActionScript file
import edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents.OnSlideClickEvent;
[Bindable]
private static var _slideIndex:Number;
[Bindable]
[Embed("assets/images/Prev.png")]
private var prevIcon:Class;
[Bindable]
[Embed("assets/images/next.png")]
private var nextIcon:Class;
[Bindable]
[Embed("assets/images/up.png")]
private var upIcon:Class;
[Bindable]
[Embed("assets/images/down.png")]
private var downIcon:Class;
import mx.collections.ArrayCollection;
import mx.events.ListEvent;
import flash.events.MouseEvent;

[Bindable]
private var _thumbNailDataProvider:ArrayCollection;
[Bindable]
private var _isverticalThumbShow:Boolean;
[Bindable]
private var _ishorizontalThumbShow:Boolean;
private static var DIRECTION_LEFT:String="left";
private static var DIRECTION_RIGHT:String="right"
private static var DIRECTION_TOP:String="top"
private static var DIRECTION_DOWN:String="down"

public function set thumbNailDataProvider(dataCollection:ArrayCollection):void{
	_thumbNailDataProvider=dataCollection
}

protected function lstThumbnails_itemClickHandler(event:ListEvent):void{
	// TODO Auto-generated method stub
	this.dispatchEvent(new OnSlideClickEvent(event.currentTarget.selectedItem));
}

protected function cmdScrollPrevForHorizontal_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	setScrol(DIRECTION_LEFT)
}

public function cmdScrollNextForHorizontal_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	setScrol(DIRECTION_RIGHT);
}

public function HorizontalCheckScroll():void{
	if (verticalThumbnail.horizontalScrollPosition == 0)
		//cmdScrollPrev.visible=false;
		cmdScrollPrev.visible=true;
	else
		cmdScrollPrev.visible=true;
	if (verticalThumbnail.horizontalScrollPosition == verticalThumbnail.maxHorizontalScrollPosition)
		cmdScrollNext.visible=true;
		//cmdScrollNext.visible=false;
	else
		cmdScrollNext.visible=true;
}
public function set scrolledIndex(index:Number):void{
	if (index == -1)
		return;
	_slideIndex=index;
	verticalThumbnail.scrollToIndex(_slideIndex);
	horizontalThumbnail.scrollToIndex(_slideIndex);
}

public static function get slideIndex():Number{
	return _slideIndex;
}

public static function set slideIndex(index:Number):void{
	_slideIndex=index;
}

public function set isVerticalThumbShow(value:Boolean):void{
	if (value == true)
		_isverticalThumbShow=true;
	else
		_isverticalThumbShow=false;
}

public function set isHorizontalThumbShow(value:Boolean):void{
	if (value == true)
		_ishorizontalThumbShow=value;
	else
		_ishorizontalThumbShow=value;
}

private function setScrol(direction:String):void{
	var newPos:int;
	if (direction == DIRECTION_TOP)	{
		newPos=horizontalThumbnail.verticalScrollPosition - 1;
		if (newPos >= 0)
			horizontalThumbnail.verticalScrollPosition=newPos;
	}
	else if (direction == DIRECTION_DOWN){
		newPos=horizontalThumbnail.verticalScrollPosition + 1;
		if (newPos <= horizontalThumbnail.maxVerticalScrollPosition)
			horizontalThumbnail.verticalScrollPosition=newPos;
	}
	else if (direction == DIRECTION_LEFT){
		newPos=verticalThumbnail.horizontalScrollPosition - 1;
		if (newPos >= 0)
			verticalThumbnail.horizontalScrollPosition=newPos;
		HorizontalCheckScroll();
	}
	else if (direction == DIRECTION_RIGHT){
		newPos=verticalThumbnail.horizontalScrollPosition + 1;
		if (newPos <= verticalThumbnail.maxHorizontalScrollPosition)
			verticalThumbnail.horizontalScrollPosition=newPos;
		HorizontalCheckScroll();
	}
}
protected function cmdScrollPrevForVertical_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	setScrol(DIRECTION_TOP);
	//HorizontalCheckScroll();

}

protected function cmdScrollNextForVertical_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	setScrol(DIRECTION_DOWN);
}

protected function horizontalThumbnail_mouseWheelHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	if (event.delta == -3)
		setScrol(DIRECTION_DOWN)
	else
		setScrol(DIRECTION_TOP);
}
