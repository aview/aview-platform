// ActionScript file
import edu.amrita.aview.core.common.Events.FileLoadedEvent;
import edu.amrita.aview.core.common.FMSPortTester;
import edu.amrita.aview.core.common.FileLoaderManager;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.playback.ConnectionComp;
import edu.amrita.aview.core.playback.ConsolidateXmlBuilder;
import edu.amrita.aview.core.playback.ContextSetter;
import edu.amrita.aview.core.playback.DocumentPointerPlayer;
import edu.amrita.aview.core.playback.PttPlayer;
import edu.amrita.aview.core.playback.WbPlayer;
import edu.amrita.aview.core.playback.WbPointerPlayer;
import edu.amrita.aview.core.playback.components.ChatComp;
import edu.amrita.aview.core.playback.components.DocComp;
import edu.amrita.aview.core.playback.components.VideoComp;
import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
import edu.amrita.aview.core.shared.audit.AuditContext;

import flash.display.DisplayObjectContainer;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.media.SoundTransform;
import flash.sampler.NewObjectSample;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.Label;
import mx.controls.sliderClasses.Slider;
import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.events.SliderEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
applicationType::desktop{
	import edu.amrita.aview.core.playback.components.FullScreenComp;
}

		private var log:ILogger
		public var chatWndw:ChatComp;
		public var wbPlayer:WbPlayer;
		public var presenterVid:VideoComp;
		public var viewerVid:VideoComp;
		private var wbPointerPlayer:WbPointerPlayer;
		private var pttPlayer:PttPlayer;
        private var docPointerPlayer:DocumentPointerPlayer;
		public var chatBool:Boolean=true;
		public var PresenterBool:Boolean=true;
		public var ViewerBool:Boolean=true;
		applicationType::desktop{
			public var fullScreenPresenter:FullScreenComp;
			public var fullScreenViewer:FullScreenComp;
			public var fullScreenChat:FullScreenComp;
		}
		
		public var fullScreenPresenterBool:Boolean=false;
		public var fullScreenViewerBool:Boolean=false;
		public var fullScreenChatBool:Boolean=false;
		//public var seek:seekbar;
		public var presenterFMSUrl:String;	
		private var presenterFmsConnection:ConnectionComp;
		private var viewerFmsConnection:ConnectionComp;
        [Bindable]
        public var STATE_ARRAY:Array = [{label:"Document", data:"1"},{label:"WhiteBoard", data:"2"}];
       
        private var consolidateXmlBuilder:ConsolidateXmlBuilder
        private var contextSetter:ContextSetter
        private var centalTimer:Timer;
        
        private var playerInitialized:Boolean=false;
       // private var wbSprite:ScratchArea
        public var fileLoaderManager:FileLoaderManager
        private var fullScreenPresenterSet:Boolean=false;
		private var fullScreenViewerSet:Boolean=false;
        [Bindable]
       // private var timeVariable:int=0;
        private var videoVolume:SoundTransform = new SoundTransform();
		private var diffSeekValuePresenter:int = 0;
		private var diffSeekValueViewer:int = 0;
         //This variable is used to checks whether the editing page is active or not.       
         public var editingActive:Boolean = false;
         private var pausedTimer:Boolean=false;
         private var whiteboardMask:Canvas;
		[Bindable]
         private var lectureTitle:String;
         private var playerUIInitialTimeOut:uint

		[Embed(source='/edu/amrita/aview/core/playback/assets/flash/playBackLoading.swf')]
		[Bindable]
		private var swfFile:Class;
        /**
        * It creates the different UI componnents such as Video componnents, chat componnents
        * etc
        */   
		private function init():void
		{ 
			createDocComp();
			createPresenterVideoComp();
			createViewerVideoComp();
			createChatComp();
			log=Log.getLogger("aview.modules.RecordingPlayback.Playback.Components.AviewPlayerComp");
			//createWbComp();
			playerUIInitialTimeOut=setTimeout(loadRecordedFiles,200);
        }

		private var timeOutId:uint
		public function playerResizeHandler(event:ResizeEvent):void
		{
			if(docComp && docComp.slidelist )
			{
				docComp.slidelist.executeBindings();
				if(docSlideIndex>-1)
				{
					timeOutId=setTimeout(setIndex,100);
				}
				
			}
		}
		private function setIndex():void
		{
			clearTimeout(timeOutId);;
			docComp.slidelist.scrollToIndex(docSlideIndex);
			docComp.slidelist.selectedIndex=docSlideIndex;
			
		
		}
        private function loadRecordedFiles():void
		{
			clearTimeout(playerUIInitialTimeOut);
			fileLoaderManager=new FileLoaderManager(contentUrl+contentFilePath)  
			fileLoaderManager.addEventListener(FileLoadedEvent.ALL_LOADED,onAllFilesLoaded);
			fileLoaderManager.addEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onFileLoadError);
			fileLoaderManager.loadRecordedFiles();   			
			tn.selectedIndex=1;
			
		}
        private function createPresenterVideoComp():void
        {
			presenterVid=new VideoComp();
       		presenterVid.width=presenter.width;
        	presenterVid.height=presenter.height;
			//Fix for issue #17071
			applicationType::desktop{
				presenterVid.x=presenter.x;
				presenterVid.y=presenter.y;
			}
			applicationType::web{
				//To assign presenterVid component minimunm width and minimunm height
				presenterVid.minHeight = presenter.height;
				presenterVid.minWidth = presenter.width;
				//Assign y value of presenterVid for UI alignment.
				presenterVid.x=presenter.x;
				presenterVid.y=FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+10;
				//Added resizeevent
				presenter.addEventListener(ResizeEvent.RESIZE,presenterResize);
			}
        	PopUpManager.addPopUp(presenterVid, presenter);
			presenterVid.title="Presenter Video :";
			presenterVid.muteButton.addEventListener(MouseEvent.CLICK,presenterVolume);
			presenterVid.volumeSeek.addEventListener(SliderEvent.CHANGE,controlVolume);
        	if(editingActive == false)
        	{    
				//Fix for issue #17616
				applicationType::web{
	            	presenterVid.doubleClickEnabled = false;
				}
	            presenterVid.addEventListener(CloseEvent.CLOSE,closePresenterWndw); 
	            presenterVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK,presenterVideoFullscreen);
				//Fix for issue #17071
				applicationType::desktop{
					presenterVid.doubleClickEnabled = true;
		            presenterVid.addEventListener(MouseEvent.MOUSE_DOWN,addMoveListnerPresenterVd);
		            presenterVid.addEventListener(MouseEvent.MOUSE_UP,removeMoveListnerPresenterVd);
				}
           }
        }
        private function createViewerVideoComp():void
        {
        	viewerVid=new VideoComp();
            PopUpManager.addPopUp(viewerVid, viewer);  
            viewerVid.width=viewer.width;
            viewerVid.height=viewer.height;
			//Fix for issue #17071
			applicationType::desktop{
	            viewerVid.x=viewer.x;
	            viewerVid.y=viewer.y;
			}
			applicationType::web{
				// To assign viewerVid component minimunm width and minimunm height
				viewerVid.minHeight = viewer.height;
				viewerVid.minWidth = viewer.width;
				//Assign y value of viewerVid for UI alignment. 
				viewerVid.x=viewer.x;
				viewerVid.y=viewer.y+100;
			}
			viewerVid.title="Viewer Video :";     
			viewerVid.muteButton.addEventListener(MouseEvent.CLICK,viewerVolume);
			viewerVid.volumeSeek.addEventListener(SliderEvent.CHANGE,controlVolume);
            if(editingActive == false)
            {   
				//Fix for issue #17071
				applicationType::desktop{
	            	viewerVid.doubleClickEnabled=true;
					viewerVid.addEventListener(MouseEvent.MOUSE_DOWN,addMoveListnerViewerVd);
					viewerVid.addEventListener(MouseEvent.MOUSE_UP,removeMoveListnerViewerVd);
				}
				applicationType::web{
					//To disable doubleClick event.
					viewerVid.doubleClickEnabled=false;
				}
	 			viewerVid.addEventListener(CloseEvent.CLOSE, closeViewerWndw);
	            viewerVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK,viewerVideoFullscreen);
            }
			else
			{
				playpauseButton.visible=false;
				stopButton.visible=false;
				closeWndowButton.visible=false;
			}
		}
        private function createDocComp():void
        {
        	docComp=new DocComp;
			documentTab.addChild(docComp);
			docComp.documentPlayer.setDocPath(contentUrl+contentFilePath);
         	docComp.documentPlayer.addEventListener(AviewPlayerEvent.DOC_TAB_CHANGED,onDocPlayerEvent);
    		docComp.documentPlayer.addEventListener(AviewPlayerEvent.WB_TAB_CHANGED,onDocPlayerEvent)
    		docComp.addEventListener(AviewPlayerEvent.SLIDE_PANNEL_CLOSSED,onSlidePannelClose);
			docComp.documentPlayer.addEventListener(AviewPlayerEvent.SLIDE_CHANGE,onSlideChange);
			docComp.addEventListener(AviewPlayerEvent.SlideSlected,onSlideSelected);
         	docComp.p2fLoader.visible=true;
        }
		private var docSlideIndex:int=-1
		private function onSlideChange(evnt:AviewPlayerEvent):void
		{
			docSlideIndex=evnt.currentSlideIndex;
			docComp.slidelist.scrollToIndex(docSlideIndex);
			docComp.slidelist.selectedIndex=docSlideIndex;
		}
        private function createWbComp():void
        {
			
        	wbPlayer=new WbPlayer();
            wbPlayer.wbSprite.width=wbCan.width	;
    		wbPlayer.wbSprite.height=wbCan.height;
    		wbPlayer.addEventListener(AviewPlayerEvent.WB_TAB_CHANGED,onWbPlayerEvent);
    		wbPlayer.addEventListener(AviewPlayerEvent.WB_PAGE_CHANGED,onWbPlayerEvent);
    		wbPlayer.addEventListener(AviewPlayerEvent.WB_CLEARED,onWbPlayerEvent);
			wbPlayer.wbSprite.drawBackground(0xffffff);
    		wbCan.addChild(wbPlayer.wbSprite);
			whiteboardMask=new Canvas;
			whiteboardMask.graphics.beginFill(0xffffff, 1);
			whiteboardMask.graphics.drawRect(0, 0, wbCan.width, wbCan.height);
			wbCan.mask=whiteboardMask;
			wbCan.addChild(whiteboardMask);             
			
        }
        private function createChatComp():void
        {
		    chatWndw=new ChatComp();
		    if(editingActive == false)
		    {
				//Fix for issue #17071
				applicationType::desktop{
		        	chatWndw.doubleClickEnabled=true;
					chatWndw.width=chat.width;
					chatWndw.height=chat.height;
					chatWndw.x=chat.x;
					chatWndw.y=chat.y+5.5;
					chatWndw.addEventListener(MouseEvent.MOUSE_DOWN,addMoveListnerChat);
					chatWndw.addEventListener(MouseEvent.MOUSE_UP,removeMoveListnerChat);
					chatWndw.addEventListener(MouseEvent.DOUBLE_CLICK,chatWindowFullscreen);
				}
				applicationType::web{
					chatWndw.doubleClickEnabled=false;
					//To assign chatWndw component minimunm width and minimunm height
					chatWndw.minHeight = chat.height;
					chatWndw.minWidth = chat.width;
					//Assign  y value of chatWndw for UI alignment.
					chatWndw.x=chat.x;
					chatWndw.y=chat.y+115;
				}
				//Fix for issue #17740
				chatWndw.addEventListener(CloseEvent.CLOSE,closeChatWndw);
	        }
			PopUpManager.addPopUp(chatWndw,chat);
			chatWndw.chatPlayer.setUiReference(chatWndw.chatbox);
        }
        
        public function setValues(presenterFMSUrl:String,viewerFMSUrl:String,videoFilePath:String,contentUrl:String,contentFilePath:String,lectureInfo:String):void
        {
        	this.presenterFMSUrl=presenterFMSUrl
        	this.viewerFMSUrl=viewerFMSUrl;
        	this.videoFilePath=videoFilePath;
			this.contentUrl=contentUrl;
			this.contentFilePath=contentFilePath;
			ClassroomContext.RECORDED_CONTENT_FILE_PATH = contentFilePath;
			ClassroomContext.RECORDED_CONTENT_URL = contentUrl;
			lectureTitle="Lecture Topic:"+lectureInfo;
        }
           private function onAllFilesLoaded(evnt:FileLoadedEvent):void
           {
           		fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED,onAllFilesLoaded);
           		fileLoaderManager.removeEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onFileLoadError);
           		contextSetter=new ContextSetter(fileLoaderManager);
           		consolidateXmlBuilder=new ConsolidateXmlBuilder(fileLoaderManager,contentUrl+contentFilePath);  
           		consolidateXmlBuilder.addEventListener(AviewPlayerEvent.CONSOLIDATE_XML_CREATED,initializePlayers);
           		consolidateXmlBuilder.buildConsilidateXml();     		
           		
            	//consolidateXmlBuilder.loadFiles(xmlPath);
           }
           private function onFileLoadError(evnt:FileLoadedEvent):void
           {
           		Alert.show("Error Loading the Lecture","Playback Module",4,this);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.editingActiveflag = 0;
           		this.dispatchEvent(new Event("File error"));
           		fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED,onAllFilesLoaded);
           		fileLoaderManager.removeEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onFileLoadError);
           } 
			 
            public function closePlayer():void
            {
				applicationType::desktop{
				    if(fullScreenPresenter)
						fullScreenPresenter.close()
					if(fullScreenChat)
						fullScreenChat.close();
					if(fullScreenViewer)
						fullScreenViewer.close();
				}
            	    if(centalTimer && centalTimer.running)
            	   		centalTimer.stop();
					if(Log.isInfo()) log.info("In closePlayer- Timer Storped");
					viewerVid.videoPlayer.stopVideoPlayer();					
            		viewerVid.videoPlayer=null;
					//Fix for issue #17071
					applicationType::web{
						// Added this logic to remove viewer video popup window when user clicks on 'Back to library' 
						PopUpManager.removePopUp(viewerVid);
					}
            		viewerVid=null;  		
            		//Close presenter video player
            		presenterVid.videoPlayer.stopVideoPlayer();
            		presenterVid.videoPlayer=null;
					//Fix for issue #17071
					applicationType::web{
						// Added this logic to remove presenterVid video popup window when user clicks on 'Back to library' 
						PopUpManager.removePopUp(presenterVid);
					}
            		presenterVid=null;
            		//Close document player
            		docComp.documentPlayer.closeDocumentPlayer();
            		docComp.documentPlayer=null;
            		docComp=null;
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.killPlayback()
					}
            }
			private var objHeight:Number=0;
			private var objWidth:Number=0;
			private var resizeCount:Number=0;
			private var previousWidth:Number=0;
			public function getResolution(obj:DisplayObjectContainer):void
			{
				if(resizeCount == 0)
				{
					previousWidth = objWidth;
					resizeCount = resizeCount + 1;
				}
				var tempWidth:Number;
				
				objHeight=obj.height;
				tempWidth=(objHeight / 3) * 4;
				if (tempWidth >= obj.width)
				{
					objWidth=obj.width;
					objHeight=(objWidth / 4) * 3;
				}
				else
				{
					objWidth=tempWidth;
				}  
			}
				
			//Fix for issue #17071
			private function presenterResize(event:ResizeEvent):void
			{	
				applicationType::desktop{
					if(presenterVid && (presenterVid.videoDisp.hasEventListener(MouseEvent.DOUBLE_CLICK)|| editingActive))			
					{
						presenterVid.width=presenter.width;
						presenterVid.height=presenter.height;
						presenterVid.x=presenter.x;
						presenterVid.y=presenter.y;
					}
				}
				applicationType::web{
					if(presenterVid )
					{
						presenterVid.width=presenter.width;
						presenterVid.height=presenter.height;
						//To assign presenterVid component minimunm width and minimunm height
						presenterVid.minHeight = presenter.height;
						presenterVid.minWidth = presenter.width;
						//Changed 'x' and 'y' value of popup window for UI alignment.
						presenterVid.x=7;
						presenterVid.y=FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+10;
					}
				}
			}
			
			private function viewerResize():void
			{ 
				//Fix for issue #17071
				applicationType::desktop{
					if(viewerVid && (viewerVid.videoDisp.hasEventListener(MouseEvent.DOUBLE_CLICK) || editingActive))				
					{
						viewerVid.width=viewer.width;
						viewerVid.height=viewer.height;
						viewerVid.x=viewer.x;
						viewerVid.y=presenter.y+presenter.height+10;
					}
				}
				applicationType::web{
					if(viewerVid )
					{
						viewerVid.width=viewer.width;
						viewerVid.height=viewer.height;
						//To assign viewerVid component minimunm width and minimunm height
						viewerVid.minHeight = viewer.height;
						viewerVid.minWidth = viewer.width;
						//Changed 'x' and 'y' value of popup window for UI alignment.
						viewerVid.x=presenterVid.x;
						viewerVid.y=presenterVid.y + presenterVid.height + 15; 
					}
				}
			}
			private function chatResize():void
			{
				//Fix for issue #17071
				applicationType::desktop{
					if(chatWndw && editingActive == false && (chatWndw.hasEventListener(MouseEvent.DOUBLE_CLICK) || editingActive))				
					{
						chatWndw.width=chat.width;
						chatWndw.height=chat.height;
						chatWndw.x=chat.x;
						chatWndw.y=viewerVid.y+viewerVid.height+10;
					}
				}
				applicationType::web{
					if(chatWndw )
					{
						chatWndw.width=chat.width;
						//Changed 'x,y' and 'Height' value of popup window for UI alignment.Fix for issue #11251:Changed y value for proper UI alignment
						chatWndw.height=chat.height-10;	
						//To assign chatWndw component minimunm width and minimunm height
						chatWndw.minHeight = chat.height;
						chatWndw.minWidth = chat.width;
						chatWndw.x=viewerVid.x;
						chatWndw.y=viewerVid.y+viewerVid.height+15;
					}
				}
			}
			private var referanceTime:Number;
			private var currentTimeOffset:uint;
            private function startCentralTimer():void
            {
				if(isPresenterFMSConnected && isViewerFMSConnected)
				{
					playpauseButton.enabled=true;
	            	centalTimer=new Timer(10)
	            	centalTimer.addEventListener(TimerEvent.TIMER,updateCentralSeekBar)
	            	seekUpdateCount=1;
	            	playHeadTime=0;
					var date:Date=new Date();
					referanceTime=date.time;
					centalTimer.start(); 
					if(Log.isInfo()) log.info("In startCentralTimer- Timer Started");
					playLecture()
	            	/*wbPlayer.playWb(0);
	            	docComp.documentPlayer.playDocument(0);
	            	chatWndw.chatPlayer.playChat(0);*/
					
					
	            	this.dispatchEvent(new Event("PlayerInitialized"));
				}
            }          
           
                        
            public var viewerFMSUrl:String;
            public var videoFilePath:String;
			public var contentUrl:String;
			public var contentFilePath:String;
            private  var seekUpdateCount:uint;
            public var playHeadTime:Number
            private var scaleFactorX:Number;
            private var scaleFactorY:Number;
            private var previousPlayTime:Number=-1;
            private var previousViewerPlayTime:Number=-1;
            public var editTime:Label=new Label();
            public var editTotalTime:Label=new Label();
			private var portTesterTimeoutId:uint;
            private function formatAndDisplayCentralTime():void
            {
				
				var Hours:uint= playHeadTime / (1000*60*60)
				var Minutes:uint = (playHeadTime % (1000*60*60)) / (1000*60);
				var Seconds:uint = ((playHeadTime % (1000*60*60)) % (1000*60)) / 1000;
				centralTimeLabel.text=Hours.toString()+":"+Minutes.toString()+":"+Seconds.toString()  
				if(editingActive)						
				{	
					var editMinutes:uint= Minutes+(Hours*60);						
					editTime.text=editMinutes.toString()+":"+Seconds.toString();
				}	
					
            }
			private function updateReferenceTime():void
			{
				var date:Date=new Date()
				referanceTime=date.time-playHeadTime-currentTimeOffset;
			}
			private function stopPlayingVideo():void
			{
				if(presenterVid.videoPlayer.netStreamVideo)
					presenterVid.videoPlayer.netStreamVideo.close();
				//presenterVid.videoPlayer.currentVideoEndTime=0;
				presenterVid.videoPlayer.currentVideoSource="";
				presenterVid.lblVideoMode.visible=false;
				if(viewerVid.videoPlayer.netStreamVideo)
					viewerVid.videoPlayer.netStreamVideo.close();
				//viewerVid.videoPlayer.currentVideoEndTime=0;
				viewerVid.videoPlayer.currentVideoSource="";
				viewerVid.lblVideoMode.visible=false;
				if(presenterVid.videoPlayer.isVideoLoaded)
				{   presenterVid.videoPlayer.isStreamReady=false;
					presenterVid.videoPlayer.isVideoLoaded=false;
					presenterVid.videoDisp.mx_internal::videoPlayer.clear();
				}
				if(viewerVid.videoPlayer.isVideoLoaded)
				{   
					viewerVid.videoPlayer.isStreamReady=false
					viewerVid.videoPlayer.isVideoLoaded=false;
					viewerVid.videoDisp.mx_internal::videoPlayer.clear();
				}
			}
			private function playLecture():void
			{
				if(playpauseButton.label=="Play")
				{
					playpauseButton.label="Pause"
				}				
				if(!stopButton.enabled)
				{   
					stopButton.enabled=true;					
				}
				if((playHeadTime/1000)>=seekBar.maximum)
				{
					if(Log.isInfo()) log.info("In playLecture Play End- Timer Stopped");	
					resetPlayer();
					
				}
				else
				{
					wbPlayer.playWb(playHeadTime);
					wbPointerPlayer.playWbPointer(playHeadTime);	
					pttPlayer.playPtt(playHeadTime);
					presenterVid.videoPlayer.playVid(playHeadTime,"pVideo");
					viewerVid.videoPlayer.playVid(playHeadTime,"vVideo");
					docComp.documentPlayer.playDocument(playHeadTime);           	    
					chatWndw.chatPlayer.playChat(playHeadTime);
					if(playHeadTime%1000 ==0)
					{
						seekBar.value=(playHeadTime/1000);
					}
				    if(presenterVid.videoPlayer.isVideoSeekedManually)
					{
						presenterVid.videoPlayer.isVideoSeekedManually = false; 
						presenterVid.videoPlayer.isVideoSeekedAutomatically = false;
						presenterVid.videoPlayer.isSeekValueSetZero = false;
						diffSeekValuePresenter = presenterVid.videoPlayer.videoSeekValue;
					}
					else if(presenterVid.videoPlayer.isVideoSeekedAutomatically)
					{
						presenterVid.videoPlayer.isVideoSeekedManually = false; 
						presenterVid.videoPlayer.isVideoSeekedAutomatically = false;
						presenterVid.videoPlayer.isSeekValueSetZero = false;
						diffSeekValuePresenter = presenterVid.videoPlayer.videoSeekValue - seekBar.value ;
					}
					else if(presenterVid.videoPlayer.isSeekValueSetZero)
					{
						diffSeekValuePresenter = 0;
					}
						
					if(viewerVid.videoPlayer.isVideoSeekedAutomatically)
					{
						viewerVid.videoPlayer.isVideoSeekedManually = false; 
						viewerVid.videoPlayer.isVideoSeekedAutomatically = false;
						viewerVid.videoPlayer.isSeekValueSetZero = false;
						diffSeekValueViewer = viewerVid.videoPlayer.videoSeekValue - seekBar.value ;
					}
					else if(viewerVid.videoPlayer.isVideoSeekedManually)
					{
						viewerVid.videoPlayer.isVideoSeekedManually = false; 
						viewerVid.videoPlayer.isVideoSeekedAutomatically = false;
						viewerVid.videoPlayer.isSeekValueSetZero = false;
						diffSeekValueViewer = viewerVid.videoPlayer.videoSeekValue;
					}
					else if(viewerVid.videoPlayer.isSeekValueSetZero)
					{
						diffSeekValueViewer = 0;
					}
						
					/*if(previousPlayTime-100==presenterVid.videoPlayer.netStreamVideo.time &&  presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded)
					{
						
						centalTimer.stop();	
						if(Log.isInfo()) log.info("In updateCentralSeekBar2- Timer stopped");	
						presenterVid.videoPlayer.netStreamVideo.bufferTime=10;
						presenterVid.videoPlayer. netStreamVideo.seek(seekBar.value - presenterVid.videoPlayer.currVideoStartTime+diffSeekValuePresenter);
						
						if(viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded)
						viewerVid.videoPlayer.netStreamVideo.seek(seekBar.value- viewerVid.videoPlayer.currVideoStartTime+diffSeekValuePresenter);
						
					}
					
				    if(previousViewerPlayTime-100== viewerVid.videoPlayer.netStreamVideo.time &&  viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded)
					{
						centalTimer.stop();
						if(Log.isInfo()) log.info("In updateCentralSeekBar3- Timer stopped");	
						viewerVid.videoPlayer.netStreamVideo.bufferTime=10;
						viewerVid.videoPlayer.netStreamVideo.seek(seekBar.value-viewerVid.videoPlayer.currVideoStartTime+diffSeekValueViewer);
						if(presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded)
						presenterVid.videoPlayer.netStreamVideo.seek(seekBar.value -  presenterVid.videoPlayer.currVideoStartTime+diffSeekValueViewer);
					}
					previousPlayTime=presenterVid.videoPlayer.netStreamVideo.time ;
					previousViewerPlayTime= viewerVid.videoPlayer.netStreamVideo.time;
					var playTime:Number= presenterVid.videoPlayer.netStreamVideo.time + presenterVid.videoPlayer.currVideoStartTime;
					var sliderValue:Number=seekBar.value;
					if(presenterVid.videoPlayer.isStreamReady)
					{
						if(playTime > sliderValue+1+diffSeekValuePresenter || playTime < sliderValue-1+diffSeekValuePresenter)
						{
							if(Log.isInfo()) log.info("Seek adjustmment automatically");
							
							presenterVid.videoPlayer.netStreamVideo.seek(sliderValue+diffSeekValuePresenter-(presenterVid.videoPlayer.currVideoStartTime)); 
						}
					}
					if(viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded)
					{                   	
						sliderValue=seekBar.value;
						playTime=viewerVid.videoPlayer.netStreamVideo.time + viewerVid.videoPlayer.currVideoStartTime;
						if(playTime > sliderValue+1+diffSeekValueViewer || playTime < sliderValue-1+diffSeekValueViewer)
							viewerVid.videoPlayer.netStreamVideo.seek(sliderValue+diffSeekValueViewer-viewerVid.videoPlayer.currVideoStartTime);
					} */
				}        
			}
			private function resetPlayer():void
			{
				//Fix for issue #19317
				if(centalTimer){
					centalTimer.stop()
					centalTimer.reset();
				}
				if(presenterVid)
					presenterVid.lblVideoMode.visible=false;
				if(viewerVid)
					viewerVid.lblVideoMode.visible=false;
				pausedTimer=false;
				playHeadTime =-100;
				currentTimeOffset =0;
				seekUpdateCount=1;
				stopPlayingVideo();
				wbPlayer.clearWb();
				docComp.documentPlayer.clearDocumentPlayer();
				if(!slideBtn.enabled && !editingActive)
				{
					if(docComp.slidelist && docComp.slidelist.selectedIndex>0)
					{
						docComp.slidelist.scrollToIndex(0);
						docComp.slidelist.selectedIndex=0;
					}
					docComp.closeSlidePanel();
					
				}
				chatWndw.chatbox.text="";
				chatWndw.chatPlayer.msg = "";
				playpauseButton.label="Play";
				seekBar.value=0;
				centralTimeLabel.text="00:00:00";
				stopButton.enabled=false;
				tn.selectedIndex=1;
				presenterVid.playBackIcon= presenterVid.playBack_unclicked;
				presenterVid.muteButton.toolTip="Mute";
				viewerVid.playBackIcon= viewerVid.playBack_unclicked;
				viewerVid.muteButton.toolTip="Mute";
			}
            private function updateCentralSeekBar(evnt:TimerEvent):void
            { 
				var date:Date = new Date()
				currentTimeOffset=date.time - (referanceTime+playHeadTime);
				if(currentTimeOffset>=100)
				{
					playHeadTime+=100
					formatAndDisplayCentralTime();
					playLecture();
				}
            }

           // public var p2fPlayer:p2fPlayer;
           public var docComp:DocComp=new DocComp();
           private function onDocPlayerEvent(evnt:AviewPlayerEvent):void
            {
            	if(evnt.type==AviewPlayerEvent.DOC_TAB_CHANGED)
            	{
            		tn.selectedIndex=0
            	}
				if(evnt.type==AviewPlayerEvent.WB_TAB_CHANGED)
				{
					tn.selectedIndex=1
				}
            }
            private function onSlideSelected(event:AviewPlayerEvent):void
			{
				seekBar.value=event.time/1000;				
				var slideTimeRounded:int=Math.floor(event.time/100);		
				playHeadTime = (slideTimeRounded*100);
				currentTimeOffset=0;
				updateReferenceTime();
				if(!centalTimer.running)
				{
					centalTimer.start();
					if(Log.isInfo()) log.info("In onSlideSelected- Timer Started");	
				}
				chatWndw.chatPlayer.updateChat(playHeadTime);
				wbPlayer.setContext(event.time);
				docComp.documentPlayer.setContext(event.time);
				formatAndDisplayCentralTime();
				presenterVid.videoPlayer.setContext(playHeadTime, seekBar.value, "pVideo", presenterVid.videoDisp);
				viewerVid.videoPlayer.setContext(playHeadTime, seekBar.value, "vVideo", viewerVid.videoDisp);
			}
            private function onSlidePannelClose(evnt:AviewPlayerEvent):void
            {
            	slideBtn.enabled=true;
            }
            private function initializePlayers(evnt:AviewPlayerEvent):void
            {
 				wbPointerPlayer=new WbPointerPlayer(consolidateXmlBuilder,wbPlayer.wbSprite);	
				pttPlayer=new PttPlayer(presenterVid,viewerVid,consolidateXmlBuilder,contextSetter);	
				pttPlayer.addEventListener(AviewPlayerEvent.MUTE_PRESENTER_STREAM,mutePresenter);
				pttPlayer.addEventListener(AviewPlayerEvent.MUTE_VIEWER_STREAM,muteViewer);
				pttPlayer.addEventListener(AviewPlayerEvent.UNMUTE_PRESENTER_STREAM,unMutePresenter);
				pttPlayer.addEventListener(AviewPlayerEvent.UNMUTE_VIEWER_STREAM,unMuteViewer);
             	seekBar.maximum=(fileLoaderManager.endTimeXml.etime)/1000;				
				var time:Number=seekBar.maximum*1000;
				var Hours:uint= time / (1000*60*60)
				var Minutes:uint = (time % (1000*60*60)) / (1000*60);
				var Seconds:uint = ((time % (1000*60*60)) % (1000*60)) / 1000;
				endTimeLabel.text=Hours.toString()+":"+Minutes.toString()+":"+Seconds.toString()  
				if(editingActive)						
				{	
					var editMin:uint=(Minutes+Hours*60)
					editTotalTime.text=editMin.toString()+":"+Seconds.toString();
				}
             	docComp.documentPlayer.setConsolidateXMLBuilder(consolidateXmlBuilder);
             	docComp.documentPlayer.setContextSetter(contextSetter);
        		wbPlayer.setValues(consolidateXmlBuilder,contextSetter);
                chatWndw.chatPlayer.setConsolidateXML(consolidateXmlBuilder);
				seekBar.addEventListener(SliderEvent.CHANGE,seekChange)
				seekBar.addEventListener(SliderEvent.THUMB_RELEASE,seekChange);	
				seekBar.addEventListener(MouseEvent.MOUSE_DOWN,onSeekBarMouseDown)
				
				var presenterFMSIP:String=presenterFMSUrl.substring(presenterFMSUrl.indexOf("://")+3,presenterFMSUrl.indexOf("/vod"))
				var presenterPortTester:FMSPortTester = new FMSPortTester(presenterFMSIP,"/"+Constants.COLLABORATION_SERVER_MODULE_NAME+"/ConnectionTester",getConnectedPresenter,this,true);				
				presenterPortTester.selectFMSPort();	
				if(presenterFMSUrl!=viewerFMSUrl)
				{
					portTesterTimeoutId=setTimeout(viewerPortTester, 100);
				}

            }
			private function viewerPortTester():void
			{
				clearTimeout(portTesterTimeoutId);
				var viewerFMSIP:String=viewerFMSUrl.substring(viewerFMSUrl.indexOf("://")+3,viewerFMSUrl.indexOf("/vod"))
				var viewerPortTester:FMSPortTester  = new FMSPortTester(viewerFMSIP,"/"+Constants.COLLABORATION_SERVER_MODULE_NAME+"/ConnectionTester",getConnectedViewer,this,true);				
				viewerPortTester.selectFMSPort();
			}
           private function getConnectedPresenter():void
		   {
			   var presenterFMSUrlTemp:String = "";
			   var startIndex:int = presenterFMSUrl.indexOf("//");
			   startIndex += 2; //Added for //
			   var endIndex:int = presenterFMSUrl.indexOf("/",startIndex);
			   
			   if(startIndex != -1 && endIndex != -1)
			   {
				   presenterFMSUrlTemp+=presenterFMSUrl.slice(0,startIndex);
				   presenterFMSUrlTemp+=presenterFMSUrl.slice(startIndex,endIndex)+":"+ClassroomContext.portFMS;
				   presenterFMSUrlTemp+=presenterFMSUrl.slice(endIndex,presenterFMSUrl.length);
			   }
			   
			   presenterFmsConnection=new ConnectionComp(presenterFMSUrlTemp);
			   presenterFmsConnection.netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onConnectionError) 
			   presenterFmsConnection.netConnection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionSuccessPresenter)
			   playerInitialized=true;
		   }
			private function getConnectedViewer():void
			{
				var viewerFMSUrlTemp:String = "";
				var startIndex:int = viewerFMSUrl.indexOf("//");
				startIndex += 2; //Added for //
				var endIndex:int = viewerFMSUrl.indexOf("/",startIndex);
				
				if(startIndex != -1 && endIndex != -1)
				{
					viewerFMSUrlTemp+=viewerFMSUrl.slice(0,startIndex);
					viewerFMSUrlTemp+=viewerFMSUrl.slice(startIndex,endIndex)+":"+ClassroomContext.portFMS;
					viewerFMSUrlTemp+=viewerFMSUrl.slice(endIndex,viewerFMSUrl.length);
				}

				viewerFmsConnection=new ConnectionComp(viewerFMSUrlTemp); 
				viewerFmsConnection.netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onConnectionError) 
				viewerFmsConnection.netConnection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionSuccessViewer)
			}

          
            private function onConnectionError(ncObj:Event) :void
			{
              //AuditContext.userAction.connectionSuccessEventLog("Playback");
			}
			private var isPresenterFMSConnected:Boolean=false;
			private var isViewerFMSConnected:Boolean=false;
			private function connectToViewerVideo():void
			{
				viewerVid.videoPlayer.setValues(viewerFmsConnection.netConnection,videoFilePath,consolidateXmlBuilder,contextSetter
					,fileLoaderManager,viewerVid);
				viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_READY,onViewerStreamStatus);
				viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_NOT_READY,onViewerStreamStatus);
				viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE,onViewerStreamStatus);
				viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_SEEK,startTimeUpdate);
				viewerVid.videoPlayer.connectToVod();
				isViewerFMSConnected=true;
			}
			private function onConnectionSuccessViewer(ncObj:NetStatusEvent) :void
			{ 	// trace(ncObj.info.code);    
				if (ncObj.info.code == "NetConnection.Connect.Success")
				{					
					AuditContext.userAction.connectionSuccessEventLog("PlaybackViewer",viewerFmsConnection.netConnection.uri,null);
					connectToViewerVideo();
					startCentralTimer(); 
				}
				else if(ncObj.info.code == "NetConnection.Connect.Closed")
				{
					AuditContext.userAction.connectionCloseEventLog("PlaybackViewer",viewerFmsConnection.netConnection.uri);
				}
				else if(ncObj.info.code == "NetConnection.Connect.Failed")
				{
					AuditContext.userAction.connectionFailEventLog("PlaybackViewer",viewerFmsConnection.netConnection.uri);
				}
				else if(ncObj.info.code == "NetConnection.Connect.Rejected")
				{
					AuditContext.userAction.connectionRejectEventLog("PlaybackViewer",viewerFmsConnection.netConnection.uri);
				}
			}
			private function onConnectionSuccessPresenter(ncObj:NetStatusEvent) :void
			{ 	// trace(ncObj.info.code);    
				if (ncObj.info.code == "NetConnection.Connect.Success")
		 	    {
					AuditContext.userAction.connectionSuccessEventLog("PlaybackPresenter",presenterFmsConnection.netConnection.uri,null);
                	presenterVid.videoPlayer.setValues(presenterFmsConnection.netConnection,videoFilePath,consolidateXmlBuilder,contextSetter
                			,fileLoaderManager,presenterVid);
		        	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_READY,onPresenterStreamStatus);
		        	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_NOT_READY,onPresenterStreamStatus);
		        	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE,onPresenterStreamStatus);
		        	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_SEEK,startTimeUpdate);
		        	presenterVid.videoPlayer.connectToVod(); 
					isPresenterFMSConnected = true;
					if(presenterFMSUrl==viewerFMSUrl)
					{
						viewerFmsConnection=presenterFmsConnection;
						connectToViewerVideo();
					}
				    startCentralTimer(); 
				}
				else if(ncObj.info.code == "NetConnection.Connect.Closed")
				{
					AuditContext.userAction.connectionCloseEventLog("PlaybackPresenter",presenterFmsConnection.netConnection.uri);
				}
				else if(ncObj.info.code == "NetConnection.Connect.Failed")
				{
					AuditContext.userAction.connectionFailEventLog("PlaybackPresenter",presenterFmsConnection.netConnection.uri);
				}
				else if(ncObj.info.code == "NetConnection.Connect.Rejected")
				{
					AuditContext.userAction.connectionRejectEventLog("PlaybackPresenter",presenterFmsConnection.netConnection.uri);
				}
			}
            
			private function onPresenterStreamStatus(evnt:AviewPlayerEvent):void
			{
				if(Log.isInfo()) log.info("In onPresenterStreamStatus Eventsd :-"+evnt.type);	
				if(viewerVid)
				{
					if(Log.isInfo()) log.info("In onPresenterStreamStatus isStreamReady :-"+viewerVid.videoPlayer.isStreamReady
					+";;;isVideoLoaded:"+viewerVid.videoPlayer.isVideoLoaded);	
				}
				if(evnt.type==AviewPlayerEvent.STREAM_READY)
				{
					playStreams();
					
				}
				else if(evnt.type==AviewPlayerEvent.STREAM_NOT_READY)
				{
					if(viewerVid  && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded)
					{
						viewerVid.videoPlayer.netStreamVideo.pause();
					}
					centalTimer.stop();
				
				}
				if(evnt.type==AviewPlayerEvent.STREAM_PLAY_COPMLETE && presenterVid)
				{	
					presenterVid.videoPlayer.videoToggled=false;
					presenterVid.videoPlayer.timerRun=false; 
					presenterVid.videoDisp.mx_internal::videoPlayer.clear();
					presenterVid.videoPlayer.netStreamVideo.close();	
					presenterVid.videoPlayer.currentVideoSource="";
					if(viewerVid  && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded)
					{
						playStreams();
					}
               	}
				
				controlVolume(null);
			}
			private function playStreams():void
			{
				if(presenterVid && !presenterVid.videoPlayer.isStreamReady && !presenterVid.videoPlayer.isVideoLoaded)
				{
					presenterVid.videoPlayer.netStreamVideo.close();
					presenterVid.videoDisp.mx_internal::videoPlayer.clear();
				}
				if(viewerVid && !viewerVid.videoPlayer.isStreamReady && !viewerVid.videoPlayer.isVideoLoaded)
				{
					viewerVid.videoPlayer.netStreamVideo.close();
					viewerVid.videoDisp.mx_internal::videoPlayer.clear();
					
				}
			    //if(!centalTimer.running && presenterVid && presenterVid.videoPlayer.isVideoLoaded && presenterVid.videoPlayer.isStreamReady)
				//If presenter stream is ready and viewer stream is not ready then pause the presenter stream
				if(presenterVid && presenterVid.videoPlayer.isVideoLoaded && presenterVid.videoPlayer.isStreamReady)	
				{
					if(viewerVid && viewerVid.videoPlayer.isVideoLoaded && !viewerVid.videoPlayer.isStreamReady)
					{
						presenterVid.videoPlayer.netStreamVideo.pause();
						centalTimer.stop();
						
					}
				}
				//if(!centalTimer.running && viewerVid && viewerVid.videoPlayer.isVideoLoaded && viewerVid.videoPlayer.isStreamReady)
				//If viewer stream is ready and presenter stream is not ready then pause the viewer stream
				if(viewerVid && viewerVid.videoPlayer.isVideoLoaded && viewerVid.videoPlayer.isStreamReady)
				{
					if(presenterVid && presenterVid.videoPlayer.isVideoLoaded && !presenterVid.videoPlayer.isStreamReady)
					{
						viewerVid.videoPlayer.netStreamVideo.pause();
						centalTimer.stop();
						
					}
				}
				if(!centalTimer.running && ((presenterVid  && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded) ||
					(presenterVid && !presenterVid.videoPlayer.isStreamReady && !presenterVid.videoPlayer.isVideoLoaded)) &&
					((viewerVid  && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded) ||
						(viewerVid && !viewerVid.videoPlayer.isStreamReady && !viewerVid.videoPlayer.isVideoLoaded)))

				{
					if(playBackBufferingMessageComp.source!=null)
					{
						playBackBufferingMessageComp.unloadAndStop();
					}
					if(Log.isInfo()) log.info("In playStreams :- Both streams ready");	
					if(presenterVid  && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded && playpauseButton.label=="Pause")
					{
						presenterVid.videoPlayer.netStreamVideo.resume();
					}
					else if(presenterVid  && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded && playpauseButton.label=="Play")
					{
						presenterVid.videoPlayer.netStreamVideo.pause();
					}
					if(viewerVid  && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded && playpauseButton.label=="Pause")
					{
						viewerVid.videoPlayer.netStreamVideo.resume();
					}
					else if(viewerVid  && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded && playpauseButton.label=="Play")
					{
						presenterVid.videoPlayer.netStreamVideo.pause();
					}
					if(playpauseButton.label =="Pause")
					{
						updateReferenceTime()
						centalTimer.start();
						if(Log.isInfo()) log.info("In playStreams :- Both streams ready-Timer started")
					}
					
				}
			}
			private function onViewerStreamStatus(evnt:AviewPlayerEvent):void
			{
				if(Log.isInfo()) log.info("In onViewerStreamStatus Eventsd :-"+evnt.type);	
				if(presenterVid)
				{
					if(Log.isInfo()) log.info("In onViewerStreamStatus isStreamReady :-"+presenterVid.videoPlayer.isStreamReady
						+";;;isVideoLoaded:"+presenterVid.videoPlayer.isVideoLoaded);	
				}
				if(evnt.type==AviewPlayerEvent.STREAM_READY )
				{
					playStreams();
					
				}
				else if(evnt.type==AviewPlayerEvent.STREAM_NOT_READY)
				{
					if(presenterVid  && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded)
					{
						presenterVid.videoPlayer.netStreamVideo.pause();
					}
					centalTimer.stop();
					
				}
				if(evnt.type==AviewPlayerEvent.STREAM_PLAY_COPMLETE && viewerVid)
				{	
					viewerVid.videoPlayer.videoToggled=false;
					viewerVid.videoPlayer.timerRun=false; 
					viewerVid.videoDisp.mx_internal::videoPlayer.clear();
					viewerVid.videoPlayer.netStreamVideo.close();	
					viewerVid.videoPlayer.currentVideoSource="";
					if(presenterVid  && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded)
					{
						playStreams();
					}
				}
				
				controlVolume(null);
			}
            private function startTimeUpdate(evnt:AviewPlayerEvent):void
            {
            	if((!presenterVid.videoPlayer.timerRun) && (!viewerVid.videoPlayer.timerRun)) 
            	{
            	  if((!presenterVid.videoPlayer.isVideoLoaded) &&  (!viewerVid.videoPlayer.isVideoLoaded))
            	  {
            	  	if(!pausedTimer)
					{
						if(!centalTimer.running)
						{
							updateReferenceTime()
							centalTimer.start(); 
							if(playBackBufferingMessageComp.source!=null)
							{
								playBackBufferingMessageComp.unloadAndStop();
							}
							if(Log.isInfo()) log.info("In startTimeUpdate- Timer Started");
						}
					}
            		  else
            		  {       				
						presenterVid.videoPlayer.currentVideoSource="";
					    viewerVid.videoPlayer.currentVideoSource="";
            		  	//viewerVid.videoPlayer.currentVideoEndTime=0;
            		   // presenterVid.videoPlayer.currentVideoEndTime=0;
            		  	viewerVid.videoPlayer.netStreamVideo.close();
						presenterVid.videoPlayer.netStreamVideo.close();
						presenterVid.videoDisp.mx_internal::videoPlayer.clear();  
            		    viewerVid.videoDisp.mx_internal::videoPlayer.clear();  	
            		  }           		   
            	  }
            	}
            	
            }
            private function onWbPlayerEvent(evnt:AviewPlayerEvent):void
            {
            	if(evnt.type==AviewPlayerEvent.WB_TAB_CHANGED)
            	{
            		tn.selectedIndex=1
            	}
            	else if(evnt.type==AviewPlayerEvent.WB_PAGE_CHANGED)
            	{
            		pageNo.text="Page No : "+evnt.pageNumber;
            		tn.selectedIndex=1  // shold remove this line later only the above line of code is enough
            	}
            	else if(evnt.type==AviewPlayerEvent.WB_CLEARED)
            	{
					//Fix for issue #19317
					if(wbPointerPlayer){
            			wbPointerPlayer.pointerShape=null;
					}
            	}
            }
            private function onSeekBarMouseDown(evnt:Event):void
            {
				if(centalTimer)
				{
					if(stopButton.enabled)
						playBackBufferingMessageComp.load(swfFile);
						//playBackBufferingMessageComp.source=(")";
	            	centalTimer.stop(); 
					if(viewerVid  && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded)
					{
						viewerVid.videoPlayer.netStreamVideo.pause();
					}
					if(presenterVid  && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded)
					{
						presenterVid.videoPlayer.netStreamVideo.pause();
					}
						
					if(Log.isInfo()) log.info("In onSeekBarMouseDown - Timer stopped");	
				}
            }
            private function controlVolume(event:Event):void
			{			
				if( presenterVid.muteButton.toolTip=="Mute")
					presenterVid.muteButton.toolTip="Unmute"
				else
					presenterVid.muteButton.toolTip="Mute"
				if(viewerVid.muteButton.toolTip=="Mute")
					viewerVid.muteButton.toolTip="Unmute"
				else
					viewerVid.muteButton.toolTip="Mute"
				presenterVolume(null);
				viewerVolume(null);
		      		 
			}
			private function presenterVolume(event:Event):void
			{
				var evnt:AviewPlayerEvent;
				if( presenterVid.muteButton.toolTip=="Mute")
				{
					mutePresenter(evnt);
					
				}
				else
				{
					unMutePresenter(evnt);
					
				}
			}
			private function mutePresenter(evnt:AviewPlayerEvent):void
			{
				if(presenterVid  && presenterVid.videoPlayer && presenterVid.videoPlayer.netStreamVideo )
				{
					videoVolume.volume=0;
					presenterVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
					presenterVid.playBackIcon= presenterVid.playBack_clicked;
					presenterVid.muteButton.toolTip="Unmute";
				}
			}
			private function unMutePresenter(evnt:AviewPlayerEvent):void
			{
				if(evnt!=null && presenterVid.playBackIcon == presenterVid.playBack_clicked)
					return;
				if(presenterVid  && presenterVid.videoPlayer && presenterVid.videoPlayer.netStreamVideo )
				{
					videoVolume.volume = (presenterVid.volumeSeek.value/100)
					presenterVid.playBackIcon= presenterVid.playBack_unclicked;
					presenterVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
					presenterVid.muteButton.toolTip="Mute";
					
				}
			}
			private function unMuteViewer(evnt:AviewPlayerEvent):void
			{
				if(viewerVid  && viewerVid.videoPlayer && viewerVid.videoPlayer.netStreamVideo )
				{
					videoVolume.volume = (viewerVid.volumeSeek.value/100);
					viewerVid.playBackIcon= viewerVid.playBack_unclicked;
					viewerVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
					viewerVid.muteButton.toolTip="Mute";
				}
				
			}
			private function muteViewer(evnt:AviewPlayerEvent):void
			{
				if(viewerVid  && viewerVid.videoPlayer && viewerVid.videoPlayer.netStreamVideo )
				{
					videoVolume.volume=0;
					viewerVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
					viewerVid.playBackIcon=viewerVid.playBack_clicked;
					viewerVid.muteButton.toolTip="Unmute";
				}
			}
			private function viewerVolume(event:Event):void
            {
				var evnt:AviewPlayerEvent;
				if(viewerVid.muteButton.toolTip=="Mute")
				{
					muteViewer(evnt);
				}
				else
				{
					unMuteViewer(evnt);
				}
				
			}
            private function addMoveListnerPresenterVd(ev:MouseEvent):void
            {
            	presenterVid.addEventListener(MoveEvent.MOVE,presenterVidMove);
            }
            private function removeMoveListnerPresenterVd(ev:MouseEvent):void
            {
            	presenterVid.removeEventListener(MoveEvent.MOVE,presenterVidMove);
            	
            }
            private function addMoveListnerViewerVd(ev:MouseEvent):void
            {
            	viewerVid.addEventListener(MoveEvent.MOVE,viewerVidMove);
            }
            private function removeMoveListnerViewerVd(ev:MouseEvent):void
            {
            	viewerVid.removeEventListener(MoveEvent.MOVE,viewerVidMove);
            }
            private function addMoveListnerChat(ev:MouseEvent):void
            {
            	chatWndw.addEventListener(MoveEvent.MOVE,chatMove);
            }
            private function removeMoveListnerChat(ev:MouseEvent):void
            {
            	chatWndw.removeEventListener(MoveEvent.MOVE,chatMove);
            }
            private function presenterVidMove(ev:MoveEvent):void
            {
				//Fix for issue #17071
				applicationType::desktop{
	            	if(ev.oldY>(viewer.height/2)&& !fullScreenViewerBool)
	            	{
	            	    viewerVid.move(presenter.x,presenter.y)
	            	}
	            	if(ev.oldY>(viewer.height/2+presenter.height) && !fullScreenChatBool)
	            	{
	            		chatWndw.move(viewer.x,viewer.y);
	            	}
	                if(ev.oldY<(presenter.height/2)&& !fullScreenViewerBool)
	            	{
	            	   viewerVid.move(viewer.x,viewer.y)
	            	}
	            	if(ev.oldY<(viewer.height/2+presenter.height)&& !fullScreenChatBool)
	            	{
	            		chatWndw.move(chat.x,chat.y)
	            	}
				}
				applicationType::web{
					if(ev.oldY>(viewer.height/1.2)&& !fullScreenViewerBool)
					{
						viewerVid.move(presenter.x+7,FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+5)
					}
					if(ev.oldY>(viewer.height/1.2+presenter.height) && !fullScreenChatBool)
					{
						chatWndw.move(viewer.x+7,viewer.y+115);
					}
					if(ev.oldY<(presenter.height/1.2)&& !fullScreenViewerBool)
					{
						viewerVid.move(viewer.x+7,viewer.y+115)
					}
					if(ev.oldY<(viewer.height/1.2+presenter.height)&& !fullScreenChatBool)
					{
						chatWndw.move(chat.x+7,chat.y+115)
					}
				}
            	
            }
             private function viewerVidMove(ev:MoveEvent):void
            {
				 //Fix for issue #17071
				 applicationType::desktop{
	            	if(ev.oldY<(viewer.height/2) && !fullScreenPresenterBool)
	            	{
						presenterVid.move(viewer.x,viewer.y)
	            	}
	            	if(ev.oldY>(viewer.height/2)&& !fullScreenPresenterBool)
	            	{
						presenterVid.move(presenter.x,presenter.y)
	            	}	   
				
	            	if(ev.oldY>(viewer.height/2+presenter.height)&& !fullScreenChat)
	            	{
						chatWndw.move(viewer.x,viewer.y);
	            	}
	            	if(ev.oldY<(viewer.height/2+presenter.height)&& !fullScreenChat)
	            	{
						chatWndw.move(chat.x,chat.y)
	            	}
				 }
				 applicationType::web{
					 if(ev.oldY<(viewer.height/1.2) && !fullScreenPresenterBool)
					 {
						 presenterVid.move(viewer.x+7,viewer.y+115)
					 }
					 if(ev.oldY>(viewer.height/1.2)&& !fullScreenPresenterBool)
					 {
						 presenterVid.move(presenter.x+7,FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+5)
					 }   
					 if(ev.oldY>(viewer.height/1.2+presenter.height))
					 {
						 chatWndw.move(viewer.x+7,viewer.y+115);
					 }
					 if(ev.oldY<(viewer.height/1.2+presenter.height))
					 {
						 chatWndw.move(chat.x+7,chat.y+115)
					 } 
				 }
            }
            private function chatMove(ev:MoveEvent):void
            {
				//Fix for issue #17071
				applicationType::desktop{
	            	if(ev.oldY<(viewer.height/2+presenter.height)&& !fullScreenViewerBool)
	            	{
	            		viewerVid.move(chat.x,chat.y)
	            	}
	            	if(ev.oldY>(viewer.height/2+presenter.height)&& !fullScreenViewerBool)
	            	{
						viewerVid.move(viewer.x,viewer.y);
	            	}
	            	if(ev.oldY<(viewer.height/2)&& !fullScreenPresenterBool)
	            	{
						presenterVid.move(viewer.x,viewer.y)
	            	}
	            	if(ev.oldY>(viewer.height/2)&& !fullScreenPresenterBool)
	            	{
						presenterVid.move(presenter.x,presenter.y)
	            	}
				}
				applicationType::web{
					if(ev.oldY<(viewer.height/1.2+presenter.height)&& !fullScreenViewerBool)
					{
						viewerVid.move(chat.x+7,chat.y+115)
					}
					if(ev.oldY>(viewer.height/1.2+presenter.height)&& !fullScreenViewerBool)
					{
						viewerVid.move(viewer.x+7,viewer.y+115);
					}
					if(ev.oldY<(viewer.height/1.2)&& !fullScreenPresenterBool)
					{
						presenterVid.move(viewer.x+7,viewer.y+115)
					}
					if(ev.oldY>(viewer.height/1.2)&& !fullScreenPresenterBool)
					{
						presenterVid.move(presenter.x+7,FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+5)
					}
				}
            }
           
          private function presenterVideoFullscreen(evnt:MouseEvent):void
           {  
           	
           	 PopUpManager.removePopUp(presenterVid);   
           	 presenterVid.showCloseButton=false;
           	 presenterVid.setStyle("headerHeight",0);			 
			 fullScreenPresenterBool=true;
           	 presenterVid.videoDisp.removeEventListener(MouseEvent.DOUBLE_CLICK,presenterVideoFullscreen);
			 applicationType::desktop{
	           	 fullScreenPresenter=new FullScreenComp();
				 fullScreenPresenter.addEventListener(Event.CLOSING,onPresnterVideoToNormalState)
	           	 fullScreenPresenter.videoComp=presenterVid;
	           	 fullScreenPresenter.title=presenterVid.title;	           	 fullScreenPresenter.open()
			 }
           }
           private function onPresnterVideoToNormalState(evnt:Event):void
           {
           		presenterVid.showCloseButton=true;
           		presenterVid.clearStyle("headerHeight");
				fullScreenPresenterBool=false;
           		presenterVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK,presenterVideoFullscreen);
				applicationType::desktop{
	           		fullScreenPresenter.removeEventListener(Event.CLOSING,onPresnterVideoToNormalState)
					
	            	fullScreenPresenter.removeAllChildren();
				}
            	if(viewerVid && !fullScreenViewerBool)
           	   	{
           	   		viewerVid.x=viewer.x;
	            	viewerVid.y=viewer.y    
           	    }
           	   if(chatWndw && !fullScreenChatBool)
	  		 	{
	  		 		chatWndw.x=chat.x;
	  		 		chatWndw.y=chat.y;
	  		 	}
                PopUpManager.addPopUp(presenterVid,presenter);      
                presenterVid.width=presenter.width;
                presenterVid.height=presenter.height              
                presenterVid.doubleClickEnabled=true;  
           }
            private function viewerVideoFullscreen(evnt:MouseEvent):void
           { 
           	 viewerVid.showCloseButton=false;	
			 viewerVid.setStyle("headerHeight",0);
			 fullScreenViewerBool=true;
           	 PopUpManager.removePopUp(viewerVid); 
           	 viewerVid.videoDisp.removeEventListener(MouseEvent.DOUBLE_CLICK,viewerVideoFullscreen); 
			 applicationType::desktop{
	             fullScreenViewer=new FullScreenComp();
	           	 fullScreenViewer.addEventListener(Event.CLOSE,onViewerVideoToNormalState)
	           	 fullScreenViewer.videoComp=viewerVid;
	             fullScreenViewer.title=viewerVid.title;           	 
	          	 fullScreenViewer.open()
			 }
           }
            private function onViewerVideoToNormalState(evnt:Event):void
           {
			   if(viewerVid)
			   {
	           	   viewerVid.showCloseButton=true;
				   viewerVid.clearStyle("headerHeight");
				   fullScreenViewerBool=false;
				   applicationType::desktop{
		           	   fullScreenViewer.removeEventListener(Event.CLOSING,onPresnterVideoToNormalState)    
		           	   fullScreenViewer.removeAllChildren();
				   }
		           viewerVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK,viewerVideoFullscreen);                 
		       	    if(presenterVid && !fullScreenPresenterBool)
		  		 	{
		  		 		presenterVid.x=presenter.x;
		  		 		presenterVid.y=presenter.y;
		  		 	}
		  		 	if(chatWndw && !fullScreenChatBool)
		  		 	{
		  		 		chatWndw.x=chat.x;
		  		 		chatWndw.y=chat.y;
		  		 	}
		             viewerVid.width=viewer.width;
		             viewerVid.height=viewer.height 
		             viewerVid.x=viewer.x;
		             viewerVid.y=viewer.y       
		             PopUpManager.addPopUp(viewerVid,viewer);        
		             viewerVid.doubleClickEnabled=true; 
			   }
           }
           private function chatWindowFullscreen(evnt:MouseEvent):void
           {  
       		 	chatWndw.title="";
            	chatWndw.showCloseButton=false;	
				chatWndw.setStyle("headerHeight",0);
				fullScreenChatBool=true
            	chatWndw.removeEventListener(MouseEvent.DOUBLE_CLICK,chatWindowFullscreen);
           		PopUpManager.removePopUp(chatWndw); 
				applicationType::desktop{
	           		fullScreenChat=new FullScreenComp();
	           	 	fullScreenChat.addEventListener(Event.CLOSE,onChatWindowToNormalState)
	           	 	fullScreenChat.chatComp=chatWndw;
	           	 	fullScreenChat.title="Chat";
	           	 	fullScreenChat.open();
				}
           }
           private function onChatWindowToNormalState(evnt:Event):void
           {
			   if(chatWndw)
			   {
	           	   chatWndw.title="Chat";
	           	   chatWndw.showCloseButton=true;
				   chatWndw.clearStyle("headerHeight");
				   fullScreenChatBool=false;
				   applicationType::desktop{
		           	   fullScreenChat.removeEventListener(Event.CLOSING,onChatWindowToNormalState)    
		           	   fullScreenChat.removeAllChildren();
				   }
		           chatWndw.addEventListener(MouseEvent.DOUBLE_CLICK,chatWindowFullscreen);                 
		       	    if(presenterVid && !fullScreenPresenterBool)
		  		 	{
		  		 		presenterVid.x=presenter.x;
		  		 		presenterVid.y=presenter.y;
		  		 	}
		  		 	if(viewerVid && !fullScreenViewerBool)
	           	   	{
	           	   		viewerVid.x=viewer.x;
		            	viewerVid.y=viewer.y    
	           	    }
		             chatWndw.width=chat.width;
		             chatWndw.height=chat.height 
		             chatWndw.x=chat.x;
		             chatWndw.y=chat.y       
		             PopUpManager.addPopUp(chatWndw,chat);        
		             chatWndw.doubleClickEnabled=true;   
			   }
           }
            private function toFullscreen(evnt:MouseEvent):void
            { 
            	if(evnt.target==presenterVid)
            	{
            		//trace("anjj")
            	}  
            	else if(evnt.target==viewerVid) 
            	{  
            		//trace("vvvv")
            	} 
            	else if(evnt.currentTarget==presenterVid)
            	{
            		
            	}          
                                                 	
      		 }
      		 private function closePstrFSWndw(ev:KeyboardEvent):void
      		 {
      		 	/* if(ev.charCode==27)
      		 	{ 
      		 		fullScreenPresenter.close();     		 		
      		 	} */
      		 }
      		 private function closeVvrFSWndw(ev:KeyboardEvent):void
      		 {
      		 	/* if(ev.charCode==27)
      		 	{
      		 		fullScreenViewer.close();
      		 	} */
      		 }
      		 private function closeChatFSWndw(ev:KeyboardEvent):void
      		 {
      		 	/* if(ev.charCode==27)
      		 	{
      		 		fullScreenChat.close();
      		 	} */
      		 }
      		 private function wndslide(ev:SliderEvent):void
      		 {
      		 	/* trace(ev.value)
      		 	fullScreenPresenter.Videodisp.playheadTime=ev.value; */
      		 	
      		 }
      		private function seekBarValue(seekValue:Object):String
			{
				var time:Number=Number(seekValue)*1000;
				var Hours:uint= time / (1000*60*60);
				var Minutes:uint = (time % (1000*60*60)) / (1000*60);
				var Seconds:uint = ((time % (1000*60*60)) % (1000*60)) / 1000
				return Hours.toString()+":"+Minutes.toString()+":"+Seconds.toString() ; 			
			}
      		 public function seekChange(evnt:SliderEvent):void
      		 { 
				if(stopButton.enabled)
				{
					seekBar.setThumbValueAt(evnt.thumbIndex , Math.floor(evnt.value));
					var sliderObject:Slider = Slider(seekBar);
					playHeadTime =Math.floor( sliderObject.values[evnt.thumbIndex] * 1000);
					//if seek to the end
					if((playHeadTime/1000)>=Math.floor(seekBar.maximum))
					{
						if(Log.isInfo()) log.info("In seekChange Play End- Timer Stopped");	
						resetPlayer();
						return
						
					}
	      		 	wbPlayer.isRestore=true;
					presenterVid.videoPlayer.setContext(playHeadTime, seekBar.value, "pVideo", presenterVid.videoDisp);
					viewerVid.videoPlayer.setContext(playHeadTime, seekBar.value, "vVideo", viewerVid.videoDisp);
	      		 	/*timeVariable=Math.floor(evnt.value);	*/
	      		 	wbPlayer.clearWb();       
	      		 	updateReferenceTime();
	      		 	/* seekBar.value=Math.floor(evnt.value);
	      		 	playHeadTime=seekBar.value*1000; */
	      		 	wbPlayer.setContext(playHeadTime+100);  
					chatWndw.chatPlayer.updateChat(playHeadTime);
	      		 	docComp.documentPlayer.setContext(playHeadTime);
					presenterVid.lblVideoMode.visible=false;
					viewerVid.lblVideoMode.visible=false;
	      		 	pttPlayer.setContext(playHeadTime);
	      		 	seekUpdateCount=1;
	      		 	//centalTimer.start();
	      		 	this.dispatchEvent(new SliderEvent("Notify seek change"));  
	      		 	formatAndDisplayCentralTime()
				}
				else
				{
					seekBar.value=0;
				}
      		 }
      		
      		 private function addPopupWndw(ev:MouseEvent):void
      		 {
      		 	
      		 	if(ev.currentTarget.label=="CHAT"&&!chatBool)
      		 	{
      		 		PopUpManager.addPopUp(chatWndw,chat);
      		 		chatWndw.width=chat.width;
	                chatWndw.height=chat.height;
	                chatWndw.x=chat.x;
	                chatWndw.y=viewer.y+viewer.height+10;
      		 		chatBool=true;
      		 		chatBtn.enabled=false;
					//Fix for issue #17071
					applicationType::desktop{
	      		 		if(presenterVid && !fullScreenPresenterBool)
	      		 		{
	      		 			presenterVid.x=presenter.x;
	      		 			presenterVid.y=presenter.y;
	      		 		}
	      		 		if(viewerVid && !fullScreenViewerBool)
	      		 		{
	      		 			 viewerVid.x=viewer.x;
	                   		 viewerVid.y=presenter.y+presenter.height+10;
	      		 		}
					}
					applicationType::web{
						chatWndw.y=viewer.y+viewer.height+115;
						if(presenterVid && !fullScreenPresenterBool)
						{
							presenterVid.x=presenter.x;
							presenterVid.y=FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+10;
						}
						if(viewerVid && !fullScreenViewerBool)
						{
							viewerVid.x=viewer.x;
							viewerVid.y=presenter.y+presenter.height+110;
						}
					}
      		 	}
      		 	if(ev.currentTarget.label=="PRESENTER"&&!PresenterBool)
      		 	{
      		 		PopUpManager.addPopUp(presenterVid,presenter); 
      		 		presenterVid.x=presenter.x;
      		 		presenterVid.y=presenter.y;
      		 		PresenterBool=true;
      		 		pvdoBtn.enabled=false;
					//Fix for issue #17071
					applicationType::desktop{
	      		 		if(viewerVid && !fullScreenViewerBool)
	      		 		{
	      		 			 viewerVid.x=viewer.x;
	                   		 viewerVid.y=presenter.y+presenter.height+10;
	      		 		}
	      		 		if(chat && !fullScreenChatBool)
	      		 		{
	      		 			chatWndw.x=chat.x;
		                	chatWndw.y=viewer.y+viewer.height+10;
	      		 		}
					}
					applicationType::web{
						presenterVid.width = presenter.width;
						presenterVid.height = presenter.height;
						presenterVid.y=FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+10;
						if(viewerVid && !fullScreenViewerBool)
						{
							viewerVid.x=viewer.x;
							viewerVid.y=presenter.y+presenter.height+110;
						}
						if(chat && !fullScreenChatBool)
						{
							chatWndw.x=chat.x;
							chatWndw.y=viewer.y+viewer.height+115;
						}
					}
      		 	}
      		 	if(ev.currentTarget.label=="VIEWER"&&!ViewerBool)
      		 	{
      		 		PopUpManager.addPopUp(viewerVid,viewer);
      		 		viewerVid.width=viewer.width;
               	    viewerVid.height=viewer.height;
                    viewerVid.x=viewer.x;
                    viewerVid.y=presenter.y+presenter.height+10;
      		 		ViewerBool=true;
      		 		vvdoBtn.enabled=false;
					//Fix for issue #17071
					applicationType::desktop{
	      		 		if(presenterVid && !fullScreenPresenterBool)
	      		 		{
	      		 			presenterVid.x=presenter.x;
	      		 			presenterVid.y=presenter.y;
	      		 		}
	      		 		if(chat && !fullScreenChatBool)
	      		 		{
	      		 			chatWndw.x=chat.x;
		                	chatWndw.y=viewer.y+viewer.height+10;
	      		 		}
					}
					applicationType::web{
						viewerVid.x=viewer.x;
						viewerVid.y=presenter.y+presenter.height+110;
						if(presenterVid && !fullScreenPresenterBool)
						{
							presenterVid.x=presenter.x;
							presenterVid.y=FlexGlobals.topLevelApplication.mainApp.Aviewbanner.height*1.7+10;
						}
						if(chat && !fullScreenChatBool)
						{
							chatWndw.x=chat.x;
							chatWndw.y=viewer.y+viewer.height+115;
						}
					}
      		 		
      		 	}      		 	     		 	    		 	
      		 }
      		  private function addSlideWndw():void
      		 {
 				docComp.addChild(docComp.slideWndw);
 				docComp.baseContainer.percentWidth=100;
 				slideBtn.enabled=false;     	 	 	
      		 } 
      		 private function closePresenterWndw(ev:CloseEvent):void
      		 {   
      		 	PopUpManager.removePopUp(presenterVid);   
      		 	pvdoBtn.enabled=true;   		 
      		    PresenterBool=false;        		    		  		 	    		 	
      		 }
      		 private function closeViewerWndw(ev:CloseEvent):void
      		 {
      		 	PopUpManager.removePopUp(viewerVid); 
      		 	vvdoBtn.enabled=true;     		 	
      		 	ViewerBool=false;        		 	     	 		 	
      		 }      		
      		 private function closeChatWndw(ev:CloseEvent):void
      		 {      		 	
      		 	PopUpManager.removePopUp(chatWndw);  
      		 	chatBtn.enabled=true;    		 	  
      		 	chatBool=false;       		 	 	 		 	
      		 }
      		 public function endAppl():void
      		 {	  	 	   
            	centalTimer.stop();
				if(Log.isInfo()) log.info("In endAppl - Timer stopped");	
				
       		 }
       		 private function presenterFullWndwClose(ev:Event):void
       		 {   		 	
       		 	PopUpManager.addPopUp(presenterVid,presenter)   
       		 	prstlbl.visible=false;    		 	       		 
       		 	//fullScreenPresenter.Videodisp.removeEventListener(VideoEvent.PLAYHEAD_UPDATE,changevaluePstr);
       		 	presenterVid.x=presenter.x;
      		    presenterVid.y=presenter.y;     		    
       		 	fullScreenPresenterBool=false;
				applicationType::desktop{
       		 		fullScreenPresenter=null;
				}
       		 }
       		 private function viewerFullWndwClose(ev:Event):void
       		 {
       		   
       		    PopUpManager.addPopUp(viewerVid,viewer);	
       		    viwrlbl.visible=false; 
       		    viewerVid.width=viewer.width;
                viewerVid.height=viewer.height;
                viewerVid.x=viewer.x;
                viewerVid.y=presenterVid.y+presenterVid.height+10;      		    
       		 	fullScreenViewerBool=false;
				applicationType::desktop{
       		   		fullScreenViewer =null;
				}
       		 } 
       		 private function chatFullWndwClose(ev:Event):void
       		 {
       		    PopUpManager.addPopUp(chatWndw,FlexGlobals.topLevelApplication.chat);
       		    FlexGlobals.topLevelApplication.chatWndw.width=chat.width;
				FlexGlobals.topLevelApplication.chatWndw.height=chat.height;
				FlexGlobals.topLevelApplication.chatWndw.x=chat.x;
	            FlexGlobals.topLevelApplication.chatWndw.y=viewerVid.y+viewerVid.height+10;
       		    chatlbl.visible=false;
       		    fullScreenChatBool=false;	
       		 }
       		
       		public var tempCanWidth:Number=0;
       		private function onResizeWb(evt:ResizeEvent):void
		    {
		    	if( wbPlayer && wbPlayer.wbSprite)
		    	{
					wbCan.removeChild(whiteboardMask);
					wbCan.removeChild(wbPlayer.wbSprite);
					whiteboardMask=null;
					wbPlayer.wbSprite.width=wbCan.width	;
					wbPlayer.wbSprite.height=wbCan.height;
					wbPlayer.wbSprite.drawBackground(0xffffff);
					wbCan.addChild(wbPlayer.wbSprite);
					whiteboardMask=new Canvas()
					whiteboardMask.graphics.beginFill(0xffffff, 1);
					whiteboardMask.graphics.drawRect(0, 0, wbCan.width, wbCan.height);
					wbCan.mask=whiteboardMask;
					wbCan.addChild(whiteboardMask);
					if(playerInitialized )
					{
		    		 wbPlayer.setContext(playHeadTime+100);  
					}
		    	}
		    	
		    }
		
		   public function playPausePlayer():void
		    {
		    	if(playpauseButton.label=="Play" && (!stopButton.enabled))
		    	{   				
					pausedTimer=false;
		    		if(slideBtn.enabled)
					{
						addSlideWndw();
					}
		    		playpauseButton.label="Pause";
					if(!centalTimer.running)
					{
						updateReferenceTime();
						centalTimer.start();
						if(Log.isInfo()) log.info("In playPausePlayer - Timer started");
					}
		    	}
		    	else if(playpauseButton.label=="Play")
		    	{ 
				  presenterVid.videoPlayer.pausedCheck=false;
				  viewerVid.videoPlayer.pausedCheck=false;
				  if(presenterVid.videoPlayer.videoToggled)
				  {
		    		presenterVid.videoPlayer.netStreamVideo.togglePause();
					presenterVid.videoPlayer.videoToggled=false;
				  }
				  if(viewerVid.videoPlayer.videoToggled)
				  {
		    		viewerVid.videoPlayer.netStreamVideo.togglePause();
					viewerVid.videoPlayer.videoToggled=false;
				  }
		    		pausedTimer=false;
		    		playpauseButton.label="Pause";
					if(!centalTimer.running)
					{
						updateReferenceTime();
						centalTimer.start();
						if(Log.isInfo()) log.info("In playPausePlayer 2 - Timer started");
					}
		    		if(viewerVid.videoPlayer.isStreamReady)
		    		   viewerVid.videoPlayer.isVideoLoaded=true;
		    		if(presenterVid.videoPlayer.isStreamReady)
		    		   presenterVid.videoPlayer.isVideoLoaded=true;
		    		setTimeout(clearVideo,100);		    		
		    	}	    	
		    	else
		    	{  
					presenterVid.videoPlayer.pausedCheck=true;
					viewerVid.videoPlayer.pausedCheck=true;
					pausedTimer=true;
		    		playpauseButton.label="Play";
		    		centalTimer.stop();			
					if(Log.isInfo()) log.info("In playPausePlayer - Timer stopped");	
		    		if(presenterVid.videoPlayer.isStreamReady || presenterVid.videoPlayer.isVideoLoaded)
					{
       		 			presenterVid.videoPlayer.netStreamVideo.pause();
						presenterVid.videoPlayer.videoToggled=true;
					}
       		 		if(viewerVid.videoPlayer.isStreamReady || viewerVid.videoPlayer.isVideoLoaded)
					{
       		 			viewerVid.videoPlayer.netStreamVideo.pause();
						viewerVid.videoPlayer.videoToggled=true;
					}
		    	}
		    }
		    private function clearVideo():void
		    {
		    	if(presenterVid.videoPlayer.currentVideoEndTime<playHeadTime)		    	
		    		 {
		    		  presenterVid.videoDisp.mx_internal::videoPlayer.clear(); 
            		  presenterVid.videoPlayer.netStreamVideo.close();	 
		    		 } 
		    	if(viewerVid.videoPlayer.currentVideoEndTime<playHeadTime)
		    		{
		    		  viewerVid.videoDisp.mx_internal::videoPlayer.clear(); 
            		  viewerVid.videoPlayer.netStreamVideo.close();	 
		    		}				
				if(playpauseButton.label!="Pause")
				{
					if(!centalTimer.running)
					{
						updateReferenceTime();
						centalTimer.start();
						if(Log.isInfo()) log.info("In clearVideo- Timer Started");
					}
				}
		    }
			//Fix for issue #19317
			public function closePlayback():void
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.playBackActiveflag=0
				applicationType::desktop{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.player.close();
				}
				//Fix for issue #17071
				applicationType::web{
					//Following codes were added to remove AviewPlayer Instance and remove popup window
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.playBackActiveflag=0;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Library_canvas.removeAllChildren();
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.player = null;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Library_canvas.addChild(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst);
					//Added these logic to stop the player and close playback window when user clicks on 'Back to library'
					stopPalayBack();
					closePlayer();
					PopUpManager.removePopUp(chatWndw);
				}
			}
			public function stopPalayBack():void
		     {   				 				
				presenterVid.videoPlayer.pausedCheck=false;
				viewerVid.videoPlayer.pausedCheck=false;
				presenterVid.videoPlayer.videoToggled=false;
				viewerVid.videoPlayer.videoToggled=false;
		        pausedTimer=false;
		    	if(!stopButton.enabled)
		    	{
		    		playpauseButton.label="Pause";
					//Fix for issue #17071
					applicationType::desktop{
						if(!centalTimer.running)
						{
							updateReferenceTime();
							centalTimer.start();
							if(Log.isInfo()) log.info("In stopPalayBack- Timer Started");
						}
					}
					applicationType::web{
						if(centalTimer)
						{
							if(!centalTimer.running)
							{
								updateReferenceTime();
								centalTimer.start();
								if(Log.isInfo()) log.info("In stopPalayBack- Timer Started");
							}
						}
					}
				}
		    	else
		    	{
					if(playBackBufferingMessageComp.source!=null)
					{
						playBackBufferingMessageComp.unloadAndStop();
					}
					resetPlayer();				
		    	}
		    }
		  
