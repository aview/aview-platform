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
 * File			: QbQuestionTypeVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Question Type .
 * Stores values : multiple choice , multiple response
 *
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbQuestionType")]
	public class QbQuestionTypeVO extends Auditable {
		/**
		 * The question type id : primary key
		 */
		private var _qbQuestionTypeId:Number=0;

		/**
		 * The question type name
		 */
		private var _qbQuestionTypeName:String=null;

		/**
		 * @public
		 * Get the question type id
		 *
		 * @return Number
		 */
		public function get qbQuestionTypeId():Number {
			return _qbQuestionTypeId;
		}

		/**
		 * @public
		 * Set the question type id
		 * @param qbQuestionTypeId the qbQuestionTypeId to set
		 * @return void
		 */
		public function set qbQuestionTypeId(qbQuestionTypeId:Number):void {
			this._qbQuestionTypeId=qbQuestionTypeId;
		}

		/**
		 * @public
		 * Get the question type name
		 *
		 * @return String
		 */
		public function get qbQuestionTypeName():String {
			return _qbQuestionTypeName;
		}

		/**
		 * @public
		 * Set the question type name
		 * @param qbQuestionTypeName the qbQuestionTypeName to set
		 * @return void
		 */
		public function set qbQuestionTypeName(qbQuestionTypeName:String):void {
			this._qbQuestionTypeName=qbQuestionTypeName;
		}
	}
}
