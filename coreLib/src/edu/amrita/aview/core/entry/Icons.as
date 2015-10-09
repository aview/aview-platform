//Virtual class room Icon
[Bindable]
[Embed(source="assets/images/classroom_unclicked.png")]
public var VirtualClass_unclicked:Class;

[Bindable]
[Embed(source="assets/images/classroom_clicked.png")]
public var VirtualClass_clicked:Class;
[Bindable]
public var VirtualClass:Class;


// Library Icon
[Bindable]
[Embed(source="assets/images/library_unclicked.png")]
public var Library_unclicked:Class;

[Bindable]
[Embed(source="assets/images/library_clicked.png")]
public var Library_clicked:Class;
[Bindable]
public var LibraryIcon:Class;

// Biometric Icon
[Bindable]
[Embed(source="assets/images/biometric_unclicked.png")]
public var Biometric_unclicked:Class;

[Bindable]
[Embed(source="assets/images/biometric_clicked.png")]
public var Biometric_clicked:Class;
[Bindable]
public var BiometricIcon:Class;

//Document Icon 
[Bindable]
[Embed(source="assets/images/docUnselect.png")]
public var Document_unclicked:Class;

[Bindable]
[Embed(source="assets/images/docClicked.png")]
public var Document_clicked:Class;
[Bindable]
public var DocumentIcon:Class;

//Busy cursor
[Embed(source="assets/flash/cursor_5.swf")]
public var busyImg:Class;


//Administration Icon 
[Bindable]
[Embed(source="assets/images/setup_unclicked.png")]
public var Administration_unclicked:Class;

[Bindable]
[Embed(source="assets/images/setup_clicked.png")]
public var Administration_clicked:Class;
[Bindable]
public var AdministrationIcon:Class;

//Preference Icon 
[Bindable]
[Embed(source='assets/images/quicknote_clicked.png')]
public var quickNoteIcon_Clicked:Class;
[Bindable]
[Embed(source='assets/images/quicknote_unclicked.png')]
public var quickNoteIcon_UnClicked:Class;
[Bindable]
public var quickNoteIcon:Class=quickNoteIcon_UnClicked;


[Bindable]
[Embed(source="assets/images/Settings.png")]
public var Preference_unclicked:Class;

[Bindable]
[Embed(source="assets/images/perfer.png")]
public var Preference_clicked:Class;
[Bindable]
public var PreferenceIcon:Class;

//Video Icon 
[Bindable]
[Embed(source="assets/images/videoUnselect.png")]
public var Video_unclicked:Class;

[Bindable]
[Embed(source="assets/images/videoSelected.png")]
public var Video_clicked:Class;
[Bindable]
public var VideoIcon:Class;

//Whiteboard Icon 
[Bindable]
[Embed(source="assets/images/whiteboardUnselect.png")]
public var Whiteboard_unclicked:Class;

[Bindable]
[Embed(source="assets/images/whiteboardClkd.png")]
public var Whiteboard_clicked:Class;
[Bindable]
public var WhiteboardIcon:Class;

//3DViewer Icon 
[Bindable]
[Embed(source="assets/images/3DUnselect.png")]
public var Viewer3D_unclicked:Class;
[Bindable]
[Embed(source="assets/images/3DClicked.png")]
public var Viewer3D_clicked:Class;
[Bindable]
public var ViewerIcon3D:Class=Viewer3D_unclicked;

//2DViewer Icon 
[Bindable]
[Embed(source="assets/images/2DUnselect.png")]
public var Viewer2D_unclicked:Class;
[Bindable]
[Embed(source="assets/images/2DClicked.png")]
public var Viewer2D_clicked:Class;
[Bindable]
public var ViewerIcon2D:Class=Viewer2D_unclicked;

//VideoShare Icon
[Bindable]
[Embed(source="assets/images/videoshareUnselect.png")]
public var vidShare_unclicked:Class;
[Bindable]
[Embed(source="assets/images/vidshareClicked.png")]
public var vidShare_clicked:Class;
[Bindable]
public var vidShareIcon:Class=vidShare_unclicked;

