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
 * File			: QbDifficultyLevelVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object class for Difficulty level
 * Stores various levels : easy , medium ,difficult
 *
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;
	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbDifficultyLevel")]
	public class QbDifficultyLevelVO extends Auditable {
		/**
		 * The difficulty level id : primary key
		 */
		private var _qbDifficultyLevelId:Number=0;

		/**
		 * The name of difficulty level
		 */
		private var _qbDifficultyLevelName:String=null;

		/**
		 * @public
		 * Get the difficulty level id
		 *
		 * @return Number
		 */
		public function get qbDifficultyLevelId():Number {
			return _qbDifficultyLevelId;
		}

		/**
		 * @public
		 * Set the difficulty level id
		 * @param qbDifficultyLevelId the qbDifficultyLevelId to set
		 * @return void
		 */
		public function set qbDifficultyLevelId(qbDifficultyLevelId:Number):void {
			this._qbDifficultyLevelId=qbDifficultyLevelId;
		}

		/**
		 * @public
		 * Get the difficulty level name
		 *
		 * @return String
		 */
		public function get qbDifficultyLevelName():String {
			return _qbDifficultyLevelName;
		}

		/**
		 * @public
		 * Set the difficulty level name
		 * @param qbDifficultyLevelName the qbDifficultyLevelName to set
		 * @return void
		 */
		public function set qbDifficultyLevelName(qbDifficultyLevelName:String):void {
			this._qbDifficultyLevelName=qbDifficultyLevelName;
		}


	}
}
