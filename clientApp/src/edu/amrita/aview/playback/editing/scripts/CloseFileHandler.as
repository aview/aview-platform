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
 * File	    	: CloseFileHandler.as
 * Module		: Video Editing
 * Developer(s) : Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the constants variables.
 *
 **/

package edu.amrita.aview.playback.editing.scripts{
	import flash.events.Event;
	
	public class CloseFileHandler extends Event	{
		/**
		 * Constant variables.
		 */
		public static const CLOSED_VIDEO_SETTING_OK:String="closed_ok";
		public static const CLOSED_VIDEO_SETTING_CANCEL:String="closed_cancel";
		public static const CLOSED_VIDEO_EDITING:String="closed_cancel";
		public static const CLOSED_VIDEO_EDITING_CANCEL:String="cancel";
		public static const PLAYBACK_STOP:String="stopped";
		public static const CUT_RECORDED_INIT:String="init";
		public static const CUT_RECORDED_CLOSE:String="close";
		
		/**
		 * Constructor will invoke event
		 */
		public function CloseFileHandler(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}
