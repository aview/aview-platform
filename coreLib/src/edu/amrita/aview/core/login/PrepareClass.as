import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;

import mx.core.FlexGlobals;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
applicationType::mobile{
	import mx.rpc.http.HTTPService;
}
applicationType::DesktopWeb{
	import mx.rpc.http.mxml.HTTPService;
}
public var Teacher_Info_Box:String;
public var class_info:String;

private var httpServerMonitor:HTTPService;


/**
 * The function calls gettingToClass function and removes
 * lecture notice board canvas from homepage.
 *
 *
 * @return void
 */
// The function calls gettingToClass function and removes 
// lecture notice board canvas from homepage.
public function enterclass():void { 

	getServerTime();
}

public function getServerTime():void { 

	//Earlier this function is used to get server time from the fms
	//using the echoResponder object
	httpServerMonitor=new HTTPService();
	httpServerMonitor.url=encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Whiteboard/serverDate.php?module=main");
	httpServerMonitor.addEventListener(ResultEvent.RESULT, getTimeFromServer);
	httpServerMonitor.addEventListener(FaultEvent.FAULT, faultGetTimeFromServer);
	httpServerMonitor.send();
}

/**
 * Result handler for getting the server time using the http
 * service 'httpServerMonitor'.
 */
public function getTimeFromServer(event:ResultEvent):void { 

	if (Log.isDebug()) 		log.debug("time:" + event.result);
	Teacher_Info_Box=event.result.toString();
	getClassInfo();
}

/**
 * Fault handler for getting the server time using the http
 * service 'httpServerMonitor'.
 */

public function faultGetTimeFromServer(event:FaultEvent):void { 

	////////////////////////////////////////////////////////////////
	//Add a meaningful alert if the user fails to get the 
	//time from the server
	//Update for Bug #200//#5613 ---START		
	MessageBox.show("Wamp server is down." + "\nPlease contact A-VIEW Administrator.", "ERROR", MessageBox.MB_OK, this);
	//Fix for issue #18483
	applicationType::web{
		ClassroomContext.classStartedFlag=false;
	}
	//Update for Bug #200 ---END
	if(Log.isError()) log.error("entry::PrepareClass::faultGetTimeFromServer:"+ AbstractHelper.getStaticFaultMessage(event));
}


// This function displays the class information like
// Course name, Teacher name, date, Topic and Centre
// in multiple window mode.	
public function getClassInfo():void { 

	Teacher_Info_Box=Teacher_Info_Box.substr(0, Teacher_Info_Box.search("GMT"));
	class_info="Course Name: " + ClassroomContext.course.courseName + "\nDate: " + Teacher_Info_Box + "\nLecture Name: " 
		+ ClassroomContext.lecture.lectureName + "\nCentre: " + ClassroomContext.institute.instituteName;
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.gettingToClass();
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.gettingToClass()
	}
}

public function checkStudentBWLimit():void { 

	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.arrBW=Constants.availableVideoPublishingBandwidths;
	}
	applicationType::mobile{
		arrBW=Constants.availableVideoPublishingBandwidths;;
	}
	if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE && ClassroomContext.aviewClass.minPublishingBandwidthKbps != 0 && ClassroomContext.aviewClass.maxPublishingBandwidthKbps != 0) {
		var temp:Array=new Array();
		for (var i:int=0; i < Constants.availableVideoPublishingBandwidths.length; i++) {
			if (Constants.availableVideoPublishingBandwidths[i].index >= ClassroomContext.aviewClass.minPublishingBandwidthKbps && Constants.availableVideoPublishingBandwidths[i].index <= ClassroomContext.aviewClass.maxPublishingBandwidthKbps) {
				temp.push(Constants.availableVideoPublishingBandwidths[i]);
			}
		}
		applicationType::DesktopWeb{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.arrBW=temp;
		}
		applicationType::mobile{
			arrBW=temp;
		}
	}
}
