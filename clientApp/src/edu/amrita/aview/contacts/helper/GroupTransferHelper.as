package edu.amrita.aview.contacts.helper
{
	import edu.amrita.aview.contacts.vo.GroupTransferVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class GroupTransferHelper extends AbstractHelper
	{
		private var groupTranferRO:RemoteObject=null;
		public function GroupTransferHelper()
		{
			super();
			groupTranferRO=new RemoteObject();
			groupTranferRO.destination="grouptransferhelper";
			groupTranferRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			groupTranferRO.showBusyCursor=true;
			
			groupTranferRO.createGroupTransfer.addEventListener("result", createGroupTransferResultHandler);
			groupTranferRO.createGroupTransfer.addEventListener("fault", genericFaultHandler);
			
			groupTranferRO.createPendingGroupTransfers.addEventListener("result", createPendingGroupTransfersResultHandler);
			groupTranferRO.createPendingGroupTransfers.addEventListener("fault", createPendingGroupTransfersFaultHandler);
			
			groupTranferRO.updateGroupTransfer.addEventListener("result", updateGroupTransferResultHandler);
			groupTranferRO.updateGroupTransfer.addEventListener("fault", genericFaultHandler);
			
			groupTranferRO.deleteGroupTransfer.addEventListener("result", deleteGroupTransferResultHandler);
			groupTranferRO.deleteGroupTransfer.addEventListener("fault", genericFaultHandler);
			
			groupTranferRO.getTransferredGroupsByReceiver.addEventListener("result", getTransferredGroupsByReceiverResultHandler);
			groupTranferRO.getTransferredGroupsByReceiver.addEventListener("fault", genericFaultHandler);			
			
		}
		
		public function createGroupTransfer(group:GroupTransferVO, creatorId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupTranferRO.createGroupTransfer(group, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		public function createGroupTransferResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		public function createPendingGroupTransfers(groups:ArrayCollection, creatorId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupTranferRO.createPendingGroupTransfers(groups, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		public function createPendingGroupTransfersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		public function createPendingGroupTransfersFaultHandler(event:FaultEvent):void
		{
			if (event.fault.faultString && event.fault.faultString.indexOf("Duplicate entry")>-1)
			{
				event.token.onFault(event);
			}
			else
			{
				genericFaultHandler(event);
			}
		}
		public function updateGroupTransfer(group:GroupTransferVO, updaterId:Number,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=groupTranferRO.updateGroupTransfer(group, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		public function updateGroupTransferResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		public function deleteGroupTransfer(groupTransferId:Number, onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=groupTranferRO.deleteGroupTransfer(groupTransferId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		public function deleteGroupTransferResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		public function getTransferredGroupsByReceiver( userId:Number,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=groupTranferRO.getTransferredGroupsByReceiver(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		public function getTransferredGroupsByReceiverResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
	}
}