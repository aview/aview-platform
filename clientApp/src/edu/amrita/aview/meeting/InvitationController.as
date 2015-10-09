package edu.amrita.aview.meeting
{
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.meeting.events.InvitationEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class InvitationController extends EventDispatcher
	{
		private var invitationView:InvitationView=null;
		[Bindable]
		private var invitationModel:InvitationModel=null;
		private var userVO:UserVO=null;
		private var appEventMap:EventMap=null;
		private var timer:Timer=null;
		//private var eventMap:EventMap=null;

		public function InvitationController(userVO:UserVO,appEvtMap:EventMap)
		{
			this.userVO=userVO;
			this.appEventMap=appEvtMap;
		}
		
		public function init():void
		{
			this.appEventMap.registerInitiator(this,InvitationEvent.CLOSE_INVITATION);
		}
		public function getInvitationView():InvitationView
		{
			if(invitationView ==null)
			{
				invitationView=new InvitationView();		
				
			}
			return invitationView;
		}
		public function getInvitationModel():InvitationModel
		{
			if(invitationModel==null)
			{
				invitationModel=new InvitationModel();
			}
			return invitationModel;
		}
		public function createInvitationPopup():void
		{
			getInvitationView();
			invitationView.invitationModel=this.invitationModel;
			invitationView.addEventListener(CloseEvent.CLOSE,onCloseInvitation);
			PopUpManager.addPopUp(this.invitationView,FlexGlobals.topLevelApplication as UIComponent,true);
			PopUpManager.centerPopUp(invitationView);		
			invitationView.btnAccept.addEventListener(MouseEvent.CLICK,acceptInvitation);
			invitationView.btnReject.addEventListener(MouseEvent.CLICK,rejectInvitation);
			timer=new Timer(1000, 30);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCloseInvitation);
			timer.start();
		}
		private function onCloseInvitation(event:Event):void
		{
			PopUpManager.removePopUp(invitationView);
			this.dispatchEvent(new InvitationEvent(InvitationEvent.CLOSE_INVITATION));
			resetTimer();
			invitationView.stopRing();
		}
		private function acceptInvitation(event:Event):void
		{
			this.dispatchEvent(new InvitationEvent(InvitationEvent.ACCEPT,invitationModel));
			resetTimer();
			invitationView.stopRing();
			PopUpManager.removePopUp(invitationView);
		}
		private function rejectInvitation(event:Event):void
		{
			this.dispatchEvent(new InvitationEvent(InvitationEvent.REJECT,invitationModel));
			resetTimer();
			invitationView.stopRing();
			PopUpManager.removePopUp(invitationView);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.getTodaysLectures();
		}
		private function resetTimer():void
		{
			if(timer!=null)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onCloseInvitation);
				timer=null;
			}
		}
	}
}