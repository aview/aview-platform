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
 * File			: DynamicTextArea.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * Used for question and answer choice display , in quiz
 *
 * This control is a multiline text field with a border and optional scroll bars
 */
package edu.amrita.aview.core.evaluation.quiz {
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;

	import mx.controls.TextArea;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	/*
	 * Class : DynamicTextArea
	 * Customized TextArea 
	*/
	public class DynamicTextArea extends TextArea {
		/* Default constructor */
		public function DynamicTextArea() {

			super();

			super.horizontalScrollPolicy="off";

			super.verticalScrollPolicy="off";

			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete);
			this.addEventListener(Event.CHANGE, adjustHeightHandler);

		}

		/**
		 * @private
		 * Handler for 'CREATION_COMPLETE' event.
		 * @param event type of FlexEvent
		 * @return void
		 */
		private function creationComplete(event:FlexEvent):void {
			textField.autoSize=TextFieldAutoSize.LEFT;
			textField.wordWrap=true;
		}

		/**
		 * @private
		 * Handler for 'UPDATE_COMPLETE' event.
		 * @param event type of FlexEvent
		 * @return void
		 */
		private function updateComplete(event:FlexEvent):void {
			if (super.height != Math.floor(textField.height))
				super.height=textField.height;
		}
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.evaluation.quiz.DynamicTextArea.as");
		
		/**
		 * @private
		 * Handler for 'CHANGE' event.
		 * @param event type of Event
		 * @return void
		 */
		private function adjustHeightHandler(event:Event):void {
			if(Log.isInfo()) log.info("textField.getLineMetrics(0).height: " + textField.getLineMetrics(0).height);
			/* Comparing text area height and text field height */
			if (height <= textField.textHeight + textField.getLineMetrics(0).height) {
				height=textField.textHeight;
				validateNow();
			}
		}
	}
}
