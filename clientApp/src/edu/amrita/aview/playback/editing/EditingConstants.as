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
 * File			: EditingConstants.as
 * Module		: Video Editing
 * Developer(s)	: Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the constant values used in Video Editing.
 *
 */
package edu.amrita.aview.playback.editing
{
	//AKCR: please use the single line format for comments
	/**
	 * File contains the constant values used in Video Editing.
	 */
	public class EditingConstants{
		public function EditingConstants(){
		}
		
		/**
		 * X co ordinate value of ribbon .
		 */
		public static const SCALE_START_X_POS:Number=40;
		
		/**
		 * Y co ordinate value of ribbon .
		 */
		public static const SCALE_START_Y_POS:Number=50;
		
		/**
		 * Height of short needle in the scale.
		 */
		public static const SCALE_SHORT_NEEDLE_HT:Number=15;
		
		/**
		 * Height of long needle in the scale.
		 */
		public static const SCALE_LONG_NEEDLE_HT:Number=25;
		
		/**
		 * Width of needle.
		 */
		public static const SCALE_NEEDLE_THICKNESS:Number=1;
		
		/**
		 * Color of needle scale.
		 */
		public static const SCALE_NEEDLE_COLOR:uint=0x000000;
		
		/**
		 * Color of text written above the scale for indicating min/sec.
		 */
		public static const SCALE_TEXT_COLOR:uint=0x000000;
		
		/**
		 * Padding between two text in scale.
		 */
		public static const SCALE_TEXT_PADDING:int=10;
		
		/**
		 * Padding between scale and ribbon
		 */
		public static const SCALE_RIBBON_PADDING:int=2;
		
		/**
		 * Padding of container from right
		 */
		public static const EDITOR_CONTAINER_RIGHT_PADDING:int=20;
		
		/**
		 * Padding of container from left
		 */
		public static const EDITOR_CONTAINER_LEFT_PADDING:int=30;
		
		/**
		 * Width of ribbon text
		 */
		public static const RIBBON_TEXT_WIDTH:int=35;
		
		/**
		 * Height of ribbon.
		 */
		public static const RIBBON_HEIGHT_PC:Number=13.5;
		
		/**
		 * Edit icon.
		 */
		[Embed(source='assets/images/cut_active.png')]
		public static var cutActiveIcon:Class;
		
		/**
		 * Inactive Edit icon.
		 */
		[Embed(source='assets/images/cut_inactive.png')]
		public static var cutInactiveIcon:Class;
		
		/**
		 * Play icon.
		 */
		[Embed(source='assets/images/play_active.png')]
		public static var playActiveIcon:Class;
		
		/**
		 * Pause icon.
		 */
		[Embed(source='assets/images/play_paused.png')]
		public static var playInactiveIcon:Class;
		
		/**
		 * Insert icon.
		 */
		[Embed(source='assets/images/insert_active.png')]
		public static var insertActiveIcon:Class;
		
		/**
		 * Stop inactive icon.
		 */
		
		[Embed(source='assets/images/play_stopinactive.png')]
		public static var stopInactiveIcon:Class;
		
		/**
		 * Stop icon.
		 */
		[Embed(source='assets/images/play_stopped.png')]
		public static var stopActiveIcon:Class;
	}
}
