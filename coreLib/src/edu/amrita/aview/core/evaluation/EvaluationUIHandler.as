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
 * File			: QuizUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This is the parent component for all quiz activities like question bank , question paper and quiz
 * It delegates the control to the specific component as per the users choice
 *
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QbCategoryHelper;
import edu.amrita.aview.core.evaluation.helper.QbDifficultyLevelHelper;
import edu.amrita.aview.core.evaluation.helper.QbQuestionTypeHelper;
import edu.amrita.aview.core.evaluation.helper.QbSubcategoryHelper;
import edu.amrita.aview.core.evaluation.polling.PollingResultForStudent;
import edu.amrita.aview.core.evaluation.questionBank.QuestionBank;
import edu.amrita.aview.core.evaluation.questionPaper.QuestionPaper;
import edu.amrita.aview.core.evaluation.quiz.QuizResult;
import edu.amrita.aview.core.evaluation.quiz.StudentMobileViewLiveQuiz;
import edu.amrita.aview.core.evaluation.quiz.StudentOffLineQuizView;
import edu.amrita.aview.core.evaluation.quiz.StudentViewLiveQuiz;
import edu.amrita.aview.core.evaluation.vo.QbQuestionTypeVO;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.display.DisplayObject;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

/**
 * Flag variable to denote getAllActiveQbQuestionTypes excecution is complete 
 */
private var qbQuestionTypeHelperExecuted:Boolean=false;
/**
 * Flag variable to denote getAllActiveDifficultyLevels excecution is complete 
 */
private var qbDifficultyLevelHelperROExecuted:Boolean=false;
/**
 * Flag variable to denote getAllActiveQbCategoriesForUser excecution is complete 
 */
private var qbCategoryHelperROExecuted:Boolean=false;
/**
 * Flag variable to denote getAllActiveQbSubcategoriesForUser excecution is complete 
 */
private var qbSubcategoryHelperROExecuted:Boolean=false;

// Various components to be display in the parent component on appropriate selection
private var qb:QuestionBank;
private var qp:QuestionPaper;
private var quiz:QuizResult;
private var studentQuiz:StudentOffLineQuizView;
public var polling:PollingResultForStudent=new PollingResultForStudent();

// Used to call remote methods
private var qbDifficultyLevelHelperRO:QbDifficultyLevelHelper;
private var qbCategoryHelperRO:QbCategoryHelper;
private var qbSubcategoryHelperRO:QbSubcategoryHelper;
private var qbQuestionTypeHelperRO:QbQuestionTypeHelper;
// Used to display quiz in live classroom
applicationType::DesktopWeb{
	private var studentLiveQuizView:StudentViewLiveQuiz;
}
applicationType::mobile{
	[Bindable]
	public var studentLiveQuizView:StudentMobileViewLiveQuiz;
}
// Used for getting questions for quiz in live classroom
private var forPopUpQuizId:String;

/**
 * For debug log
 */
applicationType::DesktopWeb{
	private var log:ILogger=Log.getLogger("aview.modules.evaluation.EvaluationUIHandler.as");
}
/**
 * @public
 * Sets the initial data like enable/disable buttons , calling remote methods etc
 * 
 * @return void
 */
public function initEvaluation():void
{
	applicationType::DesktopWeb{
		// Checking whether login user's role is teacher
		if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
		{
			qbQuestionTypeHelperExecuted=false;
			qbDifficultyLevelHelperROExecuted=false;
			qbCategoryHelperROExecuted=false;
			qbSubcategoryHelperROExecuted=false;
			
			qbDifficultyLevelHelperRO=new QbDifficultyLevelHelper();
			qbCategoryHelperRO=new QbCategoryHelper();
			qbSubcategoryHelperRO=new QbSubcategoryHelper();
			qbQuestionTypeHelperRO=new QbQuestionTypeHelper();
			
			qbQuestionTypeHelperRO.getAllActiveQbQuestionTypes(getAllActiveQbQuestionTypesResultHandler);
			qbDifficultyLevelHelperRO.getAllActiveDifficultyLevels(getAllActiveDifficultyLevelsResultHandler);
			qbCategoryHelperRO.getAllActiveQbCategoriesForUser(ClassroomContext.userVO.userId,getAllActiveQbCategoriesForUserResultHandler);
			qbSubcategoryHelperRO.getAllActiveQbSubcategoriesForUser(ClassroomContext.userVO.userId,getAllActiveQbSubcategoriesForUserResultHandler);
			qbQuestionTypeHelperRO.getQbQuestionTypeByName(QuizContext.POLLING,getQbQuestionTypeByNameResultHandler)
			// Checking whether the user is in the classroom or not.
			if (ClassroomContext.checkIsClassRoom)
			{
				if (hBoxParent.contains(btnQuestionBank) && hBoxParent.contains(btnQuestionPaper) && hBoxParent.contains(btnQuiz))
				{
					hBoxParent.removeChild(btnQuestionBank);
					hBoxParent.removeChild(btnQuestionPaper);
					hBoxParent.removeChild(btnQuiz);
					hBoxParent.removeChild(btnTodayQuiz);
					hBoxParent.removeChild(btnPollingResult);
				}
				showQuestionPaper();
			}
			else
			{
				hBoxParent.addChild(btnQuestionBank);
				hBoxParent.addChild(btnQuestionPaper);
				hBoxParent.addChild(btnQuiz);
				btnQuestionBank.enabled=true;
				btnQuestionPaper.enabled=true;
				btnQuiz.enabled=true;
				btnTodayQuiz.visible=false;
				btnTodayQuiz.includeInLayout=false;
				btnPollingResult.visible=false;
				btnPollingResult.includeInLayout=false;
			}
		}
		else
		{
			btnQuestionBank.includeInLayout=false;
			btnQuestionPaper.includeInLayout=false;
			showQuiz();
		}
	}
}

