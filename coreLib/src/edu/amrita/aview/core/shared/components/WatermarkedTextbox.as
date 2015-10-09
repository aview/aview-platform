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
 * File			: WatermarkedTextbox.as
 * Module		: Common
 * Developer(s)	: Sivaram SK
 * Reviewer(s)	:Monisha Mohanan,Veena Gopal K.V
 *
 */
//MMCR:-Function description 
package edu.amrita.aview.core.shared.components
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;
	
	[Style(name="watermarkColor", type="Number", format="Color", inherit="no")]
	[Event(name="watermarkChanged", type="flash.events.Event")]
	[Event(name="watermarkVisibilityChanged", type="flash.events.Event")]
	/**
	 *
	 * @public
	 * extends TextInput
	 *
	 */
	public class WatermarkedTextbox extends TextInput
	{
		
		// Define a static variable.
		private static var classConstructed:Boolean=classConstruct();
		private var _label:Label=new Label();
		
		private var _bWatermarkColor:Boolean=true;
		private var _watermark:String;
		
		[Inspectable(defaultValue="", variable="_watermark", type="String", name="Watermark", format="String")]
		[Bindable(event="watermarkChanged")]
		
		private var _watermarkVisible:Boolean;
		
		[Inspectable(defaultValue=true, variable="_watermarkVisible", type="Boolean", name="Watermark is visible", format="Boolean")]
		[Bindable(event="watermarkVisibilityChanged")]

		
		/**
		 *
		 * @private
		 * Define a static method.
		 *
		 * @return Boolean
		 *
		 */
		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("WatermarkedTextbox"))
			{
				// If there is no CSS definition for StyledRectangle,
				// then create one and set the default value.
				var newStyleDeclaration:CSSStyleDeclaration=new CSSStyleDeclaration();
				newStyleDeclaration.setStyle("watermarkColor", 0xbbbbbb);
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("WatermarkedTextbox", newStyleDeclaration, true);
			}
			return true;
		}
		
		
		
		/**
		 *
		 * @public
		 * constructor
		 *
		 */
		public function WatermarkedTextbox()
		{
			super();
			this.addEventListener(FocusEvent.FOCUS_IN, _hideWatermark);
			this.addEventListener(FocusEvent.FOCUS_OUT, _showWatermark);
		}
		/**
		 *
		 * @public
		 * setter function for setting the data
		 * @param value type String
		 * @return void
		 */
		public function set watermark(value:String):void
		{
			this._watermark=value;
			if (this._label)
				this._label.text=this._watermark;
			this.dispatchEvent(new Event("watermarkChanged"));
		}
		
		/**
		 *
		 * @public
		 * getter function for setting the data
		 *
		 * @return String
		 */
		public function get watermark():String
		{
			return this._watermark;
		}
		
	    /**
		 *
		 * @public
		 * setter function for setting the visibility of the component
		 * @param value type Boolean
		 * @return void
		 */
		public function set watermarkVisible(value:Boolean):void
		{
			this._watermarkVisible=value;
			this._label.visible=(this.text == "" && value);
		}
		
		/**
		 *
		 * @public
		 * getter function for setting the visibility of the component
		 *
		 * @return Boolean
		 */
		public function get watermarkVisible():Boolean
		{
			return this._watermarkVisible;
		}
				
		/**
		 *
		 * @public
		 * setter function for assigning the data to the component
		 * @param value type String
		 * @return void
		 */
		override public function set text(value:String):void
		{
			super.text=value
			this.watermarkVisible=(!value);
		}
		
		/**
		 *
		 * @public
		 * setter function for assigning the data in html format 
		 * @param value type String
		 * @return void
		 */
		override public function set htmlText(value:String):void
		{
			super.htmlText=value
			this.watermarkVisible=(!value);
		}
		
		/**
		 *
		 * @public
		 * function for applying the style
		 * @param styleProp type String
		 * @return void
		 */
		override public function styleChanged(styleProp:String):void
		{
			
			super.styleChanged(styleProp);
			if (styleProp == "watermarkColor")
			{
				_bWatermarkColor=true;
				invalidateDisplayList();
				return;
			}
		}
		/**
		 *
		 * @private
		 * function for setting the visibily of the component
		 * @param event of Focus
		 * @return void
		 *
		 */
		private function _hideWatermark(event:FocusEvent):void
		{
			this.watermarkVisible=false;
		}
		
		/**
		 *
		 * @private
		 * function for setting the visibily of the component
		 * @param event of Focus
		 * @return void
		 */
		private function _showWatermark(event:FocusEvent):void
		{
			this.watermarkVisible=true;
		}
		
		/**
		 *
		 * @protected
		 *
		 * @return void
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			this.addChild(this._label);
			this._label.text=this.watermark;
		}
		
		/**
		 *
		 * @protected
		 * @param unscaledWidth type number
		 * @param unscaledHeight type number
		 * @return void
		 */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this._label.height=this.height;
			this._label.width=this.width;
			if (_bWatermarkColor)
			{
				_bWatermarkColor=false;
				this._label.setStyle("color", this.getStyle("watermarkColor"));
			}
		}
		
		
	}
}
