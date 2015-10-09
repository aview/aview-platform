package edu.amrita.aview.contacts.search
{
	//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.UserStatusProviderEvent;
	import edu.amrita.aview.contacts.helper.GroupUserHelper;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	public class SearchResultController extends EventDispatcher
	{
		private var searchResultView:SearchResultView=null;
		[Bindable]
		private var searchResultModel:SearchResultModel=null;
		private var userVO:UserVO=null;
		private var moduleRO:ModuleRO=null;
		public function SearchResultController(userVO:UserVO,mro:ModuleRO)
		{
			this.userVO=userVO;
			this.moduleRO=mro;
		}
		
		public function getSearchResultView():SearchResultView
		{
			if(searchResultView==null)
			{
				searchResultView=new SearchResultView();
				searchResultView.addEventListener(ContactsEvent.ADD_USER,onAddUser);
				this.moduleRO.moduleEventMap.registerInitiator(this,ContactsEvent.REFRESH);
				this.moduleRO.moduleEventMap.registerInitiator(this,UserStatusProviderEvent.USER_STATUS_CHANGE);
				this.moduleRO.applicationEventMap.registerMapListener(ContactsEvent.USER_STATUS_CHANGED,changeUserStatus);
			}
			searchResultModel=getSearchResultModel();
			searchResultView.searchResultModel=searchResultModel;
			return this.searchResultView;
		}
		public function getSearchResultModel():SearchResultModel
		{
			if(searchResultModel==null)
			{
				searchResultModel=new SearchResultModel();
			}
			return searchResultModel;
		}
		private function getSelectedUserIds():ArrayCollection
		{
			var userIds:ArrayCollection=new ArrayCollection();
			for(var index:int=0;index<searchResultModel.selectedUsers.length;index++)
			{
				userIds.addItem(searchResultModel.selectedUsers[index].userId);
			}
			return userIds;
		}
		public function addUsersToGroup():void
		{
			var groupuserHelper:GroupUserHelper=new GroupUserHelper();
			groupuserHelper.addUsersToGroup(searchResultModel.selectedGroup.contactGroupId,
											getSelectedUserIds(),userVO.userId,addUsersToGroupResultHandler);
		}
		public function validateAndAddUsers():void
		{
			var existingUsers:Array = new Array();
			var userIds:ArrayCollection = new ArrayCollection;
			var groupUsers:ArrayCollection=searchResultModel.selectedGroup.groupUsers;
			var selectedUsers:ArrayCollection=searchResultModel.selectedUsers;
			for(var index:int=0;index<selectedUsers.length;index++)
			{
				var currentSelectedUserId:Number=selectedUsers[index].userId; 
				var userExist:Boolean=false;
				if(groupUsers!=null)
				{
					for(var g:int=0;g<groupUsers.length;g++)
					{
						if(groupUsers[g].user.userId ==  selectedUsers[index].userId)
						{
							existingUsers.push(selectedUsers[index].userDisplayName);
							selectedUsers.removeItemAt(index);
							userExist=true;
							break;
						}
					}
				}
				if(!userExist)
				{
					userIds.addItem(currentSelectedUserId);
				}
			}
			if(userIds.length>0)
			{
				
				var alertMessage:String='';
				for (var existingUserCount:int=0; existingUserCount < existingUsers.length; existingUserCount++)
				{
					if (existingUserCount == 0)
					{
						alertMessage=existingUsers[existingUserCount];
					}
					else
					{
						alertMessage+=", " + existingUsers[existingUserCount];
					}
				}
				if (existingUsers.length > 1)
				{
					Alert.show(alertMessage + " already present in the group", "Alert");
					
				}
				else if (existingUsers.length == 1)
				{
					Alert.show(alertMessage + " already present in the group", "Alert");						
				}
				addUsersToGroup();
				existingUsers=null;
			}
			else
			{
				Alert.show("Selected user(s) is already present in the group","Information");
				searchResultView.enableAddButton();
			}
		}
		/** 
		 * check that the selected user is present in the group
		 * if yes, an alert is shown
		 * else add user to that group
		 * TODO:This comparison can be reduced if the members are added to the GroupVO
		 */
		
		public function addUsersToGroupResultHandler(event:ResultEvent):void
		{
			this.dispatchEvent(new ContactsEvent(ContactsEvent.REFRESH,null));
			searchResultView.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		private function onAddUser(event:ContactsEvent):void
		{
			validateAndAddUsers();
		}
		public function getOnlineUsers():void
		{
			this.dispatchEvent(new UserStatusProviderEvent(UserStatusProviderEvent.USER_STATUS_CHANGE,setUserStatus));
		}
		public function setUserStatus(onlineUsers:Object):void
		{
			if(searchResultModel.users==null)
				return;
			for(var index:int=0;index<searchResultModel.users.length;index++)
			{
				var user:UserVO=searchResultModel.users[index];
				if(onlineUsers[user.userName]!=null)
				{
					user.userStatus=onlineUsers[user.userName];
				}
			}
		}
		private function changeUserStatus(event:ContactsEvent):void
		{
			for(var index:int=0;index<searchResultModel.users.length;index++)
			{
				var user:UserVO=searchResultModel.users[index];
				var userObj:Object=event.data;
				if(userObj.name==user.userName)
				{
					user.userStatus=userObj.userStatus;
					break;
				}
			}
			searchResultModel.users.refresh();
		}
		
		
	}
	
}