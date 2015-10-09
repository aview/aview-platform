package edu.amrita.aview.core.documentSharing.helper
{
	import edu.amrita.aview.core.documentSharing.vo.DocumentConversionVO;
	
	import mx.collections.ArrayList;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	public class DocumentConversionHelper extends AbstractHelper
	{
		private var docConversionHelper:RemoteObject=null;
		
		public function DocumentConversionHelper(){
			docConversionHelper=new RemoteObject();
			docConversionHelper.destination="documentConversionHelper";
			docConversionHelper.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			docConversionHelper.showBusyCursor=true;
			
			docConversionHelper.addConversionToQueue.addEventListener("result", addConversionToQueueResultHandler);
			docConversionHelper.addConversionToQueue.addEventListener("fault", genericFaultHandler);
			
			docConversionHelper.getDocumentConversion.addEventListener("result", getDocumentConversionResultHandler);
			docConversionHelper.getDocumentConversion.addEventListener("fault", genericFaultHandler);
			
			docConversionHelper.cancelPendingConversion.addEventListener("result", cancelPendingConversionResultHandler);
			docConversionHelper.cancelPendingConversion.addEventListener("fault", genericFaultHandler);
			
			docConversionHelper.retryFailedConversion.addEventListener("result", retryFailedConversionResultHandler);
			docConversionHelper.retryFailedConversion.addEventListener("fault", genericFaultHandler);
			
			docConversionHelper.getAllNonProcessedDocuments.addEventListener("result", getAllNonProcessedDocumentsResultHandler);
			docConversionHelper.getAllNonProcessedDocuments.addEventListener("fault", genericFaultHandler);
			
			docConversionHelper.getProgress.addEventListener("result", getProgressResultHandler);
			docConversionHelper.getProgress.addEventListener("fault", genericFaultHandler);
		}
		
		public function getProgress(conversionId:Number,onResult:Function,onFault:Function= null):void{
			var token:AsyncToken=docConversionHelper.getProgress(conversionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		private function getProgressResultHandler(event:ResultEvent):void{
			event.token.onResult(event.result as int);
		}
		
		public function getAllNonProcessedDocuments(userId:Number,onResult:Function,onFault:Function= null):void{
			var token:AsyncToken=docConversionHelper.getAllNonProcessedDocuments(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		private function getAllNonProcessedDocumentsResultHandler(event:ResultEvent):void{
			event.token.onResult(event.result as ArrayList);
		}
		
		public function retryFailedConversion(conversionId:Number,onResult:Function,onFault:Function= null):void{
			var token:AsyncToken=docConversionHelper.retryFailedConversion(conversionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		private function retryFailedConversionResultHandler(event:ResultEvent):void	{
			event.token.onResult(event.result as DocumentConversionVO);
		}
		
		public function cancelPendingConversion(conversionId:Number,onResult:Function,onFault:Function= null):void{
			var token:AsyncToken=docConversionHelper.cancelPendingConversion(conversionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		private function cancelPendingConversionResultHandler(event:ResultEvent):void{
			event.token.onResult(event.result as Boolean);
		}
		
		public function addConversionToQueue(documentConversion:DocumentConversionVO,onResult:Function,onFault:Function= null):void{
			var token:AsyncToken=docConversionHelper.addConversionToQueue(documentConversion);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		private function addConversionToQueueResultHandler(event:ResultEvent):void{
			event.token.onResult(event.result as Number);
		}
		
		public function getDocumentConversion(conversionId:Number,onResult:Function,onFault:Function= null):void{
			var token:AsyncToken=docConversionHelper.getDocumentConversion(conversionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		private function getDocumentConversionResultHandler(event:ResultEvent):void{
			event.token.onResult(event.result as DocumentConversionVO);
		}
	
	}
}
