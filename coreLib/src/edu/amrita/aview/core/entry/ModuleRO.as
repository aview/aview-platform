package edu.amrita.aview.core.entry
{
	import com.amrita.edu.collaboration.CollaborationService;
	
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;

	public class ModuleRO extends ModuleVO
	{
		public function ModuleRO()
		{
			super();
		}
		
		override public function get mediaServerConnection():MediaServerConnection
		{
			return _mediaServerConnection;
		}
		
		override public function get moduleEventMap():EventMap
		{
			return _moduleEventMap;
		}
		
		override public function get applicationEventMap():EventMap
		{
			return _applicationEventMap;
		}
		
		override public function get collaborationService():CollaborationService
		{
			return _collaborationService;
		}
		
		override public function get userVO():UserVO
		{
			return _userVO;
		}
		
		override public function get lectureVO():LectureVO
		{
			return _lectureVO;
		}

		
		
	}
}