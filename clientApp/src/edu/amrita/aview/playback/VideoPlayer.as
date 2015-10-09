
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
 * File			: VideoPlayer.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)	: Remya T
 *
 * VideoPlayer Class is a extended class of EventDispatcher. This Class may
 * Contain all the information about the current video
 *
 */
package edu.amrita.aview.playback{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import mx.core.mx_internal;
	use namespace mx_internal;
	import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
	import edu.amrita.aview.playback.components.VideoComp;
	import edu.amrita.aview.playback.events.AviewPlayerEvent;
	import mx.controls.VideoDisplay;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.containers.TitleWindow;
	applicationType::desktop{
		import edu.amrita.aview.playback.components.FullScreenComp;
	}
	import edu.amrita.aview.common.service.MediaServerConnection;
	import flash.utils.setTimeout;
	
	public class VideoPlayer extends EventDispatcher{		
		[Bindable]
		/**
		 * For refers video path of Player
		 */
		public static var videoPath:String;
		/**
		 * For refers the MediaServerConnection class
		 * @defalut is null
		 */
		public static var netConnectionVideo:MediaServerConnection=null;
		/**
		 * For refers the ConsolidateXmlBuilder class for consolidate the xml data
		 */
		public static var consolidateXmlBuilder:ConsolidateXmlBuilder;
		/**
		 * For refers the FileLoaderManager class
		 */
		public static var fileLoaderManager:FileLoaderManager;
		/**
		 * For refers the ContextSetter class
		 */
		public static var contextSetter:ContextSetter;
		
		/**
		 * For refers the NetStream class
		 */
		public var netStreamVideo:NetStream;
		/**
		 *  For to check whether the stream is ready or not
		 *  @default false means Stream is not ready
		 */
		public var isStreamReady:Boolean=false;
		/**
		 *  For to check whether the video loaded or not
		 *  @default false means video is not loaded
		 */
		public var isVideoLoaded:Boolean=false;
		/**
		 *  For to check whether the timer is running or not
		 *  @default false means timer  is not running
		 */
		public var timerRun:Boolean=false;
		/**
		 *  For to check whether the video toggled to array or not
		 *  @default false means video toggled not in to array
		 */
		public var videoToggled:Boolean=false;
		/**
		 * For to check whether the player status in pause or not
		 *  @default false means timer  is not running
		 */
		public var pausedCheck:Boolean=false;
		/**
		 * For to check whether the video seek  is happen automatically or not
		 * @default false means video seek  is happen not automatically
		 */
		public var isVideoSeekedAutomatically:Boolean=false;
		/**
		 * For to check whether the the video seek  is happen manually or not
		 * @default false means  video seek  is happen  not manually
		 */
		public var isVideoSeekedManually:Boolean=false;
		/**
		 *  For to check whether the seek value  is set in to zero or not
		 *  @default false means seek value  is not set in to zero
		 */
		public var isSeekValueSetZero:Boolean=false;
		
		private var isVideoEndTime:Boolean = false;
		private var waitBufferCount:int = 0;
		
		/**
		 * End time of Current video
		 */
		public var currentVideoEndTime:Number=0;
		/**
		 * Preivous starting time
		 */
		public var previousStime:Number=0
		/**
		 * Previous End time
		 */
		public var previousEtime:Number=0
		/**
		 * Current video source path
		 */
		public var currentVideoSource:String;
		/**
		 * Current video start time
		 */
		public var currVideoStartTime:Number;
		/**
		 * For refers VideoDisply class
		 */
		public var videoComp:VideoDisplay;
		
		/**
		 * Seek value of Video player
		 */
		public var videoSeekValue:int;
		
		//private variables
		/**
		 * Check whether the stream of a video complete or not
		 * @default false means not completed
		 */
		private var streamPlayComplete:Boolean=false;
		/**
		 * Duration of current video
		 */
		private var currentVideoDuration:Number
		/**
		 * Object for netstream connection
		 */
		private var netStreamClient:Object=new Object();
		/**
		 * Refers for Loger class for loging the current activity
		 */
		private var log:ILogger
		
		/**Platform specific variables*/
		applicationType::web{
			/**
			 * For refers DesktopPlayback class
			 */
			private var desktopVideoComp:DesktopPlayback;
		}
		applicationType::desktop{
			/**
			 * For refers DesktopPlaybackWindow class
			 */			
			private var desktopVideoComp:DesktopPlaybackWindow;
		}
		
		applicationType::web{
			/**
			 * @Public
			 * Here we set all data for video play back
			 * @param netConnection of type MediaServerConnection
			 * @param vPath of type String
			 * @param consoXmlBuilder of type ConsolidateXmlBuilder
			 * @param contextSettr of type ContextSetter
			 * @param fileManager of type FileLoaderManager
			 * @param videoComp of type VideoDisplay
			 * @param desktopVideoComp of type DesktopPlaybackWindow
			 * @param isLocalPlayback of type Boolean
			 * @return void
			 */
			public function setValues(netConnection:MediaServerConnection, vPath:String, consoXmlBuilder:ConsolidateXmlBuilder, contextSettr:ContextSetter, fileManager:FileLoaderManager, videoComp:VideoDisplay, desktopVideoComp:DesktopPlayback=null, isLocalPlayback:Boolean=false):void{
				netConnectionVideo=netConnection;
				videoPath=vPath;
				consolidateXmlBuilder=consoXmlBuilder;
				fileLoaderManager=fileManager;
				contextSetter=contextSettr;
				if (desktopVideoComp == null)
					this.videoComp=videoComp
				else
					this.desktopVideoComp=desktopVideoComp;
				log=Log.getLogger("aview.edu.amrita.aview.playback.VideoPlayer");
			}
		}
		applicationType::desktop{
			/**
			 * @Public
			 * Here we set all data for video play back
			 * @param netConnection of type MediaServerConnection
			 * @param vPath of type String
			 * @param consoXmlBuilder of type ConsolidateXmlBuilder
			 * @param contextSettr of type ContextSetter
			 * @param fileManager of type FileLoaderManager
			 * @param videoComp of type VideoDisplay
			 * @param desktopVideoComp of  type DesktopPlaybackWindow
			 * @param isLocalPlayback of type Boolean
			 * @return void
			 */
			public function setValues(netConnection:MediaServerConnection, vPath:String, consoXmlBuilder:ConsolidateXmlBuilder, contextSettr:ContextSetter, fileManager:FileLoaderManager, videoComp:VideoDisplay, desktopVideoComp:DesktopPlaybackWindow=null, isLocalPlayback:Boolean=false):void{
				netConnectionVideo=netConnection;
				videoPath=vPath;
				consolidateXmlBuilder=consoXmlBuilder;
				fileLoaderManager=fileManager;
				contextSetter=contextSettr;
				if (desktopVideoComp == null)
					this.videoComp=videoComp
				else
					this.desktopVideoComp=desktopVideoComp;
				log=Log.getLogger("aview.edu.amrita.aview.playback.VideoPlayer");
			}
		}
		
		/**
		 * @public
		 * This Function will handling the video component change while playback
		 * session
		 *
		 * @param newVideoComp of type Object
		 * @param newToolTip of type String
		 * @return void
		 */
		public function changeVideoComp(newVideoComp:Object, newToolTip:String):void{
			this.videoComp.mx_internal::videoPlayer.clear();
			this.videoComp.toolTip="";
			this.videoComp=newVideoComp as VideoDisplay;
			this.videoComp.toolTip=newToolTip;
			videoComp.mx_internal::videoPlayer.attachNetStream(netStreamVideo);
		}
		
		
		/**
		 * @public
		 * This function is used to handling the connection to  Video server
		 * @return void
		 *
		 */
		public function connectToVod():void{
			netStreamVideo=new NetStream(netConnectionVideo.netConnection);
			netStreamVideo.client=netStreamClient;
			netStreamClient.onPlayStatus=onPlayStatusHandler;
			netStreamClient.onMetaData=onMetaDataHandler;
			netStreamVideo.bufferTime=15;
			if (desktopVideoComp == null){
				videoComp.mx_internal::videoPlayer.attachNetStream(netStreamVideo);
				videoComp.mx_internal::videoPlayer.visible=true;
			}
			else{
				applicationType::web{
					desktopVideoComp.videoDisp.mx_internal::videoPlayer.attachNetStream(netStreamVideo);
					desktopVideoComp.videoDisp.mx_internal::videoPlayer.visible=true;
				}
				applicationType::desktop{
					desktopVideoComp.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.attachNetStream(netStreamVideo);
					desktopVideoComp.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.visible=true;
				}
			}
			netStreamVideo.addEventListener(NetStatusEvent.NET_STATUS, streamHandler);
		}
		
		/**
		 * @private
		 * This function is used for Handling the metadata of video		 *
		 * @param info of type Object
		 * @return void
		 */
		private function onMetaDataHandler(info:Object):void{
			currentVideoDuration=info.duration;
		}
		
		/**
		 * @private
		 * This function is used for Handling the status of play
		 *
		 * @param info of type Object
		 * @return void
		 */
		private function onPlayStatusHandler(info:Object):void{
			if (Log.isInfo()) log.info("In onPlayStatusHandler- Status:-" + info.code);
			if (info.code == "NetStream.Play.Complete"){
				currentVideoSource="";
				previousEtime=0;
				previousStime=0;
				streamPlayComplete=true;
				isVideoLoaded=false;
				isStreamReady=false
				dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_PLAY_COPMLETE));
			}
		}
		
		/**
		 * @private
		 * This is the function handling the stream of VideoDisplay
		 * this is the handler for NetStatusEvent
		 *
		 * @param evnt of NetStatusEvent
		 * @return void
		 */
		private function streamHandler(evnt:NetStatusEvent):void{
			if (Log.isInfo()) log.info("In streamHandler- Status:-" + evnt.info.code);			
			if (evnt.info.code == "NetStream.Buffer.Full" || evnt.info.code == "NetStream.Play.Start"){
				isVideoLoaded=true;
				if(netStreamVideo.bufferLength>1)
					dispatchStreamReady()
				else
				{
					setTimeout(waitForBuffering,500);
				}
			}			
			if (evnt.info.code == "NetStream.Buffer.Empty"){
				dispatchStreamNotReady();
			}
		}		
		
		private function waitForBuffering():void
		{
			waitBufferCount++;
			//The below pause and play for keep the buffer filling.
			netStreamVideo.pause();
			netStreamVideo.resume();
			if(netStreamVideo.bufferLength>1)
			{
				if(Log.isInfo()) log.info("In waitForBuffering- Dtream ready :Source-" +netStreamVideo.info.resourceName);
				//netStreamVideo.pause();
				dispatchStreamReady()
			}
			else
			{
				if(waitBufferCount == 10 && isVideoEndTime)
				{
					isVideoLoaded = true;
					dispatchStreamReady();
				}
				else
				{
					if(Log.isInfo()) log.info("In waitForBuffering- Dtream NOT ready :Source-" +netStreamVideo.info.resourceName);
					netStreamVideo.pause();
					setTimeout(waitForBuffering,500);
				}
			}
			
		}
		
		/**
		 * @private
		 * For dispatching Event type STREAM_NOT_READY of AviewPlayerEvent		 *
		 * @return void
		 */
		private function dispatchStreamNotReady():void{
			netStreamVideo.bufferTime=10;
			if (!streamPlayComplete && netStreamVideo.time - 1 <= currentVideoDuration){
				isStreamReady=false;
				dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_NOT_READY));
			}
			else{
				streamPlayComplete=false;
			}
		}
		
		
		/**
		 * @private
		 * For dispatching Event type STREAM_READY of AviewPlayerEvent		 *
		 * @return void
		 *
		 */
		private function dispatchStreamReady():void{
			isVideoEndTime = false;
			waitBufferCount = 0;
			isStreamReady=true;
			netStreamVideo.bufferTime=15;
			dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_READY));
		}
		
		/**
		 * @public
		 * This function is used to handling the playing functionality of video play back		 *
		 * @param time of Numeber
		 * @param module of String
		 * @return void
		 */
		
		//VVCR: function name can more clear by renaming it as playVideo instead of playVid		
		public function playVid(time:Number, module:String):void{
			if (time > 0 && (time / 1000) == Math.ceil((currentVideoEndTime) / 1000)) { 
				// && viewerVideoPly) 
				currentVideoEndTime=0;
				netStreamVideo.close();
				if (desktopVideoComp == null){
					videoComp.mx_internal::videoPlayer.clear();					
				}
				else{
					applicationType::web{
						desktopVideoComp.videoDisp.mx_internal::videoPlayer.clear();
					}
					applicationType::desktop{
						desktopVideoComp.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
					}
				}
				isVideoLoaded=false;
				isStreamReady=false;
				dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_PLAY_COPMLETE));
			}
			
			var xml:XML=consolidateXmlBuilder.getDataAtTime(time, module);
			
			for each (var evnt:XML in xml.elements()){
				timerRun=true;				
				netStreamVideo.close();
				if (desktopVideoComp == null)
					videoComp.mx_internal::videoPlayer.clear();
				else{
					applicationType::web{
						desktopVideoComp.videoDisp.mx_internal::videoPlayer.clear();
					}
					applicationType::desktop{
						desktopVideoComp.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
					}
				}
				currentVideoEndTime=int(evnt.@etime);
				if (evnt.@isAudioOnly == "true" && Number(evnt.@fileSize) <= 0)
					return;
				netStreamVideo.bufferTime=10;
				
				currentVideoSource=evnt.@src;
				previousEtime=evnt.@etime;
				previousStime=evnt.@stime;
				isVideoLoaded=true;
				var videoSrcEdit:String=evnt.@src;
				var fileExtension:String=videoSrcEdit.substring((videoSrcEdit.length - 3), videoSrcEdit.length);
				if (fileExtension != "flv")
					netStreamVideo.play("mp4:" + videoPath + evnt.@src, 0, -1);
				else if (fileExtension == "flv")
					netStreamVideo.play(videoPath + videoSrcEdit.substring(0, (videoSrcEdit.length - 4)));
				
				currVideoStartTime=time / 1000;
				if (evnt.@seekExist == "true"){
					isVideoSeekedAutomatically=true;
					videoSeekValue=int(evnt.@seekTime);
					netStreamVideo.seek(int(evnt.@seekTime));
					currVideoStartTime=0;
				}
				else if (evnt.@seekTime != -1){
					isSeekValueSetZero=true;
				}
				applicationType::desktop{					
					if (module == "desktop")
						desktopVideoComp.activate();
				}
			}
			
		}
		
		/**
		 * @public
		 * This function is used to set the context data for video playback
		 *
		 * @param playHeadTime of type Number
		 * @param seekValue of type Number
		 * @param module of type String
		 * @param videoDisp of type VideoDisplay
		 * @return void
		 */
		public function setContext(playHeadTime:Number, seekValue:Number, module:String, videoDisp:VideoDisplay):void{
			var xml:XML;
			isVideoEndTime = false;
			waitBufferCount = 0;
			if (module == "pVideo"){
				xml=contextSetter.getPresenterVideoContext(playHeadTime);
			}
			else if (module == "desktop"){
				xml=contextSetter.getDesktopVideoContext(playHeadTime);
			}
			else{
				xml=contextSetter.getViewerVideoContext(playHeadTime);
			}
			if (xml.elements() != null && xml != ""){
				var videoStartTime:Number;
				var currentVideoPlayStartTime:Number;
				var videoSource:String;
				for each (var evnt:XML in xml.elements()){
					videoStartTime=parseFloat(evnt.@stime) / 1000;
					currVideoStartTime=videoStartTime;
					currentVideoEndTime=int(evnt.@etime);
					videoSource=evnt.@src;	
					if(currentVideoEndTime - playHeadTime <= 6000)
						isVideoEndTime = true;
					if (evnt.@isAudioOnly == "true" && Number(evnt.@fileSize) <= 0)
						return;
				}
				currentVideoPlayStartTime=seekValue - videoStartTime;
				
				if (videoSource == currentVideoSource){
					timerRun=false;
					isVideoLoaded=true;
					isStreamReady=false;
					if (evnt.hasOwnProperty("@seekStartValue") && seekValue + 1 > evnt.@seekStartValue){
						currentVideoPlayStartTime=currentVideoPlayStartTime + int(evnt.@seekTime); //;- int(evnt.@seekStartValue));
						isVideoSeekedManually=true;
						videoSeekValue=int(evnt.@seekTime) - int(evnt.@seekStartValue);
						if (videoSeekValue < 0)
							videoSeekValue=videoSeekValue * -1;
						if (previousEtime == evnt.@etime && previousStime == evnt.@stime)
							currVideoStartTime=0;
					}
					else{
						isSeekValueSetZero=true;
					}
					netStreamVideo.seek(currentVideoPlayStartTime);
					if (pausedCheck){
						netStreamVideo.pause();
						videoToggled=true;
					}
				}
				else{
					if (evnt.hasOwnProperty("@seekStartValue") && seekValue > evnt.@seekStartValue){
						isVideoSeekedManually=true;
						videoSeekValue=int(evnt.@seekTime) - int(evnt.@seekStartValue);
						
					}
					else{
						isSeekValueSetZero=true;
					}
					timerRun=true;
					netStreamVideo.close();
					videoDisp.mx_internal::videoPlayer.clear();
					netStreamVideo.bufferTime=15;
					var videoSrcEdit:String=evnt.@src;
					var fileExtension:String=videoSrcEdit.substring((videoSrcEdit.length - 3), videoSrcEdit.length);
					if (fileExtension != "flv")
						netStreamVideo.play("mp4:" + videoPath + videoSrcEdit, 0, -1);
					else if (fileExtension == "flv")
						netStreamVideo.play(videoPath + videoSrcEdit.substring(0, (videoSrcEdit.length - 4)));
					isVideoLoaded=true;
					isStreamReady=false;
					currentVideoSource=videoSource;
					previousEtime=evnt.@etime;
					previousStime=evnt.@stime;
					netStreamVideo.seek(currentVideoPlayStartTime);
					videoToggled=false;
				}
			}
			else{
				previousEtime=0;
				previousStime=0;
				currentVideoSource="";
				timerRun=false;
				isVideoLoaded=false;
				isStreamReady=false;
				netStreamVideo.close();
				currentVideoEndTime=0;
				videoDisp.mx_internal::videoPlayer.clear();
				videoToggled=false;
			}
			if (xml == ""){
				previousEtime=0;
				previousStime=0;
				currentVideoSource="";
				videoToggled=false;
				currentVideoEndTime=0;
				timerRun=false;
				isVideoLoaded=false;
				isStreamReady=false;
				netStreamVideo.close();
				videoDisp.mx_internal::videoPlayer.clear();
				
			}
			if (module != "pVideo")
				dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_SEEK));
		}
		
		/**
		 * @public
		 * For seek the stream of video
		 *
		 * @param seekValue of type Number
		 * @return void
		 */
		public function seekStream(seekValue:Number):void{
			netStreamVideo.seek(seekValue);
		}
		
		/**
		 * @public
		 * This function is used to handling the video seek to particular time
		 *
		 * @param videoTag of type XML
		 * @param seekValue of type Number
		 * @return void
		 */
		public function loadAndSeekStream(videoTag:XML, seekValue:Number):void{
			timerRun=true;
			netStreamVideo.close();
			videoComp.mx_internal::videoPlayer.clear();
			netStreamVideo.bufferTime=15;
			var videoSrcEdit:String=videoTag.@src;
			var fileExtension:String=videoSrcEdit.substring((videoSrcEdit.length - 3), videoSrcEdit.length);
			if (fileExtension != "flv")
				netStreamVideo.play("mp4:" + videoPath + videoSrcEdit, 0, -1);				
			else if (fileExtension == "flv")
				netStreamVideo.play(videoPath + videoSrcEdit.substring(0, (videoSrcEdit.length - 4)));
			isVideoLoaded=true;
			isStreamReady=false;
			currentVideoSource=videoTag.@src;
			previousEtime=videoTag.@etime;
			previousStime=videoTag.@stime;
			netStreamVideo.seek(seekValue);
			videoToggled=false;
		}
		
		
		/**
		 * @public
		 * This function is used to clearing the video details from the player		 *
		 * @return void
		 */
		public function clearVideo():void{
			if (videoComp){
				videoComp.toolTip="";
				videoComp.mx_internal::videoPlayer.clear();
				videoComp.mx_internal::videoPlayer.attachNetStream(null);
			}
			if (netStreamVideo){
				netStreamVideo.close();
				netStreamVideo=null;
			}
		}
		
		/**
		 * @public
		 * Invoking this function while the player has been stop
		 *
		 * @return void
		 */
		public function stopVideoPlayer():void{
			currentVideoEndTime=0;
			clearVideo();
			if (netConnectionVideo){
				netConnectionVideo.close();
				netConnectionVideo=null;
			}
		}
	}
}
