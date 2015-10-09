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
 * File			: CheckBoxList.as
 * Module		: Common
 * Developer(s)	: Abhirami
 * Reviewer(s)	: Sivaram SK,Vishnupreethi.k
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.common.components.checkBox
{
	import flash.events.MouseEvent;
	
	import spark.components.CheckBox;
	import spark.components.List;
	/**
	 * VPCR: Add class description */
	public class CheckBoxList extends List
	{
		/**
		 *  @public 
		 * constructor
		 */
		public function CheckBoxList()
		{
			super();
		}
		/**
		 * VPCR: Add function description */
		/**
		 * @protected
		 * @param event of type MouseEvent
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
				/**
				 * fake all mouse interactions as if it had the Ctrl key is active (true) */
				
				event.ctrlKey = true;
			}
			super.item_mouseDownHandler(event);
		}
	}
}