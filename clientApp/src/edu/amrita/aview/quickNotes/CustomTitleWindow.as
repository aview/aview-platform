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
 * File			: CustomTitleWindow.as
 * Module		: QuickNote
 * Developer(s)	: Sivaram
 * Reviewer(s)	: Remya T
 *
 * CustomTitleWindow.as is a TitleWindow based custom component used for loading quicknote.
 *
 */
package edu.amrita.aview.quickNotes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	
	/**
	 * @public
	 * TitleWindow based custom component used for loading quicknote.
	 * Added minimize option to the titlewindow.
	 */
	public class CustomTitleWindow extends TitleWindow
	{
		/**
		 * Button variable for collapse the quicknote titlewindow.
		 */
		public var collapseButton:Button;
		
		/**
		 * Button variable for poppingout the quicknote titlewindow to a window component.
		 */
		private var popOutButton:Button;
		
		/**
		 * Button variable for closing the quicknote titlewindow.
		 */
		private var closeBtn:Button;
		
		/**
		 * Variable for storing the icon image for popout button.
		 */
		[Bindable]
		[Embed(source="assets/images/pop_out.png")]
		public var popoutIcon:Class;
		
		/**
		 * Variable for storing the mouse-over icon image for popout button.
		 */
		[Bindable]
		[Embed(source="assets/images/pop_out_over.png")]
		public var mouseOverPopoutIcon:Class;
		
		/**
		 * Variable for storing the icon image for minimize button.
		 */
		[Bindable]
		[Embed(source="assets/images/quickNote_minimize.png")]
		public var collapseIcon:Class;
		
		/**
		 * Variable for storing the mouse-over icon image for minimize button.
		 */
		[Bindable]
		[Embed(source="assets/images/quickNote_minimize_over.png")]
		public var mouseOverCollapseIcon:Class;
		
		/**
		 * Variable for storing the mouse-over icon image for maximize button.
		 */
		[Bindable]
		[Embed(source="assets/images/quickNote_maximize_over.png")]
		public var mouseOverMaximizeIcon:Class;
		
		/**
		 * Variable for storing the icon image for maximize button.
		 */
		[Bindable]
		[Embed(source="assets/images/quickNote_maximize.png")]
		public var mouseOutMaximizeIcon:Class;
		
		/**
		 * Variable for storing the icon image for close button.
		 */
		[Bindable]
		[Embed(source="assets/images/Medium_close.png")]
		public var closeIcon:Class;
		
		/**
		 * Variable for storing the mouse-over icon image for close button.
		 */
		[Bindable]
		[Embed(source="assets/images/Medium_close_over.png")]
		public var mouseOverCloseIcon:Class;
		
		/**
		 * @public
		 * Constructor function for the class CustomTitleWindow.
		 *
		 *
		 * @return null
		 */
		public function CustomTitleWindow()
		{
			title="Custom TitleWindow";
			showCloseButton=true;
		}
		
		/**
		 * @private
		 * Function for getting the close button from the titlewindow.
		 *
		 *
		 * @return Button
		 */
		private function get closeButton():Button
		{
			var _closeButton:Button;
			if (!_closeButton)
			{
				for (var i:int=0; i < titleBar.numChildren; ++i)
				{
					if (titleBar.getChildAt(i) is Button && titleBar.getChildAt(i) != collapseButton && titleBar.getChildAt(i) != popOutButton && titleBar.getChildAt(i) != closeBtn)
					{
						_closeButton=titleBar.getChildAt(i) as Button;
					}
				}
			}
			
			return _closeButton;
		}
		
		/**
		 * @protected
		 * Function used for creating collapse,popout,close buttons and add event listners to it,then add it to the titlebar.
		 *
		 * @return void
		 */
		//PNCR: instead of using a generic name use a specific function name.
		override protected function createChildren():void
		{
			super.createChildren();
			collapseButton=new Button();
			collapseButton.focusEnabled=false;
			collapseButton.width=18;
			collapseButton.height=18;
			collapseButton.toolTip="Collapse";
			collapseButton.addEventListener(MouseEvent.CLICK, collapseHandler);
			collapseButton.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void
			{
				mouseOverHandler(event, 'collapse')
			});
			collapseButton.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void
			{
				mouseOutHandler(event, 'collapse')
			});
			collapseButton.setStyle("icon", collapseIcon);
			collapseButton.owner=this;
			titleBar.addChild(collapseButton);
			
			popOutButton=new Button();
			popOutButton.width=18;
			popOutButton.height=18;
			popOutButton.toolTip="Pop-out";
			popOutButton.addEventListener(MouseEvent.CLICK, clickHandler);
			popOutButton.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void
			{
				mouseOverHandler(event, 'popout')
			});
			popOutButton.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void
			{
				mouseOutHandler(event, 'popout')
			});
			popOutButton.setStyle("icon", popoutIcon);
			applicationType::desktop
			{
				// No pop out feature for web.
				titleBar.addChild(popOutButton);
			}
			
			closeBtn=new Button();
			closeBtn.width=18;
			closeBtn.height=18;
			closeBtn.toolTip="Close";
			closeBtn.addEventListener(MouseEvent.CLICK, closeHandler);
			closeBtn.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void
			{
				mouseOverHandler(event, 'close')
			});
			closeBtn.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void
			{
				mouseOutHandler(event, 'close')
			});
			closeBtn.setStyle("icon", closeIcon);
			titleBar.addChild(closeBtn);
		}
		
		//PNCR: Since the below two functions are doing similar functionality combine both with an argument.
		
		/**
		 * @private
		 * Mouseover event handler for collapse,popout,close buttons
		 *
		 * @param event accepts any type
		 * @param value of type string
		 * @return void
		 */
		private function mouseOverHandler(event:*, value:String):void
		{
			switch (value)
			{
				case 'close':
					closeBtn.setStyle("icon", mouseOverCloseIcon);
					break;
				case 'popout':
					popOutButton.setStyle("icon", mouseOverPopoutIcon);
					break;
				case 'collapse':
					if (this.height == 33)
					{
						collapseButton.setStyle("icon", mouseOverMaximizeIcon);
					}
					else
					{
						collapseButton.setStyle("icon", mouseOverCollapseIcon);
					}
					break;
			}
		}
		
		/**
		 * @private
		 * Mouseout event handler for collapse,popout,close buttons
		 *
		 * @param event accepts any type
		 * @param value of type string
		 * @return void
		 */
		private function mouseOutHandler(event:*, value:String):void
		{
			switch (value)
			{
				case 'close':
					closeBtn.setStyle("icon", closeIcon);
					break;
				case 'popout':
					popOutButton.setStyle("icon", popoutIcon);
					break;
				case 'collapse':
					if (this.height == 33)
					{
						collapseButton.setStyle("icon", mouseOutMaximizeIcon);
					}
					else
					{
						collapseButton.setStyle("icon", collapseIcon);
					}
					break;
			}
		}
		
		/**
		 * @protected
		 * Function used for setting the layout chrome of the title window.
		 *
		 * @param layoutWidth,layoutHeight type of Number
		 * @return void
		 */
		override protected function layoutChrome(layoutWidth:Number, layoutHeight:Number):void
		{
			super.layoutChrome(layoutWidth, layoutHeight);
			var width:Number=collapseButton.getExplicitOrMeasuredWidth();
			var height:Number=collapseButton.getExplicitOrMeasuredHeight();
			closeBtn.setActualSize(width, height);
			closeBtn.move(closeButton.x - 1, closeButton.y - 1);
			popOutButton.setActualSize(width, height);
			popOutButton.move(closeButton.x - (closeButton.width + 6), closeButton.y - 1);
			collapseButton.setActualSize(width, height);
			applicationType::desktop
			{
				collapseButton.move(closeButton.x - (closeButton.width + 27), closeButton.y - 1);
			}
			applicationType::web
			{
				//No pop out feature for web.
				collapseButton.move(closeButton.x - (closeButton.width + 10), closeButton.y - 1);
			}
		}
		
		/**
		 * @private
		 * Mouseclick event handler for popout button
		 *
		 * @param event accepts any type
		 * @return void
		 */
		private function clickHandler(event:*):void
		{
			dispatchEvent(new Event('popOutHandler', true, false));
		}
		
		/**
		 * @private
		 * Mouseclick event handler for collapse button
		 *
		 * @param event accepts any type
		 * @return void
		 */
		private function collapseHandler(event:*):void
		{
			dispatchEvent(new Event('miniHandler', true, false));
		}
		
		/**
		 * @private
		 * Mouseclick event handler for close button
		 *
		 * @param event accepts any type
		 * @return void
		 */
		private function closeHandler(event:*):void
		{
			dispatchEvent(new Event('clseHandler', true, false));
		}
	}
}
