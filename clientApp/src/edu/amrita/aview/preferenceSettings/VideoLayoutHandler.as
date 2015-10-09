import edu.amrita.aview.core.entry.Constants;

import mx.core.FlexGlobals;

private function init():void
{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout == Constants.PRESENTER_LAYOUT)
	{
		rbPresentation.selected=true;
	}
	else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout == Constants.MEETING_LAYOUT)
	{
		rbDiscussion.selected=true;
	}
	else
	{
		rbSimple.selected=true;
	}
}
