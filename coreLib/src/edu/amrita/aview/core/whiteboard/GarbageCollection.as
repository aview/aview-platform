package edu.amrita.aview.core.whiteboard
{
	import edu.amrita.aview.core.userPreference.ConfigFileReader;
	
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.osmf.events.TimeEvent;
	
	public class GarbageCollection
	{
		public function GarbageCollection()
		{
		}
		/**
		 * Timer used to invoke garbage collection, if there is a long gap (5 sec) between user drawings. 
		 */
		private var garbageCollectionTimer:Timer;
		public var totalGCCalls = 1; //on page change it has to set to zero again.
		public var lastGCCall:Number;
		
		/**
		 * Function to check whether a garbage collection call is required or not.
		 */
		public function handleGarbageCollection(totalObjects:int):void{
			trace("handle garbage collection");
			var gc_config = ConfigFileReader.configValues.Whiteboard.GarbageCollection;
			var minuteDiff = gc_config.TimeGapRequiredInMinuteBetweenTwoGC;
			//find out how many minutes before the last gc call happened.
			if (lastGCCall !=0){
				var timeDiff:* = Math.floor(getTimer() - lastGCCall);
				var minuteDiff = int(timeDiff/(60*1000)) %60;
			}
			// wbCanvas.numElements;
			//If the total number of objects and the last gc call crossed the threshold values then call a timer to start gc. 
			if (totalObjects >(gc_config.NumberOfObjectRequiredToCallGC*totalGCCalls) && minuteDiff >= gc_config.TimeGapRequiredInMinuteBetweenTwoGC){
				garbageCollectionTimer=new Timer(gc_config.BreakReuiredInSecBetweenWritingToCallGC*1000,0);
				garbageCollectionTimer.start();
				garbageCollectionTimer.addEventListener(TimerEvent.TIMER,invokeGarbageCollection);
			}
		}
		
		/**
		 * Function to invoke Garbage collection.
		 * Since it needs more CPU memory this is called only at the time of page change 
		 * and when the the total number of objects and the last gc call crossed the threshold values.
		 * threshold values are stored in Settings.json 
		 */
		public function callGarbageCollection():void{ 
			lastGCCall = getTimer();
			System.gc();
			System.gc();
			stopGarbageCollectionTimer();
			trace("********************************calling gc***************************************");
		}
		
		/**
		 * Function to stop garbage collection timer. 
		 * It is called from two locations
		 * 1. After calling a garbage collection stop the timer
		 * 2. If the user start writing in between stop the timer. 
		 */
		public function stopGarbageCollectionTimer():void{
			if (garbageCollectionTimer && garbageCollectionTimer.hasEventListener(TimerEvent.TIMER)){
				garbageCollectionTimer.stop();
				garbageCollectionTimer.removeEventListener(TimerEvent.TIMER,callGarbageCollection);
			}
		}
		
		/**
		 * Temporary function to invoke garbage collection. The totalGCCalls should increase only from the garbageCollectionTimer event.
		 */
		private function invokeGarbageCollection(e:TimerEvent):void{
			totalGCCalls = totalGCCalls +1;
			callGarbageCollection();
		}
			
	}
}