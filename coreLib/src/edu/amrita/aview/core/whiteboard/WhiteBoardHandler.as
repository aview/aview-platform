import com.adobe.images.JPGEncoder;
import com.adobe.serialization.json.JSON;
import com.amrita.edu.collaboration.AutoPropertyName;
import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.whiteboard.DrawingArea;
import edu.amrita.aview.core.whiteboard.HideComponent;
import edu.amrita.aview.core.whiteboard.Shapepoint;
import edu.amrita.aview.core.whiteboard.WhiteboardShape;
import edu.amrita.aview.core.whiteboard.WhiteboardShapeSprite;
applicationType::mobile{
	import edu.amrita.aview.core.whiteboard.mobileTools.MobileTextToolComponent;
}
applicationType::DesktopWeb{
	import edu.amrita.aview.core.whiteboard.objectHandle.HandleDescription;
	import edu.amrita.aview.core.whiteboard.objectHandle.HandleRoles;
	import edu.amrita.aview.core.whiteboard.objectHandle.MoveableTextArea;
	import edu.amrita.aview.core.whiteboard.objectHandle.ObjectChangedEvent;
	import edu.amrita.aview.core.whiteboard.objectHandle.ObjectHandles;
	import edu.amrita.aview.core.whiteboard.objectHandle.SpriteHandle;
	import edu.amrita.aview.core.whiteboard.objectHandle.TextDataModel;
	import edu.amrita.aview.core.whiteboard.objectHandle.constraints.MovementConstraint;
	import edu.amrita.aview.core.whiteboard.objectHandle.constraints.SizeConstraint;
}
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import mx.collections.ArrayList;
applicationType::DesktopWeb{
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.controls.Text;
}
import mx.core.FlexGlobals;
import mx.core.UITextField;
import mx.events.ColorPickerEvent;
import mx.events.FlexEvent;
import mx.events.MenuEvent;
import mx.events.ResizeEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

import spark.components.Group;
applicationType::mobile{
	import spark.components.Label;
}
import spark.components.NumericStepper;
import spark.components.RichEditableText;
import edu.amrita.aview.core.shared.events.mobileCustomEvents.WhiteBoardActionEvent;
import spark.events.PopUpEvent;
import edu.amrita.aview.core.whiteboard.mobileTools.DynamicTextArea;
import flash.utils.getTimer;
import edu.amrita.aview.core.userPreference.ConfigFileReader;
import edu.amrita.aview.core.whiteboard.drawing_object.Pencil;
import edu.amrita.aview.core.whiteboard.drawing_object.Eraser;
import edu.amrita.aview.core.whiteboard.GarbageCollection;
import mx.core.UIComponent;
import mx.utils.StringUtil;
import edu.amrita.aview.core.playback.events.ClickEvent;
import edu.amrita.aview.core.whiteboard.WhiteboardComp;
import edu.amrita.aview.core.login.boilerplate.Strings;

/**Platform specific imports*/
applicationType::desktop{
	import flash.display.NativeWindowDisplayState;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import edu.amrita.aview.core.whiteboard.Whiteboard;
}

/**
 * Array list which contains the collaboration mode values and labels.
 * Labels from this list is showing when presenter open the collaboration
 * list menu.
 *
 */
applicationType::DesktopWeb{
	private const ALL_COLLABORATION_MODES:ArrayList=new ArrayList([{label: ResourceManager.getInstance().getString('myResource', 'whiteboardhandleras.selectedviewerlabel'), data: Constants.CM_SELECTED_STUDENT_CAN_WRITE}, {label: ResourceManager.getInstance().getString('myResource', 'whiteboardhandleras.allviewerslabel'), data: Constants.CM_ALL_STUDENT_CAN_WRITE}, {label: ResourceManager.getInstance().getString('myResource', 'whiteboardhandleras.noviewerslabel'), data: Constants.CM_NO_STUDENT_CAN_WRITE}, {label: ResourceManager.getInstance().getString('myResource', 'whiteboardhandleras.hidewhiteboardlabel'), data: Constants.CM_HIDE_WHITEBOARD}]);
}
applicationType::mobile{
	private const ALL_COLLABORATION_MODES:ArrayList =new ArrayList([{label:"Selected Viewer", data:Constants.CM_SELECTED_STUDENT_CAN_WRITE},{label:"All Viewers", data:Constants.CM_ALL_STUDENT_CAN_WRITE},{label:"No Viewer", data:Constants.CM_NO_STUDENT_CAN_WRITE},{label:"Hide Whiteboard", data:Constants.CM_HIDE_WHITEBOARD}]);
}

/**
 * Array list which contains the collaboration mode values and labels which are
 * assigned to collaboration list menu when presenter select hide whiteboard
 * collaboration mode.
 */
private const UNHIDE_COLLABORATION_MODE:ArrayList=new ArrayList([{label:"Hide Whiteboard", data:Constants.CM_HIDE_WHITEBOARD},{label: "Unhide Whiteboard", data: Constants.CM_UNHIDE_WHITEBOARD}]);

/**
 * The xml declaration statement for the whiteboard recording xml.
 */
private const INITIAL_SHAPE_XML:String="<?xml version=\"1.0\" encoding=\"utf-8\"?>" + "\n";

/**
 * Menu item label for whiteboard context menu
 * 
 */
public var  toolSelect:String="";
public var lastFontSize:Number = 12;
private const exportPageContextMenuItemLabel:String="Export Page";
/**
 * Menu item label for whiteboard context menu
 */
private const importPageContextMenuItemLabel:String="Import Page";
/**
 * Menu item label for whiteboard context menu
 */
private const exportImageContextMenuItemLabel:String="Export as Image";
/**
 * Menu item label for whiteboard context menu
 */
private const importImageContextMenuItemLabel:String="Import Image";
/**
 * Menu item label for whiteboard context menu
 */
private const showCollaboratorContexttMenuItemLabel:String="Show Collaborators";
//PNCR: //#BugFix: 14630. Enable presenter control button when user get presenter control.
/**
 * Flag to check whether the user has presenter control after collaboration mode set
 */
private var isCollaborationModePresenter:Boolean = false;
applicationType::DesktopWeb{
	/**
	 * Dataprovider for whiteboard context menu
	 */
	[Bindable]
	public var rightClickMenuDp:Array=[{label: exportPageContextMenuItemLabel, enabled: true}, {label: importPageContextMenuItemLabel, enabled: true}, {label: exportImageContextMenuItemLabel, enabled: true},  {label: showCollaboratorContexttMenuItemLabel, type: "check", toggled: false, enabled: true}, {label: pasteContexttMenuItemLabel, enabled: false}];
}

private var garbageCollection:GarbageCollection = new GarbageCollection();

//PNCR: #BugFix: 14615. removed "Import image" button from the right click options.
//{label: importImageContextMenuItemLabel, enabled: false},
/**
 * This var stores the current tool name. By default it is fh(means free hand )
 * @default fh
 */
public var toolName:String="fh";

/**
 * Variable hold the status message of netConnection object.
 */
public var netConnectionStatus:String="";

/**
 *  Object of DrawingArea component. DrawingArea is a component based
 * on UiComponemnt . All drawing sprites are added to this object
 */
public var drawingArea:DrawingArea=new DrawingArea();

/**
 * This var maintains the current page number
 * @default 1
 */
[Bindable]
public var pageNumber:int=1;
applicationType::DesktopWeb{
	/**
	 * Boolean variable which set to true while recording the
	 * existing whiteboard content when moderator starts recording of the class.
	 */
	public var recordedExistingContent:Boolean=false
	/**
	 * The whiteboard custom context menu.
	 */
	private var rightClickMenu:Menu;
	/**
	 * This is used to show the handle for selecting/moving/resizing
	 * textArea in Whiteboard.
	 */
	private var objectHandleForTextArea:ObjectHandles;
	/**
	 * This is used to show the handle for selecting/moving/resizing
	 * textArea in Whiteboard.
	 */
	private var objectHandleForShape:ObjectHandles;
	
	/**
	 * This array is used to store the handle information like type, position etc  for objectHandleForTextArea.
	 */
	private var handlesForTextArea:Array=[];
	
	/**
	 * This array is used to store the handle information like type, position etc  for objectHandleForShape.
	 */
	private var handlesForShapes:Array=[];
	/**
	 * This variable is holding the text for a currently selected
	 * teaxtArea
	 */
	[Bindable]
	private var dataModelForTextArea:TextDataModel;

	/**
	 * Custom textArea object which used to applay object handles.
	 * When it lose its focus , it removed from the whiteboard and replaced with
	 * normal spark textArea object.
	 */
	private var movableTextArea:MoveableTextArea;
}
/**
 * Icon used for pop-out function
 */
[Bindable]
[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/view-fullscreen1.png")]
private var popoutIcon:Class;

/**
 * Icon used  for pop-in function
 */
[Bindable]
[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/windows_nofullscreen.png")]
private var popinIcon:Class;

/**
 * Icon used for show pointer function.
 */
[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/showPointer_new.png")]
[Bindable]
private var showPointerIcon:Class;

/**
 * Icon used for remove pointer function.
 */
[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/showPointer_newselected.png")]
[Bindable]
private var removePointerIcon:Class;

/**
 * //PNCR: #BugFix: 14762
 * Images to enable or disable Text tool
 */
[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/textTool_newselected.png")]
[Bindable]
private var disableTextToolEnableSizeSelectionImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/textTool_new.png")]
[Bindable]
private var enableTextToolImage:Class;

/**
 * //PNCR: #BugFix: 14762
 * Images to enable or disable erase tool
 */
/*[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/eraserSelected.png")]
[Bindable]
private var disableEraseToolEnableSizeSelectionImage:Class;*/

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/erasersmallSelected_new.png")]
[Bindable]
private var SmallEraserSelectionImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/mediumEraserSelected_new.png")]
[Bindable]
private var MediumEraserSelectionImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/LargeEraserSelected_new.png")]
[Bindable]
private var LargeEraserSelectionImage:Class;


[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/RectangleSelected_new.png")]
[Bindable]
private var RectangleSelectionImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/circleSelected_new.png")]
[Bindable]
private var CircleSelectionImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/lineSelected_new.png")]
[Bindable]
private var LineSelectionImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/Eraser_new.png")]
[Bindable]
private var EraseToolImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/Shapes.png")]
[Bindable]
private var ShapeToolImage:Class;

[Embed(source="/edu/amrita/aview/core/whiteboard/assets/images/defaultShape.png")]
[Bindable]
private var ShapeDefault:Class;
/**
 * Icon class which hold the icon for current pointer
 * status.
 */
[Bindable]
private var pointerIcon:Class=removePointerIcon;

/**
 * This sprite object is used for intial drawing by the user who draws the object.
 */
private var userDrawingSprite:WhiteboardShapeSprite;

/**
 * This variable value decides the background color of the whiteboard.
 * By default the value is made a white.
 * This is value is not changed in application since the use of eraser can cause issues
 * @default 0xffffff
 */
private var backgroundColor:Number=0xffffff;

/**
 * This var decides the line thickness of the drawing shapes.By default it is 3 as per the suggestion from IIT-B.
 * @default 3
 */
private var lineThickness:Number=3;

/**
 * This var decides the line color of the drawing shapes. By default it is black.
 * @default 0x000000
 */
private var lineColor:String="0x000000";

/**
 * This var decides the line alpha of the drawing objects. By default it is 1
 * @default 1
 */
private var lineAlpha:Number=1;

/**
 * This var stores the intial mouse x valuse of one particular  shape when we start drawing it.
 */
private var startX:Number;

/**
 * This var stores the intial mouse y valuse of one particular  shape when we start drawing it.
 */
private var startY:Number;

/**
 * This var stores the current mouse x value while drawing
 */
private var xPos:Number;

/**
 * This var stores the current mouse y value while drawing
 */
private var yPos:Number;


/**
 * A mask is to create a hole through which the contents of another
 *  display object are visible. This Sprite object is used set the borders of the
 *  whiteboard.
 */
private var whiteboardMask:Group;

/**
 * Sacle factor for x values for a shape. It is the ratio taken based on the current
 * width with the width of the UI comp during drawing.
 * @default 0.0000000000000
 * */
private var scaleFactorX:Number=0.0000000000000;

/**
 * Sacle factor for y values for a shape. It is the ratio taken based on the current height with the height of the UI comp during drawing
 * @default 0.0000000000000
 */
private var scaleFactorY:Number=0.0000000000000;

/**
 * This var is to keep track of total number of pages  of a Whiteboard file
 */
[Bindable]
private var totalPages:int=1;

/**
 * This variable keeps track of the drawing permission set by the teacher.
 * SelectedStudentOnly = only selected student has the permission to draw.
 * NoStudent = No students user have the permission to draw
 */
//TODO: This variable will take value from the user preference in future 
private var collaborationMode:String="";

/**
 * This is an associative array which stores the file objects, filestream
 * objects for accessing the files corresponding to each page.
 */
private var fileDetailsForCaching:Array=null;

/**
 * This flag is used to determine the current page is updated or not
 */
private var pageUpdated:Boolean=false;
/**
 * Bug #18514. Created a array of flags. instead of a single page update flag. 
 * So before pagesave it will check whether that particular page has to be saved or not. 
 */
private var isPageUpdated:Object = new Object();
/**
 * This label is used to show a waiting message when navigate to a new page
 */
private var labelMessageWhileNavigation:Label=new Label();

/**
 * This variable keeps track the folder path of the xml files to be saved.
 */
private var localFilePath:String="";

/**
 * A shape object that is used as the pointer
 */
private var pointerShape:Shape=null;

/**
 * The current x position of the pointer shape
 */
private var pointerShapeX:Number=0;
/**
 * The current y position of the pointer
 */
private var pointerShapeY:Number=0;
/**
 * The width of the drawing area before rezise occurs.
 */
private var drawingAreaWidthBeforResize:Number=1;
/**
 * The height of the drawing area  before rezise occurs.
 */
private var drawingAreaHeightBeforResize:Number=1;

/**
 * The varible to keep track of whether a Text component is in editable mode
 */
private var textAreaEditable:Boolean=false;

/**
 * Timer for saving the whiteboard in 1 minute interval
 */
private var autoSaveTimerForPage:Timer=new Timer(60000, 0);

/**
 * Data provider for collaboration list. Its keep bindable because when
 * the presenter select hide option all othe option removed dynamically
 */
[Bindable]
private var collaborationListDataProvider:ArrayList=new ArrayList();

/**
 * This variable holds the current shape information when user draws a particular shape
 */
private var whiteboardShape:WhiteboardShape;

/**
 * This array holds all the shapes for the current page.
 */
private var whiteboardShapeArray:Array=new Array();

/**
 * Collaboration object used to control the collaboration mode
 */
private var collaborationModeCollaborationObject:CollaborationObject;
/**
 * Collaboration object used for navigation between pages
 */
private var navigationCollaborationObject:CollaborationObject;

/**
 * Collaboration object used for undo and redo
 */
private var undoRedoCollaborationObject:CollaborationObject;

/**
 * Collaboration Object used to collaborate whiteboard drawing
 */
private var shapeCollaborationObject:CollaborationObject;

/**
 * Collaboration Object used to collaborate the shape selection and manipulation.
 */
private var shapeSelectionCollaborationObject:CollaborationObject;

/**
 * Collaboration Object used to collaborate the pointer sharing.
 */
private var pointerCollaborationObject:CollaborationObject;

/**
 * Name of the whiteboard caching directory.This directory resided in the
 * application storage directory.
 */
private var cacheDirectoryName:String;

/**
 * Logger class variable. This is used to log the activities in whiteboard
 */
private var logger:ILogger=Log.getLogger("aview.edu.amrita.aview.core.whiteboard.WhiteboardComp");

/**
 * This variable is set in the creation complete event of
 * this whiteboard componnent.
 */
private var isWbInitialized:Boolean=false;

/**
 * This variable holds the number of the page we need to save
 * while navigating between pages.If we navigating from page 3 to
 * 5, the value of this variable will be 3.
 */
private var pageToSave:int

/**
 * This holds the folder path for a page in the content server.
 */
private var remoteFolderPath:String=null;

/**
 * The URLRequest object for uploading a page.
 */
private var fileUploadUrlRequest:URLRequest=null;

/**
 * This holds the content server ip for the whiteboard.
 */
private var contentServer:String=null;

/**
 * This component is used to hide the viewer whiteboards when
 * presenter hides the whiteboard
 */
private var hideWbCanvas:HideComponent;

/**
 * Label for showing message when presenter hides the whiteboard
 */
private var hideWbMessagelabel:Label

/**
 * The width of the drawing area container  before rezise occurs.
 */
private var previousBaseContainerWidth:Number=0;

/**
 * The height of the drawing area container before rezise occurs.
 */
private var previousBaseContainerHeight:Number=0;

/**
 * Hold the collaboration mode when teacher hides the whiteboard.
 */
private var collaborationStatusBeforeHideMode:String

/**
 * The width of the drawing area where the shape is drawn.
 */
private var drawingAreaWidthForShape:uint=0;
/**
 * The height of the drawing area where the shape is drawn.
 */
private var drawingAreaHeightForShape:uint=0;

/**
 * The size of the eraser.
 */
private var eraserThichness:uint=8;
/**
 * Timer used to invoke 'drawFreeHandPreview' function at every particular interval
 */
private var drawingPreviewTimer:Timer;
/**
 *  This array stores the set of points in 100 milliseconds to draw the preview
 */
private var previewShapePointsArray:Array;

/**
 * The reference for the setTimeout when connectWhiteboardCollabObjects function
 * is called from the core/main module before the whiteboard get initiallized.
 */
private var connectCollabObjtsSetTimeOutId:uint;

/**
 * Set to true when whiteboard component is initialized and the shared objects
 * are created.
 */
private var isCollabObjectCreated:Boolean=false;
/**
 * A flag to indicate to execute some code only once.
 */
private var runOnce:Boolean=false;

/**
 * The reference for the setTimeout when setupWhiteboardOnConnection function
 * is called from the core/main module before the whiteboard get initiallized.
 */
private var connectionSetTimeOutId:uint;

/**
 * The reference for the setTimeout when updateWbControls function
 * is called from the core/main module before the whiteboard get initiallized.
 */
private var updateControlSetTimeOutId:uint;

/**
 * This varible is used to run certion code blocks only for login
 * and not for every re-connection
 */
private var isLogin:Boolean=false;

/**
 * When user enter values in  any of the numeric steppers(eg: page number,
 * line thickness etc) we are calling some validation function
 * after some time. This variable keeps the id of the corrresponding
 * setTimeout function.
 */
private var validationSetTimeOutId:uint
/**
 * The setTimeout id for the pasteText() when it calls through
 * keyboard short cut.
 */
private var pasteSetTimeOutId:uint;

private var navigationInfoStoreTimeOutId:uint;

/**
 * The HTTPService object for creating the server side folder  ofor the lecture.
 */
private var createServerSideFolderService:HTTPService;

/**
 * Suffix added to the end of the collaboration name for linking
 * the collaboration name and the whiteboard page.
 */
private var sharedObjectSuffix:String="Page1";

/**
 * This variable keep tracks the shape id of the latest drawn shape.
 */
private var currentShapeId:uint=1;
/**
 * The clear interval id for waitForShapeCollaborationObjectConnect function
 */
private var waitForShapeCollaborationObjectConnectIntervalId:uint

/**
 * Holds the text content of the selected text box.
 */
private var textContentWhenSelected:String
/**
 * Store the tool name when user select a text box. This is for restoring
 * the previous tool after the user done with the currently selected text box.
 */
private var previousTool:String="";

/**
 * Set true when presenter select show collaborator option.
 */
public var showCollaborator:Boolean=false;

/**
 * Holds the array of shpaes from an imported page.
 */
private var shapeArrayFromImportedPage:Array
/**
 * Reference to the Alert message shown while preview the shapes of an
 * imported page.
 */
private var previewAlert:MessageBox=null;

/**
 * This flag is set to true for indicating that the clear function
 * is invoked as part of importing the external page.
 */
private var clearWhenImporting:Boolean=false;

/**
 * Declared as an private instance because to close the loader before creating new.
 */
private var pageLoader:URLLoader;

/********* Drawing objects ************/
//Pencil object to draw free hand drawings.
private var pencil:Pencil = new Pencil();
//Eraser object to erase the existing drawings.
private var eraser:Eraser = new Eraser();

[Bindable]
public var toolBoxEraserMenuOpened:Boolean;
private var menuEraserOpenTimout:uint;
[Bindable]
public var toolBoxShapeMenuOpened:Boolean;
private var menuShapeOpenTimout:uint;
/**Platform specific variables*/
applicationType::desktop{
	private const pasteContexttMenuItemLabel:String="Paste";
	
	/**
	 * Whiteboard pop out window. 
	 * call activate() to enable popout whiteboard.
	 */
	public var whiteBoardFullWndw:Whiteboard;
}

applicationType::web{
	/*Changed label of Paste item since we cannot access paste functionality via flex api in web.*/
	private const pasteContexttMenuItemLabel:String="Use Ctrl+V to paste text";
	
	private var textW:Number;
	private var textH:Number;
	private var maxAvailableWidth:Number;
	private var maxAvailableHeight:Number;
	/*File is not available for web. So we changed File to FileReference. */
	private var fileReference:FileReference;
	/*To hold remote folder path. */
	private var fileUploadUrl:String=null;
	//Fix for issues #17614 and #17585
	//To store whiteboard page details to Local Shared Object
	private var pageDetailsSharedObject:SharedObject;
}
applicationType::mobile{
	//Added to check whether eraser button is enabled.
	private var isEraserButtonEnabled:Boolean = true;
	public var isMousePointerEnabled:Boolean = true;
	private var collaboratorObject:Object;
	private var collaboratorPosition:Dictionary = new Dictionary();
	private var isCallFromDraShapes:Boolean = false;
	public var isPasteActive:Boolean = false;
	public var textComp:MobileTextToolComponent;
	public var isSoftKeyboardActivate:Boolean = false;
	private var collaborationSelectedIndex:int = 0;
	private var wbShapeObject:Object = new Object;
	//The varible to keep track of whether a Text component is in editable status in presenter side.
	public var txtAreaEdit:Boolean=false;
	
	[Embed(source="assets/mobile/show_pointer.png")]
	[Bindable]
	public var showMobilePointerIcon:Class;  
	
	[Embed(source="assets/mobile/removepointer.png")]
	[Bindable]
	public var removeMobilePointerIcon:Class;  
}
//Fix for issue #20017
public var uploadedPageNumber:int;


/**
 * This is the intialize function for the Whiteboard Component.
 * It intializes and sets the default values.
 */
private function init():void{
	if (Log.isInfo())		logger.info(" Entered function init");
	try{
		var fileNameDate:Date=new Date();
		cacheDirectoryName="" + fileNameDate.getDate() + (fileNameDate.getMonth() + 1) + fileNameDate.getFullYear();
		localFilePath="/WhiteBoard/" + cacheDirectoryName + "/" + ClassroomContext.lecture.lectureName + "/";
		fileDetailsForCaching=new Array();
		updateCollaborationStatus(Constants.CM_SELECTED_STUDENT_CAN_WRITE);
		hideWbMessagelabel=new Label();
		hideWbMessagelabel.text="Whiteboard has been hidden by the presenter";
		remoteFolderPath="/AVContent/Whiteboard//" + ClassroomContext.institute.instituteId + "//" + ClassroomContext.course.courseId + "//" + ClassroomContext.aviewClass.classId + "//" + ClassroomContext.lecture.lectureId;
		fileUploadUrlRequest=new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Common/upload.php?folderPath=" + remoteFolderPath));
		
		resetInMemoryShapes();
		toolName="fh";
		applicationType::DesktopWeb{
			lineThicknessStepper.value=3;
			//Change #16400
			presenterControls.visible=false;
			toolBoxContainer.visible=false;
			if (whiteboardBaseCanvas.contains(eraserOptionBox)){
				whiteboardBaseCanvas.removeElement(eraserOptionBox);
			}
			if (whiteboardBaseCanvas.contains(textToolOptionBox)){
				whiteboardBaseCanvas.removeElement(textToolOptionBox);
			}
		}
		applicationType::mobile{
			FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.enabled=false;
			FlexGlobals.topLevelApplication.whiteBoardTools.btnCollaboration.enabled=false;
			FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=false;
			FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=false;
			//To disable the whiteboard menu button
			FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = false;
			//Add event listeners for white board tools
			FlexGlobals.topLevelApplication.whiteBoardTools.addEventListener(WhiteBoardActionEvent.WHITE_BOARD_ACTION,selectWBTools);
		}
		isWbInitialized=true;
		isLogin=true;
		applicationType::DesktopWeb{
			createObjectHandle();
			if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
				popOutBtn.setStyle("icon", popoutIcon);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveModule(false);
			}
		}
		applicationType::mobile{
			FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon = removeMobilePointerIcon;
		}
		contentServer=ClassroomContext.CONTENT_WHITEBOARD;
	}
	catch (Err:Error){
		if (Log.isInfo()) logger.info("Error in init" + Err.getStackTrace()+" - "+Err.message);
	}
	if (Log.isInfo())		logger.info("init : contentServer = "+contentServer+", ClassroomContext.CONTENT_WHITEBOARD = "+ClassroomContext.CONTENT_WHITEBOARD);
}

/**
 * This function is used for validating the values entered in page number
 * numeric stepper and line thickness numeric stepper.
 */
//TODo: Include the font size numeric stepper also.
private function validatNumericStepperAfterDelay(numericStepper:NumericStepper):void{
	clearTimeout(validationSetTimeOutId);
	if (numericStepper.textDisplay.text == "" || numericStepper.textDisplay.text == "-"){
		return;
	}
	var stepperValue:Number=parseFloat(numericStepper.textDisplay.text);
	//PNCR: can use the conditions in a single if and condition.
	if (stepperValue > numericStepper.maximum){
		if (numericStepper.id == "currentPageNumericStepper"){
			numericStepper.textDisplay.text=pageNumber.toString();
			//MessageBox.show("Page number is not valid. Please enter a valid page number","WARNING",0);
		}
		else if (numericStepper.id == "lineThicknessStepper"){
			numericStepper.textDisplay.text=lineThickness.toString();
			//MessageBox.show("The maximum value for line thickness is 10","WARNING",0);
		}
		
		
	}
		//The condition 
		//numericStepper.textDisplay.text.length != numericStepper.textDisplay.text.match(/[0-9]*/)[0].length)
		//is for ensuring that there is no succeeding  minus(-) sign is enterred.
	else if (stepperValue < numericStepper.minimum || isNaN(stepperValue) || numericStepper.textDisplay.text.length != numericStepper.textDisplay.text.match(/[0-9]*/)[0].length){
		
		if (numericStepper.id == "currentPageNumericStepper"){
			numericStepper.textDisplay.text=pageNumber.toString();
			//MessageBox.show("Page number is not valid. Please enter a valid page number","WARNING",0);
		}
		else if (numericStepper.id == "lineThicknessStepper"){
			numericStepper.textDisplay.text=lineThickness.toString();
			//MessageBox.show("Line thickness is not valid. Please enter a valid value","WARNING",0);
		}
		
	}
	Mouse.cursor=MouseCursor.ARROW;
	
}

/**
 * Key-up event handler for page number numeric stepper and
 * Line thickness numeric stepper
 */
private function validatNumericStepper(numericStepper:NumericStepper):void{
	validationSetTimeOutId=setTimeout(validatNumericStepperAfterDelay, 100, numericStepper)
	
}
applicationType::DesktopWeb{
	/**
	 * Initializes the object handles for text tool and shapes.
	 */
	private function createObjectHandle():void{
		if (Log.isInfo())		logger.info(" Entered function createObjectHandle");
		objectHandleForTextArea=new ObjectHandles(wbCanvas);
		objectHandleForShape=new ObjectHandles(wbCanvas);
		handlesForTextArea.push(new HandleDescription(HandleRoles.RESIZE_UP, new Point(50, 0), new Point(0, 0)));
		handlesForTextArea.push(new HandleDescription(HandleRoles.RESIZE_RIGHT, new Point(100, 50), new Point(0, 0)));
		handlesForTextArea.push(new HandleDescription(HandleRoles.RESIZE_DOWN, new Point(50, 100), new Point(0, 0)));
		handlesForTextArea.push(new HandleDescription(HandleRoles.RESIZE_LEFT, new Point(0, 50), new Point(0, 0)));
		handlesForTextArea.push(new HandleDescription(HandleRoles.MOVE, new Point(50, 50), new Point(0, 0)));
		
		dataModelForTextArea=new TextDataModel();
		addObjectHandleConstraints(objectHandleForTextArea);
		
		handlesForShapes.push(new HandleDescription(HandleRoles.MOVE, new Point(0, 0), new Point(0, 0)));
		handlesForShapes.push(new HandleDescription(HandleRoles.MOVE, new Point(100, 0), new Point(0, 0)));
		handlesForShapes.push(new HandleDescription(HandleRoles.MOVE, new Point(0, 100), new Point(0, 0)));
		handlesForShapes.push(new HandleDescription(HandleRoles.MOVE, new Point(100, 100), new Point(0, 0)));
		handlesForShapes.push(new HandleDescription(HandleRoles.MOVE, new Point(50, 50), new Point(0, 0)));
		
		addObjectHandleConstraints(objectHandleForShape);
	}
	
	/**
	 * Adding the size and movemnet constraints for the object handle.
	 * The movement constraint restricts the object handle to go beyond
	 * the drawing area.
	 */
	private function addObjectHandleConstraints(objHandle:ObjectHandles):void{
		objHandle.clearOldConstraints();
		if (objHandle != objectHandleForShape){
			var constraint:SizeConstraint=new SizeConstraint();
			constraint.minWidth=30;
			//constraint.maxWidth = 200;
			constraint.minHeight=30;
			//constraint.maxHeight = 200;
			objHandle.addDefaultConstraint(constraint);
		}
		
		var constraint2:MovementConstraint=new MovementConstraint();
		constraint2.minX=5;
		constraint2.minY=5;
		constraint2.maxX=wbCanvas.width - 5;
		constraint2.maxY=wbCanvas.height - 5;
		objHandle.addDefaultConstraint(constraint2);
	}
}

/**
 * Removes the eraser tool's  option menu and/or text tool's option menu
 * from the drawing area.
 */
private function removeToolOptions(event:MouseEvent):void{
	applicationType::DesktopWeb{
		
		if (event.currentTarget != btnEraser){
			//whiteboardBaseCanvas.removeElement(eraserOptionBox);
			eraserOptionBox.visible=false;
		}
	/*	if (whiteboardBaseCanvas.contains(textToolOptionBox) && event.currentTarget != btnTextTool){
			whiteboardBaseCanvas.removeElement(textToolOptionBox);
		}*/
	}
}
private function showHideEraserMenu():void
{
	applicationType::DesktopWeb{
		//btnShapes.setStyle("imageSkin",ShapeDefault);
		//btnTextTool.setStyle("imageSkin",enableTextToolImage);
		if(eraserOptionBox.visible==true)
		{
			eraserOptionBox.visible = false;
			toolBoxEraserMenuOpened=false;
		}
		else
		{
			eraserOptionBox.visible = true;
			menuEraserOpenTimout=setTimeout(setFlagValueforEraserMenu, 100);
		}
}
}
private function showHideShapeMenu():void
{
		applicationType::DesktopWeb{
			//btnEraser.setStyle("imageSkin",EraseToolImage);
			//btnTextTool.setStyle("imageSkin",enableTextToolImage);
			if(shapesOptionBox.visible==true)
			{
				shapesOptionBox.visible = false;
				toolBoxShapeMenuOpened=false;
			}
			else
			{
				shapesOptionBox.visible = true;
				menuShapeOpenTimout=setTimeout(setFlagValueforShapeMenu, 100);
			}
}
}

private function setFlagValueforEraserMenu():void
{
	toolBoxEraserMenuOpened=true;
}

private function setFlagValueforShapeMenu():void
{
	toolBoxShapeMenuOpened=true;
}

/**
 * This function is invoked when user select shape color from
 * quick access color buttons.
 */
public function setQuickAccessColor(evnt:MouseEvent):void{
	applicationType::DesktopWeb{
		lineColorComboBox.selectedColor=evnt.currentTarget.getStyle("chromeColor");
		lineColor=evnt.currentTarget.getStyle("chromeColor");
		if (movableTextArea){
			movableTextArea.setStyle("color", uint(lineColor));
		}
		whiteBoardLineColorEventLog(pageNumber, uint(lineColor), "QuickAccess");
	}
	applicationType::mobile{
		lineColor=evnt.currentTarget.getStyle("chromeColor");
	}
}

/**
 *
 * @private
 * Audits the "WhiteBoardLineColor" action, when the presenter/user changes the color of their drawing
 *
 * @param pageNumber - Current page number
 * @param color - Chosen color's hex code
 * @param selectionMethod - QuickAccess or ColorPicker
 * @return void
 *
 */
private function whiteBoardLineColorEventLog(pageNumber:int, color:Number, selectionMethod:String):void
{
	AuditContext.userAction.createAction(AuditConstants.whiteBoardLineColor, pageNumber + "", color + "", selectionMethod);
}

/**
 * Deletes all the shape objects of the current page from the
 * internal array.
 */
private function resetInMemoryShapes():void{
	whiteboardShapeArray.splice(0);
}

/**
 * Converts the internal shape array to XML
 */
private function getPageXml(pageNumber:int):String{
	var pageXml:String=INITIAL_SHAPE_XML + "<Shapes pageNumber=\"" + pageNumber + "\">" + "\n";
	for (var i:uint=0; i < whiteboardShapeArray.length; i++){
		pageXml+=whiteboardShapeArray[i].convertToXml().toString();
		
	}
	pageXml+="</Shapes>";
	return pageXml;
	
}

/**
 * Starts the timer for auto saving a page.
 */
private function startAutoSaveTimer():void{
	autoSaveTimerForPage.start();
}

/**
 * Stops the timer for auto saving a page.
 */
private function stopAutoSaveTimer():void{
	autoSaveTimerForPage.stop();
}

/**
 *This function deletes the cached whiteboard files when
 *user closes the application if neccessary.
 */
private function deletingWbCache(serverFailOver:Boolean):void{
	applicationType::DesktopMobile{
		try{
			var file:File=new File(File.applicationStorageDirectory.nativePath + "\\WhiteBoard")
			if (file.exists){
				var subDirArr:Array=file.getDirectoryListing()
				for (var i:int=0; i < subDirArr.length; i++){
					if (!serverFailOver){
						if (subDirArr[i].name != cacheDirectoryName){
							subDirArr[i].deleteDirectory(true);
						}
					}
					else{
						if (subDirArr[i].name == cacheDirectoryName){
							subDirArr[i].deleteDirectory(true);
						}
					}
				}
			}
		}
		catch (Err:Error){
			if (Log.isError()) logger.error("Error while deleting temporary files" + Err.getStackTrace());
		}
	}
}

/**
 * Function to enable keyboard shortcuts in whiteboard. Example cntl+v to paste a text in whiteboard.
 * @param event of type KeyboardEvent.
 */
public function handleKeyboardShortcut(evnt:KeyboardEvent):void{
	applicationType::DesktopWeb{
		//If control+v is pressed invoke the paste method
		//Change #16400
		if (toolBoxContainer.visible){
			if (evnt.ctrlKey && evnt.keyCode == 86){
				if (Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
					//Fix for issue #10735.This logic is not used, directly cal function paste();
					applicationType::desktop{
						pasteSetTimeOutId=setTimeout(pasteText, 100, true);
					}
					applicationType::web{
						pasteText(true);
					}
				}
				else{
					MessageBox.show("The data format of current clipboard content is not supported by whiteboard.", "Info", MessageBox.MB_OK, whiteboardBaseCanvas);
				}
			}
		}
	}
}

/**
 * This function is called from core module(users.as) after user connection is made.
 * This function mainly creates all the collaboration objects. It also creates the
 * the folder structure in the content server for storing the page xml files for the lecture.
 */
public function connectWhiteboardCollabObjects():void{
	clearTimeout(connectCollabObjtsSetTimeOutId);
	if (Log.isDebug()) logger.debug("connectWhiteboardCollabObjects: Waiting for collaboration object to connect" );
	if (!isWbInitialized){
		connectCollabObjtsSetTimeOutId=setTimeout(connectWhiteboardCollabObjects, 200);
	}
	else{
		//Create these services only once after the roles are determined.
		if (Log.isDebug()) logger.debug("connectWhiteboardCollabObjects: runOnce = "+runOnce.toString());
		if (!runOnce){
			applicationType::DesktopWeb{
				if (Log.isError()) logger.error("connectWhiteboardCollabObjects: Connected. Userrole= " +FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole );
				//PNCR: two if condition with same conditions.
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
					autoSaveTimerForPage.addEventListener(TimerEvent.TIMER, autoSavePage);
					autoSaveTimerForPage.start();
				}
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
					createServerSideFolderService=new HTTPService();
					createServerSideFolderService.url=encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Common/createFolderStructure.php?folderPath=" + remoteFolderPath);
					// Creating the directory for saving files
					createServerSideFolderService.addEventListener(ResultEvent.RESULT, serverSideFolderCreated);
					createServerSideFolderService.addEventListener(FaultEvent.FAULT, failToCreateServerSideFolder);
					createServerSideFolderService.send();
					wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
					if (Log.isError()) logger.error("connectWhiteboardCollabObjects: Serverside folder creation completed." );
				}
			}
			applicationType::mobile{
				if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole ==  Constants.PRESENTER_ROLE){
					autoSaveTimerForPage.addEventListener(TimerEvent.TIMER,autoSavePage);
					autoSaveTimerForPage.start();
				}
				if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
					var createServerSideFolderService:HTTPService=new HTTPService();
					createServerSideFolderService.url=encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD+":"+ClassroomContext.portWAMP + "/AVScript/Common/createFolderStructure.php?folderPath=" + remoteFolderPath);
					// Creating the directory for saving files
					createServerSideFolderService.addEventListener(ResultEvent.RESULT, serverSideFolderCreated);
					createServerSideFolderService.addEventListener(FaultEvent.FAULT,failToCreateServerSideFolder);
					createServerSideFolderService.send();
					wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
				}
			}
			runOnce=true;
		}
		collaborationModeCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("collaborationModeSO");
		collaborationModeCollaborationObject.setOnClear(collaborationModeSOClearHanler);
		collaborationModeCollaborationObject.setOnChangeProperty("collaborationMode", collaborationModeSOPropertyChageHandler);
		
		navigationCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("navigationSO");
		navigationCollaborationObject.setOnClear(navigationSOClearHandler);
		navigationCollaborationObject.setOnChangeProperty("pageInfo", navigationSOChangeHandler);
		
		undoRedoCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("whiteboardUndoRedoSO");
		undoRedoCollaborationObject.setOnChangeProperty("undo", undoChangeHandler);
		undoRedoCollaborationObject.setOnChangeProperty("redo", redoChangeHandler);
		//Bug #15259. If there is any new drawing happening then clear the undo array in all nodes. Otherwise other privileged users can redo the old drawings.
		undoRedoCollaborationObject.setOnChangeProperty("clearAll", deleteUndoShapesFromAllUsers);
		
		
		
		pointerCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("whiteboardPointerSO");
		pointerCollaborationObject.setOnChangeProperty("pointerPosition", pointerPositionChangeHandler);
		pointerCollaborationObject.setOnChangeProperty("pointerStatus", pointerEnableDiableChangeHandler);
		
		isCollabObjectCreated=true;
	}
}


