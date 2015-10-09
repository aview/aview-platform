import flash.events.KeyboardEvent;
import mx.managers.PopUpManager;

[Bindable]
public var classroomStatus:Boolean=false;

protected function init():void
{
	
		sessionContainer.visible=classroomStatus;
		sessionContainer.includeInLayout=classroomStatus;
		this.setFocus();
	
	
}
private function keydownhandler(event:KeyboardEvent):void
{
	if (event.keyCode==27)
		PopUpManager.removePopUp(this);
	//Alert.show();
}