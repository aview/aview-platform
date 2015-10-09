 package objectResolver
{
	import mx.core.FlexGlobals;
	
	public class DocumentSharingFac
	{
		public function DocumentSharingFac()
		{
		}
		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var auditable = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditableObj();
		public var auditConstants = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditConstantsObj();
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();
		public var closeFileComponentEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getcloseFileComponentEventObj();
		public var contentOperationEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getcontentOperationEventObj();
		public var contentService = FlexGlobals.topLevelApplication.applicationModuleHandler.getcontentServiceObj();
		public var downloadRequestedEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getdownloadRequestedEventObj();
		public var fileManager = FlexGlobals.topLevelApplication.applicationModuleHandler.getfileManagerObj();
		public var messageBox = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxObj();
		public var messageBoxEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxEventObj();
		public var uploadCompletedEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getuploadCompletedEventObj();


/*		
=======================DocumentSharing=======================
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.common.components.fileManager.events.DownloadRequestedEvent;
import edu.amrita.aview.common.components.fileManager.events.UploadCompletedEvent;
import edu.amrita.aview.common.components.fileManager.FileManager;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.service.content.ContentService;
import edu.amrita.aview.common.vo.Auditable;
*/
	
	}
}