/**
 * Delete all the property values and close the shapeCollaborationObject.
 */
private function deleteWhiteboardShapesCollaborationObject():void{
	logger.info("fn:deleteWhiteboardShapesCollaborationObject - Delete and close collaboration object for - "+sharedObjectSuffix);
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && shapeCollaborationObject){
			shapeCollaborationObject.removeAllValues();
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && shapeCollaborationObject){
			shapeCollaborationObject.removeAllValues();
		}
	}
	ClassroomContext.collaborationService.closeCollaborationObject("whiteboardShapesSO_" + sharedObjectSuffix);
	
}

/**
 * Creates the shapeCollaborationObject.
 */
private function getwhiteboardShapesCollaborationObject():void{
	shapeCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("whiteboardShapesSO_" + sharedObjectSuffix, AutoPropertyName.NUMERIC);
	shapeCollaborationObject.setOnClear(whiteboardShapesSOOnClear);
	//shapeCollaborationObject.unlock();
}

/**
 * Delete all the property values and close the shapeSelectionCollaborationObject.
 */
private function deleteWhiteboardShapeSelectionCollaborationObject():void{
	applicationType::DesktopWeb{
		if (shapeSelectionCollaborationObject && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			shapeSelectionCollaborationObject.removeAllValues();
		}
	}
	applicationType::mobile{
		if (shapeSelectionCollaborationObject && FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			shapeSelectionCollaborationObject.removeAllValues();
		}
	}
	
	ClassroomContext.collaborationService.closeCollaborationObject("whiteboardShapeSelectionSO_" + sharedObjectSuffix);
}

/**
 * Creates the shapeSelectionCollaborationObject.
 */
private function getWhiteboardShapeSelectionCollaborationObject():void{
	shapeSelectionCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("whiteboardShapeSelectionSO_" + sharedObjectSuffix);
	shapeSelectionCollaborationObject.setOnChange(shapeSelectionCollaborationObjectChageHandler);
}

/**
 * This function is called from core module(users.as) after the application
 * is connected or reconnected to server. After the successful connection, enables the controls in whiteboard.
 */
public function setupWhiteboardOnConnection():void{
	clearTimeout(connectionSetTimeOutId);
	
	//Bug #15101. If there is a reconnection happends when a import page alert present, then remove the alert and corresponding shapes; and redraw the shapes.
	if (previewAlert){
		PopUpManager.removePopUp(previewAlert);
		removePreviewShapesFromPage();
		drawShapes();
	}
	
	if (!isWbInitialized){
		connectionSetTimeOutId=setTimeout(setupWhiteboardOnConnection, 200);
	}
	else{
		//Change #16403
		if (isPresenter()) {//Bug #16573. Enable page navigation only for presenter.
			nextBtn.enabled=true;
			applicationType::DesktopWeb{
				currentPagwb.enabled = true;
			}
			if (pageNumber != 1)
				previousBtn.enabled=true;
		}
		applicationType::DesktopWeb{
			//currentPageNumericStepper.enabled=true
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.alertServerSwitching == null)
				fileDetailsForCaching=new Array();
		}
		applicationType::mobile{
			fileDetailsForCaching=new Array();
		}
			
	}
}

/**
 * This function is called from core module(users.as) when the application
 * lose connection with the FMS.
 */
public function setupWhiteboardOnConnectionClose():void{
	/*applicationType::DesktopWeb{
		currentPageNumericStepper.enabled=false;
	}*/
	applicationType::DesktopWeb{
		nextBtn.enabled=false;
		currentPagwb.enabled = false;
		previousBtn.enabled=false;
	}
}

/**
 * The change handler for shapeSelectionCollaborationObject. It get called when
 * the position or size or text content of a selected shape changes.
 */
private function shapeSelectionCollaborationObjectChageHandler(value:Object,id:String):void{
	if (shapeSelectionCollaborationObject.syncEventCount > 1){
		//pageUpdated=true;
		isPageUpdated[value.pageNum] = true;
		applyShapeChanges(value);
	}
	
}

/**
 * It get called when the position or size or text content of a selected shape changes.
 */
private function applyShapeChanges(value:Object):void{
	if (value.action == "reposition"){
		applayPosition(value);
	}
	else if (value.action == "resize"){
		applayNewSize(value);
	}
	else if (value.action == "textChange"){
		applayNewText(value);
	}
}

/**
 *  It get called when the size of a selected shape changes.
 */
private function applayNewSize(value:Object):void{
	var obj:DisplayObject=drawingArea.getChildByName(value.shapeName) as DisplayObject
	if (obj){
		obj.width=value.newWidth;
		obj.height=value.newHeight;
		//Bug #15652. At the time of resize, change the textbox position also. 
		obj.x=value.newX;
		obj.y=value.newY;
		var index:int=getShapeIndex(value.shapeName);
		if (index >= 0){
			whiteboardShapeArray[index].txtAreaWidth=value.newWidth;
			whiteboardShapeArray[index].txtAreaHeight=value.newHeight;
		}
	}
}

/**
 *  It get called when the text content of a selected text shape changes.
 */
private function applayNewText(value:Object):void{
	applicationType::DesktopWeb{
		//Bug #15180, 15179. Added an extra condition to remove text from whiteboard, if user clear the text from text area.
		if (!value.newText){
			removeShapeFromWhiteboard(value.shapeName);
		}
		else {
			var obj:MoveableTextArea=drawingArea.getChildByName(value.shapeName) as MoveableTextArea
			if (obj){
				obj.text=value.newText;
				
				
				var index:int=getShapeIndex(value.shapeName);
				if (index >= 0){
					whiteboardShapeArray[index].txt_str=value.newText;
				}
			}
		}
	}
}

/**
 * Function to remove a shape from whiteboard.
 * @param shapeName, of type String
 */
private function removeShapeFromWhiteboard(shapeName:String):void{
	applicationType::DesktopWeb{
		var shape:Array=whiteboardShapeArray.splice(getShapeIndex(shapeName), 1);
		var child:DisplayObject = drawingArea.getChildByName(shapeName)
		if (child)
			drawingArea.removeChild(child);
		shapeCollaborationObject.removeValue(shape[0].shapeId);
		if (whiteboardShapeArray.length == 0){
			clearBtn.enabled=false;
		}
	}
}

/**
 * It get called when the position of a selected shape changes.
 */
private function applayPosition(value:Object):void{
	var obj:DisplayObject=drawingArea.getChildByName(value.shapeName) as DisplayObject
	if (obj){
		obj.x=value.newX * (wbCanvas.width / value.drawnAreaWidth);
		obj.y=value.newY * (wbCanvas.height / value.drawnAreaHeight);
		//drawingArea.removeChild(obj);
		var index:int=getShapeIndex(value.shapeName);
		if (index >= 0){
			whiteboardShapeArray[index].shapeX=value.newX;
			whiteboardShapeArray[index].shapeY=value.newY;
			
			//PNCR: #BugFix: 14936. After change the position of object show collaborator name.
			if(showCollaborator){
				removeCollaboratorNameBoxForObject(whiteboardShapeArray[index]);
				showCollaboratorForShape(whiteboardShapeArray[index]);
			}
		}
	}
}
/**
 * Function to remove a collaboration name box. 
 * If a user moves an object the collaboration name will be removed and a new name text will be created at the new object locaiton. 
 */
private function removeCollaboratorNameBoxForObject(shapeObj:WhiteboardShape):void{
	applicationType::DesktopWeb{
		var textBoxName:String = "collab_"+ shapeObj.shapeName;
		for (var i:int=wbCanvas.numElements - 1; i > 0; i--){
			if (wbCanvas.getElementAt(i) is Text){
				var textBox:Object = wbCanvas.getElementAt(i);
				if (textBox.name == textBoxName)
					wbCanvas.removeElementAt(i);
			}
		}
	}
}

/**
 * This function is used update the position of shapes for late-coming users
 * or re-connected users.
 */
private function getAndUpdateShapePosition():void{
	var data:Object=shapeSelectionCollaborationObject.getData();
	for each (var value:Object in data){
		applyShapeChanges(value);
	}
}

/**
 * This function get called when presenter enable or disable whiteboard pointer.
 */
private function pointerEnableDiableChangeHandler(value:String, oldValue:String, name:String):void{
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && pointerCollaborationObject.syncEventCount > 1){
			if (value == "enabled" && pointerShape == null){
				createMousePointer();
			}
			if (value == "disabled"){
				removePointer()
			}
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && pointerCollaborationObject.syncEventCount > 1){
			if (value == "enabled" && pointerShape == null){
				createMousePointer();
			}
			if (value == "disabled"){
				removePointer()
			}
		}
	}
}

/**
 * It get called when presenter moves/use the whiteboard pointer.
 */
private function pointerPositionChangeHandler(value:Object, oldValue:Object, name:String):void{
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && pointerCollaborationObject.syncEventCount > 1){
			movePointer(value.x, value.y, value.width, value.height);
			
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && pointerCollaborationObject.syncEventCount > 1){
			movePointer(value.x, value.y, value.width, value.height);
		}
	}
}

/**
 * Change the postion of the moude pointer.
 */
private function movePointer(_x:Number, _y:Number, _width:Number, _height:Number):void{
	if (pointerShape == null){
		createMousePointer()
	}
	var shapePoint:Shapepoint=new Shapepoint
	var scaleX:Number;
	var scaleY:Number
	pointerShapeX=_x;
	pointerShapeY=_y;
	drawingAreaWidthBeforResize=wbCanvas.width;
	drawingAreaHeightBeforResize=wbCanvas.height;
	scaleX=wbCanvas.width / _width;
	scaleY=wbCanvas.height / _height;
	pointerShape.x=scaleX * _x;
	pointerShape.y=scaleY * _y;
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.wbPointerRecorder.addEventTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), _x, _y, _width, _height, "")
		}
	}
}

/**
 * The clear handler for collaborationModeCollaborationObject.
 */
public function collaborationModeSOClearHanler():void{
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && isLogin){
			isLogin=false;
			collaborationModeCollaborationObject.setValue("collaborationMode", Constants.CM_SELECTED_STUDENT_CAN_WRITE);
			return;
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && isLogin){
			isLogin=false;
			collaborationModeCollaborationObject.setValue("collaborationMode", Constants.CM_SELECTED_STUDENT_CAN_WRITE);
			return;
		}
	}
}

/**
 * Change  handler for collaborationModeCollaborationObject.This function is called when user changes the collaboration mode
 */
public function collaborationModeSOPropertyChageHandler(value:String, oldValue:String, name:String):void{
	
	collaborationMode=value;
	if (collaborationMode == null || collaborationMode == "null" || collaborationMode.toString() == "undefined"){
		collaborationMode=Constants.CM_SELECTED_STUDENT_CAN_WRITE;
		if (Log.isInfo())			logger.info("collaborationModeSOPropertyChageHandler:- collaborationMode:" + collaborationMode + ":");
	}
	setDrawingPermission();
}


/**
 * Clear handler for navigationCollaborationObject.This is get called when user
 * connects or re-connect to navigationCollaborationObject. It reads the current page number from
 * the collaboration object and loads/reloads the page.
 */
private function navigationSOClearHandler():void{
	//Server fail-over navigation
	if (Log.isInfo()) logger.info("navigationSOClearHandler: contentServer = "+ contentServer + ", ClassroomContext.CONTENT_WHITEBOARD = " + ClassroomContext.CONTENT_WHITEBOARD);
	if (contentServer != ClassroomContext.CONTENT_WHITEBOARD){
		
		if (Log.isInfo())			logger.info(" failover navigation");
		contentServer=ClassroomContext.CONTENT_WHITEBOARD;
		// Creating the directory for saving files in new content server
		createServerSideFolderService=new HTTPService();
		createServerSideFolderService.url=encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Common/createFolderStructure.php?folderPath=" + remoteFolderPath);
		createServerSideFolderService.addEventListener(ResultEvent.RESULT, serverSideFolderCreated);
		createServerSideFolderService.addEventListener(FaultEvent.FAULT, failToCreateServerSideFolder);
		createServerSideFolderService.send();
		logger.info("navigationSOClearHandler: createServerSideFolderService url= "+createServerSideFolderService.url);
		fileUploadUrlRequest=new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Common/upload.php?folderPath=" + remoteFolderPath));
		return;
	}
	
	var data:Object=navigationCollaborationObject.getData();
	//FMS restart case 
	if (data == null || data["pageInfo"] == "null" || data["pageInfo"] == null || data["pageInfo"] == undefined || data["pageInfo"] == "undefined"){	
		retrievePageDetailsFromContentServer();		
		//PNCR: Bug #14225. The below logic has to be executed after the info.json file read.
		/*applicationType::DesktopWeb{
			currentPageNumericStepper.value=pageNumber;
		}
		if (pageNumber > 1){
			navigationCollaborationObject.setValue("pageInfo", {PageNumberCaching: pageNumber, currentPageNumber: pageNumber, totalPage: totalPages, lectureNamet: ClassroomContext.lecture.lectureName});
		}
		//#BugFix: #14886, #15551, #15528, #15527
		//If it is a first time login or there is no connected collaboration object, then read the page and connect a shapeCollaborationObject
		if (!shapeCollaborationObject || !shapeCollaborationObject.isConnected()) readPage(pageNumber);
		*/
		return;
	}
	
	//PNCR: Bug #18178. On reconnection check whether the pagechange happened in between or not. 
	//if so then load that page. 
	var soPageNumber:int =parseInt(data["pageInfo"].currentPageNumber);
	if (soPageNumber != pageNumber){
		pageNumber = soPageNumber;
		readPage(pageNumber);
	}
	totalPages=parseInt(data["pageInfo"].totalPage);
	applicationType::DesktopWeb{
		//pageNumDisplay.text="/" + totalPages;
		//currentPageNumericStepper.value=pageNumber;
		if (isPresenter())
			setPreviousButtonToolTip();
	}
	
	//#BugFix: #14886, #15551, #15528, #15527
	//If it is a first time login or there is no connected collaboration object, then read the page and connect a shapeCollaborationObject
	if (!shapeCollaborationObject || !shapeCollaborationObject.isConnected()) readPage(pageNumber);
	applicationType::DesktopWeb{
		if (pageNumber != 1 && isPresenter()){
			previousBtn.enabled=true;
		}
		if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.setValue("val", FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex);
		}
	}
}

private function retrievePageDetailsFromContentServer():void{
	readPageFromContentServer("info.json",loadPageRetrievedFromContentServer,faultHandlerForContentServerFileRead);

}

/**
 * Function to read a file from content server
 */
private function readPageFromContentServer(filename:String,resultHandler:Function,faultHandler:Function):void{
	var pageLoader:URLLoader=new URLLoader();
	pageLoader.dataFormat=URLLoaderDataFormat.BINARY;
	pageLoader.addEventListener(Event.COMPLETE, resultHandler)
	pageLoader.addEventListener(IOErrorEvent.IO_ERROR, faultHandler)
	pageLoader.load(new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + remoteFolderPath + "/" + filename)));
}

/**
 * Result handler of file read from content server 
 */
private function loadPageRetrievedFromContentServer(event:Event){
	logger.info("Reached result handler for content server file read");
	var loader:URLLoader = URLLoader(event.target);
	var jsonString:* = com.adobe.serialization.json.JSON.decode(loader.data);
	loadPage(jsonString.CurrentPage,jsonString.TotalPages);
}

/**
 * Fault handler of file read from content server 
 */
private function faultHandlerForContentServerFileRead(event:Event){
	logger.info("Reached fault handler for content server file read. File not present: "+event.toString());
	loadPage(1,1);
}

/**
 * Load a particular page on whiteboard. 
 * By default current page and tottal pages will be 1. 
 * At the time of reconnection the currentPage and totalPage values retrieved from content server info.json file and load those page.
 */
private function loadPage(currentPage:int, totalPagesFromContentServer:int):void{
	if(Log.isDebug()) logger.debug("Loading the page currentPage= "+currentPage+", totalPagesFromContentServer="+totalPagesFromContentServer)
	pageNumber = currentPage; 
	totalPages = totalPagesFromContentServer;
	applicationType::DesktopWeb{
		//currentPageNumericStepper.value=pageNumber;
		//pageNumDisplay.text="/" + totalPages;
		setPreviousButtonToolTip();
	}
	if (pageNumber > 1){
		navigationCollaborationObject.setValue("pageInfo", {PageNumberCaching: pageNumber, currentPageNumber: pageNumber, totalPage: totalPages, lectureNamet: ClassroomContext.lecture.lectureName});
	}
	//#BugFix: #14886, #15551, #15528, #15527
	//If it is a first time login or there is no connected collaboration object, then read the page and connect a shapeCollaborationObject
	if (!shapeCollaborationObject || !shapeCollaborationObject.isConnected()) 
		readPage(pageNumber);
}

/**
 * Function to inform all users to deleteundo shapes.
 */
private function deleteUndoShapesFromAllUsers(shapeName:String, oldValue:String, name:String):void{
	//Bug #15737. After reconnection the syncEventCount will be one. so no need to delete at reconnection.
	if (undoArray.length >0 && undoRedoCollaborationObject.syncEventCount > 1)
		deleteUndoShapes();
}

/**
 * Called when presenter perform undo. The last drawn shape is remomed from
 * the drawing area and keep it in an undoArray.
 */
private function undoChangeHandler(undoShapeName:String, oldValue:String, name:String):void{
	if (undoRedoCollaborationObject.syncEventCount > 1 && undoShapeName != ""){
		//pageUpdated=true;
		var splicedArray:Array=whiteboardShapeArray.splice(getShapeIndex(undoShapeName), 1);
		undoArray.push(splicedArray[0]);
		isPageUpdated[splicedArray[0].pageNo] = true;
		drawingArea.removeChild(drawingArea.getChildByName(splicedArray[0].shapeName));
		applicationType::DesktopWeb{
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				shapeCollaborationObject.removeValue(splicedArray[0].shapeId);
			}
		}
		applicationType::mobile{
			if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				shapeCollaborationObject.removeValue(splicedArray[0].shapeId);
			}
		}
		if (whiteboardShapeArray.length == 0){
			applicationType::DesktopWeb{
				clearBtn.enabled=false;
			}
		}
		//Bug #15058. If the collaboration name is present for that object, then remove collaboration name text also at the time of undo.
		if (showCollaborator){
			applicationType::DesktopWeb{
				for (var i:int=wbCanvas.numElements - 1; i > 0; i--){
					var element:* = wbCanvas.getElementAt(i);
					if (element is Text && element.name == "collab_"+ undoShapeName){
						wbCanvas.removeElementAt(i);
					}
				}
			}
			
		}
	}
}

/**
 * Called when presenter perform redo. The last undone shape is taken from the
 * undo array and draw to the drawing area.
 */
private function redoChangeHandler(redoShapeName:String, oldValue:String, name:String):void{
	if (undoRedoCollaborationObject.syncEventCount > 1 && redoShapeName != ""){
		//pageUpdated=true;
		var splicedArray:Array=undoArray.splice(undoArray.length - 1, 1)
		//Bug #15259. If there is no shape to redo, then return. 
		if (splicedArray.length == 0)
			return;
		isPageUpdated[splicedArray[0].pageNo] = true;
		if (whiteboardShapeArray.length == 0){
			applicationType::DesktopWeb{
				clearBtn.enabled=true;
			}
		}
		applicationType::DesktopWeb{
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				//Bug #15452. At the time of redo the object owner was changing. Commented that feature.
				//splicedArray[0].drawnBy=ClassroomContext.userVO.userName;
				splicedArray[0].ignoreSync=false;
				splicedArray[0].shapeId=currentShapeId;
				shapeCollaborationObject.addValue(splicedArray[0]);
			}
			
		}
		applicationType::mobile{
			if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				//Bug #15452. At the time of redo the object owner was changing. Commented that feature.
				//splicedArray[0].drawnBy=ClassroomContext.userVO.userName;
				splicedArray[0].ignoreSync=false;
				splicedArray[0].shapeId=currentShapeId;
				shapeCollaborationObject.addValue(splicedArray[0]);
			}
		}
		
	}
	
}


/**
 * Called when presenter navigate from one page. The pervious page is saved to server and
 * the new page is fetched from the server.
 */
private function navigationSOChangeHandler(pageInfo:Object, oldPageInfo:Object, name:String):void{
	clearTimeout(navigationInfoStoreTimeOutId);
	logger.info("Navigation - navigationSOChangeHandler: "+ navigationCollaborationObject.syncEventCount.toString() +" should be grater than 1");
	if (navigationCollaborationObject.syncEventCount > 1){
		disableRightClickMenu();
		pageNumber=parseInt(pageInfo.currentPageNumber);
		pageToSave=parseInt(pageInfo.PageNumberCaching);
		applicationType::DesktopWeb{
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
				totalPages=parseInt(pageInfo.totalPage);
				//currentPageNumericStepper.value=pageNumber;
				//pageNumDisplay.text="/" + totalPages;
			}
		}
		applicationType::mobile{
			if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
				totalPages=parseInt(pageInfo.totalPage);
			}
		}
		stopAutoSaveTimer();
		logger.info("Navigation - navigationSOChangeHandler: pagenumber="+pageNumber.toString()+", pagetoSave="+pageToSave.toString());
		if (pageNumber != pageToSave){
			//shapeCollaborationObject.lock();
			applicationType::DesktopWeb{
				//Bug #15215. Restore button has to be removed.
				/*if (restorBtn.enabled){
					restorBtn.enabled=false;
				}*/
				if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addPageTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), pageNumber);
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addSizeTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), wbCanvas.width, wbCanvas.height);
				}
				//PNCR: #BugFix: 14756, 14874, 14875. If there is any unsaved textArea is present, then remove that.
				if(movableTextArea) removeTextArea();
				//PNCR: #BugFix: 15099. Remove the object selection points in the new page. no need to commit.
				if (isSelectionMode) removeSelection(false);
			}
			savePage(pageToSave);
			readPage(pageNumber);
			applicationType::DesktopWeb{
				clearBtn.enabled=(whiteboardShapeArray.length == 0 ? false : true);
			}
			
			activateWb();
			//Bug #14225
			navigationInfoStoreTimeOutId=setTimeout(saveNavigaionInformationForTheSession, 3000);
			
		}
		else {//When FMS restarts. We just save the current whiteboard to server
			var key:String="page" + pageNumber;
			if (fileDetailsForCaching[key] == null)
				savePage(pageToSave);
		}
		
	}
}

/**
 * This function reads the shapes  from FMS shared object.
 * Added checkForNewShapes - to avoid partial drawing display in viewer side.
 * If there is any new drawings in SO then only it will return value, else viewer will retrive the value from content server.  
 */
private function getShapeFromSO(checkForNewShapes:Boolean = false):Array{
	var isNewShapesInSO:Boolean = false;
	var tempSOPropertyName:String=ClassroomContext.lecture.lectureName + "|" + pageNumber;
	if (Log.isInfo())		logger.info(" Entered function getShapeFromSO.Getting shape for page: " + pageNumber + "Shape proerty name: " + tempSOPropertyName);
	var tempWhiteboardShapeArray:Array=new Array();
	var data:Object=shapeCollaborationObject.getData();
	for (var propertyName:String in data){
		if (shapeCollaborationObject.getData()[propertyName] != null){
			var shapeObj:WhiteboardShape=new WhiteboardShape();
			shapeObj.initBySO(shapeCollaborationObject.getData()[propertyName].propertyValue);
			if(shapeObj.ignoreSync == false){isNewShapesInSO = true}
			tempWhiteboardShapeArray.push(shapeObj);
		}
	}
	if (Log.isInfo())		logger.info(" In function getShapeFromSO. Total shapes from SO: " + tempWhiteboardShapeArray.length);
	if (tempWhiteboardShapeArray.length > 0){
		tempWhiteboardShapeArray.sortOn("shapeId", Array.NUMERIC);
	}
	if(checkForNewShapes && !isNewShapesInSO)
		return new Array();
	else
		return tempWhiteboardShapeArray;
}

/**
 * Toggle the enable status of clear and restore button.
 */
private function toggleClearRestore(clear:Boolean):void{
	//applicationType::DesktopWeb{
		//clearBtn.enabled=clear;
		//Bug #15215. Restore button has to be removed.
		//restorBtn.enabled=!clear;
	//}
	applicationType::mobile{
		//To enable and disable the clear/restore button when presenter navigates to next/previous page.
		var isDrawingExist:Boolean = false;
		for(var i:int = 0 ;i<whiteboardShapeArray.length; i++)
		{
			if(whiteboardShapeArray[i].drawnBy != "null" && whiteboardShapeArray[i].pageNo == pageNumber)
			{
				isDrawingExist = true;
				break;
			}
		}
		FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.enabled = isDrawingExist;
	}
}

/**
 * This method is called from readPage & onPageLoaderStatus. After loading the shapes from server cache and shared objects
 This will setup the in memory shapes and setup the button states
 */
private function setupWhiteboardPage():void{
	var toolName:String
	var tempWhiteboardShapeArray:Array=whiteboardShapeArray.concat();
	whiteboardShapeArray.splice(0);
	var isClear:Boolean=false;
	//16445. On pageread, pageUpdated flag is not required. 
	//It will cause unnecessary pageSave for fast page navigation.
	/*if (tempWhiteboardShapeArray.length > 0){
		pageUpdated=true;
	}*/
	for (var i:uint=0; i < tempWhiteboardShapeArray.length; i++){
		toolName=tempWhiteboardShapeArray[i].toolName;
		if (toolName != "clear" && toolName != "restore"){
			if (isClear){
				resetInMemoryShapes();
				isClear=false;
				//resetInMemoryBackupShapes();
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						shapeCollaborationObject.removeAllValues();
						currentShapeId=1;
					}
				}
				applicationType::mobile{
					if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						shapeCollaborationObject.removeAllValues();
						currentShapeId=1;
					}
				}
			}
			applicationType::DesktopWeb{
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
					tempWhiteboardShapeArray[i].ignoreSync=true;
					tempWhiteboardShapeArray[i].shapeId=currentShapeId;
					shapeCollaborationObject.addValue(tempWhiteboardShapeArray[i]);
				}
			}
			applicationType::mobile{
				if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
					tempWhiteboardShapeArray[i].ignoreSync=true;
					tempWhiteboardShapeArray[i].shapeId=currentShapeId;
					shapeCollaborationObject.addValue(tempWhiteboardShapeArray[i]);
				}
			}
			whiteboardShapeArray.push(tempWhiteboardShapeArray[i]);
			currentShapeId++;
		}
		else if (toolName == "clear"){
			if (i == tempWhiteboardShapeArray.length - 1){
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						tempWhiteboardShapeArray[i].ignoreSync=true;
						tempWhiteboardShapeArray[i].shapeId=currentShapeId;
						shapeCollaborationObject.addValue(tempWhiteboardShapeArray[i]);
						currentShapeId++;
					}
				}
				applicationType::mobile{
					if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						tempWhiteboardShapeArray[i].ignoreSync=true;
						tempWhiteboardShapeArray[i].shapeId=currentShapeId;
						shapeCollaborationObject.addValue(tempWhiteboardShapeArray[i]);
						currentShapeId++;
					}
				}
				whiteboardShapeArray.push(tempWhiteboardShapeArray[i]);
			}
			isClear=true;
			toggleClearRestore(false);
		}
		else if (toolName == "restore"){
			isClear=false;
			toggleClearRestore(true);
		}
	}
	
}
/**
 * Function to check whether the user is presenter or not
 */
private function isPresenter(){
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			return true;
		else
			return false;
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			return true;
		else
			return false;
	}
}


/**
 * Draw shpes from the local array
 */
