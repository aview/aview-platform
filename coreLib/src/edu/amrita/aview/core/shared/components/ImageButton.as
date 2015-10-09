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
 * File			: ImageButton.as
 * Module		: Common
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 *
 * For creating the buttons with
 * the different faces of images
 *
 */

package edu.amrita.aview.core.shared.components
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import spark.components.Button;
	
	[Style(name="imageSkin", type="*")]
	[Style(name="imageSkinDisabled", type="*")]
	[Style(name="imageSkinDown", type="*")]
	[Style(name="imageSkinOver", type="*")]
	/**
	 * @public
	 * extends Button
	 */
	public class ImageButton extends Button
	{
		/**
		 * @public
		 *
		 *
		 * @retun void
		 */
		public function ImageButton()
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