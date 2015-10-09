import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.setTimeout;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;


public var menuOpened:Boolean;
private var menuOpenTimout:uint;

protected function component_creationCompleteHandler(event:FlexEvent):void
{
	// TODO Auto-generated method stub
	menuOpenTimout=setTimeout(init,100);
}

public function init():void
{
	menuOpened=true;
}
public function navigateurl(str:String):void {
	var linkName:String='';
	switch (str) {
		case 'contactUs':  {
			linkName="http://aview.in/contact-us";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'intro':  {
			linkName="http://www.youtube.com/v/gIi3b25eKes&hl=en&fs=1&rel=0&autoplay=1";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'howToGuide':  {
			linkName="http://www.youtube.com/v/PhCwBJ2i-5k&hl=en&fs=1&rel=0&autoplay=1";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'publicLeacture':  {
			linkName="http://aview.in/upcoming-events";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'latestNews':  {
			linkName="http://aview.in/news";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'newFeatures':  {
			linkName="http://aview.in/a-view-new-features";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'aboutAview':  {
			linkName="http://aview.in/aview";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
		case 'releasenote':  {
			linkName="http://aview.in/releases/4.0/release-overview";
			var url1:URLRequest=new URLRequest(linkName);
			navigateToURL(url1, "_blank");
			break;
		}
	}
}