private function drawShapes(isImpoetPage:Boolean=false):void{
	var shapeArray:Array;
	if (isImpoetPage){
		shapeArray=shapeArrayFromImportedPage
	}
	else{
		shapeArray=whiteboardShapeArray;
		removeShapes();
	}
	if (Log.isInfo())		logger.info(" Entered function drawShapes for the page " + pageNumber + ". Numner of shapes:" + whiteboardShapeArray.length);
	if (pointerShape != null){
		if (drawingAreaWidthBeforResize > 0 && drawingAreaHeightBeforResize > 0){
			pointerShape.x=pointerShapeX * (wbCanvas.width / drawingAreaWidthBeforResize) - 3
			pointerShape.y=pointerShapeY * (wbCanvas.height / drawingAreaHeightBeforResize) - 3
		}
		else{
			pointerShape.x=pointerShapeX - 3;
			pointerShape.y=pointerShapeY - 3;
		}
	}
	var drawingToolName:String;
	var shapeLength:uint=shapeArray.length;
	if (shapeLength > 0){
		toggleClearRestore(true);
	}
	for (var i:uint=0; i < shapeLength; i++){
		drawingToolName=shapeArray[i].toolName;
		if (drawingToolName != "clear"){
			logger.info("fn: drawShapes. Going to write shape canvas width= "+wbCanvas.width+" and height= "+wbCanvas.height)
			var obj:Object=shapeArray[i].drawShape(wbCanvas.width, wbCanvas.height, backgroundColor);
			
			if (obj != null){
				
				//if some users are logged in older versions, the shape objects may not have shapeName property 
				if (shapeArray[i].shapeName)
					obj.name=shapeArray[i].shapeName;
				logger.info("fn: drawShapes. Got sprite from drawShape function name= "+obj.name)
				applicationType::DesktopWeb{
					if (!checkAndUpdatingExistingShape(obj)){
						logger.info("fn: drawShapes. There is no existing sprite with same name= "+obj.name)
						obj is WhiteboardShapeSprite ? drawingArea.addChild(obj as WhiteboardShapeSprite) : drawingArea.addChild(obj as MoveableTextArea);
						
						
						if (showCollaborator){
							showCollaboratorForShape(shapeArray[i]);
						}
					}
					else{
						logger.info("fn: drawShapes. There is an existing sprite with the same name= "+obj.name)
					}
				}
				applicationType::mobile{
					if (!checkAndUpdatingExistingShape(obj)){
						obj is WhiteboardShapeSprite ? drawingArea.addChild(obj as WhiteboardShapeSprite) : drawingArea.addChild(obj as DynamicTextArea);
						if (showCollaborator){
							showCollaboratorForShape(shapeArray[i]);
						}
					}
				}
			}
			else{
				logger.info("fn: drawShapes. There is no object got from Whiteboardshape-> drawShape function")
			}
			applicationType::DesktopWeb{
				if (whiteboardShapeArray.length == 0)
					clearBtn.enabled = false;
				else if (isPresenter())
					clearBtn.enabled = true;
			}
		}
		else if (drawingToolName == "clear"){
			if (i > 0){
				removeShapes();
				toggleClearRestore(false);
			}
			else if (i == 0){
				applicationType::DesktopWeb{
					clearBtn.enabled=(whiteboardShapeArray.length == 0 ? false : true);
				}
			}
		}
	}
	//PNCR: #BugFix: 14978. On resize enable object selection if that button is active.
	if(isSelectionMode)
		enableSelection();
	makePointerAsTopChild();
		
	//If presenter has hidden the whiteboard, make the hide canvas as top child always
	if (hideWbCanvas != null){
		whiteboardBaseCanvas.setElementIndex(hideWbCanvas, whiteboardBaseCanvas.numElements - 1)
	}
	
}

/**
 * Check whether the shape is already existing and apply the changes if any.
 */
private function checkAndUpdatingExistingShape(obj:Object):Boolean{
	var isExisting:Boolean=false;
	var shape:Object=drawingArea.getChildByName(obj.name);
	if (shape){
		shape.x=obj.x;
		shape.y=obj.y;
		applicationType::mobile{
			if (obj is DynamicTextArea){
				
				shape.text=shape.text;
			}
			else if (obj is WhiteboardShapeSprite){
			}
		}
		applicationType::DesktopWeb{
			if (obj is MoveableTextArea){
				
				shape.text=shape.text;
			}
			else if (obj is WhiteboardShapeSprite){
			}
		}
		isExisting=true;
	}
	return isExisting;
}
/**
 * This function get called in every one minute for a presenter to save the current
 * whiteboard page
 */
private function autoSavePage(evnt:TimerEvent):void{
	savePage(pageNumber)
}

//Bug #14225
/**
 * Function to store the navigation information permanantly.
 * This will store the total page number and current page number. So even if the user login after a long break, it will open the same old page. 
 */
private function saveNavigaionInformationForTheSession():void{
	logger.info(" Entered function saveNavigaionInformationForTheSession. Current page:" + pageNumber);
	applicationType::DesktopMobile{
		//Local file where we store the information temporarly. Later this file will upload to content server using php.
		var file:File=new File(File.applicationStorageDirectory.nativePath + localFilePath + "info.json");
		
		//Bite array to store the data to write.
		var biteArray:ByteArray=new ByteArray();
		biteArray.writeUTFBytes('{"TotalPages":'+totalPages+',"CurrentPage":'+pageNumber+'}');
		
		//File stream which write the data in to a local file.
		var fileStream:FileStream=new FileStream();
		fileStream.open(file, FileMode.WRITE);
		fileStream.writeBytes(biteArray, 0, biteArray.length);
		fileStream.close();
	
		//Upload the local file to the content server.
		//16445. Added a separate event handler for upload complete and upload failed.
		//Otherwise it will use 'onUploadCompleate' and set the pageUpdate flag to true, which is not required for page info store. 
		file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onInfoPageUploadCompleate);
		file.addEventListener(HTTPStatusEvent.HTTP_STATUS, onInfoPageUploadFailed);
		file.addEventListener(IOErrorEvent.IO_ERROR, onInfoPageUploadFailed);
		file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onInfoPageUploadFailed);
		//fileUploadUrlRequest contains the fileupload.php link with remote location, where to store the file. It is defined at the time of wb initialization.
		file.upload(fileUploadUrlRequest);
	}
	//Fix for issues #17614 and #17585
	applicationType::web{
		fileUploadUrl=encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Common/createFileWithData.php?folderPath=" + remoteFolderPath + "&&fileName=info.json");
		//Bite array to store the data to write.
		var biteArray:ByteArray=new ByteArray();
		biteArray.writeUTFBytes('{"TotalPages":'+totalPages+',"CurrentPage":'+pageNumber+'}');
		
		var request:URLRequest=new URLRequest(fileUploadUrl);
		request.method=URLRequestMethod.POST;
		request.data=biteArray;
		request.contentType='application/octet-stream';
		var loader:URLLoader=new URLLoader();
		loader.addEventListener(Event.COMPLETE, onInfoPageUploadCompleate);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onInfoPageUploadFailed);
		loader.load(request);
	}
}
//Fix for issues #17614 and #17585
applicationType::web{
	/**
	 * Event handler for info page upload complete.
	 */
	protected function onInfoPageUploadCompleate(event:Event):void
	{
		logger.info("Navigation: Page info stored successfully")
	}
	/**
	 * Event handler for info page upload failed.
	 */
	protected function onInfoPageUploadFailed(event:IOErrorEvent):void
	{
		if(Log.isError()) logger.error("whiteboard::WhiteBoardHandler::onInfoPageUploadFailed:");
		MessageBox.show("Server is Down. The information page is not saved or auto-saved to server", "WARNING", MessageBox.MB_OK, this);
	}
}
applicationType::DesktopMobile{
	/**
	 * Event handler for info page upload complete.
	 */
	protected function onInfoPageUploadCompleate(event:DataEvent):void
	{
		logger.info("Navigation: Page info stored successfully")
	}
	/**
	 * Event handler for info page upload failed.
	 */
	protected function onInfoPageUploadFailed(event:FaultEvent):void
	{
		if(Log.isError()) logger.error("whiteboard::WhiteBoardHandler::onInfoPageUploadFailed:" + AbstractHelper.getStaticFaultMessage(event));
		MessageBox.show("Server is Down. The information page is not saved or auto-saved to server", "WARNING", MessageBox.MB_OK, this);
	}
}

/**This function will save the page locally
 * as well as upload the page to server if the user is a presenter
 */
private function savePage(pageNo:int):void{
	if (Log.isInfo())		logger.info(" Navigation: Entered function savePage. Page saving is:" + pageNo);
	var key:String="page" + pageNo;
	var obj:Object=null;
	
	//Create the  file objects and file stream objects for the writing the 
	// file to cache, if they are not created already.
	if (fileDetailsForCaching[key] == null){
		applicationType::DesktopMobile{
			obj=new Object();
			obj["fileObject"]=new File(File.applicationStorageDirectory.nativePath + localFilePath + key + ".xml");
			obj["fileStreamObj"]=new FileStream();
			fileDetailsForCaching[key]=obj
		}
		applicationType::web{
			//Remote folder path to save whiteboard drawings.
			//Fix for issues #16764 and #16797
			fileUploadUrl=encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + "/AVScript/Common/createFileWithData.php?folderPath=" + remoteFolderPath + "&&fileName=" + key + ".xml");
		}
	}
	// If some changes, save the page
	logger.info(" Navigation: pageUpdated = " + (isPageUpdated.hasOwnProperty(pageNo) ? isPageUpdated[pageNo] : "no pageNo: "+pageNo+" property") +" it should be true");
	//if (pageUpdated){
	if (isPageUpdated.hasOwnProperty(pageNo) && isPageUpdated[pageNo]){
		logger.info(" Navigation: pageUpdated = " + isPageUpdated[pageNo].toString() +" it should be true");
		disableOrEnableNavigation(false);
		obj=fileDetailsForCaching[key];
		var biteArray:ByteArray=new ByteArray();
		logger.info(" Navigation: goint to write shapes in bitearray. PageNum = " + pageNo.toString());
		//logger.info(" Navigation: whiteboardShapeArray. length = " + whiteboardShapeArray.length.toString());
		//logger.info(" Navigation: whiteboardShapeArray. last tool = " + whiteboardShapeArray[whiteboardShapeArray.length-1].toolName );
		logger.info(" Navigation: last action = " + toolName );
		biteArray.writeUTFBytes(getPageXml(pageNo));
		
		applicationType::DesktopMobile{
			obj["fileStreamObj"].open(obj.fileObject, FileMode.WRITE);
			//biteArray.compress("deflate"); // compress the data
			obj["fileStreamObj"].writeBytes(biteArray, 0, biteArray.length);
			obj["fileStreamObj"].close();
			applicationType::desktop{
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) {//upload to server
					obj["fileObject"].addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleate)
					obj["fileObject"].addEventListener(HTTPStatusEvent.HTTP_STATUS, onUploadFailed)
					obj["fileObject"].addEventListener(IOErrorEvent.IO_ERROR, onUploadFailed)
					obj["fileObject"].addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadFailed)
					
					obj["fileObject"].upload(fileUploadUrlRequest);
				}
			}
			applicationType::mobile{
				if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole ==  Constants.PRESENTER_ROLE){//upload to server
					obj["fileObject"].addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleate)
					obj["fileObject"].addEventListener(HTTPStatusEvent.HTTP_STATUS, onUploadFailed)
					obj["fileObject"].addEventListener(IOErrorEvent.IO_ERROR, onUploadFailed)
					obj["fileObject"].addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadFailed)
					
					obj["fileObject"].upload(fileUploadUrlRequest);
				}
			}
		}
		//Fix for issues #17614 and #17585
		applicationType::web{
			//To save whiteboard drawings to server. 
			//Fix for issue #20017
			uploadedPageNumber = pageNo;
			var request:URLRequest=new URLRequest(fileUploadUrl);
			request.method=URLRequestMethod.POST;
			request.data=biteArray;
			request.contentType='application/octet-stream';
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(Event.COMPLETE, onUploadCompleate);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onUploadFailed);
			loader.load(request);
		}
	}
	else{
		logger.info("no update on page "+ pageNo +" to save. Global variable pageNumber = "+pageNumber);
	}
}

/**
 * Invoked when the page saving to server fails.
 */
private function onUploadFailed(evnt:FaultEvent):void{
	if(Log.isError()) logger.error("whiteboard::WhiteBoardHandler::onUploadFailed:" + AbstractHelper.getStaticFaultMessage(evnt));
	MessageBox.show("Server is Down. The page is not saved or auto-saved to server", "WARNING", MessageBox.MB_OK, this);
	disableOrEnableNavigation(true);
	//pageUpdated=true; //So after one minute it will start saving automatically.
	applicationType::desktop{
		var pageNum:int = getPageNumberFromUploadedFileName(evnt.target as File);
		isPageUpdated[pageNum] = true;
	}
}

/**
 * Invoked after saving the page to server.
 */
applicationType::web{
	//DataEvent is not supported. So changed to Event.
	private function onUploadCompleate(evnt:Event):void{
		//pageUpdated=false; //The page auto save will stope until any new change comes.
		//Fix for issue #20017
		isPageUpdated[uploadedPageNumber] = false;
		//Fix for issue #19387
		logger.info("Navigation: upload completed")
		if (isPresenter())
			disableOrEnableNavigation(true);
		garbageCollection.callGarbageCollection(); //call garbage collection on page change happens.
		garbageCollection.totalGCCalls = 0; //variable used to check how many times garbageCollection function called. In a new page the count has to restart.
		
	}
}
applicationType::DesktopMobile{
	private function onUploadCompleate(evnt:DataEvent):void{
		//pageUpdated=false;
		var pageNum:int = getPageNumberFromUploadedFileName(evnt.target as File);
		isPageUpdated[pageNum] = false;
		logger.info("Navigation: upload completed")
		if (isPresenter())
			disableOrEnableNavigation(true);
		garbageCollection.callGarbageCollection(); //call garbage collection on page change happens.
		garbageCollection.totalGCCalls = 0; //variable used to check how many times garbageCollection function called. In a new page the count has to restart.
		
	}
	
	/**
	 * Function to get page number for the file name. 
	 * If use the global variable pageNumber, then there are chanses that it may get changed before upload complete (In case of fast navigation)  
	 */
	private function getPageNumberFromUploadedFileName(file:File):int{
		var complPageName:String = file.name;
		var pageName:String = complPageName.split(".")[0];
		var pageNum:int = pageName.split("page")[1];
		return pageNum;
	}
}

/**
 * This function is used to retrieve the whiteboard pages
 */
private function readPage(pageNo:int):void{
	//Clear out the previous page shapes
	if (Log.isInfo())		logger.info(" Entered function readPage.Page reading is: " + pageNo);
	currentShapeId=1;
	deleteWhiteboardShapesCollaborationObject();
	deleteWhiteboardShapeSelectionCollaborationObject();
	sharedObjectSuffix="Page" + pageNo;
	getwhiteboardShapesCollaborationObject();
	getWhiteboardShapeSelectionCollaborationObject();
	resetInMemoryShapes();
	removeShapes();
	//pageNumberReading=pageNo;
	var key:String="page" + pageNo;
	waitForShapeCollaborationObjectConnect(key);
	
	
}

/**
 * Initialises the shape array from the xml file.
 */
private function initializeShapeArrayForPage(biteArray:ByteArray):void{
	if (Log.isInfo())		logger.info(" Entered function initializeShapeArrayForPage");
	var tempWhiteboardShapeArray:Array=null;
	whiteboardShapeArray=new Array();
	//Fix for issues #17614 and #17585
	applicationType::web{
		//Fix for issue #20017
		if (biteArray != null){
			var xmlShapesFromFile:XML=XML(biteArray);
			if (xmlShapesFromFile.@pageNumber == pageNumber){
				whiteboardShapeArray=convertXmlToObjects(xmlShapesFromFile);
			}
			else{
				if (Log.isInfo())				logger.info(" In function initializeShapeArrayForPage. Shape Array is empty ");
			}
		}
	}
	applicationType::DesktopMobile{
		if (biteArray != null){
			var xmlShapesFromFile:XML=XML(biteArray);
			if (xmlShapesFromFile.@pageNumber == pageNumber){
				whiteboardShapeArray=convertXmlToObjects(xmlShapesFromFile);
				
			}
			else{
				if (Log.isInfo())				logger.info(" In function initializeShapeArrayForPage. Shape Array is empty ");
			}
			
		}
	}
	applicationType::DesktopWeb{
		if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
				recordedExistingContent=false;
				recordExistingContent();
			}
		}
	}
}

/**
 * Function which convert the xml files to shape Object
 */
private function convertXmlToObjects(xmlData:XML, isFromImportPage:Boolean=false):Array{
	var shapeObj:WhiteboardShape
	var shapePoint:Shapepoint;
	var tempWhiteboardShapeArray:Array=new Array();
	for each (var shape:XML in xmlData.shape){
		shapeObj=new WhiteboardShape()
		shapeObj.initByXML(shape);
		tempWhiteboardShapeArray.push(shapeObj);
	}
	if (!isFromImportPage)
		tempWhiteboardShapeArray.sortOn("shapeId", Array.NUMERIC);
	return tempWhiteboardShapeArray;
}

/**
 * Status handler for the url loader
 */
private function onPageLoaderStatus(evnt:Event):void{
	if (Log.isInfo())		logger.info(" Entered function onPageLoaderStatus. The current page is: " + pageNumber);
	//Succesfully load the data from the server
	var biteArray:ByteArray=null;
	if (evnt.type == Event.COMPLETE){
		var pageLoader:URLLoader=evnt.currentTarget as URLLoader;
		applicationType::DesktopMobile{
			var fileObj:File=new File(File.applicationStorageDirectory.nativePath + localFilePath + "page" + pageNumber + ".xml");
			var fileStreamObj:FileStream=new FileStream();
			fileStreamObj.open(fileObj, FileMode.WRITE);
			
			fileStreamObj.writeBytes(pageLoader.data, 0, pageLoader.bytesLoaded);
			fileStreamObj.close()
		}
		biteArray=pageLoader.data;
		
		pageLoader.removeEventListener(Event.COMPLETE, onPageLoaderStatus)
		pageLoader.removeEventListener(IOErrorEvent.IO_ERROR, onPageLoaderStatus);
		initializeShapeArrayForPage(biteArray);
		setupWhiteboardPage();
		drawShapes();
		getAndUpdateShapePosition();
		
	}
		//If some error loading data from the server
	else if (evnt.type == IOErrorEvent.IO_ERROR){
		if (Log.isError())			logger.error("onPageLoaderStatus: Error while loading shapes from xml file for page :" + pageNumber + ".Error message :" + evnt.toString());
	}
	
	//Initializes whiteboardShapeArray
	startAutoSaveTimer();
	
}

/**
 * Read and construct the page XML after shapeCollaborationObject get connected.
 */
private function waitForShapeCollaborationObjectConnect(pageXmlName:String):void{
	logger.info("Fn: waitForShapeCollaborationObjectConnect pageName = "+pageXmlName);
	clearInterval(waitForShapeCollaborationObjectConnectIntervalId)
	if (shapeCollaborationObject.syncEventCount == 0){
		logger.info("Fn: waitForShapeCollaborationObjectConnect Waiting for SO to connect. pageName = "+pageXmlName);
		waitForShapeCollaborationObjectConnectIntervalId=setInterval(waitForShapeCollaborationObjectConnect, 50, pageXmlName)
	}
	else{
		//Bug #19992. Viewer reading the page from SO first, if it is null then from content server. 
		//Sometimes the viewer system may be slow in processing readpage(). 
		//And presenter will read page and add shapes (partially) in SO.
		//This partial SO will read by viewer and show only those drawings.
		//To avoid this partial reading checking whether there is any new drawings in SO, if not then read from Content server.
		whiteboardShapeArray=getShapeFromSO(true);
		if (whiteboardShapeArray.length == 0){
			logger.info("Fn: waitForShapeCollaborationObjectConnect. No SO read from content server. pageName = "+pageXmlName);
			
			//Bug #18782. Close existing pageLoader before loading a new. Otherwise fast page change may call unnecessary pageloads.
			if (pageLoader) {
				pageLoader.close();
				pageLoader.removeEventListener(Event.COMPLETE, onPageLoaderStatus)
				pageLoader.removeEventListener(IOErrorEvent.IO_ERROR, onPageLoaderStatus)
				pageLoader = null;
			}
			
			pageLoader=new URLLoader();
			pageLoader.dataFormat=URLLoaderDataFormat.BINARY;
			pageLoader.addEventListener(Event.COMPLETE, onPageLoaderStatus)
			pageLoader.addEventListener(IOErrorEvent.IO_ERROR, onPageLoaderStatus)
			//Fix for issue #20060
			applicationType::DesktopMobile{
				pageLoader.load(new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + remoteFolderPath + "/" + pageXmlName + ".xml")));
			}
			applicationType::web{
				pageLoader.load(new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_WHITEBOARD + ":" + ClassroomContext.portWAMP + remoteFolderPath + "/" + pageXmlName + ".xml?nocache=" + (new Date()).getTime())));
			}
		}
		else{
			logger.info("Fn: waitForShapeCollaborationObjectConnect. SO has value. pageName = "+pageXmlName +" shapeArray length"+whiteboardShapeArray.length);
			setupWhiteboardPage();
			drawShapes();
			getAndUpdateShapePosition();
			startAutoSaveTimer();
		}
	}
	
}

/**
 * This function is used to disable the navigation control while
 * the new page is loading and enable it back after the page loaded
 */
private function disableOrEnableNavigation(flag:Boolean):void{
	applicationType::DesktopWeb{
		//Change #16403
		nextBtn.enabled=flag;
		//Change #16479
		currentPagwb.enabled = flag;
	}
	/*applicationType::DesktopWeb{
		currentPageNumericStepper.enabled=flag;
	}*/

	if (!flag){
			previousBtn.enabled=flag;
		if (hideWbCanvas != null){
			whiteboardBaseCanvas.addElement(labelMessageWhileNavigation);
			labelMessageWhileNavigation.setStyle("fontSize", "20")
			labelMessageWhileNavigation.x=(whiteboardBaseCanvas.width / 2) - 130;
			labelMessageWhileNavigation.y=(whiteboardBaseCanvas.height / 2) - 20;
			whiteboardBaseCanvas.setElementIndex(labelMessageWhileNavigation, whiteboardBaseCanvas.numElements - 1);
		}
	}
	else{
		if (pageNumber != 1){
			previousBtn.enabled=flag;
		}
		if (hideWbCanvas == null){
			try{
				whiteboardBaseCanvas.removeElement(labelMessageWhileNavigation);
			}
			catch (err:Error){
				if(Log.isError()) logger.error("Error in disableOrEnableNavigation method:"+ err.getStackTrace());
			}
		}		
	}
}

/**
 * This method is to handle mouse out event when user draw beyond the boundaries of the drawing area.
 * This is to stops the user from drawing beyond the boundary.
 * @param event The Mouse over events of components in the  boundaries of drawing area.
 */
private function scratchAreaMouseOutHandler(e:MouseEvent):void{
	//Bug #19330. Reverted back to the old logic. 
	// To avoid Bug #15546, changed the rollout event handle from "enabledrawing()" to "drawingAreadMouseDown()". 
	wbCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
	
	//Bug #15546.Some times the roll_out event is dispatching unnecessary. To avoid that,
	//Added a condition to throw mouse up event only if the mouse is out from the drawing area.
	/*if ((e.localX > 0 && e.localX < wbCanvas.width) && (e.localY > 0 && e.localY < wbCanvas.height-13)){
		applicationType::DesktopWeb{
			//Bug #17050. The mouseup should call even for the palets also.
			if ((toolBoxContainer.hitTestPoint(e.stageX,e.stageY,true)) || (presenterControls.hitTestPoint(e.stageX,e.stageY,true))){
				wbCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
			}
		}
	}
	else{
		wbCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
	}*/
}

/**
 * This function gets invoked at every 100 milliseconds while drawing free hand/eraser
 * It create a sprite and draw the part of shape by connecting the points catched in the
 * 100 milliseconds interval.
 */
private function drawFreeHandPreview(event:TimerEvent):void{
	if (previewShapePointsArray.length > 0){
		drawFreeHandAndEraser(previewShapePointsArray, userDrawingSprite);
		previewShapePointsArray.splice(0, previewShapePointsArray.length - 1);
	}
}

/**
 *  This function draws the freehand and eraser to the drawing area.
 */
private function drawFreeHandAndEraser(points:Array, parent:Sprite):void{
	var shape:WhiteboardShapeSprite=new WhiteboardShapeSprite();
	parent.addChild(shape);
	applicationType::DesktopWeb{
		if (toolName =="e"){
			//shape.graphics.lineStyle(ERASER_THICKNESS, backgroundColor, lineAlpha);
			shape.graphics.lineStyle(eraserThichness, backgroundColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		}
		else{
			shape.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
		}
	}
	applicationType::mobile{
		//For AVCM: Added to check whether eraser button is enabled.
		if (!isEraserButtonEnabled){
			//shape.graphics.lineStyle(ERASER_THICKNESS, backgroundColor, lineAlpha);
			shape.graphics.lineStyle(eraserThichness, backgroundColor, lineAlpha,false,LineScaleMode.NORMAL,CapsStyle.SQUARE); 
		}
		else{
			shape.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
		}
	}
	var i:uint;
	//shape.name=whiteboardShape.shapeName;
	var minimumXY:Point=WhiteboardShape.findMinimumXY(points);
	shape.graphics.moveTo(points[0].x - minimumXY.x, points[0].y - minimumXY.y);
	for (i=1; i < points.length; i++){
		shape.graphics.lineTo(points[i].x - minimumXY.x, points[i].y - minimumXY.y);
	}
	shape.x=minimumXY.x;
	shape.y=minimumXY.y;
	if (parent == drawingArea){
		shape.name=whiteboardShape.shapeName;
	}
	
}


/**
 * Invoked when user select a text box. The text box is added to the
 * object handle, create and populate the shape object out of the
 * selected text box.
 */
private function onTextSelect(evnt:MouseEvent):void{
	applicationType::DesktopWeb{
		evnt.stopImmediatePropagation();
		selectText(evnt.currentTarget as MoveableTextArea);
		
	}
}

applicationType::DesktopWeb{
	private function selectText(object:MoveableTextArea):void
	{
		textAreaEditable=true;
		removeSelection(true);
		if (toolName != "txt"){
			previousTool=toolName;
			setCurrentTool("txt");
		}
		
		
		if (movableTextArea){
			commitText();
			textAreaEditable=true
		}
		createShapeObject();
		objectHandleForTextArea.addEventListener(ObjectChangedEvent.OBJECT_MOVED, onObjectMovedHandler);
		objectHandleForTextArea.addEventListener(ObjectChangedEvent.OBJECT_RESIZED, onObjectResizeddHandler);
		movableTextArea=object;
		movableTextArea.removeEventListener(MouseEvent.MOUSE_DOWN, onTextSelect);
		whiteboardShape.shapeName=movableTextArea.name;
		var shapePoint:Shapepoint=new Shapepoint();
		shapePoint.x=movableTextArea.x
		shapePoint.y=movableTextArea.y
		whiteboardShape.shapePoints.push(shapePoint);
		whiteboardShape.toolName="txt";
		addObjectHandleConstraints(objectHandleForTextArea);
		
		dataModelForTextArea.x=movableTextArea.x;
		dataModelForTextArea.y=movableTextArea.y;
		//movabeTextArea.setStyle("contentBackgroundAlpha","0");
		movableTextArea.setStyle("color", uint(lineColor));
		movableTextArea.setStyle("contentBackgroundAlpha", 1);
		//movabeTextArea.setStyle("fontSize",textFondStepper.value);
		movableTextArea.setStyle("borderVisible", true);
		movableTextArea.selectable=true;
		movableTextArea.editable=true;
		movableTextArea.focusEnabled=true;
		dataModelForTextArea.width=movableTextArea.width;
		dataModelForTextArea.height=movableTextArea.height;
		dataModelForTextArea.text=movableTextArea.text;
		dataModelForTextArea.name=movableTextArea.name;
		dataModelForTextArea.drawnBy=movableTextArea.drawnBy;
		movableTextArea.model=dataModelForTextArea;
		textContentWhenSelected=movableTextArea.text;
		//wbCanvas.addElement(movabeTextArea);
		movableTextArea.setFocus();
		objectHandleForTextArea.registerComponent(dataModelForTextArea, movableTextArea, handlesForTextArea);
		objectHandleForTextArea.selectionManager.setSelected(dataModelForTextArea);
		
	}
	
	/**
	 * Invoked when user select a shape. The shape is added to the
	 * object handle so that the user can manipulate it.
	 */
	private function onShapeSelect(evnt:MouseEvent):void{
		evnt.stopImmediatePropagation();
		removeSelection(true);
		selectShape(evnt.target as WhiteboardShapeSprite);
		//var shape:WhiteboardShapeSprite=evnt.target as WhiteboardShapeSprite;
	}
	
	private function selectShape(shape:WhiteboardShapeSprite):void
	{
		objectHandleForShape.registerComponent(shape, shape, handlesForShapes);
		objectHandleForShape.selectionManager.setSelected(shape);
		objectHandleForShape.addEventListener(ObjectChangedEvent.OBJECT_MOVED, onObjectMovedHandler);
	}
	/**
	 * Invoked when the presenter resizes the text box.
	 */
	private function onObjectResizeddHandler(evnt:ObjectChangedEvent):void{
		var index:int=getShapeIndex(evnt.relatedObjects[0].name);
		if (index >= 0){
			shapeSelectionCollaborationObject.setValue(evnt.relatedObjects[0].name + "_resize", 
				{action: "resize", shapeName: evnt.relatedObjects[0].name, 
					newWidth: evnt.relatedObjects[0].width, newHeight: evnt.relatedObjects[0].height,
					newX:evnt.relatedObjects[0].x,newY:evnt.relatedObjects[0].y,pageNum:whiteboardShapeArray[index].pageNo
				});
		//Bug #15652. At the time of resize, change the textbox position also. Passing coardinates also as value.
		}
	}
	
	/**
	 * Invoked when presenter moves a shape or text box after selecting it.
	 */
	private function onObjectMovedHandler(evnt:ObjectChangedEvent):void{
		var index:int=getShapeIndex(evnt.relatedObjects[0].name);
		if (index >= 0){
			//Before passing the reposition info, calculate the new location in its own (objects) base width and hight. 
			//Otherwise the position will be passed based on wbCanvas width and height. 
			var newX:int = evnt.relatedObjects[0].x * whiteboardShapeArray[index].drawnAreaWidth / wbCanvas.width;
			var newY:int = evnt.relatedObjects[0].y * whiteboardShapeArray[index].drawnAreaHeight / wbCanvas.height;
		
			shapeSelectionCollaborationObject.setValue(evnt.relatedObjects[0].name + "_reposition", {action: "reposition", shapeName: evnt.relatedObjects[0].name, 
				newX: newX, newY: newY, 
				drawnAreaWidth: whiteboardShapeArray[index].drawnAreaWidth,
				drawnAreaHeight: whiteboardShapeArray[index].drawnAreaHeight,
				pageNum:whiteboardShapeArray[index].pageNo
			});
		}
	}

	/**
	 * Close and clean the whiteboard custom context menu.
	 */
	private function onRightClickMenuClose(evnt:MenuEvent):void{
		rightClickMenu.removeEventListener(MenuEvent.MENU_HIDE, onRightClickMenuClose);
		rightClickMenu.removeEventListener(MenuEvent.ITEM_CLICK, onRightClickMenuSelect);
		rightClickMenu=null;
	}

	/**
	 * Invoked when user select one item from the whiteboard custom context menu.
	 */
	private function onRightClickMenuSelect(evnt:MenuEvent):void{
		switch (evnt.label){
			case exportPageContextMenuItemLabel:
				selectFolderForExporting(false);
				
				break;
			
			case importPageContextMenuItemLabel:
				if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
					MessageBox.show("The user is not connected to the server", "WARNING", MessageBox.MB_OK, whiteboardBaseCanvas);
					return;
				}
				browseTheFile();
				break;
			case exportImageContextMenuItemLabel:
				selectFolderForExporting(true);
				
				break;
			case importImageContextMenuItemLabel:
				//selectFolderForExporting();
				
				break;
			case showCollaboratorContexttMenuItemLabel:
				//If presenter has selected the show collaboration option. If he selected
				//this "Show Collaborators" option it will be preceeded by a tick mark.
				if (evnt.itemRenderer.data.toggled){
					showCollaborator=true;
					showCollaboratorNames();
				}
				else{
					showCollaborator=false;
					hideCollaboratorNames();
				}
				
				break;
			case pasteContexttMenuItemLabel:
				pasteText();
				break;
			
		}
	}
	
	/**
	 * Show/Hide the whiteboard custom context menu.Also it enable/disable the
	 * menu item based on the privilege.
	 */
	private function handleContextMenu(evnt:MouseEvent):void{
		if (rightClickMenu == null){
			var index:int;
			rightClickMenu=Menu.createMenu(wbCanvas, rightClickMenuDp, true);
			rightClickMenu.addEventListener(MenuEvent.MENU_HIDE, onRightClickMenuClose);
			rightClickMenu.addEventListener(MenuEvent.ITEM_CLICK, onRightClickMenuSelect);
			index=getMenuItemIndex(pasteContexttMenuItemLabel);
			
			applicationType::desktop{
				if (index > -1 && Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
					// for all users who has writing permisiion
					//Change #16400
					if (toolBoxContainer.visible){
						rightClickMenuDp[index].enabled=true;
					}
					else{
						rightClickMenuDp[index].enabled=false;
					}
				}
				else if (index > -1 && !Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
					rightClickMenuDp[index].enabled=false;
				}
			}
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				
				enableMenuItems(true);
			}
			else{
				enableMenuItems(false);
			}
			
			xPos=wbCanvas.mouseX;
			yPos=wbCanvas.mouseY;
			var _xPos:Number=evnt.stageX;
			var _yPos:Number=evnt.stageY;
			//Set the x position of the menu so that it should not go beyond
			//the whiteboard area.
			if (xPos + 150 > wbCanvas.width){
				_xPos=evnt.stageX + (wbCanvas.width - xPos) - 150;
			}
			//Set the x position of the menu so that it should not go beyond
			//the whiteboard area.
			if (yPos + 60 > wbCanvas.height){
				_yPos=evnt.stageY + (wbCanvas.height - yPos) - 60;
			}
			
			rightClickMenu.show(_xPos, _yPos);
		}
		else{
			rightClickMenu.hide();
			handleContextMenu(evnt);
		}
	}
	
	/**
	 * Enable/Disable the menu item based on the privilege.
	 */
	private function enableMenuItems(isPresenter:Boolean):void{
		var index:int;
		index=getMenuItemIndex(exportPageContextMenuItemLabel);
		if (index > -1){
			rightClickMenuDp[index].enabled=isPresenter;
		}
		index=getMenuItemIndex(importPageContextMenuItemLabel);
		if (index > -1){
			rightClickMenuDp[index].enabled=isPresenter;
		}
		//Bug# 14628, 14627
		//PNCR: enable/disable for export/import images
		index=getMenuItemIndex(exportImageContextMenuItemLabel);
		if (index > -1){
			rightClickMenuDp[index].enabled=isPresenter;
		}
		index=getMenuItemIndex(importImageContextMenuItemLabel);
		if (index > -1){
			rightClickMenuDp[index].enabled=isPresenter;
		}
		
		index=getMenuItemIndex(showCollaboratorContexttMenuItemLabel);
		if (index > -1){
			rightClickMenuDp[index].enabled=isPresenter;
			if (showCollaborator == false){
				rightClickMenuDp[index].toggled=false;
			}
		}
		
	}
	
	/**
	 * Return the index of a menu item.
	 */
	private function getMenuItemIndex(menuItemLabel:String):int{
		var index:int=-1;
		for (var i:uint=0; i < rightClickMenuDp.length; i++){
			if (rightClickMenuDp[i].label == menuItemLabel){
				index=i;
				break;
			}
		}
		return index;
	}
}
/**
 * Paste the clipboard content(text) to the text box. If not text box is under selection,
 * it creates a new text box and add the text to it. Also it sets the position and size
 * of the the text box so that it never go beyond the drawing area.
 */
