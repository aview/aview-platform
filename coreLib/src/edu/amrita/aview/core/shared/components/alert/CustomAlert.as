// AKCR: please change the copyright banner
////////////////////////////////////////////////////////////////////////////////
//
// *Copyright (c) 2007
//
// The usual Yada-Yada!
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this code and associated documentation
// files (the "Code"), to deal in the Code without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Code is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Code.
//
// THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// Further it is worth to mention that no animals have been 
// harmed during the development. No trees have been cut 
// down. Womens rights have been treated with full respect.
// Mankind's safety has been ensured at every step.
//
// Peace!
//
// 
////////////////////////////////////////////////////////////////////////////////
/**
 * @file: alert
// @author: Uday M. Shankar
// @date: 31-03-2007
// @description: Extending the Alert to create more customized alerts 
// with predefined icons etc.
// reviewer: Sivaram SK
 */
package edu.amrita.aview.core.shared.components.alert
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.core.IFlexModuleFactory;
	
	public class CustomAlert extends Alert
	{
		/**
		 * for showing the error icon in the alert window
		 */
		[Embed(source='assets/images/alert_error.gif')]
		private static var iconError:Class;
		/**
		 * for showing the info icon in the alert window
		 */
		[Embed(source='assets/images/alert_info.gif')]
		private static var iconInfo:Class;
		/**
		 * for showing the confirm icon in the alert window
		 */
		[Embed(source='assets/images/alert_confirm.gif')]
		private static var iconConfirm:Class;
		
		/**
		 * SKCR: add comments 
		 * */
		public static function mouseDownListener(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
		}
		
		/**
		 * @public
		 * for showing the information alert message
		 * @param message type String.
		 * @param title type String, Default value Information
		 * @param closehandler type Function, Default value Null.
		 * @param parent type Sprite, Default value Null.
		 * @return Alert
		 */
		public static function info(message:String, title:String="Information", closehandler:Function=null, parent:Sprite=null):Alert
		{
			var alert:Alert=show(message, title, Alert.OK, parent, closehandler, iconInfo);
			alert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
			return alert;
		}
		
		/**
		 * @public
		 * for showing the error alert message
		 * @param message type String.
		 * @param title type String, Default value Error.
		 * @param closehandler type Function, Default value Null.
		 * @param parent type Sprite., Default value Null.
		 * @return Alert;
		 */
		public static function error(message:String, title:String="Error", closehandler:Function=null, parent:Sprite=null):Alert
		{
			var alert:Alert=show(message, title, Alert.OK, parent, closehandler, iconError);
			alert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
			return alert;
		}
		
		/**
		 * @public
		 * for showing the confirm alert message
		 * @param message type String.
		 * @param title type String, Default value Confirmation
		 * @param closehandler type Function, Default value Null
		 * @param parent type Sprite, Default value Null
		 * @return Alert
		 */
		public static function confirm(message:String, title:String="Confirmation", closehandler:Function=null, parent:Sprite=null):Alert
		{
			var alert:Alert=show(message, title, Alert.YES | Alert.NO, parent, closehandler, iconConfirm);
			alert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
			return alert;
		}
		
		/**
		 * @public
		 * for showing the confirm alert message with the default No button selected
		 * @param message type String
		 * @param title type String, Default value Confirmation.
		 * @param closehandler type Function, Default Null
		 * @param parent type Sprite, Default value Null
		 * @return Alert
		 */
		public static function confirmDefaultNo(message:String, title:String="Confirmation", closehandler:Function=null, parent:Sprite=null):Alert
		{
			var alert:Alert=show(message, title, Alert.YES | Alert.NO, parent, closehandler, iconConfirm, Alert.NO);
			alert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
			return alert;
		}
		
		/**
		 * @public
		 * for showing the confirm alert message with the default yes button selected
		 * @param message type String
		 * @param title type String, Default value Confirmation.
		 * @param closehandler type Function, Default value Null
		 * @param parent type Sprite, Default value Null
		 * @return Alert
		 */
		public static function confirmDefaultYes(message:String, title:String="Confirmation", closehandler:Function=null, parent:Sprite=null):Alert
		{
			var alert:Alert=show(message, title, Alert.YES | Alert.NO, parent, closehandler, iconConfirm, Alert.YES);
			alert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
			return alert;
		}
		
		/**
		 * @public
		 * for showing the custom alert message
		 * @param message type String
		 * @param title type String, Default value Confirmation
		 * @param flag type unint, Default value 4
		 * @param parent type Sprite,Default value Null
		 * @param defaultButtonFlag type uint, Default value 4
		 * @param closehandler type Function, Default value Null
		 * @param iconClass type Class, Default value Null
		 * @param moduleFactory type IFlexModuleFactory, Default Null
		 * @return Alert
		 */
		public static function customMessage(message:String, title:String="Confirmation", flags:uint=4, parent:Sprite=null, closehandler:Function=null, iconClass:Class=null, defaultButtonFlag:uint=4, moduleFactory:IFlexModuleFactory=null):Alert
		{
			var alert:Alert=show(message, title, flags, parent, closehandler, iconClass, defaultButtonFlag, moduleFactory);
			alert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
			return alert;
		}
	}
}
