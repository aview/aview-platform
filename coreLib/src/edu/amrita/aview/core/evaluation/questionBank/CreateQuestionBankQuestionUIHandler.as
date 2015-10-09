
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
 * File			: CreateQuestionBankQuestionUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * CreateQuestionBankQuestionUIHandler acts as handler for CreateQuestionBankQuestion.mxml
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.helper.QbQuestionHelper;
import edu.amrita.aview.core.evaluation.vo.QbAnswerChoiceVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionMediaFileVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.fileManager.FileManager;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.service.content.ContentService;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ValidationResultEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;
import mx.validators.NumberValidator;

import spark.components.HGroup;
import spark.components.RadioButton;

/**Platform specific imports*/
applicationType::desktop{
	import flash.filesystem.File;
}	

[Bindable]
/**
 * Variable to hold question bank question
 * */
public var qbQuestionVO:QbQuestionVO;

[Bindable]
/**
 * Holds answerchoices of a question.
 */
public var answerChoices:ArrayCollection = new ArrayCollection;

[Bindable]
/**
 * For polling questions, set it to true.
 */
public var isPolling:Boolean = false;
/**
 * Variable to hold question bank subcategory Id
 */
public var qbSubcategoryId:Number = 0;

/**
 * Variable to hold custom alert
 */
private var alertWindow:Alert;

[Bindable]
/**
 * To hold quiz difficulty level.
 */
private var levels:ArrayCollection = new ArrayCollection();

[Bindable]
/**
 * To hold question types.
 */
private var questionTypes:ArrayCollection = new ArrayCollection();

/**
 * To hold removed choices.
 */
private var removedChoices:ArrayCollection = new ArrayCollection;

/**
 * Question bank question helper class instance
 */
private var qbQuestionHelper:QbQuestionHelper;
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.questionBank.CreateQuestionBankQuestionUIHandler.as");

private const MIN_ANSWER_CHOICE_COUNT : Number = 2;
private const MAX_UPLOAD_FILE_SIZE : Number = 40*1024*1024;
private const UPLOAD_FILE_FORMAT_PNG : String = "png";
private const UPLOAD_FILE_FORMAT_JPG : String = "jpg";
private const UPLOAD_FILE_FORMAT_JPEG : String = "jpeg";
private const UPLOAD_FILE_FORMAT_GIF : String = "gif";
private const UPLOAD_FILE_FORMAT_BMP : String = "bmp";
private const UPLOAD_FILE_FORMAT_MP3 : String = "mp3";
private const UPLOAD_FILE_FORMAT_WAV : String = "wav";
private const UPLOAD_FILE_FORMAT_MP4 : String = "mp4";
private const UPLOAD_FILE_FORMAT_FLV : String = "flv";
private const UPLOAD_FILE_FORMAT_F4V : String = "f4v";


//For uploading : Start
/**
 * Variable to hold FileFilter instance
 */
private var fileFilter : FileFilter;

[Bindable]
/**
 * Temporary variable to hold uploading file path
 */
private var tempNativeFilePath : String = "";
/**
 * Image icon class
 */
[Embed(source="assets/images/NoImageAvailable.png")]
private var errorImageIcon : Class ;
[Bindable]
/**
 * Variable to hold upload file name
 */
private var uploadFileName : String = "";
[Bindable]
/**
 * Variable to hold upload file type
 */
private var uploadFileType : String = "";
/**
 * Variable to know whether uploaded image is removed or not
 */
private var mediaFileRemoved : Boolean = false;
/**Platform specific variables*/
applicationType::desktop{
	/**
	 * Variable to hold File instance
	 */
	private var fileReference : File;
}
applicationType::web
{
	/**File is not available for web. So we changed File to FileReference*/
	private var fileReference:FileReference;
}
//For uploading : End
/**
 * @public
 * Function : editQuestionType To disable question level and question type combobox when editing.
 *
 * @return void
 */