public function pasteText(isKeyboardShortCut:Boolean=false):void{
	applicationType::desktop{
		clearTimeout(pasteSetTimeOutId);
		var text:String=Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT).toString();
	}
	applicationType::web{
		if (!isKeyboardShortCut){
			var text:String=Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT).toString();
		}
	}
	applicationType::DesktopWeb{
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("The user is not connected to the server", "WARNING", MessageBox.MB_OK, whiteboardBaseCanvas);
			return;
		}
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("The user is not connected to the server","WARNING",MessageBox.MB_OK,whiteboardBaseCanvas,null,null,MessageBox.IC_INFO);
			return;
		}
		var text:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT).toString(); 
	}
	applicationType::DesktopWeb{
		//PNCR: Disable all active object selection before pasting a new text. If there is already a text area is selected then paste inside that (Do not disable that selection). 
		if (!movableTextArea) 
			disableObjectSelection();
     }
	
	if (toolName != "txt"){
		previousTool=toolName;
	}
	setCurrentTool("txt");
	applicationType::DesktopWeb{
		if (movableTextArea == null){
			applicationType::desktop{
				//Fix for issue #10735
				var maxAvailableWidth:Number=wbCanvas.width - 50;
				var maxAvailableHeight:Number=wbCanvas.height - 40;
				var uiText:UITextField=new UITextField();
				uiText.setStyle("fontSize", 12);
				uiText.text=text
				var textW:Number=uiText.textWidth;
				var textH:Number=uiText.textHeight;
				
				if (isKeyboardShortCut){
					xPos=wbCanvas.mouseX;
					yPos=wbCanvas.mouseY;
				}
				
				if (textW > maxAvailableWidth){
					textH=Math.ceil(textH * (textW / maxAvailableWidth));
					textW=maxAvailableWidth;
					xPos=20;
				}
				else if (xPos + textW > maxAvailableWidth){
					xPos=xPos - (xPos + textW - maxAvailableWidth);
				}
				
				if (textH > maxAvailableHeight){
					textH=maxAvailableHeight;
					yPos=15;
				}
				else if (yPos + textH > maxAvailableHeight){
					yPos=yPos - (yPos + textH - maxAvailableHeight);
					
				}
			}
			createTextArea(textW + 25, textH + 20);
			createShapeObject()
			var shapePoint:Shapepoint=new Shapepoint();
			whiteboardShape.shapePoints.push(shapePoint);
			
		}
		//PNCR: added an extra null value checking condition. If the textarea is creating for first time then set the value from Data model.
		//#BugFix: 14919
		if (isKeyboardShortCut && movableTextArea.text!="" ){
			dataModelForTextArea.text=movableTextArea.text;
		}
		else{
			applicationType::desktop{
				dataModelForTextArea.text=dataModelForTextArea.text + text;
			}
			//Fix for issue #17254
			applicationType::web{
				dataModelForTextArea.text=dataModelForTextArea.text + StringUtil.trim(text);
			}
		}
		movableTextArea.selectRange(movableTextArea.text.length, movableTextArea.text.length);
		movableTextArea.setScrollOnBegining();
	}
	applicationType::mobile{
		textComp = new MobileTextToolComponent();
		textComp.open(wbCanvas);
		textComp.isPopUp = true;
		PopUpManager.centerPopUp(textComp);
		textComp.textCompX = textComp.x;
		textComp.textCompY = textComp.y;
		textComp.maxHeight = wbCanvas.height/2;
		textComp.maxWidth = wbCanvas.width/2;
		textComp.txtToolArea.text = text;
		textComp.addEventListener(PopUpEvent.CLOSE,commitMobileAppText);
		textComp.setFocus();
		isPasteActive = true;
	}
	//#BugFix: 14918
	//PNCR: clear the undo shape history. After pasting a text, should not be possible to redo any previous undo shapes.
	//Added this condition to match functionality with other tool selections. 
	deleteUndoShapes();
	//PNCR: Bug #15119. On text paste a new object selection created. Set selectionmode flag to true, then only on the next button selection it will commit.
	//isSelectionMode =true;
}

/**
 * Displays the name of the author/creater of each shapes.
 */
public function showCollaboratorNames():void{
	//Bug #15163. Added a condition to check whether the whiteboard is clear or not.
	if (!isWhiteboardClear()){
		for (var i:uint=0; i < whiteboardShapeArray.length; i++){
			if (whiteboardShapeArray[i].shapePoints.length > 0){
				showCollaboratorForShape(whiteboardShapeArray[i])
			}
		}
	}
}

/**
 * Function to check whether any object is present in whiteboard or not. 
 */
private function isWhiteboardClear():Boolean{
	//TODO: This function has to be changed to check drawingArea.numChildren>0. For that, required to remove the mousepointer from the drawing area.
	var clear:Boolean = true;
	for (var i:uint=0; i < whiteboardShapeArray.length; i++){
		if (whiteboardShapeArray[i].shapePoints.length > 0){
			if (isDrawingVisible(whiteboardShapeArray[i].shapeName))
				clear = false;
		}
	}
	return clear
}
/**
 * Function to check whether a particular shapename is already visible in the drawing area.
 */
private function isDrawingVisible(shapeName:String):Boolean{
	return (drawingArea.getChildByName(shapeName)!=null ? true : false) 
}

/**
 * Hides the name of the author/creater of each shapes.
 */
public function hideCollaboratorNames():void
{
	//#Bug fix: 14626	
	//PNCR: Changed property from child to element.
	/*for (var i:int=wbCanvas.numChildren - 1; i > 0; i--){
		if (wbCanvas.getChildAt(i) is Text){
			wbCanvas.removeChildAt(i);
		}
	}*/
	applicationType::DesktopWeb{
		for (var i:int=wbCanvas.numElements - 1; i > 0; i--){
			if (wbCanvas.getElementAt(i) is Text){
				wbCanvas.removeElementAt(i);
			}
		}
	}
	applicationType::mobile{
		for(var i:int=wbCanvas.numChildren-1;i>0;i--){
			if( wbCanvas.getChildAt(i) is Label){
				wbCanvas.removeElementAt(i);
			}
		}
	}
}

/**
 * Shows the file System file browser window.
 */
private function browseTheFile():void{
	applicationType::DesktopWeb{
		var txtFilter:FileFilter=new FileFilter("Whiteboard Files(*.awb)", "*.awb");
		
		applicationType::desktop{
			var fileReference:File=new File();
		}
		applicationType::web{
			fileReference=new FileReference();
		}
		fileReference.browse([txtFilter]);
		fileReference.addEventListener(IOErrorEvent.IO_ERROR, errorOnSelectFileHandler);
		fileReference.addEventListener(Event.SELECT, onSelectFileHandler);
	}
}

/**
 * Preview the shapes from the imported page to the user.
 * Get user confirmation for committing the shapes
 */
private function previewShapesFromPage():void{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
		//Iterate the shape array for the imported page and remove the 
		//items taht are not actual shapes(like cleared, clear and restore)
		//and also remove all the shapes bfore clear operation if it is not following a restore operation
		for (var i:int=0; i < shapeArrayFromImportedPage.length; i++){
			
			shapeArrayFromImportedPage[i].isRecorded=false;
			shapeArrayFromImportedPage[i].drawnBy=ClassroomContext.userVO.userName
			shapeArrayFromImportedPage[i].drawnAreaWidth=wbCanvas.width;
			shapeArrayFromImportedPage[i].drawnAreaHeight=wbCanvas.height
			shapeArrayFromImportedPage[i].pageNo=pageNumber;
			if (shapeArrayFromImportedPage[i].toolName == "cleared"){
				shapeArrayFromImportedPage.splice(i, 1);
				i--;
				
			}
				//if current shape's toolName is clear and next shape is not a type of restore
			else if (shapeArrayFromImportedPage[i].toolName == "clear" && (i == shapeArrayFromImportedPage.length - 1 || shapeArrayFromImportedPage[i + 1].toolName != "restore")){
				// if its a last shape, delete the complete array; take the rest shapes otherwise
				if (i == shapeArrayFromImportedPage.length - 1){
					shapeArrayFromImportedPage.splice(0);
					break;
				}
				else{
					shapeArrayFromImportedPage=shapeArrayFromImportedPage.slice(i + 1);
					i=-1;
					
				}
			}
				//if current shape's toolName is clear and next shape is a type of restore ,delete the two shapes.
			else if (i < shapeArrayFromImportedPage.length - 1 && shapeArrayFromImportedPage[i].toolName == "clear" && shapeArrayFromImportedPage[i + 1].toolName == "restore"){
				shapeArrayFromImportedPage.splice(i, 2);
				i--;
				
			}
		}
		removeShapes();
		drawShapes(true);
		//PNCR: added seperate event handler for yes and no. //#BugFix: #14622
		previewAlert=MessageBox.show("By selecting 'Yes' button these shapes will send to all viewers, Do you want to continue?", "Confirmation", MessageBox.MB_YESNO, this.parent as Sprite, acceptPreviewConfirmation, declinePreviewConfirmation);
		
	}
	else{
		MessageBox.show("Unable to do the operation since moderator had released your presenter role.", "Info", MessageBox.MB_OK, whiteboardBaseCanvas);
	}
	
	
}

/**
 * Get the input from the user whether to proceed with the preview of
 * the imported page.
 */
private function acceptPreviewConfirmation(evnt:MessageBoxEvent):void{
	previewAlert=null;
	if (evnt.type == MessageBoxEvent.MESSAGEBOX_YES){
		/*
		instead of calling clearScratchPad() which calls server-side method 'addGraphic' and a series of server-side method calls using the while-loop below,
		importPage() method is used which calls a single method on the server-side.
		All the necessary code from clearScratchPad() method is added to importPage() and also the while-loop logic.
		closeAllOPenPannels() method from clearScratchPad() is pulled-out and inserted below (and before removeShapes and drawShapes).
		It cannot be added to importPage() since that would close all panels after drawing the shapes.
		Series of calls to the server causes syncing problems.
		*/
		/*if(whiteboardShapeArray.length>0){
		clearWhenImporting=true;
		clearScratchPad()
		}*/
		closeAllOpenPannels();
		removeShapes();
		drawShapes(true);
		importPage();
		//Fix for issue #19882
		applicationType::web{
			btnFreehand.setFocus();
		}
		/*while(shapeArrayFromImportedPage.length>0){
		var splicedShapeaArray:Array=shapeArrayFromImportedPage.splice(0,1);
		shapeCollaborationObject.addValue(splicedShapeaArray[0]);
		}*/
	}
	/*else if (evnt.type == MessageBoxEvent.MESSAGEBOX_NO){
		removePreviewShapesFromPage();
		drawShapes();
	}*/
}

/**
 * Function to decline messagebox and show the previous image on window.
 */
private function declinePreviewConfirmation(evnt:MessageBoxEvent):void{
	//PNCR: #Bugfix:15094. Changed previewAlert to null, unless it will again ask at the time of popin.
	previewAlert=null;
	if (evnt.type == MessageBoxEvent.MESSAGEBOX_NO){
		removePreviewShapesFromPage();
		drawShapes();
	}
}
/**
 * Send the imported page details to the server to be set in the shared object.
 * Before the importing a page, it has to clear the whiteboard.
 */
private function importPage():void{
	clearWhenImporting=true;
	toggleClearRestore(true)
	var shapeObj:WhiteboardShape=createClearGarphic();
	//PNCR: Changed from netConnection to shared object. //#BugFix: #14622
	shapeCollaborationObject.addValue(shapeObj);
	for (var i = 0; i < shapeArrayFromImportedPage.length; i++)
	{
		//PNCR: add a shapeid in sequantial order after the clear object. in the import page it may differ. 
		shapeArrayFromImportedPage[i].shapeId=currentShapeId++;
		shapeCollaborationObject.addValue(shapeArrayFromImportedPage[i]);
	}
		
	/*
	//called from the client when a page is imported
	//	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("importPage", null, shapeObj, shapeArrayFromImportedPage, ClassroomContext.lecture.lectureName + "|" + pageNumber);
	client.importPage = function(clearGraphic, importedGraphics, lecturePageNum)
	{
	
	c_n = "importPage, " + this.ip+":"+lecturePageNum;
	avc_logging("Entered Function",c_n,T_DEBUG);
	Client.prototype.addGraphic(clearGraphic, lecturePageNum);
	for (var i = 0; i < importedGraphics.length; i++)
	{
	Client.prototype.addGraphic(importedGraphics[i], lecturePageNum);
	}
	}*/
}
/**
 * Clear all the existing shapes and set current shapeid to 1 before import a page.
 * Otherwise on import unnecessarly all the existing shapes will send to FMS with a "clear page" action. 
 * By clearing the shape array can avoid sending the unnecessary old shapes. 
 */
private function clearShapesBeforeImporting():void{
	whiteboardShapeArray.splice(0);
	currentShapeId=1;
}

/**
 * Removed the shapes drawn as part of preview an imported page.
 */
private function removePreviewShapesFromPage():void{
	for (var i:uint=0; i < shapeArrayFromImportedPage.length; i++){
		var child:DisplayObject =  drawingArea.getChildByName(shapeArrayFromImportedPage[i].shapeName)
		if (child)
			drawingArea.removeChild(child);
		
	}
	if (showCollaborator){
		hideCollaboratorNames();
		showCollaboratorNames()
	}
}

/**
 * Handle the error while reading an imported file.
 */
private function errorOnSelectFileHandler(event:Event):void{
	MessageBox.show("Some error hapened while opening.", "Error", MessageBox.MB_OK);
}

/**
 * Get invoked when user select a file for importing.
 */
private function onSelectFileHandler(event:Event):void{
	applicationType::desktop{
		var file:File=event.target as File;
		// if user select the file of type wb read the file  and convert it ini array of shapes
		if (file.name.substr(-4, 4) == ".awb"){
			var biteArray:ByteArray=new ByteArray();
			var fileStream:FileStream=new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(biteArray, 0, fileStream.bytesAvailable);
			fileStream.close();
			try{
				var xmlShapesFromFile:XML=XML(biteArray);
				shapeArrayFromImportedPage=convertXmlToObjects(xmlShapesFromFile, true);
				previewShapesFromPage();
			}
			catch(myError:Error) { 
				MessageBox.show("Please select a valid file.. ", "Warning", MessageBox.MB_OK);
			} 
		}
		else{
			MessageBox.show("Please select a valid file.. ", "Warning", MessageBox.MB_OK);
		}
	}
	applicationType::web{
		//Load whiteboard drawings from local machine using FileReference.load() method.
		if (event.target.type == ".awb"){
			fileReference.addEventListener(Event.COMPLETE, onWBLoadComplete);
			fileReference.load();
		}
		else{
			MessageBox.show("Please select a valid file.. ", "Warning", MessageBox.MB_OK);
		}
	}
}

/**
 * The function is the complete handler for fileReference.
 * This function is called after the Whiteboard drawings load complete handler.
 * @param event
 * @return void
 */
applicationType::web{
	private function onWBLoadComplete(event:Event):void{
		var byteS:ByteArray=fileReference.data;
		var xmlShapesFromFile:XML=XML(byteS);
		shapeArrayFromImportedPage=convertXmlToObjects(xmlShapesFromFile, true);
		previewShapesFromPage();
	}
}

/**
 * Invoked while user  select the option for exporting the current page as image.
 */
private function exportPageAsImage(event:Event):void{
	event.target.removeEventListener(Event.SELECT, exportPageAsImage);
	//JHCR: Try to combine these function calls by assigning a null value to the first parameter(file), it can be an optional paramenter 
	applicationType::desktop{
		exportPage(event.target as File, ".jpg");
	}
	//No file property available for web, so we pass file extension
	applicationType::web{
		exportPage(".jpg");
	}
}

/**
 * Exports the the whiteboard  page as image. It Check whether the file name is following the
 * proper extention and  also check wheter a file with same name is existing.
 */
//JHCR: Try to combine these functions
applicationType::web{
	private function exportPage(extention:String):void{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			//Directly invoke function saveExportedFile()
			saveExportedFile(extention);
		}
		else{
			MessageBox.show("Unable to do the operation since moderator had released your presenter role.", "Info", MessageBox.MB_OK, whiteboardBaseCanvas)
		}
	}
}
applicationType::desktop{
	private function exportPage(targetFile:File, extention:String):void{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			
			var selectedFileName:String=targetFile.name;
			if (selectedFileName.substr((-(extention.length)), extention.length) != extention && targetFile.exists){
				CustomAlert.customMessage("Please select an awb file to export the whiteboard page.", "Info", Alert.OK, whiteboardBaseCanvas)
				return;
			}
			if (targetFile.exists && selectedFileName.substr((-(extention.length)), extention.length) == extention){
				saveExportedFile(targetFile, extention);
				return;
			}
			var filePath:String=targetFile.nativePath;
			var file:File;
			if (selectedFileName.substr((-(extention.length)), extention.length) != extention){
				filePath=filePath + extention;
			}
			file=new File(filePath);
			if (file.exists){
				MessageBox.show("" + filePath + " already exists. do you want to replace it?", "Info", MessageBox.MB_YESNO, whiteboardBaseCanvas, function(_event:MessageBoxEvent):void{
					saveExportedFile(file, extention, _event);
				});
			}
			else{
				saveExportedFile(file, extention);
			}
		}
		else{
			MessageBox.show("Unable to do the operation since moderator had released your presenter role.", "Info", MessageBox.MB_OK, whiteboardBaseCanvas)
		}
	}
}

/**
 * Invoked when the user selects the option for exporting the whiteboard page as xml.
 */
private function exportPageAsXml(event:Event):void{
	event.target.removeEventListener(Event.SELECT, exportPageAsXml);
	//JHCR: Try to combine these function calls by assigning a null value to the first parameter(file), it can be an optional paramenter
	applicationType::web{
		//No file property available for web so we pass only file extension
		exportPage(".awb");
	}
	applicationType::desktop{
		exportPage(event.target as File, ".awb");
	}
}

/**
 * Write the exported file from memory to disk.
 */
//JHCR: Try to combine these functions
applicationType::web{
	//No file property available for web.
	private function saveExportedFile(extension:String, evnt:MessageBoxEvent=null):void{
		if (evnt == null || (evnt && evnt.type == MessageBoxEvent.MESSAGEBOX_YES)){
			var msgBox:MessageBox=null;
			var biteArray:ByteArray=new ByteArray();
			if (extension == ".awb"){
				//FileReference is used for create a file in local machine.
				fileReference=new FileReference();
				biteArray.writeUTFBytes(getPageXml(pageNumber));
				fileReference.addEventListener(IOErrorEvent.IO_ERROR, errorinExportPage);
				fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				fileReference.save(biteArray, "page" + pageNumber + "_" + ClassroomContext.lecture.lectureName + ".awb");
			}
			else{
				msgBox=MessageBox.show("Image conversion is in progress.Please wait.", "Info", null, wbCanvas);
				var jpgSource:BitmapData=new BitmapData(wbCanvas.width, wbCanvas.height);
				jpgSource.draw(wbCanvas, new Matrix());
				var jpgEncoder:JPGEncoder=new JPGEncoder(80);
				biteArray=jpgEncoder.encode(jpgSource);
				//FileReference is used for create a jpg file in local machine
				(new FileReference()).save(biteArray, "page" + pageNumber + "_" + ClassroomContext.lecture.lectureName + ".png");
			}
			if (msgBox){
				PopUpManager.removePopUp(msgBox);
				msgBox=null;
			}
		}
	}
}
applicationType::desktop{
	private function saveExportedFile(file:File, extension:String, evnt:MessageBoxEvent=null):void{
		if (evnt == null || (evnt && evnt.type == MessageBoxEvent.MESSAGEBOX_YES)){
			var msgBox:MessageBox=null;
			file.addEventListener(IOErrorEvent.IO_ERROR, errorinExportPage)
			var fileStream:FileStream=new FileStream();
			
			var biteArray:ByteArray=new ByteArray();
			if (extension == ".awb"){
				
				//PNCR: this is a patch to solve Bug #15467. The user of property ignoreSync has to recheck again.
				setRequiredObjPropertyForPageExport();
				biteArray.writeUTFBytes(getPageXml(pageNumber));
			}
			else{
				msgBox=MessageBox.show("Image conversion is in progress.Please wait.", "Info", null, wbCanvas);
				var jpgSource:BitmapData=new BitmapData(wbCanvas.width, wbCanvas.height);
				jpgSource.draw(wbCanvas, new Matrix());
				var jpgEncoder:JPGEncoder=new JPGEncoder(80);
				biteArray=jpgEncoder.encode(jpgSource);
				
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(biteArray, 0, biteArray.length);
			fileStream.close();
			if (msgBox){
				PopUpManager.removePopUp(msgBox);
				msgBox=null;
			}
		}
	}
}

/**
 * Function to set object propertied before export page.
 */
private function setRequiredObjPropertyForPageExport():void{
	for (var i:uint=0; i < whiteboardShapeArray.length; i++){
		//By default the existing objects ignoreSync property will be true. If so while exporting it will store as it is.
		//When import the same page it will not sync with other viewers. To avoid that set the property false.
		whiteboardShapeArray[i].ignoreSync = false;
	}
}

/**
 * //Progress handler for FileReference.
 */
applicationType::web{
	private function progressHandler(event:Event):void{
		if (event.target.type != ".awb"){
			fileReference.cancel();
			MessageBox.show("Please save file with .awb extention.", "Info", null, wbCanvas);
			return;
		}
	}
}

/**
 * Handles the File IO error while writing the exported page to disk.
 */
private function errorinExportPage(evnt:IOErrorEvent):void{
	MessageBox.show("Some error happened during the save operation", "Error", MessageBox.MB_OK, whiteboardBaseCanvas);
}

/**
 * Show the system file browser window for selecting the location for
 * saving the exporting file.
 */
private function selectFolderForExporting(asImage:Boolean):void{
	applicationType::desktop{
		try{
			var directorySelector:File
			if (asImage){
				directorySelector=File.documentsDirectory.resolvePath("page" + pageNumber + "_" + ClassroomContext.lecture.lectureName + ".jpg");
				
				directorySelector.addEventListener(Event.SELECT, exportPageAsImage);
			}
			else{
				directorySelector=File.documentsDirectory.resolvePath("page" + pageNumber + "_" + ClassroomContext.lecture.lectureName + ".awb");
				directorySelector.addEventListener(Event.SELECT, exportPageAsXml);
			}
			directorySelector.browseForSave("Save as");
		}
		catch (error:Error){
			MessageBox.show("Error in selecting a folder for exporting..", "Error", MessageBox.MB_OK, whiteboardBaseCanvas);
		}
	}
	applicationType::web{
		//Since there is no file property for web, we directly invoke function exportPage().
		if (asImage){
			exportPage(".jpg");
		}
		else{
			exportPage(".awb");
		}
	}
}

/**
 * Create and initialises a whiteboard shape.
 */
private function createShapeObject():void{
	whiteboardShape=new WhiteboardShape();
	
	whiteboardShape.lineColor=lineColor;
	whiteboardShape.lineThickness=lineThickness;
	whiteboardShape.lineAlfa=lineAlpha
	whiteboardShape.drawnBy=ClassroomContext.userVO.userName
	whiteboardShape.drawnAreaWidth=wbCanvas.width;
	whiteboardShape.drawnAreaHeight=wbCanvas.height
	whiteboardShape.pageNo=pageNumber;
	var date:Date=new Date();
	whiteboardShape.shapeId=currentShapeId;
	whiteboardShape.shapeName=ClassroomContext.userVO.userName + date.time;
	
}

/**
 * Creates and initialises a text box.
 */
private function createTextArea(width:Number=50, height:Number=50):void{
	applicationType::DesktopWeb{
		//Bug #16595
		createObjectHandle();
		addObjectHandleConstraints(objectHandleForTextArea);
		textAreaEditable=true
		movableTextArea=new MoveableTextArea();
		applicationType::web{
			//Added PASTE event for textArea.
			movableTextArea.addEventListener(Event.PASTE, onTextareaPasteEvent);
		}
		movableTextArea.setStyle("contentBackgroundAlpha", "0");
		movableTextArea.setStyle("color", uint(lineColor));
		movableTextArea.setStyle("fontSize", textFondStepper.value);
		dataModelForTextArea.x=xPos;
		dataModelForTextArea.y=yPos;
		dataModelForTextArea.width=width;
		dataModelForTextArea.height=height;
		dataModelForTextArea.text="";
		movableTextArea.model=dataModelForTextArea;
		wbCanvas.addElement(movableTextArea);
		movableTextArea.setFocus();
		objectHandleForTextArea.registerComponent(dataModelForTextArea, movableTextArea, handlesForTextArea);
		objectHandleForTextArea.selectionManager.setSelected(dataModelForTextArea);
	}
}

/**
 * Paste event handler for text box.
 */
applicationType::web{
	private function onTextareaPasteEvent(evnt:Event):void{
		//Fix for issue #10735: Added resize eventListener for text area resize
		movableTextArea.addEventListener(ResizeEvent.RESIZE, onTextAreaResizeHandler);
		dataModelForTextArea.text=movableTextArea.text;
		//Fix for issue #10735
		var uiText:UITextField=new UITextField();
		uiText.setStyle("fontSize", 12);
		uiText.text=movableTextArea.text;
		//Fix for issue #19639
		uiText.width=movableTextArea.width;
		textW=movableTextArea.width;
		textH=movableTextArea.height;
		maxAvailableWidth=wbCanvas.width - 50;
		maxAvailableHeight=wbCanvas.height - 40;
		xPos=wbCanvas.mouseX;
		yPos=wbCanvas.mouseY;
		//Fix for issue #19639
		dataModelForTextArea.width=uiText.textWidth;
		dataModelForTextArea.height=50;//movableTextArea.height;
	}
}

/**
 * Text area resize handler function.
 * Fix for issue #10735.
 */
applicationType::web{
	private function onTextAreaResizeHandler(event:ResizeEvent):void{
		//Fix for issue #10735
		if (textW > maxAvailableWidth){
			textH=Math.ceil(textH * (textW / maxAvailableWidth));
			textW=maxAvailableWidth;
			xPos=20;
		}
		else if (xPos + textW > maxAvailableWidth){
			xPos=xPos - (xPos + textW - maxAvailableWidth);
		}
		if (textH > maxAvailableHeight){
			textH=maxAvailableHeight;
			yPos=15;
		}
		else if (yPos + textH > maxAvailableHeight){
			yPos=yPos - (yPos + textH - maxAvailableHeight);
		}
		//Fix for issue #19639
		dataModelForTextArea.x=movableTextArea.x;
		dataModelForTextArea.y=movableTextArea.y;
		dataModelForTextArea.width=movableTextArea.width;
		dataModelForTextArea.height=movableTextArea.height;
	}
}

/**
 * Mouse down event handler for drawing area. It intiates the drawing of a shape by
 * getting the start point.
 */
private function drawingAreaMouseDownHandler(event:MouseEvent):void{
	
	//If user start writing then stop garbage collection call. Otherwise it will affect the cpu memory.
	garbageCollection.stopGarbageCollectionTimer();
	//Moved from enableDrawing() to here. to avoid Bug #15546
	if (!wbCanvas.hasEventListener(MouseEvent.ROLL_OUT)){
		wbCanvas.addEventListener(MouseEvent.ROLL_OUT, scratchAreaMouseOutHandler);
	}
	
	applicationType::DesktopWeb{
		//For new exit option
		FlexGlobals.topLevelApplication.mainApp.application_clickHandler();
		if (event.target is SpriteHandle || (movableTextArea && event.target is RichEditableText)){
			return;
		}
	}
	drawingArea.setFocus();
	applicationType::DesktopWeb{
		try{
			if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
				MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
				return;
			}
		}
		catch (e:Error){
			logger.info("Error on mouseclick at the time of reconnection."+e);
			return;
		}
			
		//PNCR: #BugFix: 14973. The double click event should not remove the selection from textarea. For the same text area click the parent is null. 
		if (event.target.parent)
			removeSelection(isSelectionMode);
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING",MessageBox.MB_OK,this,null,null,MessageBox.IC_ALERT);
			return;
		}
	}
	if (!isSelectionMode){
		applicationType::DesktopWeb{
			if (pointerIcon == removePointerIcon && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				showPointer.enabled == false;
				removePointer();
			}
		}
		applicationType::mobile{
			if(FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon == removeMobilePointerIcon &&  FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole ==  Constants.PRESENTER_ROLE){
				isMousePointerEnabled == false;
				removePointer();
			}
		}
		//////////////////////////////////////////////////////////////////////////
		// taking starting position of drawing
		//xPos:This var stores the current mouse x value of one particular drawing 
		xPos=wbCanvas.mouseX;
		//yPos:This var stores the current mouse y value of one particular drawing
		yPos=wbCanvas.mouseY;
		//startX:This var stores the starting mouse x value of one particular drawing  
		startX=wbCanvas.mouseX;
		//startY:This var stores the starting mouse y value of one particular drawing  
		//WARNIG: in this fuction starting mouse points and current mouse points are same
		startY=wbCanvas.mouseY;
		closeAllOpenPannels();
		/* When a user types into the number field of the numeric stepper
		and then goes to draw, the focus remains in the stepper field
		and no changeLineThickness event occurs.
		So, just in case the text field still has focus in the Numeric stepper,
		change the focus: */
		
		// create new sprite object for drawing new shape and add it to the main sprite(_scratchBase). 
		userDrawingSprite=new WhiteboardShapeSprite();
		
		drawingArea.addChild(userDrawingSprite);
		applicationType::DesktopWeb{
			//if (!btnFreehand.enabled || !btnEraser.enabled){
				//PNCR #BugFix:14795. Changed btnEraser enabled/disabled codes to toolName check.
				if (["fh", "e"].indexOf(toolName) >= 0){
					if (ConfigFileReader.configValues.Whiteboard.EnableLineRenderTimeDelay ==1){
						var delay:Number = ConfigFileReader.configValues.Whiteboard.LineRenderTimeDelayInMillisec;
						drawingPreviewTimer=new Timer(delay,0);
						drawingPreviewTimer.start();
						drawingPreviewTimer.addEventListener(TimerEvent.TIMER,drawFreeHandPreview);
					}
					else if (!btnFreehand.enabled){ //if pencil selected.
						pencil.lineThickness = lineThickness;
						pencil.lineAlpha = lineAlpha;
						pencil.lineColor = lineColor;
						pencil.draw(userDrawingSprite,xPos, yPos,true);
					}
					else{//if eraser is selected
						eraser.thickness = eraserThichness;
						eraser.color = backgroundColor.toString();
						eraser.alpha = lineAlpha;
						eraser.draw(userDrawingSprite,xPos, yPos,true);
					}
					
				}
				else{
					userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				}
			//}
		}	
		applicationType::mobile{
			//Added to check whether eraser button is enabled.
			if(!FlexGlobals.topLevelApplication.whiteBoardTools.btnFreehand.enabled || !isEraserButtonEnabled){
				if (ConfigFileReader.configValues.Whiteboard.EnableLineRenderTimeDelay ==1){
					var delay:Number = ConfigFileReader.configValues.Whiteboard.LineRenderTimeDelayInMillisec;
					drawingPreviewTimer=new Timer(delay,0);
					drawingPreviewTimer.start();
					drawingPreviewTimer.addEventListener(TimerEvent.TIMER,drawFreeHandPreview);
				}
				else if (!FlexGlobals.topLevelApplication.whiteBoardTools.btnFreehand.enabled ){ //if pencil selected.
					pencil.lineThickness = lineThickness;
					pencil.lineAlpha = lineAlpha;
					pencil.lineColor = lineColor;
					pencil.draw(userDrawingSprite,xPos, yPos,true);
				}
				else{//if eraser is selected
					eraser.thickness = eraserThichness;
					eraser.color = backgroundColor.toString();
					eraser.alpha = lineAlpha;
					eraser.draw(userDrawingSprite,xPos, yPos,true);
				}
			}
			else{
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
			}
		}
		createShapeObject();
		var shapePoint:Shapepoint=new Shapepoint();
		whiteboardShape.shapePoints.push(shapePoint);
		//PNCR: added shapename. Else on collaboration object draw time, the object will not identify by name. 
		userDrawingSprite.name = whiteboardShape.shapeName;
		//Add first point to previewArray
		previewShapePointsArray=new Array();
		previewShapePointsArray.push(shapePoint);
		//PNCR: moved toolName assign before if else condition. 
		whiteboardShape.toolName=toolName;
		//Bug #16616. Do not create shape for object selection.
		if (toolName != "txt" && toolName!= "os"){
			shapePoint.x=xPos
			shapePoint.y=yPos
			applicationType::DesktopWeb{
				//Commit text if there is any uncommitted text tool is present.
				//PNCR: Changed the text commit to a function. It is called from other locations also.
				commitUncommitedTexts();
			}
			wbCanvas.addEventListener(MouseEvent.MOUSE_UP, drawingAreaMouseUpHandler);
			if (!wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
				wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
		}
		applicationType::DesktopWeb{
			//PNCR: #BugFix: 14762
			if (toolName == "txt"){
				//PNCR: #BugFix: 14937. Enable clear button if there is text present.
				if (movableTextArea) toggleClearRestore(true);
				checkCommitText(event, false);
			}
		}
		
		applicationType::mobile{
			if(!FlexGlobals.topLevelApplication.whiteBoardTools.btnTextTool.enabled && !isPasteActive){
				if(!txtAreaEdit){	
					createMobileTextComponent();
				}else{
					textComp.updateMsg(true);
					txtAreaEdit = false;
					//To close the soft keyboard if it is exist
					if(isSoftKeyboardActivate){
						textComp.txtToolArea.setFocus();
						isSoftKeyboardActivate = false;
					}
				}
			}
		}
	}
}

