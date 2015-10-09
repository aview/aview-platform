package edu.amrita.aview.contacts.transferContacts
{
	import edu.amrita.aview.contacts.events.ContactsTransferEvent;
	import edu.amrita.aview.contacts.events.SearchEvent;
	import edu.amrita.aview.contacts.helper.GroupTransferHelper;
	import edu.amrita.aview.contacts.transferContacts.SendContactsModel;
	import edu.amrita.aview.contacts.vo.GroupTransferVO;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.helper.UserHelper;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class SendContactsController
	{
		private var sendContactsView:SendContactsView=null;
		private var sendContactsModel:SendContactsModel=null;
		private var moduleRO:ModuleRO=null;
		private var receivers:Array=null;
		public function SendContactsController()
		{
		}
		public function init(selectedGroup:GroupVO,moduleRO:ModuleRO):void
		{
			this.moduleRO=moduleRO;
			getSendContactsModel().selectedGroup=selectedGroup;
		}
		public function getSendContactsView():SendContactsView
		{
			if(sendContactsView==null)
			{
				 sendContactsView=new SendContactsView();
				 sendContactsView.addEventListener(SearchEvent.SEARCH_EVENT,onSearchUsers);
				 sendContactsView.addEventListener(ContactsTransferEvent.SEND_GROUP,sendGroup);
			}
			 sendContactsModel=getSendContactsModel();
			 sendContactsView.init(sendContactsModel,moduleRO.userVO);
			 return sendContactsView;
		}

		public function addSendContactsView(parent:DisplayObject):void
		{
			PopUpManager.addPopUp(sendContactsView,parent,true);
			PopUpManager.centerPopUp(sendContactsView);
		}
		private function getSendContactsModel():SendContactsModel
		{
			if(sendContactsModel==null)
			sendContactsModel=new SendContactsModel();
			return sendContactsModel;
		}
		private function onSearchUsers(event:SearchEvent):void
		{
			searchUsers();
		}
		private function searchUsers():void
		{
			var userHelper:UserHelper=new UserHelper();
			userHelper.searchUsersByName(sendContactsModel.searchKey,onSearchResult);
		}
		private function onSearchResult(event:ResultEvent):void
		{
			sendContactsModel.users=event.result as ArrayCollection;
		}
		private function sendGroup(event:ContactsTransferEvent):void
		{
			var groupUsers:ArrayCollection=sendContactsModel.selectedGroup.groupUsers;
			var groupTransfers:ArrayCollection=new ArrayCollection();
			receivers=new Array()
			for(var index:int=0;index<sendContactsModel.selectedUsers.length;index++)
			{
				var groupTransfer:GroupTransferVO=new GroupTransferVO();
				groupTransfer.group=sendContactsModel.selectedGroup;				
				groupTransfer.receiver=sendContactsModel.selectedUsers.getItemAt(index) as UserVO ;
				groupTransfer.sender=this.moduleRO.userVO;
				groupTransfers.addItem(groupTransfer);
				
				receivers.push(groupTransfer.receiver.userName);
				
			}
			var groupTransferHelper:GroupTransferHelper=new GroupTransferHelper();
			groupTransferHelper.createPendingGroupTransfers(groupTransfers,moduleRO.userVO.userId,
				createPendingGroupTransfersResultHandler,createPendingGroupTransfersFaultHandler);
			
			
		}
		
		private function createPendingGroupTransfersResultHandler(event:ResultEvent):void
		{
			Alert.show("Group sent to the selected members","Information");
			PopUpManager.removePopUp(this.sendContactsView);
			moduleRO.mediaServerConnection.netConnection.call("refreshSharedGroups",null,receivers);
		}
		private function createPendingGroupTransfersFaultHandler(event:FaultEvent):void
		{
			Alert.show(" You are Sharing the selected group repeatedly to one or more members.Please remove them and try again!","Error");
		}
			
	}
}