public function editQuestionType():void
{
	levelsComboBox.enabled = false;
	cbQuestionTypes.enabled = false;
	var i:int = 0;
	// Set the question type as per the selected question's question type 
	for (i = 0; i < questionTypes.length; i++) 
	{
		if (questionTypes[i].qbQuestionTypeId == qbQuestionVO.qbQuestionTypeId) 
		{
			cbQuestionTypes.selectedIndex = i;
			break;
		}
	}
	for (i = 0; i < levels.length; i++) 
	{
		if (levels[i].qbDifficultyLevelId == qbQuestionVO.qbDifficultyLevelId) 
		{
			levelsComboBox.selectedIndex = i;
		}
	}	
	/*if(qbQuestionVO.qbQuestionMediaFiles.length > 0  && qbQuestionVO.qbQuestionMediaFiles.getItemAt(0).qbQuestionMediaFolderPath != null && qbQuestionVO.qbQuestionMediaFiles.getItemAt(0).qbQuestionMediaFileType != null)
	{
		var qbQuestionMediaFile : QbQuestionMediaFileVO = qbQuestionVO.qbQuestionMediaFiles.getItemAt(0) as QbQuestionMediaFileVO;
		tempNativeFilePath = qbQuestionMediaFile.qbQuestionMediaFolderPath + qbQuestionMediaFile.qbQuestionMediaFileName;
		if(qbQuestionMediaFile.qbQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_IMAGE)
		{
			setImageVisibility(true);
			
			setVideoVisibility(false);
		}
		else if(qbQuestionMediaFile.qbQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_AUDIO || qbQuestionMediaFile.qbQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_VIDEO)
		{
			setVideoVisibility(true);
			
			setImageVisibility(false);
		}
	}	*/
}

/**
 * @public
 * Function : validateInputForPolling Validate user entered input values when creating polling question.
 *
 * @return Boolean
 */
public function validateQuestion():Boolean
{
	//Fix for Bug # 10110,10111 
	// To hold the error message while validating
	var errorMessage:String = "";
	// To hold the return value.
	var returnValue:Boolean = true;
	// If choice text is blank, set it to true
	var blankErrorFlag:Boolean = false;
	// If choices are same, set it to true
	var sameErrorFlag:Boolean = false;
	// If choices are same, set it to true
	var isAnsSelected:Boolean = false;
	if(!isPolling)
	{
		if (cbQuestionTypes.selectedIndex == -1) 
		{
			errorMessage += "Select question type.\n";
			cbQuestionTypes.setFocus();
		}
		
		if (levelsComboBox.selectedIndex == -1) 
		{
			errorMessage += "Select difficulty level.\n";
			levelsComboBox.setFocus();
		}
		
		if (StringUtil.trim(marksText.text) == null || StringUtil.trim(marksText.text) == "") 
		{
			errorMessage += "Enter marks.\n";
			marksText.setFocus();
		}
		//Fix for Bug#16839
		else
		{
			var marks:Number = Number(marksText.text);
			var v:NumberValidator = new NumberValidator;
			var vResult:ValidationResultEvent = v.validate(marks);
			
			if ((vResult.type == ValidationResultEvent.INVALID) || (marks <= 0)) 
			{
				errorMessage += "Invalid value for marks.\n";	
			}
		}
	}
	
	// Check if question text is null or empty
	if (StringUtil.trim(questionText.text) == null || StringUtil.trim(questionText.text) == "") 
	{
		questionText.setFocus();
		errorMessage += "Question field is empty.\n";
	}
	
	// Loop through the answer choices , for validating it 
	for (var i:int = 0; i < choices.length; i++) 
	{
		 /** To hold user entered choice text in lower case. */ 
		var choiceText:String = StringUtil.trim(String(choices[i].answerText.text).toLowerCase());
		
		//To check whether user entered choice text is null.		
		if (choiceText == null || choiceText == "") 
		{
			choices[i].answerText.setFocus();
			blankErrorFlag = true;
		} 
		else 
		{
			// To compare all choices with each other.
			
			for (var j:int = i + 1; j < choices.length; j++) 
			{
				// To hold choice text
				var ch:String = StringUtil.trim(choices[j].answerText.text);

				if (choiceText == ch.toLowerCase()) 
				{
					if(Log.isDebug()) log.debug("found same");
					choices[i].answerText.setFocus();
					sameErrorFlag = true;
				}
			}
			if(!isPolling)
			{
				if (choices[i].answerChoiceForMC.selected) 
				{
					isAnsSelected = true;
				}
			}
		}
	}
	
	// Checking condition and setting apropriate error messages.	
	if (blankErrorFlag) 
	{
		errorMessage += "The choice text cannot be blank.\n";
	}
	if (sameErrorFlag) 
	{
		errorMessage += "The choices text cannot be same.\n";
	}
	if(!isPolling)
	{
		if (!isAnsSelected) 
		{
			errorMessage += "Select the correct answer.\n";
		}
	}
	if (choices.length < 2) 
	{
		errorMessage += "At least two choices are required.\n";
	}
	
	if (errorMessage.length > 0) 
	{
		alertWindow = CustomAlert.error(errorMessage, QuizContext.ALERT_TITLE_INFORMATION, null, this);
		returnValue = false;
	}
	return returnValue;
}

/**
 * @public
 * Function : getQuestionDetails To get the user entered question details
 *
 * @return QbQuestionVO
 */
