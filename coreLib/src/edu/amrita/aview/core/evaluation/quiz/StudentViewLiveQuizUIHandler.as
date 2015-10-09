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
 * File			: StudentViewLiveQuizUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This component is used to display quiz to student , consisting of questions and its answers
 *
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.SendAnswerResponseEvent;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionHelper;
import edu.amrita.aview.core.evaluation.helper.QuizResponseHelper;
import edu.amrita.aview.core.evaluation.quiz.LiveQuizResult;
import edu.amrita.aview.core.evaluation.vo.QuizAnswerChoiceVO;
import edu.amrita.aview.core.evaluation.vo.QuizQuestionChoiceResponseVO;
import edu.amrita.aview.core.evaluation.vo.QuizQuestionResponseVO;
import edu.amrita.aview.core.evaluation.vo.QuizQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuizResponseVO;
import edu.amrita.aview.core.evaluation.vo.QuizVO;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
}
applicationType::mobile{
	import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
	import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
	import edu.amrita.aview.core.evaluation.questionPaper.LiveMobileQuizResultUI;
}

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;
import mx.core.IFlexDisplayObject;
import flash.display.DisplayObject;
import edu.amrita.aview.core.entry.Constants;



/**Platform specific imports*/
applicationType::desktop
{
	import flash.desktop.NativeApplication;
}
/**
 * Stores quiz id
 */
public var quizId:int=0;

/**
 * Stores quiz type : Online or Live
 */
public var quizType:String=null;

/**
 * Stores hour,minutes,seconds for displaying time in offline quiz.
 */
public var displayHour:Number=0;
public var displayMinutes:Number;
public var displaySeconds:Number=0;

/**
 * Flag for changing the UI if its polling or normal quiz
 */

/**
 * Fix for Bug id 17579-->
 **/
[Bindable]
public var isPolling : Boolean;

/**
 * Stores the questions and answers
 */
[Bindable]
private var questionAnsObj : Object;

[Bindable]
/**
 * Stores quiz name
 */
private var txtQuizName : String = "";

[Bindable] 
/**
 * Stores image file path
 */
public var myImage : String;
[Bindable]
/**
 * Stores the title of panel
 */
private var titleForPnl:String="Student Answer Sheet";
[Bindable]
/**
 * Stores the index of question being currently attempted
 */
private var currentQuestionIndex:int=0;

[Embed(source="assets/images/silver-bell.gif")]
/**
 * Icon class
 */
private var imageIcon:Class;

/**
 * Stores the total score , scored by the student
 */
private var totalScore:Number=0;
//Fix for 10671, 10616
/**
 * Variable to compute the total marks for the given quiz. 
 * */
private var totalMarks:Number=0.0;

/**
 * Total questions in the quiz
 */
private var totalQuestions:int=0;
/** 
 * For checking whether video is played once or not
 * */
private var videoPlayedArray:Array = null;
/**
 *  Timer used for offline quiz
 */
private var timerForOfflineQuiz:Timer;

/**
 * Nos. of questions answered by the student
 */
private var answeredQuestionCount:int;

// Calls the remote methods
private var quizResponseHelper:QuizResponseHelper;
private var quizQuestionHelper:QuizQuestionHelper;

/**
 * Response of the student
 */
private var answeredQuestions:ArrayCollection=new ArrayCollection;

/**
 * Contains list of question/answers for the quiz
 */
private var masterQA:ArrayCollection=new ArrayCollection;

/**
 * Used for logging messages into logger in debugging mode
 */
private var log:ILogger=Log.getLogger("edu.amrita.aview.core.evaluation.quiz.StudentViewLiveQuiz");

// Used for masking the time in offline quiz
private const MIN_MASK:String="00";
private const SEC_MASK:String="00";
private const HOUR_MASK:String="00";
private const TIMER_INTERVAL:int=1000;

// Fix for bug # 17579,17797 start
// Default time out for polling questions. Currently set to 2 minutes
private const MAX_TIMEOUT_FOR_POLL_IN_MINUTE : int = 2;
// Fix for bug # 17579 end

applicationType::mobile{
	[Bindable]
	private var quizQuestioLst:ArrayCollection = new ArrayCollection();
	[Bindable]
	public var questionNumber:String ="";
	[Bindable]
	public var studentLiveQuizResultComp:LiveMobileQuizResultUI;
}
//Fix for Bug#18035
private var alertMessage:Alert = null;
/**
 * @public
 * Sets the initial data as per offline , live quiz
 *
 * @return void
 */
public function initApp():void
{
	quizResponseHelper=new QuizResponseHelper();
	quizQuestionHelper=new QuizQuestionHelper();
	// If canAnswer canvas contain something then remove all in it 
	if (canAnswer != null)
	{
		applicationType::DesktopWeb{
			canAnswer.removeAllChildren();
		}
		applicationType::mobile{
			canAnswer.removeAllElements();
		}
	}
	quizQuestionHelper.getQuizQuestionsForQuiz(quizId,getQuizQuestionsForQuizResultHandler);
	// Fix for Bug id 17579 start
	// If quiz type is online then start timer. 
	/*
	if (quizType == QuizContext.ONLINE_QUIZ_TYPE )
	{
		timerForOfflineQuiz=new Timer(TIMER_INTERVAL);
		timerForOfflineQuiz.addEventListener(TimerEvent.TIMER, updateTimer);
		startTimer();
		
		
	}
	*/
// Fix for Bug id 17579 end
}

