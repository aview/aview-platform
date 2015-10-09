import edu.amrita.aview.core.desktopSharing.DesktopViewer;

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
 * File			: DesktopPlayerHandler.as
 * Module		: DesktopSharing
 * Developer(s)	: Ajith Kumar R, Remya T
 * Reviewer(s)	: Meena S
 *
 *DesktopPlayerHandler.as is used to handle functionalities related to DesktopPlayer custom component.
 *
 */
public var desktopPlayerComp:DesktopViewer;

private function init():void{
	desktopPlayerContainer.addElement(desktopPlayerComp);
	//Fix for issues #15296 and #15522
	desktopPlayerComp.setPlayerPositionAndSize(desktopPlayerContainer.height - 63);
}

/**
 * function for closing the connections when the application is closed
 */
//This is called when user closes desktop sharing window 
public function closeWindow():void{
	applicationType::desktop{
		if (!desktopPlayerComp.desktopSharingWindow.closed && !desktopPlayerComp.isPopOut){
			desktopPlayerComp.popOutDesktopSharingWindow();
		}
		else if(desktopPlayerComp.desktopSharingWindow.closed && desktopPlayerComp.isPopOut){
			desktopPlayerComp.isPopOut=true;
			desktopPlayerComp.isDesktopPlayerWindowClosedManually = true;
			desktopPlayerComp.popOutDesktopSharingWindow();
		}
		//Fix for #20126
		else
		{
			desktopPlayerComp.isDesktopPlayerWindowClosedManually = true;
			desktopPlayerComp.isPopOut=false;
		}
	}
		
}
//Fix for issues #15296 and #15522
private function setPlayerPosition():void{
	desktopPlayerComp.setPlayerPositionAndSize(desktopPlayerContainer.height - 63);
}
//Fix for issue #15296
private function onResize():void{
	setPlayerPosition();
}