public function getQuestionDetails():QbQuestionVO 
{
	// set the question type 
	if (cbQuestionTypes.selectedItem != null) 
	{
		qbQuestionVO.qbQuestionTypeId = cbQuestionTypes.selectedItem.qbQuestionTypeId;
	}
	// set the question level 
	//Fix for Bug#14871
	if (levelsComboBox.selectedItem != null) 
	{
		qbQuestionVO.qbDifficultyLevelId = levelsComboBox.selectedItem.qbDifficultyLevelId;
	}
	/*if(uploadFileTextInput.text != QuizContext.EMPTY_STRING && uploadFileTextInput.text != null)
	{
		var path:String = "";
		if(ClassroomContext.CONTENT_DOCUMENT != QuizContext.EMPTY_STRING)
		{
			path = "http://" + ClassroomContext.CONTENT_DOCUMENT + "/AVContent/Upload/Personal/"+ClassroomContext.userVO.userName+"/My Quiz Files/";
		}
		else
		{
			path = "http://localhost/AVContent/Upload/Personal/"+ClassroomContext.userVO.userName+"/My Quiz Files/";
		}
		var qbQuestionMediaFileVO: QbQuestionMediaFileVO = null;
		if((qbQuestionVO.qbQuestionId != 0) && (qbQuestionVO.qbQuestionMediaFiles.length > 0))
		{
			//Since it is assummed that only one image/media file is available with one question
			qbQuestionMediaFileVO = qbQuestionVO.qbQuestionMediaFiles.getItemAt(0) as QbQuestionMediaFileVO;
		}
		else
		{
			qbQuestionMediaFileVO = new QbQuestionMediaFileVO();
		}	
		qbQuestionMediaFileVO.qbQuestionMediaFileType = uploadFileType;
		qbQuestionMediaFileVO.qbQuestionMediaFolderPath = path;
		qbQuestionMediaFileVO.qbQuestionMediaFileName = uploadFileName;
		qbQuestionMediaFileVO.qbQuestion = qbQuestionVO;
		qbQuestionVO.addQbQuestionMediaFile(qbQuestionMediaFileVO);
	}
	else if(mediaFileRemoved)
	{
		qbQuestionVO.qbQuestionMediaFiles.removeAll();
		qbQuestionVO.qbQuestionMediaFiles.refresh();
		mediaFileRemoved = false;
	}*/
	/** save the answers */
	var answers:ArrayCollection = new ArrayCollection();
	ArrayCollectionUtil.copyData(answers, qbQuestionVO.qbAnswerChoices);
	
	// To clear 'qbAnswerChoices' arraycollection, if it is not null.
	if (qbQuestionVO.qbAnswerChoices != null) 
	{
		qbQuestionVO.qbAnswerChoices.removeAll();
	}

	// Filling data to 'qbAnswerChoices' arraycollection	 
	for (var i:int = 0; i < answers.length; i++)
	{
		//Fix for Bug #11004
		answers[i].choiceText = StringUtil.trim(answers[i].choiceText);
		qbQuestionVO.addQbAnswerChoices(answers[i]);
	}

	// Setting display sequence to each answer choice.	 
	for (i = 0;i < choices.length;i++)
	{
		qbQuestionVO.qbAnswerChoices[i].displaySequence=i + 1;
	}

	// If polling there is no correct or wrong answer,so all answer choice fraction value is set to 1.	 
	if (isPolling)
	{
		for (i = 0;i < choices.length;i++)
		{
			qbQuestionVO.qbAnswerChoices[i].fraction = 1;
		}

		qbQuestionVO.qbQuestionTypeId = QuizContext.pollingQuestionTypeId;
	}
	if(Log.isDebug()) log.debug("getQuestionDetails::qbQuestionVO::" + qbQuestionVO);
	return qbQuestionVO;
}

