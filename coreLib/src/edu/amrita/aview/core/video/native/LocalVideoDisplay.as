package edu.amrita.aview.core.video.native
{
	//---------------------------------------------------------------------------------------------
	// 1. Authors      : Vivek
	// 2. Description  : LocalVideoDisplay class is used for showing the local video of user as a 
	//                   preview to himslef.This is being done by playing the uservideo stream from 					  
	//					 FMIS after its being published. 
	// 3. Dependencies : FFMPEGPublisher.as
	//---------------------------------------------------------------------------------------------
	
	import edu.amrita.aview.common.service.MediaServerConnection;
	
	import flash.events.Event;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.controls.VideoDisplay;
	import mx.core.FlexGlobals;
	import mx.core.Window;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	
	public class LocalVideoDisplay extends Window
	{
		/**
		 * Video Object to display the stream video.
		 */
		private var LocalVideo:Video;
		
		/**
		 * MediaServerConnection object for creating connection to FMIS.
		 */
		private var mediaServerConn:MediaServerConnection;
		
		/**
		 * NetStream object to create and play the user video stream.
		 */
		private var netStream:NetStream=null;
		
		/**
		 * Contains the streamName of current user.
		 */
		private var streamName:String;
		
		/**
		 * VideoDisplay Object to show the video stream.
		 */
		private var localVidDisplay:VideoDisplay;
		
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.video.native.LocalVideoDisplay.as");
		
		/**
		 * ToolTip text for showing the window tooltip.
		 */
		private var toolTipText:String="If you face any audio video problems,\n closing this window may help";
		
		/** This function will initialize the application with creating Objects and adding the
		 * event listeners
		 *
		 * @param
		 * @return void
		 */
		
		public function LocalVideoDisplay():void
		{
			//START--------------------------------------------------------------------------------
			//create an object of Video class with width and height as 208 and 140
			//then set the visibility value to true
			//END----------------------------------------------------------------------------------
			LocalVideo=new Video(208, 140);
			LocalVideo.visible=true;
			//START--------------------------------------------------------------------------------
			//create an object for VideoDisplay called localVidDisplay. Then set height,width 
			//properites to it. Add the video object to this video display object. Set the 
			//visibility to true and then also set the live parameter to true.
			//END----------------------------------------------------------------------------------
			localVidDisplay=new VideoDisplay();
			localVidDisplay.width=210;
			localVidDisplay.height=140;
			localVidDisplay.live=true;
			localVidDisplay.addChild(LocalVideo);
			localVidDisplay.visible=true;
			//START--------------------------------------------------------------------------------
			//create the window class and set the height,width for the window.Make it non-resizable
			//and out a title for the window. Set a tooltoip for the window and also add the video 
			//display object to this window.
			//END----------------------------------------------------------------------------------
			this.width=localVidDisplay.width;
			this.height=localVidDisplay.height + 20;
			this.resizable=false;
			this.maximizable=false;
			this.title="My Video - AVC";
			this.addChild(localVidDisplay);
			this.toolTip=toolTipText;
			//Event listener for handlingv window close event. 
			this.addEventListener(Event.CLOSE, closeEventHandler);
		}
		
		/** This function will set the netconnection for the window instance.
		 * <br> This is being called from modules where video encoding and streaming occures<br>
		 *
		 * @param  mediaServerConnection MediaServerConnection Object, connectionURL String, userName String
		 * @return void
		 */
		public function setMediaServerConnection(mediaServerConnection:MediaServerConnection, streamname:String):void
		{
			//START--------------------------------------------------------------------------------
			//set the netconnection object so that it can reuse the already existing netconnection.
			//Here the netconnection in use is the once created in the Video_ScriptCode.as.Also the
			//URL and user's stream name is also taken and initialised here.
			//END----------------------------------------------------------------------------------
			mediaServerConn=mediaServerConnection;
			streamName=streamname;
			//call the playStream function
			playStream();
		
		}
		
		/** playStream function will be used to create the netstream based on the netconnetion
		 *  and then it will playback the current user's stream from the server.
		 *
		 * @param
		 * @return void
		 */
		private function playStream():void
		{
			//START--------------------------------------------------------------------------------
			//create a netStream object and then set the client and metadata properties to it.
			//attache the netsrtream to previously creeated video object and then play the stream
			//by passing the current user's stream name. To avoid echo while preview is showm 
			//stop receiving audio stream from server.
			//END----------------------------------------------------------------------------------
			netStream=new NetStream(mediaServerConn.netConnection);
			netStream.client=new Object();
			netStream.client.onMetaData=ns_onMetaData;
			LocalVideo.attachNetStream(netStream);
			//netStream.bufferTime=0.1;
			netStream.play(streamName);
			netStream.receiveAudio(false);
		}
		
		/** Event handler for window close event.
		 */
		public function closeEventHandler(event:Event):void
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoON=false;
			this.removeAllChildren();
			this.close();
		}
		
		/**
		 *Dummy handler for onMetaData event.
		 */
		private function ns_onMetaData(item:Object):void
		{
			if(Log.isDebug()) log.debug("metaData");
		}
	
	
	}
}
