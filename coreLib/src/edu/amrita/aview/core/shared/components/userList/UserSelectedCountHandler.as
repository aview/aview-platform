import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;

/**
 *
 * File			: UserSelectedCountHandler.as
 * Module		: Common
 * Developer(s)	: Ashish
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-add description for bindable variable
//VGCR:-add description for function
[Bindable]
private var userIntCount:String;

[Bindable]
private var toolTipData:String;
private var isPCEnabled:Boolean;

/**
 *@private 
 * 
 */
private function changeICon():void
{
	if(ClassroomContext.userVO.role==Constants.MONITOR_TYPE){
		userIntCount=this.data.viewVideoCount.toString();
		toolTipData="Monitor Count : " + userIntCount;
	}
	else{
		isPCEnabled = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.peopleCountFlag;
		if(isPCEnabled){
			userIntCount=this.data.peopleCount.toString();
		 	toolTipData="People Count : " + userIntCount;
		}
		else{
			userIntCount=this.data.userInteractedCount.toString();
			toolTipData="Interaction Count : " + userIntCount;
		}
		
	}
	
}