/**
 * @private
 * Function : initQBQ Handler for initialize event
 *
 * @return void
*/
private function initQBQ():void
{
	qbQuestionHelper = new QbQuestionHelper();
	//Creating two dummy answer choices to show minimum two
	//answer choice textboxes. Since the answer choices are shown using
	//repeater we need to do this. These two dummy answer choices are added 
	//to the dummyQuestion varibale
	var dummyQuestion:QbQuestionVO = new QbQuestionVO;
	var dummyAns:QbAnswerChoiceVO = new QbAnswerChoiceVO;
	var dummyAnswers:ArrayCollection = new ArrayCollection;
	dummyAns.questionTypeId = QuizContext.MULTIPLE_CHOICE_QUESTION_TYPE_ID;
	dummyAns.questionLevelId = ClassroomContext.EASY;
	dummyAnswers.addItem(dummyAns);
	dummyAns = new QbAnswerChoiceVO;
	dummyAns.questionTypeId = QuizContext.MULTIPLE_CHOICE_QUESTION_TYPE_ID;
	dummyAns.questionLevelId = ClassroomContext.EASY;
	dummyAnswers.addItem(dummyAns);
	dummyQuestion.qbAnswerChoices = dummyAnswers;
	qbQuestionVO = dummyQuestion;	
	answerChoices = dummyAnswers;
	cbQuestionTypes.setFocus();
	questionText.setStyle("backgroundColor", "#ffffff");
	marksText.setStyle("backgroundColor", "#ffffff");
	levels.removeAll();
	questionTypes.removeAll();

	ArrayCollectionUtil.copyData(levels, ClassroomContext.quizDifficultyLevels);
	ArrayCollectionUtil.copyData(questionTypes, ClassroomContext.quizQuestionTypes);
	var index:int=QuizContext.getItemIndexByProperty(levels, "qbDifficultyLevelId", String(0));
	if (index != -1) {
		levels.removeItemAt(index);
	}
	index = QuizContext.getItemIndexByProperty(questionTypes, "qbQuestionTypeId", String(0));
	if (index != -1) {
		questionTypes.removeItemAt(index);
	}
	cbQuestionTypes.selectedIndex = QuizContext.getItemIndexByProperty(questionTypes, 'qbQuestionTypeId', String(QuizContext.MULTIPLE_CHOICE_QUESTION_TYPE_ID));
	levelsComboBox.selectedIndex = QuizContext.getItemIndexByProperty(levels, 'qbDifficultyLevelId', String(ClassroomContext.EASY));
	//	Fix for Bug#15068
	answerCanvasScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, scrollerPropertyChangeHandler);
}

/**
 * @private
 * Function : checkQuestionType Handler for change event in Question Type combo box.
 *
 * @return void
*/
private function onChangeQuestionType():void
{
	//Fix for Bug#14871,16837
	if(cbQuestionTypes.selectedIndex > -1)
	{
		qbQuestionVO.qbQuestionTypeId = cbQuestionTypes.selectedItem.qbQuestionTypeId;
		var dummyQuestion:QbQuestionVO = new QbQuestionVO;
		var dummyAns:QbAnswerChoiceVO = new QbAnswerChoiceVO;
		dummyAns.questionTypeId = cbQuestionTypes.selectedItem.qbQuestionTypeId;
		if(cbQuestionTypes.selectedItem.qbQuestionTypeId == QuizContext.TRUE_OR_FALSE_QUESTION_TYPE_ID)
		{
			dummyAns.choiceText = "True";
		}
		dummyQuestion.addQbAnswerChoices(dummyAns);
		dummyAns = new QbAnswerChoiceVO;
		dummyAns.questionTypeId = cbQuestionTypes.selectedItem.qbQuestionTypeId;
		if(cbQuestionTypes.selectedItem.qbQuestionTypeId == QuizContext.TRUE_OR_FALSE_QUESTION_TYPE_ID)
		{
			dummyAns.choiceText = "False";
		} 
		dummyQuestion.addQbAnswerChoices(dummyAns);
		qbQuestionVO = dummyQuestion;
		answerChoices = new ArrayCollection;
		answerChoices = qbQuestionVO.qbAnswerChoices;
		qbQuestionVO.qbQuestionTypeId = dummyAns.questionTypeId;
		if(Log.isDebug()) log.debug(""+answerChoices);
	}
	//Fix for Bug#16837:Start
	else
	{
		cbQuestionTypes.selectedIndex = -1;
	}
	//Fix for Bug#16837:End
}

/**
 * @private
 * Function : closeCreateQuestionBankQuestion To remove this component when user cancel it.
 *
 * @return void
 *
 */
private function closeCreateQuestionBankQuestion(qbQuestion : QbQuestionVO = null):void 
{
	this.dispatchEvent(new EvaluationEvent(EvaluationEvent.CREATE_OR_UPDATE,qbQuestion));
	PopUpManager.removePopUp(this);
}


/**
 * @private
 * Function : rollback Click handler for Cancel button.
 *
 * @return void
 */
private function rollback():void
{
	if(Log.isDebug()) log.debug("rollback::removedChoices.length::" + removedChoices.length);
	removedChoices.removeAll();
	closeCreateQuestionBankQuestion();
}

/**
 * @private
 * Function : addChoice Click handler for addChoice icon.
 *
 * @return void
 */
private function addChoice():void
{
	//Fix for Bug #11147,11159,11160
	if(qbQuestionVO.qbAnswerChoices.length < ClassroomContext.SYSTEM_PARAMETERS['QuizAnswerChoiceCount'])
	{
		var choice:QbAnswerChoiceVO = new QbAnswerChoiceVO;
		choice.questionTypeId = isPolling ? QuizContext.pollingQuestionTypeId : cbQuestionTypes.selectedItem.qbQuestionTypeId;
		qbQuestionVO.addQbAnswerChoices(choice);
	}
	else
	{
		//Fix for Bug#16863
		CustomAlert.error("Answer choices cannot be more than " + ClassroomContext.SYSTEM_PARAMETERS['QuizAnswerChoiceCount'] + ".", QuizContext.ALERT_TITLE_INFORMATION, null, this);
	}
}

