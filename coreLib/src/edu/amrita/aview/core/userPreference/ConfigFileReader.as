package edu.amrita.aview.core.userPreference
{

	
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ConfigFileReader
	{
		private var _jsonPath:String = "config/Settings.json";
		public static var configValues:Object;
		public function ConfigFileReader()
		{
			init();
			/*if (Stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, init);*/
		}
				
		private function init(e:Event = null):void 
		{
			//removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest();
			request.url = _jsonPath;
			loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderFaultHandler);
			loader.load(request);
		}
		
		private function onLoaderComplete(e:Event):void 
		{
			var loader:URLLoader = URLLoader(e.target);
			var jsonArray:Array = com.adobe.serialization.json.JSON.decode(loader.data);

			//trace("loader.data: " + loader.data);
			configValues = jsonArray[0];
		}
		
		private function onLoaderFaultHandler(e:Event):void{
			configValues = 	{		
				Whiteboard:
				{
					DebugMode : 0,
					EnableLineRenderTimeDelay : 0,
					LineRenderTimeDelayInMillisec : 100,
					Smoothing:
					{
						EnableLineSmoothing : 1,
						SkipPoints : 2,
						AddPointsBetweenLine : 0
					},
					DrawingFullScreen : 0,
					GarbageCollection:
					{
						BreakReuiredInSecBetweenWritingToCallGC : 10,
						NumberOfObjectRequiredToCallGC : 200,
						TimeGapRequiredInMinuteBetweenTwoGC : 5
					}
				}
				
			}
		}
		
	}
}