/**
 * Function to commit the uncommited texts, if there is any text item is present.
 *
 */
private function commitUncommitedTexts():void{
	applicationType::DesktopWeb{
		if (movableTextArea){
			whiteboardShape.toolName="txt";
			commitText();
			//PNCR: #BugFix: 14966
			//Revert back to currently selected tool after commit the text. 
			whiteboardShape.toolName = toolName;
		}
	}
}
/**
 * This function desides whether to create a text box or committing the current text box
 * when user click on the drawing are.
 */
private function checkCommitText(event:MouseEvent, isObjectSelection:Boolean):void{
	applicationType::DesktopWeb{
		//If no text box is active, create a new text box.
		if (!textAreaEditable){
			createTextArea();
		}
			//Check whether the user click outside the current text box and commit it. //event.target != movabeTextArea &&
		else if (
			(event.target == drawingArea || 
				(event.target != drawingArea && movableTextArea && event.target.parent && 
					!(event.target.parent.parentDocument.parent is MoveableTextArea) && objectHandleForTextArea && 
					!(event.target is SpriteHandle)
				)
			) 
			&& movableTextArea && textAreaEditable
		){
			commitText(isObjectSelection);
			
		}
	}
}

/**
 * Set the minimum height and width  for text box.
 */
public function lockTextArea(width:Number, height:Number):void{
	applicationType::DesktopWeb{
		var constraint:SizeConstraint=new SizeConstraint();
		constraint.minWidth=width;
		//constraint.maxWidth = 200;
		constraint.minHeight=height;
		//constraint.maxHeight = 200;
		if (objectHandleForTextArea)
			objectHandleForTextArea.changeDefaultSizeeConstraint(constraint);
	}
}

/**
 * Creates the mouse pointer shape.
 */
private function createMousePointer():void{
	pointerIcon=removePointerIcon;
	applicationType::mobile{
		FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon = removeMobilePointerIcon;
	}
	pointerShape=new Shape();
	pointerShape.graphics.beginFill(0xFF0000, .5);
	pointerShape.graphics.lineStyle(1, 0xFF0000, .5);
	pointerShape.graphics.drawCircle(3, 3, 3);
	pointerShape.graphics.endFill();
	drawingArea.addChild(pointerShape);
	pointerShape.x=wbCanvas.mouseX - 3;
	pointerShape.y=wbCanvas.mouseY - 3;
}

/**
 * Mouse move event handler for drawing area. We draw the shape and save each point in mouse move and save in the shape object
 */
private function drawingAreaMouseMoveHandler(event:MouseEvent):void{
	//Add the following code for reducing the flickering
	event.updateAfterEvent();
	//If user select  mouse pointer sharing then send each mouse points to all users
	//while user moves the mouse.
	var shapePoint:Shapepoint
	//JH: We can avoid this check if we have a separate eventListener for pointer
	//Bug #17573. Commented the disable condition for selectobject+pointer move.
	//if (!isSelectionMode){
		handleMousePointer();
	//}
	//JH: We can avoid this check also if we have a separate eventListener for pointer
	if (wbCanvas.hasEventListener(MouseEvent.MOUSE_UP)){
		applicationType::DesktopWeb{
			// draw free hand
			//PNCR: commented because erase button dont have enable or disable.
			//if (!btnFreehand.enabled || !btnEraser.enabled){
			if (["fh","e"].indexOf(toolName)>=0){
				shapePoint=new Shapepoint()
				shapePoint.x=wbCanvas.mouseX;
				shapePoint.y=wbCanvas.mouseY;
				whiteboardShape.shapePoints.push(shapePoint);
				if (ConfigFileReader.configValues.Whiteboard.EnableLineRenderTimeDelay ==1){
					//Add points/shapes to previewArray to draw points in 100ms together
					previewShapePointsArray.push(shapePoint);
				}
				else{
					var drawObject = (toolName=="fh" ? pencil : eraser ); 
					drawObject.draw(userDrawingSprite,wbCanvas.mouseX,wbCanvas.mouseY,false)
				}
			}
				// draw straight line
			else if (toolName=="st"){
				//Clear the shapes drawn on the _scratchSurface
				userDrawingSprite.graphics.clear();
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingSprite.graphics.moveTo(startX, startY);
				userDrawingSprite.graphics.lineTo(wbCanvas.mouseX, wbCanvas.mouseY);
			}
				// draw rectangle
			else if (toolName == "r"){
				//Clear the shapes drawn on the _scratchSurface
				userDrawingSprite.graphics.clear();
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingSprite.graphics.moveTo(startX, startY);
				userDrawingSprite.graphics.drawRect(startX, startY, (wbCanvas.mouseX - startX), (wbCanvas.mouseY - startY));
			}
				// Draw circle
			else if (toolName == "c"){
				//Clear the shapes drawn on the _scratchSurface
				userDrawingSprite.graphics.clear();
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingSprite.graphics.moveTo(startX, startY);
				userDrawingSprite.graphics.drawCircle(startX, startY, Math.sqrt(Math.pow((wbCanvas.mouseX - startX), 2) + Math.pow((wbCanvas.mouseY - startY), 2)));
			}
		}
		applicationType::mobile{
			// draw free hand
			if (["fh","e"].indexOf(toolName)>=0 && !FlexGlobals.topLevelApplication.whiteBoardTools.btnFreehand.enabled || !isEraserButtonEnabled)
			{
				shapePoint=new Shapepoint()
				shapePoint.x=wbCanvas.mouseX;
				shapePoint.y=wbCanvas.mouseY;
				whiteboardShape.shapePoints.push(shapePoint);
				if (ConfigFileReader.configValues.Whiteboard.EnableLineRenderTimeDelay ==1){
					//Add points/shapes to previewArray to draw points in 100ms together
					previewShapePointsArray.push(shapePoint);
				}
				else{
					var drawObject = (toolName=="fh" ? pencil : eraser ); 
					drawObject.draw(userDrawingSprite,wbCanvas.mouseX,wbCanvas.mouseY,false)
				}
			}
			// draw straight line
			else if (toolName=="st" && !FlexGlobals.topLevelApplication.whiteBoardTools.btnLine.enabled)
			{
				//Clear the shapes drawn on the _scratchSurface
				userDrawingSprite.graphics.clear();
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingSprite.graphics.moveTo(startX, startY);
				userDrawingSprite.graphics.lineTo(wbCanvas.mouseX, wbCanvas.mouseY);
				
				
			}
			// draw rectangle
			else if (toolName == "r" && !FlexGlobals.topLevelApplication.whiteBoardTools.btnRectangle.enabled)
			{
				//Clear the shapes drawn on the _scratchSurface
				userDrawingSprite.graphics.clear();
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingSprite.graphics.moveTo(startX, startY);
				userDrawingSprite.graphics.drawRect(startX, startY, (wbCanvas.mouseX - startX), (wbCanvas.mouseY - startY));
			}
				// Draw circle
			else if (toolName == "c" && !FlexGlobals.topLevelApplication.whiteBoardTools.btnCircle.enabled)
			{
				//Clear the shapes drawn on the _scratchSurface
				userDrawingSprite.graphics.clear();
				userDrawingSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingSprite.graphics.moveTo(startX, startY);
				userDrawingSprite.graphics.drawCircle(startX, startY, Math.sqrt(Math.pow((wbCanvas.mouseX - startX), 2) + Math.pow((wbCanvas.mouseY - startY), 2)));
			}
		}
	}
}

/**
 * Mouse up event handler for drawing area. It ends the drawing of a shape and send the shape object
 * to server so that every one get it
 */
private function drawingAreaMouseUpHandler(event:MouseEvent):void{
	applicationType::DesktopWeb{
		if (!showPointer.enabled && pointerShape == null){
			createMousePointer();
			showPointer.enabled=true;
		}
	}
	//Moved from disableDrawing() to here. to avoid Bug #15546
	if (wbCanvas.hasEventListener(MouseEvent.ROLL_OUT)){
		wbCanvas.removeEventListener(MouseEvent.ROLL_OUT, scratchAreaMouseOutHandler);
	}
	
	applicationType::mobile{
		if(!isMousePointerEnabled && pointerShape == null){
			createMousePointer();
			isMousePointerEnabled=true;
		}
	}
	//Bug #17044. If mouse goes out from top border then the y position change to -1. It will affect the circle drawing. 
	//So changed it to 0 if the value is less than zero. 
	xPos=(wbCanvas.mouseX < 0 ? 0 : wbCanvas.mouseX);
	yPos=(wbCanvas.mouseY < 0 ? 0 : wbCanvas.mouseY);
	if (wbCanvas.hasEventListener(MouseEvent.MOUSE_UP))
		wbCanvas.removeEventListener(MouseEvent.MOUSE_UP, drawingAreaMouseUpHandler);
	if (pointerIcon == showPointerIcon){
		logger.info ("Mousemove missing: drawingAreaMouseUpHandler. if show pointer is not selected.")
		wbCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
	}
	// just click not drawn anything
	if (startX == xPos && startY == yPos && whiteboardShape.shapePoints.length == 1){
		//PNCR: if it is just a a mouse click then release the object.
		if (drawingArea.contains(userDrawingSprite))
			drawingArea.removeChild(userDrawingSprite);
		return;
	}
	if (!isSelectionMode){
		//PNCR: #BugFix:14621. Replaced the toggleClearRestore() call outside if. The clear button has to be enabled even if the 'Restore' button disabled. 
		toggleClearRestore(true);
		applicationType::DesktopWeb{
			//Bug #15215
			//If the last action is clear then refresh all storage, now onwards only the new objects will be stored.
			//if (restorBtn.enabled){
			if (whiteboardShapeArray.length>0 && whiteboardShapeArray[whiteboardShapeArray.length - 1].toolName == "clear"){
				shapeCollaborationObject.removeAllValues();
				resetInMemoryShapes();
				whiteboardShape.shapeId=1;
				currentShapeId=1;
			}
		}
	}
	deleteUndoShapes();
	applicationType::DesktopWeb{
		//if (!btnEraser.enabled){
		//PNCR: commented because erase button dont have enable or disable.
		if (toolName == "e"){
			xPos+=(eraserThichness / 2);
			yPos+=(eraserThichness / 2);
		}
	}
	applicationType::mobile{
		if (!isEraserButtonEnabled){
			xPos+=(eraserThichness/2);
			yPos+=(eraserThichness/2);
		}
	}
	applicationType::DesktopWeb{
		//if (!btnFreehand.enabled || !btnEraser.enabled){
		if (["fh","e"].indexOf(toolName)>=0){
			// If the CPU optimized time delay logic required.		
			if (ConfigFileReader.configValues.Whiteboard.EnableLineRenderTimeDelay ==1){
				
				//Stop timer and removeEventListeners to it after finishing drawing
				drawingPreviewTimer.stop();
				drawingPreviewTimer.removeEventListener(TimerEvent.TIMER, drawFreeHandPreview);
				drawingPreviewTimer=null;
				if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
					userDrawingSprite.removeChildren();
				}
				else{
					if (userDrawingSprite){
						for (var i:int=userDrawingSprite.numChildren - 1; i > -1; i--)
							userDrawingSprite.removeChildAt(i);
					}
				}
				// While viewer drawing, if the presenter changes the page
				// and the viewer lift his mouuse on the next page, the 
				//userDrawingSprite  may removed de to the navigationSO synk
				
			}
			/*else{ //if no cpu optimization is required
				var drawObject = (!btnFreehand.enabled ? pencil : eraser );
				drawObject.drawFinish(whiteboardShape.shapeName);
			}*/
			//PNCR: commented becaues it is already removing at the time of line smoothing.
			/*if (drawingArea.contains(userDrawingSprite)){
				drawingArea.removeChild(userDrawingSprite);
				
				//drawFreeHandAndEraser(whiteboardShape.shapePoints, drawingArea);
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("addGraphic", null,whiteboardShape,ClassroomContext.lecture.lectureName+"|"+pageNumber);		
			}*/
			shapeCollaborationObject.addValue(whiteboardShape);
			
		}
		else{ //if the current tool is not freehand or eraser.
			var shapePoint:Shapepoint=new Shapepoint()
			shapePoint.x=xPos;
			shapePoint.y=yPos;
			whiteboardShape.shapePoints.push(shapePoint);
			shapeCollaborationObject.addValue(whiteboardShape);
			userDrawingSprite.name=whiteboardShape.shapeName;
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("addGraphic", null,whiteboardShape,ClassroomContext.lecture.lectureName+"|"+pageNumber);		
		}
	}
	applicationType::mobile{
		if (["fh","e"].indexOf(toolName)>=0 &&!FlexGlobals.topLevelApplication.whiteBoardTools.btnFreehand.enabled||!isEraserButtonEnabled){
			// If the CPU optimized time delay logic required.		
			if (ConfigFileReader.configValues.Whiteboard.EnableLineRenderTimeDelay ==1){
				if(drawingPreviewTimer!= null){
					//Stop timer and removeEventListeners to it after finishing drawing
					drawingPreviewTimer.stop();
					drawingPreviewTimer.removeEventListener(TimerEvent.TIMER,drawFreeHandPreview);
					drawingPreviewTimer=null;
				}
				if(AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
					userDrawingSprite.removeChildren();
				}else{
					if(userDrawingSprite){
						for(var i:int =userDrawingSprite.numChildren-1; i>-1; i--)
							userDrawingSprite.removeChildAt(i);
					}
				}
			}
			shapeCollaborationObject.addValue(whiteboardShape);
		}else{
			var shapePoint:Shapepoint=new Shapepoint()
			shapePoint.x=xPos
			shapePoint.y=yPos
			whiteboardShape.shapePoints.push(shapePoint);
			shapeCollaborationObject.addValue(whiteboardShape);
		}
	}
	if (showCollaborator){
		showCollaboratorForShape(whiteboardShape);
	}
	handleMousePointer();
	makePointerAsTopChild();
	
	garbageCollection.handleGarbageCollection(drawingArea.numChildren);
	
}



/**
 * Move the pointer shape. If the pointer shape is not exist , creates the pointer shape.
 */
private function handleMousePointer():void{
	applicationType::DesktopWeb{
		//If user has selected show pointer option and user is not drawing
		if (pointerIcon == removePointerIcon && !wbCanvas.hasEventListener(MouseEvent.MOUSE_UP) && showPointer.enabled && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			if (pointerShape == null){
				createMousePointer();
			}
			pointerShape.x=wbCanvas.mouseX - 3;
			pointerShape.y=wbCanvas.mouseY - 3;
			//FMS restart case.
			if (pointerCollaborationObject.getData()["pointerStatus"] == "disabled" || pointerCollaborationObject.getData()["pointerStatus"] == undefined){
				pointerCollaborationObject.setValue("pointerStatus", "enabled");
			}
			pointerCollaborationObject.setValue("pointerPosition", {x: wbCanvas.mouseX - 3, y: wbCanvas.mouseY - 3, width: wbCanvas.width, height: wbCanvas.height});
			if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
				if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.wbPointerRecorder.addEventTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), wbCanvas.mouseX - 3, wbCanvas.mouseY - 3, wbCanvas.width, wbCanvas.height, "")
				}
			}
			
		}
	}
	applicationType::mobile{
		if((FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon == removeMobilePointerIcon && !wbCanvas.hasEventListener(MouseEvent.MOUSE_UP) && isMousePointerEnabled&& FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)){
			if(pointerShape==null){
				createMousePointer();
			}
			pointerShape.x=wbCanvas.mouseX - 3;
			pointerShape.y=wbCanvas.mouseY - 3;
			//FMS restart case.
			if (pointerCollaborationObject.getData()["pointerStatus"] == "disabled" || pointerCollaborationObject.getData()["pointerStatus"] == undefined){
				pointerCollaborationObject.setValue("pointerStatus", "enabled");
			}
			pointerCollaborationObject.setValue("pointerPosition", {x: wbCanvas.mouseX - 3, y: wbCanvas.mouseY - 3, width: wbCanvas.width, height: wbCanvas.height});
		}
	}
}

//Change #16409. Modified the function to work with new UI. 
private var intractiveUser:Boolean = false;
public function setDrawingPermission():void{
	applicationType::DesktopWeb{
		var wbControls:Array = [textToolOptionBox,lineThicknessStepperBox,colorBox,collaborationBox,newPage,showPointer,clearBtn,btnUndo,btnRedo,btnSelect,btnTextTool,btnFreehand,btnEraser,btnShapes];
		var intractiveButtons:Array = [textToolOptionBox,lineThicknessStepperBox,colorBox,btnSelect,btnTextTool,btnFreehand,btnEraser,btnShapes];
		intractiveUser =(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAcceptedStudent(ClassroomContext.userVO.userName) ? true : false);
		
		//Default settings
		presenterControls.visible = false;
		toolBoxContainer.visible = false;
		disableWriting();
		
		var writePermissionEnabled:Boolean = false;
		
		for (var i:int = 0; i<wbControls.length; i++){
			UIComponent(wbControls[i]).enabled = false;
		}
		//Bug #16645. Store the last collaboration mode. So it can be reverted when presenter unhide. 
		if (collaborationMode!=Constants.CM_HIDE_WHITEBOARD)
			collaborationStatusBeforeHideMode=collaborationMode;
		
		switch (collaborationMode){
			case Constants.CM_SELECTED_STUDENT_CAN_WRITE:
				writePermissionEnabled = intractiveUser;
				break;
			case Constants.CM_NO_STUDENT_CAN_WRITE:
				//Bug #16707. If no viewer selects, then it should hide drawing for interactive users also.
				intractiveUser = false;
				writePermissionEnabled = false;
				break;
			case Constants.CM_ALL_STUDENT_CAN_WRITE:
				writePermissionEnabled = true;
				break;
			case Constants.CM_HIDE_WHITEBOARD:
				if (!isPresenter())
					hideWhiteboard();
				break;
		}
		if (isPresenter() || intractiveUser || writePermissionEnabled){
			presenterControls.visible = true;
			toolBoxContainer.visible = true;
			enableWriting();
		}
		
		//Enable buttons based on user permission.
		if(isPresenter()){
			for (var i:int = 0; i<wbControls.length; i++){
				UIComponent(wbControls[i]).enabled = true;
			}
		}
		else if (intractiveUser || writePermissionEnabled){
			for (var i:int = 0; i<intractiveButtons.length; i++){
				UIComponent(intractiveButtons[i]).enabled = true;
			}
		}
		
		//Unhide whiteboard
		if (hideWbCanvas != null && (collaborationMode != Constants.CM_HIDE_WHITEBOARD || isPresenter())){
			whiteboardBaseCanvas.removeElement(hideWbCanvas);
			hideWbCanvas=null;
			pageNoTxt.visible=true;
		}
		
		setCurrentTool(toolName);
		updateCollaborationStatus(collaborationMode);
	}
	applicationType::mobile{
		if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled && FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole!=Constants.PRESENTER_ROLE){	
			FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=false;
			FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=false;
			//To disable the whiteboard menu button
//			FlexGlobals.topLevelApplication.whiteBoardTools.menuGroup.enabled = false;
			FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = false;
		}
		if (hideWbCanvas != null && collaborationMode != Constants.CM_HIDE_WHITEBOARD){
			whiteboardBaseCanvas.removeElement(hideWbCanvas);
			hideWbCanvas=null;
			pageNoTxt.visible=true;
		}
		//To close the text tool when presenter changes the collaboration status, if text tool has opened.
		if(textComp){
			if(textComp.isPopUp){
				textComp.updateMsg(true);
				txtAreaEdit = false;
			}
			//To close the soft keyboard if it is exist
			if(isSoftKeyboardActivate){
				textComp.txtToolArea.setFocus();
				isSoftKeyboardActivate = false;
			}
		}
		if (drawingArea != null){
			switch (collaborationMode){
				case Constants.CM_SELECTED_STUDENT_CAN_WRITE:
					//only if this user is the selected student, add mouse down event handler to the drawing area 
					if (FlexGlobals.topLevelApplication.mainApp.isAcceptedStudent(ClassroomContext.userVO.userName)){
						applicationType::DesktopMobile{
							enableWriting();
							if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled){ 
								FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
								FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
								//To disable the whiteboard menu button
								//FlexGlobals.topLevelApplication.whiteBoardTools.menuGroup.enabled = true;
								FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
								setCurrentTool(toolName);
							}
						}
						applicationType::web{
							//For Guest Login: Restrict draw/write feature for guest user
							if(ClassroomContext.userVO.role != Strings.GUEST_TYPE)
							{ 
								enableWriting();
								if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled){ 
									FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
									FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
									//To disable the whiteboard menu button
									//FlexGlobals.topLevelApplication.whiteBoardTools.menuGroup.enabled = true;
									FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
									setCurrentTool(toolName);
								}
							}
						}
					}
					//For every other student (and not for teacher) remove mouse down event handler from the drawing area 
					else if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						disableWriting();
					}
					break;
				case Constants.CM_NO_STUDENT_CAN_WRITE:
					//For all the students remove the mouse down event handler from the drawing area
					if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						disableWriting();
					}
					break;
				
				case Constants.CM_ALL_STUDENT_CAN_WRITE:
					//Add mouse down event handler to the drawing area if there is not such event handler is 
					//already existing
					applicationType::DesktopMobile{
						enableWriting();
						if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled){ 
							FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
							FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
							//To disable the whiteboard menu button
							FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = false;
							setCurrentTool(toolName);
						}
					}
					applicationType::web{
						//For Guest Login: Restrict draw/write feature for guest user
						if(ClassroomContext.userVO.role != Strings.GUEST_TYPE)
						{
							enableWriting();
							if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled){ 
								FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
								FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
								//To disable the whiteboard menu button
								FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = false;
								setCurrentTool(toolName);
							}
						}
					}
					break;
				case Constants.CM_HIDE_WHITEBOARD:
					// For all viewers, creates a hide canvase and added to the top of the drawing area
					if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						hideWbCanvas=new HideComponent();
						hideWbCanvas.width=whiteboardBaseCanvas.width;
						hideWbCanvas.height=whiteboardBaseCanvas.height;
						hideWbCanvas.setStyle("backgroundColor","0xFFFFFF");
						whiteboardBaseCanvas.addElement(hideWbCanvas);
						pageNoTxt.visible=false;
					}
					break;
				default: // After restarting FMS and Login, both the presenter and selected viewer can write
					if(FlexGlobals.topLevelApplication.mainApp.isAcceptedStudent(ClassroomContext.userVO.userName)== ClassroomContext.userVO.userName || FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled ){
							FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
							FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
							//To disable the whiteboard menu button
							FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
						}
						setCurrentTool(toolName);
					}
			}
			updateCollaborationStatus(collaborationMode);
		}
	}
}

private function hideWhiteboard():void{
	//Bug #16645. Remove hideWbCanvas before hiding. Otherwise multiple canvases will be present in whiteboardBaseCanvas.
	if (hideWbCanvas)
		if(whiteboardBaseCanvas.contains(hideWbCanvas))
			whiteboardBaseCanvas.removeElement(hideWbCanvas);
	hideWbCanvas=new HideComponent();
	hideWbCanvas.width=whiteboardBaseCanvas.width;
	hideWbCanvas.height=whiteboardBaseCanvas.height;
	hideWbCanvas.setStyle("backgroundColor", "0xFFFFFF");
	whiteboardBaseCanvas.addElement(hideWbCanvas);
	pageNoTxt.visible=false;
}

/**
 * This function sets the permission for the user to determine
 * whether the user(student) has permission to draw on whiteboard as
 * per the preference set by the teacher.
 * @param StudentSelected Name of the selected student
 */
public function setDrawingPermission_O():void{
	if (Log.isInfo())		logger.info(" Entered function setDrawingPermission");
	applicationType::DesktopWeb{
		//Change #16400
		if (toolBoxContainer && toolBoxContainer.visible && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
			toolBoxContainer.visible=false;
		}
	}
	applicationType::mobile{
		if(FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole!=Constants.PRESENTER_ROLE){	
			FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=false;
			FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=false;
			//To disable the whiteboard menu button
			FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = false;
		}
	}
	if (hideWbCanvas != null && collaborationMode != Constants.CM_HIDE_WHITEBOARD){
		whiteboardBaseCanvas.removeElement(hideWbCanvas);
		hideWbCanvas=null;
		pageNoTxt.visible=true;
	}
	applicationType::DesktopWeb{
		if (rightClickMenu){
			rightClickMenu.hide();
		}
		lineColorComboBox.close();
		if (movableTextArea){
			commitText();
		}
	}
	applicationType::mobile{
		//For AVCM: To close the text tool when presenter changes the collaboration status, if text tool has opened.
		if(textComp){
			if(textComp.isPopUp){
				textComp.updateMsg(true);
				txtAreaEdit = false;
			}
			//To close the soft keyboard if it is exist
			if(isSoftKeyboardActivate){
				textComp.txtToolArea.setFocus();
				isSoftKeyboardActivate = false;
			}
		}
	}
	////////////////////////////////////////////////////////
	//Set user permission according to the preference set by the teacher.
	//If the preference is "SelectedStudentOnly" then add mouse down
	//event handler to the drawing area for the selected student only
	//
	//If the preference set by the teacher is "NoStudent" then remove 
	//mouse down event handler from the drawing area for all the student
	//
	//If the preference set by the teacher is "AllStudents" then add 
	//mouse down event handler from the drawing area for all the student
	if (drawingArea != null){
		switch (collaborationMode){
			case Constants.CM_SELECTED_STUDENT_CAN_WRITE:
				//only if this user is the selected student, add mouse down event handler 
				//to the drawing area 
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAcceptedStudent(ClassroomContext.userVO.userName)){
						enableWriting();
						//Change #16400
						if (toolBoxContainer && !toolBoxContainer.visible){
							toolBoxContainer.visible=true;
							setCurrentTool(toolName);
						}
					}
						//For every other student (and not for teacher) remove mouse down 
						//event handler from the drawing area 
					else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						disableWriting();
						//Bug #15446. Change presenter button mode also when presenter role changes.
						changePresenterButtonsMode(false);
					}
				}
				applicationType::mobile{
					if (FlexGlobals.topLevelApplication.mainApp.isAcceptedStudent(ClassroomContext.userVO.userName)){
						enableWriting();
						if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled){ 
							FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
							FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
							//To disable the whiteboard menu button
							FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
							setCurrentTool(toolName);
						}
					}
					//For every other student (and not for teacher) remove mouse down 
					//event handler from the drawing area 
					else if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						disableWriting();
					}
				}
				break;
			case Constants.CM_NO_STUDENT_CAN_WRITE:
				//For all the students remove the mouse down event handler 
				//from the drawing area
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						disableWriting();
						//PNCR: //#BugFix: 14630. Enable presenter control button when user get presenter control.
						changePresenterButtonsMode(false);
					}
				}
				applicationType::mobile{
					if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						disableWriting();
					}
				}
				break;
			
			case Constants.CM_ALL_STUDENT_CAN_WRITE:
				//Add mouse down event handler to the drawing area if there is not such event handler is 
				//already existing
				enableWriting();
				applicationType::DesktopWeb{
					//Change #16400
					if (toolBoxContainer && !toolBoxContainer.visible){
						toolBoxContainer.visible=true;
						//	toolSectection.visible=true;
						setCurrentTool(toolName);
					}
				}
				applicationType::mobile{
					if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled ){ 
						FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=false;
						FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=false;
						//To disable the whiteboard menu button
						FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = false;
						setCurrentTool(toolName);
					}
				}
				break;
			case Constants.CM_HIDE_WHITEBOARD:
				// For all viewers, creates a hide canvase and added to the top of the drawing area
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && hideWbCanvas == null){
						hideWbCanvas=new HideComponent();
						hideWbCanvas.width=whiteboardBaseCanvas.width;
						hideWbCanvas.height=whiteboardBaseCanvas.height;
						hideWbCanvas.setStyle("backgroundColor", "0xFFFFFF");
						whiteboardBaseCanvas.addElement(hideWbCanvas);
						pageNoTxt.visible=false;
					}
				}
				applicationType::mobile{
					if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){
						hideWbCanvas=new HideComponent();
						hideWbCanvas.width=whiteboardBaseCanvas.width;
						hideWbCanvas.height=whiteboardBaseCanvas.height;
						hideWbCanvas.setStyle("backgroundColor","0xFFFFFF");
						whiteboardBaseCanvas.addElement(hideWbCanvas);
						pageNoTxt.visible=false;
					}
				}
				break;
			default: // After restarting FMS and Login, both the presenter and selected viewer can write
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAcceptedStudent(ClassroomContext.userVO.userName) || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						//Change #16400
						if (toolBoxContainer && !toolBoxContainer.visible)
							toolBoxContainer.visible=true;
						setCurrentTool(toolName);
					}
				}
				applicationType::mobile{
					if(FlexGlobals.topLevelApplication.mainApp.isAcceptedStudent(ClassroomContext.userVO.userName)== ClassroomContext.userVO.userName || FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						if(FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser && !FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled && FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox && !FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled){
							FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
							FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true;
							//To disable the whiteboard menu button
							FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
						}
						setCurrentTool(toolName);
					}
				}
		}
		updateCollaborationStatus(collaborationMode);
	}
}

/**
 * Called if the directory creation for saving the lectures in the server when the teacher login to a class is suceed.
 * @param e of type ResultEvent
 */
private function serverSideFolderCreated(e:ResultEvent):void{
	if (e.result.status == false){
		MessageBox.show("Application Error (Error Number: S/WB/0005)\nPlease contact A-VIEW Administrator.", "Alert", MessageBox.MB_OK, this);
	}
	else if (e.result.status == true){
		if (Log.isDebug()) 			logger.debug(" SserverSideFolderCreatede");
	}
	else if (e.result.status == "exist"){
		if (Log.isDebug()) 			logger.debug(" SserverSideFolderCreatede");
	}
	if (createServerSideFolderService != null){
		createServerSideFolderService.removeEventListener(ResultEvent.RESULT, serverSideFolderCreated);
		createServerSideFolderService.removeEventListener(FaultEvent.FAULT, failToCreateServerSideFolder);
	}
	
}

/**
 * Called if any error during the creation of server side directory.
 * @param e of type ResultEvent
 */
private function failToCreateServerSideFolder(evnt:FaultEvent):void
{
	if(Log.isError()) logger.error("whiteboard::WhiteBoardHandler::failToCreateServerSideFolder:" + AbstractHelper.getStaticFaultMessage(evnt));
	MessageBox.show("Application Error (Error Number: S/WB/0005-" + evnt.fault.faultString + ")\nPlease contact A-VIEW Administrator.", "ERROR", MessageBox.MB_OK, whiteboardBaseCanvas);
	if (createServerSideFolderService != null){
		createServerSideFolderService.removeEventListener(ResultEvent.RESULT, serverSideFolderCreated);
		createServerSideFolderService.removeEventListener(FaultEvent.FAULT, failToCreateServerSideFolder);
	}
}


/**
 * Method to handle the net security error during FMS connection
 * @param e of type SecurityErrorEvent
 */
private function netSecurityError(event:SecurityErrorEvent):void{
	MessageBox.show("Application Error (Error Number: S/WB/0001-" + event.text + ")\nPlease contact A-VIEW Administrator.", "ERROR", MessageBox.MB_OK, this);
}


/**This function is called when teacher changes the  drawing permission
 * at run time. The graphic shared object is set with appropriate values 
 * @param event It is of type Event
 */
