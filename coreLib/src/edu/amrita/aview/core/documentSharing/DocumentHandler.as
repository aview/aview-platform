// ActionScript file
import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents.OnSlideClickEvent;
import edu.amrita.aview.core.documentSharing.ispring.as2player.IPlayer;
import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationInfo;
import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationPlaybackController;
import edu.amrita.aview.core.documentSharing.ispring.as2player.SlidePlaybackEvent;
import edu.amrita.aview.core.documentSharing.ispring.as2player.StepPlaybackEvent;
import edu.amrita.aview.core.documentSharing.ispring.flex.PlayerInitEvent;
import edu.amrita.aview.core.documentSharing.singleFileperPage.FileDownloader;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.shared.components.fileManager.FileManager;
}
import edu.amrita.aview.core.shared.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.core.shared.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.core.shared.components.fileManager.events.DownloadRequestedEvent;
import edu.amrita.aview.core.shared.components.fileManager.events.UploadCompletedEvent;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.service.content.ContentService;

import flash.desktop.ClipboardFormats;
import flash.desktop.ClipboardTransferMode;
import flash.display.CapsStyle;
import flash.display.DisplayObjectContainer;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.SoftKeyboardEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.controls.ProgressBar;
import mx.core.FlexGlobals;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.events.ScrollEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.CursorManagerPriority;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;
import mx.resources.ResourceManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import objectResolver.DocumentSharingFac;

import spark.components.HScrollBar;
import spark.components.NavigatorContent;
import spark.components.VScrollBar;
import mx.events.FlexMouseEvent;
import spark.events.PopUpEvent;
import edu.amrita.aview.core.shared.components.fileManager.Upload;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.text.ReturnKeyLabel;
import flash.utils.setInterval;
import flash.utils.clearInterval;
import flash.events.AsyncErrorEvent;
import mx.controls.Alert;
import edu.amrita.aview.core.documentSharing.singleFileperPage.DownloadURLFolder;
import mx.managers.FocusManager;
import edu.amrita.aview.core.video.pretesting.Pretesting;
import edu.amrita.aview.core.documentSharing.ispring.as2player.PlayerEvent;
import edu.amrita.aview.core.playback.components.DocComp;
import edu.amrita.aview.core.entry.ClassRoomSgl;
import edu.amrita.aview.core.entry.ClassroomComponent;
import mx.rpc.http.HTTPService;
import mx.rpc.Fault;
import mx.rpc.AsyncToken;
import mx.collections.ArrayList;
import mx.states.AddChild;
import edu.amrita.aview.core.login.boilerplate.Strings;
import edu.amrita.aview.core.shared.components.mobileComponents.toast.Toast;



applicationType::mobile{
	import edu.amrita.aview.core.shared.components.fileManager.MobileFileManager;
}
/**Platform specific imports*/
applicationType::desktop
{
	import edu.amrita.aview.core.documentSharing.DocSharing;
}
 public static var docBaseRoot="../../AVContent/Upload/Personal/";
/** Variable declaration */
[Embed(source="assets/images/hide-left.png")]
private var hideThumbLeft:Class;
[Bindable]
[Embed(source="assets/images/hide-right.png")]
private var unhideThumbLeft:Class;
[Embed(source="assets/images/hide-down.png")]
private var thumbUp:Class;
[Bindable]
[Embed(source="assets/images/hide-top.png")]
private var thumbDown:Class;
/**
 * Width of Print2Flash container
 */
[Bindable]
private var timeOutSet:uint=0;
[Bindable]
public var isPresnter:Boolean=false;
public var isProgressBarPresent:Boolean=false;
[Bindable]
public var p2fWidth:Number;
/**
 * Height of Print2Flash container
 */
[Bindable]
public var p2fHeight:Number;
/**
 *  IP Address for connecting to the Wamp Server
 */
public var ipAddress:String;

/**
 * user type of the current user like teacher or student or admin
 */
public var userName:String;
/**
 * username of the current presenter
 */
[Bindable]
public var presenterName:String;
public var selectArea:String;
[Bindable]
public var userRole:String;
private var checkFileNew:String;
private var logFile:String;
[Bindable]
private var checkFile:Number=0;

private var checkLogFileCount:Number=0;
private var checkPPTFileName:String;
private var connectionStatus:Boolean=false;

/**
 * the uploaded file location
 */
private var loadedFileURL:String="";

[Bindable]
/**
 * total number of pages of currently loaded document
 */
[Bindable]
public var totalPages:int=parseInt("");
/**
 * shared object for the document module
 */
private var documentCollaborationObject:CollaborationObject=null;

/**
 *  Temperory variable contains the remote file path
 * @default null
 */
/**
 * Store animated variable
 * @default null
 */
/**
 * For store module name
 */
private var usingModule="documentsharing";
/**
 * For set upload status
 */
[Bindable]
public var setUpload:Boolean=true;
/**
 *  To store temp file path
 */
[Bindable]
private var popOutStat:Boolean;
public var temFilePath:String="";
public var isAnimateCheck:String="";
//set to null because when student logins first time,inside sync function
//we are checking whether this string is equal to 'tempPath1' or not.
//The default value of 'tempPath1' is null.  
private var previousRemoteFilePath:String=null;

/**
 * page number retrieving from the shared object on the student side
 * @default 0
 */
private var pagNo:Number=0;
/**
 * the page number which is entered by user for go to particular page
 * @default 1
 */
private var tempNumber:Number=1;
/**
 * flag for identifying the network connection is initialized or not
 * @default false
 */
private var buttonEnable:Boolean=false;
private var onetimeConnect:Boolean=false;
/**
 * current class name which the user logged in
 */
private var teacherClass:String;
/**
 * maximum vertical scroll position retrieving from shared object on student side
 */
public var maxY:Number=0;
/**
 * maximum horizontal scroll position retrieving from shared object on student side
 */
public var maxX:Number=0;

/**
 *  flag for identifying the rotation of documents for the first time in student side
 * 	@default false
 */
private var onetimeConnectStudent:Boolean=false;

/**
 * current horizontal position of document
 */
private var xValue:Number=0;
/**
 * current vertical position document
 */
private var yValue:Number=0;
/**
 * temperory storage of the file path of the currently loaded file
 */
private var tempPath:String="";

//Flag to check whether an file is animated  or not	
public var animatedFile:Boolean
//Issue #34 ---START
/**
 * A flag to identify the 'onDocResize()' function is invoked or not
 *
 */
//false means not invoked the 'onDocResize()' function
private var resizing:Boolean=false;

/**
 * for calculating and storing the percentage of bytes downloaded
 * to the print2flash container
 * @default 0
 */
private var percentLoaded:Number=0;
/**
 * for identifying the download error message is shown or not
 * false means not shown
 * @default false
 */
private var isdownloadErrorShown:Boolean=false;
/**
 * Maximum number of retries performed to re establish document sharing connection,
 * incase the connection gets closed.
 */
private var MAX_DOCUMENTSHARING_CONNECTION_RETRIES:int=30;

/**
 * Current number of retries to re establish document sharing connections
 */
private var documentSharingConnectionRetries:int=0;

/**
 * Wait time between document sharing reconnections
 */
private var DOCUMENTSHARING_CONNECTION_RETRY_WAIT_TIME_MS:int=3000;
/**
 *
 */
private var resourcemanager:ResourceManager=new ResourceManager();
/**
 *
 */
private var connectionTimeoutId:uint;
/**
 * For referring the document's scale factor of X-axis
 */
public var zoomFactorX:Number;
/**
 * For referring the document's scale factor of Y-axis
 */
public var zoomFactorY:Number;
/**
 * For referring the ispring document's scale factor of X-axis at Presenter side
 * @default 1
 */
public var ispringZoomFactorX:Number=1;
/**
 * For referring the ispring document's scale factor of Y-axis
 * @default 1
 */
public var ispringZoomFactorY:Number=1;
/**
 * For referring the Presenter document's scale factor of X-axis at viewer side
 */
private var teacherZoomFactorX:Number;
/**
 * For referring the Presenter document's scale factor of Y-axis at viewer side
 */
private var teacherZoomFactorY:Number;
/**
 * For referring the Presenter ispring document's scale factor of X-axis at viewer side
 */
private var teacherZoomFactorXForAnimated:Number;
/**
 * For referring the Presenter ispring document's scale factor of Y-axis at viewer side
 */
private var teacherZoomFactorYForAnimated:Number;
/**
 * For referring the Presenter's  documnet container Width  at viewer side
 */
private var p2fWidthTeacher:Number;
/**
 * For referring the Presenter's  ispring documnet container Width  at viewer side
 */
private var iSpringWidthTeacher:Number;
/**
 * For referring the Presenter's documnet container Width  at viewer side
 */
private var p2fHeightTeacher:Number;
/**
 * For referring the Presenter's Mouse point
 */
private var pointerShape:Shape;
/**
 * Presenter's Mouse Position
 */
private var pointerX:Number;
/**
 * Presenter's Mouse Position
 */
private var pointerY:Number;
/**
 *container's width before resize
 * @default 0
 */
private var previousWidth:Number=0;
/**
 * container's height before resize
 * @default 0
 */
private var previousHeight:Number=0;
[Bindable]
public var fileNameWidth:Number;
/**
 * FileDownloader class for local caching
 */
private var fileDownloaderObj:FileDownloader=new FileDownloader();
private var downloader:DownloadURLFolder;
[Bindable]
/**
 * page number of currently loaded
 */
private var currentPage:int=parseInt("");
/**
 * local path of currently loaded document
 */
private var localSFPFilePath:String="";
[Bindable]
/**
 * Width of ispring container
 */
public var iSpringWidth:Number;
[Bindable]
/**
 * Height of ispring container
 */
public var iSpringHeight:Number;
/**
 * information about ispring  slide
 */
private var iSpringSlideInfo:IPresentationInfo;
/**
 * Controler of  ispring document
 */
private var iSpringSlideControler:IPresentationPlaybackController;
/**
 * Player of  ispring document
 */
private var iSpringPlayer:IPlayer;
/**
 * Width  of ispring slide
 */
public var iSpringSlideWidth:Number;
/**
 * Height of ispring slide
 */
public var iSpringSlideHeight:Number;
/**
 * Annotation Shape container
 */
private var uiComp:UIComponent
/**
 * For referring the shape objects
 */
private var shapePointSprite:Shape;
/**
 *Shape holder Container
 */
private var userDrawingSprite:Sprite;
/**
 * For storing the Annotation object values
 */
private var shapePointsArray:Array;
/**
 * Thickness of Annotation drawings
 */
private var lineThickness:Number;
/**
 * Alpha of Annotation drawings
 */
private var lineAlpha:Number
/**
 * Color of Annotation drawings
 */
private var lineColor:uint
/**
 *Annotation Tool name
 */
private var toolName:String;
/**
 * Document container's  rotaion degree
 * @default 0
 */
private var rotationDegree:Number=0;
/**
 * Page number of previously loaded
 * @defalut 0
 */
private var previousPage:int=0;
/**
 * Document's scroll direction
 */
private var scrollDirction:String;
/**
 * Document's scroll Position
 */
private var scrollPosition:Number;

/**
 * Document's X scroll Position
 */
public var scrollPositionX:Number;

/**
 * Document's Y scroll Position
 */
public var scrollPositionY:Number;
/**
 * current custom mouse cursor's id
 * @default 0
 */
private var myCursorId:int=0;
/**
 * count of erase operation
 * @default 0
 */
private var eraseCount:Number=0;
/**
 * temporary width of document container
 * @default 0
 */
private var tempP2FWidth:Number=0;
/**
 * Normal scale value of document container
 */
private var normalWidth:Number;
/**
 *
 */
private var getSizeTimeout:uint;
/**
 * The previous role of current user
 */
private var previousRole:String="";
/**
 * Alert message box
 */
private var alert = new MessageBox();
/**
 * To check whether the page is loaded or not.
 * false for page not loaded
 * @default false
 */
private var isPageLoaded:Boolean=false;
/**
 * To check whether the page is Getting Loaded.
 * false for page not loaded
 * @default false
 */
private var isLoadDoc:Boolean=false;
/**
 * To check whether document window is full screen or not
 * false means not fullscreen
 * @default false
 */
public var isPopOut:Boolean=false;
/**
 *  To check whether document local download  is disturbed or not
 *  false means not disturbed
 *  @default false
 */
public var isDownloadDisturbed:Boolean=false;
/**
 *  To check whether user's document download  is allowed or not
 *  false means not allowed
 *  @default false
 */

applicationType::DesktopWeb{
	private var isDownloadPermission:Boolean=false;
}
applicationType::mobile{
	public var isDownloadPermission:Boolean=false;
}
/**
 * To store previous Annotation Tool Nmae
 * 
 */
public var prevTool:String;
/**
 *  To check whether the user is late coming or not
 *  false means not late coming
 *  @default false
 */
private var isLatecomming:Boolean=false;
/**
 *  Thumbnail path for document at presenter side
 */
private var presenterThumbPath:String;
/**
 *  To check whether the new page is loaded or not
 *  false means not changed
 *  @default false
 */
private var isNewPageLoad:Boolean=false;
/**
 *  To check whether  annotation tool pen is selected or not
 *  false means not selected
 *  @default false
 */
private var penSelected:Boolean=false;
/**
 *  To check whether annotation tool highlighter is selected or not
 *  false means not selected
 *  @default false
 */
private var highlighterSelected:Boolean=false;
/**
 *  To check whether annotation tool is removed or not
 *  false means not removed
 *  @default false
 */
private var isAnnotationToolRmoved:Boolean=false;
/**
 *  To check whether the document is unload or not
 *  false means not unloaded
 *  @default false
 */
private var docUnloaded:Boolean=false;
/**
 *  To check whether the Presenter's mouse beeing shared or not
 *  false means not shared
 *  @default false
 */
private var mousePointerShared:Boolean=false;
public var windowMinimized:Boolean=false;
/**
 *  To check whether the document is loaded or not
 *  false means not loaded
 *  @default false
 */
public var isResized:Boolean=false;
public var isZoom:Boolean=false;
private var loadCompletedFlag:Boolean=false;
/**
 *  To check whether the document is ispring file or not
 *  false means not ispring file
 *  @default false
 */
public var pptLoaded:Boolean=false;
/**
 *  To check whether the presenter's  is ispring file or not
 *  false means not ispring file
 *  @default false
 */
private var presenterMousePointer:Boolean=false;
/**
 *  To check whether the presenter's  mouse point beeing shared or not
 *  false means its not shared
 *  @default false
 */
private var teacherMouseout:Boolean=false;
/**
 *  To check whether the initilize process has completed or not
 *  false means not completed yet .
 *  @default false
 */
private var initCalled:Boolean=false;
/**
 *  To check whether the animation change done automatically or not
 *  false means not automatically.
 *  @default false
 */
private var automaticSlideSwitching:Boolean=true;
[Bindable]
public var infoBarWidth:Number=0;
/**
 *  To check whether the page number is valid or not
 *  false means not invalide.
 *  @default false
 */

private var isInvalidePage:Boolean=false;
/**
 *  To check whether the user's thumnail selction  is Horizontal or not
 *  false means not Horizontal.
 *  @default false
 */
private var isHThumb:Boolean=false;
/**
 *  To check whether the user's thumnail selction  is Vertical or not
 *  false means not Vertical.
 *  @default false
 */
private var isVThumb:Boolean=false;
/**
 *  To check whether the prsenter load a new file or not
 *  false means not loaded.
 *  @default false
 */
private var isNewfile:Boolean=false;
/**
 * This for to show user's document downloading progress to local drive
 */
[Bindable]
private var progressBar:ProgressBar;
/**
 * This for to check the viewer/moderator status
 */
public var isDownload:Boolean=false;
/**
 * Collection of thumbnail information like filepath,number etc
 */
[Bindable]
public var holdPop:Number=0;
private const ERROR:String="Error";
public static var spclCharArray:Array=[" ", "~", "!", "@", "#", "$", "%", "^", "&", ",", "*", "(", ")", "'", "+"];
applicationType::mobile{
	[Bindable]
	public var resizeCount:Number = 0;
	[Bindable]
	public var toolItemGap:Number=45;
	[Bindable]
	public var toolWidth:Number;
	[Embed(source="assets/images/show_pointer.png")]
	public var mobileMousePointerEnable:Class;
	
	[Embed(source="assets/images/removepointer.png")]
	public var mobileMousePointerDisable:Class;
	
}

public var recordedRemoteFilePath:String="";
[Bindable]
public var mousePointerShare:Class;
[Bindable]
private var thumbnailDataCollection:ArrayCollection;
[Embed(source="assets/images/mousePointerShare_new.png")]
public var mousePointerEnable:Class;
[Embed(source="assets/images/mousePointerShare_newActive.png")]
public var mousePointerDisable:Class;
[Embed("components/annotations/assets/images/Pen_icon.png")]
private var penCursor:Class;
[Embed("components/annotations/assets/images/highlighter.png")]
private var highlightCursor:Class;
[Bindable]
[Embed(source="assets/images/view-fullscreen1.png")]
public var popoutIcon:Class;
[Bindable]
[Embed(source="assets/images/windows_nofullscreen.png")]
public var popinIcon:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/documentSharing/assets/images/annotate_pencilActive.png")]
private var pencilActive:Class;
[Embed(source="/edu/amrita/aview/core/documentSharing/assets/images/annotate_pencil.png")]
private var pencilDefault:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/documentSharing/assets/images/annotate_marker.png")]
private var annotate_markerDefault:Class;
[Embed(source="/edu/amrita/aview/core/documentSharing/assets/images/annotate_markerActive.png")]
private var annotate_markerActive:Class;


[Bindable]
[Embed(source="/edu/amrita/aview/core/documentSharing/assets/images/annotate_eraser.png")]
private var annotate_eraserDefault:Class;
[Embed(source="/edu/amrita/aview/core/documentSharing/assets/images/annotate_eraserActive.png")]
private var annotate_eraserActive:Class;

private static const THUMB_FOLDER:String="@@-Thumbnails-@@";
private static const SFP_FOLDER_PREFIX:String="_sfp__";

private static const NEWFILE:String="NewFile";
private static const PAGECHANGE:String="PageChange";
private static const ANIMATIONCHANGE:String="StepChange";
private static const DOCROTATION:String="Rotation";
private static const DOCZOOM:String="Scale";
private static const DOCSROLLCHANGE:String="Scroll";
private static const MOUSEPOINT:String="SharingMousePoint";
private static const DOWNLOADACCESS:String="PermissionToDownload";
private static const ANNOTATIONTOOL:String="SetAnnotationTool";
private static const ANNOTATIONOBJECTS:String="SetAnnotationValues";
//added for red5
private static const DELETEDOCUMENT:String="Delete";
private var dragSupportedFiles:Array=new Array("pdf","ppt","jpg","doc","docx","pptx","xlsx","bmp","gif","xls","txt");
private static const PERMISSION:String=ResourceManager.getInstance().getString('myResource', 'documentas.allowdownload');
private static const UNLOAD:String=ResourceManager.getInstance().getString('myResource', 'documentas.unloadthisdocument');
private static const DENY_PERMISSION:String=ResourceManager.getInstance().getString('myResource', 'documentas.denydownload');
private static const DOWNLOAD:String=ResourceManager.getInstance().getString('myResource', 'documentas.downloaddocument');
private static const ANNOTATE:String=ResourceManager.getInstance().getString('myResource', 'documentas.annotationtool');
private static const REMOVE_ANNOTATE:String=ResourceManager.getInstance().getString('myResource', 'documentas.removeannotation');
private static const PERMISSION_DENY_STATUS_MSG:String=ResourceManager.getInstance().getString('myResource', 'doccomp.permissionstatustext');
private static const PERMISSION_GRANT_STATUS_MSG:String=ResourceManager.getInstance().getString('myResource', 'documentas.viewercandownload');
private static const HILIGHT_COLOR:uint=0xf2ef09;
private static const HILIGHT_THICKNESS_ANIMATED:Number=20;
private static const HILIGHT_THICKNESS_NONANIMATED:Number=40;
private static const HILIGHT_ALPHA:Number=.4;
private static const PEN_COLOR:uint=0x000000;
private static const PEN_THICKNESS_ANIMATED:Number=3;
private static const PEN_THICKNESS_NONANIMATED:Number=5;
private static const PEN_ALPHA:Number=1;
//--- Custom context menu logic starts ---	
public var contextMenuList:mx.controls.List;
/**Array that stores the menu items in the context menu
 */
[Bindable]
private var contextMenuArray:Array=new Array();

/**This flag is set for Presenter or if Download access is given to Viewers
 */
[Bindable]
private var rightClickAllowed:Boolean=false;
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.edu.amrita.aview.core.documentsharing.DocComponent.mxml");

/**
 * This flag is set to true if the connection is rejected in netStatusHandler method
 * If this flag is true, then we do not retry the connections
 */
public var docConnectionRejected:Boolean=false;
/**
 *Boolean variable for upload status
 */
public var uploadStatus:Boolean=false;
/**
 **Boolean variable UploadComplete
 */
public var uploadCom:Boolean=false;
/**
 *Boolean variable thumStatus
 */
private var thumStatus:Boolean=false;
/**
 *Boolean variable clickthum
 */
private var clickThum:Boolean=false;
/**
 *Boolean variable thumnailclick
 */
private var thumClick:Boolean=false;
/**
 *Boolean variable for iSpring Status
 */
private var ispringStatus:Boolean=false;
public var selectOne:Boolean=false;	
/**Platform specific variables*/
applicationType::web{
	//Loader object to load P2F documents.
	private var p2fLoaderObj:Loader=new Loader();
	//This variable is used to store the height of document loader
	private var normalHeight:Number;
	//For Guest Login: Time out Id for initialize document component
	private var initDocCompTimeoutID:uint;
	//For Web:To call function showPointer() after a specified delay
	private var showPointerTimeOutID:uint;
	//Fix for issue #11922
	private static const PERMISSION_GUEST_STATUS_MSG:String="Guest users do not have permission to download document";
}
applicationType::desktop{
	//For Full screen window
	public var documentSharingMW:DocSharing;
	
}
[Bindable]
public var toolBoxMenuOpened:Boolean;
private var menuOpenTimout:uint;
private var uploadTimeOut:Number;
private var viewerLoadppt:Number;
/**
 * selecting teacher toolbar and print2flash container if current user is a teacher
 * and selecting student toolbar and print2flash container if current user is a student
 *  Assigning class name to teacherClass variable
 */
private function init():void{
	//boolean for  whether to check document component initilizing done or not 
	//before initilze this function in viewer side try to assign document objects from synchandler
	if (initCalled)
		return;
	initCalled=true;
	ipAddress=ClassroomContext.CONTENT_DOCUMENT;
	applicationType::DesktopWeb{
		popOutBtn.setStyle("icon", popoutIcon);
		//popOutBtn_student.setStyle("icon",popoutIcon);
		applicationType::web{
			//For Guest Login: Added this logic to avoid timing issue for Guest user.
			if (initDocCompTimeoutID)
			{
				clearTimeout(initDocCompTimeoutID);
			}
		}
		removeComponent(containerStack, fileLoad)
		removeComponent(containerStack, iSpringCanvas);
		if (ClassroomContext.IS_DOCUMENT_SHARING_ENABLED)	{
			containerStack.selectedChild=p2fCanvas;
			containerStack.removeChild(disableCanvas);
		}
		else{
			disableCanvas.visible=true;
			disableCanvas.includeInLayout=true;
			disableLabel.visible=true;
			disableLabel.includeInLayout=true;
			containerStack.selectedChild=disableCanvas;
		}
		//uploadStatus=false;
		//trace("Upload status init");
		if (userRole == Constants.PRESENTER_ROLE){
			mousePointerShare=mousePointerEnable;
			controlStack.selectedChild=teacherAppbar;
			pptLoaded=false;
			entPage.enabled=false;
			toolBarPanel.height=368;
			 btnImgDownload.enabled=false;
			btnImgUnload.enabled=false;
			nextBtn.enabled=false;
			prevBtn.enabled=false;
			chkBoxPermission.enabled=false;
			//docCanvas.addEventListener(ScrollEvent.SCROLL,getVerticalScrollPosition);
			//docScroller.verticalScrollBar.addEventListener(ScrollEvent.SCROLL, getVerticalScrollPosition);
			//docCanvas.addEventListener(ScrollEvent.SCROLL, getVerticalScrollPosition);
			
		}
		else{
			
			presenterName=ClassroomContext.currentPresenterName;
			controlStack.selectedChild=studentAppbar;
			toolBarPanel.height=97;
			thumbNailVerticalBox.visible=false;
			thumbNailHorizontalBox.visible=false;
			if(permissionStatus == PERMISSION_GRANT_STATUS_MSG)
			{
				btnImgDownload.enabled=true;
			}
			else
			btnImgDownload.enabled=false;
			btnImgUnload.enabled=false;
			//nextBtn.enabled=false;
			//prevBtn.enabled=false;
			nextBtn.visible=false;
			prevBtn.visible=false;
			entPage.enabled=false;
//			applicationType::desktop{
				//Fix for issue #8866: Commented this logic.
				//permissionMsgStudent.visible=false;
				//trace("init")
//			}
		}
	}
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveModule(false,0);
			
		}
	}
	applicationType::mobile{
		if (userRole == Constants.PRESENTER_ROLE){   
			FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare = mobileMousePointerEnable;
			FlexGlobals.topLevelApplication.docTool.teacherAppbar.visible=true;
			FlexGlobals.topLevelApplication.docTool.teacherAppbar.includeInLayout = true;
			FlexGlobals.topLevelApplication.docTool.studentAppbar.visible=false;
			FlexGlobals.topLevelApplication.docTool.studentAppbar.includeInLayout = false;
			//AVCM:controlStack.selectedChild=teacherAppbar;					
			pptLoaded=false;												
		}else{ 
			FlexGlobals.topLevelApplication.docTool.teacherAppbar.includeInLayout=false;
			FlexGlobals.topLevelApplication.docTool.studentAppbar.visible=true;
		}
		presenterName = ClassroomContext.currentPresenterName;
		teacherClass=ClassroomContext.aviewClass.className;
		/*if (FlexGlobals.topLevelApplication.selectedModuleSO && FlexGlobals.topLevelApplication.selectedModuleIndex == 0){
			FlexGlobals.topLevelApplication.setActiveModule(false);
		}*/
		docScroller.verticalScrollBar = new VScrollBar();
		docScroller.horizontalScrollBar = new HScrollBar();
	}
	//assigning current class name which is selected by user(classname) is assigned to teacherClass
	teacherClass=ClassroomContext.aviewClass.className;	
}

/**
 * initilize the connection to Collaboration object
 * initailize all property handling functions for each property
 */
public function initializeDocumentCollaborationObject():void{
	documentCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("document_so");
	documentCollaborationObject.setOnClear(collabartionSOClear);
	documentCollaborationObject.setOnChange(propertyChangeHandler);
	documentCollaborationObject.setOnChangeProperty(NEWFILE, onNewFileHandler);
	documentCollaborationObject.setOnChangeProperty(PAGECHANGE, onNewPageHandler);
	documentCollaborationObject.setOnChangeProperty(DOCROTATION, onRotaionHandler);
	documentCollaborationObject.setOnChangeProperty(DOCSROLLCHANGE, onDocScrollChangeHandler);
	documentCollaborationObject.setOnChangeProperty(DOCZOOM, onScalingHandler);
	documentCollaborationObject.setOnChangeProperty(ANNOTATIONTOOL, onAnnotationToolChangeHandler);
	documentCollaborationObject.setOnChangeProperty(ANNOTATIONOBJECTS, onAnnotationObjectHandler);
	documentCollaborationObject.setOnChangeProperty(MOUSEPOINT, onMousePointHandler);
	documentCollaborationObject.setOnChangeProperty(ANIMATIONCHANGE, onAnimationChangetHandler);
	documentCollaborationObject.setOnChangeProperty(DOWNLOADACCESS, onDownloadAccessHandler);
	//added for red5
	documentCollaborationObject.setOnDeleteProperty(DELETEDOCUMENT,onDeleteSO);
	
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.connectionRetrys == 0){
			clearServer();
		}
	}
}

/**
 * for clearing all properties from sharedobject
 * While user try to unload or close the document share module
 */
public function closeDocumentCollaborationObject():void{
// #Bugfix for admin logout	
	if(documentCollaborationObject==null)
		return;
	documentCollaborationObject.removeOnChange();
	documentCollaborationObject.removeOnChangeProperty(NEWFILE);
	documentCollaborationObject.removeOnChangeProperty(PAGECHANGE);
	documentCollaborationObject.removeOnChangeProperty(DOCROTATION);
	documentCollaborationObject.removeOnChangeProperty(DOCSROLLCHANGE);
	documentCollaborationObject.removeOnChangeProperty(DOCZOOM);
	documentCollaborationObject.removeOnChangeProperty(ANNOTATIONTOOL);
	documentCollaborationObject.removeOnChangeProperty(ANNOTATIONOBJECTS);
	documentCollaborationObject.removeOnChangeProperty(MOUSEPOINT);
	documentCollaborationObject.removeOnChangeProperty(ANIMATIONCHANGE);
	documentCollaborationObject.removeOnChangeProperty(DOWNLOADACCESS);
	//added for red5
	documentCollaborationObject.removeOnDeleteProperty(DELETEDOCUMENT);
	ClassroomContext.collaborationService.closeCollaborationObject("document_so");
}

/**
 * for adding event listeners to p2fContainer
 * when the source(filepath) set to p2fContainer
 */
private function addEventListenersToP2F():void{
	loadCompletedFlag=false;
	isdownloadErrorShown=false;
	applicationType::web{
		//Instead of SWFLoader we use Loader to load the P2F document
		p2fLoaderObj.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
		p2fLoaderObj.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesDownloaded);
		p2fLoaderObj.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
		p2fLoaderObj.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		
	}
	applicationType::DesktopMobile{
		p2fContainer.addEventListener(ProgressEvent.PROGRESS, loadProgress);
		p2fContainer.addEventListener(Event.COMPLETE, bytesDownloaded);
		p2fContainer.addEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
		p2fContainer.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);		
	}
	docScroller.verticalScrollBar.addEventListener(Event.CHANGE, getVerticalScrollPosition);
	docScroller.horizontalScrollBar.addEventListener(Event.CHANGE, getHorizontalScrollPosition);
}


/**
 * for adding event listeners to ispring Container
 * when the source(filepath) set to ispring Container
 */
private function addEventListenersToiSpring():void{
	iSpringSlideControler.addEventListener(SlidePlaybackEvent.CURRENT_SLIDE_INDEX_CHANGED, SlideChangedEvent);
	iSpringSlideControler.addEventListener(StepPlaybackEvent.ANIMATION_STEP_CHANGED, AnimationChange)
	if (this){
		this.addEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
	}
}

/**
 * for replacing some pattern in the document file name for recording purpose
 * @param replace_with pattern which is to be replaced in the string
 * @param replace pattern pattern which replaces the existing pattern
 * @param original string in which manipulation takesplace
 */
public function str_replace(replace_with:String, replace:String, original:String):String{
	var array:Array=original.split(replace_with);
	return array.join(replace);
}

/**
 * for handling the property changes in shared object
 * here values retrieved from the shared object
 * @param data current changes
 */
private function propertyChangeHandler(data:Object, name:Object):void{
	applicationType::web{
		//For Guest Login: Added this logic to avoid timing issue for Guest user.
		if (ClassroomContext.userVO.role == Strings.GUEST_TYPE){
			initDocCompTimeoutID=setTimeout(init, 200);
		}
		else{
			init();
		}
	}
	applicationType::desktop{
		if (!initCalled)
		{
			/*applicationType::DesktopWeb{
			if((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()) && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"] == 6))
			{
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveWindowInSO(0);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setVideoWallLayout(Constants.SIMPLE_LAYOUT);
			}
			}*/
			init();
		
		}
	}
	applicationType::DesktopWeb{
		userRole=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole
	}
	applicationType::mobile{
		userRole=FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole
	}
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	// ashwini: #15246 : the below condition says that if there is something in the SO, then set the active module to 
	// document sharing. Well, this will not be needed...because on reconnection OnSync_selectedModule() will be called
	// and that will set the selected module based on the value in SO. Commenting the code below.
	
	// ashish: 18365, the below code is needed essentially,
	// it switches to document sharing in all nodes if any event happens if other users are not in document module
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so){
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveModule(false);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveModule(true,0);
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.selectedModuleSO && FlexGlobals.topLevelApplication.selectedModuleIndex != 0){
			FlexGlobals.topLevelApplication.setActiveModule(true,0);
		}
	}
}

/**
 * Invoke when Presenter change the NEWFILE property in  shared object
 */
private function onNewFileHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "")
	{ 
		changeDocumentFile(newValue);
	}
	/*else if(userRole==Constants.PRESENTER_ROLE&&isDownload==false)
	{
		changeDocumentFile(newValue);
		setTimeout(setZoomValue,100);
		setZoomValue();
		//normalZoom();
		normalZoomHandler();
	}
		
	//trace("enterrrr");
	isDownload=false;*/
	
}
/**
 * Invoke when moderator give control to viewer.To set zoom factor
 */
private function setZoomValue():void
{
	documentCollaborationObject.setValue(DOCZOOM, "");
}

/**
 * Invoke when Presenter change the PAGECHANGE property in  shared object
 */
private function onNewPageHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "")
		changeDocumentPage(newValue);
		//isDownload=false;
}
/**
 * Invoke when Presenter change the ROTATION property in  shared object
 */
private function onRotaionHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "")
		changeDocumentRotation(newValue)
}

/**
 * Invoke when Presenter change the DOCZOOM property in  shared object
 */
private function onScalingHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "") changeDocumentZoom(newValue);
}

/**
 * Invoke when Presenter change the ANNOTATIONTOOL property in  shared object
 */
private function onAnnotationToolChangeHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE) changeDocumentAnnotationTool(newValue);

}
/**
 * Invoke when Presenter change the ANNOTATIONOBJECTS property in  shared object
 */
private function onAnnotationObjectHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "") changeDocumentAnnotationObjects(newValue)
}

/**
 * Invoke when Presenter change the MOUSEPOINT property in  shared object
 */
