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
 * File			: UserSOValue.as
 * Module		: Common
 * Developer(s)	: Ashish
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-Class Description
//VGCR:-Variable Description
package edu.amrita.aview.core.shared.components.userList
{
	import edu.amrita.aview.core.entry.Constants;
	
	public class UserSOValue
	{
		public var userStatus:String;
		public var controlStatus:String;
		public var userRole:String;
		public var userType:String;
		public var isModerator:Boolean;
		public var userDisplayName:String;
		public var userInstituteName:String;
		public var userTalkStatus:String;
		public var requestTime:String;
		public var isVideoPublishing:Boolean;
		public var isVideoHide:Boolean;
		public var isAudioMute:Boolean;
		public var isAudioOnlyMode:Boolean;
		public var id:String;
		public var userInteractedCount:int=0;
		public var avcRuntime:String;
		public var avcDeviceType:String;
		public var userId:int=0;
		public var viewVideoCount:int=0;
		public var peopleCount:int=0;
		/**
		 * @public 
		 * @param userValue of type Object
		 * Constructor
		 */
		public function UserSOValue(userValue:Object)
		{
			userInteractedCount=userValue.userInteractedCount;
			userStatus=userValue.userStatus;
			controlStatus=userValue.controlStatus;
			userRole=userValue.userRole;
			userType=userValue.userType;
			isModerator=userValue.isModerator;
			userDisplayName=userValue.userDisplayName;
			userInstituteName=userValue.userInstituteName;
			requestTime=userValue.requestTime;
			isVideoPublishing=userValue.isVideoPublishing;
			isVideoHide=userValue.isVideoHide;
			isAudioMute=userValue.isAudioMute;
			isAudioOnlyMode=userValue.isAudioOnlyMode;
			avcRuntime=userValue.avcRuntime;
			avcDeviceType=userValue.avcDeviceType
			//Initialize it with default value. Later this value may be reset in the setMuteSortedArray method
			userTalkStatus=Constants.FREETALK;
			id=userValue.id;
			userId=userValue.userId;
			viewVideoCount=userValue.viewVideoCount;
		}
	}
}