public function setCollaborationModeInCollabObject():void{
	if (Log.isInfo())		logger.info(" Entered function setCollaborationModeInCollabObject");
	applicationType::DesktopWeb{
		//collaborationListClose.play();
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
		var mode:String=collaborationList.selectedItem.data;
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING",MessageBox.MB_OK,this,null,null,MessageBox.IC_ALERT);
			return;
		}
		var mode:String = collaborationCallout.collaborationList.selectedItem.data;
	}
	
	switch (mode){
		case Constants.CM_SELECTED_STUDENT_CAN_WRITE:
			collaborationModeCollaborationObject.setValue("collaborationMode", Constants.CM_SELECTED_STUDENT_CAN_WRITE);
			applicationType::DesktopWeb{
				whiteBoardCollaborationEventLog(pageNumber, Constants.CM_SELECTED_STUDENT_CAN_WRITE);
			}
			break;
		case Constants.CM_ALL_STUDENT_CAN_WRITE:
			collaborationModeCollaborationObject.setValue("collaborationMode", Constants.CM_ALL_STUDENT_CAN_WRITE);
			applicationType::DesktopWeb{
				whiteBoardCollaborationEventLog(pageNumber, Constants.CM_ALL_STUDENT_CAN_WRITE);
			}
			break;
		case Constants.CM_NO_STUDENT_CAN_WRITE:
			collaborationModeCollaborationObject.setValue("collaborationMode", Constants.CM_NO_STUDENT_CAN_WRITE);
			applicationType::DesktopWeb{
				whiteBoardCollaborationEventLog(pageNumber, Constants.CM_NO_STUDENT_CAN_WRITE);
			}
			break;
		case Constants.CM_HIDE_WHITEBOARD:
			//Bug #16645. This assign moved to setDrawingPermission(), then only normal users with 'presenter control' can get this value.
			//collaborationStatusBeforeHideMode=collaborationMode;
			collaborationModeCollaborationObject.setValue("collaborationMode", Constants.CM_HIDE_WHITEBOARD);
			applicationType::DesktopWeb{
				whiteBoardHideEventLog(pageNumber, Constants.CM_HIDE_WHITEBOARD);
			}
			break;
		case Constants.CM_UNHIDE_WHITEBOARD:
			collaborationModeCollaborationObject.setValue("collaborationMode", collaborationStatusBeforeHideMode);
			applicationType::DesktopWeb{
				whiteBoardHideEventLog(pageNumber, Constants.CM_UNHIDE_WHITEBOARD);
			}
			break;
	}
	
}

/**
 *
 * @private
 * Audits the "WhiteBoardHide" action, when the presenter hides/unhides the whiteboard
 *
 * @param pageNumber - Current page number
 * @param hideMode - Hide or UnHide
 * @return void
 *
 */
private function whiteBoardHideEventLog(pageNumber:int, hideMode:String):void
{
	AuditContext.userAction.createAction(AuditConstants.whiteBoardHide, pageNumber + "", hideMode, null);
}

/**
 *
 * @private
 * Audits the "WhiteBoardCollaboration" action, when the presenter changes the collaboration mode
 *
 * @param pageNumber - Current page number
 * @param collaborationMode - Collaboration mode (No Viewer, All Viewer, Interacting Viewer)
 * @return void
 *
 */
private function whiteBoardCollaborationEventLog(pageNumber:int, collaborationMode:String):void
{
	AuditContext.userAction.createAction(AuditConstants.whiteBoardCollaboration, pageNumber + "", collaborationMode, null);
}


/**
 * Update the collaboration status label in the whiteboard status bar
 */
private function updateCollaborationStatus(mode:String):void{
	if (Log.isInfo())		logger.info(" Entered function updateCollaborationStatus and Mode = "+mode);
	//Set the collaboration dropdown values
	if (mode != Constants.CM_HIDE_WHITEBOARD){
		//PNCR: #Bugfix:14705 To avoid list height problem, Added static height(23) for each list item and multiplied by number of list items. 
		//PNCR: The static value 23 will change, after implement itemrender for list items.
		/*applicationType::DesktopWeb{
			collaborationListOpen.heightTo=ALL_COLLABORATION_MODES.length * 23;
		}*/
		collaborationListDataProvider=ALL_COLLABORATION_MODES;
	}
	else{
		collaborationListDataProvider=UNHIDE_COLLABORATION_MODE;
		/*applicationType::DesktopWeb{
			collaborationListOpen.heightTo=32;
		}*/
	}
	//Set the label
	switch (mode){
		case Constants.CM_SELECTED_STUDENT_CAN_WRITE:
			lblCollaborationModeBottom.text="Whiteboard  :  Only Selected Viewer can write";
			applicationType::DesktopWeb{
				collaborationList.selectedIndex=0;
			}
			applicationType::mobile{
				collaborationSelectedIndex = 0;
				closeAllOpenPannels();
			}
			break;
		case Constants.CM_ALL_STUDENT_CAN_WRITE:
			lblCollaborationModeBottom.text="Whiteboard  :  All Viewers can write";
			applicationType::DesktopWeb{
				collaborationList.selectedIndex=1;
			}
			applicationType::mobile{
				collaborationSelectedIndex = 1;
				closeAllOpenPannels();
			}
			break;
		case Constants.CM_NO_STUDENT_CAN_WRITE:
			lblCollaborationModeBottom.text="Whiteboard  :  No Viewer can write";
			applicationType::DesktopWeb{
				collaborationList.selectedIndex=2;
			}
			applicationType::mobile{
				collaborationSelectedIndex = 2;
				closeAllOpenPannels();
			}
			break;
		case Constants.CM_HIDE_WHITEBOARD:
			lblCollaborationModeBottom.text="Whiteboard  :  Whiteboard has been hidden by the presenter";
			applicationType::DesktopWeb{
				collaborationList.selectedIndex=0;
			}
			applicationType::mobile{
				collaborationSelectedIndex = 0;
				closeAllOpenPannels();
			}
			break;
	}
}

private function activateWb():void{
	//When the presenter is working in other modules, and if some other viewer writes on white board, the presenter view should not switch
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			return;
		}
		//Give focus to the white board when a user performs some action 
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveModule(true, 1);
			
		}
	}
	applicationType::mobile{
		if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			return;
		}
		//For AVCM: To navigates to whiteboard
		if(FlexGlobals.topLevelApplication.selectedModuleSO && FlexGlobals.topLevelApplication.isClassroomLayoutIntialized && FlexGlobals.topLevelApplication.selectedModuleIndex != 1){
			FlexGlobals.topLevelApplication.setActiveModule(true,1);
		}
	}
}

/**
 * Function required in viewer side at reconnection.
 * To draw the missing shapes which draw by the presenter in between reconnection. 
 */
private function drawMissingShapesHappenedInBetweenReconnection():void
{
	whiteboardShapeArray=getShapeFromSO();
	//Bug #18665. Issue is happening only after viewer reconnection. 
	//At the time of presenter close, SO will be cleared and viewer side onClear() will be called.
	//So in viewer side whiteboard will be cleared, and try to rewrite from blank shapeArray.
	//Added the length check condition to avoid this situation.
	if(whiteboardShapeArray.length > 0){
		setupWhiteboardPage();
		drawShapes();
		getAndUpdateShapePosition();
		startAutoSaveTimer();
	}
}

private function whiteboardShapesSOOnClear():void{
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.connectionRetrys > 0 && !isPresenter()){
			//PNCR: Bug #18178. if it is a reconnection then draw the missing shapes.
			drawMissingShapesHappenedInBetweenReconnection()
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.usersConnection.connectionRetrys > 0 && !isPresenter()){
			//PNCR: Bug #18178. if it is a reconnection then draw the missing shapes.
			drawMissingShapesHappenedInBetweenReconnection()
		}
	}
	shapeCollaborationObject.setOnChange(addGraphic);
}

/**
 * This method is called by sync when new drawing is added
 */
private function addGraphic(value:Object, name:Object):void{
	//shapeCollaborationObject.removeAllValues();
	if (shapeCollaborationObject.syncEventCount > 1 && value){
		currentShapeId=value.autoPropertyName + 1;
		var shapeObj:WhiteboardShape=new WhiteboardShape();
		shapeObj.initBySO(value.propertyValue);
		logger.info("drawing shape "+shapeObj.shapeName+" in page = "+pageNumber+" shape-PageNo = "+shapeObj.pageNo)
		if (!shapeObj.ignoreSync){
			logger.info("fn:addGraphic ignoreSync = "+shapeObj.ignoreSync+" it should be false to draw")
			activateWb();
			//pageUpdated=true;
			isPageUpdated[shapeObj.pageNo] = true;
			//For storing the width of the drawing area of user side who drawn the shape
			var teach_w:Number;
			//For storing the height of the drawing area of user side who drawn the shape
			var teach_h:Number;
			//For storing the  all the information of shapes such as color, linethickness,position, width , height 
			
			var point:Object;
			// i is using  as loop variable in this function
			var i:uint;
			var j:uint;
			var toolName:String;
			// Sprite objects for drawing the shapes
			var shapeSprite:WhiteboardShapeSprite=new WhiteboardShapeSprite();
			var txtFntScaled:uint;
			try{
				applicationType::DesktopWeb{
					//If user is moderator, record the shapes.
					if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
						if (drawingAreaWidthForShape != shapeObj.drawnAreaWidth || drawingAreaHeightForShape != shapeObj.drawnAreaHeight){
							drawingAreaWidthForShape=shapeObj.drawnAreaWidth;
							drawingAreaHeightForShape=shapeObj.drawnAreaHeight;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addSizeTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), wbCanvas.width, wbCanvas.height);
						}
						shapeObj.ctime=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime();
						shapeObj.isRecorded=true;
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addShapeTag(shapeObj.convertToXml());
					}
				}
				toolName=shapeObj.toolName;
				
				if (toolName == "clear"){
					removeSelection();
					//PNCR: Bug #15250.
					//clearShapesBeforeImporting();
					if (!clearWhenImporting){
						removeShapes();
						applicationType::DesktopWeb{
							toggleClearRestore(false);
						}
					}
					else{
						clearWhenImporting=false;
					}
					
					//Bug #15215. If there is a clear action comes after restore, then the restore action doesn't need to be stored in array of shapes.
					var shapeLength:uint=whiteboardShapeArray.length;
					if (whiteboardShapeArray[shapeLength - 1].toolName == "restore"){
						whiteboardShapeArray.splice(shapeLength - 1);
					}
					
					shapeObj.shapeId = currentShapeId++;
					whiteboardShapeArray.push(shapeObj);
				}
				else if (toolName == "restore"){
					
					var shapeLength:uint=whiteboardShapeArray.length;
					if (shapeLength > 0 && whiteboardShapeArray[shapeLength - 1].toolName == "clear"){
						whiteboardShapeArray.splice(shapeLength - 1);
					}
					drawShapes();
					
					toggleClearRestore(true);
					
					//Bug #15215. Store restore action also in the array of shapes. 
					//Then only while doing redo after "clear+undo", it can identify the last action as 'restore', and clear the screen.  
					shapeObj.shapeId = currentShapeId++;
					whiteboardShapeArray.push(shapeObj);
				}
				else{
					//restorBtn.enabled == cleared
					//Once cleared, and instead of restoring user is drawing a new shape
					//Now we should commit the clear
					applicationType::DesktopWeb{
						//Bug #15215. If the last action is clear then refresh all storage, now onwards only the new objects will be stored.
						//if (restorBtn.enabled){
						if (whiteboardShapeArray.length>0 && whiteboardShapeArray[whiteboardShapeArray.length - 1].toolName == "clear"){
							resetInMemoryShapes();
							toggleClearRestore(true)
						}
					}
					applicationType::mobile{
						if(FlexGlobals.topLevelApplication.whiteBoardTools.isClearClicked){
							resetInMemoryShapes();						
						}
					}
					whiteboardShapeArray.push(shapeObj);
					
					if (drawingArea.getChildByName(shapeObj.shapeName)){
						var obj:DisplayObject=drawingArea.getChildByName(shapeObj.shapeName) as DisplayObject;
						drawingArea.removeChild(obj);
						
					}
					applicationType::mobile{
						if (shapeObj.toolName == "txt" && shapeObj.drawnBy == ClassroomContext.userVO.userName){
							trace("Mobile user drawn text");
						}else{
							var sprite:Sprite=shapeObj.drawShape(wbCanvas.width, wbCanvas.height, backgroundColor);
						}
					}
					applicationType::DesktopWeb{
						var sprite:Sprite=shapeObj.drawShape(wbCanvas.width, wbCanvas.height, backgroundColor);
					}
					if (sprite != null){
						//if some users are logged in older versions, the shape objects may not have shapeName property 
						if (shapeObj.shapeName)
							sprite.name=shapeObj.shapeName;
						applicationType::DesktopWeb{
							//Enable object selection for the newly created shape if the selectionmode is active.
							//Change #16400
							if (isSelectionMode && toolBoxContainer.visible){
								//The the shape is a text box then enable TextSelect on mouse down action
								if (shapeObj.toolName == "txt")
									sprite.addEventListener(MouseEvent.MOUSE_DOWN, onTextSelect);
								//If the shape is not an erasor then enable Objectselection on mouse down action
								else if (shapeObj.toolName != "e")
									sprite.addEventListener(MouseEvent.MOUSE_DOWN, onShapeSelect);
							}
								
						}
						drawingArea.addChild(sprite);
						if (showCollaborator){
							showCollaboratorForShape(shapeObj)
						}
						
						//Bug #16588. The clear button has to be enabled if there is any drawing appear in the page.
						if (isPresenter()){
							applicationType::DesktopWeb{
								clearBtn.enabled = true;
							}
						}
					}
					makePointerAsTopChild();
				}
				
				
			}
			catch (err:Error){
				if(Log.isError()) FlexGlobals.topLevelApplication.mainApp.log.error("WhiteboardComp.mxml:addGraphic:exception: " + err.getStackTrace());
			}
		}
		else{
			logger.info("not drawing the shape because of ignoreSync = "+shapeObj.ignoreSync+" it should be false")
		}
	}
}

/**
 * Displays the name of the user who draws the shape.
 */
private function showCollaboratorForShape(shapeObj:WhiteboardShape):void{
	
	if (shapeObj.toolName == "e"){
		return;
	}
	applicationType::DesktopWeb{
		if (shapeObj.shapePoints.length > 0){
			var collaboratorName:Text=new Text();
			collaboratorName.name = "collab_"+ shapeObj.shapeName;
			collaboratorName.height=35;
			collaboratorName.setStyle("fontSize", 12);
			collaboratorName.text=shapeObj.drawnBy ;
			var _xPos:Number;
			var _yPos:Number;
			if (shapeObj.toolName == "txt"){
				_xPos=shapeObj.shapeX;
				;
				_yPos=shapeObj.shapeY - 8;
			}
			else{
				if (shapeObj.toolName == "c"){
					//Bug #15058. Changed the collaborators name display based on radius.
					var x0:Number=shapeObj.shapePoints[0].x;
					var x1:Number=shapeObj.shapePoints[1].x;
					var y0:Number=shapeObj.shapePoints[0].y;
					var y1:Number=shapeObj.shapePoints[1].y;
					var radius:Number=Math.sqrt(Math.pow((x1 - x0), 2) + Math.pow((y1 - y0), 2));
					_xPos= (shapeObj.shapeX > -1? shapeObj.shapeX + radius : x0);
					_yPos= (shapeObj.shapeX > -1? shapeObj.shapeY : y0 - radius) - 16;
					
					//_xPos=shapeObj.shapePoints[shapeObj.shapePoints.length - 1].x;
					//_yPos=(shapeObj.shapeX > -1? shapeObj.shapeY - 16 : shapeObj.shapePoints[0].y-8); //shapeObj.shapeY - 8;
				}
				else{
					//PNCR: The shape is drawn in to a shapeSprite. #BugFix: 14936
					//If the shapeSprite is created first time its coordinates will be -1:-1 and the position is calculated from the first shape point.
					//If the shape position is changed by the user by moving the object, then the shapeSprite cordinates will change. But the co-ordinates for each shape points will stay as it is. 
					//So if shapeSprite cordinates are -1:-1 then use point cordinates. else use shapeSprite itself.
					_xPos=(shapeObj.shapeX > -1? shapeObj.shapeX - 8 : shapeObj.shapePoints[0].x)
					_yPos=(shapeObj.shapeX > -1? shapeObj.shapeY - 16 : shapeObj.shapePoints[0].y);
					//_xPos=shapeObj.shapePoints[0].x;
					//;
					//_yPos=shapeObj.shapePoints[0].y;
				}
			}
			//Bug #15056
			collaboratorName.addEventListener(FlexEvent.CREATION_COMPLETE, onCollaboratorNameCreationComplete);
			collaboratorName.width
			//Bug #16379
			collaboratorName.x=_xPos * (drawingArea.width / shapeObj.drawnAreaWidth);
			collaboratorName.y=_yPos * (drawingArea.height / shapeObj.drawnAreaHeight);
			wbCanvas.addElement(collaboratorName);
		}
	}
	applicationType::mobile{
		if(shapeObj.shapePoints.length>0)
		{
			var collaboratorName:Label = new Label();
			collaboratorName.height=30;
			collaboratorName.text=shapeObj.drawnBy;
			//For AVCM: To set id and color for Label
			collaboratorName.setStyle("color","0x1234DF");
			collaboratorName.id = getRandomNumber().toString();
			var _xPos:Number;
			var _yPos:Number;
			if(shapeObj.toolName=="txt"){
				_xPos=shapeObj.shapeX;
				_yPos=shapeObj.shapeY-8;
			}else {
				if(shapeObj.toolName=="c"){
					_xPos=shapeObj.shapePoints[shapeObj.shapePoints.length-1].x;;
					_yPos=shapeObj.shapePoints[shapeObj.shapePoints.length-1].y;
				}else {
					_xPos=shapeObj.shapePoints[0].x;;
					_yPos=shapeObj.shapePoints[0].y;
				}
			}
			collaboratorName.addEventListener(FlexEvent.CREATION_COMPLETE,onCollaboratorNameCreationComplete);
			//To store the x and y position to Dictionary for positioning
			collaboratorObject = new Object();
			collaboratorObject.x=_xPos*(wbCanvas.width / shapeObj.drawnAreaWidth);
			collaboratorObject.y=_yPos*(wbCanvas.height / shapeObj.drawnAreaHeight);
			collaboratorPosition[collaboratorName.id] = collaboratorObject;
			collaboratorName.x = 0;
			collaboratorName.y = 0;
			wbCanvas.addElement(collaboratorName); 
		}
	}
	
}

/**
 * Creation complete of collaborator name label. It do the reposition of the label
 * if it go beyond the drawing are.
 */
private function onCollaboratorNameCreationComplete(evnt:FlexEvent):void{
	applicationType::DesktopWeb{
		var txt:Text=evnt.target as Text;
		txt.removeEventListener(FlexEvent.CREATION_COMPLETE, onCollaboratorNameCreationComplete);
		if (txt.x + txt.width > wbCanvas.width){
			txt.x=wbCanvas.width - txt.width;
		}
		if (txt.y + txt.height > wbCanvas.height){
			txt.y=wbCanvas.height - txt.height;
		}
	}
	applicationType::mobile{
		var txt:Label=evnt.target as Label;
		txt.removeEventListener(FlexEvent.CREATION_COMPLETE,onCollaboratorNameCreationComplete);
		//For AVCM: To positioning the colloborator label
		var collaboratorObj:Object = collaboratorPosition[txt.id];
		if(collaboratorObj.x+txt.width> wbCanvas.width){
			txt.x= wbCanvas.width-txt.width;
		}else{
			txt.x = collaboratorObj.x;
		}
		if(collaboratorObj.y+txt.height>wbCanvas.height){
			txt.y= wbCanvas.height-txt.height;
		}else{
			txt.y = collaboratorObj.y;
		}
		delete collaboratorPosition[txt.id];
	}
}

/**
 * Make the pointer as last child of the drawing area so that it always appear
 * top of all the shapes.
 */
private function makePointerAsTopChild():void{
	if (pointerShape != null && drawingArea.contains(pointerShape)){
		drawingArea.setChildIndex(pointerShape, drawingArea.numChildren - 1);
	}
}

/**
 * Remove the pointer shape when user stop pointer sharing
 */
private function removePointer():void{
	if (!wbCanvas.hasEventListener(MouseEvent.MOUSE_UP) && wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE)){
		logger.info ("Mousemove missing: removePointer. There are already a mouse up and mouse move events")
		wbCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
	}
	if (pointerShape != null){
		drawingArea.removeChild(pointerShape)
		pointerShape=null;
	}
}

/**
 * Clean up for whiteboard module when user log out or close.
 */
public function resetWhiteboard():void{
	if (isWbInitialized){
		applicationType::DesktopWeb{
			if ((collaborationModeCollaborationObject) && 
				(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)){
				collaborationModeCollaborationObject.setValue("collaborationMode", "NoStudent");
				
			}
		}
		applicationType::mobile{
			if ((collaborationModeCollaborationObject) && 
				(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)){
				collaborationModeCollaborationObject.setValue("collaborationMode", "NoStudent");
			}
		}
		deleteWhiteboardShapesCollaborationObject();
		deleteWhiteboardShapeSelectionCollaborationObject();
		ClassroomContext.collaborationService.closeCollaborationObject("collaborationModeSO");
		ClassroomContext.collaborationService.closeCollaborationObject("whiteboardPointerSO");
		ClassroomContext.collaborationService.closeCollaborationObject("navigationSO");
		ClassroomContext.collaborationService.closeCollaborationObject("whiteboardUndoRedoSO")
		undoRedoCollaborationObject.setValue("redo", "");
		undoRedoCollaborationObject.setValue("undo", "");
		savePage(pageNumber);
		//Bug #14225
		saveNavigaionInformationForTheSession();
		deletingWbCache(false);
		applicationType::DesktopWeb{
			if (previewAlert){
				PopUpManager.removePopUp(previewAlert);
				previewAlert=null;
			}
		}
	}
	autoSaveTimerForPage.stop();
	if (autoSaveTimerForPage.hasEventListener(TimerEvent.TIMER)){
		autoSaveTimerForPage.removeEventListener(TimerEvent.TIMER, autoSavePage);
	}
	
	
}

/**
 * Create graphic for clearing the whiteboard
 */
private function createClearGarphic():WhiteboardShape{
	var shapeObj:WhiteboardShape=new WhiteboardShape();
	shapeObj.toolName="clear";
	shapeObj.lineColor="#000000";
	shapeObj.lineThickness=0;
	shapeObj.lineAlfa=0
	shapeObj.drawnBy=ClassroomContext.userVO.userName
	shapeObj.drawnAreaWidth=wbCanvas.width;
	shapeObj.drawnAreaHeight=wbCanvas.height
	shapeObj.pageNo=pageNumber
	var date:Date=new Date();
	shapeObj.shapeId=currentShapeId;
	shapeObj.shapeName=ClassroomContext.userVO.userName + date.time;
	return shapeObj;
}

/**
 * Create and send the clear shape and on receiving this shape all the users clear the drawing area
 */
private function doClear():void{
	//if(!clearWhenImporting)
	toggleClearRestore(false);
	var shapeObj:WhiteboardShape=createClearGarphic();
	shapeCollaborationObject.addValue(shapeObj);
	whiteBoardClearEventLog(pageNumber);
	applicationType::mobile{
		FlexGlobals.topLevelApplication.whiteBoardTools.isClearClicked = true;
		FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.setStyle("icon",FlexGlobals.topLevelApplication.whiteBoardTools.restoreIcon);
		FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.toolTip = "Restore Whiteboard";
	}
}

/**
 *
 * @private
 * Audits the "WhiteBoardClear" action, when the presenter clears the whiteboard
 *
 * @param pageNumber - Current page number
 * @return void
 *
 */
private function whiteBoardClearEventLog(pageNumber:int):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.whiteBoardClear, pageNumber + "", null, null);
	}
}
public var eve:Event;
/**
 * Pressing the clear scratch pad button calls this method
 * for clearing all the graphics in the drawing area
 */
public function clearScratchPad():void{
	applicationType::DesktopWeb{
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	}
	if (Log.isInfo())		logger.info(" Entered function clearScratchPad");
	applicationType::DesktopWeb{
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
	}
	applicationType::mobile{
		if (!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
	}
	closeAllOpenPannels();
	clearWhenImporting=false;
	//Bug #15215. Should not be any redo after clear.
	deleteUndoShapes();
	if (whiteboardShapeArray.length > 0){
		doClear();
	}
	
	toolSelection();
	
}

/**
 * This method is to handle line color of drawing object
 * @param event The color picker event
 */
public function changeLineColor(event:ColorPickerEvent):void{
	applicationType::DesktopWeb{
		lineColor=event.color.toString();
		if (movableTextArea){
			movableTextArea.setStyle("color", uint(lineColor));
		}
		whiteBoardLineColorEventLog(pageNumber, uint(lineColor), "ColorPicker");
	}
}

/**
 * Invoked when user change the font size for text box.
 */
public function changeTextFontSize(event:Event):void{
	applicationType::DesktopWeb{
		//Bug #17507. Avoid shape point NAN value.
		if(isNaN((event.target as NumericStepper).value))
			textFondStepper.value = lastFontSize;
		else
			lastFontSize = textFondStepper.value;
		if (movableTextArea && textAreaEditable){
			movableTextArea.setStyle("fontSize", textFondStepper.value);
		}
	}
}

/**
 * This method is to handle line thickness of drawing object
 * @param event The change event of the line thickness numeric stepper in the tool box
 */
applicationType::DesktopWeb{
	public function changeLineThickness(event:Event):void{
		//PNCR: Bug #15195. Added isNan check, and set last selected value if it is null.
		if (isNaN(lineThicknessStepper.value)){
			lineThicknessStepper.value = lineThickness ? lineThickness : 1 ;
		}
		drawingArea.setFocus();
		lineThickness=lineThicknessStepper.value;
		whiteBoardLineThicknessEventLog(pageNumber, lineThickness);
	}
}
applicationType::mobile{
	public function changeLineThickness(event:WhiteBoardActionEvent):void{
		lineThickness = event.data.lineThickness;
	}
}
/**
 *
 * @private
 * Audits the "WhiteBoardLineThickness" action, when the presenter/user changes the line thickness of the drawings
 *
 * @param pageNumber - Current page number
 * @param lineThickness - New line thickness
 * @return void
 *
 */
private function whiteBoardLineThicknessEventLog(pageNumber:int, lineThickness:int):void
{
	AuditContext.userAction.createAction(AuditConstants.whiteBoardLineThickness, pageNumber + "", lineThickness + "", null);
}

//PNCR: //#BugFix: 14630. Enable presenter control button when user get presenter control.
/**
 * Function to enable of disable presenter role buttons based on the privilage. 
 */
private function changePresenterButtonsMode(value:Boolean){
	applicationType::DesktopWeb{
		//btnRectangel.enabled=value;
		//btnCircle.enabled=value;
		//btnLine.enabled=value;
		btnFreehand.enabled=value;
		btnShapes.enabled = value;
		btnEraser.enabled = value;
		btnTextTool.enabled = value;
		btnSelect.enabled = value;
		//PNCR: #BugFix: 14762 added seperate images for enable and disable options.
		/*btnEraser.setStyle("imageSkin",(value ? enableEraseToolImage: disableEraseToolEnableSizeSelectionImage));
		btnEraser.enabled=value;*/
		
		//PNCR: #BugFix: 14762 added seperate images for enable and disable options.
		//btnTextTool.setStyle("imageSkin",(value ? enableTextToolImage: disableTextToolEnableSizeSelectionImage));
		//PNCR: #BugFix: 14762 the enable option is required for the viewer side display.
		//btnTextTool.enabled=value;
		//Change #16400
		
		//Commented because this condition is already added at the time to premission change in "setDrawingPermission"
		//presenterControls.visible = isCollaborationModePresenter;
	
		//collaborationControlButton.enabled = isPresenter()? true: false;
		disableOrEnableNavigation(isPresenter()? true: false);
	}
}

/**
 * Invoked when user select a drawing tool.
 */
private function setCurrentTool(tool:String):void{	
	if (Log.isInfo()) logger.info(" Entered function setCurrentTool.  Tool:" + tool);
	
	applicationType::DesktopWeb{
		//PNCR: //#BugFix: 14630. Enable presenter control button when user get presenter control.
		//Commented this feature because it is included in setDrawingPermission.
		changePresenterButtonsMode(true);
		
		if (whiteboardBaseCanvas.contains(eraserOptionBox)){
			whiteboardBaseCanvas.removeElement(eraserOptionBox);
		}
		if (whiteboardBaseCanvas.contains(shapesOptionBox)){
			whiteboardBaseCanvas.removeElement(shapesOptionBox);
			
		}
		
		lineThickness=lineThicknessStepper.value;
	}
	switch (tool){
		case "r":
			toolName="r";
//			applicationType::DesktopWeb{
				//btnRectangel.enabled=false;
//			}
			applicationType::mobile{
				enableWhiteboardControls();
				FlexGlobals.topLevelApplication.whiteBoardTools.btnRectangle.enabled=false;
			}
			/* toolSectection.x=btnRectangel.x;
			toolSectection.y=btnRectangel.y; */
			break;
		
		case "c":
			toolName="c";
//			applicationType::DesktopWeb{
				//btnCircle.enabled=false;
//			}
			applicationType::mobile{
				enableWhiteboardControls();
				FlexGlobals.topLevelApplication.whiteBoardTools.btnCircle.enabled=false;
			}
			/* toolSectection.x=btnCircle.x;
			toolSectection.y=btnCircle.y; */
			break;
		
		case "st":
			toolName="st";
//			applicationType::DesktopWeb{
				//btnLine.enabled=false;
//			}
			applicationType::mobile{
				enableWhiteboardControls();
				FlexGlobals.topLevelApplication.whiteBoardTools.btnLine.enabled=false;
			}
			/* toolSectection.x=btnLine.x;
			toolSectection.y=btnLine.y; */
			break;
		case "e":
			toolName="e";
			lineThickness=eraserThichness;
			/*applicationType::DesktopWeb{
				btnEraser.setStyle("imageSkin",disableEraseToolEnableSizeSelectionImage);
			}*/
			applicationType::mobile{
				enableWhiteboardControls()
				FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=false;
			}
			//PNCR: //#Bugfix:14709. Commented the disable code for erase button. Otherwise it will not allow to change eraser size.
			//btnEraser.enabled=false;
			/* toolSectection.x=btnEraser.x;
			toolSectection.y=btnEraser.y; */
			break;
		case "fh":
			toolName="fh";
			applicationType::DesktopWeb{
				btnFreehand.enabled=false;
				btnTextTool.setStyle("imageSkin",enableTextToolImage);
			}
			applicationType::mobile{
				enableWhiteboardControls();
				FlexGlobals.topLevelApplication.whiteBoardTools.btnFreehand.enabled=false;
			}
			break;
		case "txt":
			toolName="txt";
			applicationType::DesktopWeb{
				//PNCR: #BugFix: 14762. Replaced the disabled option with disable image.
				btnTextTool.setStyle("imageSkin",disableTextToolEnableSizeSelectionImage);
				btnTextTool.enabled=false;
			}
			applicationType::mobile{
				enableWhiteboardControls();
				FlexGlobals.topLevelApplication.whiteBoardTools.btnTextTool.enabled=false;
			}
			/* toolSectection.x=btnTextTool.x;
			toolSectection.y=btnTextTool.y; */
			break;
		case "os": //PNCR object selection
			//PNCR: Bug #15119. Added a toolname for object selection. 
			// If there is a paste text commit after object selection, then it will go back to object selection. 
			enableObjectSelection();
			break;
	}
}

/**
 * This method sets the current tool as text tool. The text tool button handles two functionalities.
 * The left portion set the text tool and the right portion allow user to select text tool option like
 * font size etc.
 */
public function setTexttool(e:MouseEvent = null):void{
	
	applicationType::DesktopWeb{
		//if (e.target.mouseX < 25 && e.currentTarget == btnTextTool && btnTextTool.enabled){
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		//btnTextTool.setStyle("imageSkin",enableTextToolImage);
			if (textFondStepper.value < 1){
				textFondStepper.value=textFondStepper.minimum;
			 }
			setCurrentTool("txt");
			whiteBoardToolEventLog(String(pageNumber), "Text");
	//	}
	//	else if (e.target.mouseX > 25 && e.target.mouseX < 41 && e.currentTarget == btnTextTool && toolBoxContainer.enabled){
		//	whiteboardBaseCanvas.addElement(textToolOptionBox);
		//	textToolOptionBox.x=toolBoxContainer.x + btnTextTool.x + 2;
		//	textToolOptionBox.y=0;
		//}
	}
	applicationType::mobile{
		if(e.target.mouseX<25 && e.currentTarget==FlexGlobals.topLevelApplication.whiteBoardTools.btnTextTool && FlexGlobals.topLevelApplication.whiteBoardTools.btnTextTool.enabled){
			setCurrentTool("txt");
		}
	}
	toolSelect="txt";
}


/**
 *
 * @private
 * Audits the "WhiteBoardTool" action, when the presenter/user selects a whiteboard tool
 *
 * @param pageNumber - Current page number
 * @param toolName - Chosen tool
 * @return void
 *
 */
private function whiteBoardToolEventLog(pageNumber:String, toolName:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.whiteBoardTool, pageNumber, toolName, null);
	}
}

/**
 * This method sets the current tool as freehand.
 */
public function setFreehandTool():void{
	applicationType::DesktopWeb{
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	
	}
	setCurrentTool("fh");
	whiteBoardToolEventLog(String(pageNumber), "Free Hand");
	toolSelect="fh";
}

/**
 * This method sets the current tool as straight line.
 */
