package edu.amrita.aview.core.desktopSharing
{
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.supportClasses.ItemRenderer;
	
	public class ActiveApplicationListItemRenderer extends ItemRenderer
	{
		/**
		 * Parent container to hold values
		 */
		private var groupContainer:HGroup=new HGroup();
		/**
		 * To show user name
		 */
		private var userDisplayText:Label=new Label();
		/**
		 * To display user name along user type
		 */
		[Bindable]
		public var appName:String;
		
		
		/**
		 * @public
		 *
		 * Constructor
		 * To add data change listener
		 */
		public function ActiveApplicationListItemRenderer()
		{
			super();
			groupContainer.addEventListener(MouseEvent.DOUBLE_CLICK,onItemClick);
			
		}
		
		private function onItemClick(event:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpDisplay.selectApp();
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
			userDisplayText.text=value.label;
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
			groupContainer.paddingTop = 5;
			groupContainer.paddingBottom = 5;
			groupContainer.addElement(userDisplayText);
			groupContainer.verticalAlign="middle";
			
			this.addElement(groupContainer);
		}
	}
}