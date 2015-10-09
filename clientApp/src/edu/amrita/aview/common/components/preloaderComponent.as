/*

This package is a preloader which can be shown while loading the application.
This is taken from the following links:
	http://cookbooks.adobe.com/index.cfm?event=showdetails&postId=12756;
	Tour de Flex -> Other Components -> Preloaders (http://www.onflex.org/flexapps/components/CustomPreloader/GIF/)
Code modified by: Balaji

*/

package edu.amrita.aview.common.components
{
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    
    import mx.events.*;
    import mx.preloaders.*;
	public class preloaderComponent extends Sprite implements IPreloaderDisplay
	{
		[ Embed(source="/assets/images/preloaderScreen.png", mimeType="application/octet-stream") ]
		private var myLogo:Class;
		public var timerLoad:Timer;
		public var timer:Timer;
		private var logoLoader:Loader;
		private var timeOutID:uint;
		public function preloaderComponent()
		{
		}
		// Specify the event listeners.
        public function set preloader(preloader:Sprite):void {
            preloader.addEventListener(
	                FlexEvent.INIT_PROGRESS, handleInitProgress);
            preloader.addEventListener(
	                FlexEvent.INIT_COMPLETE, handleInitComplete);
        }
        
        public function initialize():void {
            logoLoader = new flash.display.Loader();     
            logoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, logoLoaderComplete);
            logoLoader.visible = false;
            logoLoader.loadBytes( new myLogo() as ByteArray );
            addChild(logoLoader);
			logoLoader.alpha = 0;
			onGoing();
			//Fix for issue #14226
			timeOutID = setInterval(setLoaderPosition,0.01);
        }
		// After the gif is loaded then display it.
	    private function logoLoaderComplete(event:Event):void
	    {
	        logoLoader.stage.addChild(this)
			setLoaderPosition();
	        logoLoader.visible=true;
			logoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, logoLoaderComplete);
	    } 
	   
	    private function handleInitProgress(event:Event):void {
			//Fix for issue #14226
			setLoaderPosition();
	    }
		public function onGoing():void
		{
			//Fix for issue #14226
			setLoaderPosition();
			timerLoad = new Timer( 1 );
			timerLoad.addEventListener( TimerEvent.TIMER, onGoingFade );                  
			timerLoad.start();
		}
		
		public function onGoingFade( event:TimerEvent ):void
		{
			//Fix for issue #14226
			timeOutID = setInterval(setLoaderPosition,0.01);
			//Added this check to avoid null object reference issue
			if(logoLoader)
			{
				if(logoLoader.alpha < 1)
				{
					logoLoader.alpha = logoLoader.alpha + .02;
					this.alpha = this.alpha + .02;
				}
				//if(logoLoader.alpha == 1) 
				else
				{
					timerLoad.removeEventListener( TimerEvent.TIMER, onGoingFade );     
					timerLoad.stop();
				} 
				//Fix for issue #14226
				setLoaderPosition();
			}
		}  
	    
	    //Application has downloaded so start the fade out.
	    private function handleInitComplete(event:Event):void {
			//Fix for issue #14226
			setLoaderPosition();
			var timer:Timer = new Timer(3000,1);
			timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
			timer.start();  
			setTimeout(closeScreen,3000);
	            }
		
		private function dispatchComplete(event:TimerEvent):void {
				            dispatchEvent(new Event(Event.COMPLETE));
				        }
		 
        public function closeScreen():void
        {
			//Fix for issue #14226
			setLoaderPosition();
			this.removeChild(logoLoader);
			logoLoader.unloadAndStop();
			logoLoader=null;
	    }   
		//Fix for issue #14226
		private function setLoaderPosition():void
		{
			if(timeOutID)
			{
				clearTimeout(timeOutID);
			}
			if(logoLoader)
			{
				logoLoader.x = logoLoader.stage.stageWidth/2 - logoLoader.width/2;
				logoLoader.y = logoLoader.stage.stageHeight/2 - logoLoader.height/2;
			}
		}
       
		public function get backgroundColor():uint {
            return 0;
        }
					        
        public function set backgroundColor(value:uint):void {
	    }
        
        public function get backgroundAlpha():Number {
	        return 0;
	    }
        
        public function set backgroundAlpha(value:Number):void {
        }
        
        public function get backgroundImage():Object {
            return null;
        }
        
        public function set backgroundImage(value:Object):void {
        }
        
        public function get backgroundSize():String {
            return "";
        }
        
        public function set backgroundSize(value:String):void {
        }
    
        public function get stageWidth():Number {
            return 0;
        }
        
        public function set stageWidth(value:Number):void {
        }
        
        public function get stageHeight():Number {
            return 0;
        }
        
        public function set stageHeight(value:Number):void {
        }

	}
}