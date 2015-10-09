
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	
	public interface ISlidesCollection
	{
		function get slidesCount():Number;
		function getSlideInfo(slideIndex:Number):ISlideInfo;
		function get visibleSlidesCount():Number;
		function getVisibleSlide(visibleSlideIndex:Number):ISlideInfo;
	}
}
