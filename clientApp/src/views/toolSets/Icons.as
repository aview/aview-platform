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
 * Developer(s)	: Salil George, Ganesan A, Jeevanantham N
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 * 
 * Icon. as used for declaring various icon
 * 
 */

/**
 * User action icons
 */
[Bindable]
[Embed(source="/views/toolSets/assets/button_ok.png")]
public var acceptingIcon:Class;
/**
 * Handraise release icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/rel.png")]
public var releaseIcon:Class;
/**
 * Handraise icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/icon.png")]
public var handRaiseIcon:Class;
/**
 * Handraise Release icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/releaseViewer.png")]
public var HandraiseReleaseIcon:Class;
/**
 * Disabled mic icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/DisabledMic.png")]
private var disabledMicIcon:Class;
/**
 * Unmute mic icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/PushUnmute.png")]
public var pushToTalkUnmuteIcon:Class;
/**
 * Mute icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/Pushmute.png")]
public var pushToTalkMuteIcon:Class;


/**
 * Make presenter icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/presenter.png")]
public var makePresenter:Class;
/**
 * take presenter control icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/cancel_presenter.png")]
public var takePresenterControl:Class;


/**
 * Default pretest icon
 */
[Bindable]
public var preTestIcon:Class;
/**
 * Pretest fail icon
 */
[Embed (source="/views/toolSets/assets/pretest_failed.png")]
public var preTestFailedIcon:Class;
/**
 * Pretest pass icon
 */
[Embed (source="/views/toolSets/assets/pretest_success.png")]
public var preTestPassedIcon:Class;
/**
 * Pretesting icon
 */
[Embed (source="/views/toolSets/assets/pretest.png")]
public var preTestNormalIcon:Class;

/**
 * Aview logo
 */
[Bindable]
[Embed(source="/views/assets/aview_logo.png")]
public var defaultBanner:Class; 

/**
 * Break session icon
 */
[Bindable]
[Embed(source="/views/toolSets/assets/breakSession_Icon.png")]
public var breakSessionIcon : Class ;

/**
 * Exit icon
 */
[Bindable]
[Embed (source="/views/toolSets/assets/application_exit_24x24.png")]
public var exitIcon:Class;

/**
 * Help icon
 */
[Bindable]
[Embed (source="/views/assets/help_24x24.png")]
public var helpIcon:Class;

/**
 * Change password icon
 */
[Bindable]
[Embed(source="/views/assets/password_edit.png")]
public var changePassword:Class;

/**
 * Refresh password icon
 */
[Bindable]
[Embed(source="/views/assets/refreshx30.png")]
public var refreshVideoIcon:Class;
