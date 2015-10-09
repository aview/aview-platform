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
 * File			: QuizQuestionAnswerItemRendererUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * Dispatches the event to handle the response sent by the user after attending quiz
 *
 */
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.evaluation.event.SendAnswerResponseEvent;
import edu.amrita.aview.core.evaluation.vo.QuizAnswerChoiceVO;

import flash.events.Event;

import mx.core.FlexGlobals;

/**
 * @protected
 *
 * Dispatches the send answer response event
 * @param qzAns type of QuizAnswerChoiceVO
 * @param event type of Event
 * @return void
 *
 */
protected function radiobutton1_changeHandler(qzAns:QuizAnswerChoiceVO, event:Event):void {
	/* If quiz answer choice is not null,then dispatch an event. */
	if (qzAns != null) {
		if (event.currentTarget.selected) {
			this.outerDocument.dispatchEvent(new SendAnswerResponseEvent(SendAnswerResponseEvent.RADIO_BUTTON_CHANGED, qzAns));
		} else {
			this.outerDocument.dispatchEvent(new SendAnswerResponseEvent(SendAnswerResponseEvent.CHK_BUTTON_CHANGED, qzAns));
		}
	}
}
