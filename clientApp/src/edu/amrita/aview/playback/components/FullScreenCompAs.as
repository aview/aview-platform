//VVCR: add file descirption copyright notice and asdoc style comments
import edu.amrita.aview.playback.components.ChatCom;
import edu.amrita.aview.playback.components.VideoComp;


public var videoComp:VideoComp
public var chatComp:ChatCom;
private function init():void
{
	if(videoComp)
	{
		videoComp.percentHeight=100;
		videoComp.percentWidth=100;
		this.addChild(videoComp);
		videoComp.x=0;
		videoComp.y=0;
	}
	if(chatComp)
	{
		chatComp.percentHeight=100;
		chatComp.percentWidth=100;
		this.addChild(chatComp);
		chatComp.x=0;
		chatComp.y=0;
	}
}