private function onMousePointHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "") changeDocumentMousePoint(newValue)
}

/**
 * Invoke when Presenter change the ANIMATIONCHANGE property in  shared object
 */
private function onAnimationChangetHandler(newValue:Object, oldValue:Object,name:Object):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "")
		changeDocumentAnimation(newValue)
}

/**
 * Invoke when Presenter change the DOWNLOADACCESS property in  shared object
 */
private function onDownloadAccessHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "") changeDocumentDownloadAccess(newValue);
}

/**
 * Invoke when Presenter change the DOCSCROLLCHANGE property in  shared object
 */
private function onDocScrollChangeHandler(newValue:Object, oldValue:Object, name:String):void{
	if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED){
		return;
	}
	if (userRole != Constants.PRESENTER_ROLE && newValue != "") changeDocumentScroll(newValue)
}

/**
 * Invoke when Presenter Clear all properties in  shared object
 */
private function collabartionSOClear():void{
	if (documentCollaborationObject.syncEventCount > 1 && userRole != Constants.PRESENTER_ROLE){
		unloadDocument();
		/*applicationType::DesktopWeb{
			viewerCurrentPageLabel.visible=false;
		}*/
		applicationType::mobile{
			if(informationCallout.lblCurrentPage)
				informationCallout.lblCurrentPage.visible=false;
		}
	}
}
/**
 * Invoke when Presenter remove the delete property in  shared object
 * added for red5
 */
private function onDeleteSO(name:String):void
{
	if(userRole != Constants.PRESENTER_ROLE)
	{
		unloadDocument();
	}
	applicationType::mobile{
		if(informationCallout.lblCurrentPage)
			informationCallout.lblCurrentPage.visible=false;
	}
}

/**
 * For adjust the document(File) in Viewer side according to same as Presenter side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentFile(data:Object):void{
	presenterMousePointer=false;
	isPageLoaded=data.isPageLoaded
	fileExtention=data.fileExtention;
	remoteFileName=data.fileName
	totalPages=data.totalPages;
	presenterThumbPath=data.thumbPath;
	animatedFile=data.animated;
	if(animatedFile) pptLoaded=true;
	/*applicationType::DesktopWeb{
		viewerCurrentPageLabel.visible=true;
	}*/
	applicationType::mobile{
		if(informationCallout.lblCurrentPage != null)
			informationCallout.lblCurrentPage.visible=true;
	}
	p2fWidthTeacher=data.p2fWidthTeacher;
	p2fHeightTeacher=data.p2fHeightTeacher;
	//remoteFilePath=data.path;
	remoteFileName=data.fileName;
	var obj:Object;
	applicationType::DesktopWeb{
		if (isISpringFile(fileExtention) && animatedFile){
			teacherZoomFactorXForAnimated=parseFloat(data.teacherZoomFactorX);
			teacherZoomFactorYForAnimated=parseFloat(data.teacherZoomFactorY);
			obj=getResolutionProperties(iSpringCanvas,iSpringWidth)		
		}
		else{
			teacherZoomFactorX=parseFloat(data.teacherZoomFactorX);
			trace("changeDocumentFile  teacherZoomFactorX"+teacherZoomFactorX);
			teacherZoomFactorY=parseFloat(data.teacherZoomFactorY);
			obj=getResolutionProperties(p2fCanvas,p2fWidth);		
		}
	}
	applicationType::mobile{
		teacherZoomFactorX=parseFloat(data.teacherZoomFactorX);
		teacherZoomFactorY=parseFloat(data.teacherZoomFactorY);
		obj=getResolutionProperties(p2fCanvas,p2fWidth);		
	}
	setLoaderProperties(obj);	
	if (remoteFilePath == "" || remoteFilePath != data.path){
		currentPage=1;
		remoteFilePath=data.path;
		//setTimeout(loadFileToCache, 500, remoteFilePath, fileExtention);
		loadFileToCache(remoteFilePath, fileExtention, remoteFileName);
	}
	/*else
		loadFileToCache(remoteFilePath, fileExtention, remoteFileName)*/
	if (remoteFilePath == data.path) isPageLoaded=true;
}

/**
 * For adjust the document's page in Viewer side according to same as Presenter side
 * Data collected from Sharedobject
 * @param data of object
 */
 private function changeDocumentPage(data:Object):void{
 	rightClickAllowed=false;
	p2fWidthTeacher=parseFloat(data.p2fWidthTeacher);
	applicationType::DesktopWeb{
		/*lblPageSt.visible=true;*/
		if (isISpringFile(fileExtention) && animatedFile)
		{
			teacherZoomFactorXForAnimated=parseFloat(data.teacherZoomFactorX);
			teacherZoomFactorYForAnimated=parseFloat(data.teacherZoomFactorY);
			currentPage=data.pageNo;
			if (iSpringSlideControler){
				if (highlighterSelected || penSelected){
					iSpringContainer.removeChild(uiComp);
					uiComp=null;
					annotateDoc(iSpringContainer);
					
				}
				if (isPageLoaded) newPageLoad(currentPage);
				if (uiComp) ispringScaleDocument(teacherZoomFactorXForAnimated, teacherZoomFactorYForAnimated, iSpringWidth, p2fWidthTeacher, p2fWidthTeacher);
			}
		}
		else{
			teacherZoomFactorX=parseFloat(data.teacherZoomFactorX);
			teacherZoomFactorY=parseFloat(data.teacherZoomFactorY) - .0035;
			if (isPageLoaded && currentPage != data.pageNo){
				currentPage=data.pageNo;
				newPageLoad(currentPage);
			}
			previousPage=currentPage;
		}
	}
	applicationType::mobile{
		teacherZoomFactorX = parseFloat(data.teacherZoomFactorX);
		teacherZoomFactorY = parseFloat(data.teacherZoomFactorY) - .0035; 
		if(isPageLoaded && currentPage!=data.pageNo)
		{
			currentPage=data.pageNo;
			newPageLoad(currentPage);					   
		}
		previousPage = currentPage;
	}
}

/**
 * For adjust the document zoom position in Viewer side according to same as Presenter side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentZoom(data:Object):void{	
		//Added this check to avoid document scroll issue at viewer side 
		if (data && data.zoomFactorX){
			trace("The Zoom changed is Called zoomFactorX"+data.zoomFactorX);
			teacherZoomFactorX=data.zoomFactorX;
			teacherZoomFactorY=data.zoomFactorY - .0035;						
		}
		else
			return;	
			//trace("The Zoom changed is not calling");
			
		p2fWidthTeacher=data.p2fWidthTeacher;
		p2fHeightTeacher=data.p2fHeightTeacher;
		if (isPageLoaded){
			trace("The Zoom changed is Called teacherZoomFactorX"+teacherZoomFactorX);
			scaleDocument(teacherZoomFactorX, teacherZoomFactorY, p2fWidth, p2fHeight, p2fWidthTeacher, p2fHeightTeacher)
		}
}

/**
 * For adjust the animations in viewer side according to same as presenter side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentAnimation(data:Object):void{
	stepno=data.stepNo;
	if (iSpringSlideControler) iSpringSlideControler.playFromStep(stepno);
	if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addAnimationStepTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), stepno, currentPage);
}

/**
 * For adjust the rotaion in viewer side according to same as presenter side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentRotation(data:Object):void{
	rotationDegree=parseInt(data.rotationDegree);
	rotateDoc(rotationDegree, p2fWidth, p2fHeight, teacherZoomFactorX);
}

/**
 * For adjust the Page in viewer side according to same as presenter side
 * Data collected from Sharedobject
 * @param prsentPage of Number
 */
private function pageSet(prsentPage:Number):void{
	if (prsentPage != currentPage){
		newPageLoad(prsentPage);
		currentPage=prsentPage;
	}
}
/**
 * For adjust the  scroll position in viewer side according to same as presenter side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentScroll(data:Object):void{
	scrollDirction=data.direction;
	scrollPosition=data.position;
	applicationType::DesktopWeb{
		if (scrollDirction == "vertical"){
			maxX=data.maxX;
			scrollPosition=scrollPosition * (docScroller.verticalScrollBar.maximum / maxX)
			docScroller.verticalScrollBar.value=scrollPosition;
		}
		else{
			maxY=data.maxY;
			scrollPosition=scrollPosition * (docScroller.horizontalScrollBar.maximum / maxY)
			docScroller.horizontalScrollBar.value=scrollPosition;
		}
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addScrollEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), scrollDirction, scrollPosition);
		}
	}
	applicationType::mobile{
		if(scrollDirction=="vertical"){	
			scrollPosition=scrollPosition * (p2fHeight/p2fHeightTeacher);
			docScroller.verticalScrollBar.value=scrollPosition;
			docCanvas.verticalScrollPosition = scrollPosition;
		}else{
			scrollPosition=scrollPosition * (p2fWidth/p2fWidthTeacher);
			docScroller.horizontalScrollBar.value=scrollPosition;
			docCanvas.horizontalScrollPosition = scrollPosition;
		}
	}
}
/**
 * For showing  Presenter's mouse point in viewer side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentMousePoint(data:Object):void{
	
	applicationType::DesktopWeb{
		teacherMouseout=data.teacherMouseout;
		presenterMousePointer=data.teacherMousePointer;
		var obj:Object;
		if (presenterMousePointer && !teacherMouseout){
			
			pointerX=parseFloat(data.pointerX);
			pointerY=parseFloat(data.pointerY);
			if (isISpringFile(fileExtention) && animatedFile){
				obj=getResolutionProperties(iSpringCanvas,iSpringWidth)
				setLoaderProperties(obj);
				iSpringWidthTeacher=parseFloat(data.p2fWidthTeacher);
				teacherZoomFactorXForAnimated=data.zoomFactorX
				teacherZoomFactorYForAnimated=data.zoomFactorY
				if (!uiComp){
					if (isPageLoaded){				
						uiComp=createUIComponent(0xFFFF00,0,iSpringContainer.width,iSpringContainer.height)
						iSpringContainer.addChildAt(uiComp, 1);					
						setUIcomponentDisplay(iSpringContainer.width,iSpringContainer.height);
						ispringScaleDocument(1, 1, iSpringWidth, iSpringWidthTeacher, iSpringWidthTeacher);
					}
					
					
				}
				if (isPageLoaded) showPointer(uiComp, iSpringWidth, iSpringHeight, uiComp);
			}
			else{
				obj=getResolutionProperties(p2fCanvas,p2fWidth)
				setLoaderProperties(obj);
				applicationType::web{
					//Added this logic for Pointer scaling
					if (!uiComp){
						if (isPageLoaded){						
							uiComp=createUIComponent(0xFFFF00,0,normalWidth,normalHeight)
							p2fContainer.addChildAt(uiComp, 1);						
							setUIcomponentDisplay(p2fLoaderObj.width,p2fLoaderObj.height);
							scaleDocument(1, 1, p2fLoaderObj.width, p2fLoaderObj.height, p2fLoaderObj.contentLoaderInfo.width, p2fLoaderObj.contentLoaderInfo.height);
						}
					}
					else { //Added this logic for avoid Pointer missing issue at viewer side when Presenter navigates the document. 
						if (p2fContainer.numChildren == 1) p2fContainer.addChild(uiComp);
					}
					//Added pointer to UIComponent for Pointer scaling.Also changed width and height
					if (isPageLoaded == true)
						showPointer(uiComp, normalWidth, normalHeight, uiComp);
				}
				applicationType::desktop{
					if (isPageLoaded == true)
						showPointer(p2fContainer, p2fWidth, p2fHeight, p2fContainer);
				}
				
			}
			//checking if teacher mouse pointer is outside the container or not
			if (isPageLoaded == true){
				if (teacherMouseout) pointerShape.visible=false;
				else{
					if (pointerShape) pointerShape.visible=true;
				}
			}
		}
		else{
			if (isISpringFile(fileExtention) && animatedFile){
				if (uiComp) removeUIComp(uiComp, uiComp);
			}
			else{			
				applicationType::web{
					//Added this logic for Pointer scaling
					removeUIComp(uiComp, uiComp);
				}
				applicationType::desktop{
					removeUIComp(p2fContainer, p2fContainer);
				}
			}
		}
	}
	applicationType::mobile{
		teacherMouseout=data.teacherMouseout;
		presenterMousePointer = data.teacherMousePointer;
		if(presenterMousePointer){
			pointerX = parseFloat(data.pointerX);
			pointerY = parseFloat(data.pointerY);
			getResolution();
			if(isPageLoaded==true)
				showPointer(p2fContainer,p2fWidth,p2fHeight,p2fContainer);
			//checking if teacher mouse pointer is outside the container or not
			if(isPageLoaded==true && pointerShape != null){
				if(teacherMouseout){
					pointerShape.visible=false;	
				}else{
					pointerShape.visible=true;
				}
			}
		}else{ 
			removeUIComp(p2fContainer,p2fContainer);
		}	
	}
}
applicationType::mobile{
	public function getResolution():void
	{
		//taking the previous width of the print2flash container for scaling
		if(resizeCount == 0)
		{
			previousWidth = p2fWidth;
			previousHeight=p2fHeight;
			resizeCount = resizeCount + 1;
		}
		var tempWidth:Number;
		
		p2fHeight=p2fCanvas.height-10;
		tempWidth=(p2fHeight / 3) * 4;
		if (tempWidth >= p2fCanvas.width)
		{
			p2fWidth=p2fCanvas.width-10;
			toolWidth=p2fWidth
			p2fHeight=(p2fWidth / 4) * 3;
		}
		else
		{
			p2fWidth=tempWidth;
			toolWidth=p2fWidth
		}  
		fileNameWidth=p2fWidth*(2/10);
		toolItemGap=p2fWidth/15;
	}
}
/**
 * For Handling the download permission in viewer side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentDownloadAccess(data:Object):void{
	var userAccess:String=data.permission
	if (userAccess == PERMISSION){
		applicationType::DesktopMobile{
			rightClickAllowed=true;
			isDownloadPermission=true;
			permissionStatus=PERMISSION_GRANT_STATUS_MSG;
			applicationType::desktop{
				btnImgDownload.enabled=true;
				//btnImgDownload.includeInLayout=true;
				permissionMsgStudent.toolTip="Right click on the document to download";
			}
			applicationType::mobile{
				FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled = true;
			}
			contextMenuArray=new Array(DOWNLOAD);
		}
		applicationType::web{
			//For Guest Login: Restrict Control over loaded documents(Download to local disk, access to public documents etc) for guest user
			if (ClassroomContext.userVO.role != Strings.GUEST_TYPE){
				rightClickAllowed=true;
				isDownloadPermission=true;
				permissionStatus=PERMISSION_GRANT_STATUS_MSG;
				btnImgDownload.enabled=true;
				permissionMsgStudent.toolTip="Right click on the document to download";
				contextMenuArray=new Array(DOWNLOAD);
			}
		}
	}
	else if (userAccess == DENY_PERMISSION)	{
		rightClickAllowed=false;
		isDownloadPermission=false;
		unloadContextMenuData();
		applicationType::web{
			//For Guest Login:Fix for issue #11922
			if (ClassroomContext.userVO.role == Strings.GUEST_TYPE){
				permissionMsgStudent.toolTip=PERMISSION_GUEST_STATUS_MSG;
				permissionStatus=PERMISSION_GUEST_STATUS_MSG;
				return;
			}			
		}
		applicationType::DesktopWeb{
			btnImgDownload.enabled=false;
		}
		applicationType::mobile{
			FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled = false;
		}
		setPermissionDenyStatus();
		
	}
	
	applicationType::mobile{
		if (userAccess == "Allow Download"){
			isDownloadPermission=true;
			permissionStatus=PERMISSION_GRANT_STATUS_MSG;
			FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled = true;
		}else if (userAccess == "Deny download permission")	{
			rightClickAllowed=false;
			isDownloadPermission=false;
			FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled = false;
		}
		//To change the menu item.
		if(FlexGlobals.topLevelApplication.docTool.docMenuComp.isOpen)
		{
			FlexGlobals.topLevelApplication.docTool.docMenuComp.updateDocList();
		}
	}
}
//RTCR: Need to change the function name
private function setPermissionDenyStatus():void
{
	applicationType::DesktopWeb{
		permissionMsgStudent.toolTip=PERMISSION_DENY_STATUS_MSG;
	}
	permissionStatus=PERMISSION_DENY_STATUS_MSG;
}
/**
 * For Select the annoation tool in viewer side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentAnnotationTool(data:Object):void{
	
	//toolName=data.toolName;
	toolName=data.prevTool;
	iSpringWidthTeacher=data.iSpringWidthTeacher;
	isNewPageLoad=false;
	//annottool(toolName);
	setAnnotationTools(toolName);
	applicationType::DesktopWeb{
		if (isPageLoaded && (penSelected || highlighterSelected)){
			if (isISpringFile(fileExtention) && animatedFile)
				annotateDoc(iSpringContainer);
			else
				annotateDoc(p2fContainer);
		}
	}
	applicationType::mobile{
		if (isPageLoaded && (penSelected || highlighterSelected)){
			annotateDoc(p2fContainer);
		}
	}
	if (data.toolName.search("Eraser") != -1){
		if (uiComp) erase();
	}
	if (pptLoaded){
		teacherZoomFactorXForAnimated=data.zoomFactorX;
		teacherZoomFactorYForAnimated=data.zoomFactorY;
		if (!isNaN(teacherZoomFactorXForAnimated) && !isNaN(teacherZoomFactorYForAnimated))
			ispringScaleDocument(teacherZoomFactorXForAnimated, teacherZoomFactorYForAnimated, iSpringWidth, iSpringWidthTeacher, iSpringWidthTeacher);		
	}
}
/**
 * private
 * For setting the  annoation tool for drawing
 * @param toolName of String
 */
 private function setAnnotationTools(toolName:String):void
{
	if (toolName == "Pen"){
		penSelected=true;
		highlighterSelected=false;
//		applicationType::DesktopWeb{
			//highlightTool.enabled=true;
			//penTool.enabled=false;
//		}
	}
	if (toolName == "Highlight"){
		highlighterSelected=true;
		penSelected=false;
//		applicationType::DesktopWeb{
			//highlightTool.enabled=false;
			//penTool.enabled=true;
//		}
	}
	if (toolName == "Remove annotation tools"){
		removeAnnotationTools();
	}
	if (toolName == "Remove annotation"){
		removeAnnotation();
		removeAnnotationTools();
	}
}
/**
 * For handling the annoation drawing in viewer side
 * Data collected from Sharedobject
 * @param data of object
 */
private function changeDocumentAnnotationObjects(data:Object):void{
	var pointsArray:Array=data.pointsArray;
	if (isPageLoaded){
		if (!uiComp)
			return;
		if (pptLoaded){
			iSpringWidthTeacher=data.iSpringWidthTeacher;
			teacherZoomFactorXForAnimated=data.zoomFactorX
			teacherZoomFactorYForAnimated=data.zoomFactorY
			ispringScaleDocument(teacherZoomFactorXForAnimated, teacherZoomFactorYForAnimated, iSpringWidth, iSpringWidthTeacher, iSpringWidthTeacher);
		}
		createAnnotationShape(pointsArray);
	}
}
private function createAnnotationShape(pointsArray:Array):void
{
	var annotedShape:Shape=new Shape()
	uiComp.addChild(annotedShape);
	applicationType::DesktopWeb{
		annotedShape.graphics.lineStyle(lineThickness, lineColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.MITER, 4);
	}
	applicationType::mobile{
		annotedShape.graphics.lineStyle(lineThickness,lineColor,lineAlpha,false);
	}
	annotedShape.graphics.moveTo(pointsArray[0].x, pointsArray[0].y);
	var len:uint=pointsArray.length;
	for (var k:uint=1; k < len; k++){
		annotedShape.graphics.lineTo(pointsArray[k].x, pointsArray[k].y);
	}
}
/**
 * event listener for showing the percentage of bytes loaded
 * to the print2flash container
 * @param event of ProgressEvent
 */
private function loadProgress(event:ProgressEvent):void{
	percentLoaded=event.bytesLoaded / event.bytesTotal;
	percentLoaded=Math.round(percentLoaded * 100);
	applicationType::web{
		//Instead of SWFLoader we use Loader to load the P2F document
		//Added remove event listeners to progress event of p2fContainer   
		if (percentLoaded == 100 && p2fLoaderObj.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS))
			p2fLoaderObj.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
	}
	applicationType::DesktopMobile{
		if (percentLoaded == 100 && p2fContainer.hasEventListener(ProgressEvent.PROGRESS))
			p2fContainer.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
	}
}

private function downloadPermission():void
{
	applicationType::DesktopWeb{
		if (chkBoxPermission.selected==true){
			/*if (annotation.visible)
			contextMenuArray=new Array(DOWNLOAD, DENY_PERMISSION, UNLOAD, REMOVE_ANNOTATE);
			else*/
			contextMenuArray=new Array(DOWNLOAD, DENY_PERMISSION, UNLOAD);
			permissionStatus=PERMISSION_GRANT_STATUS_MSG;
			documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: PERMISSION});
			if (Log.isDebug())log.debug("contextHandler: downloadPermission is called. permission:" + PERMISSION);
			
			documentAllowDownloadEventLog(remoteFilePath);
			//chkBoxPermission.selected=true;
		}
		else if (chkBoxPermission.selected==false){
			/*if (annotation.visible)
			contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD, REMOVE_ANNOTATE);
			else*/
			contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
			permissionStatus=PERMISSION_DENY_STATUS_MSG;
			documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: DENY_PERMISSION});
			
			if (Log.isDebug())log.debug("contextHandler: downloadPermission is called. permission:" + DENY_PERMISSION);
			documentDenyDownloadEventLog(remoteFilePath);
			//chkBoxPermission.selected=false;
		}
	}
}

/**
 * invoked when an option is selected from the context menu
 * @param event of MouseEvent
 */
private function contextHandler(event:MouseEvent):void{
	applicationType::DesktopWeb{
		if (contextMenuList.selectedItem.toString() == PERMISSION){
			/*if (annotation.visible)
				contextMenuArray=new Array(DOWNLOAD, DENY_PERMISSION, UNLOAD, REMOVE_ANNOTATE);
			else*/
			contextMenuArray=new Array(DOWNLOAD, DENY_PERMISSION, UNLOAD);
			permissionStatus=PERMISSION_GRANT_STATUS_MSG;
			documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: PERMISSION});
			if (Log.isDebug())log.debug("contextHandler: downloadPermission is called. permission:" + PERMISSION);
			
			documentAllowDownloadEventLog(remoteFilePath);
			chkBoxPermission.selected=true;
		}
		else if (contextMenuList.selectedItem.toString() == DENY_PERMISSION){
			/*if (annotation.visible)
				contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD, REMOVE_ANNOTATE);
			else*/
			contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
			permissionStatus=PERMISSION_DENY_STATUS_MSG;
			documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: DENY_PERMISSION});
			
			if (Log.isDebug())log.debug("contextHandler: downloadPermission is called. permission:" + DENY_PERMISSION);
			documentDenyDownloadEventLog(remoteFilePath);
			chkBoxPermission.selected=false;
		}
		else if (contextMenuList.selectedItem.toString() == UNLOAD)
			unloadDocument();
		else if (contextMenuList.selectedItem.toString() == DOWNLOAD)
			downloadDocumentToLocal(remoteFileName, remoteFilePath);
		else if (contextMenuList.selectedItem.toString() == ANNOTATE){	
			if (permissionStatus == PERMISSION_GRANT_STATUS_MSG)
				contextMenuArray=new Array(DOWNLOAD, DENY_PERMISSION, UNLOAD, REMOVE_ANNOTATE);
			else
				contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD, REMOVE_ANNOTATE);			
			if (!pptLoaded)
				fileNameWidth=p2fWidth / 3;
			else
				fileNameWidth=iSpringWidth / 3;
			//annotationBox.includeInLayout=true;
			//annotation.visible=true;	
			//annotation.addEventListener("onAnnotationToolSelected", annotationStart);
			documentAnnotationToolsEventLog(remoteFilePath);
		}
		else if (contextMenuList.selectedItem.toString() == REMOVE_ANNOTATE){
			toolName=REMOVE_ANNOTATE
			if (uiComp && uiComp.hasEventListener(MouseEvent.MOUSE_DOWN) && userRole == Constants.PRESENTER_ROLE)
			    uiComp.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
			if (permissionStatus == PERMISSION_GRANT_STATUS_MSG)
				contextMenuArray=new Array(DOWNLOAD, DENY_PERMISSION, UNLOAD);
			else
				contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
			removeAnnotationTools();
			documentRemoveAnnotationToolsEventLog(remoteFilePath);
		}
	}
}

/**
 *
 * @private
 * Audits the "DocumentRemoveAnnotationTools" action, when the presenter removes the annonation tool
 *
 * @param url of the document
 * @return void
 *
 */
private function documentRemoveAnnotationToolsEventLog(url:String):void
{
	AuditContext.userAction.createAction(AuditConstants.documentRemoveAnnotationTools, url, null, null);
}

/**
 *
 * @private
 * Audits the "DocumentAnnotationTools" action, when the presenter opens the annonation tool
 *
 * @param url of the document
 * @return void
 *
 */
private function documentAnnotationToolsEventLog(url:String):void
{
	AuditContext.userAction.createAction(AuditConstants.documentAnnotationTools, url, null, null);
}

/**
 *
 * @private
 * Audits the "DocumentDenyDownload" action, when the presenter takes away permission from users to download the document
 *
 * @param url of the document
 * @return void
 *
 */
private function documentDenyDownloadEventLog(url:String):void
{
	AuditContext.userAction.createAction(AuditConstants.documentDenyDownload, url, null, null);
}

/**
 *
 * @private
 * Audits the "DocumentAllowDownload" action, when the presenter gives permission to users to download the document
 *
 * @param url of the document
 * @return void
 *
 */
private function documentAllowDownloadEventLog(url:String):void
{
	AuditContext.userAction.createAction(AuditConstants.documentAllowDownload, url, null, null);
}

/**
 * for create the custom context menu
 */
private function createContextMenuList():void{
	applicationType::DesktopWeb{
		if (rightClickAllowed)	{
			var selected_X:int;
			var selected_Y:int;
			var max_X:int;
			var max_Y:int;
			hideContextMenuList();	
			contextMenuList=new mx.controls.List;
			contextMenuList.dataProvider=contextMenuArray;
			contextMenuList.visible=true;
			contextMenuList.width=160;
			if (userRole == Constants.PRESENTER_ROLE) //For Presenter
				contextMenuList.height=77;
			else if (isDownloadPermission) // For Viewer and when he has download permission
				contextMenuList.height=27;
			selected_X=containerStack.mouseX;
			selected_Y=containerStack.mouseY;
			max_X=containerStack.width - contextMenuList.width - 2;
			max_Y=containerStack.height - contextMenuList.height - 2;
			//Positioning of the menu
			//Normal area
			if (selected_X <= max_X)
				contextMenuList.x=selected_X;
			//If the menu goes out of the width
			else
				contextMenuList.x=max_X;
			//Normal area
			if (selected_Y <= max_Y)
				contextMenuList.y=selected_Y;
			//If the menu goes out of the height
			else
				contextMenuList.y=max_Y;
			if (pptLoaded) //ISpring docs
				iSpringCanvas.addElement(contextMenuList);
			else //Print2Flash docs
				p2fCanvas.addElement(contextMenuList);
			contextMenuList.addEventListener(MouseEvent.CLICK, contextHandler);
		}
	}
}

/**
 * for hide the custom context menu
 */
public function hideContextMenuList():void{
	applicationType::DesktopWeb{
		if (contextMenuList){
			if (iSpringCanvas.contains(contextMenuList) && pptLoaded)
				iSpringCanvas.removeElement(contextMenuList);
			else if (p2fCanvas.contains(contextMenuList))
				p2fCanvas.removeElement(contextMenuList);
		}
	}
}
// --- Custom context menu logic ends ---
/**
 * For downloading the documents in to PC's drive
 * @param fileName of String
 * @param filePath of String
 */
public function downloadDocumentToLocal(fileName:String, filePath:String):void{
	var originalFilePath:String="";
	var lastIdx:int=filePath.lastIndexOf("/", filePath.length);
	if (lastIdx != -1)
		originalFilePath=filePath.substr(0, lastIdx);
	originalFilePath=getDownloadableRemotePath(originalFilePath);
	var downloadedfile:URLRequest=new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + originalFilePath + "/@@-OriginalDocs-@@/" + fileName));
	var fileReference:FileReference=new FileReference();
	fileReference.download(downloadedfile);
	fileReference.addEventListener(Event.OPEN, openHandler);
	fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	fileReference.addEventListener(Event.COMPLETE, downloadComplete);
	if(Log.isDebug()) log.debug("downloadDocumentToLocal:originalFilePath:"+originalFilePath);
}

/**
 * For start Presenter's Annotation
 * this event fired from ANNOTATIONCOMP component
 * Event name is  AnnotationToolSelected
 * @param event of AnnotationToolSelected
 */
private function annotationStart(annotationToolName:String):void{
	toolName=annotationToolName;
	isNeedRemoveAnnotation=false;
	isNewPageLoad=false;
	documentAnnotationToolSelectionEventLog(remoteFilePath, toolName, currentPage);
	if (pptLoaded){
		containerStack.addEventListener(MouseEvent.ROLL_OUT, mouseIconOutListner)
		containerStack.addEventListener(MouseEvent.ROLL_OVER, mouseIconOverListner)
	}
	else{
		p2fContainer.addEventListener(MouseEvent.ROLL_OUT, mouseIconOutListner)
		p2fContainer.addEventListener(MouseEvent.ROLL_OVER, mouseIconOverListner)
	}
	setAnnotationTools(toolName);
	applicationType::DesktopWeb{
		if (isPageLoaded && (penSelected || highlighterSelected)){      
			if (isISpringFile(fileExtention) && animatedFile)
				annotateDoc(iSpringContainer);
			else
				annotateDoc(p2fContainer);
		}
	}
	if (toolName == "Eraser"){
		if(penSelected)	
			prevTool="Pen";
		if(highlighterSelected)
			prevTool="Highlight";
		eraseCount++;
		if (uiComp){
			toolName=toolName + eraseCount;
			erase();
		}
	}	
	trace("zoomFactorX in "+zoomFactorX);
	documentCollaborationObject.setValue(ANNOTATIONTOOL, {toolName: toolName, iSpringWidthTeacher: iSpringWidth, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY,prevTool:prevTool});
	if (Log.isDebug()) log.debug("annotationStart: setAnnotationTool is called. toolName:" + toolName + ", iSpringWidthTeacher:" + iSpringWidth + ", zoomFactorX:" + ispringZoomFactorX + ", zoomFactorY:" + ispringZoomFactorY);
}
/**
 * For Select purticular Annotation tool
 * @param event of AnnotationToolSelected
 */
private function  annottool(tool:String):void
{
	
	applicationType::desktop{
		if (p2fContainer.content != null && p2fContainer.visible == true)
		{
		
		var toolSelected:String=tool;
		if(penSelected||highlighterSelected) selectOne=true;
		if(toolSelected=="Pen")
		{
			prevTool="Pen";
			if(penSelected)
			{
				
				//penSelected=false;
				removeAnnotationTools();
				removeUICompEventListners();
				applicationType::desktop{
					penTool.setStyle("imageSkin",pencilDefault);
				}
				//penTool.enabled=false;
				//removeAnnotation();
				//this.cursorManager.removeAllCursors();
				//setMouseIcon();
			}
			else
			{
				
				annotationStart(toolSelected);
				applicationType::desktop{
					penTool.setStyle("imageSkin",pencilActive);
					highlightTool.setStyle("imageSkin",annotate_markerDefault);
				}
			}
			
		}
		else if(toolSelected=="Highlight")
		{
			prevTool="Highlight";
			if(highlighterSelected)
			{
				//highlighterSelected=false;
				removeAnnotationTools();
				removeUICompEventListners();
				applicationType::desktop{
					highlightTool.setStyle("imageSkin",annotate_markerDefault);
				}
				//highlightTool.enabled=false;
				//removeAnnotation();
				//this.cursorManager.removeAllCursors();
				setMouseIcon();
				/*p2fContainer.removeChildAt(2);
				if (p2fContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
					p2fContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);*/
			}
			else
			{
				annotationStart(toolSelected);
				applicationType::DesktopWeb{
					highlightTool.setStyle("imageSkin",annotate_markerActive);
					penTool.setStyle("imageSkin",pencilDefault);
				}
			}
		}
		}
		else if(pptLoaded)
		{
			var toolSelected:String=tool;
			if(toolSelected=="Pen")
			{
				prevTool="Pen";
				if(penSelected)
				{
					
					//penSelected=false;
					removeAnnotationTools();
					removeUICompEventListners();
					applicationType::desktop{
						penTool.setStyle("imageSkin",pencilDefault);
					}
					//penTool.enabled=false;
					//removeAnnotation();
					//this.cursorManager.removeAllCursors();
					//setMouseIcon();
				}
				else
				{
					
					annotationStart(toolSelected);
					applicationType::desktop{
						penTool.setStyle("imageSkin",pencilActive);
						highlightTool.setStyle("imageSkin",annotate_markerDefault);
					}
				}
				
			}
			else if(toolSelected=="Highlight")
			{
				prevTool="Highlight";
				if(highlighterSelected)
				{
					//highlighterSelected=false;
					removeAnnotationTools();
					removeUICompEventListners();
					applicationType::desktop{
						highlightTool.setStyle("imageSkin",annotate_markerDefault);
					}
					//highlightTool.enabled=false;
					//removeAnnotation();
					//this.cursorManager.removeAllCursors();
					setMouseIcon();
					/*p2fContainer.removeChildAt(2);
					if (p2fContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
					p2fContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);*/
				}
				else
				{
					annotationStart(toolSelected);
					applicationType::desktop{
						highlightTool.setStyle("imageSkin",annotate_markerActive);
						penTool.setStyle("imageSkin",pencilDefault);
					}
				}
			}
		}
		else
			return;
	}
	//Fix for issue #18009
	applicationType::web{
		if (p2fLoaderObj.numChildren>0 && p2fContainer.visible == true)	{
			var toolSelected:String=tool;
			//Fix for issue #18574
			if(penSelected||highlighterSelected) selectOne=true;
			if(toolSelected=="Pen")
			{
				//Fix for issue #18574
				prevTool="Pen";
				if(penSelected)
				{
					removeAnnotationTools();
					removeUICompEventListners();
					penTool.setStyle("imageSkin",pencilDefault);
				}
				else
				{
					annotationStart(toolSelected);
					penTool.setStyle("imageSkin",pencilActive);
					highlightTool.setStyle("imageSkin",annotate_markerDefault);
				}
			}
			else if(toolSelected=="Highlight")
			{
				//Fix for issue #18574
				prevTool="Highlight";
				if(highlighterSelected)
				{
					removeAnnotationTools();
					removeUICompEventListners();
					highlightTool.setStyle("imageSkin",annotate_markerDefault);
					setMouseIcon();
				}
				else
				{
					annotationStart(toolSelected);
					highlightTool.setStyle("imageSkin",annotate_markerActive);
					penTool.setStyle("imageSkin",pencilDefault);
				}
			}
		}
		else if(pptLoaded){
			var toolSelected:String=tool;
			if(toolSelected=="Pen")
			{
				//Fix for issue #18574
				prevTool="Pen";
				if(penSelected)
				{
					removeAnnotationTools();
					removeUICompEventListners();					
					penTool.setStyle("imageSkin",pencilDefault);					
				}
				else
				{			
					annotationStart(toolSelected);					
					penTool.setStyle("imageSkin",pencilActive);
					highlightTool.setStyle("imageSkin",annotate_markerDefault);
				}				
			}
			else if(toolSelected=="Highlight")
			{
				//Fix for issue #18574
				prevTool="Highlight";
				if(highlighterSelected)
				{
					removeAnnotationTools();
					removeUICompEventListners();				
					highlightTool.setStyle("imageSkin",annotate_markerDefault);
					setMouseIcon();
				}
				else
				{
					annotationStart(toolSelected);
					highlightTool.setStyle("imageSkin",annotate_markerActive);
					penTool.setStyle("imageSkin",pencilDefault);
				}
			}
		}
		else
			return;			
	}
}
/**
 *
 * @private
 * Audits the "DocumentAnnotationToolSelection" action, when the presenter selects a annonation tool
 *
 * @param url of the document
 * @param toolName - Name of the annotation tool
 * @param currentPageNum - Current page number
 * @return void
 *
 */
