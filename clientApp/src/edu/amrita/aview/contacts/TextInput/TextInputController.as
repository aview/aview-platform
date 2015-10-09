// ActionScript file
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
 *
 * File			: TextInputController.as
 * Module		: contacts
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Veena Gopal K.V
 *
 */
//VGCR:-Function Description
//VGCR:-Variable Description
package edu.amrita.aview.contacts.TextInput
{
	import edu.amrita.aview.contacts.events.TextInputEvent;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.utils.StringUtil;

	/**
	 * 
	 * @public
	 * extends EventDispatcher
	 * //PNCR:description
	 */
	public class TextInputController extends EventDispatcher
	{
		//PNCR: add variable description
		//private var textInputModel:TextInputModel;
		private var textInputView:TextInputView;
		
		public var oldValue:String = null;
		
		public function TextInputController()
		{
			
		}
		
		/**
		 * @public 
		 * //PNCR:description
		 * @param title of type String
		 * @param oldValue of type String
		 * @param callingComp of type DisplayObject
		 * @return void
		 */
		public function showTextInputView(title:String, oldValue:String, callingComp:DisplayObject):void
		{
			this.oldValue = oldValue;
			textInputView = new TextInputView;
			textInputView.title=title;
			textInputView.newValue=oldValue;
			textInputView.addEventListener(TextInputEvent.VALUE_CHANGED, onTextInputValueChanged);
			PopUpManager.addPopUp(textInputView, callingComp);
			PopUpManager.centerPopUp(textInputView);
		}
		
		/**
		 * @private 
		 * //PNCR:description
		 * @param event of type TextInputEvent
		 * @return void
		 */
		private function onTextInputValueChanged(event:TextInputEvent):void
		{
			var newValue:String = StringUtil.trim(event.data as String);
			if (oldValue != null)
			{
				var isValidInput:Boolean = validateInput(oldValue, newValue);
				if (!isValidInput)
				{
					textInputView.errorMsg = "New value is same as old value. Enter a different value and try again."
					return;
				}
			}
			/**if oldValue is null or if the input is valid*/
			var data:Object = {oldValue:oldValue, newValue:newValue};
			this.dispatchEvent(new TextInputEvent(TextInputEvent.VALUE_CHANGED, data));
			closeTextInputView();
		}
		
		/**
		 * @private
		 * //PNCR:description 
		 * @param oldValue of type String
		 * @param newValue of type String
		 * @return Boolean
		 */
		private function validateInput(oldValue:String, newValue:String):Boolean
		{
			if (oldValue != newValue)
			{
				return true;
			}
			return false;
		}

		/**
		 * @private
		 * //PNCR:description 
		 * @return void
		 */
		private function closeTextInputView():void
		{
			PopUpManager.removePopUp(textInputView);
			textInputView = null;
			//textInputModel = null;
		}
	}
}