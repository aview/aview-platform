package objectResolver
{
	import mx.core.FlexGlobals;

	public class LmsFac
	{
		public function LmsFac()
		{
		}
		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var auditConstants = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditConstantsObj();
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();
		public var aViewDateUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewDateUtilObj();
		public var aViewStringUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewStringUtilObj();
		public var messageBox = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxObj();
		public var messageBoxEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxEventObj();
	}
}
/*
		// ashwini: playback may be core and editing may not be, or the other way around. So keeping all the imports
		// here so as to edit it later.
		//.\playback\AviewPlayer.mxml
		var aviewPlayer = FlexGlobals.topLevelApplication.applicationModuleHandler.getAviewPlayerObj();

		// .\playback\AviewPlayerDesktop.mxml
		var aviewPlayerDesktop = FlexGlobals.topLevelApplication.applicationModuleHandler.getAviewPlayerDesktopObj();

		//.\playback\editing\VideoEditing.mxml
		
		var videoEditing = FlexGlobals.topLevelApplication.applicationModuleHandler.getVideoEditingObj();
=======================LMS=======================
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.util.AViewDateUtil;
import edu.amrita.aview.common.util.AViewStringUtil;
*/		
	
/*
	new ClassRegistrationHelper
	new ArrayCollection
	new ArrayCollection;
	new AviewPlayer
	new AviewPlayerDesktop
	new BrowseLocalFilePath
	new ByteArray
	new Date
	new File
	new FileStream
	new HTTPService
	new LMSadvanceSearch
	new LocalPlayback
	new Object
	new spark.components.Button
	new String
	new TitleWindow
	new URLLoader
	new VideoEditing
	new XML
*/
