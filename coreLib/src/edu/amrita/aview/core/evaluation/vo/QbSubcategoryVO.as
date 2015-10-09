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
 * File			: QbSubcategoryVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object class for Subcategory .
 *
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbSubcategory")]
	public class QbSubcategoryVO extends Auditable {
		/**
		 * The subcategory id : primary key
		 */
		private var _qbSubcategoryId:Number=0;

		/**
		 * The subcategory name
		 */
		private var _qbSubcategoryName:String=null;

		/**
		 * The category id
		 */
		private var _qbCategoryId:Number=0;

		/**
		 * The user name who created the subcategory
		 */
		private var _createdByUserName:String=null;

		/**
		 * The user name who modified the subcategory
		 */
		private var _modifiedByUserName:String=null;

		/**
		 * The total nos. of questions
		 */
		private var _totalQns:Number=0;

		/**
		 * The category name
		 */
		private var _qbCategoryName:String=null;

		/**
		 * @public
		 * Get the subcategory id
		 *
		 * @return Number
		 */
		public function get qbSubcategoryId():Number {
			return _qbSubcategoryId;
		}

		/**
		 * @public
		 * Set the subcategory id
		 * @param qbSubcategoryId the qbSubcategoryId to set
		 * @return void
		 */
		public function set qbSubcategoryId(qbSubcategoryId:Number):void {
			this._qbSubcategoryId=qbSubcategoryId;
		}

		/**
		 * @public
		 * Get the subcategory name
		 *
		 * @return String
		 */
		public function get qbSubcategoryName():String {
			return _qbSubcategoryName;
		}

		/**
		 * @public
		 * Set the subcategory name
		 * @param qbSubcategoryName the qbSubcategoryName to set
		 * @return void
		 */
		public function set qbSubcategoryName(qbSubcategoryName:String):void {
			this._qbSubcategoryName=qbSubcategoryName;
		}

		/**
		 * @public
		 * Get the category id
		 *
		 * @return Number
		 */
		public function get qbCategoryId():Number {
			return _qbCategoryId;
		}

		/**
		 * @public
		 * Set the category id
		 * @param qbCategoryId the qbCategoryId to set
		 * @return void
		 *
		 */
		public function set qbCategoryId(qbCategoryId:Number):void {
			this._qbCategoryId=qbCategoryId;
		}

		/**
		 * @public
		 * Get the creator user name
		 *
		 * @return String
		 *
		 */
		public function get createdByUserName():String {
			return _createdByUserName;
		}

		/**
		 * @public
		 * Set the creator user name
		 * @param value
		 * @return void
		 *
		 */
		public function set createdByUserName(value:String):void {
			_createdByUserName=value;
		}

		/**
		 * @public
		 * Get the modifier user name
		 *
		 * @return String
		 *
		 */
		public function get modifiedByUserName():String {
			return _modifiedByUserName;
		}

		/**
		 * @public
		 * Set the modifier user name
		 * @param value
		 * @return void
		 *
		 */
		public function set modifiedByUserName(value:String):void {
			_modifiedByUserName=value;
		}

		/**
		 * @public
		 * Get the total nos. of questions
		 *
		 * @return Number
		 *
		 */
		public function get totalQns():Number {
			return _totalQns;
		}

		/**
		 * @public
		 * Set the total nos. of questions
		 * @param value
		 * @return void
		 *
		 */
		public function set totalQns(value:Number):void {
			_totalQns=value;
		}

		/**
		 * @public
		 * Get the category name
		 *
		 * @return String
		 *
		 */
		public function get qbCategoryName():String {
			return _qbCategoryName;
		}

		/**
		 * @public
		 * Set the category name
		 * @param value
		 * @return void
		 *
		 */
		public function set qbCategoryName(value:String):void {
			_qbCategoryName=value;
		}


	}
}
