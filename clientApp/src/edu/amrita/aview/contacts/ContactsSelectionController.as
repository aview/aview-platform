package edu.amrita.aview.contacts
{
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class ContactsSelectionController extends EventDispatcher
	{
		private var _contactsSelectionView:ContactsSelectionView=new ContactsSelectionView();
		[Bindable]
		private var contactsSelectionModel:ContactsSelectionModel=null;
		private var allGroupsAndContacts:ArrayCollection=null;
		private var meetingMembers:ArrayCollection=null;
		
		public function ContactsSelectionController(allContacts:ArrayCollection,moduleRO:ModuleRO,
													existingUsers:ArrayCollection,allowContactsRemoval:Boolean,isEmbedded:Boolean=true)
		{
			contactsSelectionModel=new ContactsSelectionModel(allContacts,moduleRO,existingUsers,allowContactsRemoval,isEmbedded);
			contactsSelectionView.contactsSelectionModel=this.contactsSelectionModel;	
			if(!isEmbedded)
			{
				contactsSelectionView.width = 348;
				contactsSelectionView.height = 442;
			}
		}		
		public function init():void
		{
			contactsSelectionModel.init();
		}	
		public function getSelectedContactIds():ArrayCollection
		{
			return contactsSelectionModel.getSelectedContactIds();
		}
		
		public function getNewlySelectedUsers():ArrayCollection
		{
			return contactsSelectionModel.getNewlySelectedUsers();
		}

		public function get contactsSelectionView():ContactsSelectionView
		{
			return _contactsSelectionView;
		}
		public function isGroupExists():Boolean
		{
			if(contactsSelectionModel.allGroupsAndContacts ==null || contactsSelectionModel.allGroupsAndContacts.length==0)
				return false;
			else if(contactsSelectionModel.allGroupsAndContacts.length==1 && 
				contactsSelectionModel.allGroupsAndContacts[0].contactGroupName=="*PeopleNotInContacts*")
				return false;
			else
				return true;
		}

	}
}