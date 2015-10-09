package edu.amrita.aview.core.documentSharing.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	[RemoteClass(alias="edu.amrita.aview.documentsharing.entities.DocumentConversion")]
	public class DocumentConversionVO extends Auditable
	{
		
		private var _documentConversionId:Number=0;
		private var _userId:Number=0;
		private var _documentName:String=null;
		private var _documentPath:String=null;
		private var _contentServerId:Number=0;
		private var _conversionStatus:String=null;
		private var _conversionMessage:String=null;
		private var _progressPct:Number=0;	
		public function DocumentConversionVO(){
			super();
		}
		public function get documentConversionId():Number{
			return _documentConversionId;
		}
		public function set documentConversionId(value:Number):void{
			_documentConversionId=value;
		}
		
		public function get userId():Number{
			return _userId;
		}
		
		public function set userId(value:Number):void{
			_userId=value;
		}
		
		public function get documentName():String{
			return _documentName;
		}
		
		public function set documentName(value:String):void{
			_documentName=value;
		}
		
		public function get documentPath():String{
			return _documentPath;
		}
		
		public function set documentPath(value:String):void{
			_documentPath=value;
		}
		
		public function get contentServerId():Number{
			return _contentServerId;
		}
		
		public function set contentServerId(value:Number):void{
			_contentServerId=value;
		}
		
		public function get conversionStatus():String{
			return _conversionStatus;
		}
		
		public function set conversionStatus(value:String):void	{
			_conversionStatus=value;
		}
		
		public function get conversionMessage():String{
			return _conversionMessage;
		}
		
		public function set conversionMessage(value:String):void{
			_conversionMessage=value;
		}
		public function get progressPct():Number{
			return _progressPct;
		}
		public function set progressPct(value:Number):void	{
			_progressPct=value;
		}
	
	
	}
}