/**
 * @public
 * Starts the time for offline quiz
 *
 * @return void
 */
public function startTimer():void
{
	timerForOfflineQuiz.start();
}

/**
 * @public
 * Stop the timer , when the time is up
 *
 * @return void
 */
public function stopTimer():void
{
	// If timer for offline quiz is running then stop anomation and timer
	if (timerForOfflineQuiz != null)
	{
		applicationType::DesktopWeb{
			animateFader.stop();
		}
		timerForOfflineQuiz.stop();
	}
	setVisibilityForNavigationButtons(false);
}

/**
 * @public
 *
 * Handles the result , once the quiz is submitted
 * @param result type of QuizResponseVO
 * @return void
 */
public function createQuizResponseResultHandler(result:QuizResponseVO):void
{
	/* Logger */
	if (Log.isDebug()) log.debug("createQuizResponseResultHandler. Student quiz submitted successfully \n");
	if(Log.isInfo()) log.info("result :: quizresponse" + result);
}

/**
 * @public
 * Stores the answers for multiple response questions
 * @param event type of SendAnswerResponseEvent
 * @return void
 */
public function handlerAnswerForMultipleResponse(event:SendAnswerResponseEvent):void
{
	// For loop iteration variable
	var i:int;
	// Variable to hold quiz answer choice details. 
	var quizans:QuizAnswerChoiceVO=event.quizAnswerChoiceVO;
	// Variable to hold quiz question details.
	var qzqVO:QuizQuestionVO=questionAnsObj as QuizQuestionVO;
	
	// Check if the answered questions is equivalent to the questions in the list
	if (qzqVO.quizQuestionId == answeredQuestions[currentQuestionIndex].quizQuestionId)
	{
		var ansAC:ArrayCollection=new ArrayCollection();
		ansAC=answeredQuestions[currentQuestionIndex].quizAnswerChoices;
		
		// Loop the answers , given by student to set that a particular option of
		// the questions was answered
		for (i=0; i < ansAC.length; i++)
		{
			var tempAnsVO:QuizAnswerChoiceVO=ansAC.getItemAt(i) as QuizAnswerChoiceVO;
			
			if (tempAnsVO.quizAnswerChoiceId == quizans.quizAnswerChoiceId)
			{
				tempAnsVO.studentAnsFraction=0;
				ansAC.setItemAt(tempAnsVO, i);
				break;
			}
		}
	}
}

/**
 * @public
 *
 * Calls setAnswerForEachQuestion method for storing answers for multiple choice questions
 * @param event type of SendAnswerResponseEvent
 * @return void
 */
public function radioButtonClickHandler(event:SendAnswerResponseEvent):void
{
	// Temporary object to hold question answer details
	var tempObjAC:Object=ObjectUtil.copy(questionAnsObj);
	var quizans:QuizAnswerChoiceVO=event.quizAnswerChoiceVO;
		
	setAnswerForEachQuestion(tempObjAC, quizans);
}

/**
 * @public
 *
 * Display the result in live classroom
 * @param result type of QuizVO
 * @return void
 */
