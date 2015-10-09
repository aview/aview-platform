// ActionScript file
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
 * File			: UserNameRendererHandler.as
 * Module		: Common
 * Developer(s)	: Sivaram SK
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 *
 */
//VGCR:Bindable variable description
//VGCR:-function description 
//VGCR:-Variable description
import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.Constants;

import mx.core.FlexGlobals;
private var userlist_max_len:int;

[Bindable]
private var icon_source:Class;

[Bindable]
[Embed(source="assets/images/teacher gray(desktop).png")]
public var teacher_hold_desktop:Class;

[Bindable]
[Embed(source="assets/images/teacher green(desktop).png")]
public var teacher_active_desktop:Class;

[Bindable]
[Embed(source="assets/images/student gray(desktop).png")]
public var student_hold_desktop:Class;

[Bindable]
[Embed(source="assets/images/student green(desktop).png")]
public var student_active_desktop:Class;

[Bindable]
[Embed(source="assets/images/teacher gray(web).png")]
public var teacher_hold_web:Class;

[Bindable]
[Embed(source="assets/images/teacher green(web).png")]
public var teacher_active_web:Class;

[Bindable]
[Embed(source="assets/images/student gray(web).png")]
public var student_hold_web:Class;

[Bindable]
[Embed(source="assets/images/guest gray(web).png")]
public var guest_hold_web:Class;

[Bindable]
[Embed(source="assets/images/student green(web).png")]
public var student_active_web:Class;

[Bindable]
[Embed(source="assets/images/teacher gray(mobile).png")]
public var teacher_hold_mobile:Class;

[Bindable]
[Embed(source="assets/images/teacher green(mobile).png")]
public var teacher_active_mobile:Class;

[Bindable]
[Embed(source="assets/images/student gray(mobile).png")]
public var student_hold_mobile:Class;

[Bindable]
[Embed(source="assets/images/student green(mobile).png")]
public var student_active_mobile:Class;


[Bindable]
public var displayName:String;

[Bindable]
public var instituteName:String;

[Bindable]
private var tooltipText:String;

/**
 *@private 
 * 
 */
