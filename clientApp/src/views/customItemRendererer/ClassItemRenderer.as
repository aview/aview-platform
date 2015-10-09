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
 * File			: ClassItemRenderer.as
 * Module		: ClassroomListView
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Pradeesh , Jayakrishnan R
 * 
 * ClassItemRenderer is a custom ItemRenderer for displaying the list of registered classes and lectures.
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
	 * ClassItemRenderer class for displaying registered classes and lectures to enter into virtual classroom.
	 */
	public class ClassItemRenderer extends ItemRenderer
	{
		/**
		 * Parent container to hold values
		 */
		private var groupContainer:HGroup=new HGroup();
		/**
		 * To show class name
		 */
		private var classDisplayText:Label=new Label();
		/**
		 * To show lecture name
		 */
		private var lectureDisplayText:Label=new Label();

		/**
		 * @public
		 * 
		 * Constructor
		 */
		public function ClassItemRenderer()
		{
			super();
		}
		/**
		 * @public
		 *
		 * To set class and lecture names
		 *
		 * @param value holds the values of class and lecture details
		 * @return void
		 */
		override public function set data(value:Object):void
		{
			super.data=value;
			if(value!=null){
				classDisplayText.percentWidth=100;
				classDisplayText.text=data.aviewClass.className;;
				lectureDisplayText.percentWidth=100;
				lectureDisplayText.text=data.lecture.lectureName;
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
			//Add class and lecture label to groupContainer
			groupContainer.percentWidth=100;
			groupContainer.height=40;
			groupContainer.verticalAlign="middle";
			groupContainer.addElement(classDisplayText);
			groupContainer.addElement(lectureDisplayText);
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