//Fix for Bug #10430
public function getQuizByIdResultHandler(result:QuizVO):void
{
	// If result availabe then show the quiz result.
	// Else show the message "No Result Available".
	if (result != null)
	{
		applicationType::DesktopWeb{
			var studentLiveQuizResultComp:LiveQuizResult=new LiveQuizResult;
			studentLiveQuizResultComp.currentState="studentResult";
			studentLiveQuizResultComp.title="Quiz Result : " + result.quizName;
			studentLiveQuizResultComp.quizVO=result;
			PopUpManager.addPopUp(studentLiveQuizResultComp, FlexGlobals.topLevelApplication.mainApp.mainComponentContainer);
			PopUpManager.centerPopUp(studentLiveQuizResultComp);
		}
		applicationType::mobile{
			studentLiveQuizResultComp = new LiveMobileQuizResultUI ;
			studentLiveQuizResultComp.currentState="studentResult";
			studentLiveQuizResultComp.quizResultTitle = "Quiz Result : " + result.quizName;
			studentLiveQuizResultComp.quizVO=result;
			studentLiveQuizResultComp.percentWidth = 100;
			studentLiveQuizResultComp.percentHeight = 100;
			PopUpManager.addPopUp(studentLiveQuizResultComp, FlexGlobals.topLevelApplication as DisplayObject, true);
			studentLiveQuizResultComp.width = FlexGlobals.topLevelApplication.width;
			if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
				studentLiveQuizResultComp.height = FlexGlobals.topLevelApplication.height -FlexGlobals.topLevelApplication.actionBar.height;;
				studentLiveQuizResultComp.y =  FlexGlobals.topLevelApplication.actionBar.height;
			}else{
				studentLiveQuizResultComp.height=FlexGlobals.topLevelApplication.height-FlexGlobals.topLevelApplication.actionBar.height-FlexGlobals.topLevelApplication.colbTools.height;
				studentLiveQuizResultComp.y=FlexGlobals.topLevelApplication.actionBar.height+FlexGlobals.topLevelApplication.colbTools.height;
			}
			if(FlexGlobals.topLevelApplication.chatToolBox!= null && FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput && FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.enabled)
			{
				FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.visible = false;
			}
			if(FlexGlobals.topLevelApplication.questComponent!= null && FlexGlobals.topLevelApplication.questComponent.questionInput && FlexGlobals.topLevelApplication.questComponent.questionInput.enabled){
				FlexGlobals.topLevelApplication.questComponent.questionInput.visible = false;
			}
		}
	}
	else
	{
		applicationType::DesktopWeb{
			CustomAlert.info("No Result Available", QuizContext.ALERT_TITLE_INFORMATION );
		}
		applicationType::mobile{
			MessageBox.show("No Result Available" , QuizContext.ALERT_TITLE_INFORMATION,MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
	quizId=0;
}

/**
 * @public
 * Gets quiz questions and answers for the quiz
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuizQuestionsForQuizResultHandler(result:ArrayCollection):void
{
	// Logger
	if (Log.isDebug())  log.debug("getQuizQuestionsForQuizResultHandler. Incoming question length is: " + result.length + "\n");
	// Temporary object to hold the result.
	var tempObj:Object=result;
	masterQA.removeAll();
	QuizContext.copyDataByQuizSequence(masterQA, result);
	// For loop iteration variable
	var i:int;
	videoPlayedArray = new Array();
	// Calculating the total marks ,setting quiz id and quiz name.
	for (i =0; i < result.length; i++)
	{
		var quizQuestionVO:QuizQuestionVO=tempObj[i];
		quizId=quizQuestionVO.quiz.quizId;
		var questionMarks:Number=quizQuestionVO.marks;
		totalMarks+=questionMarks;
		txtQuizName=quizQuestionVO.quiz.quizName;
		// Initially all values are set to false.
		videoPlayedArray[i] = false; 
	}
	// Check if it is polling
	if (isPolling)
	{
		applicationType::mobile{
			titleForPnl="Poll";
		}
		applicationType::DesktopWeb
		{
			titleForPnl="Polling Question";
			hGroupTop.horizontalAlign="right";
			this.defaultButton=btnFinish;
		}
		//Fix for Bug id 17579 start
		setTimerForClosingQuizPollingWindow();
		//Fix for Bug id 17579 end
	}
	else
	{
		applicationType::DesktopWeb{
			titleForPnl=txtQuizName; // Bug fix # 9238	
		}
		applicationType::mobile{
			titleForPnl = "Quiz:  "+txtQuizName;
		}
	}
	totalQuestions=i;
	lblTotalMarks.text=String(totalMarks);
	callFirstQuestion(new Event('questionAC fill'));
}

//Fix for Bug id 17579 start
private function setTimerForClosingQuizPollingWindow() : void
{
	timerForOfflineQuiz=new Timer(TIMER_INTERVAL);
	timerForOfflineQuiz.addEventListener(TimerEvent.TIMER, updateTimer);
	displayHour = 0;
	displayMinutes = MAX_TIMEOUT_FOR_POLL_IN_MINUTE;
	displaySeconds = 0;
	startTimer();		
		
}
//Fix for Bug id 17579 end 

/**
 * @private
 * Updates the timer, after a stipulated time interval of 1000s
 * @param evt type of TimerEvent
 * @return void
 */
private function updateTimer(evt:TimerEvent):void
{
	// Variable used to store hour value
	var hour:String=(MIN_MASK + displayHour).substr(-HOUR_MASK.length);
	// Variable used to store minute value
	var min:String=(MIN_MASK + displayMinutes).substr(-MIN_MASK.length);
	// Variable used to store second value 
	var sec:String=(SEC_MASK + displaySeconds).substr(-SEC_MASK.length);
	// If quiz time ends then stop timer and show aproriate meassage.
	//  Else set timer accordingly
	if (displayHour == 0 && displayMinutes == 0 && displaySeconds < 0)
	{
		stopTimer();
		//Fix for Bug id 17579 start
		if(isPolling)
		{
			finishHandler();
		}
		else
		{
		applicationType::DesktopWeb{
			CustomAlert.info("Please submit the quiz otherwise you will lose");
		}
		applicationType::mobile{
			MessageBox.show("Please submit the quiz otherwise you will lose" , QuizContext.ALERT_TITLE_INFORMATION,MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
		//Fix for Bug id 17579 end
	}
	else
	{
		var t1:Number=(TIMER_INTERVAL / 1000);
			
		if (displaySeconds == 0 && displayMinutes > 0)
		{
			displaySeconds=59;
			displayMinutes=displayMinutes - 1;
		}
		else
		{
			displaySeconds=displaySeconds - t1;
		}
		if (displayMinutes == 0 && displayHour > 0)
		{
			displayHour=displayHour - 1;
			displayMinutes=59;
				
		}
		// If minute is less than 1 then show the image of ringing bell.
		else if (displayMinutes < 1)
		{
			animateFader.play();
			lblCounter.setStyle("color", "red");
			lblCounter.text=String(displayHour + ":" + min + ":" + sec);
			imgbell.source=imageIcon;
		}
		else
		{
			lblCounter.text=String(displayHour + ":" + min + ":" + sec);
		}
	}
}

/**
 * @private
 * Sets the UI for displaying the first question
 * @param event type of Event
 * @return void
 */
private function callFirstQuestion(event:Event):void
{
	lblNextQuestionCount.text="";
	// If it is not polling then set question number text to null
	if (!isPolling)
	{
		applicationType::DesktopWeb{
			lblQuestionNumber.text="";
		}
		applicationType::mobile{
			questionNumber = "";
		}
	}
	applicationType::DesktopWeb{
		canAnswer.removeAllChildren();
	}
	canAnswer.removeAllElements();
	hBoxAllQuestions.visible=true;
	answeredQuestions.removeAll();
	ArrayCollectionUtil.copyData(answeredQuestions, masterQA);
	applicationType::mobile{
		quizQuestioLst.removeAll();
	}
	currentQuestionIndex=0;
	// If it is not polling then Show navigation buttons.
	if (!isPolling)
	{
		setVisibilityForNavigationButtons(true);
	}
	firstQuestion();
}

/**
 * @private
 * Set the visibility of previous and next buttons
 * @private
 * @param flag type of Boolean
 * @return void
 */
private function setVisibilityForNavigationButtons(flag:Boolean):void
{
	btnPrevious.visible=flag;
	btnNext.visible=flag;
}

/**
 * @private
 * Display the first question of the quiz
 *
 * @return void
 */
private function firstQuestion():void
{
	// Temporary object to hold question answer details. 
	var tmpQuestionAnsObj:Object=new Object();
	tmpQuestionAnsObj=ObjectUtil.copy(masterQA[currentQuestionIndex]);
	questionAnsObj=tmpQuestionAnsObj;
	applicationType::mobile{
		quizQuestioLst.addItem(questionAnsObj);
	}
	lblNextQuestionCount.text=String(currentQuestionIndex + 1) + "/ " + String(totalQuestions);
	loadMediaFile();
	// Polling has only one question so there is no need of numbering for questions.
	applicationType::DesktopWeb{
		lblQuestionNumber.text = isPolling ? "Q." : String(currentQuestionIndex + 1) + '.';
		canAnswer.addChild(hBoxAllQuestions);
	}
	applicationType::mobile{
		questionNumber = isPolling ? "Q." : String(currentQuestionIndex + 1) + '.';
		canAnswer.addElement(hBoxAllQuestions);
	}
}

/**
 * @private
 *
 * Clear the components
 *
 * @return void
 */
private function resetComponents():void
{
	lblNextQuestionCount.text="";
	applicationType::DesktopWeb{
		lblQuestionNumber.text="";
	}
	applicationType::mobile{
		questionNumber = "";
	}
}

/**
 * @private
 *
 * Loads the previous question of the quiz
 * @param event type of MouseEvent
 * @return void
 */
private function loadPrevQuestion(event:MouseEvent):void
{
	// Load previous question only if there are more than one questions in the quiz
	if (currentQuestionIndex > 0)
	{
		/* Reduce the current index to the previous question*/
		currentQuestionIndex--; 
		// check if the actual question and attempted question are same 
		if (masterQA[currentQuestionIndex].quizQuestionId == answeredQuestions[currentQuestionIndex].quizQuestionId)
		{
			questionAnsObj=ObjectUtil.copy(answeredQuestions[currentQuestionIndex]); /* copy the attempted question/answer to a question object */
		}
		lblNextQuestionCount.text=String(currentQuestionIndex + 1) + "/ " + String(totalQuestions);
		applicationType::DesktopWeb{
			lblQuestionNumber.text=String(currentQuestionIndex + 1) + '.';
		}
		applicationType::mobile{
			quizQuestioLst.addItem(questionAnsObj);
			questionNumber=String(currentQuestionIndex + 1) + '.';
		}
		loadMediaFile();
		applicationType::DesktopWeb{
			canAnswer.addChild(hBoxAllQuestions);
		}
		applicationType::mobile{
			canAnswer.addElement(hBoxAllQuestions);
			quizQuestioLst.removeItemAt(0);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			CustomAlert.info("This is the first question.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		}
		applicationType::mobile{
			MessageBox.show("This is the first question.","Quiz Question",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
}

/**
 * @private
 *
 * Loads the next question of the quiz
 * @param event type of MouseEvent
 * @return void
 */
private function loadNextQuestion(event:MouseEvent):void
{
	/* check if the current index is less than the number of questions in quiz , it should not be the last question*/
	if (currentQuestionIndex < (masterQA.length - 1))
	{
		currentQuestionIndex++;
		var tmpQuestionAnsObj:Object=new Object();
		tmpQuestionAnsObj=ObjectUtil.copy(answeredQuestions[currentQuestionIndex]);
		questionAnsObj=tmpQuestionAnsObj;
		lblNextQuestionCount.text=String(currentQuestionIndex + 1) + "/ " + String(totalQuestions);
		applicationType::DesktopWeb{
			lblQuestionNumber.text=String(currentQuestionIndex + 1) + '.';
		}
		applicationType::mobile{
			quizQuestioLst.addItem(questionAnsObj);
			questionNumber=String(currentQuestionIndex + 1) + '.';
		}
		loadMediaFile();
		applicationType::DesktopWeb{
			canAnswer.addChild(hBoxAllQuestions);
		}
		applicationType::mobile{
			canAnswer.addElement(hBoxAllQuestions);
			quizQuestioLst.removeItemAt(0);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			CustomAlert.info("That's all the questions! Click Submit to see the score, or Previous to go back", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		}
		applicationType::mobile{
			MessageBox.show("That's all the questions! Click Submit to see the score, or Previous to go back",QuizContext.ALERT_TITLE_INFORMATION,MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
}

/**
 * @private
 * Check if user has attempted all questions before submitting the quiz
 * @param event type of MouseEvent
 * @return void
 */
private function conformationForSubmit(event:MouseEvent):void
{
	// Flag variable to notify attempted questions 
	var flag:Boolean=false;
	answeredQuestionCount=0;
	// Checking user answered questions 
	for (var i:int =0; i < answeredQuestions.length; i++)
	{
		// temporary arraycollection for quiz answer choice
		var tempAnsAC:ArrayCollection=answeredQuestions[i].quizAnswerChoices;
		// check if user has attempted the question
		for (var j:int =0; j < tempAnsAC.length; j++)
		{
			// Check if user attended the question 
			if (tempAnsAC[j].studentAnsFraction != 0)
			{
				answeredQuestionCount++;
				flag=true;
				break;
			}
		}
	}
	// On basis of last question in quiz , check for attempted answers
	if (flag)
	{
		// if all questions have not been attempted
		if (answeredQuestionCount != totalQuestions)
		{
			if (isPolling)
			{
				applicationType::DesktopWeb{
					CustomAlert.confirm("you haven’t answered the question! Are you sure, you want to submit?", "Confirmation", selectSubmitOption, this);
				}
				applicationType::mobile{
					MessageBox.show("You haven’t answered the question! Are you sure, you want to submit?","Confirmation",MessageBox.MB_YESNO,this,selectSubmitOption,null,MessageBox.IC_INFO);
				}
			}
			else
			{
				applicationType::DesktopWeb{
					CustomAlert.confirm("You haven’t answered all the questions! Are you sure, you want to submit?", "Confirmation", selectSubmitOption, this);
				}
				applicationType::mobile{
					MessageBox.show("You haven’t answered all the questions! Are you sure, you want to submit?","Confirmation",MessageBox.MB_YESNO,this,selectSubmitOption,null,MessageBox.IC_INFO);
				}
			}
		}
		// if all questions have been attempted
		else
		{
			if (isPolling)
			{
				applicationType::DesktopWeb{
					//Fix for Bug#18035
					alertMessage = CustomAlert.confirm("Are you sure, you want to submit?", "Polling", selectSubmitOption, this);
				}
				applicationType::mobile{
					MessageBox.show("Are you sure, you want to submit?","Polling",MessageBox.MB_YESNO,this,selectSubmitOption,null,MessageBox.IC_INFO);
				}
			}
			else
			{
				applicationType::DesktopWeb{
					CustomAlert.confirm("Are you sure, you want to submit?", "Quiz", selectSubmitOption, this);
				}
				applicationType::mobile{
					MessageBox.show("Are you sure, you want to submit?","Quiz",MessageBox.MB_YESNO,this,selectSubmitOption,null,MessageBox.IC_INFO);
				}
			}
		}
	}
	// If last question was not attempted
	else
	{
		// didnt attempt any question
		if (isPolling)
		{
			//Fix for Bug #10885,Bug#11185
			applicationType::DesktopWeb{
				CustomAlert.info("Please select an answer before submitting!", QuizContext.ALERT_TITLE_INFORMATION, null, this);
			}
			applicationType::mobile{
				MessageBox.show("Please select an answer before submitting!",QuizContext.ALERT_TITLE_INFORMATION,MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
			}
		}
		else
		{
			//Fix for Bug #10885
			applicationType::DesktopWeb{
				CustomAlert.info("You haven’t answered any of the questions!", QuizContext.ALERT_TITLE_INFORMATION, null, this);
			}
			applicationType::mobile{
				MessageBox.show("You haven’t answered any of the questions!",QuizContext.ALERT_TITLE_INFORMATION,MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
			}
			setVisibilityForNavigationButtons(true);
		}
	}
}

/**
 * @private
 * @param event type of CloseEvent
 * @return void
 */
applicationType::DesktopWeb{
	private function selectSubmitOption(event:CloseEvent):void
	{
		// If user select yes on conformation alert box then submit the quiz .
		if (event.detail == Alert.YES)
		{
			//Fix for Bug#17828,17829:Start
			if(timerForOfflineQuiz && timerForOfflineQuiz.running)
			{
				stopTimer();
			}
			//Fix for Bug#17828,17829:End
			finishHandler();
		}
		else if(!isPolling)
		{
			setVisibilityForNavigationButtons(true);
		}
	}
}
applicationType::mobile{
	private function selectSubmitOption(event:MessageBoxEvent):void
	{
		if(event.type == "messageBoxYES")
		{
			if(timerForOfflineQuiz && timerForOfflineQuiz.running)
			{
				stopTimer();
			}
			finishHandler();
		}
		else if(!isPolling)
		{
			setVisibilityForNavigationButtons(true);
		}
	}
}
/**
 * @private
 * Reset and clear all the components
 *
 * @return void
 */
private function finishHandler():void
{
	setVisibilityForNavigationButtons(false);
	btnFinish.visible=false;
	resetComponents();
	computeScore();
}

/**
 * @private
 *
 * Compute score for the quiz
 *
 * @return void
 */
private function computeScore():void
{
	/* Variable to hold quiz response */
	var quizResponseVO:QuizResponseVO=new QuizResponseVO();
	/* For loop iteration variable */
	var i:int=0, j:int=0;
	/* stores the user's answers*/
	var quizAnswerChoiceIdArr:Array=new Array(); 
	/* stores the question response*/
	var quizQuestionIdArr:Array=new Array(); 
	/* Variable to hold quiz question response */
	var quizQuestionResponse:QuizQuestionResponseVO=null;
	/* Variable to hold quiz question details */
	var quizQ:QuizQuestionVO;
	/* temporary list of answers */
	var tempAnsAC:ArrayCollection; 
	/* flag for correct/incorrect answer attempted*/
	var flagAns:Boolean=false; 
	/* correct answers attempted for multiple response*/
	var countForMR:int=0; 
	/* actual correct answers for multiple response*/
	var actualCountForMR:int=0; 
	/* Variable to hold quiz question choice response */
	var quizAnswer:QuizQuestionChoiceResponseVO;
	/* flag for checking if student attempted a question*/
	var studentAnswered:Boolean=false; 
	/* flag for checking if question is multiple choice , polling*/
	var isMultipleChoicePolling:Boolean=false; 
	//Fix for 10671, 10616
	//Local variable to compute the score for each question 
	var score:int=0;
	/* Checking all user answered questions. */
	for (i=0; i < answeredQuestions.length; i++)
	{
		quizQ=answeredQuestions[i];
		tempAnsAC=answeredQuestions[i].quizAnswerChoices;
		flagAns=true;
		studentAnswered=false;
		isMultipleChoicePolling=false;
		countForMR=0;
		actualCountForMR=0;
		score=0;
		/* Checking user enteredanswer choice. */
		for (j=0; j < tempAnsAC.length; j++)
		{
			quizAnswer=new QuizQuestionChoiceResponseVO;
			quizAnswer.quizAnswerChoiceId=tempAnsAC[j].quizAnswerChoiceId;
			quizAnswer.quizQuestionId=quizQ.quizQuestionId;
			//Check if the student answred the question
			if (tempAnsAC[j].studentAnsFraction != 0)
			{
				quizAnswerChoiceIdArr.push(quizAnswer);
				studentAnswered=true;
			}
			//Check if the question is of type multiple choice / polling
			if ((quizQ.questionTypeName.indexOf(QuizContext.MULTIPLECHOICE) != -1) || (quizQ.questionTypeName.indexOf(QuizContext.POLLING) != -1))
			{
				isMultipleChoicePolling=true;
				// correct answer
				flagAns = (tempAnsAC[j].fraction != 0 && tempAnsAC[j].studentAnsFraction != 0) ? true : false;
			}
			// in case of multiple response
			else
			{
				//tempAnsAC[j].fraction != 0 ?actualCountForMR++ : 0;
				//Fix for 10671, 10616
				//Increment the user answer count and correct answer count in case of 
				// multiple response
				if (tempAnsAC[j].fraction != 0)
				{
					actualCountForMR++;
				}
				if (tempAnsAC[j].studentAnsFraction != 0)
				{
					countForMR++;
				}
				//Check for the correctness. 
				//If the student has selected a wrong choice or a right choice has not been selected by the
				//student, then make the flag as false
				if ((tempAnsAC[j].fraction == 0) && (tempAnsAC[j].studentAnsFraction != 0) || (tempAnsAC[j].fraction != 0) && (tempAnsAC[j].studentAnsFraction == 0))
				{
					flagAns=false;
				}
			}
			//come out of the loop if it is a multiple choice
			if ((studentAnswered) && (isMultipleChoicePolling))
			{
				break;
			}
		}
		if ((flagAns && isMultipleChoicePolling) || (flagAns && (actualCountForMR == countForMR)))
		{
			//Fix for 10671, 10616
			//If the answer is correct, assign the quiz question mark to the score
			score=quizQ.marks;
		}
		// generate the quizquestion response array
		quizQuestionResponse=new QuizQuestionResponseVO();
		quizQuestionResponse.quizQuestionId=quizQ.quizQuestionId;
		quizQuestionResponse.score=score;
		//Fix for 10671, 10616
		//Calculate the total score for the quiz
		totalScore+=score;
		//Fix for 10671, 10616
		// Push the Quiz Question response if the student has attempted
		if (studentAnswered)
		{
			quizQuestionIdArr.push(quizQuestionResponse);
		}
	}
	quizResponseVO.quizId=quizId;
	quizResponseVO.userId=ClassroomContext.userVO.userId;
	quizResponseVO.totalScore=totalScore;
	quizResponseVO.timeStart=new Date;
	quizResponseVO.timeEnd=new Date;
	//added the quiz response type
	quizResponseVO.quizResponseType="PC";
	if (Log.isDebug())log.debug("Submitting the student result with score: " + quizResponseVO.totalScore + "\n");
	quizResponseHelper.createQuizResponse(quizResponseVO, quizQuestionIdArr, quizAnswerChoiceIdArr, ClassroomContext.userVO.userId,createQuizResponseResultHandler);
	//Alert.show("You answered " + score + " correct out of " + questionsAC.length + " questions.");
	/* Checking if it is polling*/
	if (isPolling)
	{
		//Fix for Bug #17797:Start
		if(quizQuestionIdArr.length > 0)
		{
			//Fix for Bug #17797:End
			applicationType::DesktopWeb{
				CustomAlert.info("Thank you for submitting the answer", "Polling", null, this);
			}
			applicationType::mobile{
				MessageBox.show("Thank you for submitting the answer","Polling",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
			}
		}
	}
	else
	{
		applicationType::DesktopWeb{
			//Fix for Bug #10430
			//		CustomAlert.info("Thank You for submitting the answers","SubmitQuiz", null, this) ;
			Alert.yesLabel="View Result";
			Alert.noLabel="Cancel";
			Alert.buttonWidth=100;
			//Fix for Bug #11604
			Alert.show("Thank you for submitting the answers", "Result", Alert.YES | Alert.NO, this, alertHandler);
		}
		applicationType::mobile{
			MessageBox.show("Do you want to view the Result?.","Quiz",MessageBox.MB_YESNO,this,alertHandler,alertHandler,MessageBox.IC_INFO);
		}
	}
	applicationType::DesktopWeb{
		//Modification to fix a bug
		Alert.yesLabel="Yes";
		Alert.noLabel="No";
		Alert.buttonWidth=65;
	}
	applicationType::mobile{
		//To close quiz component
		if(FlexGlobals.topLevelApplication.chatToolBox!= null && FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput && FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.visible == false){
			FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.visible = true;
		}
		if(FlexGlobals.topLevelApplication.questComponent!= null && FlexGlobals.topLevelApplication.questComponent.questionInput && FlexGlobals.topLevelApplication.questComponent.questionInput.visible == false){
			FlexGlobals.topLevelApplication.questComponent.questionInput.visible = true;
		}
	}
	ClearInfoAndCloseLiveQuizWindow();
}

/**
 * @private
 *
 * Reset all components after the live quiz is attempted
 *
 * @return void
 */
private function ClearInfoAndCloseLiveQuizWindow():void
{
	masterQA.removeAll();
	currentQuestionIndex=-1;
	totalScore=0;
	totalMarks=0.0;
	totalQuestions=0;
	//Fix for Bug #10430
	//quizId = 0 ;
	questionAnsObj=null;
	txtQuizName="";
	//Fix for Bug#18035:Start
	if(alertMessage != null)
	{
		PopUpManager.removePopUp(alertMessage);
	}
	//Fix for Bug#18035:End
	PopUpManager.removePopUp(this);
}


/**
 * @private
 *
 * Store answer for multiple choice questions
 * @param QuestAnsAC type of question
 * @param studentAnsVO type of answer
 *  @return void
 */
private function setAnswerForEachQuestion(QuestAnsAC:Object, studentAnsVO:QuizAnswerChoiceVO):void
{
	/* For loop iteration variable */
	var i:int;
	/* Variable to hold quiz question. */
	var quizQuestionVO:QuizQuestionVO=QuestAnsAC as QuizQuestionVO;
	
		var ansAC:ArrayCollection=new ArrayCollection();
		ansAC=answeredQuestions[currentQuestionIndex].quizAnswerChoices;
		// remove the entry of answer choice , to set the fraction whether student attempted it
		//Fix for bug # 20147 start
		if ((quizQuestionVO.questionTypeName.indexOf(QuizContext.MULTIPLECHOICE) != -1) || (quizQuestionVO.questionTypeName.indexOf(QuizContext.POLLING) != -1) || (quizQuestionVO.questionTypeName.indexOf(QuizContext.TRUE_OR_FALSE) != -1))
		{
			answeredQuestions.removeItemAt(currentQuestionIndex);
			ansAC=quizQuestionVO.quizAnswerChoices;
		}
		//Set the studentAnsFraction as per the answer attempted by student
		for (i=0; i < ansAC.length; i++)
		{
			var tempAnsVO:QuizAnswerChoiceVO=ansAC.getItemAt(i) as QuizAnswerChoiceVO;
			// set the fraction to 1 for the answer attempted
			if (tempAnsVO.quizAnswerChoiceId == studentAnsVO.quizAnswerChoiceId)
			{
				tempAnsVO.studentAnsFraction=1;
				ansAC.setItemAt(tempAnsVO, i);
			}
			else
			{
				// set the fraction to 0 for answer unattempted
				if ((quizQuestionVO.questionTypeName.indexOf(QuizContext.MULTIPLECHOICE) != -1) || (quizQuestionVO.questionTypeName.indexOf(QuizContext.POLLING) != -1) || (quizQuestionVO.questionTypeName.indexOf(QuizContext.TRUE_OR_FALSE) != -1) )
				{
					tempAnsVO.studentAnsFraction=0;
					ansAC.setItemAt(tempAnsVO, i);
				}
			}
		}
		if ((quizQuestionVO.questionTypeName.indexOf(QuizContext.MULTIPLECHOICE) != -1) || (quizQuestionVO.questionTypeName.indexOf(QuizContext.POLLING) != -1) || (quizQuestionVO.questionTypeName.indexOf(QuizContext.TRUE_OR_FALSE) != -1))
		{
			answeredQuestions.addItemAt(quizQuestionVO, currentQuestionIndex);
		}
		//Fix for bug # 20147 end

		
	

}

/*
* Fix for Bug #10430
* To display student live quiz result within the classroom.
* Called when clicking 'View Result' in alert box.
*/
/**
 * @private
 * Display student live quiz result within the classroom.
 * @param e type of CloseEvent
 * @return void
 */
applicationType::DesktopWeb{
	private function alertHandler(e:CloseEvent):void
	{
		// If user select yes on conformation alert box then call server function to get quiz details.
		if (e.detail == Alert.YES)
		{
			var quizHelper:QuizHelper=new QuizHelper;
			quizHelper.getQuizById(quizId,getQuizByIdResultHandler);
			
		}
		else
		{
			if(Log.isInfo()) log.info("cancel button clicked");
		}
	}
}
applicationType::mobile{
	private function alertHandler(event:MessageBoxEvent):void
	{
		if(event.type == "messageBoxYES")
		{
			var quizHelper : QuizHelper = new QuizHelper;
			quizHelper.getQuizById(quizId,getQuizByIdResultHandler);
		}
		else
		{
			MessageBox.show("Thank you for submitting the answer","SubmitQuiz",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
}
private function loadMediaFile():void
{
	myImage = null;
	
	if(questionAnsObj.quizQuestionMediaFiles != null && questionAnsObj.quizQuestionMediaFiles.length > 0)
	{
		if(questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_AUDIO 
			|| questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_VIDEO)
		{
			loadVideo();
		}
		else if(questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_IMAGE)
		{
			loadImage();
		}
		else
		{
			loadQuestion();
		}
	}
	else
	{
		loadQuestion();
	}
}

/**
 * @private
 * To load question without any media files
 * @return void
 *
 */
private function loadQuestion():void
{
	canAnswer.visible = true;
	canAnswer.includeInLayout = true;
	
	setPreviewBoxVisibility(false);
	setImageVisibility(false);
	setVideoVisibility(false);
}
/**
 * @private
 * To load image
 * @return void
 *
 */
private function loadImage():void
{
	setVideoVisibility(false);
	
	setImageVisibility(true);
	
	myImage = questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFolderPath + questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFileName;
	canAnswer.visible = true;
	canAnswer.includeInLayout = true;
}
/**
 * @private
 * To load video
 * @return void
 *
 */
private function loadVideo():void
{
	applicationType::DesktopWeb{
		setImageVisibility(false);	
		setVideoVisibility(true);
		
		if(videoPlayedArray[currentQuestionIndex] == false)
		{
			videoPlayer.videoDisplay.width = 0;
			videoPlayer.videoDisplay.height = 0;
			videoPlayer.enabled = true;
			videoPlayer.source  = ObjectUtil.copy(questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFolderPath + questionAnsObj.quizQuestionMediaFiles[0].quizQuestionMediaFileName);
			videoPlayer.seek(0.1);
			videoPlayer.play();
			canAnswer.visible = false;
			canAnswer.includeInLayout = false;
			videoPlayedArray[currentQuestionIndex] = true;
		}
		else
		{
			videoPlayer.enabled = false;
			videoPlayer.stop();
			canAnswer.visible = true;
			canAnswer.includeInLayout = true;
		}
	}
}
/**
 * @private
 * Handler when video player complete playing
 * @return void
 *
 */
private function videoPlayerCompletePlaying():void
{
	videoPlayedArray[currentQuestionIndex] = true;
	loadVideo();
}
/**
 * @private
 * To set visibility of videoPlayer
 * @return void
 *
 */
private function setVideoVisibility(value : Boolean):void
{
	applicationType::DesktopWeb{
		if(value)
		{
			setPreviewBoxVisibility(value);
		}
		videoPlayer.visible = value;
		videoPlayer.includeInLayout = value;
	}
}
/**
 * @private
 * To set visibility of ImageLoader
 * @return void
 *
 */
private function setImageVisibility(value : Boolean):void
{
	applicationType::DesktopWeb{
		if(value)
		{
			setPreviewBoxVisibility(value);
		}
		imageLoader.visible = value;
		imageLoader.includeInLayout = value;
	}
}

/**
 * @private
 * To set visibility of previewBox
 * @return void
 *
 */
private function setPreviewBoxVisibility(value : Boolean):void
{
	applicationType::DesktopWeb{
		previewBox.visible = value;
		previewBox.includeInLayout = value;
	}
}