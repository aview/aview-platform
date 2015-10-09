////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

//VVCR:Instead of saying this class, it can be more explicit by mentioning the classname. 
/**
 *
 * File			: PttPlayer.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)	: Thirumalai murugan
 * Description:This class used for handling the PushToTalk palyback functionality.
 */

package edu.amrita.aview.playback{
	import flash.events.EventDispatcher;
	
	import flash.media.SoundTransform;
	
	import edu.amrita.aview.playback.events.AviewPlayerEvent;
	import mx.controls.VideoDisplay;
	import edu.amrita.aview.core.entry.Constants;
	
	/**
	 *  You use the PttPlayer class to represent the push to talk Play back.
	 */
	public class PttPlayer extends EventDispatcher{
		/**
		 * This refers for Presenter's video
		 */
		private var pVideo:VideoDisplay;
		/**
		 *  This refers for Viewer's video
		 */
		private var viewerVideo:VideoDisplay;
		/**
		 * Consolidate xml data of PushToTalk playback
		 */
		private var condolidateXml:ConsolidateXmlBuilder;
		/**
		 * This rfers for volume for videos
		 */
		private var videoVolume:SoundTransform
		/**
		 * Context data of PushToTalk playback
		 */
		private var contextSetter:ContextSetter;		
		
		/**
		 * @public
		 * Initilze all data for PushtoTalk paly back
		 * @param presenterVideo of VideoDisplay
		 * @param viewerVideo of VideoDisplay
		 * @param condolidateXml of  ConsolidateXmlBuilder
		 * @param contextSetter of ContextSetter
		 * @return void
		 */
		public function PttPlayer(presenterVideo:VideoDisplay, viewerVideo:VideoDisplay, condolidateXml:ConsolidateXmlBuilder, contextSetter:ContextSetter){
			this.pVideo=presenterVideo;
			this.viewerVideo=viewerVideo;
			this.condolidateXml=condolidateXml;
			this.contextSetter=contextSetter;
			
		}		
		
		/**
		 * @public
		 * This function will invoked on timer time change.
		 * @param playHeadTime of type Number
		 * @return void
		 *
		 */
		public function setContext(playHeadTime:Number):void{
			var xml:XML=contextSetter.setPttContext(playHeadTime);
			if (xml.state.length() > 0)
				setPtt(xml.state[0].@state, xml.state[0].@isPresenter);
			else
				setPtt(Constants.FREETALK, "false");
		}
		
		/**
		 * @private
		 * This function will invoked while the mute operation have been processed at
		 * Presenter video		 * 
		 * @return void
		 */
		private function mutePresenter():void{			
			var event:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.MUTE_PRESENTER_STREAM);
			dispatchEvent(event);
		}
		
		/**
		 * @private
		 * This function will invoked while the un mute operation have been processed at
		 * Presenter video
		 * 
		 * @return void
		 */
		private function unMutePresenter():void{			
			var event:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.UNMUTE_PRESENTER_STREAM);
			dispatchEvent(event);
		}
		
		/**
		 * @private
		 * This function will invoked while the un mute operation have been processed at
		 * Viewer video
		 * 
		 * @return void
		 */
		private function unMuteViewer():void{			
			var event:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.UNMUTE_VIEWER_STREAM);
			dispatchEvent(event);
			
		}
		
		/**
		 * @private
		 * This function will invoked while the  mute operation have been processed at
		 * Viewer video
		 * 
		 * @return void
		 */
		private function muteViewer():void{
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.MUTE_VIEWER_STREAM);
			dispatchEvent(evnt);
		}		
		
		/**
		 * @private
		 * Setting the state of PushtoTalk
		 * @param state of type String
		 * @param isPresenter of type  String
		 * @return void
		 */
		private function setPtt(state:String, isPresenter:String):void{
			
			if (state == Constants.FREETALK){
				unMutePresenter();
				unMuteViewer();
			}
			else if (state == ""){
				mutePresenter();
				unMuteViewer();
			}
			else{
				if (isPresenter == "true"){
					unMutePresenter();
					muteViewer();
				}
				else{
					mutePresenter();
					unMuteViewer();
				}
			}
		}
		
		
		/**
		 * @public
		 * For handling the PushTotalk playback functionality.
		 * @param time of type number
		 * 
		 * @return void
		 */
		public function playPtt(time:Number):void{
			var xml:XML=condolidateXml.getDataAtTime(time, "ptt");
			var elements:XMLList=xml.elements();
			for (var i:Number=0; i < elements.length(); i++){
				setPtt(elements[i].@state, elements[i].@isPresenter);
			}
		}
	}
	
	
}
