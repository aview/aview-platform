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
 * File			: RecordedLectureVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Recorded Lecture
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.vo.RecordedLectureVO")]
	public class RecordedLectureVO
	{
		/**
		 * The lecture object
		 */
		var _lecture:LectureVO=null;
		/**
		 * The isModerator value
		 */
		var _isModerator:String=null;
		/**
		 * The useNewPlayer value
		 */
		var _useNewPlayer:Boolean=true;
		
		/**
		 * @public
		 * default constructor
		 */
		
		public function RecordedLectureVO()
		{
		}
		
		/**
		 * @public
		 * function to get lecture
		 *
		 * @return LectureVO
		 */
		public function get lecture():LectureVO
		{
			return this._lecture;
		}
		
		/**
		 * @public
		 * function to set lecture
		 * @param lecturevo type of LectureVO
		 * @return void
		 */
		public function set lecture(lecturevo:LectureVO):void
		{
			this._lecture=lecturevo;
		}
		
		/**
		 * @public
		 * function to get isModerator
		 *
		 * @return String
		 */
		
		public function get isModerator():String
		{
			return this._isModerator;
		}
		
		/**
		 * @public
		 * function to set isModerator
		 * @param value type of String
		 * @return void
		 */
		public function set isModerator(value:String):void
		{
			this._isModerator=value;
		}
		
		/**
		 * @public
		 * function to get useNewPlayer
		 *
		 * @return Boolean
		 */
		
		public function get useNewPlayer():Boolean
		{
			return this._useNewPlayer;
		}
		
		/**
		 * @public
		 * function to set userNewPlayer
		 * @param value type of Boolean
		 * @return void
		 */
		public function set userNewPlayer(value:Boolean):void
		{
			this._useNewPlayer=value;
		}
	}
}
