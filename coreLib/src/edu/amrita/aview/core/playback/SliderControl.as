package edu.amrita.aview.core.playback
{
	import mx.controls.HSlider;
	import mx.events.SliderEvent;
	
	public class SliderControl
	{
		private var slider:HSlider;
		public function SliderControl(slider:HSlider)
		{
			this.slider=slider;
			slider.addEventListener(SliderEvent.CHANGE,onSeekChange)
			slider.addEventListener(SliderEvent.THUMB_RELEASE,seekChange);	
			slider.addEventListener(MouseEvent.MOUSE_DOWN,onSeekBarMouseDown)
			
		}
		
		
		private function updateSeekBar():void
		{
			
		}
		
		private function onSeekChange():void
		{
			
		}

	}
}