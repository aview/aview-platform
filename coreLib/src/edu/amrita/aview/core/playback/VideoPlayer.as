package edu.amrita.aview.core.playback
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.mx_internal;
	use namespace mx_internal;
	import mx.controls.VideoDisplay;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.containers.TitleWindow;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import edu.amrita.aview.core.common.FileLoaderManager;
	import edu.amrita.aview.core.playback.components.VideoComp;
	import edu.amrita.aview.core.gclm.vo.ServerVO;
	import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
	
	import edu.amrita.aview.core.gclm.GCLMContext;

		public class VideoPlayer extends EventDispatcher
		{
			public function VideoPlayer():void
			{
				
			}
			//public static variables
			[Bindable]
			public static var videoPath:String;
			public static var netConnectionVideo:NetConnection=null;
			public static var consolidateXmlBuilder:ConsolidateXmlBuilder;
			public static var fileLoaderManager:FileLoaderManager;
			public static var contextSetter:ContextSetter;
			//public variables
			public var netStreamVideo:NetStream;
			public var isStreamReady:Boolean=false;
			public var isVideoLoaded:Boolean=false;		
		    public var timerRun:Boolean=false;
            public var videoToggled:Boolean=false;
		    public var pausedCheck:Boolean=false;
			public var currentVideoEndTime:Number=0;
			public var currentVideoSource:String;
			public var currVideoStartTime:Number;
			//private variables
			private var videoComp:VideoComp;
			private var streamPlayComplere:Boolean=false;
			private var currentVideoDuration:Number
			private var netStreamClient:Object=new Object();
			private var serverCategory:String;
			
			public var slide:int;
			public var videoSeekValue:int;
			public var sliderValue:int;
			public var isVideoSeekedAutomatically:Boolean = false;
			public var isVideoSeekedManually:Boolean = false;
			public var isSeekValueSetZero:Boolean = false;
			private var isVideoEndTime:Boolean = false;
			private var waitBufferCount:int = 0;
			
			private function getServerCategory(serverIp:String):String
			{
				for each (var serverVO:ServerVO in GCLMContext.serversAC)
				{
					if (serverVO.serverIp == serverIp)
					{
						return serverVO.serverCategory;
					}
				}
				return null;
			}
			
		    public function setValues(netConnection:NetConnection,vPath:String,consoXmlBuilder:ConsolidateXmlBuilder,
		    	contextSettr:ContextSetter,fileManager:edu.amrita.aview.core.common.FileLoaderManager,videoComp:VideoComp):void
		    {
				netConnectionVideo=netConnection;
		      	videoPath=vPath;
		      	consolidateXmlBuilder=consoXmlBuilder;
		      	fileLoaderManager=fileManager;
		      	contextSetter=contextSettr;
		      	this.videoComp=videoComp;
				//start of bug fix #7718 for red5 server
				//set the server category to identify if the playback streaming server is red5 or fms
				//this is necessary for setting the buffer-time.
				var url:String = netConnection.uri;
				//the url can either contain a port specified in it or not
				//rtmp://serverIp:port/vod or rtmp://serverIp/vod
				var startIndex:int = url.indexOf("//");
				var endIndex:int = url.indexOf(":",startIndex);
				if (endIndex == -1)
				{
					endIndex = url.indexOf("/",startIndex+3);
				}
				var serverIp:String =  url.substring(startIndex+2, endIndex);
				serverCategory = getServerCategory(serverIp);
				//end of bug fix #7718 for red5 server
				log=Log.getLogger("aview.modules.RecordingPlayback.Playback.VideoPlayer");
		    }
			
			//start of bug fix #7718 for red5 server
			private function setBufferTime(bufferTime:int):void
			{
				//do not the buffer time if it is red5 server.
				//setting bufferTime is causing delay in red5.
				//if (serverCategory != "RED5-LIN" && serverCategory != "RED5-WIN")
				if (serverCategory!=null && serverCategory.indexOf("FMS") != -1)
				{
					netStreamVideo.bufferTime = bufferTime;
				}
			}
			//end of bug fix #7718 for red5 server
			
			public function connectToVod():void
			{	
				netStreamVideo= new NetStream(netConnectionVideo);
				netStreamVideo.client=netStreamClient;
				netStreamClient.onPlayStatus=onPlayStatusHandler;
				netStreamClient.onMetaData=onMetaDataHandler;
				//netStreamVideo.bufferTime=15;
				setBufferTime(15);
				videoComp.videoDisp.mx_internal::videoPlayer.attachNetStream(netStreamVideo);            		
				videoComp.videoDisp.mx_internal::videoPlayer.visible = true;  
				netStreamVideo.addEventListener(NetStatusEvent.NET_STATUS, streamHandler);
				
			}
			private function onMetaDataHandler(info:Object):void
			{
				currentVideoDuration=info.duration ;
				log.info("onMetaDataHandler:currentVideoDuration: " + currentVideoDuration);
			}
			private var log:ILogger
			private function onPlayStatusHandler(info:Object):void
			{
				if(Log.isInfo()) log.info("In onPlayStatusHandler- Status:-"+info.code + ",netStreamVideo.time:" + netStreamVideo.time);
				if(info.code=="NetStream.Play.Complete")
				{   currentVideoSource="";
					streamPlayComplere=true;
					isVideoLoaded=false;
					isStreamReady=false
					dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_PLAY_COPMLETE));
					videoComp.showOrHideBuffering(false);
				}
			}
			private function onVideoConnectError(ncObj:Event) :void
			{
					
			}
			private var timeOutInterval:uint;
			private function waitForBuffering():void
			{
				waitBufferCount++;
				clearTimeout(timeOutInterval);
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
						timeOutInterval= setTimeout(waitForBuffering,500);
					}
				}
				
			}
			private function streamHandler(evnt:NetStatusEvent):void
			{
				if(Log.isInfo()) log.info("In streamHandler- :Source-" +netStreamVideo.info.resourceName+" Status:-"+evnt.info.code);
				if(evnt.info.code=="NetStream.Buffer.Full")
				{	
					if(netStreamVideo.info.resourceName!=null)
					{
						isVideoLoaded=true;
						videoComp.showOrHideBuffering(false);
						// some times buffer full event is calling with zero buffer length
						if(netStreamVideo.bufferLength>1)
							dispatchStreamReady()
						else
						{
							clearTimeout(timeOutInterval);
							timeOutInterval= setTimeout(waitForBuffering,500);
							
						}
						log.info("streamHandler:NetStream.Buffer.Full:Source-" +netStreamVideo.info.resourceName
							+"netStreamVideo.bufferLength:-"+netStreamVideo.bufferLength+"netStreamVideo.bufferTime:-"+netStreamVideo.bufferTime);
					}
				}
				if(evnt.info.code=="NetStream.Play.Start")
				{
					if(netStreamVideo.info.resourceName!=null)
					{
						isVideoLoaded=true;
						videoComp.showOrHideBuffering(false);
						if(netStreamVideo.bufferLength>1)
							dispatchStreamReady()
						else
						{
							clearTimeout(timeOutInterval);
							timeOutInterval= setTimeout(waitForBuffering,500);
						}
						log.info("streamHandler:NetStream.play.Start:Source-" +netStreamVideo.info.resourceName
							+"netStreamVideo.bufferLength:-"+netStreamVideo.bufferLength+"netStreamVideo.bufferTime:-"+netStreamVideo.bufferTime);
					}
				}
				if(evnt.info.code=="NetStream.Buffer.Empty")
				{
					dispatchStreamNotReady()
					videoComp.showOrHideBuffering(true);
				}
				if(evnt.info.code=="NetStream.Play.Stop")
				{
					log.info("streamHandler:NetStream.play.stop:netStreamVideo.time:" + netStreamVideo.time);
				}
				if(evnt.info.code=="NetStream.Buffer.Flush")
				{
					log.info("streamHandler:NetStream.play.flush:netStreamVideo.time:" + netStreamVideo.time);
				}
				
			}
            private function dispatchStreamNotReady():void
			{
				//netStreamVideo.bufferTime=10
				log.info("dispatchStreamNotReady:streamPlayComplere: " + streamPlayComplere +", currentVideoDuration: " + currentVideoDuration);
				setBufferTime(10);
				if(!streamPlayComplere && netStreamVideo.time-1<=currentVideoDuration)
				{
					log.info("dispatchStreamNotReady:dispatching STREAM_NOT_READY event.");
					isStreamReady=false;
					dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_NOT_READY));
				}
				else
				{
					streamPlayComplere=false;
				}
			}
			private function dispatchStreamReady():void
			{
				isVideoEndTime = false;
				waitBufferCount = 0;
				isStreamReady=true;
				//netStreamVideo.bufferTime=15;
				setBufferTime(15);
				dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_READY));
			}
			private function dispatchStreamComplete():void
			{
				videoComp.showOrHideBuffering(false);
				currentVideoEndTime=0;					       
				netStreamVideo.close()
				videoComp.videoDisp.mx_internal::videoPlayer.clear();
				clearVideoTitle();
				isVideoLoaded=false;
				isStreamReady=false;
				dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_PLAY_COPMLETE));
				videoComp.lblVideoMode.visible=false;
			}
			public function playVid(time:Number,module:String):void
			{
				if(time>0 && (time/1000)==Math.ceil((currentVideoEndTime)/1000))// && viewerVideoPly) 
				{ 
					dispatchStreamComplete();
			    }
				
				var xml:XML=consolidateXmlBuilder.getDataAtTime(time,module);
				
				for each(var evnt:XML in xml.elements())
				{
					 timerRun=true;
					
					 if(evnt.@isAudioOnly == "true")
					 {
						 videoComp.lblVideoMode.visible=true;
					 }
					 else
					 {
						 videoComp.lblVideoMode.visible=false;
					 }
					 //Fix for issue #19680
					 addVideoTitle(evnt.@displyname);
					 netStreamVideo.close();
					 videoComp.videoDisp.mx_internal::videoPlayer.clear();
					 if(evnt.@isAudioOnly == "true" && Number(evnt.@fileSize) <= 0)
						 return;
					 //netStreamVideo.bufferTime=10;
					 setBufferTime(10);
			    	 currentVideoEndTime=int(evnt.@etime);
			    	 currentVideoSource=evnt.@src;
			    	 isVideoLoaded=true;
					 var videoSrcEdit:String=evnt.@src;
					 var fileExtension:String=videoSrcEdit.substring((videoSrcEdit.length-3),videoSrcEdit.length)
					 if(fileExtension!="flv")
						 netStreamVideo.play("mp4:"+videoPath+evnt.@src,0,-1);
					 else if(fileExtension=="flv") 
						 netStreamVideo.play(videoPath+videoSrcEdit.substring(0,(videoSrcEdit.length-4))); 
					 //netStreamVideo.play(videoPath+evnt.@src);
					 currVideoStartTime=time/1000;
					 if(evnt.@seekExist=="true")
					 {
						 isVideoSeekedAutomatically = true;
						 videoSeekValue = int(evnt.@seekTime);
						 netStreamVideo.seek(int(evnt.@seekTime));
						 currVideoStartTime = 0;
					 }
					 else if(evnt.@seekTime!=-1)
					 {
						 isSeekValueSetZero = true;
					 }
				 }

			} 
			
			public function setContext(playHeadTime:Number,seekValue:Number,module:String,videoDisp:VideoDisplay):void
			{
				var xml:XML;
				isVideoEndTime = false;
				waitBufferCount = 0;
				if(module=="pVideo")
				{
					xml=contextSetter.getPresenterVideoContext(playHeadTime);
				}
				else
				{
					xml=contextSetter.getViewerVideoContext(playHeadTime);
				}
				if(xml.elements()!=null && xml!="")
				{   					
					var videoStartTime:Number;
					var currentVideoPlayStartTime:Number;
					var videoSource:String;
					for each(var evnt:XML in xml.elements())
					{
						videoStartTime=parseFloat(evnt.@stime)/1000;
						currVideoStartTime=videoStartTime;
						currentVideoEndTime=int(evnt.@etime);
						videoSource=evnt.@src;
						if(currentVideoEndTime - playHeadTime <= 6000)
							isVideoEndTime = true;
						//Fix for issue #19680
						addVideoTitle(evnt.@displyname);
						if(evnt.@isAudioOnly == "true")
						{
							videoComp.lblVideoMode.visible=true;
						}
						else
						{
							videoComp.lblVideoMode.visible=false;
						}
						if(evnt.@isAudioOnly == "true" && Number(evnt.@fileSize) <= 0)
							return;
					}
					currentVideoPlayStartTime = seekValue - videoStartTime;
						
						if(videoSource==currentVideoSource)
						{  
					   		timerRun=false;
					   		isVideoLoaded=true;
					   		isStreamReady=false;
							if(evnt.hasOwnProperty("@seekStartValue") && seekValue + 1 > evnt.@seekStartValue)
							{
								currentVideoPlayStartTime = currentVideoPlayStartTime + int(evnt.@seekTime) //;- int(evnt.@seekStartValue));
								isVideoSeekedManually = true;
								videoSeekValue = int(evnt.@seekTime) - int(evnt.@seekStartValue);
								if(videoSeekValue<0)
									videoSeekValue = videoSeekValue * -1;
								currVideoStartTime = 0;
							}
							else
							{
								isSeekValueSetZero = true;
							}
							netStreamVideo.seek(currentVideoPlayStartTime);						
							if(pausedCheck)
							{   							
								netStreamVideo.pause();
								videoToggled=true;
							}
					}
					else
					{
						if(evnt.hasOwnProperty("@seekStartValue") && seekValue > evnt.@seekStartValue)
						{
							isVideoSeekedAutomatically = true;
							videoSeekValue = int(evnt.@seekTime) - int(evnt.@seekStartValue);
							//currVideoStartTime = 0;
						}
						else
						{
							isSeekValueSetZero = true;
						}
						timerRun=true;
						 netStreamVideo.close();
			    		 videoDisp.mx_internal::videoPlayer.clear();
			    		 //netStreamVideo.bufferTime=15;
						 setBufferTime(15);
						 var videoSrcEdit:String=evnt.@src;
						 var fileExtension:String=videoSrcEdit.substring((videoSrcEdit.length-3),videoSrcEdit.length)
						 if(fileExtension!="flv")
							 netStreamVideo.play("mp4:"+videoPath+videoSrcEdit,0,-1);
							// netStreamVideo.play("mp4:"+videoPath+evnt.@src); 
						 else if(fileExtension=="flv") 
							 netStreamVideo.play(videoPath+videoSrcEdit.substring(0,(videoSrcEdit.length-4))); 
			    		 isVideoLoaded=true;
			    		 isStreamReady=false;
			    		 currentVideoSource=videoSource;
			    		 netStreamVideo.seek(currentVideoPlayStartTime);
						 videoToggled=false;
					}
				}
				else
				{	
					currentVideoSource="";
					timerRun=false;
					videoToggled=false;
					dispatchStreamComplete();
					
				}
				if(xml=="")
				{	
					currentVideoSource="";
					timerRun=false;
					videoToggled=false;
					dispatchStreamComplete();
				}
				if(module!="pVideo")
				  dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.STREAM_SEEK));
			}
			private function clearVideoTitle():void
			{
				var tempTitle:String =  videoComp.document.title;
				videoComp.document.title = tempTitle.substr(0, (tempTitle.search("Video :")+7));
			}
			
			private function addVideoTitle(displayName:String):void
			{
				var tempTitle:String =  videoComp.document.title;
				videoComp.document.title = tempTitle.substr(0, (tempTitle.search("Video :")+7))+" "+ displayName;
				//Fix for issue #19680
				applicationType::desktop{
					import edu.amrita.aview.core.playback.components.FullScreenComp;
					if(videoComp.parent is FullScreenComp)
					{
						videoComp.parentDocument.title=videoComp.document.title
					}
				}
			}
			public function stopVideoPlayer():void
			{
				currentVideoEndTime=0;
				if(videoComp && videoComp.videoDisp)
				{
					videoComp.videoDisp.mx_internal::videoPlayer.clear();
					clearVideoTitle();
				}
				
				if(netStreamVideo)
				{
					netStreamVideo.close();
					netStreamVideo=null;
				}
				if(netConnectionVideo)
				{
					netConnectionVideo.close();
					netConnectionVideo=null;
				}
			}
			
			 public function onBWDone():void{
				//trace("onBWDone");
			   }

	}
}
