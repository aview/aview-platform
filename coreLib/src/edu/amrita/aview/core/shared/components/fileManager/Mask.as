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
 * File			: Mask.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 *
 */
//VGCR:-Class Description 
//VGCR:-Variable Description
//VGCR:-Function Description
package edu.amrita.aview.core.shared.components.fileManager
{
	import flash.display.Sprite;
	
	import mx.containers.Box;
	import mx.controls.ProgressBar;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	public class Mask extends Box
	{
		
		/**
		 * 
		 */
		private static var _mask:Mask;
		/**
		 * 
		 */		
		private var _message:String;
		
		/**
		 *@public 
		 * Constructor 
		 * 
		 */
		public function Mask()
		{
			super();
		}
		
		/**
		 * @public 
		 * @param message of type String
		 * @param parent of type Sprite default value = null
		 * @return Mask
		 * 
		 */
		public static function show(message:String, parent:Sprite=null):Mask
		{
			_mask=new Mask();
			_mask._message=message;
			PopUpManager.addPopUp(_mask, parent, true);
			PopUpManager.bringToFront(_mask);
			PopUpManager.centerPopUp(_mask);
			return _mask;
		}
		
		
		/**
		 * @public 
		 *
		 * 
		 */
		public static function close():void
		{
			PopUpManager.removePopUp(_mask);
		}
		
		/**
		 * @protected
		 * 
		 * 
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			var pb:ProgressBar=new ProgressBar();
			pb.label=_message || "Please wait...";
			pb.indeterminate=true;
			pb.labelPlacement='center';
			pb.setStyle('barColor', uint(0xAEAEAE));
			pb.height=26;
			
			addChild(pb);
		}
	}
}
