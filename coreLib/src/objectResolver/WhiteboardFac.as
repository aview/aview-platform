package objectResolver
{
	public class WhiteboardFac
	{
		import mx.core.FlexGlobals;
		
		public function WhiteboardFac()
		{
		}

		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var auditConstants = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditConstantsObj();
		public var auditContext = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();
		public var customAlert = FlexGlobals.topLevelApplication.applicationModuleHandler.getcustomAlertObj();
		public var messageBox = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxObj();
		public var messageBoxEvent = FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxEventObj();
	}
}



/*
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.components.alert.CustomAlert;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.helper.AbstractHelper;
		//.\playback\oldPlayback\Print2Flash\Point.as
		var point = FlexGlobals.topLevelApplication.applicationModuleHandler.getPointObj();
		new DragGeometry
		new Matrix
		new Point
		new Array
		new ArrayList
		new BitmapData
		new ByteArray
		new ClassFactory
		new Date
		new Dictionary
		new DragGeometry
		new DrawingArea
		new File
		new FileFilter
		new FileReference
		new FileStream
		new Flex4ChildManager
		new Group // flex internal
		new HideComponent
		new HTTPService
		new JPGEncoder
		new Label
		new Matrix
		new MoveableTextArea
		new MovementConstraint
		new Object
		new ObjectHandles
		new ObjectHandlesSelectionManager
		new Point
		new SelectionEvent
		new Shape
		new Shapepoint
		new SizeConstraint
		new Sprite
		new Text
		new TextDataModel
		new Timer
		new UIComponent
		new UITextField
		new URLLoader
		new URLRequest
		new Whiteboard
		new WhiteboardShape
		new WhiteboardShapeSprite		

*/
