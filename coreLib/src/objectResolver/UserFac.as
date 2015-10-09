package objectResolver
{
	import mx.core.FlexGlobals;
	public class UserFac
	{
		
		public function UserFac()	{
		}
		
		//		.\chat\ChatManager.as
		var chatManager = FlexGlobals.topLevelApplication.applicationModuleHandler.getChatManagerObj();
		//		.\common\components\userList\UserSOValue.as
		var userSOValue = FlexGlobals.topLevelApplication.applicationModuleHandler.getUserSOValueObj();
/*
		new ArrayList();
		new ChatManager(classRoomModuleVO as ModuleRO);
		new ArrayCollection();
		new ArrayList();
		new DateTimeFormatter();
		new Event(Event.CLOSE);
		new Object;
		new Timer(100, 1);
		new UserSOValue(usersCollaborationObject.getData()[uName]);
		new UserTime();
     

*/		
	}
}