package edu.amrita.aview.contacts.transferContacts
{
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class SendContactsModel
	{
		public var users:ArrayCollection=null;
		public var selectedUsers:ArrayCollection=null;
		public var searchKey:String=null;
		public var selectedGroup:GroupVO=null;
		public function SendContactsModel()
		{
		}
	
	}
}