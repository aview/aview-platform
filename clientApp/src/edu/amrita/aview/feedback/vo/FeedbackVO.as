////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: FeedbackVO.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 *
 * value objects for the feedback
 */
package edu.amrita.aview.feedback.vo
{
	import edu.amrita.aview.common.vo.Auditable;
	
	import mx.collections.ArrayList;
	
	[RemoteClass(alias="edu.amrita.aview.feedback.entities.Feedback")]
	public class FeedbackVO extends Auditable
	{
		public function FeedbackVO()
		{
			super();
		}
		private var _feedbackId:Number=0;
		private var _userId:Number=0;
		private var _auditUserLoginId:Number=0;
		private var _auditLectureId:Number=0;
		private var _bandwidthRating:Number=0.0;
		
		private var _overallRating:Number=0;
		private var _audioRating:Number=0;
		private var _videoRating:Number=0;
		private var _interactionRating:Number=0;
		private var _whiteboardRating:Number=0;
		private var _documentSharingRating:Number=0;
		private var _desktopSharingRating:Number=0;
		private var _usabilityRating:Number=0;
		private var _overallFeedback:String=null;
		private var _audioFeedback:String=null;
		private var _videoFeedback:String=null;
		private var _interactionFeedback:String=null;
		private var _whiteboardFeedback:String=null;
		private var _documentSharingFeedback:String=null;
		private var _desktopSharingFeedback:String=null;
		private var _usabilityFeedback:String=null;
		private var _otherFeedback:String=null;
		
		private var _givenMM:Number=0.0; //total memory allocated by runtime
		private var _leftMM:Number=0.0; //free memory
		private var _memoryUsedMB:Number=0.0; //private memory
		private var _usedCPUPercentage:Number=0;
		private var _cpuArchitecture:String=null;
		private var _maxIDCLevel:String=null;
		
		private var _operatingSystem:String=null;
		private var _screenResolutionX:Number=0;
		private var _screenResolutionY:Number=0;
		private var _hasAudioVideo:String=null;
		private var _hasFileReadPermission:String=null;
		private var _is64bitSupport:String=null;
		private var _runtimeVersion:String=null;
		
		private var _uploadBWKb:Number=0;
		private var _downloadBWKb:Number=0;
		private var _hasProxyServer:String=null;
		private var _isBehindFirewall:String=null;
		private var _hasAVS:String=null;
		private var _antiVirusName:String=null;
		
		private var _stageWidth:Number=0;
		private var _stageHeight:Number=0;
		
		public function toString():String{
			var feedbackStr:String=" _feedbackId:" + _feedbackId + ", _userId:" + _userId + ", _auditUserLoginId:" + _auditUserLoginId + ", _auditLectureId:" + _auditLectureId + ", _bandwidthBarsAvg:" + _bandwidthRating + ", _overallRating:" + _overallRating + ", _audioRating:" + _audioRating + ", _videoRating:" + _videoRating + ", _interactionRating:" + _interactionRating + ", _whiteboardRating:" + _whiteboardRating + ", _documentSharingRating:" + _documentSharingRating + ", _desktopSharingRating:" + _desktopSharingRating + ", _usabilityRating:" + _usabilityRating + ", _overallFeedback:" + _overallFeedback + ", _audioFeedback:" + _audioFeedback + ", _videoFeedback:" + _videoFeedback + ", _interactionFeedback:" + _interactionFeedback + ", _whiteboardFeedback:" + _whiteboardFeedback + ", _documentSharingFeedback:" + _documentSharingFeedback + ", _desktopSharingFeedback:" + _desktopSharingFeedback + ", _usabilityFeedback:" + _usabilityFeedback + ", _otherFeedback:" + _otherFeedback + ", _totalMemoryMB:" + _givenMM + ", _freeMemoryMB:" + _leftMM + ", _usedMemoryMB:" + _memoryUsedMB + ", _cpuUsedPct:" + _usedCPUPercentage + ", _cpuArchitecture:" + _cpuArchitecture + ", _maxIDCLevel:" + _maxIDCLevel + ", _operatingSystem:" + _operatingSystem + ", _screenResolutionX:" + _screenResolutionX + ", _screenResolutionY:" + _screenResolutionY + ", _isAVAccess:" + _hasAudioVideo + ", _islocalFileReadAccess:" + _hasFileReadPermission + ", _is64bitSupport:" + _is64bitSupport + ", _runtimeVersion:" + _runtimeVersion + ", _uploadBWKb:" + _uploadBWKb + ", _downloadBWKb:" + _downloadBWKb + ", _isBehindProxy:" + _hasProxyServer + ", _isBehindFirewall:" + _isBehindFirewall + ", _isAntiVirusProtected:" + _hasAVS + ", _antiVirusName:" + _antiVirusName + ", _stageWidth:" + _stageWidth + ", _stageHeight:" + _stageHeight;
			return feedbackStr;
		}
		
		private var _feedbackIssues:ArrayList=new ArrayList();
		
		public function get feedbackId():Number
		{
			return _feedbackId;
		}
		
		public function set feedbackId(value:Number):void
		{
			_feedbackId=value;
		}
		
		public function get userId():Number
		{
			return _userId;
		}
		
		public function set userId(value:Number):void
		{
			_userId=value;
		}
		
		public function get auditUserLoginId():Number
		{
			return _auditUserLoginId;
		}
		
		public function set auditUserLoginId(value:Number):void
		{
			_auditUserLoginId=value;
		}
		
		public function get auditLectureId():Number
		{
			return _auditLectureId;
		}
		
		public function set auditLectureId(value:Number):void
		{
			_auditLectureId=value;
		}
		
		public function get bandwidthRating():Number
		{
			return _bandwidthRating;
		}
		
		public function set bandwidthRating(value:Number):void
		{
			_bandwidthRating=value;
		}
		
		public function get overallRating():Number
		{
			return _overallRating;
		}
		
		public function set overallRating(value:Number):void
		{
			_overallRating=value;
		}
		
		public function get audioRating():Number
		{
			return _audioRating;
		}
		
		public function set audioRating(value:Number):void
		{
			_audioRating=value;
		}
		
		public function get videoRating():Number
		{
			return _videoRating;
		}
		
		public function set videoRating(value:Number):void
		{
			_videoRating=value;
		}
		
		public function get interactionRating():Number
		{
			return _interactionRating;
		}
		
		public function set interactionRating(value:Number):void
		{
			_interactionRating=value;
		}
		
		public function get whiteboardRating():Number
		{
			return _whiteboardRating;
		}
		
		public function set whiteboardRating(value:Number):void
		{
			_whiteboardRating=value;
		}
		
		public function get documentSharingRating():Number
		{
			return _documentSharingRating;
		}
		
		public function set documentSharingRating(value:Number):void
		{
			_documentSharingRating=value;
		}
		
		public function get desktopSharingRating():Number
		{
			return _desktopSharingRating;
		}
		
		public function set desktopSharingRating(value:Number):void
		{
			_desktopSharingRating=value;
		}
		
		public function get usabilityRating():Number
		{
			return _usabilityRating;
		}
		
		public function set usabilityRating(value:Number):void
		{
			_usabilityRating=value;
		}
		
		public function get overallFeedback():String
		{
			return _overallFeedback;
		}
		
		public function set overallFeedback(value:String):void
		{
			_overallFeedback=value;
		}
		
		public function get audioFeedback():String
		{
			return _audioFeedback;
		}
		
		public function set audioFeedback(value:String):void
		{
			_audioFeedback=value;
		}
		
		public function get videoFeedback():String
		{
			return _videoFeedback;
		}
		
		public function set videoFeedback(value:String):void
		{
			_videoFeedback=value;
		}
		
		public function get interactionFeedback():String
		{
			return _interactionFeedback;
		}
		
		public function set interactionFeedback(value:String):void
		{
			_interactionFeedback=value;
		}
		
		public function get whiteboardFeedback():String
		{
			return _whiteboardFeedback;
		}
		
		public function set whiteboardFeedback(value:String):void
		{
			_whiteboardFeedback=value;
		}
		
		public function get documentSharingFeedback():String
		{
			return _documentSharingFeedback;
		}
		
		public function set documentSharingFeedback(value:String):void
		{
			_documentSharingFeedback=value;
		}
		
		public function get desktopSharingFeedback():String
		{
			return _desktopSharingFeedback;
		}
		
		public function set desktopSharingFeedback(value:String):void
		{
			_desktopSharingFeedback=value;
		}
		
		public function get usabilityFeedback():String
		{
			return _usabilityFeedback;
		}
		
		public function set usabilityFeedback(value:String):void
		{
			_usabilityFeedback=value;
		}
		
		public function get otherFeedback():String
		{
			return _otherFeedback;
		}
		
		public function set otherFeedback(value:String):void
		{
			_otherFeedback=value;
		}
		
		public function get givenMM():Number
		{
			return _givenMM;
		}
		
		public function set givenMM(value:Number):void
		{
			_givenMM=value;
		}
		
		public function get leftMM():Number
		{
			return _leftMM;
		}
		
		public function set leftMM(value:Number):void
		{
			_leftMM=value;
		}
		
		public function get memoryUsedMB():Number
		{
			return _memoryUsedMB;
		}
		
		public function set memoryUsedMB(value:Number):void
		{
			_memoryUsedMB=value;
		}
		
		public function get usedCPUPercentage():Number
		{
			return _usedCPUPercentage;
		}
		
		public function set usedCPUPercentage(value:Number):void
		{
			_usedCPUPercentage=value;
		}
		
		public function get cpuArchitecture():String
		{
			return _cpuArchitecture;
		}
		
		public function set cpuArchitecture(value:String):void
		{
			_cpuArchitecture=value;
		}
		
		public function get operatingSystem():String
		{
			return _operatingSystem;
		}
		
		public function set operatingSystem(value:String):void
		{
			_operatingSystem=value;
		}
		
		public function get screenResolutionX():Number
		{
			return _screenResolutionX;
		}
		
		public function set screenResolutionX(value:Number):void
		{
			_screenResolutionX=value;
		}
		
		public function get screenResolutionY():Number
		{
			return _screenResolutionY;
		}
		
		public function set screenResolutionY(value:Number):void
		{
			_screenResolutionY=value;
		}
		
		public function get hasAudioVideo():String
		{
			return _hasAudioVideo;
		}
		
		public function set hasAudioVideo(value:String):void
		{
			_hasAudioVideo=value;
		}
		
		public function get hasFileReadPermission():String
		{
			return _hasFileReadPermission;
		}
		
		public function set hasFileReadPermission(value:String):void
		{
			_hasFileReadPermission=value;
		}
		
		public function get is64bitSupport():String
		{
			return _is64bitSupport;
		}
		
		public function set is64bitSupport(value:String):void
		{
			_is64bitSupport=value;
		}
		
		public function get runtimeVersion():String
		{
			return _runtimeVersion;
		}
		
		public function set runtimeVersion(value:String):void
		{
			_runtimeVersion=value;
		}
		
		public function get uploadBWKb():Number
		{
			return _uploadBWKb;
		}
		
		public function set uploadBWKb(value:Number):void
		{
			_uploadBWKb=value;
		}
		
		public function get downloadBWKb():Number
		{
			return _downloadBWKb;
		}
		
		public function set downloadBWKb(value:Number):void
		{
			_downloadBWKb=value;
		}
		
		public function get hasProxyServer():String
		{
			return _hasProxyServer;
		}
		
		public function set hasProxyServer(value:String):void
		{
			_hasProxyServer=value;
		}
		
		public function get isBehindFirewall():String
		{
			return _isBehindFirewall;
		}
		
		public function set isBehindFirewall(value:String):void
		{
			_isBehindFirewall=value;
		}
		
		public function get hasAVS():String
		{
			return _hasAVS;
		}
		
		public function set hasAVS(value:String):void
		{
			_hasAVS=value;
		}
		
		public function get antiVirusName():String
		{
			return _antiVirusName;
		}
		
		public function set antiVirusName(value:String):void
		{
			_antiVirusName=value;
		}
		
		public function get feedbackIssues():ArrayList
		{
			return _feedbackIssues;
		}
		
		public function set feedbackIssues(value:ArrayList):void
		{
			_feedbackIssues=value;
		}
		
		public function addFeedbackIssue(issue:FeedbackIssueVO):void
		{
			if (this._feedbackIssues == null)
			{
				this._feedbackIssues=new ArrayList();
			}
			issue.feedback=this;
			this._feedbackIssues.addItem(issue);
		}
		
		public function removeFeedbackIssue(issue:FeedbackIssueVO):void
		{
			if (this._feedbackIssues != null)
			{
				for (var i:int=0; _feedbackIssues.length; i++)
				{
					var temp:FeedbackIssueVO=_feedbackIssues.getItemAt(i) as FeedbackIssueVO;
					if (temp.moduleId == issue.moduleId)
					{
						_feedbackIssues.removeItemAt(i);
						break;
					}
				}
			}
		}
		
		public function getFeedbackIssue(moduleId:int):FeedbackIssueVO
		{
			var feedbackIssue:FeedbackIssueVO=null;
			if (this._feedbackIssues != null)
			{
				for (var i:int=0; _feedbackIssues.length; i++)
				{
					var temp:FeedbackIssueVO=_feedbackIssues.getItemAt(i) as FeedbackIssueVO;
					if (temp.moduleId == moduleId)
					{
						feedbackIssue=temp;
						break;
					}
				}
			}
			return feedbackIssue;
		}
		
		public function get maxIDCLevel():String
		{
			return _maxIDCLevel;
		}
		
		public function set maxIDCLevel(value:String):void
		{
			_maxIDCLevel=value;
		}
		
		public function get stageWidth():Number
		{
			return _stageWidth;
		}
		
		public function set stageWidth(value:Number):void
		{
			_stageWidth=value;
		}
		
		public function get stageHeight():Number
		{
			return _stageHeight;
		}
		
		public function set stageHeight(value:Number):void
		{
			_stageHeight=value;
		}
	
		//ashCR: TODO: if the following code is not needed, then please delete it. 
		
		
//		public function get pctUsedProcessor():Number
//		{
//			return _pctUsedProcessor;
//		}
//
//		public function set pctUsedProcessor(value:Number):void
//		{
//			_pctUsedProcessor = value;
//		}
//
//		public function get spentCentralProcessingUnitPerct():Number
//		{
//			return _spentCentralProcessingUnitPerct;
//		}
//
//		public function set spentCentralProcessingUnitPerct(value:Number):void
//		{
//			_spentCentralProcessingUnitPerct = value;
//		}
//
//		public function get usedCPUPercentage():Number
//		{
//			return _usedCPUPercentage;
//		}
//
//		public function set usedCPUPercentage(value:Number):void
//		{
//			_usedCPUPercentage = value;
//		}
//
//		public function get exahustedCPUPercentage():Number
//		{
//			return _exahustedCPUPercentage;
//		}
//
//		public function set exahustedCPUPercentage(value:Number):void
//		{
//			_exahustedCPUPercentage = value;
//		}
	
	
	}
}
