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
 * File			: QuestionItemRenderer.as
 * Module		: Question
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: 
 * 
 * QuestionItemRenderer is a custom ItemRenderer for displaying the list of questions.
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
	 * QuestionItemRenderer class for displaying questions.
	 */
	public class QuestionItemRenderer extends ItemRenderer
	{
		/**
		 * Parent container to hold values
		 */
		private var groupContainer:HGroup=new HGroup();
		/**
		 * To show question name
		 */
		private var questionDisplayText:Label=new Label();
		private var questionGroup:HGroup=new HGroup();
		/**
		 * To show status name
		 */
		private var statusDisplayText:Label=new Label();
		private var statusGroup:HGroup=new HGroup();

		/**
		 * @public
		 * 
		 * Constructor
		 */
		public function QuestionItemRenderer()
		{
			super();
		}
		/**
		 * @public
		 *
		 * To set question and status names
		 *
		 * @param value holds the values of question and status details
		 * @return void
		 */
		override public function set data(value:Object):void
		{
			super.data=value;
			questionGroup.percentWidth=85;
			statusGroup.percentWidth=15;
			
			questionDisplayText.percentWidth=85;
			questionDisplayText.text=data.question;
			if(value.questionStatus == "ANSWERED"){
				questionDisplayText.setStyle("color","0x008E00");
			}else if(value.questionStatus == "SKIPPED"){
				questionDisplayText.setStyle("color","0xc80d0d");
			}else{
				questionDisplayText.setStyle("color","0x000000");
			}
			statusDisplayText.percentWidth=100;
			statusDisplayText.text=data.vote;
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
			//Add question and vote count label to groupContainer
			groupContainer.percentWidth=100;
			groupContainer.minHeight = 45;
			groupContainer.percentHeight=100;
			groupContainer.verticalAlign="middle";
			
			questionGroup.addElement(questionDisplayText);
			questionGroup.paddingTop = 3;
			questionGroup.paddingBottom = 2;
			
			groupContainer.addElement(questionGroup);
			var horizonatalBorderRect:Rect=new Rect();
			var solidStroke:SolidColorStroke=new SolidColorStroke(uint("BAC4D7"), 0.5, 0.3);
			horizonatalBorderRect.stroke=solidStroke;
			horizonatalBorderRect.width=1;
			horizonatalBorderRect.percentHeight=100;
			groupContainer.addElement(horizonatalBorderRect);
			
			statusGroup.addElement(statusDisplayText);
			statusGroup.paddingTop = 3;
			statusGroup.paddingBottom = 2;
			
			groupContainer.addElement(statusGroup);
			groupContainer.horizontalAlign="center";
			groupContainer.paddingLeft = 2;
			groupContainer.paddingRight = 2;
			
			
			//create border for groupContainer
			var borderRect:Rect=new Rect();
			borderRect.stroke=solidStroke;
			borderRect.percentWidth=100;
			borderRect.percentHeight=100;
			this.addElement(borderRect);

			this.addElement(groupContainer);
		}
	}
}