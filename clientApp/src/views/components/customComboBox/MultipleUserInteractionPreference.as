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
 * File			: MultipleUserInteractionPreference.as
 * Module		: Video
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK
 *
 * MultipleUserInteractionPreference component is used to enable and disable muliple user interaction feature
 *
 */
package views.components.customComboBox
{
	/**
	 * Importing flash library
	 */
	import flash.events.Event;
	/**
	 * Importing mx library
	 */
	import mx.core.FlexGlobals;
	import mx.events.FlexMouseEvent;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradientStroke;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	/**
	 * Importing spark library
	 */
	import views.skins.MUIToggleSkin;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.ToggleSwitch;
	import spark.components.VGroup;
	import spark.filters.DropShadowFilter;
	import spark.primitives.Line;
	import spark.primitives.Rect;

	/**
	 * MultipleUserInteractionPreference class for changing mulitiple interaction option.
	 */
	public class MultipleUserInteractionPreference extends SkinnablePopUpContainer
	{
		/**
		 * Container to add toggleSwitch, title and message label
		 */
		private var outerContainer:VGroup=new VGroup();
		/**
		 * Instance of ToggleSwitch to change the MUI option
		 */
		public var muiToggleSwitch:ToggleSwitch=new ToggleSwitch();
		/**
		 * Holds title
		 */
		private var muiTitle:Label=new Label();
		/**
		 * Holds information message for user
		 */
		[Bindable]
		public var muiMessage:Label=new Label();

		/**
		 * @public
		 *
		 * Constructor
		 * Add eventListener for changing toggle switch and MOUSE_DOWN_OUTSIDE event to close the component
		 *
		 */
		public function MultipleUserInteractionPreference()
		{
			super();
			this.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, callOutCloseHandler);
			muiToggleSwitch.addEventListener(Event.CHANGE, muiPreferenceChangeHandler);
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
		 * To add/remove MUI feature, to select/unselect multiple user for interaction
		 *
		 * @param event of ChangeEvent
		 * @return void
		 */
		private function muiPreferenceChangeHandler(event:Event):void
		{
			if (muiToggleSwitch.selected)
			{
				FlexGlobals.topLevelApplication.mainApp.changeMUIMode(true);
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.changeMUIMode(false);
			}
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
			outerContainer.percentWidth=100;
			outerContainer.percentHeight=100;

			outerContainer.paddingBottom=10;
			outerContainer.paddingLeft=10;
			outerContainer.paddingRight=10;
			outerContainer.paddingTop=10;

			outerContainer.verticalAlign="middle";
			outerContainer.horizontalAlign="center";
			//Set title
			var titleContainer:HGroup=new HGroup();
			titleContainer.percentHeight=100;
			titleContainer.percentWidth=100;
			titleContainer.paddingTop=10;
			titleContainer.verticalAlign="middle";
			titleContainer.horizontalAlign="center";
			titleContainer.addElement(muiTitle);
			muiTitle.text="Multiple user interaction ";
			muiTitle.setStyle("color", "0xFFFFFF");
			muiTitle.setStyle("fontWeight", "bold");

			//Set horizonatla line
			var line:Line=new Line();
			line.percentWidth=100;
			var lineColor:SolidColorStroke=new SolidColorStroke(uint("0xFFFFFF"), 1, 1);
			line.stroke=lineColor;

			//Set Message
			var messageContainer:HGroup=new HGroup();
			messageContainer.percentHeight=100;
			messageContainer.percentWidth=100;
			messageContainer.paddingLeft=10;
			messageContainer.paddingRight=10;
			messageContainer.paddingTop=10;
			messageContainer.verticalAlign="middle";
			messageContainer.horizontalAlign="center";
			messageContainer.addElement(muiMessage);
			muiMessage.percentWidth=100;
			muiMessage.setStyle("color", "0xFFFFFF");

			outerContainer.addElement(titleContainer);
			outerContainer.addElement(line);
			outerContainer.addElement(messageContainer);
			outerContainer.addElement(muiToggleSwitch);
			muiToggleSwitch.setStyle('skinClass', views.skins.MUIToggleSkin);

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

			addElement(outerContainer);
		}
	}
}
