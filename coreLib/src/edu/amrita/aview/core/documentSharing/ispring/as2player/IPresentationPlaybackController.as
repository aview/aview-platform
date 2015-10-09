
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.IEventDispatcher;
	
	public interface IPresentationPlaybackController extends IEventDispatcher
	{
		function get playing():Boolean;
		function get currentSlideDuration():Number;
		function play():void;
		function pause():void;
		function gotoNextSlide(autoStart:Boolean=true):void
		function gotoPreviousSlide(autoStart:Boolean=true):void
		function gotoLastViewedSlide(autoStart:Boolean=true):void
		function get currentSlideIndex():Number;
		function gotoSlide(slideIndex:Number, autoStart:Boolean=true):void;
		function get currentSlidePlaybackPosition():Number;
		function pauseCurrentSlideAt(position:Number):void;
		function playCurrentSlideFrom(position:Number):void;
		function seek(position:Number):void;
		function endSeek(resumePlayback:Boolean=undefined):void;
		function get currentStepIndex():Number;
		function gotoNextStep():void;
		function gotoPreviousStep():void;
		function set animationStepPause(pause:Number):void;
		function playFromStep(stepIndex:Number):void;
		function pauseAtStepStart(stepIndex:Number):void;
		function pauseAtStepEnd(stepIndex:Number):void;
		function set automaticSlideSwitching(autoSwitch:Boolean):void;
		function get automaticSlideSwitching():Boolean;
		function get currentVisibleSlideIndex():Number;
		function gotoVisibleSlide(visibleSlideIndex:Number, autoStart:Boolean=true):void;
		function gotoFirstSlide(autoStart:Boolean=true):void;
		function gotoLastSlide(autoStart:Boolean=true):void;
		function get nextSlideIndex():Number;
		function get previousSlideIndex():Number;
	}
}
