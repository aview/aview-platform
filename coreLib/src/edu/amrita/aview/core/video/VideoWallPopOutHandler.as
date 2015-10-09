// ActionScript file
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.video.MeetingVideoWall;
import edu.amrita.aview.core.video.VideoWall;

import flash.events.Event;

import mx.core.FlexGlobals;
import mx.core.UIComponent;

/**Platform specific imports*/
/* For Web:  AIREvent is only available for desktop.*/
applicationType::desktop{
	import mx.events.AIREvent;
}
public var meetingVidWallComp:MeetingVideoWall;
public var isMeetingLayout:Boolean = false;
public var vidWallComp:VideoWall;
private var isInit:Boolean = false;

private function init():void{
	/*if(!isMeetingLayout)
	{
		vidWallComp.percentWidth = 100;				
		vidWallComp.percentHeight = 100;
		vidWall.addChild(vidWallComp);
		vidWallComp.popOutBtn.setStyle("icon",vidWallComp.popinIcon);
		vidWallComp.isPopOut=true;
		vidWallComp.popOutBtn.visible=true;	
	}
	else
	{
		meetingVidWallComp.percentWidth = 100;				
		meetingVidWallComp.percentHeight = 100;
		vidWall.addChild(meetingVidWallComp);
		meetingVidWallComp.popOutBtn.setStyle("icon",meetingVidWallComp.popinIcon);
		meetingVidWallComp.isPopOut=true;
		meetingVidWallComp.popOutBtn.visible=true;	
	}*/
	isInit = true;
}

public function setLayout(layOut:UIComponent):void
{
	vidWall.addChild(layOut);
	layOut.percentWidth = 100;				
	layOut.percentHeight = 100;
}

public function window1_closeHandler(event:Event):void{
	// TODO Auto-generated method stub
	//close() methods is not available for web
/*	applicationType::desktop{
		if(isMeetingLayout)
		{
			// TODO Auto-generated method stub
			if(!this.closed)
			{
				meetingVidWallComp.popOutVideoWallWindow();
			}
			else
			{
				meetingVidWallComp.isPopOut=true;
				meetingVidWallComp.isPopOutClosed = true;
				meetingVidWallComp.popOutVideoWallWindow();
			}
		}
		else
		{
			if(!this.closed)
			{
				vidWallComp.popOutVideoWallWindow();
			}
			else
			{
				vidWallComp.isPopOut=true;
				vidWallComp.isPopOutClosed = true;
				vidWallComp.popOutVideoWallWindow();
			}
		}
	}*/
}

//AIREvent is only available for web
applicationType::desktop{
	public function videoWallMWwindowActivateHandler(event:AIREvent):void{
		if(!isInit)
			return;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multipleWindowActivateHandler("videoWallMW");
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changeToVideoTab();
	}
}