private function documentAnnotationToolSelectionEventLog(url:String, toolName:String, currentPageNum:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentAnnotationToolSelection, url, toolName, currentPageNum + "");
}

/**
 * For handling  Presenter's Annotation drawings
 * @param DrawingContainer of *
 */
private function annotateDoc(DrawingContainer:*):void{
	
	if (highlighterSelected){
		lineColor=HILIGHT_COLOR;
		if (pptLoaded)
			lineThickness=HILIGHT_THICKNESS_ANIMATED;
		else
			lineThickness=HILIGHT_THICKNESS_NONANIMATED;
		lineAlpha=HILIGHT_ALPHA;
	}
	else if(penSelected){
		lineColor=PEN_COLOR;
		if (pptLoaded)
			lineThickness=PEN_THICKNESS_ANIMATED;
		else
			lineThickness=PEN_THICKNESS_NONANIMATED;
		lineAlpha=PEN_ALPHA;
	}
	if (!uiComp && DrawingContainer.numChildren > 0){
		applicationType::DesktopMobile{
			uiComp=createUIComponent(0xFFFF00,0,DrawingContainer.width, DrawingContainer.height);		
			DrawingContainer.addChildAt(uiComp, 1);		
			if (pptLoaded)
			{
				applicationType::desktop{
					setUIcomponentDisplay(iSpringContainer.width,iSpringContainer.height);
				}
			}
			else{				
				setUIcomponentDisplay(p2fContainer.width,p2fContainer.height);			
			}
		}
		//Fix for issue #18009
		applicationType::web{
			uiComp = new UIComponent();
			uiComp.graphics.beginFill(0xFFFF00,0);
			if(pptLoaded)
			{
				uiComp.graphics.drawRect(uicompX,uicompY,DrawingContainer.width,DrawingContainer.height);
				setUIcomponentDisplay(iSpringContainer.width,iSpringContainer.height);
			}
			else
			{
				// Changed width and height for annotation scaling
				uiComp.graphics.drawRect(uicompX,uicompY,normalWidth,normalHeight);				
				// Added these logic for annotation scaling
				uiComp.scaleX = p2fLoaderObj.scaleX;
				uiComp.scaleY = p2fLoaderObj.scaleY; 
				//Instead of SWFLoader we use Loader to load the P2F document.Changed the width and height of UIComp
				uiComp.width=normalWidth;
				uiComp.height=normalHeight;
			}
			DrawingContainer.addChildAt (uiComp,1);
		}
	}
	applicationType::web{
		//Changed the condition.Earlier DrawingContainer contain max 3 children instead of 2
		if (userRole == Constants.PRESENTER_ROLE && isNewPageLoad && pointerShape && DrawingContainer.numChildren == 2)
		{
			//Added this logic to avoid pointer missing issue at user side when Presenter navigates the page
			showPointer(uiComp, normalWidth, normalHeight, uiComp);
		}
	}
	applicationType::DesktopMobile{
		if (userRole == Constants.PRESENTER_ROLE && isNewPageLoad && pointerShape && DrawingContainer.numChildren > 2){
			p2fContainer.swapChildrenAt(1, 2);
			p2fContainer.swapChildrenAt(0, 1);
			p2fContainer.swapChildrenAt(1, 2);
		}
	}
	
	if (this)
		this.addEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
	if (uiComp && !uiComp.hasEventListener(MouseEvent.MOUSE_DOWN) && userRole == Constants.PRESENTER_ROLE)
		uiComp.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
	isNewPageLoad=false;
	//next.enabled=true;
	//previousBtn.enabled=true;
	applicationType::DesktopWeb{
		thumbNailHorizontalBox.enabled=true;
		thumbNailVerticalBox.enabled=true;
	}
	isAnnotationToolRmoved=false;
	if(!highlighterSelected&&!penSelected)
		removeUICompEventListners();
}

/**
 * For removing  Presenter's Annotation Component
 */
private function removeAnnotationTools():void{
	isAnnotationToolRmoved=true;
	if(penSelected)
	{
		applicationType::DesktopWeb{
			penTool.setStyle("imageSkin",pencilDefault);
		}
		
	}
	if(highlighterSelected)
	{
		applicationType::DesktopWeb{
			highlightTool.setStyle("imageSkin",annotate_markerDefault);
		}
		
	}
	/*applicationType::DesktopWeb{
		if (annotation != null){
			annotation.visible=false;
			annotationBox.includeInLayout=false;
		}
	}*/
	if (!pptLoaded)
		fileNameWidth=(3 * p2fWidth) / 4;
	else
		fileNameWidth=(3 * iSpringWidth) / 4;
	if (penSelected || highlighterSelected)	{
		if (userRole == Constants.PRESENTER_ROLE)	{
			this.cursorManager.removeAllCursors();
			applicationType::web	{
				//Removed the check to avoid the pointer missing issue when Presenter clear the annotation
				removeUICompEventListners();
			}
			applicationType::DesktopMobile{
				//changes
				if (pptLoaded){
					removeUICompEventListners();
				}
			}
			if(!isNeedRemoveAnnotation)
				toolName="Remove annotation tools";
			else
				toolName="Remove annotation";
			documentCollaborationObject.setValue(ANNOTATIONTOOL, {toolName: toolName,prevTool:toolName});
			if (Log.isDebug()) log.debug("removeAnnotation: setAnnotationTool is called. toolName:" + toolName);
			
		}
		else{
			applicationType::web{
				//Fix for issue #20157
				if(pointerShape)
				{
					//Removed the check to avoid the pointer missing issue when Presenter clear the annotation
					addPointerToUIComp();
				}
			}
			/*applicationType::DesktopMobile{
				if (pptLoaded&&pointerShape){
					addPointerToUIComp();
				}
			}*/
		}
		applicationType::web{
			//p2fContainer.content is always null. So we changed the check
			if ((p2fLoaderObj.numChildren > 0 && p2fContainer.visible) || pptLoaded){
				setAnnotationFlag();
			}
		}
		applicationType::DesktopMobile{
			if ((p2fContainer.content && p2fContainer.visible) || pptLoaded){
				setAnnotationFlag();
			}
		}
	}

}
//RTCR: Need to change the function name
private function removeUICompEventListners():void{
	if (uiComp.hasEventListener(MouseEvent.MOUSE_DOWN))
		uiComp.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
	if (!pointerShape)	{
		if (uiComp.hasEventListener(MouseEvent.MOUSE_OUT))
			uiComp.removeEventListener(MouseEvent.MOUSE_OUT, mouseIconOutListner);
		if (uiComp.hasEventListener(MouseEvent.MOUSE_OVER))
			uiComp.removeEventListener(MouseEvent.MOUSE_OVER, mouseIconOverListner);		
	}
	/*else if (uiComp.numChildren > 0 && pointerShape){
		removeChildAndAddPointerToUIComp();
	}*/
}
//RTCR: Need to change the function name
private function addPointerToUIComp():void{
	if (!pointerShape)	{
		if (uiComp && uiComp.numChildren > 0)	{
			removeChildAndAddPointerToUIComp();
		}  
	}
}
//RTCR: Need to change the function name
private function setAnnotationFlag():void{
	toolName="";
	penSelected=false;
	highlighterSelected=false;
}

/**
 * For removing  Presenter's Annotation drawings
 */
private function removeAnnotation():void{
	if (userRole == Constants.PRESENTER_ROLE){		
		this.cursorManager.removeAllCursors();
		if (pptLoaded && uiComp){
			if (!pointerShape)	{
				applicationType::DesktopWeb{
					iSpringContainer.removeChild(uiComp);
				}
				uiComp=null;
			}
			else if (uiComp.numChildren > 0 && pointerShape){
				removeChildAndAddPointerToUIComp();
			}
		}
		else if (uiComp){
			applicationType::web{
				//Added this logic to avoid the pointer missing issue when Presenter clear the annotation
				if (!pointerShape)	{
					//change uicom8/10/14
					//removeUICompFromP2FContainer();
					
					if(uiComp)
					{
						p2fContainer.removeChild(uiComp);
						uiComp=null; 
					}
					
				}
				else if (uiComp.numChildren > 0 && pointerShape){
					removeChildAndAddPointerToUIComp();
				}
			}
			applicationType::desktop{
				//change uicom8/10/14
				//removeUICompFromP2FContainer();
				if(uiComp)
				{
					p2fContainer.removeChild(uiComp);
					uiComp=null; 
				}
				
			}
		}
	}
	else{
		if (pptLoaded){
			if (!pointerShape){
				if (uiComp)	{
					applicationType::DesktopWeb{
						iSpringContainer.removeChild(uiComp);
					}
					uiComp=null;
				}
			}
			else{
				if (uiComp && uiComp.numChildren > 0){
					removeChildAndAddPointerToUIComp();
				}
			}
		}
		else{
			applicationType::web{
				//p2fContainer.content is always null. So we changed the check
				if (p2fLoaderObj.numChildren > 0 && p2fContainer.visible){
					//Added this logic to avoid the pointer missing issue when Presenter clear the annotation
					if (!pointerShape){
						//change uicom8/10/14
						//removeUICompFromP2FContainer();
						if(uiComp)
						{
							p2fContainer.removeChild(uiComp);
							uiComp=null; 
						}
						
					}
					else{
						if (uiComp && uiComp.numChildren > 0){
							removeChildAndAddPointerToUIComp();
						}
					}
				}
			}
			applicationType::DesktopMobile{
				if (p2fContainer && p2fContainer.content && p2fContainer.visible){
					//change uicom8/10/14
					//removeUICompFromP2FContainer();
					if(uiComp)
					{
						//removeUICompFromP2FContainer();
						p2fContainer.removeChild(uiComp);
						uiComp=null;
					}
					
				}
			}
		}
	}
	if (uiComp && !pointerShape)
		uiComp=null;


}
//RTCR: Need to change the function name
private function removeUICompFromP2FContainer():void
{
	applicationType::DesktopWeb{
		
			if (uiComp)	{
				if(userRole == Constants.PRESENTER_ROLE){
				p2fContainer.removeChild(uiComp);
				uiComp=null;
			}
		
		else
			//p2fContainer.removeChild(uiComp);
			uiComp=null;
			//erase();
			
			
			}
		
	}
	applicationType::mobile{
		if(uiComp && uiComp.root!=null)
		{
			p2fContainer.removeChild(uiComp);
			uiComp=null; 
		}
	}
}
//RTCR: Need to change the function name
private function removeChildAndAddPointerToUIComp():void
{
	uiComp.removeChildren(0, uiComp.numChildren - 1);
	if(pointerShape)
	{
		uiComp.addChild(pointerShape);
	}
}

/**
 * For removing  mouse icon for annotation when presenter's
 * mouse goes to out from the document container
 * @param event of MouseEvent
 */
private function mouseIconOutListner(event:MouseEvent):void{
	this.cursorManager.removeAllCursors();
}

/**
 * invoke when presenter's mouse come to inside the document container
 * @param event of MouseEvent
 */
private function mouseIconOverListner(event:MouseEvent):void{
	if (!mousePointerShared && userRole == Constants.PRESENTER_ROLE)
		setMouseIcon();
}
/**
 * for setting the mouse icn according to the AnnotationTool
 */
private function setMouseIcon():void{
	this.cursorManager.removeCursor(myCursorId);
	if (penSelected)
		myCursorId=this.cursorManager.setCursor(penCursor, CursorManagerPriority.HIGH, -5, -20);
	else if (highlighterSelected)
		myCursorId=this.cursorManager.setCursor(highlightCursor, 2, -7, -16);
}

/**
 * For erase all annoatation objects from current page.
 */
private function erase():void{	
	cleanGrabageCollector();
	if (!pptLoaded)	{
		applicationType::DesktopMobile{
			//This logic is not needed now, since we have one UIComponent for annotation and pointer
			p2fContainer.removeChildAt(1);
		}
		//if (highlighterSelected || penSelected)	{
			if (userRole == Constants.PRESENTER_ROLE){
				setAnnotationEventListener();
			}
			applicationType::web{
				//Added this logic to avoid the pointer missing issue when Presenter clear the annotation
				if (mousePointerShare == mousePointerDisable)		
					uiComp.addChild(pointerShape);
			}
			applicationType::DesktopMobile{
				uiComp=null;
				annotateDoc(p2fContainer);
			}
		//}
		applicationType::web{
			//Added this logic to avoid the pointer missing issue when Presenter clear the annotation.Also bug fix for issue #8049
			if (pointerShape){
				removeChildAndAddPointerToUIComp();
			}
			else{
				//change uicom8/10/14
				//removeUICompFromP2FContainer();
				if(uiComp)
				{
					p2fContainer.removeChild(uiComp);
					uiComp=null; 
				}
				annotateDoc(p2fContainer);
			}
		}
	}
	else{
		//if (highlighterSelected || penSelected){
			if (pointerShape)
				uiComp.removeChildren(0, uiComp.numChildren - 1);
			else{
				applicationType::DesktopWeb{
					iSpringContainer.removeChild(uiComp);
					uiComp=null;
					
				}
				
			}
			applicationType::DesktopWeb{
				if(!pointerShape)
					annotateDoc(iSpringContainer);
			}
			if (userRole == Constants.PRESENTER_ROLE){
				setAnnotationEventListener();
				if (mousePointerShare == mousePointerDisable)
					uiComp.addChild(pointerShape);		
			}
			
		//}
	}
}
private function setAnnotationEventListener():void
{
	if (!uiComp.hasEventListener(MouseEvent.MOUSE_MOVE))
		uiComp.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
	if (!uiComp.hasEventListener(MouseEvent.MOUSE_UP))
		uiComp.addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
}
/**
 * For Scaling   Presenter's Annotation drawings in ispring container
 * @param zoomX of Number
 * @param zoomY of Number
 * @param width of Number
 * @param contentWidth of Number
 * @param contentHeight of Number
 */
private function ispringScaleDocument(zoomX:Number, zoomY:Number, width:Number, contentWidth:Number, contentHeight:Number):void
{
	uiComp.scaleX=zoomX * (width) / contentWidth;
	uiComp.scaleY=zoomY * (width) / contentHeight;
	if (userRole == Constants.PRESENTER_ROLE){
		//setContext(permission,unload,annotate);					
		ispringZoomFactorX=uiComp.scaleX;
		ispringZoomFactorY=uiComp.scaleY;
	}
}
private var objx1:int=0;
private var objy1:int=0;
private var objx2:int=0;
private var objy2:int=0;

private function mouseDownListener(event:MouseEvent):void{
	objx1=uiComp.mouseX;
	objy1=uiComp.mouseY;
	if (pointerShape){
		applicationType::web{
			//Added this check to avoid the issue: 'Supplied display object must be child of the caller'.
			removePointerAndEventListner();
		}
		applicationType::DesktopMobile{
			if (pptLoaded){
				removePointerAndEventListner();
			}
			else	{
				p2fContainer.removeChildAt(2);
				if (p2fContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
					p2fContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
		}
	}
	shapePointsArray=new Array();
	userDrawingSprite=new Sprite()
	uiComp.addChild(userDrawingSprite);
	shapePointSprite=new Shape();
	userDrawingSprite.addChild(shapePointSprite);
	shapePointSprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND, 2);
	shapePointSprite.graphics.moveTo(objx1, objy1);
	shapePointsArray.push({x: objx1, y: objy1});
	autoMouseUpDispatch=true;
	setAnnotationEventListener();
	applicationType::web{
		//Removed this check to fix issue #8022
		uiComp.addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
	}
	applicationType::DesktopMobile{
		if (!uiComp.hasEventListener(MouseEvent.MOUSE_OUT))
			uiComp.addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
	}
}
//RTCR: Need to change the function name
private function removePointerAndEventListner():void
{
	if (uiComp.contains(pointerShape))
		uiComp.removeChild(pointerShape);
	if (uiComp.hasEventListener(MouseEvent.MOUSE_MOVE))
		uiComp.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
}

private function mouseOutListener(event:MouseEvent):void
{
	if (pptLoaded){
		if (uiComp && ((uiComp.mouseX > uiComp.width || uiComp.mouseY > uiComp.height) || (uiComp.mouseX < 4 || uiComp.mouseY < 4)))
		  mouseOutListenerHandler();
	}
	else{
		applicationType::web{
			//Instead of SWFLoader we use Loader to load the P2F document
			if (docCanvas.mouseX > (docCanvas.width - 24) || docCanvas.mouseY > (docCanvas.height - 18) || (docCanvas.mouseX < 4 || docCanvas.mouseY < 4) || p2fLoaderObj.content.mouseX > (p2fLoaderObj.content.width - 24) || p2fLoaderObj.content.mouseY > (p2fLoaderObj.content.height - 18))
				mouseOutListenerHandler();
		}
		applicationType::DesktopMobile{
			if (p2fCanvas.mouseX > (docCanvas.width - 24) || p2fCanvas.mouseY > (p2fCanvas.height - 18) || (docCanvas.mouseX < 4 || docCanvas.mouseY < 4) || p2fCanvas.mouseX > (p2fCanvas.width) ||p2fCanvas.mouseY > (p2fCanvas.height - 18))
				mouseOutListenerHandler();
		} 
	}
}
//RTCR: Need to change the function name.
private function mouseOutListenerHandler():void{
	uiComp.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
	autoMouseUpDispatch=false
	mouseUpListener(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
}

private var autoMouseUpDispatch:Boolean=false;

private function mouseMoveListener(event:MouseEvent):void{
	objx2=uiComp.mouseX;
	objy2=uiComp.mouseY;
	if (pptLoaded)	{
		if ((objx1 < uiComp.width - 5 && objy1 < uiComp.height - 5) && (objx2 < uiComp.width - 5 && objy2 < uiComp.height - 5) && (objx1 > 4 && objy1 > 4) && (objx2 > 4 && objy2 > 4))	{			
			autoMouseUpDispatch=true;			
		}
		else{
			autoMouseUpDispatch=false;
			uiComp.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);			
			mouseUpListener(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
			return;
		}
	}	
	if (penSelected)
		myCursorId=this.cursorManager.setCursor(penCursor, CursorManagerPriority.HIGH, -5, -20);
	if (highlighterSelected)
		myCursorId=this.cursorManager.setCursor(highlightCursor, 2, -7, -16);		
	setShapeValues(objx1, objy1,objx2, objy2)	
	objx1=objx2;
	objy1=objy2;
}
private function setShapeValues(x1:Number,y1:Number,x2:Number,y2:Number):void{
	shapePointsArray.push({x: uiComp.mouseX, y: uiComp.mouseY});	
	shapePointSprite=new Shape();	
	shapePointSprite.graphics.moveTo(x1, y1);
	userDrawingSprite.addChild(shapePointSprite);
	shapePointSprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER, 2);	
	shapePointSprite.graphics.lineTo(x2, y2);
	
}
private function mouseUpListener(event:MouseEvent):void{
	this.cursorManager.removeAllCursors();
	if (mousePointerShare == mousePointerDisable){
		applicationType::web{
			//Commented this check for Pointer scaling.
			setSharingPointerDetails(event);
		}
		applicationType::DesktopMobile{
			if (pptLoaded)	{
				setSharingPointerDetails(event);
			}
			else{
				if (p2fContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
					p2fContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
				p2fContainer.addChildAt(pointerShape, 2);
				if (autoMouseUpDispatch){
					pointerShape.x=event.currentTarget.mouseX - 15;
					pointerShape.y=event.currentTarget.mouseY - 15;
					documentCollaborationObject.setValue(MOUSEPOINT, {pointerX: pointerShape.x, pointerY: pointerShape.y, teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: event.currentTarget.width, p2fHeightTeacher: event.currentTarget.height, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY})
					if (Log.isDebug()) log.debug("mouseMoveHandler: sharingMousePoint is called pointerX:" + pointerShape.x + ", pointerY:" + pointerShape.y + ", teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", p2fWidthTeacher:" + event.currentTarget.width + ", p2fHeightTeacher:" + event.currentTarget.height);
				}
				if (!p2fContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
					p2fContainer.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
		}
	}
	if (uiComp.hasEventListener(MouseEvent.MOUSE_UP))
		uiComp.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
	if (uiComp.hasEventListener(MouseEvent.MOUSE_MOVE))
		uiComp.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
	if (uiComp.hasEventListener(MouseEvent.MOUSE_OUT))
		uiComp.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
	if (!mousePointerShared && userRole == Constants.PRESENTER_ROLE)
		setMouseIcon();
	userDrawingSprite.removeChildren();
	if (uiComp.contains(userDrawingSprite))	{
		uiComp.removeChild(userDrawingSprite);
		cleanGrabageCollector();
		createAnnotationShape(shapePointsArray);
		documentCollaborationObject.setValue(ANNOTATIONOBJECTS, {pointsArray: shapePointsArray, iSpringWidthTeacher: iSpringWidth, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY});
		if (Log.isDebug()) log.debug("mouseUpListener: setAnnotationValues is called. pointsArray.length:" + shapePointsArray.length + ", iSpringWidthTeacher:" + iSpringWidth + ", zoomFactorX:" + ispringZoomFactorX + ", zoomFactorY:" + ispringZoomFactorY);
		shapePointsArray.splice(0);
	}
}

private function setSharingPointerDetails(event:MouseEvent):void
{
	if (uiComp.hasEventListener(MouseEvent.MOUSE_MOVE))
		uiComp.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
	uiComp.addChild(pointerShape);
	if (autoMouseUpDispatch){
		pointerShape.x=event.currentTarget.mouseX - 15;
		pointerShape.y=event.currentTarget.mouseY - 15;
		documentCollaborationObject.setValue(MOUSEPOINT, {pointerX: pointerShape.x, pointerY: pointerShape.y, teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: event.currentTarget.width, p2fHeightTeacher: event.currentTarget.height, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY})
		if (Log.isDebug()) log.debug("mouseMoveHandler: sharingMousePoint is called pointerX:" + pointerShape.x + ", pointerY:" + pointerShape.y + ", teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", p2fWidthTeacher:" + event.currentTarget.width + ", p2fHeightTeacher:" + event.currentTarget.height);
	}
	if (!uiComp.hasEventListener(MouseEvent.MOUSE_MOVE))
		uiComp.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
}

private function scaleDocument(zoomX:Number, zoomY:Number, width:Number, height:Number, contentWidth:Number, contentHeight:Number):void{
	
	if(zoomX ==Infinity || zoomY ==Infinity ||width ==Infinity|| height ==Infinity  || contentWidth ==Infinity  || contentHeight ==Infinity)
	return;
	applicationType::DesktopWeb{
		trace("Scale Document Called with zoomX -"+zoomX+" zoomY -"+zoomY +"Width - "+width +"Height - "+height+"Contenyt Width -"+contentWidth+"Content Height -"+contentHeight);
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			var tempDocLength:int=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded.length();
			var src:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded[tempDocLength - 1].@src;
			
			src=src.substr(0, src.lastIndexOf("."));
			src=src.substr(0, src.lastIndexOf("."));
			if (tempDocLength > 0 && remoteFilePath.substr(0, remoteFilePath.lastIndexOf(".")) == "/AVContent/Upload" + src)
				p2fContainer.addEventListener(FlexEvent.UPDATE_COMPLETE, recordZoom);
		}
	}
	applicationType::web{
		//Instead of SWFLoader we use Loader to load the P2F document
		p2fLoaderObj.scaleX=((zoomX * (width)) / contentWidth);
		p2fLoaderObj.scaleY=((zoomY * (width)) / (contentWidth));
		//Set p2fContainer width and height to make visible the annotation  
		p2fContainer.width=p2fLoaderObj.width;
		p2fContainer.height=p2fLoaderObj.height;
		//Added these logic for annotation scaling
		if (uiComp)	{
			uiComp.scaleX=p2fLoaderObj.scaleX;
			uiComp.scaleY=p2fLoaderObj.scaleY;
		}		
	}
	applicationType::DesktopMobile{
		if(ispringStatus && !isZoom){
			zoomX=1;
			zoomY=1;
		}
		p2fContainer.scaleX=((zoomX * (width)) / contentWidth);
		p2fContainer.scaleY=((zoomY * (width)) / (contentWidth));	
	}
	hideContextMenuList();
	if (userRole == Constants.PRESENTER_ROLE){
	
		applicationType::web {
			//Instead of SWFLoader we use Loader to load the P2F document
			zoomFactorX=p2fLoaderObj.scaleX;
			zoomFactorY=p2fLoaderObj.scaleY;			
		}
		applicationType::DesktopMobile{
			//setContext(permission,unload,annotate);					
			zoomFactorX=p2fContainer.scaleX;
			trace("zoomFactorX in scaleDocument "+zoomFactorX);
			zoomFactorY=p2fContainer.scaleY;
			
		}
		zoomChanged(zoomFactorX, zoomFactorY);
		if(Log.isDebug()) log.debug("scaleDocument:Scale the document with zoomFactorX"+zoomFactorX+",zoomFactorY"+zoomFactorY);
	}
	
	
}

private function recordZoom(evnt:FlexEvent):void{
	applicationType::web{
		//Instead of SWFLoader we use Loader to load the P2F document
		p2fLoaderObj.contentLoaderInfo.removeEventListener(FlexEvent.UPDATE_COMPLETE, recordZoom);		
	}
	applicationType::DesktopMobile{
		p2fContainer.removeEventListener(FlexEvent.UPDATE_COMPLETE, recordZoom);		
	}
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addZoomEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), p2fContainer.scaleX, p2fContainer.scaleY, docScroller.horizontalScrollBar.maximum,docScroller.verticalScrollBar.maximum);
	}
}

private function getsize():void{
	clearTimeout(getSizeTimeout);
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addSizeTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(),maxX, maxY, p2fWidth, p2fHeight, p2fContainer.scaleX, p2fContainer.scaleY,scrollPositionX, scrollPositionY );
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addPageEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), currentPage);
	}
}

/**
 *for initilize the progress bar at the start of local download
 * @param ev of Event
 */
private function openHandler(ev:Event):void{
	applicationType::DesktopWeb{
		progressBar=new ProgressBar();
		progressBar.height=50;
		progressBar.horizontalCenter=0;
		progressBar.verticalCenter=0
		progressBar.indeterminate=true;
		progressBar.labelPlacement="center";
		addComponent(this, progressBar);
		progressBar.label="Downloading.....";
		if(Log.isDebug()) log.debug("openHandler:start download");
	}
}

/**
 *This function is measure the download progresses
 * @param ev of ProgressEvent
 */
private function progressHandler(ev:ProgressEvent):void{
	var per:Number=((ev.bytesLoaded / ev.bytesTotal) * 100);
	var r:String=per.toFixed(1);
	applicationType::DesktopWeb{
		progressBar.label="Downloading..." + r + "%"
		progressBar.setProgress(ev.bytesLoaded, ev.bytesTotal);
		if(Log.isDebug()) log.debug("progressHandler:dowwnload progress start");
	}
}

/**
 *for removing the progress bar after local download
 * @param ev of Event
 */
private function downloadComplete(ev:Event):void{
	
	applicationType::DesktopWeb{progressBar.indeterminate=false;
		progressBar.setStyle("barColor", 0xf6c311);
		progressBar.label="Download Complete.....";
	}
		setTimeout(removeProgressBar, 4000);
	applicationType::DesktopWeb{
		documentDownloadLocalEventLog(remoteFilePath);
		if(Log.isDebug()) log.debug("downloadComplete:Download complete with:remoteFilePath "+remoteFilePath);
	}
	applicationType::mobile{
		Toast.show("The document is download to the selected directory",null);
	}
}


/**
 *
 * @private
 * Audits the "DocumentDownloadLocal" action, when the user downloads the document to local machine
 *
 * @param url of the document
 * @return void
 *
 */
private function documentDownloadLocalEventLog(url:String):void
{
	AuditContext.userAction.createAction(AuditConstants.documentDownloadLocal, url, null, null);
}

/**
 * event listener for showing the HTTP status
 * @param event of HTTPStatusEvent
 */
private function httpStatusListener(event:HTTPStatusEvent):void{
	applicationType::web{
		//Instead of SWFLoader we use Loader to load the P2F document
		if (p2fLoaderObj.contentLoaderInfo.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
			p2fLoaderObj.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener);
	}
	applicationType::DesktopMobile{
		if (p2fContainer.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
			p2fContainer.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener);
	}	
	if (event.status != 200)
		showDownloadErrorMessage("An error with HTTP Status code " + event.status + " occured.");

}

/**
 * For removing the prgress bar for download progress
 */
private function removeProgressBar():void
{
	applicationType::DesktopWeb{
		if (progressBar) removeComponent(this, progressBar);
	}
}

/**
 * Event listener for identifying input output errors
 * @param event of IOErrorEvent
 */
private function IOStatusListener(event:IOErrorEvent):void
{
	if (Log.isDebug()) log.debug("IOStatusListener. Page number" + currentPage);
	if (p2fContainer.hasEventListener(IOErrorEvent.IO_ERROR))
		p2fContainer.removeEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
	
	if (p2fContainer.source == "" || tempPath == null) 	{ //sanity check
		if (Log.isDebug()) log.debug("IOStatusListener. P2fContainer.source set to '' or tempPath1 is null");
	}
	else{
		if (Log.isDebug()) log.debug('IOStatusListener. IO error while trying to access the document:' + event);
		showDownloadErrorMessage("An I/O error occured while trying to access the document.");
	}
}

/**
 * function for identifying a security error occurs while content is loading
 * @param event of SecurityErrorEvent
 */
private function securityErrorHandler(event:SecurityErrorEvent):void{	
}

/**
 * for showing an download error message
 * And also enabling the refresh button
 * @param msg of String
 */
private function showDownloadErrorMessage(msg:String):void{
	if (!isdownloadErrorShown)	{
		alert=MessageBox.show(msg + "\nPlease click the refresh button to try again", "INFO", MessageBox.MB_OK, this.parent as Sprite);
		applicationType::DesktopWeb{
			controlStack.enabled=true;
			fileLoad.visible=false;
			if (userRole != Constants.PRESENTER_ROLE)
				studentRefreshBtn.enabled=true;
			else
				teacherRefreshBtn.enabled=true;
		}
		applicationType::mobile{
			if(userRole != Constants.PRESENTER_ROLE)
			{
				FlexGlobals.topLevelApplication.docTool.btnViewerRefresh.enabled = true;						
			}
			else
			{
				FlexGlobals.topLevelApplication.docTool.btnPresenterRefresh.enabled = true;				   		
			}
		}
		applicationType::web{
			//Instead of SWFLoader we use Loader to load the P2F document
			if (p2fLoaderObj.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS))
				p2fLoaderObj.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			if (p2fLoaderObj.contentLoaderInfo.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
				p2fLoaderObj.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener);
			if (p2fLoaderObj.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR))
				p2fLoaderObj.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
			if (p2fLoaderObj.contentLoaderInfo.hasEventListener(Event.COMPLETE))
				p2fLoaderObj.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesDownloaded);
		}
		applicationType::DesktopMobile{
			if (p2fContainer.hasEventListener(ProgressEvent.PROGRESS))
				p2fContainer.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			if (p2fContainer.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
				p2fContainer.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener);
			if (p2fContainer.hasEventListener(IOErrorEvent.IO_ERROR))
				p2fContainer.removeEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
			if (p2fContainer.hasEventListener(Event.COMPLETE))
				p2fContainer.removeEventListener(Event.COMPLETE, bytesDownloaded);
		}
		isdownloadErrorShown=true;
	}
}

private function hideThumbNail():void{
	
	applicationType::DesktopWeb{
	
	if (isVThumb){
	VThumbdecreaseWidthEffect.play();
	isVThumb=false;
	vHideBtn.setStyle("icon", unhideThumbLeft);
	}
	else if (isHThumb){
		HThumbdecreaseWidthEffect.play();
		isHThumb=false;
		hHidebtn.setStyle("icon", thumbDown);
	}
	thumStatus=true;
	//thumClick=true;
	
	}
	
}
/**
 * function for removing thumnail data
 */
 
