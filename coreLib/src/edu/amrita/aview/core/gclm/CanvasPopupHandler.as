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
 * File			: CanvasPopupHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.gclm.course.*;
import edu.amrita.aview.core.gclm.vo.ClassVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

[Bindable]
public var courseArr:Array=new Array;

[Bindable]
public var courseArr1:Array=new Array;
[Bindable]
public var teacherAC:ArrayCollection=new ArrayCollection;

[Bindable]
public var nodeCourseAC:ArrayCollection=new ArrayCollection();
[Bindable]
public var classAC:ArrayCollection=new ArrayCollection();
public var str1:int=0;
[Bindable]
public var str:String="";

[Bindable]
public var nodeTypeAC:ArrayCollection=new ArrayCollection();
[Bindable]
public var courseAC:ArrayCollection=new ArrayCollection();
[Bindable]
public var userAC:ArrayCollection=new ArrayCollection();
[Bindable]
public var highBandWArr:ArrayCollection=new ArrayCollection();
[Bindable]
public var medBandWArr:ArrayCollection=new ArrayCollection();
[Bindable]
public var lowBandWArr:ArrayCollection=new ArrayCollection();
private var defaultPrompt:Object;
public var highSelected:Object=null;
public var medSelected:Object=null;
public var lowSelected:Object=null;
public var minPublishBW:Object=null;
public var maxPublishBW:Object=null;
[Bindable]
private var dpMinPublishBWAC:ArrayCollection=new ArrayCollection();
[Bindable]
private var dpMaxPublishBWAC:ArrayCollection=new ArrayCollection();

[Bindable]
public var multiBitStatusIndicator:Boolean=false;
//Fix Bug #1817 start
// 1. Declared classVO as public variable
// 2. Declared a new variable to check if component is closed or open
public var classVO:ClassVO;

public var isCancelButtonClicked:Boolean=false;

[Bindable]
public var checkIfInitialise:Boolean=false;

//Fix Bug #1817 start
// 1. Added new event on creationComplete of component
// 2. Assign the flag a true value
//3. Check if the flag is true , delay initialisation

/**
 * @private
 *
 *
 *
 * @return void
 *
 ***/
private function creationCompleteEvent():void
{
	checkIfInitialise=true;
}

/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function init():void
{
	while (!checkIfInitialise)
	{
		
	}
	//setToolTipStyle() ;
	if (str == "Recordedlectures")
	{
		vS.addChild(recordedLectures);
		recordedLectures.visible=true;
//		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedLectureName == "")
//		{
//			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedLectureName=ClassroomContext.lecture.lectureName;
//		}
		lblLectureName.text=ClassroomContext.lecture.displayName;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords != "")
			txtKeywords.text=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords;
		else
			txtKeywords.text=ClassroomContext.lecture.displayName;
	}
}

/**
 * @private
 *
 *
 * @param e of type MouseEvent
 * @return void
 *
 ***/
private function closeThis(e:MouseEvent):void
{
	PopUpManager.removePopUp(this);
}

// Bug fix for Id #1388 end	
/**
 * @public
 *
 *
 *
 * @return void
 *
 ***/
public function getvalue():void
{

}
public var d:Date=new Date();

/**
 * @private
 *
 *
 *
 * @return void
 *
 ***/
private function closeRecordingPopup():void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changeRecordIcon();
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.RecordIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.StartRecordIcon;
	PopUpManager.removePopUp(this);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnRecord.toolTip="Start Recording";
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnRecord.enabled=true;
}
