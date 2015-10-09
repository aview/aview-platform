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
 * File			: EventMapEntry.as
 * Module		: Common
 * Developer(s)	: Soumya MD
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 *
 */
//VGCR:-Functional Description
//VGCR:-Description for all functions

package edu.amrita.aview.core.shared.eventmap
{
	

	internal class EventMapEntry
	{
		public function EventMapEntry()
		{
		}
		//VGCR:-Variable Description
		private var _eventType:String;
		private var _eventChannel:String=null;
		private var _listeners:Array=null;	
		private var _initiators:Array=null;

		/**
		 * @public 
		 * @return String
		 * 
		 */
		public function get eventType():String
		{
			return _eventType;
		}

		/**
		 * @public 
		 * @param value of type String
		 * 
		 */
		public function set eventType(value:String):void
		{
			_eventType = value;
		}		

		/**
		 * @public 
		 * @return String
		 * 
		 */
		public function get eventChannel():String
		{
			return _eventChannel;
		}

		/**
		 * @public 
		 * @param value of type String
		 * 
		 */
		public function set eventChannel(value:String):void
		{
			_eventChannel = value;
		}

		/**
		 * @public 
		 * @return Array
		 * 
		 */
		public function get listeners():Array
		{
			return _listeners;
		}

		/**
		 * @public 
		 * @param value of type Array
		 * 
		 */
		public function set listeners(value:Array):void
		{
			_listeners = value;
		}

		/**
		 * @public 
		 * @return Array
		 * 
		 */
		public function get initiators():Array
		{
			return _initiators;
		}

		/**
		 * @public 
		 * @param value of type Array
		 * 
		 */
		public function set initiators(value:Array):void
		{
			_initiators = value;
		}
		
		/**
		 * @public
		 * adds listeners to map and register them to initiators
		 * @param listener of type Function
		 * 
		 */
		public function addListener(listener:Function):void
		{
			if(_listeners==null)
			{
				_listeners=new Array();
			}
			listeners.push(listener);
			if(_initiators==null)
			{
				return;
			}
			
			for(var index:int=0;index<_initiators.length;index++)
			{
				_initiators[index].addEventListener(_eventType,listener);
			}
		
		}
		/**
		 * @public
		 * remove listeners from map and initiators
		 * @param listener of type Function
		 * 
		 */
		public function removeListener(listener:Function):void
		{
			if(_initiators==null || _listeners==null)
			{
				return;
			}
			for(var i:int=0;i<_initiators.length;i++)
			{
				_initiators[i].removeEventListener(_eventType,listener);
			}
			for(var j:int=0;j<_listeners.length;j++)
			{
				if(_listeners[j]==listener)
				{
					_listeners.splice(j,1);
					break;
				}
			}
			
		}
		/**
		 * @public
		 * adds initiator to map and register exitsting listeners to it
		 * @param initiator of type Object
		 * 
		 */
		public function addInitiator(initiator:Object):void
		{
			if(_initiators==null)
			{
				_initiators=new Array();
			}
			_initiators.push(initiator);
			if(_listeners==null)
			{
				return;
			}
			for(var index:int=0;index<_listeners.length;index++)
			{
				initiator.addEventListener(_eventType,_listeners[index]);
			}
		}
		/**
		 * @public
		 * removes the listeners from initiator and intitiator from map
		 * @param initiator of type Object
		 * 
		 */
		public function removeInitiator(initiator:Object):void
		{
			if(_initiators==null || _listeners==null)
			{
				return;
			}
			for(var i:int=0;i<_listeners.length;i++)
			{
				initiator.removeEventListener(_eventType,_listeners[i]);
			}
			for(var j:int=0;j<_initiators.length;j++)
			{
				if(initiator == _initiators[j])
				{				
					_initiators.splice(j,1);
					break;
				}
			}
		}
	}
}