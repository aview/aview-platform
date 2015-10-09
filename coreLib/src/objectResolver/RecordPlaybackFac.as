package objectResolver
{
	import mx.core.FlexGlobals;
	public class RecordPlaybackFac
	{
		public function RecordPlaybackFac()
		{
		}
		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();
		public var deleteZipFromServers = FlexGlobals.topLevelApplication.applicationModuleHandler.getdeleteZipFromServersObj();
		public var fileLoadedEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getfileLoadedEventObj();
		public var fileLoaderManager = FlexGlobals.topLevelApplication.applicationModuleHandler.getfileLoaderManagerObj();
		public var mediaServerConnection = FlexGlobals.topLevelApplication.applicationModuleHandler.getmediaServerConnectionObj();
		public var mediaServerStatusEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmediaServerStatusEventObj();
		public var messageBox = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxObj();
		public var messageBoxEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxEventObj();
	}
}




/*
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.components.fileloader.events.FileLoadedEvent;
import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.util.DeleteZipFromServers;


		// .\common\components\fileloader\FileLoaderManager.as
		var fileLoaderManager = FlexGlobals.topLevelApplication.applicationModuleHandler.getFileLoaderManagerObj();
		new Array
		new ChatRecorder
		new Date
		new DocumentRecorder
		new File
		new FileLoaderManager
		new FileStream
		new HTTPService
		new Object
		new PointerRecorder
		new PushToTalkRecorder
		new RecordingStatus
		new Timer
		new VideoRecorder
		new WhiteBoardRecorder
*/		
