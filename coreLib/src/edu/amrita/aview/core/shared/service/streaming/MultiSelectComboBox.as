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
 * File			: MultiSelectComboBox.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:-Functional Description
package edu.amrita.aview.core.shared.service.streaming
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.controls.ComboBox;
	import mx.events.ListEvent;
	import mx.logging.Log;

	//VGCR:-Class Description
	public class MultiSelectComboBox extends ComboBox
	{
		/**Control Key Pressed */
		private var ctrlKeyPressed:Boolean=false; 
		
		/**
		 * @protected
		 * This function checks whether the CtrlKey is pressed.
		 * If CtrlKey is pressed then,
		 * multiple selection is enabled for the ComboBox dropdown.
		 * @param event of type KeyboardEvent
		 * 
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(Log.isInfo()) log.info("1");
			super.keyDownHandler(event);
			
			this.ctrlKeyPressed=event.ctrlKey;
			
			if (this.ctrlKeyPressed == true)
			{
				if(Log.isInfo()) log.info("1 TRUE");
				dropdown.allowMultipleSelection=true;
			}
		}
				
		/**
		 * @protected
		 * This function prevents the ComboBox from closing if CtrlKey is pressed
		 * Else it fires a Change event to update selectedItems array on close
		 * If CtrlKey is not pressed then,
		 * ComboBox dropdown is closed and change event is dispatched.
		 * 'dropdown' in a ComboBox is a List component 
		 * @param event of type KeyboardEvent
		 * 
		 */
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			if(Log.isInfo()) log.info("2");
			super.keyUpHandler(event);
			this.ctrlKeyPressed=event.ctrlKey;
			
			if (this.ctrlKeyPressed == false)
			{
				if(Log.isInfo()) log.info("2 false");
				this.close();
				var changeEvent:ListEvent=new ListEvent(ListEvent.CHANGE);
				this.dispatchEvent(changeEvent);
				this.selectedIndex=-1;
			}
		}
				
		/**
		 * @public 
		 * This function prevents the ComboBox from closing if CtrlKey is pressed on a Close Event
		 * @param trigger of type Event 
		 * 
		 */
		override public function close(trigger:Event=null):void
		{
			if (this.ctrlKeyPressed == false)
			{
				if(Log.isInfo()) log.info("3");
				super.close(trigger);
				this.selectedIndex=-1;
			}
		}
			
		/**
		 * @public 
		 * 'selectedItems' Setter
		 * @param value of type Array
		 * 
		 */
		public function set selectedItems(value:Array):void
		{
			if (this.dropdown)
			{
				if(Log.isInfo()) log.info("selectedItems value");
				this.dropdown.selectedItems=value;
			}
		}
		
		[Bindable("change")]
		/**
		 * @public
		 * 'selectedItems' Getter 
		 * @return Array
		 * 
		 */
		public function get selectedItems():Array
		
		{
			if (this.dropdown)
			{
				if(Log.isDebug()) log.debug("selectedItems value");
				return this.dropdown.selectedItems
			}
			else
			{
				
				if(Log.isDebug()) log.debug("selectedItems value");
				// AKCR: the return type of the function is an ARRAY; is return null working?
				return null;
			}
		}
			
		/**
		 * @public
		 * 'selectedIndices' Setter 
		 * @param value of Array
		 * 
		 */
		public function set selectedIndices(value:Array):void
		{
			if (this.dropdown)
			{
				if(Log.isInfo()) log.info("selectedIndices value");
				this.dropdown.selectedIndices=value;
			}
		}
				
		[Bindable("change")]
		/**
		 * @public
		 * 'selectedIndices' Getter 
		 * @return Array
		 * 
		 */
		public function get selectedIndices():Array
		{
			if (this.dropdown)
			{
				if(Log.isDebug()) log.debug("selectedIndices ");
				return this.dropdown.selectedIndices;
			}
			else
			{
				// AKCR: is return null working well with function return type Array?
				if(Log.isDebug()) log.debug("selectedIndices ");
				return null;
			}
		}
		
		/**
		 *  @public
		 * 'MultiSelectComboBox'
		 *  constructor
		 **/
		public function MultiSelectComboBox()
		{
			if(Log.isDebug()) log.debug("MultiSelectComboBox");
			super();
		}
	
	}
}