/**
 * @private
 * Function : removeChoice Handler for 'removeChoice' event in 'choices' component.
 * @param event type of Event
 * @return void
 */
private function removeChoice(event:Event):void
{
	if (choices.length <= MIN_ANSWER_CHOICE_COUNT)
	{
		CustomAlert.error("Choice cannot be removed.\n At least two choices are required.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	
	// Loop through the choices to remove the deleted choices
	for (var i:int = 0; i < choices.length; i++) 
	{
		if (event.target == choices[i]) 
		{
			removedChoices.addItem(qbQuestionVO.qbAnswerChoices.removeItemAt(i));
			answerCanvas.setFocus();
			break;
		}
	}
}

/**
 * @private
 * Function : setCorrectAnswer Handler for 'radioButtonChange' event in 'choices' component.
 * To set the correct answer for the question.
 * @param event type of Event
 * @return void
 */
private function setCorrectAnswer(event:Event):void
{
	var i:int;
	if (isPolling || cbQuestionTypes.selectedItem == null || cbQuestionTypes.selectedItem.qbQuestionTypeId == QuizContext.MULTIPLE_CHOICE_QUESTION_TYPE_ID || cbQuestionTypes.selectedItem.qbQuestionTypeId == QuizContext.TRUE_OR_FALSE_QUESTION_TYPE_ID)
	{
		//To get the radio button object of the answer choice
		var rbAnswerChoice : RadioButton;
		for (i = 0; i < choices.length; i++) 
		{	
			// Set the correct answer fraction as '1' or '0' for wrong answer fraction
			// Checking the question type 'Multiple Choice' or is it a polling question. 
			// While creating or editing a  question , set the 'fraction' field appropriately as per the user's answer choice
			qbQuestionVO.qbAnswerChoices[i].fraction = (event.target == choices[i]) ? 1 : 0;
			rbAnswerChoice = (choices[i].answerChoiceForMC) as RadioButton;
			//Make the radio button selected to true if it is clicked by the user else false
			rbAnswerChoice.selected = (event.target == choices[i]) ? true : false;
		}
	}
	// Checking the question type 'Multiple Response'
	// While creating or editing a multiple response question , set the 'fraction' field appropriately as per the user's answer choice
	else if (cbQuestionTypes.selectedItem.qbQuestionTypeId == QuizContext.MULTIPLE_RESPONSE_QUESTION_TYPE_ID) {

		for (i = 0; i < choices.length; i++) 
		{			
			if (event.target == choices[i]) 
			{
				qbQuestionVO.qbAnswerChoices[i].fraction = (event.currentTarget.answerChoiceForMR.selected == true) ? 1 : 0;
			}
		}
	} 
	else 
	{
		CustomAlert.info("Please Select The Question Type", QuizContext.ALERT_TITLE_INFORMATION, null, this);
	}
}

/**
 * @protected
 * Function : questionTextCreationCompleteHandler Handler for 'CreationComplete' event in questionText component.
 * @param event type of FlexEvent
 * @return void
 */
protected function questionTextCreationCompleteHandler(event:FlexEvent):void {
	questionText.setFocus();

}

/**
 * @protected
 * Function : saveQuestion
 * Click handler for Save button.
 * @param event type of MouseEvent
 * @return void
 */
protected function saveQuestion(event:MouseEvent):void
{	
	qbQuestionVO = getQuestionDetails();
	if (validateQuestion()) 
	{
		if(isPolling)
		{
			//Fix for Bug#16830
			enableSaveButton(false);
			//When creating a new question ,it doesn't have an id.
			if(qbQuestionVO.qbQuestionId == 0)
			{
				qbQuestionHelper.createQbQuestionForPolling(qbQuestionVO, qbQuestionVO.qbAnswerChoices, ClassroomContext.userVO.userId,createQbQuestionForPollingResultHandler,createQbQuestionForPollingFaultHandler);
			}
				//When updating a question
			else
			{
				qbQuestionHelper.updateQbQuestion(qbQuestionVO, qbQuestionVO.qbAnswerChoices, ClassroomContext.userVO.userId,updateQbQuestionResultHandler,updateQbQuestionFaultHandler);
			}
		}
			//if quiz question
		else
		{
			/*if(StringUtil.trim(uploadFileTextInput.text) != "")
			{
				startUpload();
			}
			else
			{*/
				createQuizQuestion();
			/*}*/
		}
	}
}

/**
 *
 * @public
 * Function :createQbQuestionForPollingResultHandler
 * Result handler for 'createQbQuestionForPolling'.
 *
 * @param event type of QbQuestionVO
 * @return void
 *
 */
public function createQbQuestionForPollingResultHandler(qbQuestion:QbQuestionVO):void 
{
	if(Log.isInfo()) log.info("createQbQuestion_resultHandler::result::" + qbQuestion);
	if(Log.isInfo()) log.info("Created Question successfully .qbQuestionId::" + qbQuestion.qbQuestionId);
	closeCreateQuestionBankQuestion(qbQuestion);
}

/**
 *
 * @public
 * Function :createQbQuestionForPollingFaultHandler
 * Fault handler for 'createQbQuestionForPolling'.
 *
 * @param event type of FaultEvent
 * @return void
 *
 */
public function createQbQuestionForPollingFaultHandler(event:FaultEvent):void 
{
	if(Log.isError()) log.error("evaluation::questionBank::CreateQuestionBankQuestionUIHandler::createQbQuestionForPollingFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String = event.fault.faultString;
	if (strMsg.indexOf("Duplicate entry", 0) != -1) 
	{
		alertWindow = CustomAlert.error("The given question text already exists in the institute. Please try with a different question text", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		enableSaveButton(true);
	}
	else
	{
		closeCreateQuestionBankQuestion();
	}
}
/**
 *
 * @public
 * Function :updateQbQuestionResultHandler
 * Result handler for 'updateQbQuestion'.
 *
 * @param result type of QbQuestionVO
 * @return void
 *
 */
public function updateQbQuestionResultHandler(qbQuestion:QbQuestionVO):void 
{
	closeCreateQuestionBankQuestion(qbQuestion);
}
/**
 *
 * @public
 * Function :updateQbQuestionFaultHandler
 * Fault handler for 'updateQbQuestion'.
 *
 * @param event type of FaultEvent
 * @return void
 *
 */
public function updateQbQuestionFaultHandler(event:FaultEvent):void 
{
	if(Log.isError()) log.error("evaluation::questionBank::CreateQuestionBankQuestionUIHandler::updateQbQuestionFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String = event.fault.faultString;
	if (strMsg.indexOf("Duplicate entry", 0) != -1) 
	{
		alertWindow = CustomAlert.error("The given question text already exists in the institute. Please try with a different question text", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		enableSaveButton(true);
	} 
	else 
	{
		qbQuestionHelper.genericFaultHandler(event);
		closeCreateQuestionBankQuestion();
	}
}

/**
 * @public
 * Handles the result after creating a question
 * @param result type of QbQuestionVO
 * @return void
 *
 */
public function createQbQuestionResultHandler(result:QbQuestionVO):void {
	if(Log.isInfo()) log.info("createQbQuestion_resultHandler::result::" + result);
	if(Log.isInfo()) log.info("Created Question successfully .qbQuestionId::" + result.qbQuestionId);
	closeCreateQuestionBankQuestion(result);
}


/**
 * @public
 * Handles the fault , when a question is created
 * @param event type of FaultEvent
 * @return void
 *
 */
public function createQbQuestionFaultHandler(event:FaultEvent):void 
{
	if(Log.isError()) log.error("evaluation::questionBank::CreateQuestionBankQuestionUIHandler::createQbQuestionFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String = event.fault.faultString;
	if (strMsg.indexOf("Duplicate entry", 0) != -1) 
	{
		CustomAlert.error("The given question/Answer Choice(s)  already exist in the institute. Please try with a different question text", QuizContext.ALERT_TITLE_INFORMATION, null, this);
	}
	else 
	{
		qbQuestionHelper.genericFaultHandler(event);
		closeCreateQuestionBankQuestion();
	}
}
/**
 * @public
 * Close alert window
 * @return void
 *
 */
public function closeAlertWindow() : void
{
	if(this.alertWindow != null)
	{
		PopUpManager.removePopUp(alertWindow);
	}
}
/**
 * @public
 * Create a quiz question
 * It calls remote function to create and update question.
 * @return void
 *
 */
private function createQuizQuestion():void
{
	//When creating a new question ,it doesn't have an id.
	if(qbQuestionVO.qbQuestionId == 0)
	{
		//SubcategoryId is set before creating a question. In the case of polling it is set on server side. 
		qbQuestionVO.qbSubcategoryId = qbSubcategoryId;
		qbQuestionHelper.createQbQuestion(qbQuestionVO, qbQuestionVO.qbAnswerChoices, ClassroomContext.userVO.userId,createQbQuestionResultHandler,createQbQuestionFaultHandler);
	}
		//When updating a question
	else
	{
		if(Log.isInfo()) log.info("updateQuestion::qbQuestionVO::" + qbQuestionVO.toString());
		qbQuestionHelper.updateQbQuestion(qbQuestionVO, qbQuestionVO.qbAnswerChoices, ClassroomContext.userVO.userId,updateQbQuestionResultHandler,updateQbQuestionFaultHandler);
	}
}
/* Start : Uploading file*/

/**
 * @private
 * To browse for files to upload.
 * Adding event handler in fileReference
 * @return void
 *
 */
/*private function browseAndUpload():void
{
	applicationType::web
	{*/
		/**File is not available for web. So we changed File to FileReference */
	/*	fileReference=new FileReference();
	}
	applicationType::desktop
	{
		fileReference = new File();
	}
	fileFilter = new FileFilter("All","*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.mp3;*.mp4;*.flv;*.f4v");
	fileReference.browse([fileFilter]);
	fileReference.addEventListener(Event.CANCEL,cancelHandler);
	fileReference.addEventListener(Event.SELECT, uploadSelectHandler);
	fileReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
	fileReference.addEventListener(Event.COMPLETE, completeHandler);
	fileReference.addEventListener(IOErrorEvent.IO_ERROR, fileReferenceIOErrorEventHandler);
}*/

/**
 * @private
 * Cancel handler of fileReference
 * @param event type of Event
 * @return void
 *
 */
private function cancelHandler(event:Event):void
{
	trace("File not uploaded: Cancelled");
	
}

/**
 * @private
 * Select handler of fileReference
 * It sets upload file details
 * @param event type of Event
 * @return void
 *
 */
/*private function uploadSelectHandler(event:Event):void
{
		if(fileReference.size > MAX_UPLOAD_FILE_SIZE)
		{
			CustomAlert.info("Your file size exceeds the limit.Try another one","A-VIEW");
			return;
		}
	var fileExtention : String = "";
	fileExtention = event.target.extension;	
	
	if(fileFilter.extension.indexOf("*."+fileExtention.toLowerCase()) == -1)
	{
		Alert.show("Selected document "+event.target.name+" is not of a valid file type", "WARNING", 0, this);
		uploadFileName = "";
		tempNativeFilePath = "";
	}
	else
	{
		//the file name which is selected by user
		uploadFileName = event.target.name;
		uploadFileName = FileManager.replaceSpecialChars(uploadFileName,this);
		if(fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_JPG || fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_JPEG 
			|| fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_PNG || fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_GIF || fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_BMP)
		{
			uploadFileType = QuizContext.MEDIA_FILE_TYPE_IMAGE;	
			setImageVisibility(true);
			setVideoVisibility(false);
			applicationType::desktop
			{
				tempNativeFilePath = fileReference.nativePath;
			}
		}
		else if(fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_MP3 || fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_WAV)
		{
			uploadFileType = QuizContext.MEDIA_FILE_TYPE_AUDIO;
			setVideoVisibility(true);
			videoPlayer.play();
			setImageVisibility(false);
			applicationType::desktop
			{
				tempNativeFilePath = fileReference.nativePath;
			}
		}
		else if(fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_MP4 || fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_FLV || fileExtention.toLowerCase() == UPLOAD_FILE_FORMAT_F4V)
		{
			uploadFileType = QuizContext.MEDIA_FILE_TYPE_VIDEO;
			setVideoVisibility(true);
			videoPlayer.play();
			setImageVisibility(false);
			applicationType::desktop
			{
				tempNativeFilePath = fileReference.nativePath;	
			}
		}
		if(tempNativeFilePath == "")
		{
			setImageVisibility(false);
			setVideoVisibility(false);
		}
		uploadFileTextInput.text = tempNativeFilePath;
	}	
}*/

/**
 * @private
 * Progress handler of fileReference
 * @param event type of ProgressEvent
 * @return void
 *
 */
/*private function onUploadProgress(event:ProgressEvent):void
{
	var numPercnt:Number = Math.round((event.bytesLoaded / event.bytesTotal) * 100);
	progressIcon.label = numPercnt+"%";
}*/

/**
 * @private
 * Complete handler of fileReference
 * @param event type of Event
 * @return void
 *
 */
/*private function completeHandler(event:Event):void
{
	progressIcon.visible = false;
}*/
/**
 * @private
 * IOErrorEvent handler of fileReference
 * @param event type of IOErrorEvent
 * @return void
 *
 */
private function fileReferenceIOErrorEventHandler(error : IOErrorEvent):void
{
	trace("IO Error ::" + error);	
}
/**
 * @private
 * Upload the file using contentService(Uploading to the content server)
 * @return void
 *
 */
/*private function startUpload():void
{
	progressIcon.visible = true;
	//Uploading using content service
	var folderPath:String = "../../AVContent/Upload/Personal/" + ClassroomContext.userVO.userName + "/My Quiz Files";
	var contentService:ContentService = new ContentService();
	contentService.uploadFile(folderPath,fileReference,uploadResultHandler,uploadFaultHandler);
	
}*/
/**
 * @public
 * Result handler for uploading the file in content server
 * @return void
 *
 */
public function uploadResultHandler(event : Event):void
{
	trace("fileUploaded successfully");
	createQuizQuestion();
}
/**
 * @public
 * Fault handler for uploading the file in content server
 * @return void
 *
 */
public function uploadFaultHandler(event : Event):void
{
	CustomAlert.error("Not able to upload this file");
	trace("file not Uploaded "+event);
}
/**
 * @private
 * To set visibility of videoPlayer
 * @return void
 *
 */
/*private function setVideoVisibility(value : Boolean):void
{
	if(value)
	{
		setPreviewBoxVisibility(value);
		setDeleteButtonVisibility(value);
	}
	videoPlayer.visible = value;
	videoPlayer.includeInLayout = value;
}*/
/**
 * @private
 * To set visibility of ImageLoader
 * @return void
 *
 */
/*private function setImageVisibility(value : Boolean):void
{
	if(value)
	{
		setPreviewBoxVisibility(value);
		setDeleteButtonVisibility(value);
	}
	imageLoader.visible = value;
	imageLoader.includeInLayout = value;
}*/

/**
 * @private
 * To set visibility of previewBox
 * @return void
 *
 */
/*private function setPreviewBoxVisibility(value : Boolean):void
{
	previewBox.visible = value;
	previewBox.includeInLayout = value;
}*/

/**
 * @private
 * To set visibility of delete button
 * @return void
 *
 */
/*private function setDeleteButtonVisibility(value : Boolean):void
{
	btnDelete.visible = value;
	btnDelete.includeInLayout = value;
}*/

/**
 * @private
 * To remove media file
 * @return void
 *
 */
/*private function removeMediaFile():void
{
	mediaFileRemoved = true;
	uploadFileTextInput.text = null;
	tempNativeFilePath = null;
	setImageVisibility(false);
	setVideoVisibility(false);
	setPreviewBoxVisibility(false);
}*/

/**
 * @private
 * HTTPStatusEvent handler for imageLoader
 * @return void
 *
 */
/*private function imageHttpStatusEventHandler(event : HTTPStatusEvent):void
{
	trace("HTTPStatusEvent: :" + event);
	if(event.status != 200)
	{
		setImageVisibility(false);
		setVideoVisibility(false);
		errorImage.visible = true;
		errorImage.includeInLayout = true;
		btnDelete.visible = false;
		btnDelete.includeInLayout = false;
		
	}
}*/
/**
 * @private
 * IOErrorEvent handler for imageLoader
 * @return void
 *
 */
/*private function imageIOErrorEventHandler(event : IOErrorEvent):void
{
	trace("HTTPStatusEvent: :" + event);
	if(event)
	{
		setImageVisibility(false);
		setVideoVisibility(false);
		errorImage.visible = true;
		errorImage.includeInLayout = true;
		btnDelete.visible = false;
		btnDelete.includeInLayout = false;		
	}
}*/
/**
 * @private
 * Loading complete handler for imageLoader
 * @return void
 *
 */
/*private function imageLoadingCompleteHandler(event : Event):void
{
	trace("HTTPStatusEvent: :" + event);
	if(event)
	{		
		btnDelete.visible = true;
		btnDelete.includeInLayout = true;
		
		errorImage.visible = false;
		errorImage.includeInLayout = false;
	}
}*/
/* End : Uploading file*/

/**
 * @private
 * PropertyChange handler for answerCanvasScroller
 * To set vertical scroller position to the bottom when a new choice is added.
 * @param event type of PropertyChangeEvent
 * @return void
 *
 */
//	Fix for Bug#15068
private function scrollerPropertyChangeHandler(event:PropertyChangeEvent):void 
{	
	if((event.target == answerCanvas) && (event.property == "contentHeight") )
	{
		answerCanvas.layout.verticalScrollPosition = event.newValue as Number;
	}
}
//Fix for Bug#16837:Start
private function difficultyLevelChangeHandler():void
{
	if(levelsComboBox.selectedIndex > -1)
	{
		qbQuestionVO.qbDifficultyLevelId = levelsComboBox.selectedItem != null ? levelsComboBox.selectedItem.qbDifficultyLevelId : 0
	}
	else
	{
		levelsComboBox.selectedIndex = -1;
	}
		
}
//Fix for Bug#16837:End
//Fix for Bug#16830:Start
private function enableSaveButton(value : Boolean):void
{
	btnSave.enabled = value;
}
//Fix for Bug#16830:End