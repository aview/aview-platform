package edu.amrita.aview.core.entry
{
	import com.amrita.edu.collaboration.CollaborationService;
	
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;

	public class ModuleVO
	{
		public function ModuleVO()
		{
		}
		
		protected var _userVO:UserVO = null;
		
		protected var _applicationEventMap:EventMap = null;
		
		protected var _moduleEventMap:EventMap=null;
		
		protected var _mediaServerConnection:MediaServerConnection = null;
		
		protected var _collaborationService:CollaborationService = null;
		
		protected var _lectureVO:LectureVO = null;
		
		
		public function get mediaServerConnection():MediaServerConnection
		{
			return _mediaServerConnection;
		}

		public function get moduleEventMap():EventMap
		{
			return _moduleEventMap;
		}

		public function get applicationEventMap():EventMap
		{
			return _applicationEventMap;
		}

		public function get collaborationService():CollaborationService
		{
			return _collaborationService;
		}

		public function get userVO():UserVO
		{
			return _userVO;
		}
		
		public function get lectureVO():LectureVO
		{
			return _lectureVO;
		}

		public function set userVO(value:UserVO):void
		{
			_userVO = value;
		}

		public function set applicationEventMap(value:EventMap):void
		{
			_applicationEventMap = value;
		}

		public function set moduleEventMap(value:EventMap):void
		{
			_moduleEventMap = value;
		}

		public function set mediaServerConnection(value:MediaServerConnection):void
		{
			_mediaServerConnection = value;
		}

		public function set collaborationService(value:CollaborationService):void
		{
			_collaborationService = value;
		}

		public function set lectureVO(value:LectureVO):void
		{
			_lectureVO = value;
		}


	}
}