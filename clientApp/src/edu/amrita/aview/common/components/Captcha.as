package edu.amrita.aview.common.components
{
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	public class Captcha extends Canvas
	{
		private const CAPTCHA_WIDTH:uint = 91;
		private const CAPTCHA_HEIGHT:uint = 30;
		private var _securitycode:String;
		
		public function Captcha(type:String,counter:Number):void
		{
			// Set CAPTCHA Code
			_securitycode = randString(type, counter);
			generateDots();
			generatePolys(3);
			drawLines(0, 0, (CAPTCHA_WIDTH)-1, (CAPTCHA_HEIGHT)-1, 5, 5);
			displayCode(_securitycode);
			this.width = CAPTCHA_WIDTH;
			this.height = CAPTCHA_HEIGHT;
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			
			var largeMask:UIComponent = new UIComponent();
			largeMask.graphics.beginFill(0x00FFFF, 0.5);
			largeMask.graphics.drawRect(0, 0, CAPTCHA_WIDTH, CAPTCHA_HEIGHT);
			largeMask.graphics.endFill();
			largeMask.x = 0;
			largeMask.y = 0;
			this.addChild(largeMask);
			this.mask = largeMask;
		}
		
		// Generate random security code
		private function randString(type:String,counter:int):String
		{
			var i:int=1;
			var randStr:String="";
			var randNum:int=0;
			var useList:String="";
			var alphaChars:String="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
			var secure:String="!@$%&amp;*-_=+?~";
			for (i = 1; i <= counter; i++) {
				if (type == "alphaChars") {
					useList=alphaChars;
				} else if (type == "alphaCharsnum") {
					useList=alphaChars+"0123456789";
				} else if (type == "secure") {
					useList=alphaChars+"0123456789"+secure;
				} else {
					useList="0123456789";
				}
				
				randNum=Math.floor(Math.random()*useList.length);
				randStr=randStr+useList.charAt(randNum);
			}
			return randStr;
		}
		
		// Generate Random Dots
		public function generateDots():void
		{
			for (var a:int=0; a < 1000; a++) {
				var tmpComponent:UIComponent = new UIComponent();
				var X:int = Math.floor(Math.random()*CAPTCHA_WIDTH);
				var Y:int = Math.floor(Math.random()*CAPTCHA_HEIGHT);
				tmpComponent.graphics.lineStyle(Math.floor(Math.random()*5),
					RGBToHex(Math.floor(Math.random()*255),
						Math.floor(Math.random()*255),
						Math.floor(Math.random()*255)),
					100);
				tmpComponent.graphics.moveTo(X, Y);
				tmpComponent.graphics.lineTo(X+1, Y);
				this.addChild(tmpComponent);
			}
		}
		
		// Converts color values from RGB to Hex
		private function RGBToHex (r:uint, g:uint, b:uint):uint {
			var hex:uint = r << 16 ^ g << 8 ^ b;
			return hex;
		}
		
		// Generate One Polygon
		private function generateOnePoly(sides:uint, radius:uint, color:uint):UIComponent {
			var tmpCmp:UIComponent = new UIComponent();
			var DSides:uint = Math.floor(360/sides);
			//Highest transparency is 100 - default is 50
			tmpCmp.graphics.beginFill(color, 50);
			var cnt:int = -1;
			
			while (++cnt < sides) {
				var X:int = Math.floor(radius*Math.sin(DSides*cnt/180*Math.PI));
				var Y:int = Math.floor(radius*Math.cos(DSides*cnt/180*Math.PI));
				if (!cnt) {
					tmpCmp.graphics.moveTo(X, Y);
				} else {
					tmpCmp.graphics.lineTo(X, Y);
				}
			}
			return tmpCmp;
		}
		
		public function generatePolys(no:uint):void
		{
			for (var i:uint = 0; i < no; i++) {
				var tmpComponent:UIComponent = new UIComponent();
				var tmpRadius:int = Math.floor(Math.random()*40)+10;
				tmpComponent = generateOnePoly(Math.floor(Math.random()*6)+3, tmpRadius,
					RGBToHex(Math.floor(Math.random()*255),
						Math.floor(Math.random()*255),
						Math.floor(Math.random()*255)));
				tmpComponent.x = Math.floor(Math.random()*CAPTCHA_WIDTH);
				tmpComponent.y = Math.floor(Math.random()*CAPTCHA_HEIGHT);
				tmpComponent.rotation = Math.floor(Math.random()*360);
				tmpComponent.alpha = 0.3;
				this.addChild(tmpComponent);
			}
		}
		
		// Generate Background Lines
		private function drawLines(x:int, y:int, wi:int, hi:int, r:int, c:int):void {
			var tmpComponent:UIComponent = new UIComponent();
			// (width, 0xHEXCOLOR, transparency)
			tmpComponent.graphics.lineStyle(1, 0x33BB33, 100);
			var i:int = 0;
			var xd:Number = wi/c;
			var yd:Number = hi/r;
			for (i=0; i<= r; i++) {
				var yy:Number = y+i*yd;
				tmpComponent.graphics.moveTo(x+wi, yy);
				tmpComponent.graphics.lineTo(x, yy);
			}
			for (var j:int=0; j < c; j++) {
				var xx:Number = x+j*xd;
				tmpComponent.graphics.lineTo(xx, y);
				tmpComponent.graphics.lineTo(xx+xd, y+hi);
				
			}
			tmpComponent.graphics.lineTo(x+wi, y);
			this.addChild(tmpComponent);
		}
		
		private function displayCode(code:String):void
		{
			var tmpText:Label = new Label();
			tmpText.text = code;
			tmpText.width = CAPTCHA_WIDTH;
			tmpText.height = CAPTCHA_HEIGHT;
			tmpText.setStyle("fontSize",25);
			tmpText.setStyle("fontWeight","bold");
			tmpText.setStyle("color","#000000");
			tmpText.setStyle("horizontalCenter",0);
			tmpText.setStyle("verticalCenter",0);
			tmpText.setStyle("textAlign",'center');
			this.addChild(tmpText);
		}
		
		public function get securitycode():String
		{
			return this._securitycode;
		}
	}
}