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
 * File			: TreeCustomItemRenderer.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *TreeCustomItemRenderer class  is custom component for tree list.
 * We add two extra icons in each item in tree list for Batch processing
 *
 */
package edu.amrita.aview.core.shared.components.fileManager.TreeCustomDesign
{
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	import spark.components.Button;

	/**
	 * TreeCustomItemRenderer class  is custom component for tree list.
	 * We add two extra icons in each item in tree list for Batch processing
	*/
	public class TreeCustomItemRenderer extends TreeItemRenderer
	{
		/**
		 * SwfLoader for load the processing icon for batch preocessing
		 */
		public var processingItem:SWFLoader;
		/**
		 * SwfLoader for load the waiting icon for batch preocessing
		 */		
		public var waitingItem:Image;
		/**
		 * SwfLoader for load the waiting icon for batch preocessing
		 */		
		public var btnCancel:Button;
		[Bindable]
		[Embed("/edu/amrita/aview/core/shared/components/fileManager/assets/images/CancelProcess.png")]
		public var cancelIcon:Class;
		[Bindable]
		[Embed("/edu/amrita/aview/core/shared/components/fileManager/assets/images/loading.swf")]
		public var loadingIcon:Class;
		[Bindable]
		[Embed("/edu/amrita/aview/core/shared/components/fileManager/assets/images/clock.png")]
		public var waitingIcon:Class;
		/**
		 * Constructor
		 *@public 
		 * 
		 */
		public function TreeCustomItemRenderer()
		{
			super();
		}		
	
		/**
		 *@protected
		 *Creating the extra children for treelist
		 *
		 * 
		 */
		override protected function createChildren():void
		{
			// AKCR: please move the hard-coded string to the constant file of this package
			super.createChildren();
			processingItem=new SWFLoader();
			processingItem.source=loadingIcon;
			waitingItem=new Image();
			waitingItem.source=waitingIcon;
			//btnCancel=new Button();
			//btnCancel.setStyle("icon",cancelIcon);
			//btnCancel.addEventListener(MouseEvent.CLICK,cancelClickHandler)
			this.addChild(processingItem);
			this.addChild(waitingItem);
			//this.addChild(btnCancel);
		}
		
		private function cancelClickHandler(event:MouseEvent):void
		{
			
		}
		/**
		 * @protected 
		 * Here we set the icons for Tree list .
		 * @param unscaledWidth of type Number
		 * @param unscaledHeight of type Number
		 * 
		 */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
			var treeListData:TreeListData=TreeListData(listData);
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (treeListData)
			{
			
				this.setStyle("color", "black");
				if (treeListData.hasChildren || 
					(treeListData.item.@status != "Conversion Started" && 
						treeListData.item.@status != "Conversion not started"))
				{
					
					this.setStyle("fontWeight", "normal");
					//this.label.text = this.label.text.toUpperCase();
					processingItem.visible=false;
					waitingItem.visible=false;
					//btnCancel.visible=false;
					this.setStyle("color", "black");
				}
				else
				{
					if (treeListData.item.@status == "Conversion not started")
					{
						this.setStyle("color", "red");
						processingItem.visible=false;
						waitingItem.visible=true;
						//btnCancel.visible=true;
						waitingItem.width=20;
						waitingItem.height=20;
						//btnCancel.width=40;
						//btnCancel.height=20;
						waitingItem.x=label.textWidth + label.x + 5;
						waitingItem.y=label.textHeight - 20;
						//btnCancel.x=waitingItem.width +waitingItem.x + 5;
						//btnCancel.y=label.textHeight - 20;
					}
					else
					{
						this.setStyle("fontWeight", "bold");
						this.setStyle("color", "blue");
						processingItem.visible=true;
						waitingItem.visible=false;
						//btnCancel.visible=false;
						processingItem.width=75;
						processingItem.height=20;
						processingItem.x=label.textWidth + label.x + 5;
						processingItem.y=label.textHeight - 17;						
					}
				}
			}
		}
	}
}
