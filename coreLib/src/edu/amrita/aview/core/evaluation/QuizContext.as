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
 * File			:QuizContext.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	:
 *
 * This file contains all constants and shared variables in Evaluation module .
 */
package edu.amrita.aview.core.evaluation {
	import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
	
	import mx.collections.ArrayCollection;
	public class QuizContext {
		public function QuizContext() {
		}

		
		/**
		 * Maximum length of question paper name and question bank name
		 * while creating question paper or question bank respectively
		 */
		[Bindable]
		public static var TEXT_LENGTH:int = 60;

		/**
		 * Flag to indicate if a question paper is validated
		 */
		public static var isValidated:Boolean=false;

		/**
		 * Stores polling question type id
		 */
		[Bindable]
		public static var pollingQuestionTypeId:int = 0;

		// Different type of question
		public static const POLLING:String = "Polling";
		public static const MULTIPLECHOICE:String = "Multiple Choice";
		public static const MULTIPLERESPONSE:String = "Multiple Response";
		public static const TRUE_OR_FALSE:String = "True/False";
		
		public static var MULTIPLE_CHOICE_QUESTION_TYPE_ID:Number=1;
		public static var MULTIPLE_RESPONSE_QUESTION_TYPE_ID:Number=2;
		public static var POLLING_QUESTION_TYPE_ID:Number=3;
		public static var TRUE_OR_FALSE_QUESTION_TYPE_ID:Number=4;

		public static const ALERT_TITLE_INFORMATION:String = "Information";
		public static const ALERT_TITLE_ERROR:String = "Error";
		/**
		 * The text length of a node in tree
		 */
		public static const textLengthForTree:int = 15;

		/**
		 * Name of root node in Question Paper Tree component
		 */
		public static const ROOT_TREE_QUESTION_PAPER:String = "Question Paper";
		/**
		 * Name of root node in Question Bank Tree component
		 */
		public static const ROOT_TREE_QUESTIONBANK:String = "Question Bank";
		/**
		 * Name of root node in Quiz Tree component
		 */
		public static const ROOT_TREE_QUIZ:String = "Quiz";
		public static const EDIT_QUESTION_LABEL:String = "Edit Question";

		public static const YES:String = "Y";
		public static const NO:String = "N";

		// Pattern types in question paper
		public static const PATTERN_TYPE_RANDOM:String = "Random";
		public static const PATTERN_TYPE_SPECIFIC:String = "Specific";

		public static const NO_RESULT:String = "NA";
		public static const EMPTY_STRING:String = "";

		/**
		 * Quiz status
		 */
		public static const READY_QUIZ_STATUS:String = "Ready";

		// Quiz types
		public static const LIVE_QUIZ_TYPE:String = "Live";
		public static const ONLINE_QUIZ_TYPE:String = "Online";

		// Quiz response types		
		public static const PC_RESPONSE_TYPE:String = "P";
		public static const MOBILE_RESPONSE_TYPE:String = "M";
		
		// Used to generate alphabets from ASCII Code
		public static const ASCII_CODE:int = 97 ;
		
		public static const CREATE:String = "Create" ;
		
		public static const EDIT:String = "Edit" ;
		
		public static const QUESTION_PAPER_COMPLETE_STATUS:String = "Complete" ;
		
		public static const QUESTION_PAPER_INCOMPLETE_STATUS:String = "Incomplete" ;
			
		public static const MEDIA_FILE_TYPE_IMAGE:String = "Image" ;
		public static const MEDIA_FILE_TYPE_VIDEO:String = "Video" ;
		public static const MEDIA_FILE_TYPE_AUDIO:String = "Audio" ;
		/* Fix for Bug#11177 */
		public static const MAX_NO_OF_RANDOM_QUESTIONS:Number = 1000 ;
		/**
		 * @private
		 * Function :copyDataBySequence
		 * To copy data between 2 arraycollection by display sequence.
		 *
		 * @param dest type of ArrayCollection
		 * @param src type of ArrayCollection
		 * @return void
		 */
		public static function copyDataBySequence(dest:ArrayCollection, src:ArrayCollection):void {
			if ((src == null) || (dest == null)) 
			{
				return;
			} 
			
			ArrayCollectionUtil.copyData(dest, src);
			for (var i:int = 0; i < src.length; i++) 
			{
				(dest[i].qbAnswerChoices).removeAll();
				ArrayCollectionUtil.copyData(dest[i].qbAnswerChoices, 
						new ArrayCollection(sortAnswerChoices(src[i].qbAnswerChoices)));
			}
		}
		/**
		 * @private
		 * To sort answer choices
		 * @param answerChoices type of ArrayCollection
		 * @return Array
		 * 
		 */
		private static function sortAnswerChoices(answerChoices : ArrayCollection) : Array
		{
			var tempAnswerArray : Array = new Array(answerChoices.length);
			for (var j:int = 0; j < answerChoices.length; j++) 
			{
				tempAnswerArray[answerChoices[j].displaySequence - 1] = answerChoices[j];
			}
			return tempAnswerArray;
		}
		
		/**
		 * @private
		 * Function :copyDataByQuizSequence
		 * To copy data between 2 arraycollection by quiz sequence.
		 *
		 * @param dest type of ArrayCollection
		 * @param src type of ArrayCollection
		 * @return void
		 */
		public static function copyDataByQuizSequence(dest:ArrayCollection, src:ArrayCollection):void 
		{
			if ((src == null) || (dest == null)) 
			{
				return;
			} 
			ArrayCollectionUtil.copyData(dest, src);
			for (var i:int = 0; i < src.length; i++) 
			{
				(dest[i].quizAnswerChoices).removeAll();
				ArrayCollectionUtil.copyData(dest[i].quizAnswerChoices, 
				new ArrayCollection(sortAnswerChoices(src[i].quizAnswerChoices)));
			}
		}
		
		
		/**
		 * @private
		 * Returns the index of the element
		 * @param array type of ArrayCollection
		 * @param property type of String
		 * @param value type of String
		 * @return Number
		 *
		 */
		public static function getItemIndexByProperty(array:ArrayCollection, property:String, value:String):Number
		{
			// Loop through the array 
			for (var i:Number=0; i < array.length; i++)
			{
				// The temp object
				var obj:Object=Object(array[i]) ;
				
				// Return the index of the object if the value matches
				if (obj[property] == value)
				{
					return i;
				}
			}
			return -1;
		}
	}
}
