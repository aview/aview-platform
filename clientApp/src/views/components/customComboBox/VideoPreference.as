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
 * File			: VideoPreference.as
 * Module		: Video
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK
 *
 * VideoPreference component is used to add and remove video module at run time
 *
 */
package views.components.customComboBox
{
	/**
	 * Importing custom events
	 */
	import edu.amrita.aview.core.shared.events.mobileCustomEvents.VideoSettingPreferenceEvent;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradientStroke;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import views.skins.VideoSettingToggleSkin;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.ToggleSwitch;
	import spark.components.VGroup;
	import spark.filters.DropShadowFilter;
	import spark.primitives.Line;
	import spark.primitives.Rect;

	/**
	 * VideoPreference class for changing video module option.
	 */
	public class VideoPreference extends SkinnablePopUpContainer
	{
		/**
		 * Container to add toggleSwitch, title and message label
		 */
		private var verticalContainer:VGroup=new VGroup();
		/**
		 * Instance of ToggleSwitch to change video module
		 */
		public var videoPreferenceToggleSwitch:ToggleSwitch=new ToggleSwitch();
		/**
		 * Holds custom function
		 */
		private var setVideoStatus:Function=null;
		/**
		 * Holds title
		 */
		private var titleText:Label=new Label();
		/**
		 * Holds information message for user
		 */
		[Bindable]
		public var messageText:Label=new Label();

		/**
		 * @public
		 *
		 * Constructor
		 * Add eventListener for changing toggle switch and add MOUSE_DOWN_OUTSIDE event to close the component
		 * Set function for invoking custom function
		 *
		 * @param functionName holds custom function name
		 */
		public function VideoPreference(functionName:Function)
		{
			super();
			this.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, callOutCloseHandler);
			this.setVideoStatus=functionName;
			videoPreferenceToggleSwitch.addEventListener(Event.CHANGE, videoSettingChangeHandler);
		}

		/**
		 * @private
		 *
		 * To close the component, when user clicks on outside of the component
		 *
		 * @param event of FlexMouseEvent
		 * @return void
		 */
		private function callOutCloseHandler(event:FlexMouseEvent):void
		{
			this.close();
		}

		/**
		 * @private
		 *
		 * To invoke custom function to add/remove video module
		 *
		 * @param event of change event
		 * @return void
		 */
		private function videoSettingChangeHandler(event:Event):void
		{
			var videoStatus:VideoSettingPreferenceEvent;
			if (videoPreferenceToggleSwitch.selected)
			{
				videoStatus=new VideoSettingPreferenceEvent(VideoSettingPreferenceEvent.VIDEO_SETTING_ON);
			}
			else
			{
				videoStatus=new VideoSettingPreferenceEvent(VideoSettingPreferenceEvent.VIDEO_SETTING_OFF);
			}
			this.setVideoStatus(videoStatus);
		}

		/**
		 * @protected
		 *
		 * To add UI component into parent container
		 *
		 * @param null
		 * @return void
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			verticalContainer.percentHeight=100;
			verticalContainer.percentWidth=100;

			verticalContainer.paddingBottom=10;
			verticalContainer.paddingLeft=10;
			verticalContainer.paddingRight=10;
			verticalContainer.paddingTop=10;

			verticalContainer.verticalAlign="middle";
			verticalContainer.horizontalAlign="center";
			//Set title
			var titleContainer:HGroup=new HGroup();
			titleContainer.percentHeight=100;
			titleContainer.percentWidth=100;
			titleContainer.paddingTop=10;
			titleContainer.verticalAlign="middle";
			titleContainer.horizontalAlign="center";
			titleContainer.addElement(titleText);
			titleText.text="Video Setting ";
			titleText.setStyle("color", "0xFFFFFF");
			titleText.setStyle("fontWeight", "bold");

			//Set line
			var line:Line=new Line();
			line.percentWidth=100;
			var lineColor:SolidColorStroke=new SolidColorStroke(uint("0xFFFFFF"), 1, 1);
			line.stroke=lineColor;

			//Set message
			var messageContainer:HGroup=new HGroup();
			messageContainer.percentHeight=100;
			messageContainer.percentWidth=100;
			messageContainer.paddingLeft=10;
			messageContainer.paddingRight=10;
			messageContainer.paddingTop=10;
			messageContainer.verticalAlign="middle";
			messageContainer.horizontalAlign="center";
			messageContainer.addElement(messageText);
			messageText.percentWidth=100;
			messageText.setStyle("color", "0xFFFFFF");

			verticalContainer.addElement(titleContainer);
			verticalContainer.addElement(line);
			verticalContainer.addElement(messageContainer);
			verticalContainer.addElement(videoPreferenceToggleSwitch);
			videoPreferenceToggleSwitch.setStyle('skinClass', views.skins.VideoSettingToggleSkin);
			//Set border
			var borderRect:Rect=new Rect();
			var linearStroke:LinearGradientStroke=new LinearGradientStroke(5);
			linearStroke.rotation=270;
			var gradientEntryBlack:GradientEntry=new GradientEntry(uint("0x696969"));
			var gradientEntryGary:GradientEntry=new GradientEntry(uint("0xB3B3B3"));
			linearStroke.entries=new Array(gradientEntryBlack, gradientEntryGary);
			//Set chrome color
			var filColor:SolidColor=new SolidColor(uint("0x071124"));

			borderRect.stroke=linearStroke;
			borderRect.fill=filColor;
			borderRect.percentWidth=100;
			borderRect.percentHeight=100;

			borderRect.top=0;
			borderRect.left=0
			borderRect.bottom=0;
			borderRect.right=0;
			this.addElement(borderRect);

			addElement(verticalContainer);
		}
	}
}
