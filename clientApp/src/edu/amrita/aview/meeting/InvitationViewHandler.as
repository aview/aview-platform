import edu.amrita.aview.meeting.InvitationModel;
applicationType::desktop{
	import flash.display.NativeWindowDisplayState;
	import flash.events.NativeWindowDisplayStateEvent;
}
import flash.media.Sound;
import flash.media.SoundChannel;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

[Bindable]
public var invitationModel:InvitationModel=null;

[Embed(source="assets/images/ring.mp3")] 
[Bindable]
public var sndCls:Class;

public var snd:Sound;
public var sndChannel:SoundChannel;		

public function removeme():void
{
	PopUpManager.removePopUp(this);				
}

public function initInvitation():void
{
	snd=new sndCls()as Sound;
	sndChannel=snd.play();
	btnAccept.setFocus();
	var moderator:String=invitationModel.moderatorName;
	
	txtInvMsg.text='Meeting Invitation from '+moderator+
		' to the meeting : '+invitationModel.meetingName;
	blinkTaskBar();
	applicationType::desktop{
		if(FlexGlobals.topLevelApplication.nativeWindow.displayState==NativeWindowDisplayState.MINIMIZED)
		{
			FlexGlobals.topLevelApplication.nativeWindow.addEventListener
				(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,onNativeWindowDisplaStateChange);
		}
	}
}
applicationType::desktop{
	private function onNativeWindowDisplaStateChange(event:NativeWindowDisplayStateEvent):void
	{
		FlexGlobals.topLevelApplication.nativeWindow.removeEventListener
			(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,onNativeWindowDisplaStateChange);
		
		PopUpManager.centerPopUp(this);
	}
}

/**
 * stops the ringtone
 */
public function stopRing():void
{
	if(sndChannel)
	{
		sndChannel.stop();
	}
}
private function blinkTaskBar():void {
	//Once an invitation come to user there is a notificaition at his end and is done
	//by higlighting the taskbar icon with a different color. nativeWindow.notifyUser 
	//is a deafult class for notifying user when some event happens in the application
	// when the same is not in focus.
	applicationType::desktop {
		if (NativeApplication.supportsDockIcon) {
			var dock:DockIcon=NativeApplication.nativeApplication.icon as DockIcon;
			dock.bounce(NotificationType.CRITICAL);
		} else {
			stage.nativeWindow.notifyUser(NotificationType.CRITICAL);
		}
	}
}