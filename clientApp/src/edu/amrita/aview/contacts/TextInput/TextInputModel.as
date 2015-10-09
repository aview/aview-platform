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
 * File			: TextInputModel.as
 * Module		: contacts
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:-Function Description
package edu.amrita.aview.contacts.TextInput
{
	//PNCR:description
	[Bindable]
	public class TextInputModel
	{
		private var _title:String = null;
		
		//private var _oldValue:String = null;
		
		private var _newValue:String = null;
		
		private var _errorMsg:String = null;
		
		/**
		 * @public 
		 * //PNCR:description
		 * @param title of type String
		 * @param oldValue of type String default value null
		 * 
		 */
		public function TextInputModel(title:String, oldValue:String=null)
		{
			this._title = title;
			//this._oldValue = oldValue;
		}

		/**
		 * @public 
		 * Get function for title
		 * @return String
		 * 
		 */
		public function get title():String
		{
			return _title;
		}

		/**
		 * @public 
		 * set function for title
		 * @param value of type String
		 * 
		 */
		public function set title(value:String):void
		{
			_title = value;
		}

		/*public function get oldValue():String
		{
			return _oldValue;
		}

		public function set oldValue(value:String):void
		{
			_oldValue = value;
		}*/

		/**
		 * @public 
		 * get function for new Value
		 * @return String
		 * 
		 */
		public function get newValue():String
		{
			return _newValue;
		}

		/**
		 * @public 
		 * set function for new Value
		 * @param value of type String
		 * 
		 */
		public function set newValue(value:String):void
		{
			_newValue = value;
		}

		/**
		 * @public
		 * get function for error message
		 * @return String
		 */
		public function get errorMsg():String
		{
			return _errorMsg;
		}

		/**
		 * @public 
		 * set function for error message
		 * @param value of type String
		 */
		public function set errorMsg(value:String):void
		{
			_errorMsg = value;
		}
	}
}