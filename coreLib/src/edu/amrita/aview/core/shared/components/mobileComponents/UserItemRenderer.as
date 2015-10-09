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
 * File			: UserItemRenderer.as
 * Module		: User
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Pradeesh , Jayakrishnan R
 * 
 * UserItemRenderer is a custom ItemRenderer for displaying the list of users.
 */
package edu.amrita.aview.core.shared.components.mobileComponents
{
	/**
	 * Importing mx library
	 */
	import edu.amrita.aview.core.entry.Constants;
	
	import flash.events.MouseEvent;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.supportClasses.ItemRenderer;
	import spark.primitives.Rect;
	
	/**
	 * UserItemRenderer class for displaying logged-in user to select user for interaction, send private chat and give presenter control.
	 */
	public class UserItemRenderer extends ItemRenderer
	{
		/**
		 * Parent container to hold values
		 */
		private var groupContainer:HGroup=new HGroup();
		/**
		 * To hold user icon
		 */
		private var userImage:Image=new Image();
		/**
		 * To show user name
		 */
		private var userDisplayText:Label=new Label();
		/**
		 * To hold status icon
		 */
		private var iconLoader:Image=new Image();

		/**
		 * To display user name along user type
		 */
		[Bindable]
		public var displayName:String;
		/**
		 * Holds icon for user status.
		 */
		[Bindable]
		private var userStatusIcon:Class;
		/**
		 * Used to set talk icon for status icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/PTT_status_talk.png")]
		public var micTalkIcon:Class;
		/**
		 * Used to set mute icon for status icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/PTT_status_mute.png")]
		public var micMuteIcon:Class;
		/**
		 * Used to set ask question icon for status icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/handRaiseWaitingStatus.png")]
		public var askQuestionIcon:Class;
		/**
		 * Used to set presenter request icon for status icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/presenterControlRequestStatus.png")]
		public var presenterRequestIcon:Class;
		/**
		 * Used to set presenter hold icon for user type icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/teacher gray.png")]
		public var teacherHold:Class;
		/**
		 * Used to set presenter active icon for user type icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/teacher green.png")]
		public var teacherActive:Class;
		/**
		 * Used to set user hold icon for user type icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/student gray.png")]
		public var studentHold:Class;
		/**
		 * Used to set user active icon for user type icon.
		 */
		[Bindable]
		[Embed(source="edu/amrita/aview/core/shared/components/assets/mobileAssets/student green.png")]
		public var studentActive:Class;
		/**
		 * Holds icon for user type.
		 */
		[Bindable]
		private var userIcon:Class;

		/**
		 * @public
		 *
		 * Constructor
		 * To add data change listener
		 */
		public function UserItemRenderer()
		{
			super();
			this.addEventListener(FlexEvent.DATA_CHANGE, changeIcon);
			this.addEventListener(MouseEvent.CLICK,onItemClick);

		}
		/**
		 * @private
		 *
		 * To change the icons based on the user type and user status
		 *
		 * @param event of FlexEvent
		 * @return void
		 */
		private function changeIcon(event:FlexEvent):void
		{
			//if user type is Presenter, set user status icon for presenter
			//Otherwise set user status icon for viewer
			if(data.userType == Constants.TEACHER_TYPE)
			{
				//if userstatus is HOLD
				if (data.userStatus == Constants.HOLD)
				{
					userIcon=teacherHold;
				}
				//if userstatus is ACCEPT
				else if (data.userStatus == Constants.ACCEPT)
				{
					userIcon=teacherActive;
				}
				//if userstatus is VIEW
				else if (data.userStatus == Constants.VIEW)
				{
					userIcon=teacherHold;
				}
				//if userstatus is WAITING
				else if (data.userStatus == Constants.WAITING)
				{
					userIcon=teacherHold;
				}
			}
			else
			{
				//if userstatus is HOLD
				if (data.userStatus == Constants.HOLD)
				{
					userIcon=studentHold;
				}
				//if userstatus is ACCEPT
				else if (data.userStatus == Constants.ACCEPT)
				{
					userIcon=studentActive;
				}
				//if userstatus is VIEW
				else if (data.userStatus == Constants.VIEW)
				{
					userIcon=studentHold;
				}
				//if userstatus is WAITING
				else if (data.userStatus == Constants.WAITING)
				{
					userIcon=studentHold;
				}
			}
			//If user selected viewer and PTT status is freetalk
			if (data.userStatus == Constants.ACCEPT && data.userTalkStatus == Constants.FREETALK)
			{
				userStatusIcon=micTalkIcon;
			}
			//If user selected viewer
			else if (data.userStatus == Constants.ACCEPT)
			{
				//If PTT status is talk
				if (data.id == FlexGlobals.topLevelApplication.mainApp.getAudioMuteSOValue())
				{
					userStatusIcon=micTalkIcon;
				}
				else//If PTT status is mute
				{
					userStatusIcon=micMuteIcon;
				}
			}
			//if userstatus is WAITING
			else if (data.userStatus == Constants.WAITING)
			{
				userStatusIcon=askQuestionIcon;
			}
			//if user send presenter request
			else if (data.controlStatus == Constants.PRSNTR_REQUEST)
			{
				userStatusIcon=presenterRequestIcon;
			}
			else
			{
				userStatusIcon=null;
			}
			//To modify the display name of the user based on the user type
			//For Moderator
			if (data.isModerator == true)
			{
				displayName="M: " + data.userDisplayName;
			}
			//For presenter
			else if (data.userRole == Constants.PRESENTER_ROLE)
			{
				displayName="P: " + data.userDisplayName;
			}
			//For selected viewer
			else if (data.userStatus == Constants.ACCEPT)
			{
				displayName="V: " + data.userDisplayName;
			}
			//For user
			else
			{
				displayName=data.userDisplayName;
			}

		}
		private function onItemClick(event:MouseEvent):void
		{
			var e:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK, true);
			e.item = data;
			e.index = itemIndex;
			dispatchEvent(e);
		}
		/**
		 * @public
		 *
		 * To set username, status and user type icon
		 *
		 * @param value holds the values of user details
		 * @return void
		 */
		override public function set data(value:Object):void
		{
			super.data=value;
			userDisplayText.percentWidth=100;
			userImage.source=userIcon;
			userDisplayText.text=displayName;
			iconLoader.source=userStatusIcon;
			invalidateDisplayList();
		}

		/**
		 * @protected
		 *
		 * To create and add it into parent container
		 *
		 * @param null
		 * @return void
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			//Add userImage and userDisplayText to groupContainer
			groupContainer.percentWidth=100;
			groupContainer.addElement(userImage);
			groupContainer.addElement(userDisplayText);
			iconLoader.horizontalAlign="right";
			groupContainer.addElement(iconLoader);
			groupContainer.verticalAlign="middle";

			this.addElement(groupContainer);
		}
	}
}
