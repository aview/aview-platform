
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	
	public interface ISlideInfo
	{
		function get loaded():Boolean;
		function get duration():Number;
		function get startTime():Number;
		function get endTime():Number;
		function get level():Number;
		function get hidden():Boolean;
		function get index():Number;
		function get visibleIndex():Number;
		function get visibleStartTime():Number;
		function get visibleEndTime():Number;
		function get title():String;
		function get animationSteps():IAnimationSteps;
		function get notesText():String;
		function get startStepIndex():Number;
		function get endStepIndex():Number;
		function get slideText():String;
		function get notesTextNormalized():String;
		function get titleNormalized():String;
		function get visibleStartStepIndex():Number;
		function get visibleEndStepIndex():Number;
		function get presenterIndex():Number;
		function get resources():ISlideResources;
	}
}
