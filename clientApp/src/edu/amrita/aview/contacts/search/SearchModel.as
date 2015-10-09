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
 * File			: SearchModel.as
 * Module		: contacts
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Veena Gopal K.V
 *
 */
//VGCR:-Varaiable Description
package edu.amrita.aview.contacts.search
{
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	//PNCR: class description
	public class SearchModel
	{
		public var fName:String = "";
		public var lName:String = "";
		public var userName:String = "";
		public var instituteId:Number = 0;
		public var stateId:Number = 0;
		public var email:String = "";
		public var phoneNumber:String = "";
		public var users:ArrayCollection = null;
		public var institutes:ArrayCollection=null;
		public var states:ArrayCollection=null;
		public var selectedGroup:GroupVO=null;
		
		/**
		 * @public 
		 * Constructor 
		 * 
		 */
		public function SearchModel()
		{
		}
	}
}