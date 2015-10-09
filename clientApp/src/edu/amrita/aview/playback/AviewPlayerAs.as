
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
 * File			: AviewPlayerAs.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * For adding the playback custom player to Main container .
 *
 */
import edu.amrita.aview.playback.components.mui.player;

import mx.core.FlexGlobals;
/**
 * Refers for player class 
 * This player will hanlding all modules in palyback
 */
public var playerComp:player=new player();

//VVCR:  The comment has a star symbol at the end, which is not required.

/**
 * @private
 * For adding the player component to baseContainer *
 *
 * @return void
 *
 */
private function init():void{
	baseContainer.addElement(playerComp);
}

//VVCR:  The comment has a star symbol at the end, which is not required.

/**
 * @public
 * For closing the player component to baseContainer *
 *
 * @return void
 *
 */
public function closePlayback():void{
	playerComp.closePlayer();
}
