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
 * File			: VerticalScrollBar.as
 * Module		: Document Sharing
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK
 *
 * VerticalScrollBar.as is custom skin to view vertical scroll bar, only when user touch the container
 *
 */


package edu.amrita.aview.core.shared.skins.mobile
{
	/**
	 * Importing flash library
	 */
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * Importing mx library
	 */
	import mx.events.EffectEvent;
	/**
	 * Importing spark library
	 */
	import spark.components.VScrollBar;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
    
    /**
     * A Scroller with interactionMode="touch" fades the scrollbars away
     * after they are shown for a brief period of time.  This class
     * overrides that behavior to never fade away the VScrollBar. 
     */
    public class VerticalScrollBar extends VScrollBar
    {
		/**
		 * To set timer for fading
		 */
		private var initialFadeTimer:Timer;
		/**
		 * Set fading effect
		 */
		private var initialFadeAnimation:Animate;
		
		/**
		 * Force the scroll bars to stay visible
		 */
		private var keepScrollBars:Boolean;
		
		/**
		 * @public
		 *
		 * To setup a timer to fade away the scrollbars
		 *
		 * @param null
		 * @return void
		 */
		public function initialFadeVScrollBar():void
		{
			// show the scrollbar at initial startup
			keepScrollBars = true;
			
			
			// setup a timer to fade away the scrollbars after initial startup
			initialFadeTimer = new Timer(1000);
			initialFadeTimer.addEventListener(TimerEvent.TIMER, handleInitialFadeOut);
			initialFadeTimer.start();
		}
		/**
		 * @private
		 *
		 * To animate the scrollbars
		 *
		 * @param event of Event
		 * @return void
		 */
		private function handleInitialFadeOut(e:Event):void 
		{
			initialFadeTimer.stop();
			initialFadeTimer.removeEventListener(TimerEvent.TIMER, handleInitialFadeOut);
			
			// no longer force the scrollbars to be visible
			keepScrollBars = false;
			
			// animate the scrollbars away
			initialFadeAnimation = new Animate();
			var motionPaths:Vector.<MotionPath> = Vector.<MotionPath>([new SimpleMotionPath("alpha", 1, 0.1)]);
			initialFadeAnimation.motionPaths = motionPaths;
			initialFadeAnimation.duration = 800;
			initialFadeAnimation.addEventListener(EffectEvent.EFFECT_END, handleEffectEnd);
			initialFadeAnimation.play([this]);
			
			// TODO: Still bugs when you scroll during the initial timer
		}
		/**
		 * @private
		 *
		 * Fading effect end handler
		 *
		 * @param event of Event
		 * @return void
		 */
		private function handleEffectEnd(e:Event):void 
		{
			// remove event listener
			initialFadeAnimation.removeEventListener(EffectEvent.EFFECT_END, handleEffectEnd);
			
			// now that we're faded out we'll go back to the normal state ScrollerLayout is expecting
			this.alpha = 0;
			this.visible = false;
			this.includeInLayout = false;
			this.scaleX = 0;
			this.scaleY = 0;
		}
		/**
		 * @public
		 *
		 * Setter for alpha
		 *
		 * @param value holds alpha value
		 * @return void
		 */
		override public function set alpha(value:Number):void 
		{
			if (!keepScrollBars)
				super.alpha = value;
		}
		/**
		 * @public
		 *
		 * Setter for visibility
		 *
		 * @param value holds boolean 
		 * @return void
		 */
		override public function set visible(value:Boolean):void 
		{
			if (!keepScrollBars)
				super.visible = value;
		}
		/**
		 * @public
		 *
		 * Setter for includeInLayout
		 *
		 * @param value holds boolean 
		 * @return void
		 */
		override public function set includeInLayout(value:Boolean):void 
		{
			if (!keepScrollBars)
				super.includeInLayout = value;
		}
		/**
		 * @public
		 *
		 * Setter for scaleX
		 *
		 * @param value holds x value
		 * @return void
		 */
		override public function set scaleX(value:Number):void 
		{
			if (!keepScrollBars)
				super.scaleX = value;
		}
		/**
		 * @public
		 *
		 * Setter for scaleY
		 *
		 * @param value holds y value
		 * @return void
		 */
		override public function set scaleY(value:Number):void 
		{
			if (!keepScrollBars)
				super.scaleY = value;
		}
    }
}