private function removeThumnail():void
{
	thumbnailDataCollection=null;
}

/**
 * function for showing the list of uploaded files and user created folders from the server
 */
private function showFileList():void
{
	if (fileManager)
		return;
	hideContextMenuList();
	// CRASH: API (flexGlobals)
	applicationType::DesktopWeb{
		fileManager = new FileManager();
	}
	applicationType::mobile{
		fileManager = new MobileFileManager();
	}
	fileManager.rootFolder=presenterName + "/My Documents";	
	//fileManager.defaultFolderPath = "../../AVContent/Upload/Personal/"+presenterName+"/My Documents";
	fileManager.serverIPAddress=ClassroomContext.CONTENT_DOCUMENT;
	fileManager.isSharedLibraryVisible=true;
	//RGCR:User role should not be passed to fileManager.
	fileManager.userRole=userRole;
	fileManager.usingModule="Document Sharing";
	//fileManager.toolTipChange("Upload new document");
	fileManager.excludeFolderCreationStartingWith("_sfp__", "You cannot create a folder starting with '_sfp__'\nPlease provide another name.");
	fileManager.excludeFileDeletion(" - No documents - ", "No documents to delete!");
	fileManager.excludeFileDeletion("welcome", "You cannot delete this file!");
	fileManager.excludeFilePathDeletion(remoteFilePath, "You cannot delete a document while it is being used!");
	fileManager.excludeFolderPathDeletionPrefixOf(remoteFilePath, "You cannot delete a folder while any of its document is being used!");
	fileManager.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
	fileManager.addEventListener(ContentOperationEvent.SELECTION, onSelectionHandler)
	fileManager.addEventListener(ContentOperationEvent.DELETE, onDleteHandler)
	fileManager.addEventListener(ContentOperationEvent.FILELIST, onFileListHandler)
	fileManager.addEventListener(ContentOperationEvent.SHAREDFILELIST, onSharedFileListHandler)
	fileManager.addEventListener(ContentOperationEvent.DOWLOAD, onDownloadHandler)
	fileManager.addEventListener(ContentOperationEvent.UPLOAD, onUploadHandler)
	fileManager.addEventListener(ContentOperationEvent.CHECKEXISTANCE, onCheckFileExistanceHandler)
	fileManager.addEventListener(ContentOperationEvent.COPY, onCopyHandler)
	fileManager.addEventListener(ContentOperationEvent.CREATFOLDER, onCreateFolderHandler)
	fileManager.addEventListener(ContentOperationEvent.PREINITILIZEUPLOAD, onPreinitilizeUpload)
	fileManager.addEventListener("onDownloadRequest",onDownloadRequest);
	
	applicationType::DesktopWeb{
		PopUpManager.addPopUp(fileManager, docCont, true, PopUpManagerChildList.POPUP);
		PopUpManager.centerPopUp(fileManager);
		remoteFileName="";
		applicationType::desktop{
			if (userRole == Constants.PRESENTER_ROLE){
			if(setUpload) fileManager.setUploadBtn(true);
			else fileManager.setUploadBtn(false);
		
			if(setUpload) fileManager.setCommonUploadBtn(true);
			else fileManager.setCommonUploadBtn(false);
			}
			else{
				fileManager.setUploadBtn(false);
			}
				
		}
		//Fix for issue #18795
		applicationType::web{
			if (userRole == Constants.PRESENTER_ROLE){
				if(setUpload) fileManager.setUploadBtn(true);
				else fileManager.setUploadBtn(false);
				
				if(setUpload) fileManager.setCommonUploadBtn(true);
				else fileManager.setCommonUploadBtn(false);
			}
			else{
				fileManager.setUploadBtn(false);
			}
		}
		
			
	}
	applicationType::mobile{
		fileManager.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,modifyCalloutVisibility);
		fileManager.addEventListener(PopUpEvent.CLOSE,modifyCalloutVisibility);
	}
	fileManager.isPopUp=false;
}
private var isFolderSelected:Boolean

public var contentService:ContentService=new ContentService();

private function onSelectionHandler(event:ContentOperationEvent):void{
	var xml:XML=XML(event.selectedItem);
	var tag:String=xml.name();
	selectArea=event.selectedArea;
	fileManager.setDownloadDiscBtn(false);
	fileManager.setCreateBtn(false);
	fileManager.setDeleteBtn(false);
	fileManager.setDownloadBtn(false);
	fileManager.setUploadBtn(false);
	var usrname:String=ClassroomContext.userVO.userName;
	if (xml.@type == "initial" || tag == null || xml.@type == "fault")
		return;
	if (xml.@status == "Conversion Started"){
		alert= MessageBox.show("Selected file is being processed , please wait.", "Info", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO)
		return;	
	}
	if (xml.@status == "Conversion not started"){
		alert=MessageBox.show("Selected file is being processed , please wait.", "Info", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO)
		return;
	} 
	
	if ((xml.@label == "-No Documents-") && String(xml.@path) == ""){
		alert=MessageBox.show("There is no documents in this folder.", "Info", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO)
		//Path of the selected remote file
		remoteFilePath="";
		//name of the selected remote file/folder 
		remoteFileName="";
		isFolderSelected=false;
		//fileManager.setCommonCreateBtn(false);
		fileManager.setCommonDeleteBtn(false);
		fileManager.setCommonDownloadBtn(false);
		//fileManager.setCommonUploadBtn(false);
	}
	//--END-------------------------------------------------------------------------------------------
	
	else if (tag)
	{
		
		if (tag != "root") fileManager.setDeleteBtn(true);
		else fileManager.setDeleteBtn(false);
		remoteFilePath=xml.@path;	
		//trace("Remote File Path"+remoteFilePath);
		if (tag == fileManager.xmlFolder || tag == "root"){
			if (event.selectedArea == "SharedArea"){
				if (xml.attribute("type") == "classes" || xml.attribute("type") == "institutes" || xml.attribute("type") == "courses"){
					fileManager.setCommonDeleteBtn(false);
				}
				var isModerator:Boolean=isModeratorFolder(xml);
			}
			
			isFolderSelected=true;	
		}
		else{
			if (event.selectedArea == "SharedArea")	{
				var parent:XML=xml.parent();
				if (xml.@type != "initial")	{
					if (parent.attribute("is_moderator") == 'Y')
							isModerator=true;
					else if (parent.attribute("is_moderator") == 'N')
						isModerator=isModeratorFolder(parent);
				}
			}
			isFolderSelected=false;
		}
	}
	if (tag == "emptyFolder"){
		fileManager.setCommonCreateBtn(false);
		fileManager.setCommonDeleteBtn(false);
		fileManager.setCommonDownloadBtn(false);
		fileManager.setCommonUploadBtn(false);
		
		isFolderSelected=true
		isModerator=false;
	}
	if (isFolderSelected){
		remoteFileName=xml.@label;	
		if (event.selectedArea == "SharedArea")	{
			if (isModerator){
				fileManager.setCommonDownloadBtn(false);
				fileManager.setCommonCreateBtn(true);
				if(setUpload) fileManager.setCommonUploadBtn(true);				
				if (xml.@type != "classes")	
					fileManager.setCommonDeleteBtn(true);
			}
			else{
				fileManager.setCommonCreateBtn(false);
				fileManager.setCommonDeleteBtn(false);
				fileManager.setCommonDownloadBtn(false);
				fileManager.setCommonUploadBtn(false);
			}
			if (event.selectedItem && xml.@type != "initial")
				fileManager.setDownloadDiscBtn(false);
		}
		else{
			fileManager.setDownloadBtn(false);
			fileManager.setCreateBtn(true);
			if(setUpload) fileManager.setUploadBtn(true);
		}
	}
	else{
		remoteFileName=xml.@label;	
		//trace("Remote File Name"+remoteFileName);
		if (event.selectedArea == "SharedArea")	{
			if (isModerator && xml.@label != "Document list is loading, Please wait..."){
				if (userRole == Constants.PRESENTER_ROLE)
				fileManager.setCommonDownloadBtn(true);
				fileManager.setCommonCreateBtn(false);
				fileManager.setCommonUploadBtn(false);
				fileManager.setCommonDeleteBtn(true);
			}
			else if (xml.@label != "Document list is loading, Please wait..."){
				if (userRole == Constants.PRESENTER_ROLE)
					fileManager.setCommonDownloadBtn(true);
				fileManager.setCommonCreateBtn(false);
				fileManager.setCommonUploadBtn(false);
				fileManager.setCommonDeleteBtn(false);
			}
			fileManager.setDownloadDiscBtn(true);
		}
		else{
			fileManager.setUploadBtn(false);
			fileManager.setCreateBtn(false);
			if (xml.@label != "-No Documents-")
				fileManager.setDownloadBtn(true);
		}
	}
	if (remoteFilePath.indexOf("../../AVContent/Upload/Common") != -1)	{
		if (tag != "root" && !isFolderSelected)
			fileManager.setDownloadBtn(true);
		else
		fileManager.setDownloadBtn(false);
		fileManager.setUploadBtn(false);
		fileManager.setCreateBtn(false);
		fileManager.setDeleteBtn(false);
	}

	//var rooFolder:String="../../AVContent/Upload/Personal/" + usrname +"/My Documents";
		if(remoteFilePath=="../../AVContent/Upload/Personal/" + usrname +"/My Documents")
	{
		fileManager.setDeleteBtn(false);
		fileManager.setDownloadBtn(false);
		if(!setUpload) fileManager.setUploadBtn(false);
	}

}

private function onDleteHandler(passedEvent:Object):void{
	var event = passedEvent as  ContentOperationEvent;
	if (remoteFileName == ""){
		alert=MessageBox.show("No file selected for deletion", "INFO", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO);
		return;
		
	}
	
	remoteFilePath=remoteFilePath.replace("./../../../../", "../../");
	//trace("Remote fiel Path"+remoteFilePath);
	var exclusionMsg:String=fileManager.checkExclusionMessage(remoteFilePath, remoteFileName, isFolderSelected);
	if (exclusionMsg != "")
		alert=MessageBox.show(exclusionMsg, "INFO", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO);
	else
	{
		if((previousRemoteFilePath.search(remoteFilePath))>-1)
		{
			if(isFolderSelected)
				alert=MessageBox.show(" You cannot delete a folder while any of its document is being used!", "INFO", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO);
			else
				alert=MessageBox.show("You Can't Delete Loaded file", "INFO", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO);
			return;
		}
		if(remoteFilePath==previousRemoteFilePath)
		{
			alert=MessageBox.show("You Can't Delete Loaded file", "INFO", MessageBox.MB_OK, fileManager, null, null, MessageBox.IC_INFO);
			return;
		}
		if(!isFolderSelected)
			alert=MessageBox.show("Do you want delete this file", "Confirm File Deletion", MessageBox.MB_YESNO, fileManager, deleteConfirmation, null, MessageBox.IC_DELETE);
		else 
			alert=MessageBox.show("Do you want Delete this folder and all its contents", "Confirm File Deletion", MessageBox.MB_YESNO, fileManager, deleteConfirmation, null, MessageBox.IC_DELETE);
	}
	
}

private function deleteConfirmation(passedEvent:Object):void{
	
	var event = passedEvent as MessageBoxEvent;
	if (event.type == "messageBoxYES")
		contentService.deleteFile(remoteFilePath, successfullDeletion, deletionFaultHandler,usingModule,remoteFileName);
}

private function successfullDeletion(ev:String):void
{	
	MessageBox.show("'" + remoteFileName + "' has been deleted", "Deletion Successful", MessageBox.MB_OK, fileManager);
	fileManager.loadFileList();
}

private function deletionFaultHandler(obj:Object):void{		
}

private function onFileListHandler(passedEvent:Object):void{
	var event = passedEvent as ContentOperationEvent;
	//selectArea=event.Type;
	//remoteFilePath=remoteFilePath.replace(("/"+SFP_FOLDER_PREFIX+ remoteFileName),"");
	remoteFilePath=docBaseRoot + event.rootFolder;
	fileRoot=event.rootFolder;
	if(Log.isDebug()) log.debug("onFileListHandler:remoteFilePath"+remoteFilePath);
	contentService.getFileList(event.rootFolder, fileListResultHandler, fileListfaultHandler);
}

private function fileListResultHandler(obj:Object):void{
	if(Log.isDebug()) log.debug("fileListResultHandler:fileListResultHandler"+obj.result);
	fileManager.setFileList(obj.result);
}

private function fileListfaultHandler(obj:Object):void{
	if(Log.isDebug()) log.debug("fileListfaultHandler:Fault :fileRoot"+fileRoot);
	contentService.getFileList(fileRoot, fileListResultHandler, fileListfaultHandler1);
	//fileManager.showErrorInFileList();
}

private function fileListfaultHandler1(obj:Object):void{
	if(Log.isDebug()) log.debug("fileListfaultHandler_AgainFault:Fault");
	fileManager.showErrorInFileList();
}
private function onSharedFileListHandler(passedEvent:Object):void{
	var event = passedEvent as ContentOperationEvent;
	
	applicationType::DesktopWeb{
		contentService.getSharedFileList("./../../../../AVContent/Upload/Common", FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.xmlClassRepository, sharedLaibraryResultHandler, faultHandler);
	}
	applicationType::mobile{
		contentService.getSharedFileList("./../../../../AVContent/Upload/Common", FlexGlobals.topLevelApplication.mainApp.xmlClassRepository, sharedLaibraryResultHandler, faultHandler);
	}
}

private function sharedLaibraryResultHandler(obj:Object):void{
	if(Log.isDebug()) log.debug("sharedLaibraryResultHandler:Result----"+obj.result);
	removeProgressBar();
	fileManager.setSharedFileList(obj.result);
}

 private function onUploadHandler(passedEvent:Object):void{
	//var leng=Number;
	
	var event = passedEvent as ContentOperationEvent;
	/*applicationType::desktop{
		//fileExtention= event.fileReference.extension;
	}*/
	applicationType::web{
		fileExtention= event.fileReference.type;
	}
	remoteFileName=event.fileReference.name;
	remoteFileName=remoteFileName.replace(/\s|\,/g,"_");
	//leng=remoteFileName.length;
	//trace(leng);
	if(remoteFileName.length>100)
	{
	alert=MessageBox.show(" Filename length should not exceed 100 characters , file cannot be uploaded.Please rename the file and try again.", "Warning", MessageBox.MB_OK, fileManager as Sprite);
	
		if(fileManager.upload)
		{
		PopUpManager.removePopUp(fileManager.upload);
		fileManager.upload=null;
		}
	return;
	}
	isAnimateCheck=event.isAnimatedFile;
	var folderPath:String=remoteFilePath + "/@@-OriginalDocs-@@";
	temFilePath =remoteFilePath;
	setUpload=false;
	checkLogFileCount = 0;
	removeAllPopUpWndw();
	uploadStatus=true;
	//logFileName = temFilePath+ "/Log"+remoteFileName+".txt";
	logFileName = temFilePath+ "/Log"+remoteFileName;
	checkPPTFileName = remoteFilePath+"/"+ remoteFileName + ".swf";
	var areaSelect:String=selectArea;
	
	//var checkFile:String=remoteFilePath + "/@@-OriginalDocs-@@/"+ remoteFileName;
	//checkFileNew=checkFile;
	uploadCom=true;
	setTimeout(contentService.checkFileExistance,4000,checkFileNew, FileExistHandler,FileExistFaultHandler);
	if(pptLoaded)
	{
	
		uploadTimeOut = setTimeout(contentService.checkFileExistance,1200000,checkPPTFileName, pptFileExistHandler,FileExistFaultHandler);
	}
	else
	{
		uploadTimeOut = setTimeout(contentService.checkLogFileExistance, 1200000,logFileName, logFileExitHandler, FileExistFaultHandler);
	}
	/*if(remoteFilePathDown==getDownloadableRemotePath(remoteFilePath)+"/"+SFP_FOLDER_PREFIX+replaceSpecialChars(remoteFileName)){
		unloadDocument();
	//contentService.deleteFile(remoteFilePath, successfullDeletionFile, deletionFaultHandler,usingModule,remoteFileName);
	}*/
	contentService.uploadFileDocument(folderPath, event.fileReference, uploadComplete, onFault,ClassroomContext.userVO.userId,ClassroomContext.DATABASE_SERVER,event.isAnimatedFile,areaSelect);
	//contentService.uploadFileDocument(folderPath, event.fileReference, uploadSuccess, onFault,ClassroomContext.userVO.userId,ClassroomContext.DATABASE_SERVER,event.isAnimatedFile,areaSelect);
	applicationType::DesktopWeb{
		uploadProgress.visible=true;
		uploadProgress.includeInLayout=true;
		uploadProgress.load();
	}
	//uploadDocument();
}

private function pptFileExistHandler(data:Object):void
{
	clearTimeout(uploadTimeOut);
	var dataResult:String = data.result;
	if(dataResult.indexOf(ERROR) != -1)
	{
		if(checkLogFileCount == 5)
		{
			MessageBox.show("Upload failed. Please try again!!","INFO", MessageBox.MB_OK,this);
			setUpload=true;
		}
		else
		{
			
			checkLogFileCount++;
			uploadTimeOut = setTimeout(contentService.checkFileExistance,120000,checkPPTFileName, pptFileExistHandler,FileExistFaultHandler);
		}
	}
	else
	{
		if(isProgressBarPresent)
			this.removeElement(progressBar);
		checkLogFileCount = 0;
	}
}
private function logFileExitHandler(data:Object):void
{
	clearTimeout(uploadTimeOut);
	var dataResult:String = data.result;
	if(dataResult.indexOf(ERROR) != -1)
	{
		if(checkLogFileCount == 5)
		{
			MessageBox.show("Upload failed. Please try again!!","INFO", MessageBox.MB_OK,this);
			setUpload=true;
			applicationType::DesktopWeb{
				setUpload=true;
				uploadProgress.visible=false;
				uploadProgress.includeInLayout=false;
			}
		}
		else
		{
			checkLogFileCount++;
			uploadTimeOut = setTimeout(contentService.checkLogFileExistance, 120000,logFileName, logFileExitHandler, FileExistFaultHandler);
		}
	}  
	else
	{
		if(isProgressBarPresent)
			this.removeElement(progressBar);
		checkLogFileCount = 0;
		
	}
	
}

private function FileExistHandler(data:Object):void
{
	if(checkFile==20)
	{
		uploadCom=false;
	}
	else
	fileexistance(data.result);
	
}
private function FileExistFaultHandler(ev:Event):void
{
	//Alert.show("Handle Fault");
}
private function fileexistance(data:String):void{
	if(data.indexOf(ERROR) == -1)
	{	
		//trace("File Doest Exist");
		checkFile=checkFile+1;
		setTimeout(contentService.checkFileExistance,3000,checkFileNew, FileExistHandler,FileExistFaultHandler);
		
	}
	else
	{
		uploadCom=false;
	}
	
}
/*private function readFile():void{
	var tok:AsyncToken=srv.send();
	srv.addEventListener(ResultEvent.RESULT,result);
	srv.addEventListener(FaultEvent.FAULT,fault);
}*/
private function result(ev:Object):void{
	//trace("Suceess Read Filee");
	var obj:Object=ev.result as Object;
	//trace("Success with"+ev.result);
	readFileResult(ev.result);
}
private function readFileResult(data:String):void{
	if(data.indexOf(ERROR) == -1){
		//trace("Sucess")
	}
	else{
		//trace("fault");
	}
}
private function fault(ev1:FaultEvent):void
{
	//trace("Fault Occur Reading File");
}


private function uploadComplete(event:Event):void{
		
	//uploadProgress.unload();
	
	//connectionStatus=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected;
	//connectionStatus=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isReconnect;
	trace("Classroom Com"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp);
	trace("userConnection"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection);
	trace("netConnection"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection);
	//trace("Connected"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected);
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection==null){
		trace("Return the Upload Complete");
		applicationType::DesktopWeb{
			setUpload=true;
			uploadProgress.visible=false;
			uploadProgress.includeInLayout=false;
			return;
		}
		
	}
	else  
	{
	applicationType::DesktopWeb{    
		uploadProgress.visible=false;
		uploadProgress.includeInLayout=false;
		clearTimeout(uploadTimeOut);
		uploadCom=false;
		//FlexGlobals.topLevelApplication.mainApp.isCompleteUpload=false;
	}
	if(isProgressBarPresent)
		this.removeElement(progressBar);
	checkLogFileCount = 0;
  if(uploadStatus)
  {
		setUpload=true;
		if(userRole == Constants.PRESENTER_ROLE)
		{
			 var filePath:String=temFilePath+"/"+SFP_FOLDER_PREFIX+replaceSpecialChars(event.currentTarget.name);
			 if(remoteFilePathDown==getDownloadableRemotePath(filePath)) unloadDocument();
	if((p2fContainer.content == null && !pptLoaded)||remoteFilePathDown==getDownloadableRemotePath(filePath)){
		//if(remoteFilePath==""||fileManager) 
		remoteFilePath=temFilePath;	
		var animated:String="No Animations";
		remoteFileName=event.currentTarget.name;
		remoteFileName=replaceSpecialChars(remoteFileName);
		/*if (isISpringFile(fileExtention )&&isAnimateCheck=="Y"){
			animated="Animations"
			
			remoteFilePath=getDownloadableRemotePath(remoteFilePath)+"/"+ remoteFileName + ".swf";
		}*/
		//Fix for issue #18009
		applicationType::desktop{
			fileExtention=event.currentTarget.extension;
		}
		applicationType::web{
			fileExtention=event.currentTarget.type;
		}
		if(isISpringFile(fileExtention)&&isAnimateCheck=="Y")
		{
			animated="Animations"
			
			remoteFilePath=getDownloadableRemotePath(remoteFilePath)+"/"+ remoteFileName + ".swf";
		}
		else
		{
			remoteFilePath=getDownloadableRemotePath(remoteFilePath)+"/"+SFP_FOLDER_PREFIX+ remoteFileName;
		}
		 loadFileToCache(remoteFilePath, fileExtention, remoteFileName);
	
	}
	//setTimeout(showStatus,1000);
	
	else if(event.type=="complete")
	{
		MessageBox.show("Document uploaded successfully and can be downloaded from the corresponding folder.", "INFO",MessageBox.MB_OK,this);
	}
		
  }
  }
	}
	
}
/*private function showStatus():void{
	MessageBox.show("Document uploaded successfully and can be downloaded from the corresponding folder.", "INFO",MessageBox.MB_OK,this);
}*/
private function test(event:Event):void{
	  
}
private function onFault(event:Event):void{
	
}
private function onCheckFileExistanceHandler(passedEvent :Object):void{
	var event = passedEvent as ContentOperationEvent;
	//public var folderPath:String=remoteFilePath + "/@@-OriginalDocs-@@/"+ passedEvent.fileName;
	folderPath=remoteFilePath + "/@@-OriginalDocs-@@/"+ passedEvent.fileName;
	//folderPath=fileManager.replaceSpecialChars(folderPath,this);
	checkFileNew=folderPath;
	contentService.checkFileExistance(folderPath, checkFileExistanceResultHandler, faultHandler)
}

private function checkFileExistanceResultHandler(data:Object):void{
	
	
	fileManager.fileExistanceMessage(data.result);
}
private function successfullDeletionFile():void{
	
}
private function onCopyHandler(passedEvent : Object):void{
	var event = passedEvent as ContentOperationEvent;
	fileManager.showCopyProgressing();
	contentService.copyFiles(event.sourcePath, event.destinationPath, copyResultHandler, copyFaultHandler)
}

private function copyResultHandler(obj:Object):void{
	fileManager.showCopyFileResult(obj.result);
}

private function copyFaultHandler(event:Event):void{
}

private function onCreateFolderHandler(passedEvent :Object):void{
	var event = passedEvent as ContentOperationEvent;
	var folderPath:String="";
	if (remoteFilePath.indexOf("../../AVContent/Upload/Common") != -1)
	{
		folderPath=event.folderName;
	}
	else{
	folderPath=remoteFilePath + event.folderName;
	}
	folderPath=folderPath.replace("./../../../../", "../../");
	contentService.createFolder(folderPath, succesFolderCreation, onFault);
}

private function succesFolderCreation(msg:Object):void{
	fileManager.successNewFolder();
}

private function onDownloadHandler(passedEvent :Object):void{
	var event = passedEvent as ContentOperationEvent;
	//remoteFilePathDown=remoteFilePath;
	//remoteFileNameDown=remoteFileName;
	if (getDownloadableRemotePath(previousRemoteFilePath) != getDownloadableRemotePath(remoteFilePath) && userRole == Constants.PRESENTER_ROLE)
	{
		isDownload=true;
		removeAllPopUpWndw();
		fileExtention=getFileExtension(remoteFileName);
		//loadFileToCache(getDownloadableRemotePath(remoteFilePath), fileExtention, remoteFileName);
		loadFileToCache(getDownloadableRemotePath(remoteFilePath), fileExtention, remoteFileName);
	}
	else
	{
		
		alert=MessageBox.show("This file currently being loaded and cannot be loaded again ", "Warning", MessageBox.MB_OK, fileManager as Sprite);
	}
}

public function getDownloadableRemotePath(remotePath:String):String{
	var downloadable:String="";
	var contentRoot:String="/AVContent/";
	var idx:Number=remotePath.indexOf(contentRoot, 0);
	if (idx != -1)
	{
		downloadable=remotePath.substring(idx);
	}	
	return downloadable;
}
private var fileFileter:FileFilter=new FileFilter("Document Files", "*.pdf;*.ppt;*.jpg;*.png*;.doc;*.docx;*.pptx;*.xlsx;*.bmp;*.gif;*.xls;*.txt;*.tif");
private function onPreinitilizeUpload(event:Object):void{	
	fileManager.setUploadData(fileFileter);
}


private function getFolderPath(filePath:String):String{
	var folderPath:String="";
	var lastIdx:int=filePath.lastIndexOf("/", filePath.length);
	if (lastIdx != -1)
	{
		folderPath=filePath.substr(0, lastIdx);
	}
	return folderPath;
}

private function onCloseFileComponentEvent(passedEvent:Object):void{
	var event = passedEvent as CloseFileComponentEvent;
	if (event.componentName == CloseFileComponentEvent.FILE_MANAGER)
		removeAllPopUpWndw();
}

private function isModeratorFolder(xml:XML):Boolean{
	var isModerator:Boolean;
	if (xml.attribute("type") == "classes" || xml.attribute("type") == "institutes" || xml.attribute("type") == "courses"){
		if (xml.attribute("is_moderator") == "Y")
			isModerator=true;
		else if (xml.attribute("is_moderator") == "N")
			isModerator=false;
	}
	else{
		fileManager.setCommonDeleteBtn(true);
		var parent:XML=XML(xml).parent();
		isModerator=isModeratorFolder(parent)
	}
	return isModerator;
}
private var fileExtention:String=""; //Uploaded file extension
public var remoteFilePath:String=""; //Complete path, includes folder path and file name
public var fileRoot:String="";
public var remoteFilePathDown:String="";
public var remoteFileNameDown:String="";
public var folderPath:String="";
// CRASH: API
//private var fileManager:FileManager=null;
public var fileManager = null;

[Bindable]
public var remoteFileName:String;
[Bindable]
public var currentFileName : String;
public var event_1:ContentOperationEvent;
[Bindable]
public var tempRemoteFilename:String;
[Bindable]
[Bindable]
public var isRefresh:Boolean=false;
public var tempRemoteFilepath:String;
private var thumbPath:String; //Path of the tumbnail folder
private var logFileName:String;

/**
 * for removing all PopUp Windows
 *
 */
public function removeAllPopUpWndw():void{
	applicationType::DesktopWeb{
		var childList:IChildList=FlexGlobals.topLevelApplication.systemManager.popUpChildren;
		
		for (var i:int=childList.numChildren - 1; i > 0; i--){
			var child:IFlexDisplayObject=childList.getChildAt(i) as IFlexDisplayObject;
			PopUpManager.removePopUp(child);
			
		}
		if(isPopOut)
		{
			if(fileManager&&fileManager.upload)
			{
				PopUpManager.removePopUp(fileManager.upload);
				fileManager.upload=null;
			}
		}
			PopUpManager.removePopUp(fileManager)
			fileManager=null;
	}
	applicationType::mobile{
		if(fileManager){
			fileManager.close();
		}
		fileManager = null;
	}
}

/**
 * For to check whether the file is Powerpoint file or not
 * @param fileExt of String
 *
 */
private function isISpringFile(fileExt:String):Boolean{
	//Fix for issue #19679
	applicationType::web{
		fileExtention=fileExtention.replace(".","").toLowerCase();
	}
	if (fileExtention == "ppt" || fileExtention == "pptx" || fileExtention == "pptm" || fileExtention == "pps")	{
		return true;
	}
	return false;
}

/**
 * remoteFilePath: It has the complete folder path including the file name at the end
 * Ex:remoteFilePath=convertedfiles/ramesh_t/Folder1/Folder2/File1.ext
 * returns convertedfiles/ramesh_t/Folder1/Folder2/Thumbnails/File1.ext_files
 */
private function getThumbFolder(filePath:String):String{
	var thumbFolder:String="";
	
	var lastSlashIdx:int=filePath.lastIndexOf("/");
	if (lastSlashIdx != 0)
		thumbFolder=filePath.substr(0, lastSlashIdx + 1) + THUMB_FOLDER + "/" + remoteFileName + "_files";
	return thumbFolder;
}

/**
 * remoteFilePath: It has the complete folder path including the file name at the end
 * Ex:remoteFilePath=convertedfiles/ramesh_t/Folder1/Folder2/File1.ext
 * returns convertedfiles/ramesh_t/Folder1/Folder2/_sfp__File1.ext
 */
private function getSFPFolder(filePath:String):String{
	var sfpFolder:String="";	
	var lastSlashIdx:int=filePath.lastIndexOf("/");
	if (lastSlashIdx != 0)
	{
		sfpFolder=filePath.substr(0, lastSlashIdx + 1) + SFP_FOLDER_PREFIX + filePath.substr(lastSlashIdx + 1, filePath.length);
	}
	return sfpFolder;
}

/**
 * Common function for removing a component from parent
 */
private function removeComponent(obj:*, objForRemove:*):Boolean{
	if (obj.contains(objForRemove)){		
		obj.removeElement(objForRemove)
		return true;
	}
	return false;
}

/**
 * Common function for Addiing a component to parent component
 */
private function addComponent(obj:*, objForAdd:*):Boolean{
	if (!obj.contains(objForAdd)){
		obj.addElement(objForAdd)
		return true;
	}
	return false;
}

/**
 * for handling the control button accessible
 * Scrolling and Zooming not allowed  in ispring files
 */
private function controlButtonsIsEnable(bool:Boolean):void{
	applicationType::DesktopWeb{
		rotateBtn.includeInLayout=bool;
		zoomInBtn.includeInLayout=bool;
		zoomOutBtn.includeInLayout=bool;
		initialZoomBtn.includeInLayout=bool;
		initialZoomBtn.visible=bool;
		rotateBtn.visible=bool;
		zoomInBtn.visible=bool;
		zoomOutBtn.visible=bool;
	}
}

//RGCR: Improper variable name. Variable name should indicate the index. Variable should not be a member variable. It can be a local variable..
private var folderPrefix:int;
private var uicompX:Number=0;
private var uicompY:Number=0;
private var uicompWidth:Number=0;
private var uicompHeight:Number=0;
[Bindable]
private static var permissionStatus:String="";
private var isPrevPPTFile:Boolean = false;
/**
 * For handling the process loading the documnets into Documnet container
 * after local caching .
 * @param filePath of string
 * @param fileExt of String
 * @param fileName of String
 */