/**
 * @public
 * Display question bank component
 *
 * @return void
 */
public function showQuestionBank():void
{
	applicationType::DesktopWeb{
		// Enable visibility of the component only if all the remote methods execute successfully
		if ((qbQuestionTypeHelperExecuted == true) && (qbDifficultyLevelHelperROExecuted == true) && (qbCategoryHelperROExecuted == true) && (qbSubcategoryHelperROExecuted == true) && (ClassroomContext.checkIsClassRoom == false))
		{
			if (qb == null)
			{
				qb=new QuestionBank;
			}
			canEvaluationComponent.removeAllChildren();
			canEvaluationComponent.addChild(qb);
			btnQuestionBank.enabled=false;
			btnQuestionPaper.enabled=true;
			btnQuiz.enabled=true;
		}
	}
}

/**
 * @public
 * Display question paper component
 *
 * @return void
 */
public function showQuestionPaper():void
{
	applicationType::DesktopWeb{
		// If qp is null then initialise it with QuestionPaper component.
		if (qp == null)
		{
			qp=new QuestionPaper;
		}
		
		canEvaluationComponent.removeAllChildren();
		canEvaluationComponent.addChild(qp);
		
		btnQuestionBank.enabled=true;
		btnQuestionPaper.enabled=false;
		btnQuiz.enabled=true;
	}
}

/**
 * @public
 * Display quiz component
 *
 * @return void
 */
public function showQuiz():void
{
	applicationType::DesktopWeb{
		canEvaluationComponent.removeAllChildren();
		btnQuestionBank.enabled=true;
		btnQuestionPaper.enabled=true;
		btnQuiz.enabled=false;
		btnTodayQuiz.enabled=true;
		btnPollingResult.enabled=true;
		// If user role is teacher, then add TodayQuiz button and remove PollingResult button. 
		if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
		{
			btnTodayQuiz.includeInLayout=true;
			btnPollingResult.includeInLayout=false;
		}
		// If user role is student, then add TodayQuiz and PollingResult button. 
		if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE)
		{
			btnTodayQuiz.includeInLayout=true;
			btnPollingResult.includeInLayout=true;
		}
		// If quiz is null then initialise it with QuizResult component. 
		if (quiz == null)
		{
			quiz=new QuizResult;
		}
		canEvaluationComponent.addChild(quiz);
		quiz.initApp();
	}
}

/**
 * @public
 * Display the offline quiz component
 *
 * @return void
 */
public function showAvailableQuiz():void
{
	applicationType::DesktopWeb{
		canEvaluationComponent.removeAllChildren();
		btnQuestionBank.enabled=true;
		btnQuestionPaper.enabled=true;
		btnQuiz.enabled=true;
		btnTodayQuiz.enabled=false;
		btnTodayQuiz.includeInLayout=true;
		btnPollingResult.enabled=true;
		btnPollingResult.includeInLayout=true;
		// If studentQuiz is null then initialise it with StudentOffLineQuizView component.
		if (studentQuiz == null)
		{
			studentQuiz=new StudentOffLineQuizView;
		}
		canEvaluationComponent.addChild(studentQuiz);
		studentQuiz.init();
	}
}

/**
 * @public
 * Display the polling result component
 *
 * @return void
 */
public function showPollingQuizToStudent():void
{
	applicationType::DesktopWeb{
		canEvaluationComponent.removeAllChildren();
		btnQuestionBank.enabled=true;
		btnQuestionPaper.enabled=true;
		btnQuiz.enabled=true;
		btnTodayQuiz.enabled=true;
		btnTodayQuiz.includeInLayout=true;
		btnPollingResult.enabled=false;
		btnPollingResult.includeInLayout=true
		// If studentQuiz is null then initialise it with PollingResultForStudent component.
		if (studentQuiz == null)
		{
			polling=new PollingResultForStudent();
		}
		canEvaluationComponent.addChild(polling);
		polling.initializePollingResult();
	}
}

