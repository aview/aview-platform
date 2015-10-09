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
 * File			: SelectedViewerItemRenderer.as
 * Module		: Video
 * Developer(s)	: Salil George, Jeevanantham N
 * Reviewer(s)	: Pradeesh , Jayakrishnan R
 * 
 * SelectedViewerItemRenderer is a custom ItemRenderer for displaying the list of selected viewer.
 */
package edu.amrita.aview.core.shared.components.userList
{
	/**
	 * Importing mx library
	 */
	import mx.controls.Image;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.supportClasses.ItemRenderer;
	import spark.primitives.Rect;
	
	/**
	 * SelectedViewerItemRenderer class for displaying selected viewer to select viewer for viewing video.
	 */
	public class SelectedViewerItemRenderer extends ItemRenderer
	{
		/**
		 * Parent container to hold values
		 */
		private var groupContainer:HGroup=new HGroup();
		/**
		 * To show selected viewer name
		 */
		private var selectedViewerName:Label=new Label();
		[Bindable]
		[Embed(source="assets/images/private_chat_24x24.png")]
		public var icon:Class;
		
		private var selectedViewerIcon:Image=new Image();
		

		/**
		 * @public
		 * 
		 * Constructor
		 */
		public function SelectedViewerItemRenderer()
		{
			super();
		}
		/**
		 * @public
		 *
		 * To set selected viewer names
		 *
		 * @param value holds the values of selected viewer name
		 * @return void
		 */
		override public function set data(value:Object):void
		{
			if (value == null)
			{
				return;
			}
			super.data=value;
			selectedViewerName.percentWidth=100;
			selectedViewerName.text=data.contextName;
			if(data.contextName == "Private Chat")
			{
				selectedViewerIcon.source=icon;
			}
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
			//Add selectedViewerName label to groupContainer
			groupContainer.paddingLeft=10;
			groupContainer.paddingRight=10;
			groupContainer.percentWidth=100;
			groupContainer.verticalAlign="middle";
			groupContainer.addElement(selectedViewerIcon);
			groupContainer.addElement(selectedViewerName);
			groupContainer.horizontalAlign="center";
			
			//create border for groupContainer
			var borderRect:Rect=new Rect();
			var solidStroke:SolidColorStroke=new SolidColorStroke(uint("BAC4D7"), 0.5, 0.3);
			borderRect.stroke=solidStroke;
			borderRect.percentWidth=100;
			borderRect.percentHeight=100;
			this.addElement(borderRect);

			this.addElement(groupContainer);
		}
	}
}