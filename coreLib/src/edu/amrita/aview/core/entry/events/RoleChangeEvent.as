package edu.amrita.aview.core.entry.events
{
	import flash.events.Event;
	
	/**
	 * Event class used to notify all the module when the currently logged in user's role is changed.
	 * @author Ramesh
	 * 
	 */
	public class RoleChangeEvent extends Event
	{
		/**
		 * Event to notify all the modules when the currently logged in user's role is 
		 * changed between Constants.PRESENTER_ROLE or Constants.VIEWER_ROLE
		 */
		public static const TYPE_ROLE_CHANGE:String="roleChange";
		
		private var _newRole:String;

		/**
		 * Constructor
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param newRole: The new role of the user, either Preseenter or Viewer
		 * 
		 */
		public function RoleChangeEvent(type:String,newRole:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._newRole = newRole;
		}

		/**
		 * 
		 * @return newRole: The new role of the user, either Constants.PRESENTER_ROLE or Constants.VIEWER_ROLE
		 * 
		 */
		public function get newRole():String
		{
			return _newRole;
		}

	}
}