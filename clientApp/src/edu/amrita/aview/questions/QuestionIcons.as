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
 * File			: QuestionIcons.as
 * Module		: Question
 * Developer(s)	: Ravishankar
 * Reviewer(s)	: Meena S
 * 
 * All Question & Answer feature related styles defined in this file.
 * Besides the close Break Session pop up style also defined in this file.
 * 
 */

/**
 * 	Used to indicate that the answer question button state is enabled and may be used to mark the selected Question as Answered
 */
[Bindable]
[Embed(source="assets/images/answer.png")]
public var answer_icon:Class;

/**
 *	Used to indicate that the answer question button state is disabled
 */
[Bindable]
[Embed(source="assets/images/answer_disabled.png")]
public var answerDisabled_icon:Class;

/**
 *	Used to indicate that the delete question button state is enabled and may be used to delete the selected Question
 */
[Bindable]
[Embed(source="assets/images/delete.png")]
public var delete_icon:Class;

/**
 *	Used to indicate that the delete question button state is disabled
 */
[Bindable]
[Embed(source="assets/images/delete_disabled.png")]
public var deleteDisabled_icon:Class;
applicationType::DesktopWeb{
	/**
	 *	Used to indicate that the post question button state is enabled and may be used to post the inputed Question
	 */
	[Bindable]
	[Embed(source="assets/images/post.png")]
	public var post_icon:Class;
	/**
	 *	Used to indicate that the vote question button state is enabled and may be used to vote in favour of the selected Question
	 */
	[Bindable]
	[Embed(source="assets/images/vote.png")]
	public var vote_icon:Class;
	/**
	 *	Used to indicate that the vote for the question button state is disabled
	 */
	[Bindable]
	[Embed(source="assets/images/vote_disabled.png")]
	public var voteDsiabled_icon:Class;

}
applicationType::mobile{
	/**
	 *	Used to indicate that the post question button state is enabled and may be used to post the inputed Question
	 */
	[Bindable]
	[Embed(source="assets/images/post_mobile.png")]
	public var post_icon:Class;
	/**
	 *	Used to indicate that the vote question button state is enabled and may be used to vote in favour of the selected Question
	 */
	[Bindable]
	[Embed(source="assets/images/vote_mobile.png")]
	public var vote_icon:Class;
	
	/**
	 *	Used to indicate that the vote for the question button state is disabled
	 */
	[Bindable]
	[Embed(source="assets/images/vote_disabled_mobile.png")]
	public var voteDsiabled_icon:Class;

}

/**
 *	Used to indicate that the button will disable the Question & Answer feature
 */
[Bindable]
[Embed(source="assets/images/questionAnswerDisable.png")]
public var questionAnswerDisable_icon:Class;

/**
 *	Used to indicate that the button will enable the Question & Answer feature
 */
[Bindable]
[Embed(source="assets/images/questionAnswerEnable.png")]
public var questionAnswerEnable_icon:Class;

/**
 *	Used to close the BreakSession pop up
 */ 
[Bindable]
[Embed(source="assets/images/Medium_close.png")]
public var breakSession_closePng:Class;
