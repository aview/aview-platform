////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: CustomEvent.as
 * Module		: common
 * Developer(s)	: VijayKumar R
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 *
 * This is a custom event component
 */
package edu.amrita.aview.common.components.autoComplete
{
	import flash.events.Event;
	
	/**
	 * @public
	 * Custom event class.
	 * stores custom data in the <code>data</code> variable.
	 */
	public class CustomEvent extends Event
	{
		/**
		 * VPCR: Add variable description */
		
		public var data:Object;
		
		/**
		 * @public
		 * constructor
		 * @param type Type String
		 * @param mydata Type Object
		 * @param bubbles Type Boolean Default value False
		 * @param cancelable Type Boolean Default value False
		 */
		
		public function CustomEvent(type:String, mydata:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			
			super(type, bubbles, cancelable);
			
			data=mydata;
		}
	
	}
}
