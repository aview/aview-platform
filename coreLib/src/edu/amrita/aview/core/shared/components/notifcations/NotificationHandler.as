import edu.amrita.aview.core.shared.components.notifcations.Notification;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.FlexGlobals;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;

[Embed(source="/edu/amrita/aview/core/shared/components/notifcations/assets/images/mic.png")]
[Bindable]
public static var mic:Class;
[Embed(source="/edu/amrita/aview/core/shared/components/notifcations/assets/images/micMute.png")]
[Bindable]
public static var micMute:Class;
[Embed(source="/edu/amrita/aview/core/shared/components/notifcations/assets/images/presenter.png")]
[Bindable]
public static var presenter:Class;
[Embed(source="/edu/amrita/aview/core/shared/components/notifcations/assets/images/interaction.png")]
[Bindable]
public static var interaction:Class;

[Bindable]
public var notificationImages:Class;

public static const NOTIFICATION_INTERACTION:String="NOTIFICATION_INTERACTION";
public static const MIC_MUTED:String="MIC_MUTED";
public static const MIC_UNMUTED:String="MIC_UNMUTED";
public static const PRESENTER_CONTROL:String="PRESENTER_CONTROL";
/**
 * To store the message to show in the message box
 */
[Bindable]
public var message:String="Default Message";


private var startTime:Number;
private var endTime:Number;
private var notificationTimer:Timer;


public static function show(message:String="", parent:DisplayObject=null, iconZ:Class=null):Notification
{
	var notificationWindow:Notification=new Notification();
	
	notificationWindow.notificationImages=iconZ;

	notificationWindow.message=message;

	notificationWindow.setFocus();
	if (!parent)
	{
		var sm:ISystemManager=ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		var mp:Object=sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		if (mp && mp.useSWFBridge())
			parent=Sprite(sm.getSandboxRoot());
		else
			parent=Sprite(FlexGlobals.topLevelApplication);
	}
	
	PopUpManager.addPopUp(notificationWindow, parent, true);
	PopUpManager.centerPopUp(notificationWindow);
	return notificationWindow;
}
public function startTimer():void
{
	startTime = new Date().time;
	endTime = new Date().time + Number(7) * 1000;
	if(notificationTimer==null)
		notificationTimer = new Timer(500);
	notificationTimer.addEventListener(TimerEvent.TIMER, onTimerInterval);
	notificationTimer.start();
}

public  function onTimerInterval(event:Event):void{
	var now:Number = new Date().time;
	if(endTime <= now){
		PopUpManager.removePopUp(this);
		notificationTimer.stop();
	}else{
		//countDownTimerDisplay.text = Math.round((endTime - now)/1000).toString();
		notificationTimer.start();
	}
}
