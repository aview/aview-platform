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
 * File			: InstituteBrandingVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Institute Branding 
 * 
 */

package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.InstituteBranding")]
	public class InstituteBrandingVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function InstituteBrandingVO()
		{
			super();
		}
		/**
		 * The institute branding id
		 */
		private var _instituteBrandingId:Number=0;
		/**
		 * The institute object
		 */
		private var _institute:InstituteVO=null;
		/**
		 * The branding attribute object
		 */
		private var _brandingAttribute:BrandingAttributeVO=null;
		/**
		 * The branding attribute value
		 */
		private var _brandingAttributeValue:String=null;
		
		/**
		 * @public
		 * function to get brandingAttribute
		 *
		 * @return BrandingAttributeVO
		 */
		public function get brandingAttribute():BrandingAttributeVO
		{
			return _brandingAttribute;
		}
		
		/**
		 * @public
		 * function to set brandingAttribute
		 * @param value type of BrandingAttributeVO
		 * @return void
		 */
		public function set brandingAttribute(value:BrandingAttributeVO):void
		{
			_brandingAttribute=value;
		}
		
		/**
		 * @public
		 * function to get institute
		 *
		 * @return InstituteVO
		 */
		public function get institute():InstituteVO
		{
			return _institute;
		}
		
		/**
		 * @public
		 * function to set institute
		 * @param value type of InstituteVO
		 * @return void
		 */
		public function set institute(value:InstituteVO):void
		{
			_institute=value;
		}
		
		/**
		 * @public
		 * function to get instituteBrandingId
		 *
		 * @return Number
		 */
		public function get instituteBrandingId():Number
		{
			return _instituteBrandingId;
		}
		
		/**
		 * @public
		 * function to set instituteBrandingId
		 * @param value type of Number
		 * @return void
		 */
		public function set instituteBrandingId(value:Number):void
		{
			_instituteBrandingId=value;
		}
		
		/**
		 * @public
		 * function to get brandingAttributeValue
		 *
		 * @return String
		 */
		public function get brandingAttributeValue():String
		{
			return _brandingAttributeValue;
		}
		
		/**
		 * @public
		 * function to set brandingAttributeValue
		 * @param value type of String
		 * @return void
		 */
		public function set brandingAttributeValue(value:String):void
		{
			_brandingAttributeValue=value;
		}
	}
}