public function setlineTool():void{
	setCurrentTool("st");
	whiteBoardToolEventLog(String(pageNumber), "Straight Line");
	applicationType::DesktopWeb{
		shapesOptionBox.visible=false;
		btnShapes.setStyle("imageSkin",LineSelectionImage);
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	}
	toolSelect="st";
}

/**
 * This method sets the current tool as rectangle.
 */
public function setRectTool(e:Event):void{
	
	
	setCurrentTool("r");
	whiteBoardToolEventLog(String(pageNumber), "Rectangle");
	applicationType::DesktopWeb{
		shapesOptionBox.visible=false;
		btnShapes.setStyle("imageSkin",RectangleSelectionImage);
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	}
	toolSelect="r";
}

/**
 * This method sets the current tool as circle.
 */
public function setCircleTool(e:Event):void{
	setCurrentTool("c");
	whiteBoardToolEventLog(String(pageNumber), "Circle");
	applicationType::DesktopWeb{
		shapesOptionBox.visible=false;
		btnShapes.setStyle("imageSkin",CircleSelectionImage);
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	}
	toolSelect="c";
}

/**
 * This method sets the current tool as eraser.The eraser button handles two functionalities.
 * The left portion set the eraser tool and the right portion allow user to select the thickness
 * of the eraser.
 */
public function setEraserTool(e:Event,toolName:String=null):void{
	
	//toolSelect="e";
	eve=e;
	applicationType::DesktopWeb{
		
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		if (e.currentTarget == btnEraser){
			eraserThichness=8
			eraserOptionBox.visible=true;
			btnEraserSmall.enabled=true;
			btnEraserMedium.enabled=true;
			btnEraserLarge.enabled=true;
			setCurrentTool("e");
			whiteBoardToolEventLog(String(pageNumber), "Erase");
			
		}
		else if (e.currentTarget == btnEraser && toolBoxContainer.visible){
			/*whiteboardBaseCanvas.addElement(eraserOptionBox);
			eraserOptionBox.x=btnEraser.x + 100 ;
			eraserOptionBox.y=btnEraser.y + 70 ;*/
			eraserOptionBox.visible=true;
			if (btnEraser.enabled){
				btnEraserSmall.enabled=true;
				btnEraserMedium.enabled=true;
				btnEraserLarge.enabled=true;
			}
			
		}
		if (e.currentTarget != btnEraser){
			btnEraserSmall.enabled=true;
			btnEraserMedium.enabled=true;
			btnEraserLarge.enabled=true;
			
			switch(toolName){
				case "s":
					toolSelect="s";
					applicationType::DesktopWeb
				     {
					eraserThichness=4
					//btnEraserSmall.enabled=false;
					eraserOptionBox.visible=false;
					btnEraser.setStyle("imageSkin",SmallEraserSelectionImage);
					}
					break;
				case "m":
					toolSelect="m";
					applicationType::DesktopWeb
				{
					eraserThichness=15
					//btnEraserMedium.enabled=false;
					eraserOptionBox.visible=false;
					btnEraser.setStyle("imageSkin",MediumEraserSelectionImage);
				}
					break;
				case "l":
					toolSelect="l";
					applicationType::DesktopWeb
				{
					eraserThichness=25
					//btnEraserLarge.enabled=false;
					eraserOptionBox.visible=false;
					btnEraser.setStyle("imageSkin",LargeEraserSelectionImage);
				}
					break;
					
			}
			/*if (para == btnEraserSmall){
				eraserThichness=4
				//btnEraserSmall.enabled=false;
				eraserOptionBox.visible=false;
				btnEraser.setStyle("imageSkin",SmallEraserSelectionImage);

			}
			else if (para == btnEraserMedium){
				eraserThichness=15
				//btnEraserMedium.enabled=false;
				eraserOptionBox.visible=false;
				btnEraser.setStyle("imageSkin",MediumEraserSelectionImage);
			}
			else{
				eraserThichness=25
				//btnEraserLarge.enabled=false;
				eraserOptionBox.visible=false;
				btnEraser.setStyle("imageSkin",LargeEraserSelectionImage);
			}*/
			setCurrentTool("e");
			whiteBoardToolEventLog(String(pageNumber), "Erase");
		}
		
}
	applicationType::mobile{
		if(e.currentTarget != FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser){
			eraserCallout.btnEraserSmall.enabled=true;
			eraserCallout.btnEraserMedium.enabled=true;
			eraserCallout.btnEraserLarge.enabled=true;
			if(e.currentTarget == eraserCallout.btnEraserSmall)
			{
				eraserThichness = 4
				eraserCallout.btnEraserSmall.enabled = false;
				//Added to check whether eraser button is enabled.
				isEraserButtonEnabled = false;
			}else if(e.currentTarget == eraserCallout.btnEraserMedium){
				eraserThichness = 15
				eraserCallout.btnEraserMedium.enabled=false;
				//Added to check whether eraser button is enabled.
				isEraserButtonEnabled = false;
			}else{
				eraserThichness = 25
				eraserCallout.btnEraserLarge.enabled=false;
				//Added to check whether eraser button is enabled.
				isEraserButtonEnabled = false;
			}
			setCurrentTool("e");
		}else if(e.currentTarget == FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser){
			eraserThichness = 8
			eraserCallout.btnEraserSmall.enabled=true;
			eraserCallout.btnEraserMedium.enabled=true;
			eraserCallout.btnEraserLarge.enabled=true;
			setCurrentTool("e");
		}
	}
}

public function setShapesTool(e:MouseEvent):void{
	applicationType::DesktopWeb{
		if (e.currentTarget == btnShapes){
			//eraserThichness=8
			shapesOptionBox.visible=true;
			btnRectangel.enabled=true;
			btnCircle.enabled=true;
			btnLine.enabled=true;
			
			setCurrentTool("s");
			whiteBoardToolEventLog(String(pageNumber), "Shape");
		}
		else if (e.currentTarget == btnShapes && toolBoxContainer.visible){
			/*whiteboardBaseCanvas.addElement(shapesOptionBox);*/
			/*shapesOptionBox.x=btnShapes.x + 100;
			shapesOptionBox.y=btnShapes.y+70;*/
			shapesOptionBox.visible=false;
			if (btnShapes.enabled){
				btnRectangel.enabled=true;
				btnCircle.enabled=true;
				btnLine.enabled=true;
			}
		}
		if (e.currentTarget != btnShapes){
			btnRectangel.enabled=true;
			btnCircle.enabled=true;
			btnLine.enabled=true;
			shapesOptionBox.visible=false;
			if (e.currentTarget == btnRectangel){
				//eraserThichness=4
				btnRectangel.enabled=false;
				shapesOptionBox.visible=false;
				btnShapes.setStyle("imageSkin",RectangleSelectionImage);
			}
			else if (e.currentTarget == btnCircle){
				//eraserThichness=15
				btnCircle.enabled=false;
				shapesOptionBox.visible=false;
				btnShapes.setStyle("imageSkin",CircleSelectionImage);
			}
			else{
				//eraserThichness=25
				btnLine.enabled=false;
				shapesOptionBox.visible=false;
				btnShapes.setStyle("imageSkin",LineSelectionImage);
			}
			setCurrentTool("s");
			whiteBoardToolEventLog(String(pageNumber), "Shape");
		}
	}
	applicationType::mobile{
		if(e.currentTarget != FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser){
			eraserCallout.btnEraserSmall.enabled=true;
			eraserCallout.btnEraserMedium.enabled=true;
			eraserCallout.btnEraserLarge.enabled=true;
			if(e.currentTarget == eraserCallout.btnEraserSmall)
			{
				eraserThichness = 4
				eraserCallout.btnEraserSmall.enabled = false;
				//Added to check whether eraser button is enabled.
				isEraserButtonEnabled = false;
			}else if(e.currentTarget == eraserCallout.btnEraserMedium){
				eraserThichness = 15
				eraserCallout.btnEraserMedium.enabled=false;
				//Added to check whether eraser button is enabled.
				isEraserButtonEnabled = false;
			}else{
				eraserThichness = 25
				eraserCallout.btnEraserLarge.enabled=false;
				//Added to check whether eraser button is enabled.
				isEraserButtonEnabled = false;
			}
			setCurrentTool("e");
		}else if(e.currentTarget == FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser){
			eraserThichness = 8
			eraserCallout.btnEraserSmall.enabled=true;
			eraserCallout.btnEraserMedium.enabled=true;
			eraserCallout.btnEraserLarge.enabled=true;
			setCurrentTool("e");
		}
	}
}

/**
 * Record the existing whiteboard shapes when moderator starts recording.
 */
public function recordExistingContent():void{
	applicationType::DesktopWeb{
		if (recordedExistingContent == false){
			recordedExistingContent=true;
			var length:int=whiteboardShapeArray.length;
			var ctime:uint=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime();
			var i:uint;
			var tempWidth:Number=wbCanvas.width;
			var tempHeight:Number=wbCanvas.height;
			var pageTagIndex:Number=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.whiteboardXml.page.length();
			var sizeTagIndex:Number;
			if (pageTagIndex <= 0){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addPageTag(ctime, pageNumber);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addSizeTag(ctime, wbCanvas.width, wbCanvas.height);
			}
			else{
				sizeTagIndex=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.whiteboardXml.page[pageTagIndex - 1].size.length();
				if (sizeTagIndex <= 0){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addSizeTag(ctime, wbCanvas.width, wbCanvas.height);
				}
			}
			var xml:XML=<shape><content></content></shape>
			xml.@toolName="tab";
			xml.@ctime=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addShapeTag(xml);
			for (i=0; i < length; i++){
				if ((whiteboardShapeArray[i].drawnAreaWidth != tempWidth || whiteboardShapeArray[i].drawnAreaHeight != tempHeight) && whiteboardShapeArray[i].isRecorded == false){
					tempWidth=whiteboardShapeArray[i].drawnAreaWidth;
					tempHeight=whiteboardShapeArray[i].drawnAreaHeight;
					if (tempWidth != wbCanvas.width || tempHeight != wbCanvas.height){
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addSizeTag(ctime, tempWidth, tempHeight);
					}
				}
				if (whiteboardShapeArray[i].isRecorded == false){
					//pageUpdated=true;
					isPageUpdated[whiteboardShapeArray[i].pageNo] = true;
					whiteboardShapeArray[i].ctime=ctime;
					whiteboardShapeArray[i].isRecorded=true;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.whiteBoardRecorder.addShapeTag(whiteboardShapeArray[i].convertToXml());
				}
				
			}
			
		}
	}
}
private var delayTimeOutId:uint;

public function onShowPanel():void{
	if (showCollaborator){
		
		hideCollaboratorNames();
		delayTimeOutId=setTimeout(onDelayComplete, 100);
		
	}
}

private function onDelayComplete():void{
	clearTimeout(delayTimeOutId);
	showCollaboratorNames();
}

/**
 * This method is used to when resize the drawing area.
 *
 * @param event Resize event of drawing area.
 */
public function resize(event:ResizeEvent):void{
	/*
	if(hideWbCanvas!=null){
	hideWbCanvas.width=whiteboardBaseCanvas.width;
	hideWbCanvas.height=whiteboardBaseCanvas.height;
	whiteboardBaseCanvas.setChildIndex(hideWbCanvas,whiteboardBaseCanvas.numChildren-1)
	}
	stage.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyboardShortcut);
	// Setting drawing area with and height to new with and height while resizing
	scratchArea.removeChild(whiteboardMask);
	whiteboardBaseCanvas.removeChild(scratchArea);
	scratchArea.width=whiteboardBaseCanvas.width;
	scratchArea.height=whiteboardBaseCanvas.height;
	scratchArea.drawBackground(0);
	whiteboardBaseCanvas.addChild(scratchArea);
	addMaskCanvas();
	if(!restorBtn.enabled){
	removeShapes();
	drawShapes();
	}
	if(ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording ){
	rezizeTimeOutId=setTimeout(getSize,500);
	} */
}

private function removeShapes():void{
	if (Log.isInfo())		logger.info(" Entered function removeShapes.Page clearing is: " + pageNumber);
	if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES){
		if (userDrawingSprite){
			userDrawingSprite.removeChildren();
		}
		drawingArea.removeChildren();
	}
	else{
		if (userDrawingSprite){
			for (var i:int=userDrawingSprite.numChildren - 1; i > -1; i--)
				userDrawingSprite.removeChildAt(i);
		}
		for (var j:int=drawingArea.numChildren - 1; j > -1; j--)
			drawingArea.removeChildAt(j);
	}
	if (showCollaborator){
		hideCollaboratorNames();
	}
	clearTexttool();
	//garbageCollection.callGarbageCollection();
	pointerShape=null;
	applicationType::DesktopWeb{
		clearBtn.enabled = false;
	}
}

private function addMaskCanvas():void{
	if (Log.isInfo())		logger.info(" Entered function setCurrentTool");
	whiteboardMask.graphics.beginFill(0xffffff, 1);
	whiteboardMask.graphics.drawRect(0, 0, whiteboardBaseCanvas.width, whiteboardBaseCanvas.height);
	whiteboardMask.width = wbCanvas.width;
	whiteboardMask.height = wbCanvas.height;
	wbCanvas.mask=whiteboardMask;
	wbCanvas.addElementAt(whiteboardMask, 0);
}

public function closeAllOpenPannels():void{
	applicationType::DesktopWeb{
		lineColorComboBox.close();
		if (collaborationList.height > 0){
			//collaborationListClose.play();
		}
		if (whiteboardBaseCanvas.contains(eraserOptionBox)){
			whiteboardBaseCanvas.removeElement(eraserOptionBox);
		}
		if (whiteboardBaseCanvas.contains(textToolOptionBox)){
			whiteboardBaseCanvas.removeElement(textToolOptionBox);
			
		}
		if (rightClickMenu){
			rightClickMenu.hide();
		}
	}
	applicationType::mobile{
		//To close the eraser,colorpalatte,collaboration,size,menu and shape callout when presenter takes back the presenter control, if corresponding component is opened.
		if(eraserCallout){
			eraserCallout.close();
			if(collaborationMode == Constants.CM_ALL_STUDENT_CAN_WRITE){
				FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled = true;
			}
		}
		if(colorPalatteCallout){
			colorPalatteCallout.close();
		}
		if(collaborationCallout){
			collaborationCallout.close();
			FlexGlobals.topLevelApplication.whiteBoardTools.btnCollaboration.enabled = true;
		}
		if(FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox){
			FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.closeDropDown();
		}
		if(FlexGlobals.topLevelApplication.whiteBoardTools.wbMenuComp){
			FlexGlobals.topLevelApplication.whiteBoardTools.wbMenuComp.close();
			if(collaborationMode == Constants.CM_ALL_STUDENT_CAN_WRITE){
//				FlexGlobals.topLevelApplication.whiteBoardTools.menuGroup.enabled = true;
				FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
			}
		}
		if(sizeCallout){
			sizeCallout.close();
		}
	}
}

/**
 * Function to remove right click menu list.
 */
public function disableRightClickMenu():void{
	applicationType::DesktopWeb{
		if (rightClickMenu){
			rightClickMenu.hide();
		}
	}
}

/**
 * When presenter navigate to previous page
 */
private function navigateToPreviousPage():void{
	applicationType::DesktopWeb{
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
		if(isPageUpdated[pageNumber]) disableOrEnableNavigation(false);
		var prevPageNumber:int=pageNumber;
		pageNumber--;
		isPageUpdated[pageNumber] = false;
		//currentPageNumericStepper.value=pageNumber;
		if (pageNumber == 1){
			previousBtn.enabled=false;
			previousBtn.toolTip="";
		}
		closeAllOpenPannels();
		sendPageInfoToAllNodes(prevPageNumber, pageNumber)
		//uploadThePageToServer(tempPageNo);
		whiteBoardPageChangeEventLog(pageNumber, totalPages, "PreviousPage");
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING",MessageBox.MB_OK,this,null,null,MessageBox.IC_ALERT);
			return;
		}
		
		var prevPageNumber:int=pageNumber;
		pageNumber--;
		//AVCM:currentPageNumericStepper.value=pageNumber;
		if(pageNumber==1){
			previousBtn.enabled=false;
			previousBtn.toolTip="";
		}
		closeAllOpenPannels();
		sendPageInfoToAllNodes(prevPageNumber,pageNumber);
	}
}

/**
 *
 * @private
 * Audits the "WhiteBoardPageChange" action, when the presenter changes the whiteboad page
 *
 * @param pageNumber - Current page number
 * @param maxPage - Total number of whiteboard pages currently exist
 * @param navigationMethod - PreviousPage, NextPage, SpecificPage
 * @return void
 *
 */
private function whiteBoardPageChangeEventLog(pageNumber:int, maxPage:int, navigationMethod:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.whiteBoardPageChange, pageNumber + "", maxPage + "", navigationMethod);
	}
}

/**
 * When presenter navigate to a particular page
 */
private function navigateToSpecificPage():void{
	applicationType::DesktopWeb{
		drawingArea.setFocus();
		/*if (isNaN(currentPageNumericStepper.value)){
			currentPageNumericStepper.value=pageNumber;
			return;
		}*/
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			//currentPageNumericStepper.value=pageNumber;
			return;
		}
		//Bug #16385. if user entered any random big number
		if(totalPages<Number(currentPagwb.text)){
			MessageBox.show("Page number is not valid. Please enter a valid page number.", "WARNING", MessageBox.MB_OK, this);
			currentPagwb.text = pageNumber.toString();
			return;
		}
		
		//Bug #18860. If user press enter on pageNumber box without changing anything. Then do not perform any action.
		if(pageNumber==Number(currentPagwb.text)){
			return;
		}
		//Bug fix to avoid pagenumber <= 0. User may enter values 0 or negative values. 
		if(Number(currentPagwb.text) <= 0){
			currentPagwb.text = pageNumber.toString();
			return;
		}
		
		if(isPageUpdated[pageNumber]) disableOrEnableNavigation(false);
		var prevPageNumber:int=pageNumber;
		//Bug #:16398.
		pageNumber=Number(currentPagwb.text);
		isPageUpdated[pageNumber] = false;
		setPreviousButtonToolTip();
		
		closeAllOpenPannels();
		sendPageInfoToAllNodes(prevPageNumber, pageNumber);
		whiteBoardPageChangeEventLog(pageNumber, totalPages, "SpecificPage");
		//uploadThePageToServer(tempPageNo);
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING",MessageBox.MB_OK,this,null,null,MessageBox.IC_ALERT);
			return;
		}
		var prevPageNumber:int=pageNumber;
		if(pageNumber==1){
			previousBtn.enabled=false;
			previousBtn.toolTip="";
		}else if(!previousBtn.enabled){
			previousBtn.enabled=true;
			previousBtn.toolTip="Previous Page";
		}
		closeAllOpenPannels();
		sendPageInfoToAllNodes(prevPageNumber,pageNumber);
	}
}

private function newPageHandler():void
{
	applicationType::DesktopWeb{
		drawingArea.setFocus();
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
		
		var prevPageNumber:int=pageNumber;
		pageNumber = ++totalPages;
		setPreviousButtonToolTip();
		
		closeAllOpenPannels();
		sendPageInfoToAllNodes(prevPageNumber, pageNumber);
		whiteBoardPageChangeEventLog(pageNumber, totalPages, "SpecificPage");
	}
	applicationType::mobile{
		drawingArea.setFocus();
		if (!FlexGlobals.topLevelApplication.mainApp..usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
		
		var prevPageNumber:int=pageNumber;
		pageNumber = ++totalPages;
		setPreviousButtonToolTip();
		
		closeAllOpenPannels();
		sendPageInfoToAllNodes(prevPageNumber, pageNumber);
	}
}

private function setPreviousButtonToolTip():void{
	if (pageNumber == 1){
		previousBtn.enabled=false;
		previousBtn.toolTip="";
	
	}
	else if (pageNumber>1) {
		previousBtn.enabled=true;
		previousBtn.toolTip="Previous Page";
	}
	//RGCR: What if(pageNumber>totalPage)?
}
/**
 * When user write something, the undo array should be cleared.
 */
private function deleteUndoShapes():void{
	if (undoArray.length > 0){
		undoArray.splice(0);
		undoRedoCollaborationObject.setValue("redo", "");
		undoRedoCollaborationObject.setValue("undo", "");
		//Bug #15259.
		undoRedoCollaborationObject.setValue("clearAll", "");
	}
	//Bug #15215. If the last action is restore then remove that, to start a new refreshed set of actions array without clear and restore in between.  
	if (whiteboardShapeArray.length > 0 && whiteboardShapeArray[whiteboardShapeArray.length - 1].toolName == "restore"){
		whiteboardShapeArray.splice(whiteboardShapeArray.length - 1);
	}
	
}

/**
 * send the page information to server so that every one can get it. Also save the previous page
 * in the local cache as well as in the server cache
 */
private function sendPageInfoToAllNodes(previousPageNo:int, currentPageNo:int):void{
	applicationType::DesktopWeb{
		//Bug #15215. Restore button has to be removed.
		//restorBtn.enabled=false;
		if (whiteboardShapeArray.length == 0){
			clearBtn.enabled=false;
		}
		deleteUndoShapes();
	}
	/* if(whiteboardShapeArray.length>0){
	shapeIdWhenUploadStart = whiteboardShapeArray[whiteboardShapeArray.length-1].shapeId
	} */
	//RGCR: Why do we need to send ClassroomContext.lecture.lectureName
	navigationCollaborationObject.setValue("pageInfo", {PageNumberCaching: previousPageNo, currentPageNumber: currentPageNo, totalPage: totalPages, lectureNamet: ClassroomContext.lecture.lectureName});
	
}

/**
 * This method handles when page next button is pressed  */
private function navigateToNextPage():void{
	applicationType::DesktopWeb{
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
		if(isPageUpdated[pageNumber]) disableOrEnableNavigation(false);
		var prevPageNumber:int=pageNumber;
		pageNumber++;
		isPageUpdated[pageNumber] = false;
		//currentPageNumericStepper.value=pageNumber;
		setPreviousButtonToolTip();
		closeAllOpenPannels();
		if (pageNumber > totalPages){
			totalPages++
			//	pageNumDisplay.text="/" + totalPages; //RGCR: Formatting..
		}
		sendPageInfoToAllNodes(prevPageNumber, pageNumber);
		whiteBoardPageChangeEventLog(pageNumber, totalPages, "NextPage");
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING",MessageBox.MB_OK,this,null,null,MessageBox.IC_ALERT);
			return;
		}
		var prevPageNumber:int=pageNumber;
		pageNumber++;
		if(!previousBtn.enabled){
			previousBtn.enabled=true;
			previousBtn.toolTip="Previous Page";
		}
		closeAllOpenPannels();
		if(pageNumber>totalPages){
			totalPages++
		} 
		sendPageInfoToAllNodes(prevPageNumber,pageNumber);
	}
}

/**
 * This method is a fault handler called if some issues happen when deletion of a file is called and not successfuly deleted  */
private function faulthandledel(e:FaultEvent):void{
	if(Log.isError()) logger.error("whiteboard::WhiteBoardHandler::faulthandledel:" + AbstractHelper.getStaticFaultMessage(e));
	MessageBox.show("Application Error (Error Number: S/WB/0004-" + e.fault.faultCode + ")\nPlease contact A-VIEW Administrator.", "ERROR", MessageBox.MB_OK, this);
}


/**
 * This method is called by sync when text tool is cleared.
 * This method removes the un-comitted text area (Text tool to enter text)
 * Three would be only one such text tool at a time.
 *  */
private function clearTexttool():void{
	var str:Object;
	//Traverse through all the children of whiteboardBaseCanvas canvas and remove the text tool
	for (var i:int=0; i < whiteboardBaseCanvas.numElements; i++){
		str=whiteboardBaseCanvas.getElementAt(i);
		var abc:String=str.valueOf();
		if (abc.search("txt_") != -1){
			
			whiteboardBaseCanvas.removeElementAt(i);
			break;
		}
	}
}

/**
 * This function toggles(open/close) the list which contains the collaboaration mode option
 */
private function showCollaborationOptions():void{
	applicationType::DesktopWeb{
		if (collaborationList.height > 0){
		//	collaborationListClose.play();
		}
		else{
		//	collaborationListOpen.play();
		}
	}
	closeAllOpenPannels();
}

/**
 * Used to switch between presenter view and viewer view
 */
public function updateWbControls(isPresenter:Boolean):void{
	clearTimeout(updateControlSetTimeOutId);
	if (!isCollabObjectCreated){
		updateControlSetTimeOutId=setTimeout(updateWbControls, 200, isPresenter);
	}
	else{
		closeAllOpenPannels();
		wbCanvas.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyboardShortcut);
		applicationType::DesktopWeb{
			wbCanvas.addEventListener(MouseEvent.RIGHT_CLICK, handleContextMenu);
		}
		setDrawingPermission();
		if (isPresenter == true){
			//	toolSectection.visible=true;
			setCurrentTool(toolName);
			/* if(whiteboardControlBox.contains(whiteBoardInfo))
			whiteboardControlBox.removeChild(whiteBoardInfo); */
			//applicationType::DesktopWeb{
				//Change #16400
				//presenterControls.visible=true;
				//toolBoxContainer.visible=true; //whiteboardControlBox.addChild(toolBoxContainer);
			//}
			applicationType::mobile{
				previousBtn.visible = true;
				nextBtn.visible = true;
				//To enable whiteboard menu button
//				FlexGlobals.topLevelApplication.whiteBoardTools.menuGroup.enabled = true;
				FlexGlobals.topLevelApplication.whiteBoardTools.btnMenu.enabled = true;
				FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.enabled=true;
				FlexGlobals.topLevelApplication.whiteBoardTools.btnCollaboration.enabled=true;
				FlexGlobals.topLevelApplication.whiteBoardTools.btnEraser.enabled=true;
				FlexGlobals.topLevelApplication.whiteBoardTools.wbToolBox.enabled=true
//				FlexGlobals.topLevelApplication.whiteBoardTools.menuGroup.enabled = true;
			}
			//RGCR: Write all the code related to permissions together
			//RGCR: We should see if we can do these operations on the syncHandler,
			enableWriting();
			disableOrEnableNavigation(true);
			
			//RGCR: Set the shared object properties on server side
			//Bug #15728. Invoked the collaboration mode change only if it is a first time load. (Reconnection will not affect).
			logger.info("Before checking connection retrys in updateWbControls function");
			//Functionalities which do not execute at the time of reconnection. Execute only first time load.
			applicationType::DesktopWeb{
				if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.connectionRetrys > 0){
					logger.info("There is no connection retry so can set the default collaboration mode. Connection retrys: "+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.connectionRetrys)
					checkMousePointer();
				}
			}
			applicationType::mobile{
				if (!FlexGlobals.topLevelApplication.mainApp.usersConnection.connectionRetrys > 0){
					checkMousePointer();
				}
			}			
			
			//PNCR: when a reconnection happens/ presenter control given, then it should use the last collaboration mode instead of default SELECTED USERS mode.
			var mode:String = (collaborationMode == null ? Constants.CM_SELECTED_STUDENT_CAN_WRITE : collaborationMode);
			collaborationModeCollaborationObject.setValue("collaborationMode", mode);
			//RGCR: Should we set collaborationMode here as well?
			updateCollaborationStatus(mode);
			//wbFmsConnection.call("setPageInfo", null, pageNumber,pageNumber,totalPage,ClassroomContext.lectureName)
			
			//pointerEnabled=true;
			if (!wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
				wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler)
			if (hideWbCanvas){
				whiteboardBaseCanvas.removeElement(hideWbCanvas);
				hideWbCanvas=null;
			}
		}
		else{
			if (showCollaborator){
				showCollaborator=false;
				hideCollaboratorNames();
			}
			if (previewAlert){
				PopUpManager.removePopUp(previewAlert);
				removePreviewShapesFromPage();
				drawShapes();
				previewAlert=null;
			}
			applicationType::DesktopWeb{
				if (movableTextArea && textAreaEditable){
					commitText();
				}
			}
			if (pointerShape != null){
				removePointer()
			}
			//pointerEnabled=true;
			logger.info ("Mousemove missing: in updateWbControls if the user is not presenter = "+isPresenter.toString())
			if (wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
				wbCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler)
			applicationType::mobile{
				previousBtn.visible = false;
				nextBtn.visible = false;
			}
			//applicationType::DesktopWeb{
				//Change #16400
				//presenterControls.visible=false;
				//toolBoxContainer.visible=false;
			//}
			//RGCR: We can just call the synchandler
			collaborationMode=collaborationModeCollaborationObject.getData()["collaborationMode"];
			setDrawingPermission();
			//Change #16571
			disableOrEnableNavigation(false);
		}
	}
}
private function checkMousePointer():void{
	//PNCR: commented the action, because it is again calling after if condition. 
	//var mode:String = (collaborationMode == null ? Constants.CM_SELECTED_STUDENT_CAN_WRITE : collaborationMode);
	//collaborationModeCollaborationObject.setValue("collaborationMode", mode);
	//RGCR: Should we set collaborationMode here as well?
	//updateCollaborationStatus(mode);
	//Bug #15289. Do not change pointer status at the time of reconnection.
	if (pointerShape == null){
		createMousePointer();
	}
}

/**
 * Function to remove the text tool box. 
 * This is called in two actions
 * 1. At the time of commit tool text.
 * 2. At the time of cancel tool text, when the user move to another page before completing the action.
 */
//PNCR: #BugFix: 14756, 14874, 14875.
private function removeTextArea():void{
	applicationType::DesktopWeb{
		objectHandleForTextArea.selectionManager.clearSelection();
		objectHandleForTextArea.removeEventListener(ObjectChangedEvent.OBJECT_MOVED, onObjectMovedHandler);
		objectHandleForTextArea.unregisterComponent(movableTextArea);
		
		drawingArea.setFocus();
		
		if (drawingArea.contains(movableTextArea)){
			drawingArea.removeChild(movableTextArea);
			whiteboardShape.shapeName=movableTextArea.name;
		} 
		else if (wbCanvas.contains(movableTextArea)){
			//PNCR: #BugFix:15098. Added an elseif condition to check whether this items is present or not.
			//On pasteText action textbox will create on parent canvas not on drawing area. Remove that
			wbCanvas.removeElement(movableTextArea);
			//On mouse click after pasteText there will be an unnecessary userDrawingSprite will be in drawing area. Remove that
			//Else there will be two childs in drawingArea with same name. 
			if (userDrawingSprite && drawingArea.contains(userDrawingSprite)){
				drawingArea.removeChild(userDrawingSprite);
			}
		}
		textAreaEditable=false;
		movableTextArea=null;
	}
}

private function commitText(isObjectSelection:Boolean=false):void{
	applicationType::DesktopWeb{
		//This function will remove the old text from drawing area.
		removeTextArea();
		
		if (previousTool != ""){
			setCurrentTool(previousTool);
			previousTool="";
		}
		if (dataModelForTextArea.text != ""){
			whiteboardShape.shapeX=(dataModelForTextArea.x);
			whiteboardShape.shapeY=(dataModelForTextArea.y);
			whiteboardShape.txtToolFnt=textFondStepper.value;
			whiteboardShape.txt_str=dataModelForTextArea.text;
			whiteboardShape.txtAreaWidth=dataModelForTextArea.width;
			whiteboardShape.txtAreaHeight=dataModelForTextArea.height;
			
			//PNCR: Bug #15286. Commented to avoid unnecessary drawing. The same object is passed via collaboration object. and will draw when collaboration sync happends.
			var sprite:Sprite=whiteboardShape.drawShape(wbCanvas.width, wbCanvas.height, backgroundColor);
			sprite.name=whiteboardShape.shapeName;
			drawingArea.addChild(sprite);
			if (isSelectionMode){
				sprite.addEventListener(MouseEvent.MOUSE_DOWN, onTextSelect);
			}
			
			if (!isObjectSelection){
				shapeCollaborationObject.addValue(whiteboardShape);
			}
			else{
				if (textContentWhenSelected != whiteboardShape.txt_str){
					shapeSelectionCollaborationObject.setValue(whiteboardShape.shapeName + "_textChange", 
						{action: "textChange", shapeName: whiteboardShape.shapeName, newText: whiteboardShape.txt_str,pageNum:whiteboardShape.pageNo});
				}
			}
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("addGraphic", null,whiteboardShape,ClassroomContext.lecture.lectureName+"|"+pageNumber);
			makePointerAsTopChild();
			if (showCollaborator){
				showCollaboratorForShape(whiteboardShape);
			}
		}
		
		//Bug #15180, 15179. If user selects an existing text and clear data then, Remove the shape from both collaboration object and shape array.
		else if (isExistingShape(whiteboardShape.shapeName)){
			shapeSelectionCollaborationObject.setValue(whiteboardShape.shapeName + "_textChange", 
				{action: "textChange", shapeName: whiteboardShape.shapeName, newText: whiteboardShape.txt_str,pageNum:whiteboardShape.pageNo});
			
		}
		
		
		if (pointerIcon == removePointerIcon && showPointer.enabled && pointerShape == null && !isObjectSelection){
			createMousePointer();
			showPointer.enabled=true;
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && !wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
				wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
		}
		//textAreaEditable=false;
		//movabeTextArea=null;
	}
}

/**
 * Enable or disable the pointer sharing functionality
 */
