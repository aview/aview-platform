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
 * File			: LiveQuizResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This component is used to view result in live classroom
 *
 */
import edu.amrita.aview.core.evaluation.quiz.QuizResultViewerComponent;
import edu.amrita.aview.core.evaluation.quizResponse.StudentViewQuizResponse;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

/**
 * List of quizzes for a question paper
 */
[Bindable]
public var quizzesArray:ArrayCollection=new ArrayCollection;

/**
 * Object of QuizVO
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO;
/**
 * Constant for view result state
 */
private const VIEW_RESULT_STATE : String = "viewResult";
/**
 * Constant for list result state
 */
private const LIST_RESULT_STATE : String = "listResult";


/**
 *@private
 * Remove the pop up component
 *
 * @return void
 */
private function closeIt():void {
	PopUpManager.removePopUp(this);
}

/**
 * @private
 * Remove the pop up component by keyboard enter event
 * @param e type of KeyboardEvent
 * @return void
 */
//Fix for Bug #10664
private function closeItByKeyDown(e:KeyboardEvent):void {
	/* Check if user entered key is an 'ENTER' key ,then close the window. */
	if (e.keyCode == Keyboard.ENTER) {
		PopUpManager.removePopUp(this);
	}
}

/**
 *@private
 * Display the result component when the 'viewResult' state is entered
 *
 * @return void
 */
private function initializeResultWindow():void {
	/**
	 *  Object to refer 'QuizResultViewerComponent' component.
	 *  Component to view result. */
	var resultView:QuizResultViewerComponent=new QuizResultViewerComponent;
	resultView.percentHeight=95;
	vBoxResult.removeAllElements();
	vBoxResult.addElement(resultView);
	resultView.quizId=quizVO.quizId;
	resultView.quizVO=quizVO;
}

/**
 *@private
 * Display the student result windown when 'studentResult' state is entered
 *
 * @return void
 */
//Fix for Bug #10430
private function initializeStudentResultWindow():void {
	/**
	 *  Object to refer 'StudentViewQuizResponse' component.
	 *  Component to view result for students. */
	var resultView:StudentViewQuizResponse=new StudentViewQuizResponse;
	resultView.fromLiveQuiz = true;
	resultView.percentHeight=95;
	vBoxResult.removeAllElements();
	resultView.quizVO=quizVO;
	vBoxResult.addElement(resultView);
}

/**
 * @private
 * Formats the date as string
 * @param item type of Object
 * @param column type of DataGridColumn
 * @return String
 *
 */
//Fix for Bug #10691
private function getDateLabel(item:Object, column:DataGridColumn):String {
	return dateFormatter.format(item[column.dataField]);
}


/**
 * @protected
 * Handles double click on the datagrid
 * @param event type of MouseEvent
 * @return void
 */
protected function quizzesGridDoubleClickHandler(event:MouseEvent):void {
	/* If user select an item in datagrid,then goto viewResult state to show the quiz result. */
	if (dgQuiz.selectedItem) {
		btnBack.visible=true;
		//Fix for Bug #11447
		btnBack.includeInLayout=true;
		this.quizVO=dgQuiz.selectedItem as QuizVO;
		this.currentState = VIEW_RESULT_STATE;
	}
}

/**
 * @protected
 * Enables viewing of list of quizzes
 * @param event type of MouseEvent
 * @return void
 */
protected function backButtonClickHandler(event:MouseEvent):void {
	btnBack.visible = false;
	//Fix for Bug #11447
	btnBack.includeInLayout = false;
	this.currentState = LIST_RESULT_STATE;
}
