package edu.amrita.aview.contacts.search
{
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class SearchResultModel
	{
		public var users:ArrayCollection=null;
		public var selectedUsers:ArrayCollection=null;
		public var selectedGroup:GroupVO=null;
		public function SearchResultModel()
		{
		}
		public function setGroupUsers(users:ArrayCollection,selectedGroup:GroupVO):void
		{
			this.users=users;
			this.selectedGroup=selectedGroup;
		}
	}
}