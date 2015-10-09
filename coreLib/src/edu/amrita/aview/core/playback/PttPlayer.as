package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.playback.components.VideoComp;
	import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	
	import mx.core.mx_internal;
	import mx.olap.aggregators.AverageAggregator;

	
	public class PttPlayer extends EventDispatcher
	{
		private var pVideo:VideoComp;
		private var vVideo:VideoComp;
		private var condolidateXml:ConsolidateXmlBuilder;
		private var videoVolume:SoundTransform
		private var contextSetter:ContextSetter;
		public function PttPlayer(pVideo:VideoComp,vVideo:VideoComp,condolidateXml:ConsolidateXmlBuilder,contextSetter:ContextSetter)
		{
			this.pVideo=pVideo;
			this.vVideo=vVideo;
			this.condolidateXml=condolidateXml;
			this.contextSetter=contextSetter;
			
		}
		public function setContext(playHeadTime:Number):void
		{
			var xml:XML=contextSetter.setPttContext(playHeadTime);
			if(xml.state.length()>0)
				setPtt(xml.state[0].@state,xml.state[0].@isPresenter);
			else
				setPtt(Constants.FREETALK,"false");
		}
		private function mutePresenter():void
		{
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.MUTE_PRESENTER_STREAM);
			dispatchEvent(evnt);
		}
		private function unMutePresenter():void
		{
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.UNMUTE_PRESENTER_STREAM);
			dispatchEvent(evnt);
		}
		private function unMuteViewer():void
		{
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.UNMUTE_VIEWER_STREAM);
			dispatchEvent(evnt);
			
		}
		private function muteViewer():void
		{
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.MUTE_VIEWER_STREAM);
			dispatchEvent(evnt);
		}
		private function setPtt(state:String,isPresenter:String):void
		{
			
			if(state==Constants.FREETALK)
			{
				unMutePresenter();
				unMuteViewer();
			}
			else if(state=="")
			{
				mutePresenter();
				unMuteViewer();
			}
			else
			{
				if(isPresenter=="true")
				{
					unMutePresenter();
					muteViewer();
				}
				else
				{
					mutePresenter();
					unMuteViewer();
				}
			}
		}
		public function playPtt(time:Number):void
		{
			var xml:XML=condolidateXml.getDataAtTime(time,"ptt");
			var elements:XMLList=xml.elements();
			for(var i:Number=0;i<elements.length();i++)
			{
				setPtt(elements[i].@state,elements[i].@isPresenter);
			}
		}
	}


}
