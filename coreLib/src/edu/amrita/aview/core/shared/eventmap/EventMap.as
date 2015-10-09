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
 * File			: EventMap.as
 * Module		: Common
 * Developer(s)	: Soumya MD
 * Reviewer(s)	: Veena Gopal K.V
 * 
 * EventMap allows any Object to throw events and any Object to subscribe these events based on the event type & channel
 * The the throwing object and receiving object does not need to be aware of each other.
 * 
 * There can be more than one event map. Especially when the module wants to communicate it's internal events, 
 * it can create it's own module level instance of this event map and let it's internal classes communicate through this. 
 * 
 */
package edu.amrita.aview.core.shared.eventmap
{
	
	import flash.events.IEventDispatcher;
	//For Web:ReturnKeyLabel is not available in web.
	applicationType::desktop{
		import flash.text.ReturnKeyLabel
	}
 //VGCR:-Class Description
	public class EventMap
	{
		//VGCR:-Variable Description
		private var _eventRegistry:Object=new Object;
		private const defaultChannel:String="_default_channel";
		
		
		/**
		 * 
		 * @public
		 * constructor
		 */
		public function EventMap()
		{
		}
		
		/**
		 * @public
		 * Registers the initiator for a given event & channel
		 *  
		 * @param initiator: The initiator class which is going to throw the event. There can be multiple initiators for a given event.
		 * The initiator must be of type IEventDispatcher
		 * 
		 * @param eventType:String, The type of the event, which is being thrown
		 * 
		 * @param channel:String, Optional parameter. The channel is a general purpose string, allows for the further grouping of intiators and listeners. 
		 * Initiators & Listeners can only communicate on the unique combination of event and channel
		 * 
		 */
		public function registerInitiator(initiator:IEventDispatcher,eventType:String,channel:String=null):void
		{		
			var eventListener:EventMapEntry=null;
			//if(channel==null && channel=="")
			if(!channel)
			{
				channel=defaultChannel;
			}
			if(_eventRegistry[channel]==null)
			{
				_eventRegistry[channel]=new Object();
			}
			if(_eventRegistry[channel][eventType]==null)
			{
				eventListener=new EventMapEntry();
				eventListener.eventChannel=channel;
				eventListener.eventType=eventType;
				_eventRegistry[channel][eventType]=eventListener;				
					
			}
			_eventRegistry[channel][eventType].addInitiator(initiator);			
		}		

		/**
		 * @public
		 * Registers the listener for given event & channel
		 * 
		 * @param eventType:String, The type of the event, which is being thrown
		 * 
		 * @param eventHandler:Function, the function which is going to handle the event. 
		 * The function might belong to any object
		 * 
		 * @param channel:String, Optional parameter. The channel is a general purpose string, allows for the further grouping of intiators and listeners. 
		 * Initiators & Listeners can only communicate on the unique combination of event and channel
		 * 
		 */
		public function registerMapListener(eventType:String,eventHandler:Function,channel:String=null):void
		{			
				var eventListener:EventMapEntry=null;						
			
				//if(channel!=null && channel!="")
				if(!channel)
				{
					channel=defaultChannel;
				}
				if(_eventRegistry[channel]==null)
				{
					_eventRegistry[channel]=new Object();
				}
				if(_eventRegistry[channel][eventType]==null)
				{
					eventListener=new EventMapEntry();
					eventListener.eventChannel=channel;
					eventListener.eventType=eventType;
					_eventRegistry[channel][eventType]=eventListener;
				}
				else
				{
					eventListener=_eventRegistry[channel][eventType];
				}
				eventListener.addListener(eventHandler);			
		}
	
		/**
		 * @public
		 * Unregisters the initiator from a given event & channel
		 *  
		 * @param initiator: The initiator class which is going to throw the event. There can be multiple initiators for a given event.
		 * 
		 * @param eventType:String, The type of the event, which is being thrown
		 * 
		 * @param channel:String, Optional parameter. The channel is a general purpose string, allows for the further grouping of intiators and listeners. 
		 * Initiators & Listeners can only communicate on the unique combination of event and channel
		 * 
		 */
		public function unregisterInitiator(initiator:Object,eventType:String,channel:String=null):void
		{
			if(channel==null || channel=="")
			{	
				channel=defaultChannel;
			}
			if(_eventRegistry[channel]==null)
			{
				return;
			}
			if(_eventRegistry[channel][eventType]!=null)
			{
				_eventRegistry[channel][eventType].removeInitiator(initiator);
			}
			
		}

		/**
		 * @public
		 * Registers the listener from a given event & channel
		 * 
		 * @param eventHandler:Function, the function which is going to handle the event. 
		 * The function might belong to any object
		 * 
		 * @param eventType:String, The type of the event, which is being thrown
		 * 
		 * @param channel:String, Optional parameter. The channel is a general purpose string, allows for the further grouping of intiators and listeners. 
		 * Initiators & Listeners can only communicate on the unique combination of event and channel
		 * 
		 */
		public function unregisterMapListener(eventType:String, eventHandler:Function, channel:String=null):void
		{
			if(channel==null || channel=="")
			{	
				channel=defaultChannel;
			}
			if(_eventRegistry[channel]==null)
			{
				return;
			}
			if(_eventRegistry[channel][eventType]!=null)
			{
				_eventRegistry[channel][eventType].removeListener(eventHandler);
			}
		}		
			
		/**
		 * @public
		 * Removes all the initiators and listeners associated with a given event & channel
		 * 
		 * @param eventType:String, The type of the event, which is being thrown
		 * 
		 * @param channel:String, Optional parameter. The channel is a general purpose string, allows for the further grouping of intiators and listeners. 
		 * Initiators & Listeners can only communicate on the unique combination of event and channel
		 * 
		 */
		public function removeMap(eventType:String,channel:String=null):void
		{
			if(channel==null ||channel=="")
			{
				channel=defaultChannel;
			}
			if(_eventRegistry[channel]!=null && _eventRegistry[channel][eventType]!=null)
			{				
				delete _eventRegistry[channel][eventType];
			}
			
		}
	}
}