package views.components.Drawer
{
	import Button.test.Button;
	
	import spark.components.SkinnableContainer;

	public class SliderContainer extends SkinnableContainer
	{
		/**
		 * To set to true, when user opens home component
		 */
		private var _opened:Boolean = false;
		
		/**
		 * Button instance
		 */
		[SkinPart(required="false")]
		public var openButton:Button;
		
		/**
		 * @public
		 *
		 * To get the value of whether component is open or not
		 *
		 * @return Boolean
		 */
		public function get opened():Boolean 
		{
			return _opened;
		}
		
		/**
		 * @public
		 *
		 * Set opened as true, when user clicks to open the component
		 * Set opened as false, when user clicks to hide the component
		 *
		 * @param moduleName holds the values of whether component is open or not
		 * @return void
		 */
		public function set opened(value:Boolean):void 
		{
			if (_opened != value) {
				_opened = value;
				invalidateSkinState();
			}
		}
		/**
		 * @public
		 *
		 * To get the current state of the component
		 *
		 * @return current state of the component whether component is open or not as String
		 */
		override protected function getCurrentSkinState():String 
		{
			return (opened ? 'opened' : super.getCurrentSkinState());
		}
	}
}