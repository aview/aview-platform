package edu.amrita.aview.core.video
{
	import mx.containers.HBox;
	import mx.core.UIComponent;
	
	public interface IVideoWallLayout
	{
		function setFullScreenVideo():Boolean;
		function closeFullScreenVideo():Boolean;
		//parent can be either regular container or popout container
		function initializeComponent(parent:UIComponent, controlBar:ButtonContainer):void;


		function setParentLayout():void;
		function closeLayout(bool:Boolean):void;
		function removeVideoDisplay (username:String):void;
		function resizeVideoStreamDisplay():void;
		function removePresenterDisplay():void;
		function changeMainVideoInVideoWall(userName:String, streamName:String):void;
		function removeOldPresenterFromBigScreenInVideoWall(oldPresenter:String, newPresenter:String):void;
		applicationType::DesktopWeb{
			import edu.amrita.aview.core.video.VideoStreamDisplay;
			function addPresenterDisplay (tile:VideoStreamDisplay):void;
			function addViewerDisplay (tile:VideoStreamDisplay):void;
			function getPresenterVideoStreamDisplay():VideoStreamDisplay;
			function getViewerVideoStreamDisplay(viewerDisplay:VideoStreamDisplay):VideoStreamDisplay;
			function removeViewerDisplay(videoDisplay:VideoStreamDisplay):void;
			function getMainDisplay():VideoStreamDisplay;
		}
		applicationType::desktop{
			function initializePopOutComponent(parent:UIComponent, controlBar:ButtonContainer, popOutComponent:VideoWallPopOut):void
			//parent can be either regular container or popout container
			function setPopOutLayout(newParent:VideoWallPopOut):void;
		}
		//Fix for issue #17990
		applicationType::web{
			function resizeBaseContainer():void;
		}
	}
}