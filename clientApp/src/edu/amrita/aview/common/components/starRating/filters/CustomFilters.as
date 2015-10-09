/**
 * This component has taken from the following link
 * http://www.adobe.com/cfusion/exchange/index.cfm?event=extensionDetail&extid=1800523
 *
 * **/

/**
 *
 * File			: CustomFilters.as
 * Module		: Rating Component
 * Reviewer(s)	: Remya T,Vishnupreethi k
 */
/**
 * VPCR: Add file description */

package edu.amrita.aview.common.components.starRating.filters
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	
	/**
	 * VPCR: Add class description */
	
	
	public class CustomFilters
	{
     /**
	 * VPCR: Add variable description */
		
		private static var dropShadowFilter:DropShadowFilter=new DropShadowFilter();
		/**
		 * VPCR: Add function description for all the functions */
		
		/**
		 * @public 
		 * @return BitmapFilter
		 * 
		 */
		public static function getGradientGlowFilter():BitmapFilter
		{
			return new GradientGlowFilter(5, 45, [0xFFFFFF, 0xFFFFFF], [0.5, 0.5], [0, 176, 255], 5, 5, 2.5, BitmapFilterQuality.HIGH, BitmapFilterType.OUTER, false);
		}
		
		/**
		 * @public 
		 * @return BitmapFilter
		 * 
		 */
		
		
		public static function getGradientBevelFilter():BitmapFilter
		{
			return new GradientBevelFilter(3, 225, [0xe3d3e3, 0xCCCCCC, 0x000000], [1, 0, 0], [0, 0, 0], 2, 2, 2, BitmapFilterQuality.HIGH, BitmapFilterType.OUTER, true);
		}
		
		/**
		 * @public 
		 * @return BitmapFilter
		 * 
		 */
		
		public static function getSmallCardGlowFilter():BitmapFilter
		{
			return new GradientGlowFilter(0, 45, [0xFFFFFF, 0xFFFFFF], [0, 0.7,], [0, 63], 5, 5, 2.5, BitmapFilterQuality.HIGH, BitmapFilterType.FULL, false);
		}
		
		/**
		 * @public 
		 * @return BitmapFilter
		 * 
		 */
		
		public static function getShadowFilter(angle:Number=215):BitmapFilter
		{
			dropShadowFilter.alpha=0.7;
			dropShadowFilter.distance=3;
			dropShadowFilter.angle=angle;
			dropShadowFilter.color=0x000000;
			
			return dropShadowFilter;
		}
		
		/**
		 * @public 
		 * @return BitmapFilter
		 * 
		 */
		
		public static function getGlowFilter():BitmapFilter
		{
			return new GradientGlowFilter(5, 45, [0xc0d9fb, 0xc0d9fb], [0.3, 0.3], [3, 3], 2, 2, 1.5, BitmapFilterQuality.HIGH, BitmapFilterType.INNER, false);
		}
		
		
		/**
		 * @public 
		 * @param angle of type Number default value=215
		 * @return BitmapFilter
		 * 
		 */
		public static function getFilterForGAC(angle:Number=215):BitmapFilter
		{
			dropShadowFilter.alpha=0.7;
			dropShadowFilter.distance=3;
			dropShadowFilter.angle=angle;
			dropShadowFilter.color=0xFF2700;
			
			return dropShadowFilter;
		}
	}
}
