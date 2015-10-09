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
 * File			: PreTestConstants.as
 * Module		: Pretest
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 * 
 * PreTestConstants used to declare constant variables
 * 
 */
package views.toolSets.PreTest
{
	/**
	 * PreTestConstants class contains constants variables for pretesting.
	 */
	public class PreTestConstants
	{
		/**
		 * Common Constants
		 */
		public static const SPEAKER_TITLE:String = "Step 1 of 4: Check Speaker";
		public static const MICROPHONE_TITLE:String = "Step 2 of 4: Check Microphone";
		public static const VIDEO_TITLE:String = "Step 3 of 4: Check Video";
		public static const RESULT_TITLE:String = "Step 4 of 4: Test Result";
		
		/**
		 * Speaker Contants
		 */
		public static const SPEAKER_INSTRUCTION_MSG:String = "To test your speaker click the Play Audio button, Now you can hear the greeting audio. Ensure that your speaker is turned on. The volume should be set to an audiable level.";
		public static const PLAY_AUDIO:String = "Play Audio";
		public static const STOP_AUDIO:String = "Stop Audio";
		public static const AUDIO_TAG:String = "intro_new";
		
		
		/**
		 * Microphone Constants
		 */
		public static const MICROPHONE_INSTRUCTION_MSG:String = "To ensure that your microphone is working properly, Select a audio device from the list and click Record Audio button, and read the following sentence. Click Stop Record button once you are done and click Play Recording button to hear your recording.";
		public static const  MICROPHONE_INFO:String = '"I see the visulaization and my microphone is working properly"';
		
		/**
		 * Video Constants
		 */
		public static const VIDEO_INSTRUCTION_MSG:String = "To check your video is working properly, Select video device from the list, Now you can see your video. Once this is complete click Next button.";
		public static const FRONT_CAMERA:String = "FrontCamera";
		public static const BACK_CAMERA:String = "Back Camera";
		
		/**
		 * Result Page Constants
		 */
		public static const SPEAKER_PASS_MSG:String = ":  Speaker Test Passed";
		public static const SPEAKER_FAIL_MSG:String = ":  Speaker Test Failed";
		public static const MICROPHONE_PASS_MSG:String = ":  Microphone Test Passed";
		public static const MICROPHONE_FAIL_MSG:String = ":  Microphone Test Failed";
		public static const VIDEO_PASS_MSG:String = ":  Video Test Passed";
		public static const VIDEO_FAIL_MSG:String = ":  Video Test Failed";
		
	}
}