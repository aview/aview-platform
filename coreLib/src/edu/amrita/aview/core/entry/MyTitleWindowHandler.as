// ActionScript file

import flash.events.MouseEvent;

private function init():void
{
	this.titleBar.addEventListener(MouseEvent.MOUSE_DOWN, moveWindow);
}

private function moveWindow(event:MouseEvent):void
{
	//FlexGlobals.topLevelApplication.mainApp.nativeWindow.startMove();
	applicationType::desktop
	{
		//For Web: Since native window is not available for web.So commented following logic.
		stage.nativeWindow.startMove();
	}
}
