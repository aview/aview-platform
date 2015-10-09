package edu.amrita.aview.core.evaluation.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;

	[Bindable]
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuizQuestionMediaFile")]
	public class QuizQuestionMediaFileVO extends Auditable
	{
		public function QuizQuestionMediaFileVO()
		{
		}
		
		private var _quizQuestionMediaFileId:Number  = 0 ;
		private var _quizQuestionMediaFileName:String = null;
		private var _quizQuestion:QuizQuestionVO = null; 
		private var _quizQuestionMediaFolderPath:String = null;
		private var _quizQuestionMediaFileType:String =null;

		public function get quizQuestionMediaFileId():Number
		{
			return _quizQuestionMediaFileId;
		}

		public function set quizQuestionMediaFileId(value:Number):void
		{
			_quizQuestionMediaFileId = value;
		}

		public function get quizQuestionMediaFileName():String
		{
			return _quizQuestionMediaFileName;
		}

		public function set quizQuestionMediaFileName(value:String):void
		{
			_quizQuestionMediaFileName = value;
		}

		public function get quizQuestion():QuizQuestionVO
		{
			return _quizQuestion;
		}

		public function set quizQuestion(value:QuizQuestionVO):void
		{
			_quizQuestion = value;
		}

		public function get quizQuestionMediaFolderPath():String
		{
			return _quizQuestionMediaFolderPath;
		}

		public function set quizQuestionMediaFolderPath(value:String):void
		{
			_quizQuestionMediaFolderPath = value;
		}

		public function get quizQuestionMediaFileType():String
		{
			return _quizQuestionMediaFileType;
		}

		public function set quizQuestionMediaFileType(value:String):void
		{
			_quizQuestionMediaFileType = value;
		}


	}
}