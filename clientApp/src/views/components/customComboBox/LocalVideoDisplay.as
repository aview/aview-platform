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
 * File			: LocalVideoDisplay.as
 * Module		: Video
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Sivaram SK
 *
 * LocalVideoDisplay component is used for showing the local video.
 *
 */
package views.components.customComboBox
{
	/**
	 * Importing flash library
	 */
	import flash.media.Camera;
	import flash.media.Video;
	/**
	 * Importing spark library
	 */
	import spark.components.Callout;
	import spark.components.VideoDisplay;

	/**
	 * LocalVideoDisplay class for displaying user video.
	 */
	public class LocalVideoDisplay extends Callout
	{
		/**
		 * Video Object to display the stream video.
		 */
		private var localVideo:Video;

		/**
		 * VideoDisplay Object to show the video stream.
		 */
		private var localVidDisplay:VideoDisplay;

		/**
		 * @public
		 *
		 * To display the video
		 *
		 * @param camera holds camera object
		 * @return void
		 */
		public function createLocalVideoDisplay(camera:Camera=null):void
		{
			localVideo=new Video(208, 140);
			localVideo.visible=true;
			camera.setMode(500, 450, 15);
			localVideo.attachCamera(camera);
			localVidDisplay=new VideoDisplay();
			localVidDisplay.width=210;
			localVidDisplay.height=140;
			localVidDisplay.addChild(localVideo);
			localVidDisplay.visible=true;
			this.width=localVidDisplay.width;
			this.height=localVidDisplay.height + 20;
			this.addElement(localVidDisplay);
		}
	}
}
