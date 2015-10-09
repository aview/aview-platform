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
 * File			: DateFieldWithKeyDownHandler.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 *
 * For creating the Datefield with key down listener
 *
 */
package edu.amrita.aview.core.shared.components
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.DateField;
	
	/**
	 * @public
	 * extends DateField
	 */
	public class DateFieldWithKeyDownHandler extends DateField
	{
		/**
		 * @public
		 *
		 *
		 * @retun void
		 * Default Constructor
		 */
		public function DateFieldWithKeyDownHandler()
		{
			super();
		}
		
		/**
		 * @protected
		 *
		 * @param event type of KeyboardEvent
		 * @return void
		 * 
		 * This function is a over ridden function which takes care of keyboard event handling
		 */
		
		override protected function keyDownHandler(event : KeyboardEvent):void
		{
			/**
			 * if the user has pressed the enter key or the space key on the focus
			 * of the button trigger a mouse click event
			 */
			if((event.keyCode == Keyboard.ENTER) || (event.keyCode == Keyboard.SPACE)) 
			{
				this.open();
			}
		}
	}
}