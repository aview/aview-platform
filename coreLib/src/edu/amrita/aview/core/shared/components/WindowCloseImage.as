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
 * File			: WindowCloseImage.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 *
 * For creating the close button for all the pop up windows
 *
 */

package edu.amrita.aview.core.shared.components
{
	import flash.events.MouseEvent;
	
	import spark.components.Image;

	/**
	 * @public
	 * extends Button
	 */
	public class WindowCloseImage extends Image
	{
		
		/**
		 *  The icon classes 
		 */
		[Bindable]
		[Embed(source="../assets/images/Medium_close.png")]
		private var mouseOutCloseIcon:Class;
		[Bindable]
		[Embed(source="../assets/images/Medium_close_over.png")]
		private var mouseOverCloseIcon:Class;
		
		/**
		 * @public
		 *
		 * Constructor
		 * 
		 */
		public function WindowCloseImage()
		{
			super();
			this.source = mouseOutCloseIcon;
			this.useHandCursor = true;
			this.buttonMode = true;
			this.toolTip = "Close";
			addEventListener(MouseEvent.MOUSE_OVER, closeButtonMouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, closeButtonMouseOutHandler);
		}
		
		/**
		 * @private
		 *
		 * This function is invoked when the mouse is over the close component
		 * @param event - the mouse event
		 * @return void
		 */
		private function closeButtonMouseOverHandler(event:MouseEvent):void
		{
			this.source = mouseOverCloseIcon;
		}
		
		/**
		 * @private
		 * This function is invoked when the mouse is focussed out of the close component
		 * @param event - the mouse event
		 * @return void
		 */
		private function closeButtonMouseOutHandler(event:MouseEvent):void
		{
			this.source = mouseOutCloseIcon;
		}	
	}
}