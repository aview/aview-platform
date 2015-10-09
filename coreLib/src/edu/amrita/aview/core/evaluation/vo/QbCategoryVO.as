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
 * File			: QbCategoryVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object class for Qb Category .
 * Stores category to be used in creating question bank .
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	import mx.collections.ArrayCollection;
	
	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbCategory")]
	public class QbCategoryVO extends Auditable {
		
		/**
		 * Children of category i.e subcategory , used in QuestionBank.mxml
		 *  for displaying categories in tree component.
		 * 'children' variable is only detected by tree component for displaying the child value in the dataprovider.
		 */
		public var children:ArrayCollection=new ArrayCollection;
		
		/**
		 * The category id : primary key
		 */
		private var _qbCategoryId:Number=0;

		/**
		 * The name of category
		 */
		private var _qbCategoryName:String=null;

		/**
		 * The institute id
		 */
		private var _instituteId:Number=0;


		/**
		 * The name of user who created the category
		 */
		private var _createdByUserName:String=null;

		/**
		 *
		 * The name of user who modified the category
		 */
		private var _modifiedByUserName:String=null;

		/**
		 *The total nos. of questions
		 */
		private var _totalQuestions:Number=0;
		/**
		 * Dummy variable for UI
		 * Fix for Bug#11218
		 */
		public var displayIndex:Number=0;

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
		 * @param qbCategoryId the qb category id to set
		 * @return void
		 */
		public function set qbCategoryId(qbCategoryId:Number):void {
			this._qbCategoryId=qbCategoryId;
		}

		/**
		 * @public
		 * Get the category name
		 *
		 * @return String
		 */

		public function get qbCategoryName():String {
			return _qbCategoryName;
		}

		/**
		 * @public
		 * Set the category name
		 * @param qbCategoryName the qbCategoryName to set
		 * @return void
		 */
		public function set qbCategoryName(qbCategoryName:String):void {
			this._qbCategoryName=qbCategoryName;
		}

		/**
		 * @public
		 * Get the user name of category creator
		 *
		 * @return String
		 */

		public function get createdByUserName():String {
			return _createdByUserName;
		}

		/**
		 * @public
		 * Set the user name of category creator
		 * @param value
		 * @return void
		 */

		public function set createdByUserName(value:String):void {
			_createdByUserName=value;
		}

		/**
		 * @public
		 * Get the user name of category modifier
		 *
		 * @return String
		 */

		public function get modifiedByUserName():String {
			return _modifiedByUserName;
		}

		/**
		 * @public
		 * Set the user name of category modifier
		 * @param value
		 * @return void
		 */

		public function set modifiedByUserName(value:String):void {
			_modifiedByUserName=value;
		}

		/**
		 * @public
		 * Get the total nos. of questions
		 *
		 * @return Number
		 */
		public function get totalQuestions():Number {
			return _totalQuestions;
		}

		/**
		 * @public
		 * Set the total nos. of questions
		 * @param value
		 * @return void
		 */

		public function set totalQuestions(value:Number):void {
			_totalQuestions=value;
		}

		/**
		 * @public
		 * Get the institute id
		 *
		 * @return Number
		 */

		public function get instituteId():Number {
			return _instituteId;
		}

		/**
		 * @public
		 * Set the institute id
		 * @param value
		 * @return void
		 */

		public function set instituteId(value:Number):void {
			_instituteId=value;
		}


	}
}
