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
 * File			: ClickEvent.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * ClickEvent is a extended class of Event class.
 * This class may contain information about clicked video
 *
 */

package edu.amrita.aview.playback.events{
	import flash.events.Event;
	
	/**
	 *  ClickEvent is a extended class of Event class.
	 * This class may contain information about clicked video
	 *
	 */
	public class ClickEvent extends Event{
		/**
		 * Source of clicked video
		 */
		private var _source:String;
		/**
		 * Total palying time of clicked video
		 */
		private var _totalPlayingTime:Number;
		/**
		 * Current playhead time  of  cliked video
		 */
		private var _currentPlayHeadTime:Number;
		
		/**
		 * Get the source of Clicked Video
		 * @return  String
		 *
		 */
		public function get source():String{
			return _source;
		}
		
		/**
		 * Get the Total time  of Clicked Video
		 * @return  Number
		 *
		 */
		public function get totalPlayingTime():Number{
			return _totalPlayingTime;
		}
		
		/**
		 * Get the Current play head time of Clicked Video
		 * @return  Number
		 *
		 */
		public function get currentPlayHeadTime():Number{
			return _currentPlayHeadTime;
		}
		
		/**
		 * Constructor
		 * @param source of type String
		 * @param totalPlayingTime of type Number
		 * @param currentPlayHeadTime of type Number
		 *
		 */
		public function ClickEvent(source:String, totalPlayingTime:Number, currentPlayHeadTime:Number){
			super("ClickEvent");
			_source=source;
			_totalPlayingTime=totalPlayingTime;
			_currentPlayHeadTime=currentPlayHeadTime;
		}
		
		/**
		 * clone function
		 * @return ClickEvent
		 *
		 */
		override public function clone():Event{
			return new ClickEvent(source, totalPlayingTime, currentPlayHeadTime);
		}
	}
}
