import edu.amrita.aview.core.documentSharing.components.annotations.AnnotationToolSelected;

import flash.events.MouseEvent;

protected function pen_clickHandler(event:MouseEvent):void{
	this.dispatchEvent(new AnnotationToolSelected("Pen"));
}

protected function highlighter_clickHandler(event:MouseEvent):void{
	this.dispatchEvent(new AnnotationToolSelected("Highlight"));
}

protected function eraser_clickHandler(event:MouseEvent):void{
	this.dispatchEvent(new AnnotationToolSelected("Eraser"));
}