private function loadFileToCache(filePath:String, fileExt:String, fileName:String):void{
	applicationType::mobile{
		navigationControl.visible = true;
	}
	ipAddress=ClassroomContext.CONTENT_DOCUMENT;
	//setUpload=true;
	if (fileExt == "")
		return;
	remoteFilePathDown=getDownloadableRemotePath(filePath);
	remoteFileNameDown=fileName;
  	isProgressBarPresent=false;
	isResized=true;
	docUnloaded=false;
	isLatecomming=false;
	isPageLoaded=false;
	//trace("LOadDocumentBool"+isLoadDoc)
	var animation:String="No Animations";
	var fileSize:String=null;
	currentFileName=fileName;
	unloadContextMenuData();
	zoomFactorX=1;
	zoomFactorY=1;
	trace("Load to file cash ZoomX");
	//removeAnnotations();
	//pointerShape=null;
	isNeedRemoveAnnotation=true;
	removeAnnotationTools();
	if(isVThumb||isHThumb){
	hideThumbNail();
	}
	if (isAnnotationToolRmoved){
		removeAnnotation();
		isAnnotationToolRmoved=false
	}
	if (userRole == Constants.VIEWER_ROLE){
		applicationType::DesktopWeb{
			
				permissionMsgStudent.visible=true;
				if (isDownloadPermission == false){
				permissionMsgStudent.toolTip=PERMISSION_DENY_STATUS_MSG;
				permissionStatus=PERMISSION_DENY_STATUS_MSG;
		}
			
		}
		
	}
	else{
		totalPages=new Number();
		applicationType::DesktopWeb{
			if (entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
				entPage.removeEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
		}
		applicationType::mobile{
			//Changed logic to navigate the page.
			if(informationCallout.txtEnterPage != null && informationCallout.txtEnterPage.hasEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE))
			{
				informationCallout.txtEnterPage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,pageChanged);
			}
		}
		currentPage=1;
		previousPage = 1;
		clearServer();
	}
	controlButtonsIsEnable(false);
	folderPrefix=filePath.search("_sfp__");
	applicationType::DesktopWeb{
		fileNameStudent.visible=true;
	}
	removeProgressBar()
	if (pptLoaded){
		removeIspringEventListners();
		removeUIComp(uiComp, uiComp);
		isPrevPPTFile = true;
	}
	else{
		applicationType::web{
			//To avoid the issue "The supplied DisplayObject must be a child of the caller", we changed p2fContainer to uiComp.
			removeUIComp(uiComp, uiComp);
		}
		applicationType::DesktopMobile{
			removeUIComp(p2fContainer, p2fContainer);
		}
	}
	if (mousePointerShare == mousePointerDisable){
		mousePointerShare=mousePointerEnable
		mousePointerShared=false;
	}
	pointerShape=null;
	thumbPath=getThumbFolder(filePath);
	if (userRole == Constants.PRESENTER_ROLE){
		applicationType::DesktopWeb{
			btnImgDownload.enabled=true;
			btnImgUnload.enabled=true;
			chkBoxPermission.enabled=true;
			chkBoxPermission.selected=false;
		}
		buttonEnabling(true);
		setTimeout(buttonEnabling,1000,false);
		/*nextBtn.enabled=true;
		prevBtn.enabled=true;*/
		permissionStatus=PERMISSION_DENY_STATUS_MSG;
		documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: DENY_PERMISSION});
		if (Log.isDebug()) log.debug("loadFileToCache: downloadPermission is called. permission:" + DENY_PERMISSION);
	}
	applicationType::DesktopWeb{
		if (isISpringFile(fileExt) && folderPrefix == -1){
			iSpringContainer.addEventListener(PlayerInitEvent.PLAYER_INIT, initializeISpringPlayer);
			iSpringContainer.x=0
			iSpringContainer.y=0
			animation="Animations";
			loadingLabel.visible=false;
			//permissionMsgStudent.visible=true;
			//permissionMsg.visible=true;
			var obj:Object=getResolutionProperties(iSpringCanvas,iSpringWidth)
			setLoaderProperties(obj);
			controlStack.enabled=true;
			if (removeComponent(containerStack, p2fCanvas)){
				addComponent(containerStack, iSpringCanvas);
				containerStack.selectedChild=iSpringCanvas;
				addComponent(containerStack, fileLoad);
				containerStack.selectedChild=fileLoad;
				loadingLabel.visible=true;
				loadingLabel.text="Document is processing...Please wait...";
				
			}
			pptLoaded=true;
			loadedFileURL=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + filePath);
			//fileDownloaderObj.download(encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/DownloadFilelist.php?directory=" + filePath), currentPage, totalPages);
			iSpringContainer.unload();
			iSpringContainer.visible=true;
			iSpringContainer.load(loadedFileURL);
			//previousRemoteFilePath=filePath;
			uicompX=iSpringContainer.x;
			uicompY=iSpringContainer.y;
			infoBarWidth=iSpringWidth;
			if (Log.isDebug()) log.debug("loadFileToCache:Ispring container values X:" + uicompX +",Y:"+ uicompY +"and ISpring width is:"+infoBarWidth+"iSpringContainer Width:"+iSpringContainer.width+"iSpringContainer Height"+iSpringContainer.height+"Ispring width:"+iSpringWidth+"IspringHeight:"+iSpringHeight+"RemoteFileName:"+remoteFileName);
			//trace("unload: iSpringContainer Width:"+iSpringContainer.width+"iSpringContainer Height"+iSpringContainer.height+"iSpringContainer Height"+iSpringContainer.height+"Ispring width:"+iSpringWidth+"IspringHeight:"+iSpringHeight);  
		}
		else{
			isLoadDoc=true;
			controlStack.enabled=false;
			iSpringContainer.unload();
			removeComponent(containerStack, iSpringCanvas);
			addComponent(containerStack, p2fCanvas);
			containerStack.selectedChild=p2fCanvas;
			addComponent(containerStack, fileLoad);										
			containerStack.selectedChild=fileLoad;
			loadingLabel.visible=true;
			controlButtonsIsEnable(true);
			infoBarWidth=p2fWidth;
			fileNameWidth=p2fWidth;
			pptLoaded=false;	
			loadingLabel.text="Document is processing...Please wait...";
			loadedFileURL=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + filePath);
			fileDownloaderObj.download(encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/DownloadFilelist.php?directory=" + filePath), currentPage, totalPages);
			//visibility of print2flash container is set to false
			docCanvas.visible=true;
			p2fCanvas.visible=true;
			p2fContainer.visible=true;
			controlStack.enabled=true;
			uicompX=p2fContainer.x;
			uicompY=p2fContainer.y;
			if (Log.isDebug()) log.debug("unload: P2fCondainer Width:"+p2fContainer.width+"p2fContainer Height"+p2fContainer.height+"p2fContainer width:"+p2fWidth+"p2fHeight:"+p2fHeight);
			//trace("unload: p2fContainer Width:"+p2fContainer.width+"p2fContainer Height"+p2fContainer.height+"p2fContainer.X"+p2fContainer.x+"p2fContainer.Y:"+p2fContainer.y+"p2fWidth width:"+p2fWidth+"p2fHeight:"+p2fHeight+"containerStack WIdth:"+containerStack.width+"containerStackHeight:"+containerStack.height+"containerStack.X:"+containerStack.x+"containerStack.Y"+containerStack.y+"P2fCanvas.x"+p2fCanvas.x+"p2fCanvas.y"+p2fCanvas.y+"p2fCanvasWidth"+p2fCanvas.width+"p2fCanvasHeight"+p2fCanvas.height);
			//+"P2fCanvas.x"+p2fCanvas.x+"p2fCanvas.y"+p2fCanvas.y+"p2fCanvasWidth"+p2fCanvas.width+"p2fCanvasHeight"+p2fCanvas.height
		}
		if (userRole == Constants.VIEWER_ROLE){
			//if(penSelected||highlighterSelected){
//				applicationType::DesktopWeb{
					//if(penSelected) annottool('Pen');
					//else if(highlighterSelected)
					//annottool('Pen');
					//annotateDoc(p2fContainer);
//				}
			//}
		}
		setTimeout(setResize,4000);
		vHideBtn.visible =true;
		hHidebtn.visible =true;
		
	}
	applicationType::mobile{
		//MOBILE_ISPRING:
		/*if (isISpringFile(fileExt) && folderPrefix == -1){
			iSpringContainer.x=0;
			iSpringContainer.y=0;
			animation="Animations";
			if (removeComponent(containerStack, p2fCanvas)){
				addComponent(containerStack, iSpringContainer);
			}
			pptLoaded=true;
			iSpringPageNo = 0;
			loadedFileURL=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + filePath);
			iSpringContainer.visible=true;
			if(stageWebView == null){
				stageWebView = new StageWebViewComponent;
				stageWebView.stageWidth = iSpringContainer.width;
				stageWebView.stageHeight = iSpringContainer.height;
				stageWebView.stageX = iSpringContainer.x;
				stageWebView.stageY = iSpringContainer.y;
				iSpringContainer.addElement(stageWebView);
				stageWebView.url = encodeURI("http://" + FlexGlobals.topLevelApplication.mainApp.prepareLogin.ISPRING_SERVER + ":" + ClassroomContext.portWAMP + "/webISpring");//"http://192.168.173.112:80/webISpring";
				stageWebView.x = iSpringContainer.x;
				stageWebView.y = iSpringContainer.y;
			}else{
				if(iSpringContainer.width == 0 || iSpringContainer.width < 0 ){
					stageWebView.stageWidth = this.width;
					stageWebView.stageHeight = this.height;
				}else{
					stageWebView.stageWidth = this.width;
					stageWebView.stageHeight = this.height;
				}
				stageWebView.stageX = iSpringContainer.x;
				stageWebView.stageY = iSpringContainer.y;
				stageWebView.x = (this.width - iSpringContainer.width)/2;
				stageWebView.y = iSpringContainer.y;
			}
			trace("arguments : "+loadedFileURL);
			stageWebViewX = iSpringContainer.x;
			stageWebViewY = iSpringContainer.y;
			stageWebViewWidth = iSpringContainer.width;
			stageWebViewHeight = iSpringContainer.height;
			setTimeout(sendParamsToWeb,1000);
			
			previousRemoteFilePath=filePath;
			uicompX=iSpringContainer.x;
			uicompY=iSpringContainer.y;
			infoBarWidth=iSpringWidth;
			
		}
		else{*/
			toolWidth=p2fWidth;
			controlButtonsIsEnable(true);											
			pptLoaded=false;
			//trace("Downloading started...");					
			loadedFileURL=encodeURI("http://" + ipAddress+":"+ClassroomContext.portWAMP +filePath);								
			fileDownloaderObj.download(encodeURI("http://"+ipAddress+":"+ClassroomContext.portWAMP+"/AVScript/Upload/DownloadFilelist.php?directory="+filePath),currentPage,totalPages);
			//flag for identifying the network connection is initialized is set to true(true: means initialized)
			onetimeConnect=true;
			//visibility of print2flash container is set to false
			docCanvas.visible=true;
			p2fCanvas.visible=true;
			p2fContainer.visible=true;
			uicompX=p2fContainer.x;
			uicompY=p2fContainer.y;
		//}
	}
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			//RGCR: When this situation would come? Why can't we use isISpringFile(fileExt) check?
			if (pptLoaded && folderPrefix == -1){
				var tempFilePath:String=filePath
				tempFilePath=tempFilePath.substr(tempFilePath.search("/") + 1);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addDocLoadedTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), tempFilePath, "ispring", remoteFileName);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addSizeTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(),maxX, maxY, p2fWidth, p2fHeight, 1, 1,scrollPositionX, scrollPositionY);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addPageEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), 1);
			}
		}
	}
	//trace("LoadFile To cash Called");
	//isPresnter=false;
}
applicationType::mobile{
	private var stageWebViewX:int;
	private var stageWebViewY:int;
	private var stageWebViewWidth:int;
	private var stageWebViewHeight:int;
	private var isStageWebViewInitiated:Boolean = false;
	private var isStageWebViewCompleted:Boolean = false;
	private var iSpringPageNo:int = 0;
	//MOBILE_ISPRING:
	/*private function sendParamsToWeb():void{
		if(FlexGlobals.topLevelApplication.slider.isShowing){
			//FlexGlobals.topLevelApplication.slider.animate(false);
		}
		var arguments:String;
		if(stageWebView != null && stageWebView.stageWebView != null){
			if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
				stageWebView.resizeStageWebView(this.x, FlexGlobals.topLevelApplication.actionBar.height, this.width, this.height);
				arguments = loadedFileURL+","+iSpringPageNo+"," +FlexGlobals.topLevelApplication.actionBar.height+","+this.width+","+this.height;
			}else{
				
				var x:int = (this.width - iSpringContainer.width)/2;
					stageWebView.resizeStageWebView(x, 
						(FlexGlobals.topLevelApplication.collaborationBtnsHeight+FlexGlobals.topLevelApplication.actionBar.height), 
						this.width, 
						this.height);
			 	arguments = loadedFileURL+","+iSpringPageNo+"," +(FlexGlobals.topLevelApplication.collaborationBtnsHeight+FlexGlobals.topLevelApplication.actionBar.height)+","+this.width+","+this.height;
				
			}
			stageWebView.stageWebView.loadURL('javascript:dummyFunction("'+arguments+'");');
			iSpringArguments = arguments;
		}
	}
	public function hideStageWebView():void{
		if(stageWebView != null){
			stageWebView.resizeStageWebView(-10,-10,10,10);
		}
		isStageWebViewInitiated = false;
		isStageWebViewCompleted = false;
	}
	public function showStageWebView():void{
		iSpringContainer.visible=true;
		if(stageWebView == null){
			stageWebView = new StageWebViewComponent;
			stageWebView.stageWidth = iSpringContainer.width;
			stageWebView.stageHeight = iSpringContainer.height;
			stageWebView.stageX = iSpringContainer.x;
			stageWebView.stageY = iSpringContainer.y;
			iSpringContainer.addElement(stageWebView);
			stageWebView.url = encodeURI("http://" + FlexGlobals.topLevelApplication.mainApp.prepareLogin.ISPRING_SERVER + ":" + ClassroomContext.portWAMP + "/webISpring");
			stageWebView.x = iSpringContainer.x;
			stageWebView.y = iSpringContainer.y;
		}else{
			stageWebView.stageWidth = iSpringContainer.width;
			stageWebView.stageHeight = iSpringContainer.height;
			stageWebView.stageX = iSpringContainer.x;
			stageWebView.stageY = iSpringContainer.y;
		}
		setTimeout(sendParamsToWeb,500)
	}
	private var iSpringArguments:String = "";
	public function stageWebViewIntiated(msgFromStageView:*):void{
		trace(msgFromStageView);
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
			stageWebViewX = iSpringPageNo;
			stageWebViewY = FlexGlobals.topLevelApplication.actionBar.height;
			stageWebViewWidth = this.width;
			stageWebViewHeight = this.height;
		}else{
			var x:int = (this.width - iSpringContainer.width)/2;
			stageWebViewX = iSpringPageNo;
			stageWebViewY = (FlexGlobals.topLevelApplication.collaborationBtnsHeight+FlexGlobals.topLevelApplication.actionBar.height);
			stageWebViewWidth = iSpringContainer.width;
			stageWebViewHeight = iSpringContainer.height;
		}
		if(msgFromStageView == "Intiated" && !isStageWebViewInitiated){
			isStageWebViewInitiated = true;
		}
		if(msgFromStageView == "Completed" && !isStageWebViewCompleted){
			setTimeout(sendParamsToWeb,100);
			isStageWebViewCompleted = true;
		}
	}*/
}
private function setResize(){
	isResized=false;
}
/**
 * For getting the file extension of current file
 * @param  fileNamePath od String
 */
private function getFileExtension(fileNamePath:String):String{
	//File is double clicked
	var fileExt:String="";
	var dotIndex:int=fileNamePath.lastIndexOf(".");
	if (dotIndex != -1)
		fileExt=fileNamePath.substr(dotIndex + 1, fileNamePath.length); //+1 is to skip the dot	
	return fileExt;
}

/**
 *This will triger whne the user send the request for
 * documnet download
 * @param downloadRequestedEvent of  DownloadRequestedEvent
 */
private function onDownloadRequest(event : Object):void{
	var downloadRequestedEvent = event as DownloadRequestedEvent;
	removeAllPopUpWndw();
	recordedRemoteFilePath="";
	if (downloadRequestedEvent.downloadType == "ToLocal")
		downloadDocumentToLocal(downloadRequestedEvent.remoteFileName, downloadRequestedEvent.remotePath);
		if(Log.isDebug()) log.debug("onDownloadRequest:remote file name:"+downloadRequestedEvent.remoteFileName+",remote file path"+downloadRequestedEvent.remotePath);
	else{
		remoteFileName=downloadRequestedEvent.remoteFileName;
		remoteFilePath=downloadRequestedEvent.remotePath;
		//trace("Remote fiel Path"+remoteFilePath);
		fileExtention=getFileExtension(remoteFileName);
		//Download the file only if the previously loaded file path is not same as current path
		if (previousRemoteFilePath != remoteFilePath && downloadRequestedEvent.downloadType == "ToAview" && userRole == Constants.PRESENTER_ROLE)
			loadFileToCache(remoteFilePath, fileExtention, remoteFileName);
		else if (remoteFileName != null)
		alert=MessageBox.show("'" + remoteFileName + "'" + " has been loaded..", "Info", MessageBox.MB_OK, this.parent as Sprite)
			
	}
		

}

/**
 * This will triger while the file upload complete
 * @param uploadCompletedEvent of UploadCompletedEvent
 */
/*private function onUploadComplete(event: Object):void{
	var uploadCompletedEvent = event as UploadCompletedEvent;
	if (userRole == Constants.PRESENTER_ROLE){
		var animated:String="No Animations";
		fileExtention=uploadCompletedEvent.fileExtension;
		var str1:String=uploadCompletedEvent.remotePath;
		remoteFileName=uploadCompletedEvent.fileName;
		var results:Array=str1.split(remoteFileName);
		fileExtention=uploadCompletedEvent.fileExtension;
		if (isISpringFile(fileExtention) && uploadCompletedEvent.animated){
			animated="Animations"
			remoteFilePath=results[0] + remoteFileName + ".swf";
		}
		else
			remoteFilePath=getSFPFolder(results[0] + remoteFileName);
		removeAllPopUpWndw();
		loadFileToCache(remoteFilePath, fileExtention, remoteFileName);
		documentUploadEventLog(remoteFilePath, animated);
		
	}

}*/

/**
 *
 * @private
 * Audits the "DocumentUpload" action, when the presenter uploads document to library
 *
 * @param url of the document
 * @param animated - Whether the document contains animations
 * @return void
 *
 */
private function documentUploadEventLog(url:String, animated:String):void
{
	AuditContext.userAction.createAction(AuditConstants.documentUpload, url, animated, null);
}

/**
 * function for handling the local download error
 */
public function localDownloadErrorHandler():void{
	
	alert=MessageBox.show("Unable to access file or page  may have network problem", "Warning", MessageBox.MB_OK, this.parent as Sprite);
}

/**
 * For handling the file loading to Container after local downloading
 * @param localPath of String
 * @param msg of String
 * @param startRange of Number
 * @param endRange of Number
 * @param preferedPage of Number
 * @param totalNoOfPages of int
 * @param isNewFile of Boolean
 * @param isSucess of Boolean
 */
public function showSFPDocument(localPath:String, msg:String, startRange:Number, endRange:Number, preferedPage:Number, totalNoOfPages:int, isNewFile:Boolean, isSucess:Boolean):void
{
	applicationType::web{	
		docCanvas.horizontalScrollPosition=0;
		docCanvas.verticalScrollPosition=0;
	}
	applicationType::DesktopWeb{
	docScroller.verticalScrollBar.value = 0;
	docScroller.horizontalScrollBar.value = 0;
	}
	if (isSucess){
		if (isNewFile){
			isNewfile=true;
			isInvalidePage=false;
			
			applicationType::DesktopWeb{
				if (removeComponent(containerStack, iSpringCanvas)){
					addComponent(containerStack, p2fCanvas);
					containerStack.selectedChild=p2fCanvas;
				}
				else
				  containerStack.selectedChild=p2fCanvas;
				  var obj:Object=getResolutionProperties(p2fCanvas,p2fWidth)
				  setLoaderProperties(obj);
			}
			//MOBILE_ISPRING:
			/*applicationType::mobile{
				if(iSpringContainer.visible){
					hideStageWebView();
					removeComponent(containerStack, iSpringContainer)
					addComponent(containerStack, p2fCanvas);
				}
				isStageWebViewCompleted = false;
				isStageWebViewInitiated = false;
			}*/
			docCanvas.visible=true;
			p2fContainer.visible=true;
			totalPages=totalNoOfPages;
			localSFPFilePath=localPath;
			initilizeThumbNailData();
			if (userRole == Constants.PRESENTER_ROLE){
				applicationType::DesktopWeb{
					entPage.enabled=true;
					permissionMsg.visible=true;
				
						
				}
				applicationType::mobile{
					docCanvas.horizontalScrollPosition = 0;
					docCanvas.verticalScrollPosition = 0;
				}
				if (localSFPFilePath == "")
					alert=MessageBox.show("Please choose a document to open/download", "INFO", MessageBox.MB_OK, this.parent as Sprite);
				else{
					
					////////////////////////////////////////////////////////////////////////////////
					//TEACHER_OPEN_FILE_FOLDER #2
					//opening a file
					//if selected remote file name is not null, then calling the getResolution() function
					//in getResolution function sets the width and height of print2flash container
					//setting print2flash container visibility to false
					//setting path of the file by attaching teacher name(userType) and selected file path(newPPT) to loadPPT(a string variable)
					//displaying the file name in a label (fileNameTeacher)
					//flag for identifying the network connection is initialized is set(onetimeConnect) to true(true:means initialized)
					//setting prin2flash container source as loadPPT(full path of selected file)
					//textInput to enter page number(entPage) is set to page number 1
					//the selected remote file path(newPPT) is stored in a temperory variable tempNewPPT     
					//--START-------------------------------------------------------
					if (localSFPFilePath != ""){
						rotationDegree=0;
						rotateDoc(0, p2fWidth, p2fHeight, zoomFactorX);
						applicationType::web{
							//To avoid the issue "The supplied DisplayObject must be a child of the caller", we changed p2fContainer to uiComp.
							removeUIComp(uiComp, uiComp);
						}
						applicationType::DesktopMobile{
							removeUIComp(p2fContainer, p2fContainer);
						}
						if (mousePointerShare == mousePointerDisable){
							mousePointerShare=mousePointerEnable
							//chkEnableMousePointer.selected = false;
							mousePointerShared=false;
						}						
						animatedFile=false;
						applicationType::desktop{
							documentViewEventLog(remoteFilePath, animatedFile, totalPages);
						}
						if(!isRefresh){
						//added for red5
						documentCollaborationObject.setValue(DELETEDOCUMENT,false);	
						
						documentCollaborationObject.setValue(DOCZOOM, "");
						documentCollaborationObject.setValue(NEWFILE, {path:getDownloadableRemotePath(remoteFilePath), fileName: remoteFileName, fileExtention: fileExtention, totalPages: totalNoOfPages, thumbPath: thumbPath, p2fHeightTeacher: p2fHeight, p2fWidthTeacher: p2fWidth, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, X: xValue, Y: yValue, MaxX: maxX, MaxY: maxY, animated: animatedFile, isPageLoaded: false})
						documentCollaborationObject.setValue(PAGECHANGE, {pageNo: currentPage, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, p2fWidthTeacher: p2fWidth})
						if (Log.isDebug()) log.debug("showSFPDocument: loadNewFile is called. path:" + remoteFilePath + ", fileName:" + remoteFileName + ", fileExtention:" + fileExtention + ", thumbPath:" + thumbPath + ", p2fHeightTeacher:" + p2fHeight + ", p2fWidthTeacher:" + p2fWidth + ", teacherZoomFactorX:" + zoomFactorX + ", teacherZoomFactorY:" + zoomFactorY + ", X:" + xValue + ", Y:" + yValue + ", MaxX:" + maxX + ", MaxY:" + maxY + ", animated:" + animatedFile);
						if (Log.isDebug()) log.debug("unload: P2fCondainer Width:"+p2fContainer.width+"p2fContainer Height"+p2fContainer.height+"p2fContainer width:"+p2fWidth+"p2fHeight:"+p2fHeight);
						//trace("Showsfp: p2fContainer Width:"+p2fContainer.width+"p2fContainer Height"+p2fContainer.height+"p2fContainer width:"+p2fWidth+"p2fHeight:"+p2fHeight);
						}
						applicationType::DesktopWeb{
							if (!entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
								entPage.addEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
						}
						applicationType::mobile{
							if(informationCallout.txtEnterPage != null && !informationCallout.txtEnterPage.hasEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE))
								informationCallout.txtEnterPage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,pageChanged);
						}
						
					}
				}
				
			}
			else{
				applicationType::DesktopWeb{
					//setTimeout(showSFPDocument,100,localPath, msg, startRange, endRange, preferedPage, totalNoOfPages, isNewFile, isSucess);
					permissionMsgStudent.visible=true;
					//trace("ShowSFP");
					if(documentCollaborationObject.getData() != null && documentCollaborationObject.getData()[DOCZOOM] != "")
					{
						teacherZoomFactorX =documentCollaborationObject.getData()[DOCZOOM].zoomFactorX;
						teacherZoomFactorY = documentCollaborationObject.getData()[DOCZOOM].zoomFactorY;	
						p2fWidthTeacher = parseFloat(documentCollaborationObject.getData()[DOCZOOM].p2fWidthTeacher);
						p2fHeightTeacher = parseFloat(documentCollaborationObject.getData()[DOCZOOM].p2fHeightTeacher);
						//setTimeout(scaleDocument,500,teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fHeight,p2fWidthTeacher,p2fHeightTeacher);
						scaleDocument(teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fHeight,p2fWidthTeacher,p2fHeightTeacher);
						
						
					}
					/*
					if(!isLatecomming){
						scaleDocument(teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fHeight,p2fWidthTeacher,p2fHeightTeacher);
					}
					else
					{
						setTimeout(scaleDocument,500,teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fHeight,p2fWidthTeacher,p2fHeightTeacher);
					}	*/
					/*if(!isLatecomming){
						setTimeout(scaleDocument,500,teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fHeight,p2fWidthTeacher,p2fHeightTeacher);
					}*/
					
				}
			}
			previousRemoteFilePath=remoteFilePath;
			//previousRemoteFilePath=remoteFilePath+"/"+SFP_FOLDER_PREFIX+remoteFileName;
		}
		addEventListenersToP2F();
		applicationType::web{
			//Instead of SWFLoader we use Loader to load the P2F document to avoid Security Sandbox violation error
			var request:URLRequest=new URLRequest(localPath + "page_" + preferedPage + ".swf");
			p2fLoaderObj.load(request);
			//Added this logic to solve pointer missing issue at viewer side when presenter navigates the document
			if (p2fContainer.numChildren > 0){
				p2fContainer.removeChildren(0, p2fContainer.numChildren - 1);
				if (uiComp)
					uiComp=null;
			}
			p2fContainer.addChild(p2fLoaderObj);
		}
		applicationType::DesktopMobile{
			
			p2fContainer.load(localPath + "page_" + preferedPage + ".swf");
		}
		applicationType::mobile{
			if(userRole == Constants.VIEWER_ROLE)
			{
				if(documentCollaborationObject.getData() != null && documentCollaborationObject.getData()[DOCZOOM] != "")
				{
					teacherZoomFactorX =documentCollaborationObject.getData()[DOCZOOM].zoomFactorX;
					teacherZoomFactorY = documentCollaborationObject.getData()[DOCZOOM].zoomFactorY;	
					p2fWidthTeacher = parseFloat(documentCollaborationObject.getData()[DOCZOOM].p2fWidthTeacher);
					p2fHeightTeacher = parseFloat(documentCollaborationObject.getData()[DOCZOOM].p2fHeightTeacher);
					scaleDocument(teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fHeight,p2fWidthTeacher,p2fHeightTeacher);
					
					
				}
				if(isNewFile)
				{
					if(scrollDirction == "vertical")
					{
						docCanvas.verticalScrollPosition = scrollPosition;
					}
					else if(scrollDirction == "horizontal")
					{
						docCanvas.horizontalScrollPosition = scrollPosition;
					}
				}
				else
				{
					docScroller.verticalScrollBar.value = 0;
					docScroller.horizontalScrollBar.value = 0;
				}
				docCanvas.verticalScrollPosition = 0;
				docCanvas.horizontalScrollPosition = 0;
			}
			//To set visibilty of document border
			documentBorder.visible = true;
			if(userRole == Constants.VIEWER_ROLE)
			{
				//currentPag.visible = true;
			}
			else
			{
				navigationControl.visible = true
			}
			//Enable document info and Menu button, when presenter loads document.
			if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				FlexGlobals.topLevelApplication.docTool.btnPresenterDocumentDetails.enabled = true;
				FlexGlobals.topLevelApplication.docTool.btnPresenterMenu.enabled = true;
			}
			else
			{
				FlexGlobals.topLevelApplication.docTool.btnViewerDocumentDetails.enabled = true;
				//FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled = true;
			}
		}
		//clickThum=false;
		//trace("Show sfp document called");
		setTimeout(resetControl,1000);
		
	}
	else {
		var contentService:ContentService=new ContentService();
		var originalFilePath:String="";
		var lastIdx:int=remoteFilePath.lastIndexOf("/", remoteFilePath.length);
		if (lastIdx != -1){
			originalFilePath=remoteFilePath.substr(0, lastIdx);
			var filePath:String=originalFilePath + "/@@-OriginalDocs-@@/" + remoteFileName;
			contentService.deleteFile(filePath, deleteOriginalFileResult, faultHandler);
		}
	}
	
}
private function resetControl():void{
	//trace("Reset Control Called");
	isPresnter=false;
}

/**
 *
 * @private
 * Audits the "DocumentView" action, when the viewer starts viewing the uploaded document
 *
 * @param url of the document
 * @param animated - Whether the document contains animations (ppt)
 * @param totalPages - Total number of pages in the document
 * @return void
 *
 */
private function documentViewEventLog(url:String, animated:Boolean, totalPages:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentView, url, (animated) ? "Yes" : "No", totalPages + "");
}

/**
 * event listener for identifying the content loading is complete
 * @param event of Event
 */
private function bytesDownloaded(event:Event):void{	
	if (p2fContainer.source == "" || tempPath == null) { //sanity check
	}
	else if (percentLoaded != 100) //A valid source document
		showDownloadErrorMessage("There was an error while downloading the document.");		
	else	{
		if (isNewfile){
			applicationType::web{
				//p2fContainer.contentWidth is always null.
				normalWidth=p2fLoaderObj.contentLoaderInfo.width;
				//Stores the height of document loader
				normalHeight=p2fLoaderObj.contentLoaderInfo.height;
			}
			applicationType::DesktopMobile{
				normalWidth=p2fContainer.contentWidth
			}
		}
		if (userRole == Constants.PRESENTER_ROLE){
			if (isNewfile){
				applicationType::web{
					//p2fContainer.contentWidth and contentHeight are always null. So we changed the logic
					
					scaleDocument(zoomFactorX, zoomFactorY, p2fWidth - 30, p2fHeight - 5, normalWidth, normalHeight);
				}
				applicationType::DesktopMobile{
					trace("BytesDownload called zoomFactorX----"+zoomFactorX);
					scaleDocument(zoomFactorX, zoomFactorY, p2fWidth - 45, p2fHeight, p2fContainer.contentWidth, p2fContainer.contentHeight);
				}
				contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
				if (this)
					this.addEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
			}
		}
		else{
			//RTCR: If we remove isNewFile check we can combine below if(isDownloadPermission) condition block of codes.
			applicationType::web{
				//To avoid the issue-'document is blank at user side after doing hide panel'
				var obj:Object=getResolutionProperties(p2fCanvas,p2fWidth)
				setLoaderProperties(obj);
				scaleDocument(teacherZoomFactorX, teacherZoomFactorY, p2fWidth, p2fHeight, p2fWidthTeacher, p2fHeightTeacher)
				if (isDownloadPermission){
					//For Guest Login: Restrict Control over loaded documents(Download to local disk, access to public documents etc) for guest user
					if (ClassroomContext.userVO.role != Strings.GUEST_TYPE){
						setPermissionGrantStatus();
					}
				}
			}
			applicationType::DesktopMobile{
				if (isNewfile){
					trace("BytesDownload called zoomFactorX----"+zoomFactorX);
					scaleDocument(teacherZoomFactorX, teacherZoomFactorY, p2fWidth, p2fHeight, p2fWidthTeacher, p2fHeightTeacher)
					if (isDownloadPermission){
						setPermissionGrantStatus();
					}
				}
			}
			if (presenterMousePointer){
				if (pointerShape){
					pointerShape.x=pointerX;
					pointerShape.y=pointerY;
				}
				else showPointer(p2fContainer, p2fWidth, p2fHeight, p2fContainer);
			}
		}
		
		
		if (penSelected || highlighterSelected){
			if (userRole == Constants.PRESENTER_ROLE)
				setTimeout(annotateDoc, 100, p2fContainer);
			else
				annotateDoc(p2fContainer);
		}		
		else if (pointerShape){
			applicationType::web{
				//Added this logic to avoid pointer missing issue at user side when Presenter navigates the page.
				if (uiComp == null)	{
					pointerScaleHandler(p2fLoaderObj.contentLoaderInfo.width,p2fLoaderObj.contentLoaderInfo.height);
					//Added this logic to show the pointer after loading new page.
					showPointerTimeOutID=setTimeout(showPointer, 100, uiComp, normalWidth, normalHeight, uiComp);
				}
			}
			applicationType::DesktopMobile{
				p2fContainer.setChildIndex(pointerShape, p2fContainer.numChildren - 1);
			}
		}		
		isNewfile=false;
		isPageLoaded=true;
		applicationType::desktop{
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
				if (!pptLoaded && recordedRemoteFilePath != remoteFilePath)	{
					recordedRemoteFilePath=remoteFilePath;
					var tempFilePath:String=remoteFilePath;
					if(tempFilePath.slice(0,6) != "../../" && ClassroomContext.moderatorName!=ClassroomContext.currentPresenterName)
					{
						tempFilePath = "../.."+tempFilePath;
					}
					tempFilePath=tempFilePath.substr(tempFilePath.search("/") + 1);
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addDocLoadedTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), tempFilePath, "p2f", remoteFileName);
					getSizeTimeout=setTimeout(getsize, 50);
					
				}
			}
		}
	}
	//checking for event listeners are existing,
	//if existing, removing the event listeners
	applicationType::web{
		//Instead of SWFLoader we use Loader to load the P2F document		
		if (p2fLoaderObj.contentLoaderInfo.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
			p2fLoaderObj.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener);
		if (p2fLoaderObj.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR))
			p2fLoaderObj.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
		if (p2fLoaderObj.contentLoaderInfo.hasEventListener(Event.COMPLETE))
			p2fLoaderObj.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesDownloaded);
	}
	applicationType::DesktopMobile{
		if (p2fContainer.hasEventListener(HTTPStatusEvent.HTTP_STATUS))
			p2fContainer.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener);
		if (p2fContainer.hasEventListener(IOErrorEvent.IO_ERROR))
			p2fContainer.removeEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
		if (p2fContainer.hasEventListener(Event.COMPLETE))
			p2fContainer.removeEventListener(Event.COMPLETE, bytesDownloaded);
	}

}
//RTCR: Need to change the function name
private function setPermissionGrantStatus():void
{
	permissionStatus=PERMISSION_GRANT_STATUS_MSG;
	applicationType::DesktopWeb{
		permissionMsgStudent.toolTip="Right click on the document to download";
	}
	contextMenuArray=new Array(DOWNLOAD);
}
/**
 * For handling the file Conversion error
 * Then delete the original file in server
 * which is already uploaded
 * @param event of ResultEvent
 */
