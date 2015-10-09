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
 * File			:
 * Module		:
 * Developer(s)	:
 * Reviewer(s)	:
 *
 *
 *
 */

/**
 *
 */
package edu.amrita.aview.core.recording.Events
{
	import flash.events.Event;
	
	public class RecordingStatus extends Event
	{	public static const RECORDING_INIT_COMPLETE:String="initComplete";
		public static const RECORDING_ERROR:String="failedCreatingServerSideFolder";
		public static const RECORDED_XML_COPY_COMPLETE:String="recordedXmlCopied";
		public static const RECORDED_XML_COPY_ERROR:String="recordedXmlCopyError";
		public static const RECORDED_VIDEO_COPY_COMPLETE:String="recordedVideoCopied";
		public static const RECORDED_VIDEO_COPY_ERROR:String="recordedVideoCopyError";
		public function RecordingStatus(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}