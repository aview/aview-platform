package edu.amrita.aview.meeting
{
	import mx.collections.ArrayCollection;

	public class MeetingMembersModel
	{
		private var _meetingMembers:ArrayCollection=null;
		private var _selectedMembers:ArrayCollection=null;
		public function MeetingMembersModel()
		{
		}
		[Bindable]
		public function get meetingMembers():ArrayCollection
		{
			return _meetingMembers;
		}

		public function set meetingMembers(value:ArrayCollection):void
		{
			_meetingMembers = value;
		}
		[Bindable]
		public function get selectedMembers():ArrayCollection
		{
			return _selectedMembers;
		}

		public function set selectedMembers(value:ArrayCollection):void
		{
			_selectedMembers = value;
		}


	}
}