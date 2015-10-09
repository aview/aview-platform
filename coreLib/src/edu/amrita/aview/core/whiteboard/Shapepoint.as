package edu.amrita.aview.core.whiteboard
{
	
	public class Shapepoint{
		public function Shapepoint(){}
		public var x:uint
		public var y:uint
		
		public function convertToXml():XML{
			var pointXml:XML;
			pointXml=<point></point>;
			pointXml.@x=x;
			pointXml.@y=y;
			return pointXml;
		}
		
		public function initByXML(point:XML):void{
			this.x=point.@x;
			this.y=point.@y
		}
		
		public function initBySO(obj:Object):void{
			this.x=obj.x;
			this.y=obj.y;
		}
	}
}
