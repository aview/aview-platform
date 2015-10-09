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
 * File			: SparkCheckBoxList.as
 * Module		: common
 * Developer(s)	: Sivaram SK
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
 
/**
 * This component expects an ItemRenderer with checkbox in it.
 * Items in this list are selected/deselected using the checkbox.
 * */
package edu.amrita.aview.common.components.checkBox
{
	import flash.events.MouseEvent;
	
	import spark.components.CheckBox;
	import spark.components.List;
	
	/**
	 * VPCR: Add class description */
	

	public class SparkCheckBoxList extends List
	{
		public function SparkCheckBoxList()
		{
			super();
		}
		
		/**
		 * VPCR: Add function description */
		
		/**
		 * @protected 
		 * @param event MouseEvent
		 * 
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			if (!(event.target is CheckBox))
			{
				event.stopImmediatePropagation();
				return;
			}
			
			if (!event.shiftKey)
			{
				//fake all mouse interactions as if it had the Ctrl key is active (true)
				event.ctrlKey = true;
			}
			super.item_mouseDownHandler(event);
		}
	}
}