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
 * File			: AdministrationHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This acts as handler for Administration.mxml
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.aviewClass.ClassComp;
import edu.amrita.aview.core.gclm.classRegistration.ClassRegistrationComp;
import edu.amrita.aview.core.gclm.course.CourseComp;
import edu.amrita.aview.core.gclm.institute.InstituteComp;
import edu.amrita.aview.core.gclm.lecture.LectureComp;
import edu.amrita.aview.core.gclm.user.UserComp;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.gclm.vo.CourseVO;
import edu.amrita.aview.core.gclm.vo.InstituteVO;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

private var courseInst:CourseComp=new CourseComp;
private var classInst:ClassComp=new ClassComp;
private var lectureInst:LectureComp=new LectureComp;
private var UserInst:UserComp=new UserComp;
private var RegisterInst:ClassRegistrationComp=new ClassRegistrationComp;
private var instituteComp:InstituteComp=new InstituteComp;

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function clickCourse():void
{
	ParentComponent.removeAllChildren();
	ParentComponent.addChild(courseInst);
	courseInst.initApp();
	CourseIcon=Course_clicked;
	LectureIcon=Lecture_unclicked;
	UserAccountIcon=UserAccount_unclicked;
	ClassRegistrationIcon=ClassRegistration_unclicked;
	ClassIcon=Class_unclicked;
	InstituteIcon=Institute_unclicked;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function clickLecture():void
{
	ParentComponent.removeAllChildren();
	ParentComponent.addChild(lectureInst);
	lectureInst.initApp();
	CourseIcon=Course_unclicked;
	LectureIcon=Lecture_clicked;
	UserAccountIcon=UserAccount_unclicked;
	ClassRegistrationIcon=ClassRegistration_unclicked;
	ClassIcon=Class_unclicked;
	InstituteIcon=Institute_unclicked;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function clickUserAccount():void
{
	ParentComponent.removeAllChildren();
	ParentComponent.addChild(UserInst);
	UserInst.initApp();
	CourseIcon=Course_unclicked;
	LectureIcon=Lecture_unclicked;
	UserAccountIcon=UserAccount_clicked;
	ClassRegistrationIcon=ClassRegistration_unclicked;
	ClassIcon=Class_unclicked;
	InstituteIcon=Institute_unclicked;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function clickClassRegistration():void
{
	ParentComponent.removeAllChildren();
	ParentComponent.addChild(RegisterInst);
	RegisterInst.initApp();
	CourseIcon=Course_unclicked;
	LectureIcon=Lecture_unclicked;
	UserAccountIcon=UserAccount_unclicked;
	ClassRegistrationIcon=ClassRegistration_clicked;
	ClassIcon=Class_unclicked;
	InstituteIcon=Institute_unclicked;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function clickInstitute():void
{
	ParentComponent.removeAllChildren();
	ParentComponent.addChild(instituteComp);
	instituteComp.initComp();
	CourseIcon=Course_unclicked;
	ClassIcon=Class_unclicked;
	LectureIcon=Lecture_unclicked;
	UserAccountIcon=UserAccount_unclicked;
	ClassRegistrationIcon=ClassRegistration_unclicked;
	InstituteIcon=Institute_clicked;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
private function clickClass():void
{
	ParentComponent.removeAllChildren();
	ParentComponent.addChild(classInst);
	classInst.initClassComp();
	CourseIcon=Course_unclicked;
	ClassIcon=Class_clicked;
	LectureIcon=Lecture_unclicked;
	UserAccountIcon=UserAccount_unclicked;
	ClassRegistrationIcon=ClassRegistration_unclicked;
	InstituteIcon=Institute_unclicked;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function myDataTipFunction(value:Object):String
{
	var toolTip:String="";
	if (value is CourseVO)
	{
		toolTip=(value.courseName);
	}
	else if (value is InstituteVO)
	{
		toolTip=(value.instituteName);
	}
	else if (value is ClassVO)
	{
		toolTip=(value.className);
	}
	return toolTip;
}

/**
 * @protected
 *
 *
 * @param event of type FlexEvent
 * @return void
 *
 ***/
protected function creationCompleteHandler(event:FlexEvent):void
{
	GCLMContext.dropdownFactory.properties={showDataTips: true, dataTipFunction: myDataTipFunction}
}

//Admin module
/*Issue No:525 & 527 is fixed   */

/**
 * @private
 *
 *
 *
 * @return void
 *
 ***/
private function callRemove():void
{
	ParentComponent.removeAllChildren();
	CourseIcon=Course_unclicked;
	LectureIcon=Lecture_unclicked;
	UserAccountIcon=UserAccount_unclicked;
	ClassRegistrationIcon=ClassRegistration_unclicked;
	ClassIcon=Class_unclicked;
}
