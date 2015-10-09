////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: BrandingAttributeVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Branding Attribute
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.BrandingAttribute")]
	public final class BrandingAttributeVO extends Auditable
	{
		//Constant for logo
		public static const LOGO:String="LOGO";
		//Constant for style sheet
		public static const STYLE_SHEET:String="STYLE_SHEET";
	
		//Static variable for logo branding attribute details
		public static var logoBrandingAttributeVO:BrandingAttributeVO=null;
		//Static variable for style branding attribute details
		public static var styleBrandingAttributeVO:BrandingAttributeVO=null;
		
		/**
		 * The branding attribute id
		 */
		private var _brandingAttributeId:Number=0;
		/**
		 * The branding attribute name
		 */
		private var _brandingAttributeName:String=null;
		
		/**
		 * @public
		 * Default constructor
		 * 
		 */
		public function BrandingAttributeVO()
		{
			super();
		}
		
		/**
		 * @public
		 * Function to get branding attribute id
		 *
		 * @return Number
		 */
		public function get brandingAttributeId():Number
		{
			return _brandingAttributeId;
		}
		
		/**
		 * @public
		 * Function to set branding attribute id by value
		 * @param value type of Number
		 * @return void
		 */
		public function set brandingAttributeId(value:Number):void
		{
			_brandingAttributeId=value;
		}
		
		/**
		 * @public
		 * Function to get branding attribute name
		 *
		 * @return String
		 */
		public function get brandingAttributeName():String
		{
			return _brandingAttributeName;
		}
		
		/**
		 * @public
		 * Function to set branding attribute Name by value
		 * @param value type of String
		 * @return void
		 */
		public function set brandingAttributeName(value:String):void
		{
			_brandingAttributeName=value;
		}
	}
}
