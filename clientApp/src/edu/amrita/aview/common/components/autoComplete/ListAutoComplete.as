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
 * File			: ListAutoComplete.as
 * Module		: common
 * Developer(s)	: VijayKumar R
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.common.components.autoComplete
{
	import flash.events.KeyboardEvent;
	
	import spark.components.List;
	
	/**
	 * @public
	 * This list is used in AutoCompleteSkin.
	 * keyDownHandler is overridden so that the list can handle keyboard events for navigation.
	 */
	public class ListAutoComplete extends List
	{
		/**
		 * @protected
		 * Key down handler for handling the keyboard event
		 * @param event send the keyboard event
		 * @return void
		 */
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			
			super.keyDownHandler(event);
			
			if (!dataProvider || !layout || event.isDefaultPrevented())
				return;
			
			adjustSelectionAndCaretUponNavigation(event);
		
		}
	}
}
