////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: Icons.as
 * Module		: Common
 * Developer(s)	: 
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-Add Developers name
//VGCR:-Add description


/**Busy cursor */
[Embed(source="assets/flash/cursor_5.swf")]
public var busyImg:Class;


[Bindable]
[Embed(source="assets/images/breakSession_Icon.png")]
public var breakSession_icon:Class;


/**Chat Icon*/
[Bindable]
[Embed(source="assets/images/chatUnselect.png")]
public var Chat_unclicked:Class;

[Bindable]
[Embed(source="assets/images/chatSelected.png")]
public var Chat_clicked:Class;
[Bindable]
public var ChatIcon:Class;

[Bindable]
[Embed(source="assets/images/acceptViewer.png")]
public var AcceptingIcon:Class;

[Bindable]
[Embed(source="assets/images/rel.png")]
public var ReleaseIcon:Class;

[Bindable]
[Embed(source="assets/images/releaseViewer.png")]
public var HandraiseReleaseIcon:Class;

[Bindable]
[Embed(source="assets/images/releaseViewer.png")]
public var releaseViewerIcon:Class;

[Bindable]
[Embed(source="assets/images/webcamera.png")]
public var webcamIcon:Class;

[Bindable]
[Embed(source="assets/images/nowebcam.png")]
public var nowebcamIcon:Class;

[Bindable]
[Embed(source="assets/images/icon.png")]
public var HandraiseIcon:Class;


/**Multipresenter Icons */

[Bindable]
[Embed(source="assets/images/presenter.png")]
public var make_presenter:Class;

[Bindable]
[Embed(source="assets/images/cancel_presenter.png")]
public var take_presenter_ctrl:Class;

[Bindable]
[Embed(source="assets/images/presenter_disabled.png")]
public var disable_presenter:Class;

[Bindable]
[Embed(source="assets/images/addPeople.png")]
public var addUserIcon:Class;



[Bindable]
[Embed(source="assets/images/PushUnmute.png")]
public var pushToTalkUnmute_Icon:Class;

[Bindable]
[Embed(source="assets/images/Pushmute.png")]
public var pushToTalkMute_Icon:Class;

/**
 * Disbled icon for push to talk mic button
 */
[Bindable]
[Embed(source="assets/images/DisabledMic.png")]
private var disabledMicIcon:Class;
