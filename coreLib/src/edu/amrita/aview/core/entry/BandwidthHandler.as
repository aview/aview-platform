import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import flash.events.KeyboardEvent;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
*
* File			: BandwidthHandler.as
* Module		: Bandwidth
* Developer(s)	: Vijayakumar.R
* Reviewer(s)	: 
*
* For checking the bandwidth of the classroom
*
*/

/** Variable declarations */
[Bindable]
private var toolTipLnk:String="http://sts010.aview.in:8080/speedtest/index.html";
[Bindable]
private var serverName:String="sts010.aview.in:8080";
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.Setting");

public function initurl():void
{
	urlFetcher.send();
}

protected function exitOnEscape(event:KeyboardEvent):void
{
	// This function is for closing the bandwidth window when pressing on escape button
	if(event.keyCode==27)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.closeBandwidthWindow();
		PopUpManager.removePopUp(this);
	}
	
}




/* This function is to load the speed test web page when the user click the link to test connection speed  */
public function getSpeedTestURLResultHandler(event:ResultEvent):void{
	if(Log.isInfo()) log.info(event.result.tool.Link);
	
	//If single server is used for both content and streaming, then web server would be listening on 80, otherwise on 8080
	var contentServerPort:Number=(ClassroomContext.CONTENT_DOCUMENT == ClassroomContext.VIDEO_RECORD_SERVER) ? Constants.CONTENT_SERVER_PORT : Constants.CONTENT_SERVER_PORT_FIREWALL;
	
	toolTipLnk=encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + contentServerPort + event.result.tool.Link);
	serverName=ClassroomContext.VIDEO_RECORD_SERVER;
	//navigateToURL(new URLRequest(toolTipLnk), "_self");
}

public function getSpeedTestURLFaultHandler(event:FaultEvent):void{
	if(Log.isError()) log.error("video::SettingHandler::getSpeedTestURLFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
}