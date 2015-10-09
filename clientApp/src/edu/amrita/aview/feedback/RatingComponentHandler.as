////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: RatingComponentHandler.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 *
 * Business logic for the feedback rating component
 */
// ashCR: TODO: please change multi line comment to single line by using //
// ashCR: the /** type comments are used in generating the document and should
// ashCR: be used mostly in headers, function description etc; they are an overkill when used with import statements
/**
 * Importing the feedback package
 */
import edu.amrita.aview.feedback.MoreRatingDesc;

import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

/**
 * stores the true,false value in this variable
 * this variable will used in the checking at the time of creating the popup window
 */

[Bindable]
public var moreRatingPopupflag:Boolean=false;

/**
 * Creating an object for the MoreRatingComponent
 */
[Bindable]
private var moreRatingComp:MoreRatingDesc;

/**
 * Object to connect to the main application
 */
[Bindable]
private var application:Object = FlexGlobals.topLevelApplication;

/**
 * @protected
 * For adding the more details
 * This will invoke from the addComment Component
 *
 * @param event type MouseEvent
 * @param ComponentName type string
 * @param comment type details
 * @return void
 */

protected function moreRatingDetails(event:MouseEvent, componentName:String, comment:String,parentObj:Object):void
{
	if (application.mainApp.mainContainerComp.isPopupFeedbackComment == false)
	{
		moreRatingComp=new MoreRatingDesc();
		PopUpManager.addPopUp(moreRatingComp, this, true);
		moreRatingComp.comment=comment;
		moreRatingComp.componentName=componentName;
		moreRatingComp.parentComponent = parentObj;
		PopUpManager.centerPopUp(moreRatingComp);
		application.mainApp.mainContainerComp.isPopupFeedbackComment=true;
	}
}

/**
 * @public
 * to show the comments for the editing purpose
 * This will invoke from the saveComments function
 *
 * @param commentDetails type string
 * @param componentName type string
 * @return void
 */

public function showComments(commentDetails:String, componentName:String):void
{
	switch (componentName)
	{
		case 'overall':
			txtOverAllRating.text=commentDetails;
			if (commentDetails != null && commentDetails != '')
				txtOverAllRating.visible=true;
			else
				txtOverAllRating.visible=false;
			
			
			break;
		case 'video':
			txtvideoRating.text=commentDetails;
			if (commentDetails != null && commentDetails != '')
				txtvideoRating.visible=true;
			else
				txtvideoRating.visible=false;
			
			break;
		case 'audio':
			txtAudioRating.text=commentDetails.toString();
			if (commentDetails != null && commentDetails != '')
				txtAudioRating.visible=true;
			else
				txtAudioRating.visible=false;
			
			break;
		case 'interaction':
			txtinteractionRating.text=commentDetails.toString();
			if (commentDetails != null && commentDetails != '')
				txtinteractionRating.visible=true;
			else
				txtinteractionRating.visible=false;
			
			break;
		case 'desktop':
			txtshrRating.text=commentDetails.toString();
			if (commentDetails != null && commentDetails != '')
				txtshrRating.visible=true;
			else
				txtshrRating.visible=false;
			
			break;
		case 'whiteboard':
			txtwhiteBrdRating.text=commentDetails.toString();
			if (commentDetails != null && commentDetails != '')
				txtwhiteBrdRating.visible=true;
			else
				txtwhiteBrdRating.visible=false;
			
			break;
		case 'document':
			txtcontentRating.text=commentDetails.toString();
			if (commentDetails != null && commentDetails != '')
				txtcontentRating.visible=true;
			else
				txtcontentRating.visible=false;
			
			break;
		case 'userInterAct':
			txtUserInterRating.text=commentDetails.toString();
			if (commentDetails != null && commentDetails != '')
				txtUserInterRating.visible=true;
			else
				txtUserInterRating.visible=false;
			
			break;
	}
}
