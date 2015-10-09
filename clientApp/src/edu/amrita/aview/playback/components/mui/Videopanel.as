
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
 * File			: VideoPanel.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:VideoPanel class used for creating custom videodisply for video playback functionality.
 */
package edu.amrita.aview.playback.components.mui
{
	
	import flash.events.MouseEvent;
	
	import edu.amrita.aview.playback.events.ClickEvent;
	
	import mx.core.UIComponent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	
	
	/**
	 * VideoPanel class used for creating custom videodisply for video playback functionality
	 * @author haridasanpc
	 * 
	 */
	public class Videopanel extends UIComponent
	{
		/**
		 * _palyer is a object of MediaPlayer for interaction with all media types
		 */
		private var _player:MediaPlayer;
		/**
		 * _container is a object of MediaContainer
		 */
		private var _container:MediaContainer;
		/**
		 * _source is the video path of _player.This source will loaded to _player
		 */
		private var _source:String;
		/**
		 * _element is a  object of MediaElement.It may consist of a simple media item, such as a video or a sound
		 */
		private var _element:MediaElement;
		/**
		 * __mediaFactory is a  object of DefaultMediaFactory.
		 */
		private var _mediaFactory:DefaultMediaFactory;
		
		//GTMCR:: change Contructor to Constructor and describe what its doing
		/**
		 *Contructor
		 *
		 */
		public function Videopanel()
		{
			super();
			percentHeight=100;
			percentWidth=100;
		
		
		}		
		
		/**
		 * @protected
		 * This function for creating custom component to UIComponent
		 * @return void
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			_mediaFactory=new DefaultMediaFactory();
			_player=new MediaPlayer();
			_player.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			_container=new MediaContainer();
			addChild(_container);
			if (_source)
			{
				playMedia();
			}						
			_container.addEventListener(MouseEvent.CLICK, dispatchMouseclick);
		
		}		
	
		/**
		 *  @protected
		 * This Override method of measure
		 * @return void
		 *
		 */
		override protected function measure():void
		{
			super.measure();			
		}
		
		/**
		 * @protected
		 * For setting the sorce of media to play
		 * 
		 * @return void
		 *
		 */
		protected function playMedia():void
		{
			if (_player)
			{
				if (_element)
				{
					if (_container.containsMediaElement(_element))
					{
						_container.removeMediaElement(_element);
					}
				}
				_element=_mediaFactory.createMediaElement(new URLResource(_source))
				_player.media=_element;
				_container.addMediaElement(_element);
			}
		}
		
		/**
		 * @protected
		 * For scaling the media content according to Video disply
		 * @param unscaledWidth of Number
		 * @param unscaledheight of Number
		 * @return void
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledheight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledheight)
			if (_container)
			{
				_container.width=unscaledWidth;
				_container.height=unscaledheight;
			}
		}
		
		
		/**
		 * @protected
		 * For Handling the resolution of Media container
		 * @param ev of DisplayObjectEvent
		 * @return void
		 */
		protected function onMediaSizeChange(event:DisplayObjectEvent):void
		{
			event.stopPropagation()
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * @public
		 * Setting the source of media palyer
		 * @param value
		 * @return void
		 */
		public function set source(value:String):void
		{
			_source=value;
			playMedia();
		}
		
		/**
		 * @public
		 * This function will invoke while user click on player
		 * @param ev of MouseEvent
		 * @return void
		 *
		 */
		public function dispatchMouseclick(ev:MouseEvent):void
		{
			dispatchEvent(new ClickEvent(_source, _player.duration, _player.currentTime));
		}
	}
}
