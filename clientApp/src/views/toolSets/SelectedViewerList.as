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
 * File			: SelectedViewerList.as
 * Module		: Video
 * Developer(s)	: Salil George, Jeevanantham N
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 *
 * SelectedViewerList is a custom call-out component for displaying the list of selected viewer.
 * 
 */

package views.toolSets
{
	/**
	 * Importing flash library
	 */
	import edu.amrita.aview.core.entry.Constants;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	
	import spark.components.Callout;
	import spark.components.Label;
	import spark.components.List;
	
	import views.customItemRendererer.SelectedViewerItemRenderer;
	
	/**
	 * SelectedViewerList class for displaying selected viewer in a list
	 */
	public class SelectedViewerList extends Callout
	{
		/**
		 * To show selected viewer in list
		 */
		public var selectedViewerList:List;
		/**
		 * To show label, when there is no viewer for interaction
		 */
		private var displayLabel:Label;
		/**
		 * Holds selected viewers name 
		 */
		private var _dataProvider:ArrayList;
		
		/**
		 * @public
		 *
		 * Constructor
		 * To create components
		 */
		public function SelectedViewerList()
		{
			super();
			createComponents();
		}
		/**
		 * @public
		 *
		 * Setter for Arraylist
		 *
		 * @param value hold tha value of selected viewer list
		 * @return void
		 */
		public function set dataProvider(value:ArrayList):void
		{
			if (_dataProvider != value)
			{
				_dataProvider = value;
				selectedViewerList.dataProvider = _dataProvider;
				invalidateProperties();
			}
		}
		/**
		 * @public
		 *
		 * Getter for Arraylist
		 *
		 * @param null
		 * @return ArrayList
		 */
		[Bindable] 
		public function get dataProvider():ArrayList
		{
			return _dataProvider;
		}
		/**
		 * @private
		 *
		 * To create selected viewer list
		 *
		 * @param null
		 * @return void
		 */
		private function createComponents():void
		{
			selectedViewerList = new List;
			selectedViewerList.percentWidth = 100;
			selectedViewerList.percentHeight = 100;
			selectedViewerList.setStyle("color",uint("ffffff"));
			selectedViewerList.itemRenderer = new ClassFactory(views.customItemRendererer.SelectedViewerItemRenderer);
		}
		/**
		 * @public
		 *
		 * To update the selected viewer list and add it into parent container
		 *
		 * @param null
		 * @return void
		 */
		public function updateList():void
		{
			this.removeAllElements();
			if(this._dataProvider != null && this._dataProvider.length != 0 && this._dataProvider.source[0].value!=Constants.USER_HAS_BEEN_SELECTED)
			{
				this.addElement(selectedViewerList);
			}
			else if(this._dataProvider == null)
			{
				displayLabel = new Label;
				displayLabel.percentWidth = 100;
				displayLabel.percentHeight = 100;
				displayLabel.setStyle("textAlign","center");
				displayLabel.setStyle("verticalAlign","middle");
				displayLabel.setStyle("color",uint("ffffff"));
				displayLabel.text = "No Selected Viewer";
				
				this.addElement(displayLabel);
			}
			else
			{
				this.close();
			}
		}
	}
}