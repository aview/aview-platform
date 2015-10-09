 package objectResolver
{
	import mx.core.FlexGlobals;
	
	public class GCLMFac
	{
		public function GCLMFac()
		{
		}
        //SMCR: no need of all these files
		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var arrayCollectionUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getarrayCollectionUtilObj();
		public var auditable = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditableObj();
		public var auditConstants = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditConstantsObj();
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();
		public var aViewDateUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewDateUtilObj();
		public var aViewResponseVO = FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewResponseVOObj();
		public var aViewStringUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewStringUtilObj();
		public var customAlert = FlexGlobals.topLevelApplication.applicationModuleHandler.getcustomAlertObj();
		public var messageBox = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxObj();
		public var messageBoxEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxEventObj();
		public var statusVO = FlexGlobals.topLevelApplication.applicationModuleHandler.getstatusVOObj();
		public var systemParameterHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getsystemParameterHelperObj();
		public var systemParameterVO = FlexGlobals.topLevelApplication.applicationModuleHandler.getsystemParameterVOObj();
	}
}

/*
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.components.alert.CustomAlert;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.helper.SystemParameterHelper;
import edu.amrita.aview.common.util.ArrayCollectionUtil;
import edu.amrita.aview.common.util.AViewDateUtil;
import edu.amrita.aview.common.util.AViewStringUtil;
import edu.amrita.aview.common.vo.Auditable;
import edu.amrita.aview.common.vo.AViewResponseVO;
import edu.amrita.aview.common.vo.StatusVO;
import edu.amrita.aview.common.vo.SystemParameterVO;

		//.\meeting\MeetingManager.as
		var meetingManager = FlexGlobals.topLevelApplication.applicationModuleHandler.getMeetingManagerObj();
//		.\audit\vo\AuditLectureVO.as
		var lectureVO = FlexGlobals.topLevelApplication.applicationModuleHandler.getLectureVOObj();
		
		new ClassFactory
		new Object
		new SystemParameterHelper
		new ArrayCollection;
		new ChangePasswordComp
		new ChannelSet
		new ClassComp
		new ClassFactory
		new ClassRegisterVO
		new ClassRegistrationApprovalComp
		new ClassRegistrationComp
		new Consumer
		new CourseComp
		new CourseVO
		new CreateInstituteAdminsComp
		new CreateInstituteBranding
		new CreateInstituteServersComp
		new CreateMeetingServersComp
		new Date;
		new Dictionary
		new InstituteAdminUserVO
		new InstituteApprovalComp
		new InstituteComp
		new LectureComp
		new LectureVO
		new MeetingManager
		new Sort
		new SortField
		new StaticDataHelper
		new UserApprovalComp
		new UserComp;
		new UserHelper
*/		
