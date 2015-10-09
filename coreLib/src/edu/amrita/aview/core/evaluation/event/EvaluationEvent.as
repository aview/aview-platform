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
 * File			: EvaluationEvent.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * EvaluationEvent handles the evaluation
 *
 */
package edu.amrita.aview.core.evaluation.event
{
	import flash.events.Event;
	
	/**
	 * 
	 * The Event Class
	 * 
	 */
	public class EvaluationEvent extends Event
	{
		/**
		 * The event type 'createUpdate' w.r.t to Evaluation component
		 * like create,update category , subcategory , question paper etc... 
		 */
		public static const CREATE_OR_UPDATE:String = "createUpdate" ;
		
		/**
		 * Used as generic object , for passing value related to each event call 
		 */
		public var data:Object ;
		
		/**
		 * Default Constructor . Calls the super class to handle varous click events from child components
		 * @param type of type String
		 * @param eventObj of type Object
		 * 
		 */
		public function EvaluationEvent(type:String,value:Object = null)
		{
			super(type);
			this.data = value ;
		}
	}
}