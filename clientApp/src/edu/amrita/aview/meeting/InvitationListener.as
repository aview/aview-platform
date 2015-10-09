package edu.amrita.aview.meeting
{
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.vo.AViewResponseVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.entry.SessionEntry;
	import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
	import edu.amrita.aview.core.gclm.helper.LectureHelper;
	import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
	import edu.amrita.aview.core.gclm.vo.LectureListVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.meeting.events.InvitationEvent;
	
	import flash.events.Event;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	public class InvitationListener
	{
		
		private var invitationController:InvitationController=null;
		private var moduleRO:ModuleRO=null;
		public function InvitationListener(moduleRO:ModuleRO)
		{
			
			this.moduleRO=moduleRO;
		}
		public function init():void
		{
			moduleRO.mediaServerConnection.connectingClient.showInvitation=function(invitation:Object):void
			{
				if(ClassroomContext.aviewClass==null || ClassroomContext.aviewClass.classId==0)
				{
					createInvitationComponent(invitation);
				}
			}
		}
		public function createInvitationComponent(invitation:Object):void
		{
			if(invitationController==null)
			{
				invitationController=new InvitationController(moduleRO.userVO,moduleRO.applicationEventMap);
				invitationController.init();
				var invitaionModel:InvitationModel=invitationController.getInvitationModel();
				invitaionModel.lectureId=invitation.lectureId;
				invitaionModel.meetingName=invitation.meetingName;
				invitaionModel.userName=invitation.userName;
				invitaionModel.userId=invitation.userId;
				invitaionModel.classRegistrationId=invitation.classRegistrationId;
			    invitaionModel.moderatorName=invitation.moderatorName;
				invitationController.createInvitationPopup();	
				invitationController.addEventListener(InvitationEvent.CLOSE_INVITATION,removeInvitationComponent);
				invitationController.addEventListener(InvitationEvent.ACCEPT,acceptInvitation);
				invitationController.addEventListener(InvitationEvent.REJECT,removeInvitationComponent);
			}
		}
		public function removeInvitationComponent(event:Event):void
		{
			invitationController=null;
		}
		public function acceptInvitation(event:InvitationEvent):void
		{
			var lectureId:Number=event.data.lectureId;
			var classRegId:Number=event.data.classRegistrationId;
			var classregHelper:ClassRegistrationHelper = new ClassRegistrationHelper();
			classregHelper.getClassRegistrationById(classRegId,getClassRegisterByIdResultHandler);
			new SessionEntry().getClassRoomLecture(lectureId);
			removeInvitationComponent(null);
		}
		
		public function getClassRegisterByIdResultHandler(classRegVO:ClassRegisterVO):void
		{
			var classRegistration:ClassRegisterVO=classRegVO;
			classRegistration.statusId = 1;
			var classregHelper:ClassRegistrationHelper  = new ClassRegistrationHelper();
			classregHelper.updateClassRegistration(classRegistration,moduleRO.userVO.userId,updateClassRegistrationResultHandler);
		}
		public function updateClassRegistrationResultHandler(event:ResultEvent):void
		{				
			trace("updated classregistration status");
			
		}
		
	}
}