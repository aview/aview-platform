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
 * File			: QuizWindowUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 *
 * This component is used to setup the display of Quiz component in live classroom
 */
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quiz.QuizWindowUIHandler.as");


/**
 * @public
 * Used to close the quiz window used in desktop version
 *
 * @return void
 */

public function closeQuizWindow():void {
	try {
		// To close the quiz window.
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.quizObj.stop();
	} 
	catch (e:Error) {
		if(Log.isError()) log.error("Error in closeQuizWindow method:"+ e.getStackTrace());
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.quiz_count=0;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.LiveQuizIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.liveQuiz_unclicked;
}

/**
 * @private
 * Resize the quiz window in live classroom
 *
 * @return void
 */
private function resizeWindow():void {
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.onResizeQuizWindow();
}

