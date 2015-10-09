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
 * File			: DelayedTimer.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 * DelayedTimer class is custom class that extended from Timer Class
 *
 */
package edu.amrita.aview.common.components.fileManager
{
	
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	/**
	 * DelayedTimer class is custom class that extended from Timer Class.
	 * @author haridasanpc
	 * 
	 */
	public class DelayedTimer extends Timer
	{
		
		/**
		 *@public 
		 * Constructor
		 */
		public function DelayedTimer()
		{
			/**Init the extended timer class.*/
			super(1000, 1);
		
		}
		
		/**
		 * The object that called the timer.
		 **/
		private var _caller:Object;
		
		/**
		 * @public 
		 * Get the value of _caller
		 * @return Object
		 * 
		 */
		public function get caller():Object
		{
			return _caller;
		}
		
		/**
		 * @public 
		 * 
		 * set the value of _caller
		 * @param value of type Object
		 * 
		 */
		public function set caller(value:Object):void
		{
			_caller=value;
		}
		
		/**
		 * The item passed. Used to store any other required info the
		 * called function may require.
		 **/
		private var _item:Object;
		
		/**
		 * @public 
		 *Get the value of _item
		 * @return Object
		 * 
		 */
		public function get item():Object
		{
			return _item;
		}
		
		/**
		 * @public 
		 * Set the value of _item 
		 * @param value of type Object
		 * 
		 */
		public function set item(value:Object):void
		{
			_item=value;
		}
		
		
		/**
		 * The function passed used in the cleanup of the listener.
		 **/
		private var _func:Function;
		
		/**
		 * @public
		 * Get the value of _func
		 * @return Function
		 * 
		 */
		public function get func():Function
		{
			return _func;
		}
		
		/**
		 * @public 
		 * Set the value of _func
		 * @param value of type Function
		 * 
		 */
		public function set func(value:Function):void
		{
			_func=value;
		}
		
		
		/**
		 * @public
		 * Initialize the timer for the delayed call.
		 * @param func of type Function
		 * @param event of type Event default value=null
		 * @param caller of type Object default value = null
		 * @param delay of type Number default value =1000
		 * @param repeat of type int default value 1
		 * @param item of type Object default value=null		 * 
		 * 
		 */
		public function startDelayedTimer(func:Function, event:Event=null, caller:Object=null, delay:Number=1000, repeat:int=1, item:Object=null):void
		{
			
			if (func == null)
			{
				return;
			}
			
			this.item=item;
			
			
			this.func=func;
			
			if (caller != null)
			{
				this.caller=caller;
				
				if (event != null)
				{
					if (this.caller != event.target)
					{
						this.caller=event.target;
					}
				}
				
			}
			
			if (running == true)
			{
				cancelDelayedTimer();
			}
			
			this.delay=delay;
			this.repeatCount=repeat;
			
			//Use a weak refference so this gets cleaned up.
			addEventListener(TimerEvent.TIMER, func, false, 0, true);
			
			start();
		
		}
		
		/**
		 * @public
		 * Clean up the call, the passed object, and stop the timer.
		 *
		 *
		 */
		public function cancelDelayedTimer():void
		{
			
			if (hasEventListener(TimerEvent.TIMER))
			{
				removeEventListener(TimerEvent.TIMER, func);
			}
			
			if (running == true)
			{
				
				_func=null;
				_caller=null;
				_item == null;
				stop();
				reset();
				
			}
		
		}
	}



}