private function deleteOriginalFileResult(event:ResultEvent):void{
	unloadDocument();
	applicationType::DesktopWeb{
		alert=MessageBox.show("Some error in loading  the file,your file is damaged or unable to open.Please try new file.", "Warning", MessageBox.MB_OK, this.parent as Sprite);
	}
	applicationType::mobile{
		MessageBox.show("Animated file is not supported in HandHeld Devices","INFO",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
	}
}

/**
 * For hadling the fault of deleteService
 * @param event of FaultEvent(deleteService)
 */
private function faultHandler(event:FaultEvent):void{
	if (Log.isError()) log.error("DocumentSharing::DocumentHandler::faultHandler:"+ AbstractHelper.getStaticFaultMessage(event));

}

/**
 * For initilize the thumbnails for loaded document
 *
 */
/*Thumb Nail Functions do*/
private function initilizeThumbNailData():void{
	var obj:Object;
	thumbnailDataCollection=new ArrayCollection();
	for (var i:int=1; i <= totalPages; i++){
		obj=new Object()
		obj.filepath=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + thumbPath + "/thumbnail_" + i + ".jpg");
		obj.pageno=i;
		thumbnailDataCollection.addItem(obj);
	}
	applicationType::DesktopWeb{
		Hlist.thumbNailDataProvider=thumbnailDataCollection;
		vList.thumbNailDataProvider=thumbnailDataCollection;
	}
}

/**
 * For handling the fullscrren button's visbility
 * @param isVisible of Boolean
 */
private function popOutBtnVisble(isVisible:Boolean):void{
	applicationType::desktop{
		if (isVisible)
			popOutBtn.alpha=1;
		else
			popOutBtn.alpha=0;
	}
}

/**
 *  Make full screen view of documnet container
 *  DocSharing is the component has been used for this
 *  Ex:documentSharingMW=new DocSharing();
 */
public function popOutDocWindow():void{
	//focusManager.setFocus(popOutBtn);
	applicationType::desktop{
		//popOutBtn.setFocus();
		if (!isPopOut){
			documentSharingMW=new DocSharing();
			documentSharingMW.docComp=this;
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.docBox && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.docBox.contains((this)))
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.docBox.removeElement(this);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.docBox, Constants.FULLSCREEN_MSG);
			isPopOut=true;
			documentSharingMW.open(true);
			documentSharingMW.maximize()
			documentSharingMW.loginname=ClassroomContext.userVO.userName;
			documentSharingMW.presenterName=ClassroomContext.currentPresenterName;
			popOutDocumentEventLog();
			if(pptLoaded)ispringStatus=true;
		}
		else{
			documentSharingMW.close();
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unSetMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.docBox);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("add");
			}
			isPopOut=false;
			popOutBtn.setStyle("icon", popoutIcon);
			popOutBtn.toolTip="Pop-out";
			toolbarMoveHandler();
			//popOutBtn_student.setStyle("icon", popoutIcon);
			//popOutBtn_student.toolTip="Pop-out";
			//this.focusManager.setFocus(teacherRefreshBtn);
			popInDocumentEventLog();
			if(p2fContainer.content == null && !pptLoaded){
				setTimeout(documentResizeHandler,500);
			}
			if(ispringStatus){
				normalZoom();
				ispringStatus=false;
			}
		}
	}
}

/**
 *
 * @private
 * Audits the "PopInDocument" action, when the user Pops in/closes the document tab
 *
 * @return void
 *
 */
private function popInDocumentEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.popInDocument, null, null, null);
}

/**
 *
 * @private
 * Audits the "PopOutDocument" action, when the user Pops out the document tab
 *
 * @return void
 *
 */
private function popOutDocumentEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.popOutDocument, null, null, null);
}

/*iSpring related  code*/
/**
 *  Initilize the ispring palyer here for
 *  animated documents
 * @param event of PlayerInitEvent
 */
private function initializeISpringPlayer(event:PlayerInitEvent):void{
	applicationType::DesktopWeb{
		removeComponent(containerStack, fileLoad);
		containerStack.selectedChild=iSpringCanvas;
		controlStack.enabled=true;
		//entPage.enabled=true;
		if(!isPopOut) ispringStatus=false
		//permissionMsg.visible=true;
		var obj:Object=getResolutionProperties(iSpringCanvas,iSpringWidth)
		setLoaderProperties(obj);
		removeUIComp(uiComp, uiComp);
		iSpringPlayer=event.player;
		iSpringSlideInfo=event.player.presentationInfo;
		iSpringSlideControler=event.player.playbackController;
		pointerShape=null;
		totalPages=iSpringSlideInfo.slides.slidesCount;
		iSpringSlideWidth=iSpringSlideInfo.slideWidth;
		iSpringSlideHeight=iSpringSlideInfo.slideHeight;
		isNewfile=false;
		isPageLoaded=true;
		initilizeThumbNailData();
		if (userRole == Constants.PRESENTER_ROLE){
			entPage.enabled=true;
			permissionMsg.visible=true;  
			permissionStatus=PERMISSION_DENY_STATUS_MSG;
			addEventListenersToiSpring();
			contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
			totPag.visible=true;
			entPage.visible=true;
			teacherAppbar.enabled=true;
			onetimeConnect=true;
			animatedFile=true;		
			documentViewEventLog(remoteFilePath, animatedFile, totalPages);
			if(!isRefresh) documentCollaborationObject.setValue(NEWFILE, {path:getDownloadableRemotePath(remoteFilePath), fileName: remoteFileName, fileExtention: fileExtention, thumbPath: thumbPath, p2fHeightTeacher: iSpringHeight, p2fWidthTeacher: iSpringWidth, animated: animatedFile,totalPages:totalPages})
			
			if (Log.isDebug()) log.debug("initializeISpringPlayer: loadNewFile is called path:" + remoteFilePath + ", fileName:" + remoteFileName + ", fileExtention:" + fileExtention + ", thumbPath:" + thumbPath + ", p2fHeightTeacher:" + iSpringHeight + ", p2fWidthTeacher:" + iSpringWidth + ", animated:" + animatedFile);
			previousRemoteFilePath=remoteFilePath;
			currentPage=1;
			if (!entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
				entPage.addEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
		}
		else{
			permissionMsgStudent.visible=true;
			trace("initializeISpringPlayer");
			if (permissionStatus == PERMISSION_GRANT_STATUS_MSG){
				//For Guest Login: Restrict Control over loaded documents(Download to local disk, access to public documents etc) for guest user
				if (ClassroomContext.userVO.role != Strings.GUEST_TYPE)
					contextMenuArray=new Array(DOWNLOAD);
			}
			viewerSideAnimationPlay();
			setTimeout(PlayAnimtn,2500);
			if(iSpringContainer.document.loadIcon.content){
				
				if(Log.isDebug()) log.debug("iSpringContainer.document.loadIcon.content  With Content:"+iSpringContainer.document.loadIcon.content);
			}
			else if(iSpringContainer.document.loadIcon.content==null){
				refreshDocument();
				if(Log.isDebug()) log.debug("iSpringContainer.document.loadIcon.content With out Content:"+iSpringContainer.document.loadIcon.content);
			}
			if (!isLatecomming && userRole == Constants.VIEWER_ROLE){
				setAnnotationTools(toolName);
				if (toolName == "Eraser"){
					if (uiComp)
						erase();
				}
				if (uiComp && toolName != null && toolName != "Remove annotation tools")
					ispringScaleDocument(teacherZoomFactorXForAnimated, teacherZoomFactorYForAnimated, iSpringWidth, iSpringWidthTeacher, iSpringWidthTeacher);
				if (teacherMouseout){
					if (pointerShape)
						pointerShape.visible=false;
				}
				else if (presenterMousePointer)	{
					if (pointerShape){
						pointerShape.x=pointerX;
						pointerShape.y=pointerY;
					}
					else{				
						uiComp=createUIComponent(0xFFFF00,0,iSpringContainer.width, iSpringContainer.height);
						iSpringContainer.addChildAt(uiComp, 1);
						setUIcomponentDisplay(iSpringContainer.width,iSpringContainer.height);
						ispringScaleDocument(1, 1, iSpringWidth, iSpringWidthTeacher, iSpringWidthTeacher);
						showPointer(uiComp, iSpringWidthTeacher, iSpringWidthTeacher, uiComp);
					}
				}
				isLatecomming=true;
			}	
			
			isPageLoaded=true;
			if (Log.isDebug()) log.debug("initializeISpringPlayer: loadNewFile is called path:" + remoteFilePath + ", fileName:" + remoteFileName + ", fileExtention:" + fileExtention + ", thumbPath:" + thumbPath + ", p2fHeightTeacher:" + iSpringHeight + ", p2fWidthTeacher:" + iSpringWidth + ", animated:" + animatedFile);
			if (Log.isDebug()) log.debug("initializeISpringPlayer:  iSpringContainer Width:"+iSpringContainer.width+"iSpringContainer Height"+iSpringContainer.height+"iSpringWidth:"+iSpringWidth+"iSpringHeight:"+iSpringHeight+"teacherZoomFactorXForAnimated:"+teacherZoomFactorXForAnimated+"teacherZoomFactorYForAnimated:"+teacherZoomFactorYForAnimated+"teacherZoomFactorX:"+teacherZoomFactorX);
	 		//trace("IspringInitialiser: iSpringSlideWidth :"+iSpringSlideWidth+"iSpringSlideHeight:"+iSpringSlideHeight+"iSpringContainer Width:"+iSpringContainer.width+"iSpringContainer Height:"+iSpringContainer.height+"iSpringWidth:"+iSpringWidth+"iSpringHeight:"+iSpringHeight+"teacherZoomFactorXForAnimated:"+teacherZoomFactorXForAnimated+"teacherZoomFactorYForAnimated:"+teacherZoomFactorYForAnimated+"teacherZoomFactorX:"+teacherZoomFactorX);
			if(iSpringContainer.document.loadIcon.content==null||(iSpringHeight<=0&&iSpringWidth<=0)||(isNaN(teacherZoomFactorXForAnimated)||isNaN(teacherZoomFactorYForAnimated))){
				//trace("Refersh the document"); ||(isNaN(teacherZoomFactorXForAnimated)||isNaN(teacherZoomFactorYForAnimated))
				//teacherZoomFactorXForAnimated=
				if(Log.isDebug()) log.debug("Refersh the document called in Initialise ispring"+iSpringContainer.document.loadIcon.content);
				teacherZoomFactorXForAnimated=documentCollaborationObject.getData()["PageChange"].teacherZoomFactorX;
				teacherZoomFactorYForAnimated=documentCollaborationObject.getData()["PageChange"].teacherZoomFactorY;
				refreshDocument();
				if(Log.isDebug()) log.debug("initializeISpringPlayer:Refersh the document");
			}
			if(Log.isDebug()) log.debug("Zoom factor value X:"+documentCollaborationObject.getData()["PageChange"].teacherZoomFactorX+"Zoom factor Y:"+documentCollaborationObject.getData()["PageChange"].teacherZoomFactorY)
			//trace("Zoom factor value X:"+documentCollaborationObject.getData()["PageChange"].teacherZoomFactorX+"Zoom factor Y:"+documentCollaborationObject.getData()["PageChange"].teacherZoomFactorY);
		}
		/*if(!isResized) normalZoom();
		isResized=false
			
		trace("Ispring doc resized");*/
	}
}
private function PlayAnimtn(){
	viewerSideAnimationPlay();
	setTimeout(viewerSideAnimationPlay,2500);
	if(Log.isDebug()) log.debug("initializeISpringPlayer:Time out call in animation play");
	
}

/**
 * For handling the animation changes at viewer side
 */
private function viewerSideAnimationPlay():void{
	if (currentPage <= 1){
		iSpringSlideControler.gotoSlide(currentPage - 1, true);
		iSpringSlideControler.playFromStep(stepno);
		
	}
	else {//for late coming users0
		newPageLoad(currentPage);
	}
}

/**
 * Invoke while the slide  change in ispring container
 * @param event of StepPlaybackEvent
 */
private function SlideChangedEvent(event:SlidePlaybackEvent):void {
		if (isAnnotationToolRmoved)	{
			removeAnnotation();
			isAnnotationToolRmoved=false
		}
		applicationType::DesktopWeb{
			var obj:Object=getResolutionProperties(iSpringCanvas,iSpringWidth)
			setLoaderProperties(obj);
		}
		if (uiComp){
			if (penSelected || highlighterSelected)
				erase();
		}
		if (automaticSlideSwitching){
			currentPage=event.currentTarget.currentSlideIndex + 1;
			iSpringSlideControler.playFromStep(0);
			
		}
		automaticSlideSwitching=true;
		documentCollaborationObject.setValue(PAGECHANGE, {pageNo: iSpringSlideControler.currentSlideIndex + 1, teacherZoomFactorX: ispringZoomFactorX, teacherZoomFactorY: ispringZoomFactorX, p2fWidthTeacher: iSpringWidth})
		if (Log.isDebug()) log.debug("SlideChangedEvent: PageChange is called pageNo:" + (iSpringSlideControler.currentSlideIndex + 1) + ", teacherZoomFactorX:" + ispringZoomFactorX + ", teacherZoomFactorY:" + ispringZoomFactorX + ", p2fWidthTeacher:" + iSpringWidth);
}
public var stepno:Number;

/**
 * Invoke while animation  change in ispring container
 * @param event of StepPlaybackEvent
 */
private function AnimationChange(event:StepPlaybackEvent):void{
	if (event.stepIndex >= 0){
		
		stepno=event.stepIndex;
		documentCollaborationObject.setValue(ANIMATIONCHANGE, {stepNo: iSpringSlideControler.currentStepIndex})
		if (Log.isDebug()) log.debug("AnimationChange: animationChange is called stepNo:" + iSpringSlideControler.currentStepIndex);
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording)
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addAnimationStepTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), stepno, currentPage);
	}
}

/*........End iSpring related  code*/
/**
 * For handling the keyborad navigation
 * @param event of KeyboardEvent
 */
private function keyboardActionHandler(event:KeyboardEvent):void{
	applicationType::DesktopWeb{
		hideContextMenuList();
		if (event.ctrlKey)	{
			if (event.keyCode == 80){
				var ev:Event;
				teacherMouseShare(ev);
			}
			if (event.keyCode == 38){
				AuditContext.userAction.keyBoardShortcutEventLog("Ctrl+" + event.keyCode.toString(), "Document Sharing");
				if (currentPage < totalPages)
					currentPage+=1;
			}
			else if (event.keyCode == 40){
				AuditContext.userAction.keyBoardShortcutEventLog("Ctrl-" + event.keyCode.toString(), "Document Sharing");
				if (currentPage > 1)
					currentPage-=1;
			}
			automaticSlideSwitching=false;
		}
		else{
			if (pptLoaded){
				if (event.keyCode == 40 || event.keyCode == 39)	{
					AuditContext.userAction.keyBoardShortcutEventLog(event.keyCode.toString(), "Animations");
					automaticSlideSwitching=true;
					iSpringSlideControler.gotoNextStep();
				}
				if (event.keyCode == 37 || event.keyCode == 38)	{
					AuditContext.userAction.keyBoardShortcutEventLog(event.keyCode.toString(), "Animations");
					automaticSlideSwitching=true;
					iSpringSlideControler.gotoPreviousStep();
					if (stepno > 0)
						iSpringSlideControler.playFromStep(stepno - 1);
					
				}
			}
		}
	}
}
/**
 * for setting the resolution according to the avalible canvas height or width
 * first it check for the width according to the height is available or not
 * If width is not available according to the height, then it sets the width and height according to the width
 */
private function getResolutionProperties(parentContainer:*,prevWidth:Number):Object
{
	var obj:Object=new Object();
	previousWidth=prevWidth;
	var tempWidth:Number;
	obj.height=parentContainer.height - 10;
	tempWidth=(obj.height / 3) * 4;
	if (tempWidth >= parentContainer.width){
		obj.width=parentContainer.width - 10;
		obj.height=(obj.width / 4) * 3;
	}
	else
		obj.width=tempWidth;	
	infoBarWidth=obj.width;
	/*if (!annotationBox.includeInLayout)
		fileNameWidth=(3 * obj.width) / 4;
	else*/
		fileNameWidth= obj.width;
	return obj;
}
/**
 * setting the ispring container width and height here
 */
public function onResizeispring():void {
	resizing=true;
	applicationType::DesktopWeb{
		var obj:Object=getResolutionProperties(iSpringCanvas,iSpringWidth)
		setLoaderProperties(obj);	
	    hideContextMenuList();
	}
		if (uiComp)	{
			if (userRole == Constants.PRESENTER_ROLE)
				ispringScaleDocument(ispringZoomFactorX, ispringZoomFactorY, iSpringWidth, previousWidth, previousWidth);
			else
				ispringScaleDocument(teacherZoomFactorXForAnimated, teacherZoomFactorYForAnimated, iSpringWidth, iSpringWidthTeacher, iSpringWidthTeacher);
		}
		if(isResized) setTimeout(normalZoom,500);
		isResized=false;
	//}
}
/* End of iSpring related functions*/
/**
 * setting the p2fcontainer width and height here
 * while resizing the doc container
 */
public function onDocResize():void{
	/////////////////////////////////////////////////////////////////////////
	//if print2flash container is not null
	//then calling the method getResolution() for getting print2flash height and width
	//set print2flash container size (getting height and width of print2flash
	//if user type is "teacher", then set current page( this is because,when resizing, sometimes we may not get t he same page)
	//taking the current page from entPage(TextInput to display the current page number on the teacher side) 
	//else means if user type is student, set current page
	//taking the current page from lab(label to display the current page number on the student side)
	//--START--------------------------------------------------------------- 	
	applicationType::web{
		//p2fContainer.content is always null. So we changed the check
		if (docCanvas && p2fContainer && p2fLoaderObj.numChildren > 0) documentResizeHandler();
	}
	applicationType::DesktopMobile{
		if (docCanvas && p2fContainer && p2fContainer.source != null) documentResizeHandler();
	}
	applicationType::DesktopWeb{
		if (fileManager)
			fileManager.move((fileManager.parent.width / 2 - (fileManager.width / 2)), (fileManager.parent.height / 2 - (fileManager.height / 2)));
	}
	applicationType::web{
		//p2fContainer.content is always null. So we changed the check
		if (docCanvas && p2fContainer && p2fLoaderObj.numChildren == 0)	{
			resetDocumentContainerSize(0);
		}
	}
	applicationType::desktop{
		if (docCanvas && p2fContainer && p2fContainer.source == null && !isLoadDoc && !pptLoaded)
			resetDocumentContainerSize(0);
		if(isPopOut && p2fContainer.source == null ){
			setTimeout(documentResizeHandler,1000);
		}
		if(userRole == Constants.PRESENTER_ROLE){
		if(isResized) setTimeout(normalZoom,1000);
		resizing=false;
		isResized=false;
		//trace("Document Resizing");  
		}
	}
	//if(isResized) normalZoom();
	  
}

/**
 *
 * @private
 * This function is invoked when we resize the document container
 *
 *
 * @return void
 *
 ***/
private function documentResizeHandler():void
{
	
	/////////////////////////////////////////////////////////////
	//setting 'resizing' flag is set to true for identifying this function is invoked			 
	
	resizing=true;
	//to get the new width and height for scaling the zoom value on the student side,
	//we have moved the following lines of code from bottom	
	applicationType::DesktopWeb{
		var obj:Object=getResolutionProperties(p2fCanvas,p2fWidth)
		setLoaderProperties(obj);
	}
	applicationType::mobile{
		getResolution();
	}
	if (p2fWidth != tempP2FWidth){
		docCanvas.width=p2fWidth;
		docCanvas.height=p2fHeight;		
		if (userRole == Constants.PRESENTER_ROLE){
			tempNumber=currentPage;
			//setting the zoom with  scaled zoom value while resizing
			//if(thumStatus) normalZoomHandler();
			
			scaleDocument(zoomFactorX, zoomFactorY, p2fWidth, p2fHeight, previousWidth, previousHeight);
			//trace("Document resizeeee");
			rotateDoc(rotationDegree, p2fWidth, p2fHeight, zoomFactorX);
			if(thumStatus){
				normalZoom()
				//thumStatus=false;
			}
			
		}
		else{
			trace("Document resizeeee teacherZoomFactorX"+teacherZoomFactorX);
			scaleDocument(teacherZoomFactorX, teacherZoomFactorY, p2fWidth, p2fHeight, p2fWidthTeacher, p2fHeightTeacher);
			rotateDoc(rotationDegree, p2fWidth, p2fHeight, teacherZoomFactorX);
		}
		tempP2FWidth=p2fWidth;
		applicationType::DesktopWeb{
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording && p2fWidth > 0 && p2fHeight > 0){
				var tempDocLength:int=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded.length();
				var src:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded[tempDocLength - 1].@src;
				src=src.substr(0, src.lastIndexOf("."));
				src=src.substr(0, src.lastIndexOf("."));
				if (tempDocLength > 0 && remoteFilePath.substr(0, remoteFilePath.lastIndexOf(".")) == "/AVContent/Upload" + src)
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addSizeTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(),maxX, maxY, p2fWidth, p2fHeight, p2fContainer.scaleX, p2fContainer.scaleY, scrollPositionX, scrollPositionY);
			}
		}
	}
}

/**
 *
 * @private
 * This function is used to reset document container width and height
 *
 * @param value of Number.
 * @return void
 *
 ***/
private function resetDocumentContainerSize(value:Number):void{
	p2fWidth=value;
	p2fHeight=value;
	tempP2FWidth=value;
}
private var isNeedRemoveAnnotation:Boolean=false;
/**for setting the GUI while the controls has been changed
 * @param isPresenter of boolean to check the user role
 */
public function updateControls(isPresenter:Boolean):void{
	applicationType::DesktopWeb{	
	//showhide();
		//this.removeElement(progressBar);
		if(isProgressBarPresent) this.removeElement(progressBar);
		if (previousRole != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole){
			removeAllPopUpWndw();
			//uploadDocument();
			isNeedRemoveAnnotation=true;
			//trace("isNeedRemoveAnnotation");
			removeAnnotationTools();
			if (isAnnotationToolRmoved){
				removeAnnotation();
				isAnnotationToolRmoved=false
			}
			 
			if(isVThumb||isHThumb){
				hideThumbNail();
				isVThumb=false;
				isHThumb=false;
			}
			if (alert)
				PopUpManager.removePopUp(alert);
			applicationType::web{
				//To avoid the issue "The supplied DisplayObject must be a child of the caller", we changed p2fContainer to uiComp.
				removeUIComp(uiComp, uiComp);
			}
			applicationType::desktop{
				if (pptLoaded)
					removeUIComp(uiComp, uiComp);
				else
					removeUIComp(p2fContainer, p2fContainer);
			}
			if (!isPresenter){
				btnImgDownload.enabled=false;
				btnImgUnload.enabled=false;
				nextBtn.visible=false;
				prevBtn.visible=false;
				entPage.enabled=false;
				thumbNailVerticalBox.visible=false;
				thumbNailHorizontalBox.visible=false
				rightClickAllowed=false	
				/*setTimeout(updateControls,500,isPresenter);
				permissionMsgStudent.visible=true;*/
				unloadContextMenuData();
				if (entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
					entPage.removeEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
				if (docCanvas.hasEventListener(ScrollEvent.SCROLL))
					docCanvas.removeEventListener(ScrollEvent.SCROLL, getVerticalScrollPosition);
				userRole=Constants.VIEWER_ROLE;
				//connecting shared object with FMS
				controlStack.selectedChild=studentAppbar;
				if(isMaximized == false)
					toolBarPanel.height=97;
				else
					toolBarPanel.height=70;
				applicationType::web	{
					//p2fContainer.content is always null. So we changed the check
					if ((p2fContainer.content != null && p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true) || pptLoaded)
						saveDocumentContext();
				}
				applicationType::desktop{
					//p2fContainer.content != null &&
					if (( p2fContainer.visible == true) || pptLoaded)
						saveDocumentContext();
				}
				if (pptLoaded){
					/*viewerCurrentPageLabel.visible=true;*/
					removeIspringEventListners();
				}
				//annottool('Pen');
				if(isVThumb)
					hHidebtn_clickHandler();
				else if(isHThumb)
					vHideBtn_clickHandler();
		}
		else
		{		
				thumbNailVerticalBox.visible=true;
				thumbNailHorizontalBox.visible=true;
				nextBtn.visible=true;
				prevBtn.visible=true;
				btnImgDownload.enabled=true;
				btnImgUnload.enabled=true;
				entPage.enabled=true;
				chkBoxPermission.selected=false;
				isDownloadDisturbed=false;
				userRole=Constants.PRESENTER_ROLE;
				controlStack.selectedChild=teacherAppbar;
				if(isMaximized == false)
					toolBarPanel.height=368;
				else
					toolBarPanel.height=70;
				fileNameTeacher.text=remoteFileName;
				permissionStatus=PERMISSION_DENY_STATUS_MSG;
				permissionMsg.visible=true;
				documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: DENY_PERMISSION});
				if (Log.isDebug()) log.debug("updateControls: downloadPermission is called permission:" + DENY_PERMISSION);
				hideContextMenuList();
				applicationType::web{
					//p2fContainer.content is always null. So we changed the check
					if ((p2fLoaderObj.numChildren > 0 && (p2fContainer.visible == true || loadCompletedFlag == false)) && !pptLoaded){
						storeP2FDocumentDetails();
						//Fix for issue #20159
						chkBoxPermission.enabled=true;
						chkBoxPermission.selected=false;
						prevBtn.enabled = true;
						nextBtn.enabled = true;
					}
				}
				applicationType::desktop{
					/*if(p2fContainer.content == null){
					applicationType::DesktopWeb{
						if (!entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
							entPage.addEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
					trace("scaleDocument when Content Null ---teacherZoomFactorX:"+teacherZoomFactorX+"teacherZoomFactorY:"+teacherZoomFactorY+"p2fWidth"+p2fWidth+"p2fWidthTeacher"+p2fWidthTeacher);
					scaleDocument(teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fWidth,p2fWidthTeacher,p2fWidthTeacher);
					}
					}*/
					if ((p2fContainer.content != null && (p2fContainer.visible == true || loadCompletedFlag == false)) && !pptLoaded)
					{
						//trace("Update Controll PresenterSide Called")
						storeP2FDocumentDetails();
						
						chkBoxPermission.enabled=true;
						chkBoxPermission.selected=false;
						prevBtn.enabled = true;
						nextBtn.enabled = true;
					}
					else if(isLoadDoc){
						//trace("LOadDocumentBool in Update Controll"+isLoadDoc)
						if (!entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
							entPage.addEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
						//trace("scaleDocument when Content Null ---teacherZoomFactorX:"+teacherZoomFactorX+"teacherZoomFactorY:"+teacherZoomFactorY+"p2fWidth"+p2fWidth+"p2fWidthTeacher"+p2fWidthTeacher);
						if (Log.isDebug()) log.debug("scaleDocument when Content Null ---teacherZoomFactorX:"+teacherZoomFactorX+"teacherZoomFactorY:"+teacherZoomFactorY+"p2fWidth"+p2fWidth+"p2fWidthTeacher"+p2fWidthTeacher);
						scaleDocument(teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fWidth,p2fWidthTeacher,p2fWidthTeacher);
						
					}
				}
				if (pptLoaded && iSpringContainer.visible == true)
				{
					storeISpringDocumentDetails();
					chkBoxPermission.enabled=true;
					chkBoxPermission.selected=false;
					prevBtn.enabled = true;
					nextBtn.enabled = true;
				}
				rightClickAllowed=true;
				
				applicationType::web{				
					//Fix for issue #20232	
					if (remoteFilePath != ""){
						setCollaborationObjectValues();
					}//Instead of SWFLoader we use Loader to load the P2F documents.So we changed the check
					else if (p2fLoaderObj.numChildren == 0 || pptLoaded)
						unloadDocument();
				}
				applicationType::desktop{	
					if (remoteFilePath != ""){
						setCollaborationObjectValues();
					}
					else if (p2fContainer.content == null || pptLoaded)
						unloadDocument();
				}
				docCanvas.addEventListener(ScrollEvent.SCROLL, getVerticalScrollPosition);
				mousePointerShare=mousePointerEnable;			
				presenterMousePointer=false;
				mousePointerShared=false;			
			}		
				
			previousRole = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole;		
		}
	
		else{
				previousRole=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole;
				if(isPresenter)
				{
					if (remoteFilePath == "")
						clearServer();
					else{
						if (ipAddress != ClassroomContext.CONTENT_DOCUMENT)	{
							ipAddress=ClassroomContext.CONTENT_DOCUMENT;
							unloadDocument();
						}
						else resetFmsData();
						isDownloadDisturbed=false;
					}
				}
				else if (ipAddress != ClassroomContext.CONTENT_DOCUMENT)
						unloadDocument();
				
		}
		isProgressBarPresent=false;
	}
	applicationType::mobile{
		if(!isPresenter){		
			if(previousRole != FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole){
				removeAnnotationTools();
				if(isAnnotationToolRmoved)
				{
					removeAnnotation();
					isAnnotationToolRmoved = false
				}
				if(pptLoaded)
				{
					removeUIComp(uiComp,uiComp);
				}
				else 
				{											
					removeUIComp(p2fContainer,p2fContainer);
				}	
				if(alert)
					PopUpManager.removePopUp(alert);
				contextMenu=null;
				//changed FlexEvent.VALUE_COMMIT as Event.CHANGE
				if(informationCallout.txtEnterPage != null && informationCallout.txtEnterPage.hasEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE)){
					informationCallout.txtEnterPage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,pageChanged);
				}
				/*if(docCanvas.hasEventListener(ScrollEvent.SCROLL)){
					docCanvas.removeEventListener(ScrollEvent.SCROLL,getVerticalScrollPosition);
				}*/
				userRole= Constants.VIEWER_ROLE;	
				FlexGlobals.topLevelApplication.docTool.studentAppbar.visible=true;
				FlexGlobals.topLevelApplication.docTool.studentAppbar.includeInLayout = true;
				FlexGlobals.topLevelApplication.docTool.teacherAppbar.visible=false;
				FlexGlobals.topLevelApplication.docTool.teacherAppbar.includeInLayout=false;
				FlexGlobals.topLevelApplication.docTool.btnViewerDocument.enabled = true;
				prevBtn.enabled = false;
				nextBtn.enabled = false;
				//To set visibility of callout controls based on the usertype.
				closeInfoCallout();
				if(informationCallout.txtEnterPage != null && informationCallout.lblCurrentPage != null){
					informationCallout.txtEnterPage.visible = false;
					informationCallout.txtEnterPage.includeInLayout = false;
					informationCallout.lblTotalPage.visible = false;
					informationCallout.lblTotalPage.includeInLayout = false;
					informationCallout.lblCurrentPage.visible = true;
					informationCallout.lblCurrentPage.includeInLayout = true;
				}
				if((p2fContainer!= null && p2fContainer.content !=null && p2fContainer.visible == true) ||pptLoaded ){
					isPageLoaded=true;		
					if(remoteFilePath != ""){
						previousRemoteFilePath = remoteFilePath;
					}											
					if(!pptLoaded){	
						teacherZoomFactorX=zoomFactorX;
						teacherZoomFactorY=zoomFactorY;
						p2fWidthTeacher=p2fWidth;
						p2fHeightTeacher=p2fHeight;
						previousPage = currentPage;														
						pptLoaded=false;
					}
				}						
				if(pptLoaded){	
					removeIspringEventListners();
				}  
			}	
			if(ipAddress != ClassroomContext.CONTENT_DOCUMENT){
				unloadDocument();
			}
		}
		else{
			if(previousRole != FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole){
				removeAnnotationTools();
				if(isAnnotationToolRmoved){
					removeAnnotation();
					isAnnotationToolRmoved = false
				}
				if(alert)
					PopUpManager.removePopUp(alert);
				isDownloadDisturbed=false;
				userRole= Constants.PRESENTER_ROLE;
				FlexGlobals.topLevelApplication.docTool.studentAppbar.visible = false;
				FlexGlobals.topLevelApplication.docTool.studentAppbar.includeInLayout = false;
				FlexGlobals.topLevelApplication.docTool.teacherAppbar.visible = true;
				FlexGlobals.topLevelApplication.docTool.teacherAppbar.includeInLayout = true;
				FlexGlobals.topLevelApplication.docTool.btnDocument.enabled = true;
				prevBtn.enabled = true;
				nextBtn.enabled = true;
				//To set visibility of callout controls based on the usertype.
				closeInfoCallout();
				if(informationCallout.txtEnterPage != null && informationCallout.lblCurrentPage != null){
					informationCallout.txtEnterPage.visible = true;
					informationCallout.txtEnterPage.includeInLayout = true;
					informationCallout.lblTotalPage.visible = true;
					informationCallout.lblTotalPage.includeInLayout = true;
					informationCallout.lblCurrentPage.visible = false;
					informationCallout.lblCurrentPage.includeInLayout = false;
				}
				permissionStatus=PERMISSION_DENY_STATUS_MSG;
				documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: DENY_PERMISSION});
				if(Log.isDebug()) log.debug("updateControls: downloadPermission is called permission:"+DENY_PERMISSION);
				
				if((p2fContainer.content != null && (p2fContainer.visible == true||loadCompletedFlag == false))&& !pptLoaded){ 
					thumbPath=presenterThumbPath;
					controlButtonsIsEnable(true);
					zoomFactorX=teacherZoomFactorX;
					zoomFactorY=teacherZoomFactorY;
					getResolution();
					previousPage = currentPage;
					if(informationCallout.txtEnterPage != null && !informationCallout.txtEnterPage.hasEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE))
						informationCallout.txtEnterPage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,pageChanged);
				}
				if(remoteFilePath!=""){
					//Changed enterpage component to callout.
					if(informationCallout.txtEnterPage != null && informationCallout.lblCurrentPage != null){
						informationCallout.txtEnterPage.text=String(currentPage);
					}
					setCollaborationObjectValues();
				}
				else if(p2fContainer.content == null ||pptLoaded){
					unloadDocument();								  	
				}
				mousePointerShare = mousePointerEnable;
				FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare = mobileMousePointerEnable;
				if(pptLoaded){
					removeUIComp(uiComp,uiComp);
				}
				else {											
					removeUIComp(p2fContainer,p2fContainer);
				}	
				mousePointerShared = false;		
			}	
			else{
				if(remoteFilePath==""){
					clearServer();
				}else{
					if(ipAddress != ClassroomContext.CONTENT_DOCUMENT){
						/*ipAddress = ClassroomContext.CONTENT_DOCUMENT;
						failOverClearTimer = new Timer(1500,1);
						failOverClearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unloadDocAfterFailOver);
						failOverClearTimer.start();*/
					}else{
						resetFmsData();	
					}
					isDownloadDisturbed=false;
				}
			}
		}
		
		//To change the height of document menu list.
		FlexGlobals.topLevelApplication.docTool.docMenuComp.changeDocListHeight();
	}
	//trace("Update Controls called");
	//isPresnter=false;
}
//RTCR: Need to change function name
private function storeP2FDocumentDetails():void{
	thumbPath=presenterThumbPath;
	applicationType::DesktopWeb{
		entPage.enabled=true;
	}
	controlButtonsIsEnable(true);
	zoomFactorX=teacherZoomFactorX;
	zoomFactorY=teacherZoomFactorY;
	previousPage=currentPage;
	//trace("scaleDocument when Content Not Null ---teacherZoomFactorX:"+teacherZoomFactorX+"teacherZoomFactorY:"+teacherZoomFactorY+"p2fWidth"+p2fWidth+"p2fWidthTeacher"+p2fWidthTeacher);
	scaleDocument(teacherZoomFactorX,teacherZoomFactorY,p2fWidth,p2fWidth,p2fWidthTeacher,p2fWidthTeacher);
	contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
	if (this)
		this.addEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
	applicationType::DesktopWeb{
		if (!entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
			entPage.addEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
	}
	applicationType::mobile{
		if(informationCallout.txtEnterPage != null && !informationCallout.txtEnterPage.hasEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE))
			informationCallout.txtEnterPage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,pageChanged);
	}
}
//RTCR: Need to change function name
private function storeISpringDocumentDetails():void{
	applicationType::DesktopWeb{
		thumbPath=presenterThumbPath;
		controlButtonsIsEnable(false);
		contextMenuArray=new Array(DOWNLOAD, PERMISSION, UNLOAD);
		addEventListenersToiSpring();
		if (!entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
			entPage.addEventListener(FlexEvent.VALUE_COMMIT, pageChanged);
	}
}
//RTCR: Need to change function name
private function setCollaborationObjectValues():void{
	applicationType::DesktopWeb{
		entPage.text=String(currentPage);
	}
	documentCollaborationObject.setValue(NEWFILE, {path:getDownloadableRemotePath(remoteFilePath), fileName: remoteFileName, totalPages: totalPages, fileExtention: fileExtention, thumbPath: thumbPath, p2fHeightTeacher: p2fHeight, p2fWidthTeacher: p2fWidth, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, X: xValue, Y: yValue, MaxX: maxX, MaxY: maxY, animated: animatedFile})
	if (Log.isDebug()) log.debug("updateControls: loadNewFile is called path:" + remoteFilePath + ", fileName:" + remoteFileName + ", fileExtention:" + fileExtention + ", thumbPath:" + thumbPath + ", p2fHeightTeacher:" + p2fHeight + ", p2fWidthTeacher:" + p2fWidth + ", teacherZoomFactorX:" + zoomFactorX + ", teacherZoomFactorY:" + zoomFactorY + ", X:" + xValue + ",  Y:" + yValue + ",  MaxX:" + maxX + ",  MaxY:" + maxY + ", animated:" + animatedFile);
	documentCollaborationObject.setValue(PAGECHANGE, {pageNo: currentPage, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, p2fWidthTeacher: p2fWidth})
	if (Log.isDebug()) log.debug("updateControls: PageChange is called pageNo:" + currentPage + ", teacherZoomFactorX:" + zoomFactorX + ", teacherZoomFactorY:" + zoomFactorY + ", p2fWidthTeacher:" + p2fWidth);
}

/**
 *
 * @private
 * This function is used to save document context
 *
 *
 * @return void
 *
 ***/
private function saveDocumentContext():void{
	applicationType::DesktopWeb{
		isPageLoaded=true;
		fileNameStudent.visible=true
		permissionMsgStudent.visible=true;
		trace("saveDocumentContext Called zoomFactorX---"+zoomFactorX);
    	/*lblPageSt.visible=true;*/
		if (remoteFilePath != "") previousRemoteFilePath=remoteFilePath;
		if (!pptLoaded){
			scaleDocument(zoomFactorX,zoomFactorY,p2fWidth,p2fWidth,p2fWidth,p2fWidth);
			teacherZoomFactorX=zoomFactorX;
			teacherZoomFactorY=zoomFactorY;
			p2fWidthTeacher=p2fWidth;
			p2fHeightTeacher=p2fHeight;
			previousPage = currentPage;	
			pptLoaded=false;
			if (this && this.hasEventListener(KeyboardEvent.KEY_DOWN))
				this.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
		}
	}
}

/**
 * for show/hide the Vertical Thumbnail  
 * @param event of MouseEvent
 */
protected function vHideBtn_clickHandler(event:MouseEvent=null):void
{
	applicationType::DesktopWeb{
		// TODO Auto-generated method stub
		if (p2fContainer.content == null && p2fContainer.visible == false && !iSpringSlideControler)
			return;
		hHidebtn.enabled=false;
		vHideBtn.enabled=false;
		if(isHThumb)
		{
			HThumbdecreaseWidthEffect.play();
			isHThumb=false;
			hHidebtn.setStyle("icon", thumbDown);
			setTimeout(vHideBtn_clickHandler,1000);
			return;
		}
		 if(!isVThumb){
			VThumbInsreaseWidthEffect.play();
			isVThumb=true;
			vHideBtn.setStyle("icon", hideThumbLeft);
			clickThum=true;
			}
		
		else{
				VThumbdecreaseWidthEffect.play();
				isVThumb=false;
				vHideBtn.setStyle("icon", unhideThumbLeft);
				clickThum=false;
		}
		 hHidebtn.enabled=true;
		 vHideBtn.enabled=true;
		 //clickThum=true;
	}
}

/**
 * for show/hide the Horizontal Thumbnail
 * @param event of MouseEvent
 */
protected function hHidebtn_clickHandler(event:MouseEvent=null):void
{
	applicationType::DesktopWeb{
		// operations for show/hide the Horizontal Thumbnail 
		if (p2fContainer.content == null && p2fContainer.visible == false && !iSpringSlideControler)
		{
			return;
		} 
		hHidebtn.enabled=false;
		vHideBtn.enabled=false;
		if(isVThumb)
		{
			VThumbdecreaseWidthEffect.play();
			isVThumb=false;
			vHideBtn.setStyle("icon", unhideThumbLeft);
			setTimeout(hHidebtn_clickHandler,1000);
			return;
		}
	     if(!isHThumb){
			HThumbInsreaseWidthEffect.play();
			isHThumb=true;
			clickThum=true;
			hHidebtn.setStyle("icon", thumbUp);
			}
		
		else{
			HThumbdecreaseWidthEffect.play();
			isHThumb=false;
			hHidebtn.setStyle("icon", thumbDown);
			clickThum=false;
		}
		//vList.HorizontalCheckScroll();
		 hHidebtn.enabled=true;
		 vHideBtn.enabled=true;
		 //clickThum=true;
	}
}


/**
 * function for getting next page by clicking on the next button
 */
private function getNextPage():void{	
	//////////////////////////////////////////////////////////////
	//TEACHER_NAVIGATION_NEXT #1				
	//--START------------------------------------------
	applicationType::web{
		//Fix for issue #20195
		clearTimeout(viewerLoadppt);
		buttonEnabling(true);
		setTimeout(buttonEnabling,500,false);
		//p2fContainer.content is always null. So we changed the check
		if ((p2fLoaderObj.numChildren > 0 && fileExtention != "") || (pptLoaded && fileExtention != ""))
			nextPageHandler();
	}
	applicationType::DesktopMobile{
			clearTimeout(viewerLoadppt);
			buttonEnabling(true);
			setTimeout(buttonEnabling,500,false);
		if ((p2fContainer.content != null && fileExtention != "") || (pptLoaded && fileExtention != ""))
			
			nextPageHandler();
		
	}
}
private function buttonEnabling(btn:Boolean):void{
	if(btn){
		nextBtn.enabled=false;
		prevBtn.enabled=false;
	}
	else{
		nextBtn.enabled=true;
		prevBtn.enabled=true;
	}
}

/**
 *
 * @private
 * This function is used to get next page by clicking on the next button
 *
 *
 * @return void
 *
 ***/
private function nextPageHandler():void{
	if (isDownloadDisturbed){
		localDownloadErrorHandler();
		return;
	}
	if (currentPage != totalPages && !isDownloadDisturbed){
		isInvalidePage=false;
		automaticSlideSwitching=false;
		currentPage=currentPage + 1;
		applicationType::DesktopWeb{
			documentNavigationEventLog(remoteFilePath, "NextButton", currentPage);
		}
	}
	else{
		applicationType::DesktopWeb{
			if (entPage.text == "" && !isDownloadDisturbed){
			currentPage=previousPage;
			entPage.text=String(currentPage);
			}
		}
		applicationType::mobile{
			if(informationCallout.txtEnterPage != null && informationCallout.txtEnterPage.text=="" && !isDownloadDisturbed){
				currentPage=previousPage;
				informationCallout.txtEnterPage.text=String(currentPage);
			}
		}
	}
}

/**
 *
 * @private
 * Audits the "DocumentNavigation" action, when the presenter navigates the page
 *
 * @param url of the document
 * @param navigationMethod - Thumbnail navigation or regular navigatoin
 * @param pageNum - New page number
 * @return void
 *
 */
private function documentNavigationEventLog(url:String, navigationMethod:String, pageNum:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentNavigation, url, navigationMethod, pageNum + "");
}

