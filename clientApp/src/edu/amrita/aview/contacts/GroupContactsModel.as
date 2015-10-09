package edu.amrita.aview.contacts
{
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import mx.collections.ArrayCollection;
	[Bindable]	
	public class GroupContactsModel
	{
		public var groupUsers:ArrayCollection=null;
		public var selectedUsers:ArrayCollection=null;
		public var currentGroupName:String=null;
		public var currentGroup:GroupVO=null;
		public var contactsTitle:String=null;
		public function GroupContactsModel()
		{
		}
		
		

	}
}