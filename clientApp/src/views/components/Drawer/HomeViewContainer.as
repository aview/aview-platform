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
 * File			: HomeViewContainer.as
 * Module		: Classroom
 * Developer(s)	: Meena S
 * Reviewer(s)	: Pradeesh 
 * 
 * HomeViewContainer is a custom SkinnableContainer to to act as drawer to open and hide component when user clicks on button.
 */
package views.toolSets.home 
{
	/**
	 * Importing flash library
	 */
	import flash.events.MouseEvent;
	/**
	 * Importing spark library
	 */
	import spark.components.Button;
	import spark.components.SkinnableContainer;
	
	/**
	 * HomeViewContainer is a custom component to open/close home component.
	 */
	[SkinState("opened")]
	public class HomeViewContainer extends SkinnableContainer 
	{
		/**
		 * To set to true, when user opens home component
		 */
		private var _opened:Boolean = false;
		
		/**
		 * Button instance
		 */
		[SkinPart(required="false")]
		public var openButton:Button;
		
		/**
		 * @public
		 *
		 * To get the value of whether component is open or not
		 *
		 * @return Boolean
		 */
		public function get opened():Boolean 
		{
			return _opened;
		}
		
		/**
		 * @public
		 *
		 * Set opened as true, when user clicks to open the component
		 * Set opened as false, when user clicks to hide the component
		 *
		 * @param moduleName holds the values of whether component is open or not
		 * @return void
		 */
		public function set opened(value:Boolean):void 
		{
			if (_opened != value) {
				_opened = value;
				invalidateSkinState();
			}
		}
		/**
		 * @public
		 *
		 * To get the current state of the component
		 *
		 * @return current state of the component whether component is open or not as String
		 */
		override protected function getCurrentSkinState():String 
		{
			return (opened ? 'opened' : super.getCurrentSkinState());
		}
	}
}