/**
 * function for getting the previous page by clicking previous button
 */
private function getPreviousPage():void{
	/////////////////////////////////////////////////////////////////////
	//TEACHER_NAVIGATION_PREV #1
	//--START-----------------------------------
	applicationType::web{
		//Fix for issue #20195
		clearTimeout(viewerLoadppt);
		buttonEnabling(true);
		setTimeout(buttonEnabling,500,false);
		//p2fContainer.content is always null. So we changed the check
		if ((p2fLoaderObj.numChildren > 0 && fileExtention != "") || (pptLoaded && fileExtention != ""))
			previousPageHandler();
	}
	applicationType::DesktopMobile{
		clearTimeout(viewerLoadppt);
		buttonEnabling(true);
		setTimeout(buttonEnabling,500,false);
		if ((p2fContainer.content != null && fileExtention != "") || (pptLoaded && fileExtention != ""))
			
			previousPageHandler();
	}
}

/**
 *
 * @private
 * This function is used to get previous page by clicking on the next button
 *
 *
 * @return void
 *
 ***/
private function previousPageHandler():void{
	if (isDownloadDisturbed){
		localDownloadErrorHandler();
		return;
	}
	applicationType::DesktopWeb{
		if (currentPage != 1 && entPage.text != "" && !isDownloadDisturbed){
			automaticSlideSwitching=false;
			currentPage=parseInt(entPage.text) - 1;
			documentNavigationEventLog(remoteFilePath, "PreviousButton", currentPage);
		}
		else if (entPage.text == "" && !isDownloadDisturbed){
			isInvalidePage=false;
			currentPage=previousPage;
			entPage.text=String(currentPage);
		}
	}
	applicationType::mobile{
		if(currentPage >1 && !isDownloadDisturbed)
		{
			automaticSlideSwitching=false;
			currentPage = currentPage-1;
		}
		else if(informationCallout.txtEnterPage != null && informationCallout.txtEnterPage.text==""&& !isDownloadDisturbed)
		{
			currentPage=previousPage;
			informationCallout.txtEnterPage.text=String(currentPage);
		}
		//pageChanged(currentPage.toString());
	}
}

protected function OnSlideClickEventHandler(event:OnSlideClickEvent):void{
	// TODO Auto-generated method stub		
	/*currentPage=event.slideobject.pageno;
	newPageLoad(currentPage);*/
	if(clickThum){
	var gotoPageNo:Number=event.slideobject.pageno;
	gotoPageNo=gotoPageNo-1;
	/*applicationType::DesktopWeb{
	//this.focusManager.setFocus(teacherRefreshBtn);
	}*/
	automaticSlideSwitching=false;
	if (gotoPageNo + 1 <= totalPages) currentPage=gotoPageNo + 1;
	documentNavigationEventLog(remoteFilePath, (isVThumb) ? "VerticalThumnails" : "HorizontalThumnails", currentPage);
	}
	else return;

}

/**
 * function for getting the page which is given by the user
 */
private function enterPage():void{
	
	if (isDownloadDisturbed){
		localDownloadErrorHandler();
		currentPage=previousPage;
		applicationType::DesktopWeb{
			entPage.text=String(currentPage);
		}
		applicationType::mobile{
			informationCallout.txtEnterPage.text=String(currentPage);
		}
		return;
	}
	// mouseOver="{entPage.enabled=true}" mouseOut="{entPage.enabled=false}"
	/*if(isPopOut){
	//focusManager.setFocus(popOutBtn);
	applicationType::desktop{
	popOutBtn.setFocus();
	}
	}*/
	applicationType::DesktopWeb{
		if (parseInt(entPage.text) <= 0 || parseInt(entPage.text) > totalPages || entPage.text == ""){
			isInvalidePage=true
			alert=MessageBox.show("Enter valid Page Number", "INFO", MessageBox.MB_OK, this.parent as Sprite);
			entPage.text=String(currentPage);
			return;
		}
		
	}
	applicationType::mobile{
		if(parseInt(informationCallout.txtEnterPage.text)<=0 || parseInt(informationCallout.txtEnterPage.text)>totalPages || informationCallout.txtEnterPage.text=="")
		{
			alert=MessageBox.show("Enter valid Page Number","INFO",MessageBox.MB_OK,this.parent as  Sprite,null,null,MessageBox.IC_INFO);
			currentPage=previousPage;
			informationCallout.txtEnterPage.text=String(currentPage);
			return;
		}
	}
	isInvalidePage=false;
	automaticSlideSwitching=false;
	
	//this.stage.focus = null;
	applicationType::DesktopWeb{
		currentPage=parseInt(entPage.text);
		focusManager.setFocus(next);
		documentNavigationEventLog(remoteFilePath, "EnteredPageNumber", currentPage);
	}
	applicationType::mobile{
		currentPage=parseInt(informationCallout.txtEnterPage.text);
		focusManager.setFocus(FlexGlobals.topLevelApplication.docTool.btnPresenterRefresh);
	}
}

/**
 *This function has invoke,while the changes happend on current page .
 * @param event of FlexEvent
 */
private function pageChanged(event:FlexEvent):void{
	
	 isPresnter=true;
	//trace("Page Changed Called"+isPresnter);
	if (isInvalidePage){
		event.stopImmediatePropagation();
		return;
	}
	if(previousPage==currentPage)
		return;
	//entPage.enabled=false;
	if (parseInt(event.currentTarget.text) <= 0 || parseInt(event.currentTarget.text) > totalPages){
		applicationType::DesktopWeb{
			entPage.text=currentPage.toString();
		}
		applicationType::mobile{
			informationCallout.txtEnterPage.text = currentPage.toString();
		}
		return;
	}
	/*holdPop=downloader.temPrevPage;
	if(isPopOut){
	if(holdPop==currentPage) 
		return;
	}*/
	previousPage=currentPage;
	if (event.currentTarget.text != "") currentPage=parseInt(event.currentTarget.text);
	else{
		currentPage=previousPage;
	}
	tempNumber=currentPage;
	if (!pptLoaded && fileExtention != ""){
		if (this && (penSelected || highlighterSelected)){
			this.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
		}
		if(clickThum){
			setTimeout(newPageLoad,500,currentPage);
			//return;
		}
		
		else newPageLoad(currentPage);
		documentCollaborationObject.setValue(PAGECHANGE, {pageNo: currentPage, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, p2fWidthTeacher: p2fWidth})
		if (Log.isDebug()) log.debug("pageChanged: PageChange is called pageNo:" + currentPage + ", teacherZoomFactorX:" + zoomFactorX + ", teacherZoomFactorY:" + zoomFactorY + ", p2fWidthTeacher:" + p2fWidth);
		
	}
	if (pptLoaded && fileExtention != ""){
		ispringZoomFactorX=1;
		ispringZoomFactorY=1;
		if (!automaticSlideSwitching)
			newPageLoad(currentPage);
		if (Log.isDebug()) log.debug("pageChanged:Ispring: PageChange is called pageNo:" + currentPage + ", teacherZoomFactorX:" + zoomFactorX + ", teacherZoomFactorY:" + zoomFactorY + ", p2fWidthTeacher:" + p2fWidth);
	}
}

/**
 *For handling the page change operation
 * @param pageNo of Number
 *
 */
private function newPageLoad(pageNo:Number):void{
	//trace("New PAge Load Called");
     hideContextMenuList();
	// removeAnnotationTools();
	if (isAnnotationToolRmoved){
		removeAnnotation();
		isAnnotationToolRmoved=false
	}
	//MOBILE_ISPRING:
	/*applicationType::mobile{
		var arguments:String = (pageNo -1)+"," +true;
		if(stageWebView.stageWebView != null){
			stageWebView.stageWebView.loadURL('javascript:goToSlide("'+arguments+'");');
		}
		iSpringPageNo = pageNo -1;
	}*/
	applicationType::DesktopWeb{
		//if (pptLoaded) iSpringSlideControler.gotoSlide(pageNo - 1, true);
		if(pptLoaded){
			iSpringSlideControler.gotoSlide(pageNo - 1, true);
			viewerLoadppt =setTimeout(viewPlaySlide,1000,pageNo);
		}
		if(Log.isDebug()) log.debug("newPageLoad:Page change calle NewPageLoad");
	}
	if (!pptLoaded){
		applicationType::web{
			//Unload the document.
			p2fLoaderObj.removeChildren(0);
		}
		applicationType::desktop{
			p2fContainer.unloadAndStop(true);
		}
		if (uiComp){
			applicationType::desktop{
				//Commented following logic, to enable the next/previous button and thumbnail box when Presenter loads the new page.
				//next.enabled=false;
				//previousBtn.enabled=false;
				thumbNailHorizontalBox.enabled=false;
				thumbNailVerticalBox.enabled=false;
			}
			uiComp.graphics.clear();
			uiComp.removeChildren();
			if (uiComp.hasEventListener(MouseEvent.MOUSE_UP))
				uiComp.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
			if (uiComp.hasEventListener(MouseEvent.MOUSE_MOVE)) 
				uiComp.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			if (p2fContainer.contains(uiComp)) p2fContainer.removeChild(uiComp);
			/*if (entPage.hasEventListener(FlexEvent.VALUE_COMMIT))
				entPage.removeEventListener(FlexEvent.VALUE_COMMIT, pageChanged);*/
			uiComp=null;
			cleanGrabageCollector()
			
		}
		
		fileDownloaderObj.downloadPages(pageNo - 2, pageNo + 2, pageNo);
		isNewPageLoad=true;
		
		//entPage.enabled=true;
	}
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			if (pptLoaded) FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addPageEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), pageNo)
			else FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addPageEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), pageNo)
		}
	}
}
private function viewPlaySlide(pageNo:Number):void{
	iSpringSlideControler.gotoSlide(pageNo - 1,true);
	
}
/**
 *Invoke when presenter made changes in page number
 * @param event of Event
 *
 */
private function gotopage(event:Event):void{
	var gotoPageNo:Number=event.currentTarget.selectedIndex;
	/*applicationType::DesktopWeb{
		//this.focusManager.setFocus(teacherRefreshBtn);
	}*/
	automaticSlideSwitching=false;
	if (gotoPageNo + 1 <= totalPages) currentPage=gotoPageNo + 1;
	documentNavigationEventLog(remoteFilePath, (isVThumb) ? "VerticalThumnails" : "HorizontalThumnails", currentPage);
}


/**
 * This method is invoked when user clicks on zoomInButton.
 * This zoom the document by increasing the zoom factor.
 * Also disables the zoomInButton until the document is zoomed in.
 */
private function zoomIn():void{
	applicationType::DesktopWeb{
		var obj:Object=getResolutionProperties(p2fCanvas,p2fWidth)
		setLoaderProperties(obj);
		isZoom=true;
	}
	applicationType::mobile{
		getResolution();
	}
	applicationType::web{
		//p2fContainer.content is always null. So we changed the check
		if (p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true) zoomInHandler();
	}
	applicationType::DesktopMobile{
		if (p2fContainer.content != null && p2fContainer.visible == true) zoomInHandler();
		
	}
}

/**
 *
 * @private
 * Zoom in handler function.
 * This zoom the document by increasing the zoom factor.
 *
 *
 * @return void
 *
 ***/
private function zoomInHandler():void{
	if (zoomFactorX < 1 && zoomFactorY < 1)	{
		zoomFactorX=zoomFactorX * 1.1;
		zoomFactorY=zoomFactorY * 1.1;
		scaleDocument(zoomFactorX, zoomFactorY, 1, 1, 1, 1);
		applicationType::DesktopWeb{
			documentZoomInEventLog(remoteFilePath, zoomFactorX + "*" + zoomFactorY, currentPage);
			if(Log.isDebug()) log.debug("zoomInHandler:Document changed with remotefilename:"+remoteFilePath+",zoomFactorX:"+zoomFactorX+",zoomFactorY:"+zoomFactorY+",currentPage:"+currentPage);
		}
	}
}

/**
 *
 * @private
 * Audits the "DocumentZoomIn" action, when the presenter zooms in to the document
 *
 * @param url of the document
 * @param zoomXzoomY - Scalefactor in X*Scalefactor in Y
 * @param currentPageNum - Current page number
 * @return void
 *
 */
private function documentZoomInEventLog(url:String, zoomXzoomY:String, currentPageNum:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentZoomIn, url, zoomXzoomY, currentPageNum + "");
}

/**
 * This method is invoked after 200 milli seconds after invoking onZoomChanged method.
 * This re-enables the zoom buttons after changing the zoom value of the document
 */
private function enableZoomButton():void{
	applicationType::DesktopWeb{
		if (zoomInBtn.enabled == false) zoomInBtn.enabled=true;
		if (zoomOutBtn.enabled == false)zoomOutBtn.enabled=true;
	}
}

/**
 * This method is invoked when user clicks on zoomOutButton.
 * This zoom out the document by decreasing the zoom factor.
 * Also disables the zoomOutButton until the document is zoomed out.
 */
private function zoomOut():void{
	applicationType::web{
		//p2fContainer.content is always null. So we changed the check
		if (p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true) zoomOutHandler();
	}
	applicationType::desktop{
		isZoom=true;
		if (p2fContainer.content != null && p2fContainer.visible == true) zoomOutHandler();
	}
}

/**
 *
 * @private
 * Zoom out handler function.
 * This zoom out the document by decreasing the zoom factor
 *
 *
 * @return void
 *
 ***/
private function zoomOutHandler():void{
	if (zoomFactorX > .1 && zoomFactorY > .1){
		zoomFactorX=zoomFactorX / 1.1;
		zoomFactorY=zoomFactorY / 1.1;
		scaleDocument(zoomFactorX, zoomFactorY, 1, 1, 1, 1);
		documentZoomOutEventLog(remoteFilePath, zoomFactorX + "*" + zoomFactorY, currentPage);
		if(Log.isDebug()) log.debug("zoomOutHandler:Document changed with remotefilename:"+remoteFilePath+",zoomFactorX:"+zoomFactorX+",zoomFactorY:"+zoomFactorY+",currentPage:"+currentPage);
	}
}

/**
 *
 * @private
 * Audits the "DocumentZoomOut" action, when the presenter zooms out of the document
 *
 * @param url of the document
 * @param zoomXzoomY - Scalefactor in X*Scalefactor in Y
 * @param currentPageNum - Current page number
 * @return void
 *
 */
private function documentZoomOutEventLog(url:String, zoomXzoomY:String, currentPageNum:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentZoomOut, url, zoomXzoomY, currentPageNum + "");
}

/**
 * This method is invoked when user clicks on initialZoomBtn.
 * This sets the zoom value of the document to initial.
 */
private function normalZoom():void{
	applicationType::web{
		//p2fContainer.content is always null. So we changed the check
		if (p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true){
			normalZoomHandler();
			//p2fContainer.contentWidth and contentHeight are always null. So we changed the check
			scaleDocument(zoomFactorX, zoomFactorY, p2fWidth - 30, p2fHeight - 5, normalWidth, normalHeight);
		}
	}          
	applicationType::desktop	{
		if (p2fContainer.content != null && p2fContainer.visible == true){
			normalZoomHandler();
			scaleDocument(zoomFactorX, zoomFactorY, p2fWidth - 45, p2fHeight, p2fContainer.contentWidth, p2fContainer.contentHeight);
		}
	}
}
 
/**`
 *
 * @private
 * Normal zoom handler function.
 * This sets the zoom value of the document to initial.
 *
 *
 * @return void
 *
 ***/
private function normalZoomHandler():void{
	trace("Normal Zoom handler called");
	zoomFactorX=1;
	zoomFactorY=1;
	documentZoomResetEventLog(remoteFilePath, zoomFactorX + "*" + zoomFactorY, currentPage);
}

/**
 *
 * @private
 * Audits the "DocumentZoomReset" action, when the presenter resets the Zoom
 *
 * @param url of the document
 * @param zoomXzoomY - Scalefactor in X*Scalefactor in Y
 * @param currentPageNum - Current page number
 * @return void
 */
private function documentZoomResetEventLog(url:String, zoomXzoomY:String, currentPageNum:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentZoomReset, url, zoomXzoomY, currentPageNum + "");
}

/**
 * This method is invoked when user doing the zoom Operation.
 * This zoom the document by increasing or decreasing the zoom factor.
 * @param zoomX of number
 * @param zoomY of number
 */
private function zoomChanged(zoomX:Number, zoomY:Number):void
{
	documentCollaborationObject.setValue(DOCZOOM, {zoomFactorX: zoomX, zoomFactorY: zoomY, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight});
	if (Log.isDebug()) log.debug("zoomChanged: zoomDocument is called zoomFactorX:" + zoomX + ", zoomFactorY:" + zoomY + ", p2fWidthTeacher:" + p2fWidth + ",p2fHeightTeacher:" + p2fHeight);
}

/**
 * function for rotating the print2flash container
 * we can rotate p2fContainer  90 degree for each rotation
 */
applicationType::DesktopWeb{
	private function rotateNew():void{
		
		//if print2flash container(p2fcontainer) is not null and
		// rotation degree increment 90 more to current degree 
		applicationType::web{
			//p2fContainer.content is always null. So we changed the check
			if (p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true) rotateNewFunctionHandler();
		}
		applicationType::desktop{
			if (p2fContainer.content != null && p2fContainer.visible == true) rotateNewFunctionHandler();
		}
		//--END:------------------------------------------------------------------------
	}
}
applicationType::mobile{
	private function rotateNew(event:DocumentActionEvent):void{
		if (p2fContainer.content != null && p2fContainer.visible == true) rotateNewFunctionHandler();
	}
}
/**
 *
 * @private
 * Handler function for rotateNew
 * function for rotating the print2flash container
 * we can rotate p2fContainer  90 degree for each rotation
 *
 *
 * @return void
 *
 ***/
private function rotateNewFunctionHandler():void{
	rotationDegree+=90;
	if (rotationDegree == 360) rotationDegree=0;
	rotateDoc(rotationDegree, p2fWidth, p2fHeight, zoomFactorX);
	documentRotateEventLog(remoteFilePath, rotationDegree, currentPage);
	if(Log.isDebug()) log.debug("rotateNewFunctionHandler:Document Rotate with remotefilename:"+remoteFilePath+"zoomFactorX:"+rotationDegree+"currentPage:"+currentPage);
	hideContextMenuList();
}

/**
 *
 * @private
 * Audits the "DocumentRotate" action, when the presenter rotates the document
 *
 * @param url of the document
 * @param rotationDegree - Document rotation degree in the increments +/- 90
 * @param currentPageNum - Current page number
 * @return void
 *
 */
private function documentRotateEventLog(url:String, rotationDegree:int, currentPageNum:int):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.documentRotate, url, rotationDegree + "", currentPageNum + "");
	}
}


/**
 *for rotation related codes includes in this function
 * @param rotation of Number
 * @param width of Number
 * @param height of Number
 * @param zoom of Number
 */
private function rotateDoc(rotation:Number, width:Number, height:Number, zoom:Number):void{
	
	p2fContainer.rotation=rotation;
	switch (rotation){
		case 0:
			p2fContainer.x=0;
			p2fContainer.y=0;
			break;
		case 90:
			p2fContainer.x=width;
			p2fContainer.y=0;
			break;
		case 180:
			p2fContainer.x=width;
			p2fContainer.y=height;
			break;
		case 270:
			p2fContainer.x=0;
			p2fContainer.y=height;
			break;
	}
	if (userRole == Constants.PRESENTER_ROLE){
		documentCollaborationObject.setValue(DOCROTATION, {rotationDegree: rotationDegree});
		if (Log.isDebug()) log.debug("DocumentRotation: Document rotated at:" + rotation + "Degree");
	}
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			var tempDocLength:int=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded.length();
			var src:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded[tempDocLength - 1].@src;
			
			src=src.substr(0, src.lastIndexOf("."));
			src=src.substr(0, src.lastIndexOf("."));
			if (tempDocLength > 0 && remoteFilePath.substr(0, remoteFilePath.lastIndexOf(".")) == "/AVContent/Upload" + src)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addRotateEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), rotation);
			}
		}
	}
}

/**
 * Getting   the Vertical  scroll position values
 * Set to DOCSROLL property in Shared object
 * @param event of Event
 *
 */
private function getVerticalScrollPosition(event:Event):void{
	applicationType::DesktopWeb{
		var verticalScroll:VScrollBar=event.currentTarget as VScrollBar;
		maxX=verticalScroll.maximum;
		scrollDirction="vertical";
		scrollPosition=verticalScroll.value;
		scrollPositionY = verticalScroll.value;
		//verticalScroll.value=verticalScroll.value+8;
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			
			var tempDocLength:int=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded.length();
			var src:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded[tempDocLength - 1].@src;
			
			src=src.substr(0, src.lastIndexOf("."));
			src=src.substr(0, src.lastIndexOf("."));
			if (tempDocLength > 0 && remoteFilePath.substr(0, remoteFilePath.lastIndexOf(".")) == "../../AVContent" + src)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addScrollEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), scrollDirction, scrollPosition);
			}
		}
	}
	applicationType::mobile{
		maxX=event.currentTarget.maximum;
		scrollDirction=	event.currentTarget.direction;
		scrollPosition=event.currentTarget.position;					
	}
	if(userRole == Constants.PRESENTER_ROLE) {
		documentCollaborationObject.setValue(DOCSROLLCHANGE, {position: scrollPosition, direction: scrollDirction, maxX: maxX})
	}
	if (Log.isDebug()) log.debug("getScrollPosition: scrollDocument is called position:" + scrollPosition + ", direction:" + scrollDirction + ", maxX:" + maxX + ", maxY:" + maxY);

}

/**
 *This function stands  for getting   the horizontal scroll position values .
 * @param event of Event
 */
private function getHorizontalScrollPosition(event:Event):void{
	var horizontalScroll:HScrollBar=event.currentTarget as HScrollBar;
	maxY=horizontalScroll.maximum;
	scrollDirction="horizontal";
	scrollPosition=horizontalScroll.value;
	scrollPositionX = horizontalScroll.value;
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
			
			var tempDocLength:int=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded.length();
			var src:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.docXml.docloaded[tempDocLength - 1].@src;
			
			src=src.substr(0, src.lastIndexOf("."));
			src=src.substr(0, src.lastIndexOf("."));
			if (tempDocLength > 0 && remoteFilePath.substr(0, remoteFilePath.lastIndexOf(".")) == "/AVContent/Upload" + src){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addScrollEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), scrollDirction, scrollPosition);
			}
		}
	}
	if(userRole == Constants.PRESENTER_ROLE) {
		documentCollaborationObject.setValue(DOCSROLLCHANGE, {position: scrollPosition, direction: scrollDirction, maxY: maxY})
	}

	if (Log.isDebug()) log.debug("getScrollPosition: scrollDocument is called position:" + scrollPosition + ", direction:" + scrollDirction + ", maxX:" + maxX + ", maxY:" + maxY);

}

