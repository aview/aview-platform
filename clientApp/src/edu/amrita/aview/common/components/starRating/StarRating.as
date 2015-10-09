/**
 * This component has taken from the following link
 * http://www.adobe.com/cfusion/exchange/index.cfm?event=extensionDetail&extid=1800523
 *
 * **/
/**
 *
 * File			: StarRating.as
 * Module		: common
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Remya T,Vishnupreethi k
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.common.components.starRating
{

	import edu.amrita.aview.common.components.starRating.events.RatingEvent;
	
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	[Event(name="rateChange", type="edu.amrita.aview.common.components.starRating.events.RatingEvent")]
	/**
	 * @public
	 * Canvas has extended to create the starrating component
	 */
	public class StarRating extends Canvas
	{
		/**
		 * To set the default selection for the star
		 */
		[Bindable]
		private var _rate:int=0;
		/**
		 * To set spacing between the star
		 */
		private const STAR_DISTENCE:int=18;
		/**
		 * To stores the rate value temporary in the runtime
		 */
		private var tempRate:int=0;
		
		[Bindable]
		private var _editable:Boolean=true;
		/**
		 * To set the count of the star
		 */
		[Bindable]
		private var _starsCount:int=5;
		/**
		 * To set the selected count of the star
		 */
		[Embed(source='assets/flash/rating.swf', symbol='fillStar')]
		[Bindable]
		public var fillStar:Class;
		/**
		 * To set the unselected count of the star
		 * */
		[Embed(source='assets/flash/rating.swf', symbol='unFillStar')]
		[Bindable]
		public var unFillStar:Class;
		/**
		 * Creating an image object for showing the star
		 */
		private var starImage:Image;
		[Bindable]
		private var _tooltip:String='';
		
		/**
		 * @public
		 * constructor
		 */
		public function StarRating()
		{
			super();
			this.width=98;
			this.height=20;
			this.addEventListener(MouseEvent.MOUSE_MOVE, moveOnCanvas);
			initStars(0);
		}
		
		/**
		 * @private
		 * The following function is used to create the rating star component
		 * 
		 * @param selectionCount of type integer
		 * @return void
		 */
		private function initStars(selectionCount:int):void
		{
			//to remove the stars 
			if (numChildren > 0)
			{
				this.removeAllChildren();
			}
			
			for (var i:int=0; i < _starsCount; i++)
			{
				starImage=new Image();
				if (i < selectionCount)
				{
					starImage.source=fillStar;
				}
				else
				{
					starImage.source=unFillStar;
				}
				
				starImage.x=i * STAR_DISTENCE;
				starImage.name=(i + 1).toString();
				starImage.setStyle("width", "100%");
				starImage.setStyle("height", "100%");
				//adding event listener to the image component
				starImage.addEventListener(MouseEvent.MOUSE_OVER, overStar);
				starImage.addEventListener(MouseEvent.MOUSE_DOWN, clickAsset);
				this.addChild(starImage);
			}
		}
		/**
		 * @private
		 * for creating the rating star 
		 * @param selectionCount of type integer
		 * @return void
		 */
		private function drawStar(selectionCount:int):void
		{
			for (var i:int=1; i <= _starsCount; i++)
			{
				if (i <= selectionCount)
				{
					Image(getChildByName(i + "")).source=fillStar;
				}
				else
				{
					Image(getChildByName(i + "")).source=unFillStar;
				}
			}
		}
		/**
		 * @public
		 * setter function for setting the value
		 * @param rateCount of type integer
		 * @return void
		 */
		public function set rate(rateCount:int):void
		{
			// AKCR: please combine the first 2 IF cases with an OR statement. 
			// AKCR: actually all conditions can be combined to make a conditional operator
			// AKCR:  this._rate = ((!rateCount && _editable) || (!rateCount && !_editable)) ?  
			// AKCR: 							0 : rateCount 
			if (!rateCount && _editable)
			{
				this._rate=0;
			}
			else if (!rateCount && !_editable)
			{
				this._rate=0;
			}
			else
			{
				this._rate=rateCount;
			}
			drawStar(_rate);
		}
		
		/**
		 * @public
		 * getter function for setting the value
		 * @return integer
		 * @return void
		 */
		[Bindable]
		public function get rate():int
		{
			return this._rate;
		}
		
		/**
		 * @private
		 * For selecting the star
		 * 
		 * @param event of type MouseEvent
		 * @return void
		 */
		private function clickAsset(event:MouseEvent):void
		{
			if (_editable)
			{
				rate=tempRate;
				dispatchEvent(new RatingEvent(RatingEvent.RATE_CHANGE, this));
			}
		}
		
		/**
		 * @private
		 * For changing the color of the star in the mouse over
		 * 
		 * @param event of type MouseEvent
		 * @return void
		 */
		private function overStar(event:MouseEvent):void
		{
			if (_editable)
			{
				tempRate=event.currentTarget.name;
				drawStar(_rate);
			}
		}
		
		/**
		 * @private
		 * 
		 * @param event of type MouseEvent
		 * @return void
		 */
		
		private function moveOnCanvas(event:MouseEvent):void
		{
			if (_editable)
			{
				if (mouseX >= (width / scaleX - 15) || mouseX <= 5 || mouseY >= (height / scaleY - 5) || mouseY <= 5)
					drawStar(_rate);
			}
		}
		
		/**
		 * @public
		 * @param flag of type Boolean
		 * @return void
		 */
		public function set editable(flag:Boolean):void
		{
			this._editable=flag;
		}
		
		/**
		 * @public
		 * Setter function for taking the star count
		 * @param starCount of type Integer
		 * @return void
		 */
		public function set startsCount(starCount:int):void
		{
			this._starsCount=starCount;
		}
		
		/**
		 * @public
		 * Getter function for taking the star count
		 * @return Integer
		 */
		public function get starsCount():int
		{
			return this._starsCount;
		}
		
		/**
		 * @public
		 * Setter function for setting the tooltip
		 * @param toolTip of type String
		 * @return void
		 */
		[Bindable]
		public function set starToolTip(toolTip:String):void
		{
			_tooltip=toolTip;
		}
		
		/**
		 * @public
		 * Getter function for setting the tooltip
		 * @return String
		 */
		public function get starToolTip():String
		{
			return _tooltip;
		}
	
	}
}
