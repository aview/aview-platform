import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.vo.AViewResponseVO;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.SessionEntry;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.vo.ClassServerVO;
import edu.amrita.aview.core.gclm.vo.LectureListVO;

import flash.external.ExternalInterface;

import mx.collections.*;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;

public var sessionEntry:SessionEntry=null;
private var lectureDetail:LectureListVO=null;
applicationType::mobile{
	[Bindable]
	public var lectureSelectedItem:*;
}
/**
 * For Log API
 */
public function listDoubleClickHandler():void {
	applicationType::DesktopWeb{
		lectureDetail=LectureListVO(dataGrid.selectedItem);
	}
	applicationType::mobile{
		lectureDetail=LectureListVO(lectureSelectedItem);
	}
	if(lectureDetail){
		sessionEntry=new SessionEntry();
		sessionEntry.getClassRoomLecture(lectureDetail.lecture.lectureId);
		sessionEntry.addEventListener(CloseEvent.CLOSE,closeHandler);
	}
}
private function closeHandler(event:CloseEvent):void {
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Homepage.addChild(
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can);
	}
}


