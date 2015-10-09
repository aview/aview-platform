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
 * File			: StudentOffLineQuizViewUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This component is used to display the offline quiz
 * Offline quiz is a way of conducting quiz on a particular date, at a particular time
 * The user can login at the stipulated time , and take quiz.
 * After submitting the quiz , the user can view result instantly
 *
 */
import edu.amrita.aview.core.shared.components.ArrayCollectionExtended;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.quiz.StudentViewLiveQuiz;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
/**
 * Variable to hold quiz details. 
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO();

/**
 * List of active quizzes
 */
[Bindable]
private var quizResult:ArrayCollection;

/**
 * Calls the remote method
 */
private var quizHelper:QuizHelper;

/**
 * Logged in user id
 */
private var userId:Number=ClassroomContext.userVO.userId;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quiz.StudentOffLineQuizViewUIHandler.as");

/**
 * @public
 *
 * Calls the remote method to populate the available offline quizzes
 *
 * @return void
 */
public function init():void {
	quizHelper=new QuizHelper();
	quizHelper.getAllActiveQuizzesOffLineForStudent(userId,getAllActiveQuizzesOffLineForStudentResultHandler);
}

/**
 * @public
 * Handles the list of active quizzes
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQuizzesOffLineForStudentResultHandler(result:ArrayCollection):void {
	quizResult=new ArrayCollection();
	// If result from server is not null then add the result to quizResult arraycollection.
	if ((result != null) && (result.length != 0)) {
		var i:int=0;
		if(Log.isInfo()) log.info("getAllActiveQuizzesForStudentResultHandler");
		// Temporary ArrayCollectionExtended object to hold quiz result.
		var tmpAC:ArrayCollectionExtended=new ArrayCollectionExtended();
		// Temporary arraycollection to hold quiz result.
		var quiz:ArrayCollection;
		
		quiz=new ArrayCollectionExtended(result.source);
		// Adding all the elements in the quiz arraycollection to temporary ArrayCollectionExtended object
		// Assign this temporary ArrayCollectionExtended object to quizResult Arraycollection.
		for (i=0; i < quiz.length; i++) {
			tmpAC.addItem(quiz.getItemAt(i));
		}
		quizResult=tmpAC;
	}
}

/**
 * @private
 *
 * Displays the quiz , for the user to attend
 *
 * @return void
 *
 */
private function viewStudentAnswerSheet():void {
	//Component to display the quiz
	var studentAnswerSheet:StudentViewLiveQuiz;
	// If user select a result in datagrid then show the student answer sheet. 
	if (dgStudentResult.selectedIndex != -1) {
		studentAnswerSheet=StudentViewLiveQuiz(PopUpManager.createPopUp(this, StudentViewLiveQuiz, true));
		studentAnswerSheet.quizId=dgStudentResult.selectedItem.quizId;
		studentAnswerSheet.quizType=dgStudentResult.selectedItem.quizType;
		var timeLimit:int=dgStudentResult.selectedItem.durationSeconds;
		// If timeLimit is greater than 60 then change it to hours and minutes format.
		if (timeLimit >= 60) {
			var hours:int;
			var minutes:int;
			hours=timeLimit / 60;
			minutes=timeLimit % 60;
			studentAnswerSheet.displayHour=hours;
			studentAnswerSheet.displayMinutes=minutes;
		} else {
			studentAnswerSheet.displayMinutes=dgStudentResult.selectedItem.durationSeconds;
		}
		PopUpManager.centerPopUp(studentAnswerSheet);
		studentAnswerSheet.initApp();
		quizResult.removeItemAt(dgStudentResult.selectedIndex);
	}

}
