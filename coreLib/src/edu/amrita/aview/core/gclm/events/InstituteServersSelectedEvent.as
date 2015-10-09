////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: InstituteServersSelectedEvent.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This event is generated whenever the user is done with the selection of class room servers for an Institute
 *
 */
package edu.amrita.aview.core.gclm.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	/**
	 * The event class
	 */
	public class InstituteServersSelectedEvent extends Event
	{
		/**
		 * The event type 
		 */		
		public static var INSTITUTE_SERVERS_SELECTED:String="instituteserversselected";
		/**
		 * To store the branding selection info that needs to be passed to the event handler 
		 */		
		private var _data:ArrayCollection;
		/**
		 * To store the data servers details for the aview class 
		 */		
		private var _dataServers:ArrayCollection;
		/**
		 * To store the content servers details for the aview class 
		 */		
		private var _contentServers:ArrayCollection;
		/**
		 * To store the desktop sharing servers details for the aview class 
		 */		
		private var _desktopSharingServers:ArrayCollection;
		/**
		 * To store the presenter video server details for the aview class 
		 */		
		private var _presenterVideoServers:ArrayCollection;
		/**
		 * To store the viewer video servers details for the aview class 
		 */		
		private var _viewerVideoServers:ArrayCollection;
		
		/**
		 *
		 * @public
		 * Constructor for this classs
		 * @param type : The event type
		 * @param bubbles : Boolean if the event has to be bubbled
		 * @param cancelable : Boolean if the event can be cancelled
		 * @param data : The branding info
		 * @return NA
		 *
		 ***/
		public function InstituteServersSelectedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:ArrayCollection=null)
		{
			super(type, bubbles, cancelable);
			_data=data;
			_dataServers=ObjectUtil.copy(data[0]) as ArrayCollection;
			_contentServers=ObjectUtil.copy(data[1]) as ArrayCollection;
			_desktopSharingServers=ObjectUtil.copy(data[2]) as ArrayCollection;
			_presenterVideoServers=ObjectUtil.copy(data[3]) as ArrayCollection;
			_viewerVideoServers=ObjectUtil.copy(data[4]) as ArrayCollection;
		}
		
		/**
		 *
		 * @public
		 * Overridden function from the base class
		 *
		 * @return Event
		 *
		 ***/
		override public function clone():Event
		{
			return new InstituteServersSelectedEvent(type, bubbles, cancelable, data);
		}
		
		/**
		 *
		 * @public
		 * Function to get the stored data by the event handler
		 *
		 * @return the data arraycollection
		 *
		 ***/
		public function get data():ArrayCollection
		{
			return _data;
		}
		
		/**
		 * @return the data servers
		 */
		public function get dataServers():ArrayCollection
		{
			return _dataServers;
		}
		
		/**
		 * @return the content server
		 */
		public function get contentServers():ArrayCollection
		{
			return _contentServers;
		}
		
		/**
		 * @return the desktop sharing servers
		 */
		public function get desktopSharingServers():ArrayCollection
		{
			return _desktopSharingServers;
		}
		
		/**
		 * @return the presenter video servers
		 */
		public function get presenterVideoServers():ArrayCollection
		{
			return _presenterVideoServers;
		}
		
		/**
		 * @return the viewer video servers
		 */
		public function get viewerVideoServers():ArrayCollection
		{
			return _viewerVideoServers;
		}
	}
}