/**
 * @public
 *
 * Gets all active question types
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQbQuestionTypesResultHandler(result:ArrayCollection):void
{
	//Fix for Bug#15194
	if(result != null)
	{
		if(Log.isInfo()) log.info("SubcategoryView::getAllActiveQbQuestionTypes_resultHandler::result::" + result.toString());
		if(result.length > 0)
		{
			ClassroomContext.quizQuestionTypes=new ArrayCollection;
			ArrayCollectionUtil.copyData(ClassroomContext.quizQuestionTypes, result);
		}
		qbQuestionTypeHelperExecuted=true;
		showQuestionBank();
	}
}

/**
 * @public
 * Gets all difficulty levels
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveDifficultyLevelsResultHandler(result:ArrayCollection):void
{
	//Fix for Bug#15194
	if(result != null)
	{
		if(Log.isInfo()) log.info("getAllActiveDifficultyLevels_resultHandler::result::" + result);
		if(result.length > 0)
		{
			ClassroomContext.quizDifficultyLevels=new ArrayCollection;
			ClassroomContext.quizDifficultyLevels=result;
		}		
		qbDifficultyLevelHelperROExecuted=true;
		showQuestionBank();
	}
}

/**
 * @public
 * Gets all categories
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQbCategoriesForUserResultHandler(result:ArrayCollection):void
{
	//Fix for Bug#15194
	if(result != null)
	{
		if(Log.isInfo()) log.info("getAllActiveQbCategoriesForUser_resultHandler::result::" + result);
		if(result.length > 0)
		{
			ClassroomContext.quizCategories=new ArrayCollection;
			ArrayCollectionUtil.copyData(ClassroomContext.quizCategories, result);
		}
		qbCategoryHelperROExecuted=true;
		showQuestionBank();
	}
}

/**
 * @public
 * Gets all subcategories
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQbSubcategoriesForUserResultHandler(result:ArrayCollection):void
{
	//Fix for Bug#15194
	if(result != null)
	{
		if(Log.isInfo()) log.info("getAllActiveQbSubcategoriesForUser_resultHandler::result::" + result);
		if(result.length > 0)
		{
			ClassroomContext.quizSubCategories=result;
		}
		qbSubcategoryHelperROExecuted=true;
		showQuestionBank();
	}
}

/**
 * @public
 * Start quiz in a live classroom for students
 * @param quizId type of String
 * @return void
 */
public function startLiveQuizForStudents(quizId:String,isQuiz:Boolean):void
{
	forPopUpQuizId=quizId;
	applicationType::DesktopWeb{
		studentLiveQuizView=new StudentViewLiveQuiz();
		PopUpManager.addPopUp(studentLiveQuizView, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3, true);
		PopUpManager.centerPopUp(studentLiveQuizView);
	}
	applicationType::mobile{
		quizEntryCount++;
		studentLiveQuizView=new StudentMobileViewLiveQuiz();
		studentLiveQuizView.percentWidth=100;
		studentLiveQuizView.percentHeight=100;
		PopUpManager.addPopUp(studentLiveQuizView, FlexGlobals.topLevelApplication as DisplayObject, true);
		studentLiveQuizView.width = FlexGlobals.topLevelApplication.width;
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
			studentLiveQuizView.height = FlexGlobals.topLevelApplication.height -FlexGlobals.topLevelApplication.actionBar.height;;
			studentLiveQuizView.y =  FlexGlobals.topLevelApplication.actionBar.height;
		}else{
			studentLiveQuizView.height=FlexGlobals.topLevelApplication.height-FlexGlobals.topLevelApplication.actionBar.height-FlexGlobals.topLevelApplication.colbTools.height;
			studentLiveQuizView.y=FlexGlobals.topLevelApplication.actionBar.height+FlexGlobals.topLevelApplication.colbTools.height;
		}
		if(FlexGlobals.topLevelApplication.chatToolBox!= null && FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput && FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.enabled)
		{
			FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.visible = false;
		}
		if(FlexGlobals.topLevelApplication.questComponent!= null && FlexGlobals.topLevelApplication.questComponent.questionInput && FlexGlobals.topLevelApplication.questComponent.questionInput.enabled){
			FlexGlobals.topLevelApplication.questComponent.questionInput.visible = false;
		}
	}
	studentLiveQuizView.quizId=int(Number(forPopUpQuizId));
	studentLiveQuizView.isPolling=!isQuiz;
	studentLiveQuizView.initApp();
}

/**
 * @public
 * Gets details of polling question type
 * @param event type of QbQuestionTypeVO
 * @return void
 */
public function getQbQuestionTypeByNameResultHandler(event:QbQuestionTypeVO):void
{
	if(event != null)
	{
		QuizContext.pollingQuestionTypeId=event.qbQuestionTypeId;
	}
}