//LiveQuiz
[Bindable]
[Embed(source="assets/images/quizUnselect.png")]
public var liveQuiz_unclicked:Class;
[Bindable]
[Embed(source="assets/images/quizSelected.png")]
public var liveQuiz_clicked:Class;
[Bindable]
public var LiveQuizIcon:Class=liveQuiz_clicked;

//Polling
[Bindable]
[Embed(source="assets/images/pollUnselect.png")]
public var poll_unclicked:Class;
[Bindable]
[Embed(source="assets/images/pollSelected.png")]
public var poll_clicked:Class;
[Bindable]
public var pollingIcon:Class=poll_clicked;


[Bindable]
public var PublishIcon:Class;


[Bindable]
[Embed(source="assets/images/title image.png")]
public var defaultBanner:Class;

private var soundClass:Class;


//Classroom Icons
[Bindable]
[Embed(source="assets/images/hidePanel.png")]
public var hideVideoPannel:Class;

[Bindable]
[Embed(source="assets/images/hidePanel.png")]
public var hideVideoPannel_select:Class;

[Bindable]
[Embed(source="assets/images/showPanel.png")]
public var unHideVideoPannel:Class;

[Bindable]
[Embed(source="assets/images/showPanel.png")]
public var unHideVideoPannel_select:Class;

[Bindable]
public var imgMultiViewer:Class;

[Bindable]
[Embed(source="assets/images/video_wall_maximize.png")]
public var imgMultiViewerMaximize:Class;

[Bindable]
[Embed(source="assets/images/video_wall_minimize.png")]
public var imgMultiViewerMinimize:Class;

[Bindable]
[Embed(source="assets/images/videoList.png")]
public var multiVideoList:Class;

[Bindable]
[Embed(source="assets/images/videowall_25_clicked.png")]
public var multiVideoWall:Class;

[Bindable]
[Embed(source="assets/images/video_wall_Active.png")]
public var multiVideoWallActive:Class;

[Bindable]
[Embed(source="assets/images/videowall_disabled.png")]
public var multiVideoWallDisable:Class;

//Record Icon

[Bindable]
[Embed(source="assets/images/rec.png")]
public var StartRecordIcon:Class;

[Bindable]
[Embed(source="assets/images/stop.png")]
public var StopRecordIcon:Class;

[Bindable]
[Embed(source="assets/images/recordIndicator.png")]
public var RecordIndicatorIcon:Class;

[Bindable]
public var RecordIcon:Class;


[Embed(source="assets/images/Start Video (32).png")]
public var startIcon:Class;

[Embed(source="assets/images/Stop Video (32).png")]
private var stopIcon:Class;

[Bindable]
public var startStopToggleIcon:Class;



//Settings Button
[Bindable]
[Embed(source="assets/images/settingsUnselect.png")]
public var settings_unselect:Class;

[Bindable]
[Embed(source="assets/images/settingsSelect.png")]
public var settings_select:Class;

[Bindable]
public var settingsIcon:Class=settings_unselect;

//My video Icon
[Bindable]
[Embed(source="assets/images/My video.png")]
public var myVideo_Icon:Class;

[Bindable]
[Embed(source="assets/images/My Video_disabled.png")]
public var myVideo_disabled:Class;

//Share Desktop
[Bindable]
[Embed(source="assets/images/desktopUnselect.png")]
public var share_Desktop:Class;

[Bindable]
[Embed(source="assets/images/desktopStop.png")]
public var stop_Sharing:Class;

[Bindable]
[Embed(source="assets/images/desktopUnselect.png")]
public var share_Desktop_Multi:Class;

[Bindable]
[Embed(source="assets/images/desktopStop.png")]
public var stop_Sharing_Multi:Class;


[Bindable]
[Embed(source="assets/images/desktop sharing.png")]
private var show_Desktop_IconClass:Class;

[Bindable]
[Embed(source="assets/images/desktopUnselect.png")]
public var show_DesktopUnselect:Class;

[Bindable]
[Embed(source="assets/images/desktopStop.png")]
public var show_DesktopSelect:Class;

