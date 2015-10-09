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
 * File			: MxImageButton.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 *
 * For creating the mxml buttons with the different faces of images.
 * This file can be removed when all the existing Mx buttons are converted to Spark buttons
 *
 */

package edu.amrita.aview.common.components
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Button;
	
	/**
	 * @public
	 * extends Button
	 */
	public class MxImageButton extends Button
	{
		/**
		 * @public
		 *
		 *
		 * @retun void
		 */
		public function MxImageButton()
		{
			super();
		}
		
		/**
		 * @protected
		 * @param event type of KeyboardEvent
		 * @return void
		 * 
		 * This function is a over ridden function which takes care of keyboard event handling
		 */
		
		override protected function keyDownHandler(event : KeyboardEvent):void
		{
			/**if the user has pressed the enter key or the space key on the focus 
			 * of the button trigger a mouse click event
			 */
			if((event.keyCode == Keyboard.ENTER) || (event.keyCode == Keyboard.SPACE)) 
			{
				event.target.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
	}
}