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
package views.customItemRendererer
{
	/**
	 * Importing mx library
	 */
	import mx.graphics.SolidColorStroke;
	/**
	 * Importing spark library
	 */
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
			selectedViewerName.text=data.selectedViewerName;
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
			groupContainer.percentWidth=100;
			groupContainer.height=45;
			groupContainer.verticalAlign="middle";
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