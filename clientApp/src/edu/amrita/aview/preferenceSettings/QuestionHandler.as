import flash.events.Event;

import mx.core.FlexGlobals;


protected function chkBoxQuestionInteraction_changeHandler(event:Event):void
{
	
	
	if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.interactionStatusChanged)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.interactionStatusChanged=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionInteractionStatus=chkBoxQuestionInteraction.selected;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionInitialInteractionStatus=!chkBoxQuestionInteraction.selected;
	}
}