applicationType::DesktopWeb{
	/**
	 * for handling  the mouse point sharing .
	 * @param event of Event
	 */
	private function teacherMouseShare(event:Event):void{
		applicationType::web{
			//p2fContainer.content is always null. So we changed the check
			if ((p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true) || pptLoaded) teacherMouseShareHandler();
			else mousePointerShare=mousePointerEnable;
		}
		applicationType::desktop{
			if ((p2fContainer.content != null && p2fContainer.visible == true) || pptLoaded) teacherMouseShareHandler();
			else mousePointerShare=mousePointerEnable;
		}
	}
	//RTCR: Need to change the function name
	private function teacherMouseShareHandler():void{
		if (mousePointerShare == mousePointerEnable){
			mousePointerShare=mousePointerDisable;
			mousePointerShared=true;
			if (isISpringFile(fileExtention) && animatedFile){
				if (!uiComp){
					ispringZoomFactorX=1;
					ispringZoomFactorY=1;				
					uiComp=createUIComponent(0xFFFF00,0,iSpringContainer.width, iSpringContainer.height);
					iSpringContainer.addChildAt(uiComp, 1);
					ispringScaleDocument(ispringZoomFactorX, ispringZoomFactorY, iSpringWidth, iSpringWidth, iSpringWidth);
					setUIcomponentDisplay(iSpringContainer.width,iSpringContainer.height);
				}
				showPointer(uiComp, iSpringWidth, iSpringHeight, uiComp);
				documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: iSpringWidth, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY})
				if (Log.isDebug()) log.debug("teacherMouseShare: sharingMousePoint is called teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", iSpringWidthTeacher:" + iSpringWidth + ", zoomFactorX:" + ispringZoomFactorX + ", zoomFactorY:" + ispringZoomFactorY);
			}
			else{
				applicationType::desktop{
					showPointer(p2fContainer, p2fWidth, p2fHeight, p2fContainer);
				}
				applicationType::web{
					//Added these logic for Pointer scaling.
					if (!uiComp){
						pointerScaleHandler(normalWidth, normalHeight);					
					}
					showPointer(uiComp, normalWidth, normalHeight, uiComp);
				}
				documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight})
				if (Log.isDebug()) log.debug("teacherMouseShare: sharingMousePoint is called teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", p2fWidthTeacher:" + p2fWidth + ", p2fHeightTeacher:" + p2fHeight);
			}
			documentPointerEventLog(remoteFilePath, "PointerEnabled", currentPage);
		}
		else if (mousePointerShare == mousePointerDisable){
			mousePointerShare=mousePointerEnable;
			mousePointerShared=false;
			if (isISpringFile(fileExtention) && animatedFile){
				removeUIComp(uiComp, uiComp);
				documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: iSpringWidth, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY})
				if (Log.isDebug()) log.debug("teacherMouseShare: sharingMousePoint is called teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", iSpringWidthTeacher:" + iSpringWidth + ", zoomFactorX:" + ispringZoomFactorX + ", zoomFactorY:" + ispringZoomFactorY);
			}
			else{
				applicationType::desktop{
					removeUIComp(p2fContainer, p2fContainer);
				}
				applicationType::web{	
					//Changed p2fConatiner to uiComp for Pointer scaling.
					removeUIComp(uiComp, uiComp);
				}
				documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight})
				if (Log.isDebug()) log.debug("teacherMouseShare: sharingMousePoint is called teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", p2fWidthTeacher:" + p2fWidth + ", p2fHeightTeacher:" + p2fHeight);
			}
			documentPointerEventLog(remoteFilePath, "PointerDisabled", currentPage);
		}
	}
}
applicationType::mobile{
	public function teacherMouseShare(event:DocumentActionEvent):void
	{
		if((p2fContainer.content!=null && p2fContainer.visible == true)||pptLoaded)
		{
			if(FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare == mobileMousePointerEnable)
			{	
				FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare = mobileMousePointerDisable;
				mousePointerShared = true;
				teacherMouseout=false;
				showPointer(p2fContainer,p2fWidth,p2fHeight,p2fContainer);
				documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight})
				if(Log.isDebug()) log.debug("teacherMouseShare: sharingMousePoint is called teacherMousePointer:"+mousePointerShared+", teacherMouseout:"+teacherMouseout+", p2fWidthTeacher:"+p2fWidth+", p2fHeightTeacher:"+p2fHeight);
				
			}
			else if(FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare == mobileMousePointerDisable)
			{
				FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare = mobileMousePointerEnable;
				mousePointerShared = false;
				removeUIComp(p2fContainer,p2fContainer);
				if(!teacherMouseout){
					if(pointerShape){
						pointerShape.visible = false;
					} 
					//flag set to true when teacher's mouse is out of the container
					teacherMouseout = true;
					if(!pptLoaded){
						documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight})
						if(Log.isDebug()) log.debug("mouseOutHandler: sharingMousePoint is called teacherMousePointer:"+mousePointerShared+", teacherMouseout:"+teacherMouseout+", p2fWidthTeacher:"+p2fWidth+", p2fHeightTeacher:"+p2fHeight);
					}
				}
			}				
		}
		else
		{
			FlexGlobals.topLevelApplication.docTool.mobileMousePointerShare = mobileMousePointerEnable;
		}
	}
}

/**
 *
 * @private
 * Audits the "DocumentPointer" action, when the presenter enables/disables mouse pointer sharing
 *
 * @param url of the document
 * @param pointerMode - Poiner enabled or disabled
 * @param currentPageNum - Current page number
 * @return void
 *
 */
private function documentPointerEventLog(url:String, pointerMode:String, currentPageNum:int):void
{
	AuditContext.userAction.createAction(AuditConstants.documentPointer, url, pointerMode, currentPageNum + "");
}

private function pointerScaleHandler(width:Number, height:Number):void
{
	applicationType::web{
		zoomFactorX=1;
		zoomFactorY=1;
		uiComp=createUIComponent(0xFFFF00,0, width, height);
		p2fContainer.addChildAt(uiComp, 1);
		scaleDocument(zoomFactorX, zoomFactorY, p2fLoaderObj.width, p2fLoaderObj.height, normalWidth, normalHeight);
		setUIcomponentDisplay(p2fLoaderObj.width,p2fLoaderObj.height);
	}
}
/**
 * for invoking  the mouspoint sharing .
 * @param dispObj of DisplayObjectContainer
 * @param width of Number
 * @param height of Number
 * @param listnerObj of *
 */
private function showPointer(dispObj:DisplayObjectContainer, width:Number, height:Number, listnerObj:*):void{
	applicationType::web{
		//p2fContainer.content is always null. So we changed the check
		if ((p2fLoaderObj.numChildren > 0 && p2fContainer.visible == true) || pptLoaded){
			if (!pointerShape){
				pointerShape=createPointerShape();
				if (!dispObj.contains(pointerShape))
				{
					dispObj.addChild(pointerShape)
				}
				pointerShape.x=width / 2;
				pointerShape.y=height / 2;
			}
			else{
				//Added this check to avoid null object reference issue when Presenter navigates the document
				if (uiComp) uiComp.addChild(pointerShape);
			}
			//Added this check to avoid pointer missing issue when Presenter navigates the page.
			if (!pptLoaded && p2fContainer.getChildIndex(uiComp) == 0) p2fContainer.swapChildrenAt(0, 1);
			hideContextMenuList();
		}
	}
	applicationType::DesktopMobile{
		if ((p2fContainer.content != null && p2fContainer.visible == true) || pptLoaded){
			if (!pointerShape){
				pointerShape=createPointerShape();
				if (!dispObj.contains(pointerShape)) dispObj.addChild(pointerShape)
				//if (penSelected || highlighterSelected){
					if (!pptLoaded && dispObj.numChildren > 2)
						dispObj.setChildIndex(pointerShape, 2)
				//}
				//else if (!pptLoaded) dispObj.setChildIndex(pointerShape, 1)
				pointerShape.x=width / 2;
				pointerShape.y=height / 2;
				
			}
			else{
				if (pptLoaded) uiComp.addChild(pointerShape);
				else{
					dispObj.addChild(pointerShape)
					pointerShape.x=pointerX;
					pointerShape.y=pointerY;
				}
			}
			hideContextMenuList();
		}
	}
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording && userRole != Constants.PRESENTER_ROLE){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docPointerRecorder.addEventTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), pointerX, pointerY, dispObj.width, dispObj.height, dispObj.name)
		}
	}
	if (userRole == Constants.PRESENTER_ROLE){
		if (!listnerObj.hasEventListener(MouseEvent.MOUSE_MOVE))
			listnerObj.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		if (!listnerObj.hasEventListener(MouseEvent.MOUSE_OUT))
			listnerObj.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		if (!listnerObj.hasEventListener(MouseEvent.MOUSE_OVER))
			listnerObj.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		
	}
	else{
		listnerObj.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		if(pointerShape!=null){
			pointerShape.x=pointerX;
			pointerShape.y=pointerY;
		}
	}
	applicationType::web	{
		//clear show pointer time out
		clearTimeout(showPointerTimeOutID);
	}
}

/**
 * For moving the mouspoint sharing component.
 *  @param event of MouseEvent
 */
private function mouseMoveHandler(event:MouseEvent):void{
	var mousePointx1:int=0;
	var mousePointy1:int=0;
	var width:Number;
	var height:Number;
	if (pointerShape){
		
		mousePointx1=event.currentTarget.mouseX - 15;
		mousePointy1=event.currentTarget.mouseY - 15;
		if (pptLoaded){
			if ((mousePointx1 < uiComp.width - 23 && mousePointy1 < uiComp.height - 23) && (mousePointx1 >= 0 && mousePointy1 >= 0)){
				pointerShape.visible=true;
				pointerShape.x=event.currentTarget.mouseX - 15;
				pointerShape.y=event.currentTarget.mouseY - 15;
			}
			else pointerShape.visible=false;
		}
		else{
			applicationType::web{
				//Added this logic for Pointer scaling 				
				setUIcomponentDisplay(normalWidth,normalHeight);
				if ((mousePointx1 < uiComp.width - 23 && mousePointy1 < uiComp.height - 23) && (mousePointx1 >= 0 && mousePointy1 >= 0)){
					pointerShape.visible=true;
					pointerShape.x=event.currentTarget.mouseX - 15;
					pointerShape.y=event.currentTarget.mouseY - 15;
					//Set teacherMouseout value to false when teacher's mouse is inside of the container, to avoid pointer missing issue at Viewer side 
					teacherMouseout=false;
				}
				else{
					pointerShape.visible=false;
					//Set teacherMouseout value to true when teacher's mouse is out of the container, to avoid pointer missing issue at Viewer side .
					teacherMouseout=true;
				}
			}
			applicationType::DesktopMobile{
				pointerShape.x=event.currentTarget.mouseX - 15;
				pointerShape.y=event.currentTarget.mouseY - 15;
			}
		}
		documentCollaborationObject.setValue(MOUSEPOINT, {pointerX: pointerShape.x, pointerY: pointerShape.y, teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: event.currentTarget.width, p2fHeightTeacher: event.currentTarget.height, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY})
		if (Log.isDebug()) log.debug("mouseMoveHandler: sharingMousePoint is called pointerX:" + pointerShape.x + ", pointerY:" + pointerShape.y + ", teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", p2fWidthTeacher:" + event.currentTarget.width + ", p2fHeightTeacher:" + event.currentTarget.height);
		applicationType::DesktopWeb{
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording){
				if (event.currentTarget.name == "p2fContainer"){
					width=p2fWidth;
					height=p2fHeight;
				}
				else{	
					width=iSpringWidth;
					height=iSpringHeight;
				}
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docPointerRecorder.addEventTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), pointerShape.x, pointerShape.y, width, height, event.currentTarget.name)
			}
		}
	}
}

/**
 * For to check  whether the teacher mousepoint outside the documentsharing window or not.
 * @param evnet of MouseEvent
 */
private function mouseOutHandler(event:MouseEvent):void{
	if (pointerShape) pointerShape.visible=false;
	//flag set to true when teacher's mouse is out of the container
	teacherMouseout=true;
	if (pptLoaded){
		documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: iSpringWidth, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY})
		if (Log.isDebug()) log.debug("teacherMouseShare: sharingMousePoint is called teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", iSpringWidthTeacher:" + iSpringWidth + ", zoomFactorX:" + ispringZoomFactorX + ", zoomFactorY:" + ispringZoomFactorY);
	}
	else{
		documentCollaborationObject.setValue(MOUSEPOINT, {teacherMousePointer: mousePointerShared, teacherMouseout: teacherMouseout, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight})
		if (Log.isDebug()) log.debug("mouseOutHandler: sharingMousePoint is called teacherMousePointer:" + mousePointerShared + ", teacherMouseout:" + teacherMouseout + ", p2fWidthTeacher:" + p2fWidth + ", p2fHeightTeacher:" + p2fHeight);
	}
}

/**
 * For to check  whether the teacher mousepoint inside the documentsharing window or not.
 * @param evnet of MouseEvent
 */
private function mouseOverHandler(event:MouseEvent):void{
	if (pointerShape) pointerShape.visible=true;
	teacherMouseout=false;
}

/**
 * For removing the mouspoint sharing component.
 * @param dispObj of DisplayObjectContainer
 * @param listnerObj of *
 */
private function removeUIComp(dispObj:DisplayObjectContainer, listnerObj:*):void{
	
	if (dispObj){
		if (userRole == Constants.PRESENTER_ROLE){
			if (listnerObj.hasEventListener(MouseEvent.MOUSE_MOVE))
				listnerObj.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			if (listnerObj.hasEventListener(MouseEvent.MOUSE_OUT))
				listnerObj.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			if (listnerObj.hasEventListener(MouseEvent.MOUSE_OVER))
				listnerObj.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		}
		if (pointerShape){
			//removeComponent(dispObj,pointerShape);
			if (dispObj.contains(pointerShape)) 
				dispObj.removeChild(pointerShape)
			if(penSelected || highlighterSelected)
			{
				pointerShape = null;
			}
			else
			{
				pointerShape = null;	
				if(pptLoaded&&!isAnnotationToolRmoved)
				{   
					applicationType::DesktopWeb{
						iSpringContainer.removeChild(uiComp);
					}
					uiComp=null;
				}
				else{
					applicationType::web{
						//change uicom8/10/145
						//removeUICompFromP2FContainer();
						if(uiComp)
						{
							p2fContainer.removeChild(uiComp);
							uiComp=null; 
						}
					}
				}
				
				
			}
		}
	
			/*if (dispObj.contains(pointerShape)) {
			 	dispObj.removeChild(pointerShape)
			 	pointerShape=null;
				if(pptLoaded && uiComp.numChildren==0)
				iSpringContainer.removeChild(uiComp);
				uiComp = null;
			}
			else{
				if (pptLoaded){
					applicationType::DesktopWeb{
						iSpringContainer.removeChild(uiComp);
					}
				}*/
				//Added logic to remove the uicomponent from p2fContainer if uiComp is exists.
				
			
	}
		
	
	if (mousePointerEnable == mousePointerDisable){
		mousePointerEnable=mousePointerEnable
		mousePointerShared=false;
	}
}

/**
 * For reseting the document shared object value after network failure
 */
private function resetFmsData():void{
	if (pptLoaded){
		documentCollaborationObject.setValue(NEWFILE, {path: getDownloadableRemotePath(remoteFilePath), fileName: remoteFileName, fileExtention: fileExtention, thumbPath: thumbPath, p2fHeightTeacher: iSpringHeight, p2fWidthTeacher: iSpringWidth, animated: animatedFile,totalPages:totalPages})
		documentCollaborationObject.setValue(ANIMATIONCHANGE, {stepNo: stepno})
	}
	else{
		documentCollaborationObject.setValue(NEWFILE, {path:getDownloadableRemotePath(remoteFilePath), fileName: remoteFileName, fileExtention: fileExtention, totalPages: totalPages, thumbPath: thumbPath, p2fHeightTeacher: p2fHeight, p2fWidthTeacher: p2fWidth, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, X: xValue, Y: yValue, MaxX: maxX, MaxY: maxY, animated: animatedFile, isPageLoaded: false})
		documentCollaborationObject.setValue(PAGECHANGE, {pageNo: currentPage, teacherZoomFactorX: zoomFactorX, teacherZoomFactorY: zoomFactorY, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight})
		documentCollaborationObject.setValue(DOCZOOM, {zoomFactorX: zoomFactorX, zoomFactorY: zoomFactorY, p2fWidthTeacher: p2fWidth, p2fHeightTeacher: p2fHeight});
		if (scrollPosition && scrollDirction)
			//document_so.setValue(docScroll,{position:scrollPosition,direction:scrollDirction,maxX:maxX,maxY:maxY})
			if (permissionStatus == PERMISSION_GRANT_STATUS_MSG)
				documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: PERMISSION});
		if (permissionStatus == PERMISSION_DENY_STATUS_MSG)
			documentCollaborationObject.setValue(DOWNLOADACCESS, {permission: DENY_PERMISSION});	
	}
	if (toolName){
		documentCollaborationObject.setValue(ANNOTATIONTOOL, {toolName: toolName, iSpringWidthTeacher: iSpringWidth, zoomFactorX: ispringZoomFactorX, zoomFactorY: ispringZoomFactorY});
	}
}

/**
 * This function is handling refreshing the loaded Document
 */
private function refreshDocument():void{
	
	applicationType::DesktopWeb{
		controlStack.enabled=false;
	}
	if(remoteFileName!=""&&remoteFilePath!=""){
		tempRemoteFilename=remoteFileName;
		tempRemoteFilepath=remoteFilePath;
	}
	isRefresh=true;
	//loadedFileURL=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/Upload/" + remoteFilePath);
	//unloadDocument();
	//removedata();
	onetimeConnect=true;
	loadFileToCache(getDownloadableRemotePath(tempRemoteFilepath), fileExtention, tempRemoteFilename);
	documentRefreshEventLog(tempRemoteFilepath);
	isRefresh=false;
}

/**
 *
 * @private
 * Audits the "DocumentRefresh" action, when the user refreshes the document
 *
 * @param url of the document
 * @return void
 *
 */
private function documentRefreshEventLog(url:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.documentRefresh, url, null, null);
	}
}

/**
 * fault handler for deleteService
 * @param event of FaultEvent
 */
private function faulthandledel(event:FaultEvent):void
{	
	if (Log.isError()) log.error("DocumentSharing::DocumentHandler::faulthandledel:"+ AbstractHelper.getStaticFaultMessage(event));
	alert=MessageBox.show("Application Error (Error Number: S/DS/0002-" + event.fault.errorID + ")\nPlease contact A-VIEW Administrator.", "ERROR", MessageBox.MB_OK, this.parent as Sprite);
}
private function removedata():void{
	unloadContextMenuData();
	hideContextMenuList();
}
/**
 * for unloading  the current loaded document from documnet sharing container
 *
 */
private function unloadDocument():void{
	
	applicationType::DesktopWeb{
		isLoadDoc=false;
		//trace("LoadDocument Bool"+isLoadDoc);
		isPresnter=false;
		if(isVThumb||isHThumb){
		removeThumnail();
		hideThumbNail();
		isVThumb=false;
		isHThumb=false;
		setTimeout(unloadDocument,1000);
		return;
		}
		//ispringStatus=false;
		unloadContextMenuData();
		hideContextMenuList();
		
		applicationType::web{
			//p2fContainer.content is always null. So we changed the check
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording && (pptLoaded || p2fLoaderObj.numChildren > 0)){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addUnloadEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime());
			}
		}
		applicationType::desktop{
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording && (pptLoaded || p2fContainer.content != null)){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.docRecorder.addUnloadEvent(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime());
			}
		}	
		/*viewerCurrentPageLabel.visible=false;
		lblPageSt.visible=false;*/
		infoBarWidth=0;
		currentFileName=null;
	}
	//removeAnnotationTools();
	if(isAnnotationToolRmoved)
	{
		//highlightTool.enabled=false;
		//penTool.enabled=false;
		applicationType::DesktopWeb{
			penTool.setStyle("imageSkin",pencilDefault);
			highlightTool.setStyle("imageSkin",annotate_markerDefault);
		}
		
	}
	applicationType::mobile{
		//To close the information callout.
		closeInfoCallout();
	}
	if (userRole != Constants.PRESENTER_ROLE){		
		loadCompletedFlag=true;	
		currentPage=0;
		totalPages=0;
		removeAnnotation();
		//removeAnnotationTools();
		removeAnnotationTools();
		applicationType::DesktopWeb {
			
			btnImgDownload.enabled=false;
			entPage.enabled=false;
		}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		applicationType::web{
			//Unload the document.
			p2fLoaderObj.removeChildren(0);
			//Fix for issue #17158
			p2fCanvas.visible=false;
			//For Web:Removed pptLoaded check to avoid document is not getting loaded issue when Presenter enable pointer and navigates and again load a dcoument.
			if (pointerShape){
				removePointer();
			}
		}
		applicationType::DesktopMobile{
			if(p2fContainer!=null){
				p2fContainer.unloadAndStop();
			}
			if (pointerShape && pptLoaded){
				removePointer();
			}
		}		
		presenterMousePointer=false;
		isDownloadPermission=false
		applicationType::DesktopWeb{
			if (!pptLoaded)
				p2fContainer.removeChildren();
		}
	}
	else{		
		currentPage=new Number();
		applicationType::DesktopWeb{
		/*	if (pointerShape && pptLoaded){
				removePointer();
			}*/	
			/*if (mousePointerShare != mousePointerEnable){
				var ev:Event;
				applicationType::DesktopWeb{
					teacherMouseShare(ev);
				}
				applicationType::mobile{
					FlexGlobals.topLevelApplication.docTool.btnDocument.dispatchEvent(new DocumentActionEvent(DocumentActionEvent.ENABLE_MOUSE_POINTER));
				}
			}*/
			isNeedRemoveAnnotation=true;
			removeAnnotationTools();
			btnImgUnload.enabled=false;
			entPage.enabled=false;
			btnImgDownload.enabled=false;
			nextBtn.enabled=false;
			prevBtn.enabled=false;
			chkBoxPermission.selected=false;
			chkBoxPermission.enabled=false;
			ispringStatus=false;
		}
		totalPages=new Number();			
		applicationType::web{
			//Unload the document.
			p2fLoaderObj.removeChildren(0);
			//Fix for issue #17158
			p2fCanvas.visible=false;
		}
		applicationType::DesktopMobile{
			p2fContainer.unloadAndStop();			
		}
		p2fContainer.visible=false;
		controlButtonsIsEnable(true);
		if (mousePointerShare != mousePointerEnable){
			var ev:Event;
			applicationType::DesktopWeb{
				teacherMouseShare(ev);
			}
			applicationType::mobile{
				FlexGlobals.topLevelApplication.docTool.btnDocument.dispatchEvent(new DocumentActionEvent(DocumentActionEvent.ENABLE_MOUSE_POINTER));
			}
		}
		mousePointerShare=mousePointerEnable;			
		//if(!isRefresh)
		clearServer();
		documentUnloadEventLog(remoteFilePath);
	}
	remoteFileName="";
	//temFilePath=remoteFilePath;
	remoteFilePath="";
	localSFPFilePath=""
	previousRemoteFilePath="";
	permissionStatus="";
	applicationType::DesktopWeb{
		permissionMsg.visible=false;
		permissionMsgStudent.visible=false;	
		//trace("Unload");
		if (Log.isDebug()) log.debug("unload: iSpringContainer Width:"+iSpringContainer.width+"iSpringContainer Height"+iSpringContainer.height+"iSpringContainer Height"+iSpringContainer.height+"Ispring width:"+iSpringWidth+"IspringHeight:"+iSpringHeight);
//	trace("unload: iSpringContainer Width:"+iSpringContainer.width+"iSpringContainer Height"+iSpringContainer.height+"iSpringContainer Height"+iSpringContainer.height+"Ispring width:"+iSpringWidth+"IspringHeight:"+iSpringHeight);
		docCanvas.visible=false;
	}
	applicationType::mobile{
		if(docCanvas!=null){
			docCanvas.visible=false;
		}
	}
	if (isAnnotationToolRmoved){
		removeAnnotation();
		isAnnotationToolRmoved=false
	}
	applicationType::DesktopWeb{
		if (isISpringFile(fileExtention)){
			iSpringContainer.unload();
			iSpringContainer.visible=false;
			pptLoaded=false;
			removeComponent(containerStack, iSpringCanvas);
			addComponent(containerStack, p2fCanvas);
			
		}
		fileLoad.visible=false;
		if (Log.isDebug()) log.debug("unload: P2fCondainer Width:"+p2fContainer.width+"p2fContainer Height"+p2fContainer.height+"p2fContainer width:"+p2fWidth+"p2fHeight:"+p2fHeight);
		//trace("unload: p2fContainer Width:"+p2fContainer.width+"p2fContainer Height"+p2fContainer.height+"p2fContainer width:"+p2fWidth+"p2fHeight:"+p2fHeight);
		vHideBtn.visible =false;
		hHidebtn.visible =false;
	}
	applicationType::mobile{
		//MOBILE_ISPRING:
		/*if (isISpringFile(fileExtention)){
			hideStageWebView();
			iSpringContainer.visible=false;
			pptLoaded=false;
		}else{*/
			//To set visibilty of document border and remove content from SwfLoader
			documentBorder.visible = false;
			if(p2fContainer!=null){
				p2fContainer.source = null;
				p2fContainer.load(null);
			}
			//Disable document info and menu button, when presenter unloads document.
			if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				FlexGlobals.topLevelApplication.docTool.btnPresenterDocumentDetails.enabled = false;
				FlexGlobals.topLevelApplication.docTool.btnPresenterMenu.enabled = false;
			}else{
				FlexGlobals.topLevelApplication.docTool.btnViewerDocumentDetails.enabled = false;
				FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled = false;
			}
		//}
	}
	//scaleDocument(zoomFactorX, zoomFactorY, p2fWidth - 45, p2fHeight, p2fContainer.contentWidth, p2fContainer.contentHeight);
}
/**
 *
 * @private
 * Audits the "DocumentUnload" action, when the presenter unloads the document
 *
 * @param url of the document
 * @return void
 *
 */
private function documentUnloadEventLog(url:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.documentUnload, url, null, null);
	}
}

private function removePointer():void
{
	uiComp.removeChild(pointerShape);
	pointerShape=null;
}

/**
 * For to clear the users_so shared object when application is closed.
 */
public function clearServer():void{
	if (userRole == Constants.PRESENTER_ROLE){
		if (Log.isDebug()) log.debug("clearServer: clearProperties is called. userRole:" + userRole);
		if(!isRefresh) documentCollaborationObject.removeAllValues();
	}
}    

/**
 * For remove all the Event listners from p2f container.
 */
public function removeEventHandlers():void   
{
	if (p2fContainer){
		if (p2fContainer.hasEventListener(ProgressEvent.PROGRESS)) p2fContainer.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
		if (p2fContainer.hasEventListener(Event.COMPLETE)) p2fContainer.removeEventListener(Event.COMPLETE, bytesDownloaded);
		if (p2fContainer.hasEventListener(IOErrorEvent.IO_ERROR)) p2fContainer.removeEventListener(IOErrorEvent.IO_ERROR, IOStatusListener);
		if (p2fContainer.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) p2fContainer.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	}
	removeIspringEventListners()
}

/**
 * For remove all the Event listners from ispring container.
 */
private function removeIspringEventListners():void{
	if (iSpringSlideControler){
		if (iSpringSlideControler.hasEventListener(SlidePlaybackEvent.CURRENT_SLIDE_INDEX_CHANGED))
			iSpringSlideControler.removeEventListener(SlidePlaybackEvent.CURRENT_SLIDE_INDEX_CHANGED, SlideChangedEvent);
		if (iSpringSlideControler.hasEventListener(StepPlaybackEvent.ANIMATION_STEP_CHANGED))
			iSpringSlideControler.removeEventListener(StepPlaybackEvent.ANIMATION_STEP_CHANGED, AnimationChange)
		if (this && this.hasEventListener(KeyboardEvent.KEY_DOWN))
			this.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardActionHandler)
	}
}
/**
 * function for closing the connections when the application is closed
 */
public function close_doc():void{	
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.DocumentIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.Document_unclicked;
	}
		if (fileManager)fileManager=null;
		if (p2fContainer.content == null &&!pptLoaded )
		{
			onDocResize();
		}
		applicationType::mobile{
		//trace("window closing");
		FlexGlobals.topLevelApplication.DocumentIcon=FlexGlobals.topLevelApplication.Document_unclicked;
	}
}
/**
 * For Creating UI component for Annotation drawings
 * @param fillColor of uint
 * @param fillAlpha of Number
 * @param width of Number
 * @param height of Number
 * @return UIComponent
 * 
 */
private function createUIComponent(fillColor:uint,fillAlpha:Number,width:Number,height:Number):UIComponent{
	uiComp=new UIComponent();
	uiComp.graphics.beginFill(fillColor, fillAlpha);
	uiComp.graphics.drawRect(uicompX, uicompY,width,height);
	return uiComp;
}
/**
 * for clear the Grabage collection
 */
private function cleanGrabageCollector():void{
	flash.system.System.gc();
	flash.system.System.gc();
	flash.system.System.gc();
	flash.system.System.gc();
}

/**
 * for creating poinetr shape for Mousepoint sharing 
 * @return Shape
 * 
 */
private function createPointerShape():Shape{
	pointerShape=new Shape();
	pointerShape.graphics.beginFill(0xFF0000, .5);
	pointerShape.graphics.lineStyle(1, 0xFF0000, .5);
	pointerShape.graphics.drawCircle(15, 15, 15);
	pointerShape.graphics.endFill();
	return pointerShape;
}
/**
 * for setting the UIcomponent width height 
 */
private function setUIcomponentDisplay(width:Number,height:Number):void{
	uiComp.width=width;
	uiComp.height=height;
}
/**
 * for setting the document loader properties
 */
private function setLoaderProperties(obj:Object):void{
	if(pptLoaded){
		iSpringWidth=obj.width;
		iSpringHeight=obj.height;
		return;
	}	
	p2fWidth=obj.width;
	p2fHeight=obj.height;	
}
    
private function unloadContextMenuData():void{
	if (contextMenuList){
		contextMenuList.dataProvider=null;
		contextMenuArray=null;
		contextMenuList.visible=false;
	}
}
applicationType::mobile{
	/**
	 * @private
	 *
	 * To enable the fileManager button, based on the user Type
	 *
	 * @param event of Event
	 * @return void
	 */
	private function modifyCalloutVisibility(event:Event):void{
		if (userRole == Constants.PRESENTER_ROLE){
			FlexGlobals.topLevelApplication.docTool.btnDocument.enabled=true;
		}else{
			FlexGlobals.topLevelApplication.docTool.btnViewerDocument.enabled=true;
		}
	}
}
import spark.events.TitleWindowBoundsEvent;


private function handleDown(e:Event):void{
	applicationType::DesktopWeb{
		toolBarPanel.startDrag();
		toolBarPanel.addEventListener(MouseEvent.MOUSE_MOVE,toolbarMoveHandler);
	}
}
private function handleUp(e:Event):void{
	applicationType::DesktopWeb{
		toolBarPanel.stopDrag();
	}
}

public function toolbarMoveHandler(e:MouseEvent=null):void
{
	applicationType::DesktopWeb{
		//Fix for Bug#18497:Start
		if(toolBarPanel)
		{
			//trace("presenterControls.x"+ toolBarPanel.x+toolBarPanel.width);
			//trace("presenterControls.y"+ toolBarPanel.y+toolBarPanel.height);
			//trace("wb.width"+ this.width);
			//trace("wb.height"+ this.height);
			
			var val:Number;
			//checking with the x position and width 
			if (toolBarPanel.x < 0)
			{
				toolBarPanel.x=0;
				toolBarPanel.stopDrag();
			}
			if ((toolBarPanel.x + toolBarPanel.width) > this.width) {
				val=0;
				val=(toolBarPanel.x + toolBarPanel.width) - this.width;
				toolBarPanel.x=toolBarPanel.x - val;
				toolBarPanel.stopDrag();
			}
			//checking with the y position and height 
			if (toolBarPanel.y < 0)
			{
				toolBarPanel.y=0;
				toolBarPanel.stopDrag();
			}
			if ((toolBarPanel.y + toolBarPanel.height) > this.height) {
				val=0;
				val=(toolBarPanel.y + toolBarPanel.height) - this.height;
				toolBarPanel.y=toolBarPanel.y - val;
				toolBarPanel.stopDrag();
			}
		}
		//Fix for Bug#18497:End
	}
}

private var isMaximized:Boolean = false;
[Bindable]
private var compHeight:int =0;
private function showhide():void
{
	applicationType::DesktopWeb{
		if(controlStack.selectedIndex==0)
			compHeight = 368;
		else
			compHeight = 97;
		if(!isMaximized)
		{
			isMaximized = true;
			
			toolBarPanel.height=70; 
			controlStack.visible=false;
		    toolBar.visible=true;
			/*showhideButton.setStyle("",rotate);*/
			rotate.play();
			showhideButton.toolTip="Show toolbar";
		}
		else
		{
			showhideButton.toolTip="Hide toolbar";
			isMaximized = false;
			toolBarPanel.height=compHeight;
			controlStack.visible=true;
			toolBar.visible=false;
			/*showhideButton.setStyle("",rotate1);*/
			/*rotate.play();*/
			rotate1.play();
			toolbarMoveHandler();
		}
	}
}
private function showHideThumbnailMenu():void
{
	applicationType::DesktopWeb{
		if(thumbnailMenuContainer.visible==true)
		{
			thumbnailMenuContainer.visible = false;
			toolBoxMenuOpened=false;
		}
		else
		{
			thumbnailMenuContainer.visible = true;
			menuOpenTimout=setTimeout(setFlagValueforMenu, 100);
		}
	}
	
	
}

private function setFlagValueforMenu():void
{
	toolBoxMenuOpened=true;
}
private function setActiveAnnotationTool(toolName:String):void
{
	switch(toolName)
	{
		case 'Pen':
			applicationType::DesktopWeb{
				eraserTool.enabled=true;
				highlightTool.enabled=true;
				penTool.enabled=false;
			}
			break;
		case 'Highlight':
			applicationType::DesktopWeb{
				eraserTool.enabled=true;
				highlightTool.enabled=false;
				penTool.enabled=true;
			}
			break;
		case 'Eraser':
			applicationType::DesktopWeb{
				eraserTool.enabled=false;
				highlightTool.enabled=true;
				penTool.enabled=true;
			}
			break;
	}
	
}
/**
 * @public 
 * Replacing the special charactor from filename
 * @param fileFolder of type String
 * @param parent of type Sprite
 * @return string
 * 
 */
public static function replaceSpecialChars(fileFolder:String):String
{
	// AKCR: instead of arrays, can you use a HashMap? This will avoid the inner for loop
	var special:Boolean=false;
	for (var a:int=0; a < fileFolder.length; a++)
	{
		for (var b:int=0; b < spclCharArray.length; b++)
		{
			if (fileFolder.charAt(a) == spclCharArray[b])
			{
				fileFolder=fileFolder.replace(fileFolder.charAt(a), "_");
				special=true;
			}
		}
	}
	return fileFolder;
}
private function unloadConfirmation(passedEvent:Object):void
{
	var event = passedEvent as MessageBoxEvent;
	if (event.type == "messageBoxYES")
		unloadDocument();
	
}

public function uploadDocument():void
{
	
	if(p2fContainer.content == null && !pptLoaded)
	{
		progressBar=new ProgressBar();
		progressBar.height=20;
		progressBar.horizontalCenter=0;
		progressBar.verticalCenter=0
		progressBar.indeterminate=true;
		progressBar.labelPlacement="center";
	//progressBar.setStyle("barColor",0x00FF00);
		progressBar.setStyle("chromeColor",'#2a5ea4');
		progressBar.setStyle("color","#FFFFFF");
		this.addElement(progressBar);
		progressBar.label="Uploading.....";
		isProgressBarPresent=true;
	}
	
}
	