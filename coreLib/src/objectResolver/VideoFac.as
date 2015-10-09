package objectResolver
{
//	import edu.amrita.aview.audit.AuditContext;
	import mx.core.FlexGlobals;

	public class VideoFac
	{
		public function VideoFac()
		{
		}
		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var auditConstants = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditConstantsObj();
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();
		public var mediaServerConnection = FlexGlobals.topLevelApplication.applicationModuleHandler.getmediaServerConnectionObj();
		public var mediaServerStatusEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmediaServerStatusEventObj();
		public var videoConnection = FlexGlobals.topLevelApplication.applicationModuleHandler.getvideoConnectionObj();
	}
}

/*
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.streaming.VideoConnection;
		// .\audit\AuditContext.as
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getAuditContextObj();
		// .\biometric\SnapshotComponent.mxml
		public var snapshotComponent = FlexGlobals.topLevelApplication.applicationModuleHandler.getSnapshotComponentObj();
		// .\common\service\streaming\VideoConnection.as
		public var videoConnection = FlexGlobals.topLevelApplication.applicationModuleHandler.getVideoConnectionObj();
		// .\common\service\streaming\VideoConnectionData.as
		public var videoConnectionData = FlexGlobals.topLevelApplication.applicationModuleHandler.getVideoConnectionDataObj();
new Array
new ArrayCollection
new ArrayList
new DragSource
new flash.media.Video
new Image
new LocalConnection
new MeetingVideoWall
new NetConnection
new NetStream
new Object
new Rectangle
new SoundTransform
new VideoWall
new Array
new ArrayCollection
new AVParameters
new Date
new File
new FileStream
new H264VideoStreamSettings
new HTTPService
new Image
new List
new LocalVideo
new LocalVideoDisplay
new LocalVideoFullscreen
new MediaServerConnection
new mx.controls.Button
new NativeProcess
new NativeProcessStartupInfo
new NetStream
new Object
new Rectangle
new setting;
new SnapshotComponent
new Socket
new spark.components.Button
new StreamSignalDisplay
new SWFLoader
new Timer
new Vector.<String>
new Video
new VideoConnection
new VideoConnectionData
new VideoDisplay
new VideoStreamDisplay
new VideoStreamDisplayFullScreen
new VideoStreamSettings
new VideoTileEvent
new VideoWallPopOut
 
*/