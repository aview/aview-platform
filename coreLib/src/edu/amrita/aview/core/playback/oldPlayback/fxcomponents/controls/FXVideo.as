/**
 * This package has the control functions for video player.
 * This fx video player is a open source component which is downloaded from the web which is an inbuilt API for the controls of a standard player.
 * The component is modified according to sync the document, whiteboard and chat modules.
 *    */
package edu.amrita.aview.core.playback.oldPlayback.fxcomponents.controls
{
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuItem;
	
	import mx.controls.VideoDisplay;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.MetadataEvent;
	import mx.events.SliderEvent;
	import mx.events.VideoEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import edu.amrita.aview.core.playback.oldPlayback.Aview_Playback;
	import edu.amrita.aview.core.playback.oldPlayback.fxcomponents.controls.fxvideo.PlayPauseButton;
	import edu.amrita.aview.core.playback.oldPlayback.fxcomponents.controls.fxvideo.StopButton;
	import edu.amrita.aview.core.playback.oldPlayback.fxcomponents.controls.fxvideo.VolumeButton;
	
	[Style(name="backColor", type="uint", format="Color")]
	
	/**
	 *  The color of the buttons on the control bar.
	 *
	 *  @default 0xeeeeee
	 */
	
	[Style(name="frontColor", type="uint", format="Color")]
	
	/**
	 *  The height of the control bar. Odd values look better.
	 *
	 *  @default 21
	 */
	
	[Style(name="controlBarHeight", type="Number")]
	
	/**
	 *  The name of the font used in the timer.
	 *
	 *  @default "Verdana"
	 */
	[Style(name="timerFontName", type="String", inherit="no")]
	
	/**
	 *  The size of the font used in the timer.
	 *
	 *  @default 9
	 */
	
	
	[Style(name="timerFontSize", type="Number")]
	
	/**
	 *  The FXVideo control lets you play an FLV file in a Flex application.
	 *  It supports progressive download over HTTP, streaming from the Flash Media
	 *  Server, and streaming from a Camera object.
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;controls:FXVideo&gt;</code> tag inherits all the tag
	 *  attributes of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;controls:FXVideo
	 *
	 *    <b>Styles</b>
	 *    backColor="0xFFF0FFFF"
	 *    frontColor="0xFFF5F5DC"
	 *    controlBarHeight="21"
	 *    timerFontName="Verdana"
	 *    timerFontSize="9"
	 *
	 *  /&gt;
	 *  </pre>
	 *
	 */
	
	
	public class FXVideo extends VideoDisplay
	{
		
		/**
		 *  Constructor.
		 */
		public var ready:Boolean=false;
		
		public var flag:Number=0;
		public var playBackObj:Aview_Playback=new Aview_Playback();
		
		public function FXVideo()
		{
			super();
			textFormat=new TextFormat();
			
			
			var newContextMenu:ContextMenu;
			newContextMenu=new ContextMenu();
			
			newContextMenu.hideBuiltInItems();
			var defaultItems:ContextMenuBuiltInItems=newContextMenu.builtInItems;
			defaultItems.print=true;
			
			var item:ContextMenuItem=new ContextMenuItem("About Player");
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			newContextMenu.customItems.push(item);
			
			contextMenu=newContextMenu;
		}
		
		
		private var textFormat:TextFormat;
		private var thumbHookedToPlayhead:Boolean=true;
		private var volumeBeforeMute:Number=0;
		private var loadProgress:Number=0;
		private var flo:Boolean=true;
		
		/** display objects */
		
		public var controlBar:UIComponent;
		public var playheadSlider:FXProgressSlider;
		private var volumeSlider:FXSlider;
		private var videoArea:UIComponent;
		private var ppButton:PlayPauseButton;
		private var stopButton:StopButton;
		private var volumeButton:VolumeButton;
		[Bindable]
		public var timerTextField:TextField;
		
		/** style */
		
		private var frontColor:uint;
		private var backColor:uint;
		private var controlBarHeight:uint;
		private var timerFontName:String;
		private var timerFontSize:Number;
		
		public var timerValue:Number;
		
		private var thumbPress_time:Number;
		private var thumbRelease_time:Number;
		private var mouseclick_time:Boolean=true;
		private var thumbflag:Boolean=true;
		
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.playback.oldPlayback.fxcomponents.controls.FXVideo.as");
		
		/** properties */
		
		private var _adjustVolumeOnScroll:Boolean=true;
		
		/**
		 *  Specifies whether the volume should adjust when users
		 *  scroll over the video.
		 *
		 *  @default true
		 */
		public function set adjustVolumeOnScroll(value:Boolean):void
		{
			_adjustVolumeOnScroll=value;
		}
		
		/**
		 *  @private
		 */
		
		public function get adjustVolumeOnScroll():Boolean
		{
			return _adjustVolumeOnScroll;
		}
		
		/** */
		
		private var _playPressed:Boolean;
		
		private function set playPressed(value:Boolean):void
		{
			_playPressed=value;
			(value) ? ppButton.state="pause" : ppButton.state="play"
		
		}
		
		private function get playPressed():Boolean
		{
			return _playPressed;
		}
		
		/**
		 * Creates any child components of the component. For example, the
		 * ComboBox control contains a TextInput control and a Button control
		 * as child components.
		 */
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			frontColor=getStyle("frontColor");
			if (!frontColor)
				frontColor=0xcccccc;
			
			backColor=getStyle("backColor");
			if (!backColor)
				backColor=0x555555;
			
			controlBarHeight=getStyle("controlBarHeight");
			if (!controlBarHeight)
				controlBarHeight=21;
			
			timerFontName=getStyle("timerFontName");
			if (!timerFontName)
				timerFontName="Verdana";
			
			timerFontSize=getStyle("timerFontSize");
			if (!timerFontSize)
				timerFontSize=9;
			
			addEventListener(MetadataEvent.METADATA_RECEIVED, onMetadataReceived);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			addEventListener(ProgressEvent.PROGRESS, onProgress);
//		addEventListener(VideoEvent.PLAYHEAD_UPDATE, onPlayheadUpdate);			aravindbc
			addEventListener(VideoEvent.STATE_CHANGE, onStateChange);
			addEventListener(VideoEvent.REWIND, onRewind);
			addEventListener(VideoEvent.COMPLETE, onComplete);
			addEventListener(VideoEvent.READY, onReady);
			
			videoArea=new UIComponent();
			addChild(videoArea);
			
			videoArea.addEventListener(MouseEvent.CLICK, pp_onClick);
			
			controlBar=new UIComponent();
			addChild(controlBar);
			
			playheadSlider=new FXProgressSlider();
			controlBar.addChild(playheadSlider);
			
			//	playheadSlider.addEventListener(SliderEvent.CHANGE, playhead_onChange);
			//playheadSlider.addEventListener(SliderEvent.THUMB_PRESS, onThumbPress);
			playheadSlider.addEventListener(SliderEvent.THUMB_RELEASE, onThumbRelease);
//		playheadSlider.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);		aravindbc
			//	playheadSlider.addEventListener(SliderEvent.THUMB_DRAG, onThumbDrag);
//		playheadSlider.addEventListener(MouseEvent.CLICK,onplayheadMouseclick)		aravindbc
			
			
			volumeSlider=new FXSlider();
			controlBar.addChild(volumeSlider);
			
			volumeSlider.addEventListener(SliderEvent.CHANGE, volume_onChange);
			
			ppButton=new PlayPauseButton();
			controlBar.addChild(ppButton);
			
			ppButton.addEventListener(MouseEvent.CLICK, pp_onClick);
			
			stopButton=new StopButton();
			controlBar.addChild(stopButton);
			
			stopButton.addEventListener(MouseEvent.CLICK, stop_onClick);
			
			volumeButton=new VolumeButton();
			controlBar.addChild(volumeButton);
			
			volumeButton.addEventListener(MouseEvent.CLICK, volume_onClick);
			
			timerTextField=new TextField();
			controlBar.addChild(timerTextField);
			
			(autoPlay) ? playPressed=true : playPressed=false
		}
		
		/**
		 * Commits any changes to component properties, either to make the
		 * changes occur at the same time, or to ensure that properties are set in
		 * a specific order.
		 */
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			ppButton.iconColor=frontColor;
			stopButton.iconColor=frontColor;
			volumeButton.iconColor=frontColor;
			
			playheadSlider.setStyle("thumbColor", frontColor);
			playheadSlider.setStyle("thumbOutlineColor", backColor);
			
			volumeSlider.maximum=1;
			volumeSlider.value=volume;
			volumeSlider.setStyle("thumbColor", frontColor);
			volumeSlider.setStyle("thumbOutlineColor", backColor);
			
			textFormat.color=frontColor;
			textFormat.font=timerFontName;
			textFormat.size=timerFontSize;
			
			timerTextField.defaultTextFormat=textFormat;
			
			
			if (playBackObj.switchViewFlag == true)
			{
				timerTextField.text=formatTime(playheadTime) + " / " + formatTime(totalTime);
			}
			else if (playBackObj.switchViewFlag == false)
			{
				timerTextField.text=formatTime(playheadTime) + " / " + formatTime(totalTime);
			}
			else
			{
				timerTextField.text="Loading";
			}
			
			timerTextField.selectable=false;
			timerTextField.autoSize=TextFieldAutoSize.LEFT;
		}
		
		/**
		 * Sizes and positions the children of the component on the screen based on
		 * all previous property and style settings, and draws any skins or graphic
		 * elements used by the component. The parent container for the component
		 * determines the size of the component itself.
		 */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var h:uint=controlBarHeight;
			
			// draw
			
			videoArea.graphics.clear();
			videoArea.graphics.beginFill(0xffcccc, 0);
			videoArea.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			
			controlBar.graphics.clear();
			controlBar.graphics.beginFill(backColor);
			controlBar.graphics.drawRect(0, 0, unscaledWidth, h);
			
			// size
			
			controlBar.setActualSize(unscaledWidth, h);
			ppButton.setActualSize(h, h);
			stopButton.setActualSize(h, h);
			volumeButton.setActualSize(h, h);
			///////////////////////////////////
			// Adjusted the width of seek bar and volume control bar since seek bar should be longer than the other
			// Issue #182 ---STARTS
			playheadSlider.setActualSize(unscaledWidth - h - 180, 9);
			volumeSlider.setActualSize(50, 9);
			// Issue #182 ---ENDS
			
			// position
			
			controlBar.x=0;
			controlBar.y=unscaledHeight;
			
			ppButton.x=0;
			ppButton.y=0;
			
			stopButton.x=h;
			stopButton.y=0;
			
			///////////////////////////////////
			// In order to increase the width of seekbar, its horizontal position is also changed 
			// Issue #182 ---STARTS
			playheadSlider.x=stopButton.x + h + 5;
			// Issue #182 ---ENDS
			playheadSlider.y=(controlBar.height - playheadSlider.height) / 2;
			
			///////////////////////////////////
			// In order to increase the width of seekbar, the position of timer text field is also changed 
			// Issue #182 ---STARTS        
			timerTextField.x=playheadSlider.x + playheadSlider.width + 2;
			timerTextField.y=(controlBar.height - timerTextField.height) / 2 - 1;
			// Issue #182 ---ENDS
			
			///////////////////////////////////
			// In order to increase the width of seekbar, the position of volume button is also changed 
			// Issue #182 ---STARTS  
			volumeButton.x=unscaledWidth - volumeSlider.width - 8 - volumeButton.width;
			// Issue #182 ---ENDS
			volumeButton.y=0;
			
			volumeSlider.x=unscaledWidth - volumeSlider.width - 6;
			volumeSlider.y=(controlBar.height - volumeSlider.height) / 2;
			;
		}
		
		private function onMenuItemSelect(event:ContextMenuEvent):void
		{
			navigateToURL(new URLRequest("http://www.amrita.edu"));
		}
		
		private function onMetadataReceived(event:MetadataEvent):void
		{
			playheadSlider.maximum=Math.round(totalTime);
			play();
			updateTimer();
		}
		
		private function onMouseWheel(event:MouseEvent):void
		{
			if (!_adjustVolumeOnScroll)
				return;
			volume+=event.delta / Math.abs(event.delta) * .05;
			volumeSlider.value=volume
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			loadProgress=Math.floor(event.bytesLoaded / event.bytesTotal * 100);
			var playheadProgress:Number=Math.floor(playheadTime / totalTime * 100);
			playheadSlider.progress=loadProgress;
		}
		
		private var sFlag:int=0;
		private var sTime:Number=0;
		
		/* 	public function onPlayheadUpdate(event:VideoEvent):void    This methos is not used
			{
				if(thumbHookedToPlayhead)
				{
					playheadSlider.value = Math.round(playheadTime);
					updateTimer();
					Application.application.lmsInst.design_LMS.chatRedraw(playheadTime);
					Application.application.lmsInst.design_LMS.objSprite.graphics.clear();
					Application.application.lmsInst.design_LMS.whiteboardRedraw(playheadTime);
					Application.application.lmsInst.design_LMS.updateSlide(Math.round(playheadTime));
				}
		
				if(flo)
				{
					thumbHookedToPlayhead = false;
				}
		
				if(flo && playheadTime > 0)
				{
					thumbHookedToPlayhead = true;
					stop();
					flo = false;
					if(_playPressed)
					{
						play();
					}
				}
			} */
		
		private function onStateChange(event:VideoEvent):void
		{
			if (event.state == VideoEvent.CONNECTION_ERROR)
			{
				timerTextField.text="Conn Error";
			}
		}
		
		private function onRewind(event:VideoEvent):void
		{
		
		}
		
		/**
		 * This method is called when the video downloading is completed.
		 * The method loads all the other modules that are related to this video and make the default play option false.
		 * Once the modules components are loaded the lms instance will be removed from the application.
		 * @param event This passes the video event when the downloading of the video is completed
		 * @return void   */
		private function onComplete(event:VideoEvent):void
		{
			Application.application.mainContainerComp.lmsInst.design_LMS.loadDocWBChatComponents();
			playPressed=false;
			Application.application.mainContainerComp.lmsInst.design_LMS.clearWBChatifDataisNull();
		}
		
		private function onReady(event:VideoEvent):void
		{
			play();
		}
		
		private function pp_onClick(event:MouseEvent):void
		{
			if (playPressed)
			{
				pause();
				playPressed=false;
			}
			else
			{
				play();
				playPressed=true;
			}
		}
		
		/******************************************************************Playhead Slider Events************************************************************/
		
		private function onThumbRelease(event:SliderEvent):void
		{
			if (thumbflag == false)
				play();
			
			thumbHookedToPlayhead=true;
			thumbRelease_time=Math.round(event.currentTarget.value);
			
			try
			{
				playheadSlider.value=thumbRelease_time;
				playheadTime=thumbRelease_time;
				if(Log.isInfo()) log.info(" thumbRelease_time" + playheadSlider.value);
			}
			catch (error:Error)
			{
				if(Log.isError()) log.error("catch of onThumbRelease"+ error.getStackTrace());
			}
			updateTimer();
			
			Application.application.mainContainerComp.lmsInst.design_LMS.chatReloadDuringSeek(thumbRelease_time);
			Application.application.mainContainerComp.lmsInst.design_LMS.objSprite.graphics.clear();
			Application.application.mainContainerComp.lmsInst.design_LMS.WBRedrawDuringSeek(thumbRelease_time);
			Application.application.mainContainerComp.lmsInst.design_LMS.syncSlidewithVideo(thumbRelease_time);
//		playheadSlider.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		/* private function playhead_onChange(event:SliderEvent):void
	{
		try
		{
			thumbHookedToPlayhead = true;
			playheadTime = event.currentTarget.value;
		}
		catch(error:Error)
		{
		
		}
		updateTimer();
		Application.application.lmsInst.design_LMS.chatRedraw(playheadTime);
		Application.application.lmsInst.design_LMS.objSprite.graphics.clear();
		Application.application.lmsInst.design_LMS.whiteboardRedraw(playheadTime);
		Application.application.lmsInst.design_LMS.updateSlide(Math.round(event.currentTarget.value));
	}
		
	private function onThumbPress(event:SliderEvent):void
	{
		thumbHookedToPlayhead = false;
		thumbPress_time=Math.round(event.currentTarget.value);
	}
		
	 private function onMouseDown(event:MouseEvent):void
	  {
		   thumbHookedToPlayhead = false;
	}
	 */
		 /* private function onThumbDrag(event:SliderEvent):void
	   {
			  timerTextField.text = formatTime(event.value)+" / "+formatTime(totalTime);
		   // playBackObj.remove();
		   thumbflag = false;
		   pause();
		 Application.application.lmsInst.design_LMS.chatRedraw(thumbRelease_time);
		   Application.application.lmsInst.design_LMS.objSprite.graphics.clear();
		   Application.application.lmsInst.design_LMS.whiteboardRedraw(thumbRelease_time);
		   Application.application.lmsInst.design_LMS.updateSlide(thumbRelease_time);
	   }
		   
			  private function onplayheadMouseclick(e:MouseEvent):void
	   {
			  try
		   {
		   playheadTime = Math.round(e.currentTarget.value);
		   playheadSlider.value = Math.round(e.currentTarget.value);
   //		Alert.show(Math.round(e.currentTarget.value).toString());
   //		Alert.show("time"+playheadTime);
		   }
		   catch(error:Error)
		   {
		   }
		   Application.application.lmsInst.design_LMS.chatRedraw(Math.round(e.currentTarget.value));
		   Application.application.lmsInst.design_LMS.objSprite.graphics.clear();
		   Application.application.lmsInst.design_LMS.whiteboardRedraw(Math.round(e.currentTarget.value));
		   Application.application.lmsInst.design_LMS.updateSlide(Math.round(e.currentTarget.value));
	   } */
		   
		   /* private function onMouseout(e:MouseEvent):void
		{
		
			playheadSlider.removeEventListener(MouseEvent.MOUSE_OUT,onMouseout);
		}
		 */
		
		private function volume_onChange(event:SliderEvent):void
		{
			volume=event.currentTarget.value;
		}
		
		/**
		 * This method is called when stop button is pressed. This loads again the all the other components and if LMS instance is existing will be removed
		 * @param event Mouse click event on the play/stop toggle button
		 * @return void */
		public function stop_onClick(event:MouseEvent):void
		{
			stop();
			flag=1;
			playPressed=false;
			
			Application.application.mainContainerComp.lmsInst.design_LMS.loadDocWBChatComponents();
			try
			{
				Application.application.mainContainerComp.lmsInst.design_LMS.clearWBChatifDataisNull();
			}
			catch (err:Error){
				if(Log.isError()) log.error("Error in stop_onClick method in FXVideo.as"+ err.getStackTrace());
			}
		}
		
		private function volume_onClick(event:MouseEvent):void
		{
			if (volume == 0)
			{
				volume=volumeSlider.value=volumeBeforeMute;
			}
			else
			{
				volumeBeforeMute=volume;
				volume=volumeSlider.value=0;
			}
		}
		
		public function formatTime(value:int):String
		{
			var result:String=(value % 60).toString();
			if (result.length == 1)
				result=Math.floor(value / 60).toString() + ":0" + result;
			else
				result=Math.floor(value / 60).toString() + ":" + result;
			return result;
		}
		
		public function updateTimer():void
		{
			timerTextField.text=formatTime(playheadTime) + " / " + formatTime(totalTime);
		}
	
	}
}