private function enableDisablePointer():void{
	
	
	//toolSelect="";
	applicationType::DesktopWeb{
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
		closeAllOpenPannels();
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
		}
		else{
			if (pointerIcon == showPointerIcon){
				if (!wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
					wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
				showPointer.toolTip="Remove Pointer";
				pointerIcon=removePointerIcon;
				if (pointerShape == null)
					createMousePointer();
				pointerShape.x=whiteboardBaseCanvas.width / 2;
				pointerShape.y=whiteboardBaseCanvas.height / 2;
				whiteBoardPointerEventLog(String(pageNumber), "Pointer Enabled");
				//RGCR: Set the shared object properties on server side
				pointerCollaborationObject.lock();
				pointerCollaborationObject.setValue("pointerStatus", "enabled");
				pointerCollaborationObject.setValue("pointerPosition", {x: whiteboardBaseCanvas.width / 2, y: whiteboardBaseCanvas.height / 2, width: wbCanvas.width, height: wbCanvas.height});
				pointerCollaborationObject.unlock();
				
			}
			else{
				pointerIcon=showPointerIcon;
				showPointer.toolTip="Enable Pointer";
				whiteBoardPointerEventLog(String(pageNumber), "Pointer Disabled");
				//RGCR: Set the shared object properties on server side
				pointerCollaborationObject.setValue("pointerStatus", "disabled");
				removePointer();
			}
		}
	}
	applicationType::mobile{
		if(!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING",MessageBox.MB_OK,this,null,null,MessageBox.IC_ALERT);
		}else{
			if(FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon == showMobilePointerIcon)
			{
				if(!wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
					wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
				FlexGlobals.topLevelApplication.whiteBoardTools.showPointer.toolTip="Remove Pointer";
				pointerIcon = removePointerIcon;
				FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon = removeMobilePointerIcon;
				if(pointerShape==null)
					createMousePointer();
				pointerShape.x= whiteboardBaseCanvas.width/2;
				pointerShape.y =whiteboardBaseCanvas.height/2;
				pointerCollaborationObject.lock();
				pointerCollaborationObject.setValue("pointerStatus", "enabled");
				pointerCollaborationObject.setValue("pointerPosition", {x: whiteboardBaseCanvas.width / 2, y: whiteboardBaseCanvas.height / 2, width: wbCanvas.width, height: wbCanvas.height});
				pointerCollaborationObject.unlock();
				
			}else{
				pointerIcon = showPointerIcon;
				FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon = showMobilePointerIcon;
				FlexGlobals.topLevelApplication.whiteBoardTools.showPointer.toolTip="Enable Pointer";
				pointerCollaborationObject.setValue("pointerStatus", "disabled");
				removePointer();
			}
		}
	}
	toolSelection();
}

/**
 *
 * @private
 * Audits the "WhiteBoardPointer" action, when the presenter/user enables/disables the pointer
 *
 * @param pageNumber - Current page number
 * @param pointerMode - Pointer Enabled or Pointer Disabled
 * @return void
 *
 */
private function whiteBoardPointerEventLog(pageNumber:String, pointerMode:String):void
{
	AuditContext.userAction.createAction(AuditConstants.whiteBoardPointer, pageNumber, pointerMode, null);
}

private function enableSelection():void{
	applicationType::DesktopWeb{
		for (var i:int=0; i < drawingArea.numChildren; i++){
			var obj:Object=drawingArea.getChildAt(i);
			if ((obj is WhiteboardShapeSprite || obj is MoveableTextArea) && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && obj.drawnBy == ClassroomContext.userVO.userName))){
				if (obj is WhiteboardShapeSprite && obj.shapeType != "e") { //&& isSelectableShape(obj.name ))
					obj.addEventListener(MouseEvent.MOUSE_DOWN, onShapeSelect);
				}
				else if (obj is MoveableTextArea && obj.shapeType == "txt"){
					obj.addEventListener(MouseEvent.MOUSE_DOWN, onTextSelect);
				}
			}
		}
	}
}

private function disableSelection():void{
	applicationType::DesktopWeb{
		for (var i:int=0; i < drawingArea.numChildren; i++){
			var obj:Object=drawingArea.getChildAt(i);
			//Bug #15183. Added remove listner for both object and text at the time of disable selection.
			if (obj.hasEventListener(MouseEvent.MOUSE_DOWN)){
				obj.removeEventListener(MouseEvent.MOUSE_DOWN, (obj is WhiteboardShapeSprite ? onShapeSelect : onTextSelect));
			}
		}
	}
}
private var isSelectionMode:Boolean=false;
private var lastSelected:String;
private function removeSelection(needCommit:Boolean=false):void{
	applicationType::DesktopWeb{
		if (objectHandleForShape.selectionManager.currentlySelected.length > 0){
			var currObject = objectHandleForShape.selectionManager.currentlySelected.pop()
			lastSelected = currObject.name;
			objectHandleForShape.unregisterComponent(currObject);
			objectHandleForShape.selectionManager.clearSelection();
			//showCollaboratorForSahpe(currObject as WhiteboardShape);
		}
		if (objectHandleForTextArea.selectionManager.currentlySelected.length > 0){
			lastSelected = movableTextArea.name;
			if (needCommit){
				commitText(true);
			}
			else{
				objectHandleForTextArea.unregisterModel(objectHandleForTextArea.selectionManager.currentlySelected.pop());
				objectHandleForTextArea.selectionManager.clearSelection();
			}
		}
	}
}

/**
 * Function to enable the object selection. It will call when user click on the "Select object" button
 */
private function enableObjectSelection(){
	applicationType::DesktopWeb{
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
		toolName = "os";
		changePresenterButtonsMode(true);
		isSelectionMode=true;
		btnSelect.enabled = false;
		enableSelection();
		if (pointerShape != null){
			drawingArea.removeChild(pointerShape);
			pointerShape=null;
		}
	}
	toolSelect="os";
}

/**
 * Function to disable the object selection. 
 * It will call when user click on the any other button and the "Select object" is enabled.
 */
private function disableObjectSelection(){
	applicationType::DesktopWeb{
		isSelectionMode=false;
		btnSelect.enabled = true;
		removeSelection();
		disableSelection();
		if (pointerShape == null){
			createMousePointer()
		}
		commitUncommitedTexts();
	}
}
/*
//PNCR: currently not using changed to two seperate enable and disable functions since it is called from two different actions.
private function enableDisableSelection():void{
	var data:Object=navigationCollaborationObject.getData();
	if (isSelectionMode){
		isSelectionMode=false;
		//btnSelect.enabled = true;
		removeSelection();
		disableSelection();
		if (pointerShape == null){
			createMousePointer()
		}
		
	}
	else{
		isSelectionMode=true;
		//btnSelect.enabled = false;
		enableSelection();
		if (pointerShape != null){
			drawingArea.removeChild(pointerShape)
			pointerShape=null;
		}
	}
}
*/
private function getShapeIndex(shapeName:String):int{
	var index:int=-1;
	for (var i:uint; i < whiteboardShapeArray.length; i++){
		if (whiteboardShapeArray[i].shapeName == shapeName){
			index=i;
			break;
		}
	}
	return index;
}
/**
 * Function to check whether tha shapename is already present in whiteboard or not.
 */
private function isExistingShape(shapeName):Boolean {
	return (getShapeIndex(shapeName) > -1 ? true : false);
}

private var undoArray:Array=new Array()

private function undo():void{
	applicationType::DesktopWeb{
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	}
	//Bug #15215. If the last action is clear then call restore instead or undoing a shape.
	if (whiteboardShapeArray.length>0 && whiteboardShapeArray[whiteboardShapeArray.length - 1].toolName == "clear"){
		restoreLastClear();
	}
	else
	{
		if (whiteboardShapeArray.length > 0){
			//Bug #15215. If user click undo two times after clear, then remove the last restore action from array; and perform the undo for other object. 
			if (whiteboardShapeArray[whiteboardShapeArray.length - 1].toolName == "restore"){
				whiteboardShapeArray.splice(whiteboardShapeArray.length - 1);
			}
			undoRedoCollaborationObject.setValue("undo", whiteboardShapeArray[whiteboardShapeArray.length - 1].shapeName);
			undoRedoCollaborationObject.setValue("redo", "");
		}
	}
	toolSelection();
}


private function redo():void{
	applicationType::DesktopWeb{
		btnEraser.setStyle("imageSkin",EraseToolImage);
		btnShapes.setStyle("imageSkin",ShapeDefault);
		btnTextTool.setStyle("imageSkin",enableTextToolImage);
	}
	//Bug #15215. If the last action is restore then call clear instead or redoing a shape.
	if (whiteboardShapeArray.length > 0 && whiteboardShapeArray[whiteboardShapeArray.length - 1].toolName == "restore"){
		clearScratchPad();
	}
	else{
		if (undoArray.length > 0){
			undoRedoCollaborationObject.setValue("redo", undoArray[undoArray.length - 1].shapeName);
			undoRedoCollaborationObject.setValue("undo", "");
		}
	}
	toolSelection();
}

private function toolSelection()
{
	
	switch(toolSelect)
	{
		case "r":setRectTool(eve);
			break;
		case "c":setCircleTool(eve);
			break;
		case "st":setlineTool();
			break;
		case "txt":setTexttool();	
			break;
		case "m":setEraserTool(eve,"m");
			break;
		case "s":setEraserTool(eve,"s");
			break;
		case "l":setEraserTool(eve,"l");
			break;
	}
}

/**
 * This function restor the clear function
 */
private function restoreLastClear():void{
	applicationType::DesktopWeb{
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
	}
	applicationType::mobile{
		if (!FlexGlobals.topLevelApplication.mainApp.usersConnection.netConnection.connected){
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
	}
	closeAllOpenPannels();
	var shapeObj:WhiteboardShape=new WhiteboardShape();
	shapeObj.toolName="restore";
	shapeObj.lineColor="#000000";
	shapeObj.lineThickness=0;
	shapeObj.lineAlfa=0
	shapeObj.drawnBy=ClassroomContext.userVO.userName
	shapeObj.drawnAreaWidth=wbCanvas.width;
	shapeObj.drawnAreaHeight=wbCanvas.height;
	shapeObj.pageNo=pageNumber;
	var date:Date=new Date();
	shapeObj.shapeId=currentShapeId;
	shapeObj.shapeName=ClassroomContext.userVO.userName + date.time;
	shapeCollaborationObject.addValue(shapeObj);
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("addGraphic", null,shapeObj,ClassroomContext.lecture.lectureName+"|"+pageNumber);
	whiteBoardRestoreEventLog(pageNumber);
	applicationType::mobile{
		FlexGlobals.topLevelApplication.whiteBoardTools.isClearClicked = false;
		FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.setStyle("icon",FlexGlobals.topLevelApplication.whiteBoardTools.clearIcon);
		FlexGlobals.topLevelApplication.whiteBoardTools.btnClearRestore.toolTip = "Clear Whiteboard";
	}
}

/**
 *
 * @private
 * Audits the "WhiteBoardRestore" action, when the presenter restores the cleared whiteboard
 *
 * @param pageNumber - Current page number
 * @return void
 *
 */
private function whiteBoardRestoreEventLog(pageNumber:int):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.whiteBoardRestore, pageNumber + "", null, null);
	}
}

private function enableWriting():void{
	//PNCR: //#BugFix: 14630. Enable presenter control button when user get presenter control.
	isCollaborationModePresenter = true;
	if (!wbCanvas.hasEventListener(MouseEvent.MOUSE_DOWN)){
		wbCanvas.addEventListener(MouseEvent.MOUSE_DOWN, drawingAreaMouseDownHandler);
	}
	
}

private function disableWriting():void{
	//PNCR: //#BugFix: 14630. Enable presenter control button when user get presenter control.
	isCollaborationModePresenter = false;
	if (wbCanvas.hasEventListener(MouseEvent.MOUSE_DOWN)){
		wbCanvas.removeEventListener(MouseEvent.MOUSE_DOWN, drawingAreaMouseDownHandler);
	}
}

private function drawShapesAfterLogin(evnt:FlexEvent):void{
	wbCanvas.removeEventListener(FlexEvent.UPDATE_COMPLETE, drawShapesAfterLogin);
	drawShapes();
	//If there was a selection before resize, then enable the same object selection with new size.
	if(lastSelected){
		applicationType::DesktopWeb{
			var selectedObject:DisplayObject = drawingArea.getChildByName(lastSelected) as DisplayObject
			if (selectedObject is MoveableTextArea)
				selectText(selectedObject as MoveableTextArea);
			else
				selectShape(selectedObject as WhiteboardShapeSprite);
		}
	}
}

protected function whiteboardBaseCanvas_resizeHandler(event:ResizeEvent):void{
	wbCanvas.addEventListener(FlexEvent.UPDATE_COMPLETE, onWbBaseCanvaseResizeComplete);
	//resizeTimeOut=setTimeout(onWbBaseCanvaseResizeComplete,100);
}

private function onWbBaseCanvaseResizeComplete(evnt:FlexEvent):void{
	if (Log.isInfo())		logger.info(" Entered function onWbBaseCanvaseResizeComplete");
	wbCanvas.removeEventListener(FlexEvent.UPDATE_COMPLETE, onWbBaseCanvaseResizeComplete);
	//clearTimeout(resizeTimeOut);
	applicationType::DesktopWeb{
		var constraint2:MovementConstraint=new MovementConstraint();
		constraint2.minX=5;
		constraint2.minY=5;
		constraint2.maxX=wbCanvas.width - 5;
		constraint2.maxY=wbCanvas.height - 5;
		if (objectHandleForTextArea)
			objectHandleForTextArea.changeDefaultMoveConstraint(constraint2);
		applicationType::desktop{
			if (!this.systemManager.stage.nativeWindow.visible || this.systemManager.stage.nativeWindow.stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED){
				if (Log.isInfo()) logger.info("onWbBaseCanvaseResizeComplete:Minimized state");
			}
			//Bug #15171
			//The whiteboard shapes draw (with scale) has to be called at every window resize. Even if it is minimized.  
			onWbBaseCanvaseResizeCompleteHandler();
		}
		applicationType::web{
			if (AVCEnvironment.os != AVCEnvironment.ANDROID || AVCEnvironment.os != AVCEnvironment.IOS){// && (!this.systemManager.stage.nativeWindow.visible || this.systemManager.stage.nativeWindow.stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)){
				if (Log.isInfo()) logger.info("onWbBaseCanvaseResizeComplete:Minimized state");
			}
			onWbBaseCanvaseResizeCompleteHandler();
		}
	}
	applicationType::mobile{
		if(showCollaborator)
		{
			hideCollaboratorNames();
			showCollaboratorNames();
		}
		onWbBaseCanvaseResizeCompleteHandler();
	}
	if (Log.isInfo())		logger.info(" onWbBaseCanvaseResizeComplete:previousWbWidth: " + previousBaseContainerWidth + ":previousWbHeight:" + previousBaseContainerHeight);
}
//RTCR: Need to change the function name
private function onWbBaseCanvaseResizeCompleteHandler():void{
	if (hideWbCanvas != null){
		hideWbCanvas.width=whiteboardBaseCanvas.width;
		hideWbCanvas.height=whiteboardBaseCanvas.height;
		whiteboardBaseCanvas.setElementIndex(hideWbCanvas, whiteboardBaseCanvas.numElements - 1)
	}
	
	//On window resize disable the selection and then enable it. othewise the selection box size will persist the last selected object size.
	applicationType::DesktopWeb{
		if (objectHandleForShape){
			lastSelected = null;
			removeSelection(true);
			if (toolName=="os")
				btnSelect.enabled=false;
		}
		//Bug #16656. By default object handle will create only for initial wbCanvas area. it has to recreate when wb resize. 
		//createObjectHandle();
	}
	//Mask is required to prevent mouse movement outside wbcanvas.
	/*if(whiteboardMask){
		if (wbCanvas.contains(whiteboardMask))
			wbCanvas.removeElement(whiteboardMask);
		addMaskCanvas();
	}*/
	
	if (previousBaseContainerWidth > 0 && previousBaseContainerHeight > 0 && whiteboardBaseCanvas.width > 0 && whiteboardBaseCanvas.height > 0){
		//Commented because, For the initial call, it will reach here only after UPDATE_COMPLETE. so added drawShapes() directly instead of an event call.
		if (!wbCanvas.hasEventListener(FlexEvent.UPDATE_COMPLETE)){
			wbCanvas.addEventListener(FlexEvent.UPDATE_COMPLETE, drawShapesAfterLogin);
		}
		//drawShapes();
		//PNCR: wbCanvas size has been changed to 100% instead of fixed width and height, so the scaling(streaching) is not required any more.
		wbCanvas.scaleX*=(whiteboardBaseCanvas.width / previousBaseContainerWidth);
		wbCanvas.scaleY*=(whiteboardBaseCanvas.height / previousBaseContainerHeight);
		if (Log.isInfo())			logger.info(" onWbBaseCanvaseResizeComplete. Scaling the Whiteboard. " + "previousWbWidth: " + previousBaseContainerWidth + ":previousWbHeight:" + previousBaseContainerHeight + "whiteboardBaseCanvas width: " + whiteboardBaseCanvas.width + " whiteboardBaseCanvas height: " + whiteboardBaseCanvas.height);
	}
	else if (!wbCanvas.contains(drawingArea)){
		//Initialize the whitebaord UI
		if (Log.isInfo())			logger.info(" onWbBaseCanvaseResizeComplete:!wbCanvas.contains(scratchArea)");
		////////////////////////////////////////////////////////////////////////////
		// Create and add the UI component for drawing shapes
		// scratchArea is a custom component based on UIComponent. All drawing sprites are get
		//added as the child of scratchArea
		//whiteboardBaseCanvas is a canvas that holds the drawing area of the white board
		//PNCR: no need to change the drawing area size, it will change dynamically. 
		drawingArea.width=whiteboardBaseCanvas.width;
		drawingArea.height=whiteboardBaseCanvas.height;
		wbCanvas.addElement(drawingArea);
		//scratchArea.drawBackground(backgroundColor);
		//whiteboardBaseCanvas.addEventListener(ResizeEvent.RESIZE, resize);
		// Define mask sprite.
		// mask is to create a hole through which the contents of another display object are visible.
		whiteboardMask=new Group();
		//PNCR: Mask is not required, it's size will not change dynamically according to the parent.
		addMaskCanvas();
		//wbCanvas.addEventListener(MouseEvent.ROLL_OUT, scratchAreaMouseOutHandler);
		//drawShapes();
		previousBaseContainerWidth=whiteboardBaseCanvas.width;
		previousBaseContainerHeight=whiteboardBaseCanvas.height;
		whiteboardBaseCanvas.percentHeight=100;
		whiteboardBaseCanvas.percentWidth=100;
	}
		
	if (whiteboardBaseCanvas.width > 0 && whiteboardBaseCanvas.height > 0){
		previousBaseContainerWidth=whiteboardBaseCanvas.width;
		previousBaseContainerHeight=whiteboardBaseCanvas.height;
	}
	applicationType::DesktopWeb{
		if (ConfigFileReader.configValues.Whiteboard.DebugMode ==1){
			testLabel.text = whiteboardBaseCanvas.width.toString()+" : "+whiteboardBaseCanvas.height.toString() + "\n";
			testLabel.text += wbCanvas.width.toString()+" : "+wbCanvas.height.toString()+"\n";
			testLabel.text += drawingArea.width.toString()+" : "+drawingArea.height.toString();
		}
	}
}

protected function whiteboardControlBox_resizeHandler(event:ResizeEvent):void{
	// TODO Auto-generated method stub
	//PNCR: #BugFix: 14978. On resize enable object selection if that button is active.
	if (!isSelectionMode)
		setCurrentTool(toolName);
	else
		enableObjectSelection();
	
}

protected function toolBoxContainer_showHandler(event:FlexEvent):void{
	// TODO Auto-generated method stub
	setCurrentTool(toolName);
}

protected function toolBoxContainer_mouseDownHandler(event:MouseEvent):void{
	applicationType::DesktopWeb{
		if (!btnEraser.enabled && toolBoxContainer.mouseX > 168 && toolBoxContainer.mouseX < 183 && toolBoxContainer.visible){
			if (whiteboardBaseCanvas.contains(textToolOptionBox)){
				whiteboardBaseCanvas.removeElement(textToolOptionBox);
			}
			whiteboardBaseCanvas.addElement(eraserOptionBox);
			eraserOptionBox.x=toolBoxContainer.x + btnEraser.x + 2;
			eraserOptionBox.y=0;
		}
		//else if (!btnTextTool.enabled && toolBoxContainer.mouseX > 210 && toolBoxContainer.mouseX < 230 && toolBoxContainer.enabled){
			if (whiteboardBaseCanvas.contains(eraserOptionBox)){
				whiteboardBaseCanvas.removeElement(eraserOptionBox);
			}
			//whiteboardBaseCanvas.addElement(textToolOptionBox);
			//textToolOptionBox.x=toolBoxContainer.x + btnTextTool.x + 2;
			//textToolOptionBox.y=0;
		//}
	}
}


/**
 * Starting point of all menu button click handler. 
 * Functions which are common to all buttons will describe here.
 */
// PNCR: added this function to disable "Select object" button if user click on any button after object selection.
protected function menuButtonClickHandler(event:MouseEvent):void
{	
	
	applicationType::DesktopWeb{
		var drawingButtons:Array = ["btnRectangel","btnCircle","btnLine","btnFreehand","btnTextTool","btnEraserSmall","btnEraserMedium","btnEraserLarge"] //"btnEraser","btnShapes"
		
		//If any of the menu button is clicked.
		//if (["ImageButton", "Button","Label", "Image"].indexOf(event.target.className) >= 0){
			//if user click on drawing button before committing the text. then commit it and go back to selected drawing button.
		//Change #16369. Commit text on any toolbox button click.
		if (movableTextArea){
			previousTool = toolName;
			commitUncommitedTexts();
		}
		//PNCR: BugFix: 14968. Disable object selection only at the time of drawing object selection.
		//Bug #16616. If the toolname is object selection then do not disable the section.
		if (isSelectionMode && event.target.id != "btnSelect" && toolName!="os"){ //drawingButtons.indexOf(event.target.id)>=0 && 
			disableObjectSelection();
		}
		
		
		//If user click on any presenter controls buttons after an object selection, then last selected tool will enabled.
		/*if (event.target.parent.id=="presenterControls"){
			setCurrentTool(toolName);
		}*/
		
		//var buttonClickFunctions:Object = {"previousBtn":navigateToPreviousPage,"nextBtn":navigateToNextPage}
		//if (event.target.id in buttonClickFunctions){
		//	var buttonClick:Function = buttonClickFunctions[event.target.id];
		//	buttonClick();
		//}
	}
}

private function popOutBtnVisble(isVisible:Boolean):void{
	applicationType::DesktopWeb{
		if (isVisible){
			popOutBtn.alpha=1;
		}
		else{
			popOutBtn.alpha=0;
		}
	}
}
/**
 * Flag to check whether the whiteboard is popped out or not. 
 */
public var isPopOut:Boolean=false;
public var toolTipForPopOut:String="Pop-out"
/**
 * Function to popout the whiteboard window. 
 */
public function popOutWhiteboardWindow():void{
	applicationType::DesktopWeb{
		if (!isPopOut){
			applicationType::desktop{
				whiteBoardFullWndw=new Whiteboard();
			}
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.wbBox && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.wbBox.contains((this)))

				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.wbBox.removeElement(this);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.wbBox, Constants.FULLSCREEN_MSG);
			//JHCR: Try to add this to the above block
			applicationType::desktop{
				whiteBoardFullWndw.open(true);
				whiteBoardFullWndw.maximize();
				whiteBoardFullWndw.wbComp=this;
				whiteBoardFullWndw.presenterName=ClassroomContext.currentPresenterName;
			}
			popOutBtn.setStyle("icon", popinIcon);
			popOutBtn.toolTip="Pop-in";
			isPopOut=true;
			popOutWhiteBoardEventLog();
		}
		else{
			applicationType::desktop{
				whiteBoardFullWndw.close();
			}
			//toolbarMoveHandler();
			var val:Number;
		
			//toolBoxContainer.x=70;
			
			//propertyTitleBarMoveHandler();
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unSetMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.wbBox);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.init_wb();
				//To show alert when close pop out.
				if (previewAlert)
					//PNCR: added seperate accept and decline event handlers for messagebox.
					previewAlert=MessageBox.show("By selecting 'Yes' button these shapes will be send to all viewers, Do you want to continue?", "Confirmation", MessageBox.MB_YESNO, this.parent as Sprite, acceptPreviewConfirmation,declinePreviewConfirmation);
			}
			isPopOut=false;
			popOutBtn.setStyle("icon", popoutIcon);
			popOutBtn.toolTip="Pop-out";
			
			popInWhiteBoardEventLog();
		}
	}
}

/**
 *
 * @private
 * Audits the "PopInWhiteBoard" action, when the user Pops in/closes the whiteboard tab
 *
 * @return void
 *
 */
private function popInWhiteBoardEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.popInWhiteBoard, null, null, null);
}

/**
 *
 * @private
 * Audits the "PopOutWhiteBoard" action, when the user Pops out the whiteboard tab
 *
 * @return void
 *
 */
private function popOutWhiteBoardEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.popOutWhiteBoard, null, null, null);
}
applicationType::mobile{
	//For AVCM:	To create a draggable and resizable textArea. 
	private function createMobileTextComponent():void
	{
		txtAreaEdit = true;
		textComp = new MobileTextToolComponent();
		textComp.open(wbCanvas);
		textComp.isPopUp = true;
		textComp.x = wbCanvas.mouseX;
		textComp.y = wbCanvas.mouseY;
		textComp.textCompX = wbCanvas.mouseX;
		textComp.textCompY = wbCanvas.mouseY;
		textComp.startX = wbCanvas.mouseX;
		textComp.startY = wbCanvas.mouseY;
		textComp.maxHeight = wbCanvas.height/2;
		textComp.maxWidth = wbCanvas.width/2;
		textComp.addEventListener(PopUpEvent.CLOSE,commitMobileAppText);
		textComp.setFocus();
	}
	//For AVCM: To paste text into scratch area
	private function commitMobileAppText(event:PopUpEvent):void
	{
		txtAreaEdit = false;
		if(event.data!= "")
		{
			if(isPasteActive)
			{
				isPasteActive = false;
				whiteboardShape.shapeX = event.target.startX;//wbCanvas.mouseX;
				whiteboardShape.shapeY = event.target.startY;//wbCanvas.mouseY;
			}
			else
			{
				whiteboardShape.shapeX = event.target.startX;//wbCanvas.mouseX;//event.target.textCompX;
				whiteboardShape.shapeY = event.target.startY;//wbCanvas.mouseY;//event.target.textCompY;
			}
			//To positioning the text msg.
			if(whiteboardShape.shapeX+event.target.textCompWidth > wbCanvas.width)
			{
				whiteboardShape.shapeX = wbCanvas.width - (event.target.textCompWidth);
			}
			if(whiteboardShape.shapeY+event.target.textCompHeight  > wbCanvas.height)
			{
				whiteboardShape.shapeY = wbCanvas.height - (event.target.textCompHeight);
			}
			whiteboardShape.txtToolFnt = event.target.textCompFontSize;
			whiteboardShape.txt_str = event.data;				
			whiteboardShape.txtAreaWidth = event.target.textCompWidth;
			whiteboardShape.txtAreaHeight = event.target.textCompHeight;
			var sprite:Sprite=whiteboardShape.drawShape(wbCanvas.width, wbCanvas.height, backgroundColor);
			sprite.name=whiteboardShape.shapeName;
			drawingArea.addChild(sprite);
			shapeCollaborationObject.addValue(whiteboardShape);
			makePointerAsTopChild();
		}
		if((pointerIcon == removePointerIcon && isMousePointerEnabled && pointerShape == null && AVCEnvironment.deviceType == AVCEnvironment.DESKTOP)||
			(FlexGlobals.topLevelApplication.whiteBoardTools.mobilePointerIcon == removeMobilePointerIcon && isMousePointerEnabled && pointerShape == null))
		{
			createMousePointer();
			isMousePointerEnabled=true;
			if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole ==  Constants.PRESENTER_ROLE &&
				!wbCanvas.hasEventListener(MouseEvent.MOUSE_MOVE))
				wbCanvas.addEventListener(MouseEvent.MOUSE_MOVE, drawingAreaMouseMoveHandler);
		}
		if(showCollaborator)
		{
			showCollaboratorForShape(whiteboardShape);
		}
		if(previousTool!= "")
		{
			setCurrentTool(previousTool);
			previousTool = "";
		}
	}
	//To Create random number for assigning id property to collaborator label
	private function getRandomNumber():Number
	{
		return Math.round(Math.random()*1000);
	}
}
private function toolTitleBarhandleDown(e:Event):void{
	applicationType::DesktopWeb{
		presenterControls.startDrag();
		presenterControls.addEventListener(MouseEvent.MOUSE_MOVE,toolbarMoveHandler);
		//toolbarMoveHandler(presenterControls,this.width,this.height);
	}
}
private function toolTitleBarhandleUp(e:Event):void{
	applicationType::DesktopWeb{
		presenterControls.stopDrag();
		//presenterControls.removeEventListener(MouseEvent.MOUSE_MOVE,toolbarMoveHandler);
	}
}

public function toolbarMoveHandler(e:MouseEvent=null):void
{
	applicationType::DesktopWeb{
		trace("presenterControls.x"+ presenterControls.x+presenterControls.width);
		trace("presenterControls.y"+ presenterControls.y+presenterControls.height)
		trace("wb.width"+ this.width);
		trace("wb.height"+ this.height)
		
		var val:Number;
		//checking with the x position and width 
		if (presenterControls.x < 0)
		{
			presenterControls.x=0;
			presenterControls.stopDrag();
		}
		if ((presenterControls.x + presenterControls.width) >= this.width) {
			val=0;
			val=(presenterControls.x + presenterControls.width) - this.width;
			presenterControls.x=presenterControls.x - val;
			presenterControls.stopDrag();
		}
		//checking with the y position and height 
		if (presenterControls.y < 0)
		{
			presenterControls.y=0;
			presenterControls.stopDrag();
		}
		if ((presenterControls.y + presenterControls.height) >= this.height) {
			val=0;
			val=(presenterControls.y + presenterControls.height) - this.height;
			presenterControls.y=presenterControls.y - val;
			presenterControls.stopDrag();
		}
	}
}


public function propertyTitleBarMoveHandler(e:MouseEvent=null):void
{
	applicationType::DesktopWeb{
		trace("propertiesTitleBar.x"+ toolBoxContainer.x+toolBoxContainer.width);
		trace("propertiesTitleBar.y"+ toolBoxContainer.y+toolBoxContainer.height)
		trace("wb.width"+ this.width);
		trace("wb.height"+ this.height)
		
		var val:Number;
		//checking with the x position and width 
		if (toolBoxContainer.x < 0)
		{
			toolBoxContainer.x=0;
			toolBoxContainer.stopDrag();
		}
		if ((toolBoxContainer.x + toolBoxContainer.width) >= this.width) {
			val=0;
			val=(toolBoxContainer.x + toolBoxContainer.width) - this.width;
			toolBoxContainer.x=toolBoxContainer.x - val;
			toolBoxContainer.stopDrag();
		}
		//checking with the y position and height 
		if (toolBoxContainer.y < 0)
		{
			toolBoxContainer.y=0;
			toolBoxContainer.stopDrag();
		}
		if ((toolBoxContainer.y + toolBoxContainer.height) >= this.height) {
			val=0;
			val=(toolBoxContainer.y + toolBoxContainer.height) - this.height;
			toolBoxContainer.y=toolBoxContainer.y - val;
			toolBoxContainer.stopDrag();
		}
	}
}

private var isMaximizedtb:Boolean = false;

private function showhidetoolTitleBar():void
{
	
	
	applicationType::DesktopWeb{
		
		if(!isMaximizedtb)
		{
			isMaximizedtb = true;
			toolMenu.visible=true;
			presenterControls.height=70; 
			toolsbox.visible=false;
			rotate.play();
			toolshowhideButton.toolTip="Show toolbar";
		}
		else
		{
			isMaximizedtb = false;
			toolMenu.visible=false;
			presenterControls.height=330; 
			toolsbox.visible=true;
			rotate1.play();
			toolbarMoveHandler();
			toolshowhideButton.toolTip="Hide toolbar";
		}
	}
}
private function propertiesTitleBarhandleDown(e:Event):void{
	applicationType::DesktopWeb{
		toolBoxContainer.startDrag();
		toolBoxContainer.addEventListener(MouseEvent.MOUSE_MOVE,propertyTitleBarMoveHandler);
	}
}
private function propertiesTitleBarhandleUp(e:Event):void{
	applicationType::DesktopWeb{
		toolBoxContainer.stopDrag();
	}
}
private var isMaximizedpb:Boolean = false;
private function showhideProbTitleBar():void
{
	applicationType::DesktopWeb{
		if(!isMaximizedpb)
		{
			isMaximizedpb = true;
			propMenu.visible=true;
			toolBoxContainer.width=83; 
			propBox.visible=false;
			rotate2.play();
		}
		else
		{
			isMaximizedpb = false;
			propMenu.visible=false;
			toolBoxContainer.width=418; 
			propBox.visible=true;
			rotate3.play();
			propertyTitleBarMoveHandler();
		}
	}
}

/********************************** UI Related functions ******************************/
/**
 * Bug #16754
 * Function to change the page if the page number gets change.
 */
private function checkCurrPageValueChange():void{
	applicationType::DesktopWeb{
		if (currentPagwb.text != pageNumber.toString()){
			navigateToSpecificPage();
		}
	}
}

/*private function moveHandler(obj:Object):void {
	var val:Number;
	//checking with the x position and width 
	if (obj.x < 0)
		obj.x=0;
	if ((obj.x + obj.width) > whiteboardBaseCanvas.width) {
		val=0;
		val=(obj.x + obj.width) - whiteboardBaseCanvas.width;
		obj.x=obj.x - val;
	}
	//checking with the y position and height 
	if (obj.y < 0)
		obj.y=0;
	if ((obj.y + obj.height) > whiteboardBaseCanvas.height) {
		val=0;
		val=(obj.y + obj.height) - whiteboardBaseCanvas.height;
		obj.y=obj.y - val;
	}
}*/


