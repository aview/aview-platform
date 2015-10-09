package edu.amrita.aview.core.evaluation.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;

	[Bindable]
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbQuestionMediaFile")]
	public class QbQuestionMediaFileVO extends Auditable
	{
		public function QbQuestionMediaFileVO()
		{
		}
		
		private var _qbQuestionMediaFileId:Number  = 0 ;
		private var _qbQuestionMediaFileName:String = null;
		private var _qbQuestion:QbQuestionVO = null; 
		private var _qbQuestionMediaFolderPath:String = null;
		private var _qbQuestionMediaFileType:String =null;

		


		public function get qbQuestionMediaFileId():Number
		{
			return _qbQuestionMediaFileId;
		}

		public function set qbQuestionMediaFileId(value:Number):void
		{
			_qbQuestionMediaFileId = value;
		}

		public function get qbQuestionMediaFileName():String
		{
			return _qbQuestionMediaFileName;
		}

		public function set qbQuestionMediaFileName(value:String):void
		{
			_qbQuestionMediaFileName = value;
		}

		public function get qbQuestion():QbQuestionVO
		{
			return _qbQuestion;
		}

		public function set qbQuestion(value:QbQuestionVO):void
		{
			_qbQuestion = value;
		}

		public function get qbQuestionMediaFolderPath():String
		{
			return _qbQuestionMediaFolderPath;
		}

		public function set qbQuestionMediaFolderPath(value:String):void
		{
			_qbQuestionMediaFolderPath = value;
		}

		public function get qbQuestionMediaFileType():String
		{
			return _qbQuestionMediaFileType;
		}

		public function set qbQuestionMediaFileType(value:String):void
		{
			_qbQuestionMediaFileType = value;
		}


	}
}