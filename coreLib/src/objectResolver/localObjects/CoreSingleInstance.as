package objectResolver.localObjects
{
	import edu.amrita.aview.core.whiteboard.WhiteboardComp;
	/**
	 * Class to create singleton objects for modules. Currently it is not using.
	 */
	public class CoreSingleInstance
	{
		public function CoreSingleInstance()
		{
		}
		
		/**
		 * Single instance for whiteboard component. It will be used inside/outside whiteboard to get sigleton object.
		 * Can access from all files as "CoreSingleInstance.wbComp"
		 */
		public static var wbComp:WhiteboardComp = new WhiteboardComp();
	}
}