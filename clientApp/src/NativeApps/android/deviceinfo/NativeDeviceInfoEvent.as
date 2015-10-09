package NativeApps.android.deviceinfo
{
	
	import flash.events.Event;
	
	public class NativeDeviceInfoEvent extends Event
	{
		
		public static const PROPERTIES_PARSED:String="NativeDeviceInfoEvent.PROPERTIES_PARSED";
		
		public function NativeDeviceInfoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return super.clone();
		}
	}
}