private function changeICon():void
{
	var blnk:String=" ";
	var dName:String;
	var iName:String;
	var idxDispName:int;
	var idxInstName:int;
	// AKCR: please refer to the end of document for suggestion of re-factoring the code 
	//Alert.show("userName: "+data.userDisplayName+"\n runtime: "+data.avcRuntime+"\n deviceType: "+data.avcDeviceType);
	if (this.data.avcDeviceType == AVCEnvironment.DESKTOP && this.data.avcRuntime == AVCEnvironment.STAND_ALONE)
	{
		if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_desktop;
		}
		else if (this.data.userStatus == Constants.ACCEPT && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_active_desktop;
		}
		else if (this.data.userStatus == Constants.VIEW && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_desktop;
		}
		else if (this.data.userStatus == Constants.WAITING && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_desktop;
		}
		
		else if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_desktop;
		}
		else if (this.data.userStatus == Constants.ACCEPT && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_active_desktop;
		}
		else if (this.data.userStatus == Constants.VIEW && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_desktop;
		}
		else if (this.data.userStatus == Constants.WAITING && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_desktop;
		}
	}
	else if (this.data.avcDeviceType == AVCEnvironment.DESKTOP && this.data.avcRuntime == AVCEnvironment.BROWSER)
	{
		if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_web;
		}
		else if (this.data.userStatus == Constants.ACCEPT && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_active_web;
		}
		else if (this.data.userStatus == Constants.VIEW && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_web;
		}
		else if (this.data.userStatus == Constants.WAITING && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_web;
		}
		
		else if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_web;
		}
		else if (this.data.userStatus == Constants.ACCEPT && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_active_web;
		}
		else if (this.data.userStatus == Constants.VIEW && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_web;
		}
		else if (this.data.userStatus == Constants.WAITING && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_web;
		}
		else if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.GUEST_TYPE)
		{
			icon_source=guest_hold_web;
		}
	}
	else if (this.data.avcDeviceType == AVCEnvironment.HAND_HELD_DEVICES && this.data.avcRuntime == AVCEnvironment.STAND_ALONE)
	{
		if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_mobile;
		}
		else if (this.data.userStatus == Constants.ACCEPT && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_active_mobile;
		}
		else if (this.data.userStatus == Constants.VIEW && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_mobile;
		}
		else if (this.data.userStatus == Constants.WAITING && this.data.userType == Constants.TEACHER_TYPE)
		{
			icon_source=teacher_hold_mobile;
		}
		
		else if (this.data.userStatus == Constants.HOLD && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_mobile;
		}
		else if (this.data.userStatus == Constants.ACCEPT && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_active_mobile;
		}
		else if (this.data.userStatus == Constants.VIEW && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_mobile;
		}
		else if (this.data.userStatus == Constants.WAITING && this.data.userType == Constants.STUDENT_TYPE)
		{
			icon_source=student_hold_mobile;
		}
		
	}
	
	displayName=this.data.userDisplayName;
	instituteName=this.data.userInstituteName;
	idxDispName=displayName.length;
	idxInstName=instituteName.length;
	userlist_max_len=Constants.USERLIST_MAX_LEN_CONSO;
	
	
	// AKCR: the following if/else is perhaps missing some cases. For e.g what is isModerator is true and userRole is Presenter?
	if (this.data.isModerator == true)
	{
		displayName="<b>M:</b> " + displayName;
		tooltipText="MODERATOR: " + this.data.userDisplayName + "\n" + "INSTITUTE: " + this.data.userInstituteName;
	}
	else if (this.data.userRole == Constants.PRESENTER_ROLE)
	{
		displayName="<b>P:</b> " + displayName;
		tooltipText="PRESENTER: " + this.data.userDisplayName + "\n" + "INSTITUTE: " + this.data.userInstituteName;
	}
	else if (this.data.userStatus == Constants.ACCEPT)
	{
		displayName="<b>V:</b> " + displayName;
		tooltipText="SELECTED VIEWER: " + this.data.userDisplayName + "\n" + "INSTITUTE: " + this.data.userInstituteName;
	}
	else
	{
		displayName=displayName;
		tooltipText="VIEWER: " + this.data.userDisplayName + "\n" + "INSTITUTE: " + this.data.userInstituteName;
	}
}

// AKCR: the chain of IF statements can be re-factored to use an XML configuration and simplyfy the code logic
// AKCR: Below is a map / xml alternative to the above complicated logic; this may make the code more 
// AKCR: readable and maintainable
// CONFIG*********************
//Desktop: {
//	standalone :{
//		TEACHER_TYPE :{ 
//			{HOLD   : teacher_hold_desktop}
//			{ACCEPT : teacher_hold_desktop}
//			{VIEW   : teacher_hold_desktop}
//			{WAITING: teacher_hold_desktop}
//		},
//		STUDENT_TYPE :{ 
//			{HOLD   : student_hold_desktop}
//			{ACCEPT : student_hold_desktop}
//			{VIEW   : student_hold_desktop}
//			{WAITING: student_hold_desktop}
//	}
//	browser : {
//		TEACHER_TYPE :{ 
//			{HOLD   : teacher_hold_desktop}
//			{ACCEPT : teacher_hold_desktop}
//			{VIEW   : teacher_hold_desktop}
//			{WAITING: teacher_hold_desktop}
//		},
//		STUDENT_TYPE :{ 
//			{HOLD   : student_hold_desktop}
//			{ACCEPT : student_hold_desktop}
//			{VIEW   : student_hold_desktop}
//			{WAITING: student_hold_desktop}
//		}
//	},
//handheld: {
//	standalone : {	
//		TEACHER_TYPE :{ 
//			{HOLD   : teacher_hold_desktop}
//			{ACCEPT : teacher_hold_desktop}
//			{VIEW   : teacher_hold_desktop}
//			{WAITING: teacher_hold_desktop}
//		},
//		STUDENT_TYPE :{ 
//			{HOLD   : student_hold_desktop}
//			{ACCEPT : student_hold_desktop}
//			{VIEW   : student_hold_desktop}
//			{WAITING: student_hold_desktop}
//		}
//	}
//}
//		
//// CODE*********************
////		icon_source = MYSTRUCT[this.data.userType][this.data.userStatus]
//// CODE*********************
//