[Bindable]
public var show_Desktop_IconClass_Multi:Class=show_DesktopUnselect;

[Bindable]
public var share_Desktop_IconClass:Class;

[Bindable]
public var share_Desktop_IconClass_Multi:Class;

//youtubeLive icons
[Bindable]
public var youtubelive_IconClass:Class;

[Bindable]
[Embed(source="assets/images/youtube.png")]
public var youtubeliveStart:Class;

[Bindable]
[Embed(source="assets/images/youtubeLiveStop.png")]
public var youtubeliveStop:Class;

//Bug report icon
[Bindable]
[Embed(source="assets/images/feedback_unclicked.png")]
public var feedback_unclicked:Class;

[Bindable]
[Embed(source="assets/images/feedback_clicked.png")]
public var feedback_clicked:Class;

[Bindable]
public var Feedback_icon:Class;

//Help Icon
[Bindable]
[Embed(source="assets/images/Help(selected).png")]
public var helpselect_icon:Class;
[Bindable]
[Embed(source="assets/images/Help.png")]
public var unhelp_icon:Class;
[Bindable]
public var Help_icon:Class=unhelp_icon;

//Quiz Icon
[Bindable]
[Embed(source="assets/images/quiz_unclicked.png")]
public var Quiz_unclicked:Class;

[Bindable]
[Embed(source="assets/images/quiz_clicked.png")]
public var Quiz_clicked:Class;

[Bindable]
[Embed(source="assets/images/quiz_unclicked.png")]
public var EvaluationIcon:Class;

//Live Quiz Icon
[Bindable]
[Embed(source="assets/images/Live Quiz.png")]
public var LiveQuiz_unclicked:Class;


//Meeting Icon
[Bindable]
[Embed(source="assets/images/MeetingIcon.png")]
public var Meeting_unclicked:Class;
[Bindable]
[Embed(source="assets/images/MeetingDisabledIcon.png")]
public var Meeting_clicked:Class;

[Bindable]
public var MeetingIcon:Class

//chatHistory Icon
[Bindable]
[Embed(source="assets/images/chatUnselect.png")]
public var chatHistory_unclicked:Class;
[Bindable]
[Embed(source="assets/images/chatSelected.png")]
public var chatHistory_clicked:Class;

[Bindable]
public var chatHistoryIcon:Class

//lecture refresh button
[Bindable]
[Embed(source="assets/images/refresh.png")]
public var lectureRefresh_Icon:Class;

[Bindable]
[Embed(source="assets/images/refreshOver.png")]
public var lectureRefreshOver_Icon:Class;

[Bindable]
public var lectureRefreshIcon:Class=lectureRefresh_Icon;

//end session Icon
[Bindable]
[Embed(source="assets/images/endMeeting_active.png")]
public var endSessionActive_Icon:Class;

[Bindable]
[Embed(source="assets/images/endMeeting_inactive.png")]
public var endSessionInactive_Icon:Class;

[Bindable]
public var endSessionIcon:Class=endSessionInactive_Icon;

[Bindable]
[Embed(source="edu/amrita/aview/core/entry/assets/images/secureIcon.png")]
public var secure_Icon:Class;
[Bindable]
[Embed(source="edu/amrita/aview/core/entry/assets/images/infoIcon.png")]
public var info_Icon:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/resizeCursor.png")]
public var resizeCursorSymbol:Class;


[Embed(source="/edu/amrita/aview/core/entry/assets/images/startVideo.png")]
public var startVideoIcon:Class;

[Embed(source="/edu/amrita/aview/core/entry/assets/images/stopVideo.png")]
private var stopVideoIcon:Class;

[Bindable]
public var startStopVideoToggleIcon:Class;
//Record Icon

[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/startRecord.png")]
public var startRecordIcon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/stopRecord.png")]
public var stopRecordIcon:Class;

[Bindable]
public var recordIcon:Class;

//Mute Icon

[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/mute.png")]
public var  muteIcon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/unmute.png")]
public var unMuteIcon:Class;

[Bindable]
public var muteUnmuteToggleIcon:Class;
