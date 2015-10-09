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
 * File			: QuestionPaperQuestionPreviewUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This component is used to display the preview of
 * questions used in question paper
 */

import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.vo.QbQuestionTypeVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;

import org.osmf.events.MediaPlayerStateChangeEvent;

[Bindable]
/**
 * Value Object
 */
public var quesItem:QbQuestionVO;
/**
 * The serial number of a question
 */
[Bindable]
public var qno:String;
/**
 * Flag used to hide/show answers for a question in the preview
 */
[Bindable]
public var showAnswers:Boolean;

/**
 * Flag used to stop video
 */
private var stopVideoFlag:Boolean = true;

[Bindable]
/**
 * Temporary variable to hold media file path
 */
private var mediaFilePath:String = null;
/**
 * @private
 * Used to set users answer
 * @param event of type MouseEvent
 * @return void
 *
 */
private function setUserAnswer(event:MouseEvent):void {
	var str:String=event.target.label;
	str=str.charAt(0);
}

private function getQuestionTypeId():int
{
	var questionTypesAC:ArrayCollection = new ArrayCollection() ;
	var questionTypeVO:QbQuestionTypeVO = null ;
	var index:int = 0 ;
	ArrayCollectionUtil.copyData(questionTypesAC,ClassroomContext.quizQuestionTypes) ;
	for(var i:int = 0 ; i < questionTypesAC.length ; i++)
	{
		questionTypeVO = questionTypesAC.getItemAt(i) as QbQuestionTypeVO;
		if(questionTypeVO.qbQuestionTypeName == QuizContext.MULTIPLERESPONSE)
		{
			index =questionTypeVO.qbQuestionTypeId ;
			break ;
		}
	}
	
	return index ;
}
private function onCreationComplete():void
{
	if(quesItem.qbQuestionMediaFiles.length > 0)
	{
		previewBox.visible = true;
		previewBox.includeInLayout = true;
		mediaFilePath = quesItem.qbQuestionMediaFiles[0].qbQuestionMediaFolderPath + quesItem.qbQuestionMediaFiles[0].qbQuestionMediaFileName;
		
		if(quesItem.qbQuestionMediaFiles[0].qbQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_IMAGE)
		{
			imageLoader.visible = true;
			imageLoader.includeInLayout = true;
		}
		else if(quesItem.qbQuestionMediaFiles[0].qbQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_AUDIO || quesItem.qbQuestionMediaFiles[0].qbQuestionMediaFileType == QuizContext.MEDIA_FILE_TYPE_VIDEO)
		{
			videoLoader.visible = true;
			videoLoader.includeInLayout = true;
			videoLoader.stop();
		}
	}
}

protected function videoLoader_mediaPlayerStateChangeHandler(event:MediaPlayerStateChangeEvent):void
{
	if(event.state == "playing" && stopVideoFlag)
	{
		videoLoader.stop();
		videoLoader.playPauseButton.selected = !videoLoader.playPauseButton.selected; 
		stopVideoFlag = false;
	} 
}