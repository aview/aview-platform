package edu.amrita.aview.core.video{
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.shared.service.streaming.VideoConnection;
	
	import flash.media.Camera;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class AVParameters{
		public var connectionIndex:int;
		public var microPhoneIndex:int
		public var cameraIndex:int;
		public var socketPortNo:int;
		public var videoCodec:String;
		//Variable for holding videoKeyFrameFrequency
		public var videoKeyFrameFrequency:int=15;
		public var audioDeviceDrive:String;
		public var videoDeviceDrive:String;
		public var selectedBandWidth:int;
		public var outputFileWrite:int;
		public var streamName:String;
		public var streamNumber:int;
		public var ipFMS:String;
		//public var nc:NetConnection;
		public var userStatus:int;
		public var audioBitrate:int;
		public var videoBitrate:int;
		public var videoCaptureWidth:int;
		public var videoCaptureHeight:int;
		public var bandwidth:int;
		public var quality:int;
		public var fps:int;
		public var keyFrames:int=12;
		public var className:String;
		public var deskTopSharing:int;
		public var serverType:String;
		public var streamingOption:Boolean=false;
		public var cameraType:String;
		private var arResolutionValues:Array;
		private var is4By3:Boolean = false;
		public var h264Profile:String="BaseLine";
		public var h264ProfileValue:int=3;
		
		private static var bwAdobeCodecParams:Object = new Object();
		private static var bwVP6CodecParams:Object = new Object();
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.AVParameters");
		
		public static function getPublishingParams(bwKbps:int,cameraType:String,isAdobeCodec:Boolean,is4By3:Boolean):Array
		{
			var params:Object = null;
			if(isAdobeCodec)
			{
				params = bwAdobeCodecParams;
			}
			else
			{
				params = bwVP6CodecParams;
			}
			
			if(bwKbps<=28)
				bwKbps=28;
			else if(bwKbps<=56)
				bwKbps=56;
			else if(bwKbps<=128)
				bwKbps=128;
			else if(bwKbps<=256)
				bwKbps=256;
			else if(bwKbps<=512)
				bwKbps=512;
			else if(bwKbps<=768)
				bwKbps=768;
			else if(bwKbps<=1024)
				bwKbps=1024;
			else if(bwKbps<=1536)
				bwKbps=1536;
			else if(bwKbps<=2048)
				bwKbps=2048;
			else if(bwKbps<=2520)
				bwKbps=2520;
			else if(bwKbps<=5670)
				bwKbps=5670;
			else
				bwKbps=8505;
			
			var key:String = ((is4By3)?"4:3-":"16:9-")+cameraType+"-"+bwKbps;
			
			return params[key];
		}
		
		{
			//	Webcam,16:9 ratio				   [Bandwidth,Quality,Width,Height,FPS]
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-28"] = [(28*1024)/8,0,160,90,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-56"] = [(56*1024)/8,0,320,180,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-128"] = [(128*1024)/8,0,320,180,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-256"] = [(256*1024)/8,0,640,360,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-512"] = [(512*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-768"] = [(768*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-1024"] =[(1024*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-1536"] =[(1536*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-2048"] =[(2048*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-2520"] =[(2520*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-5670"] =[(5670*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_WEBCAM+"-8505"] =[(8505*1024)/8,0,1280,720,15];
			//	HDWebcam,16:9 ratio				     [Bandwidth,Quality,Width,Height,FPS]
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-28"] = [(28*1024)/8,0,160,90,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-56"] = [(56*1024)/8,0,320,180,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-128"] = [(128*1024)/8,0,320,180,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-256"] = [(256*1024)/8,0,640,360,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-512"] = [(512*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-768"] = [(768*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-1024"] =[(1024*1024)/8,0,768,432,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-1536"] =[(1536*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-2048"] =[(2048*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-2520"] =[(2520*1024)/8,0,1536,864,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-5670"] =[(5670*1024)/8,0,1536,864,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_HD_WEBCAM+"-8505"] =[(8505*1024)/8,0,1920,1080,15];
			// EasyCap,16:9 ratio
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-28"] = [(28*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-56"] = [(56*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-128"] = [(128*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-256"] = [(256*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-512"] = [(512*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-768"] = [(768*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-1024"] =[(1024*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-1536"] =[(1536*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-2048"] =[(2048*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-2520"] =[(2520*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-5670"] =[(5670*1024)/8,0,720,576,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_EASYCAP+"-8505"] =[(8505*1024)/8,0,720,576,15];
			// Blackmagic,16:9 ratio
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-28"] = [(28*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-56"] = [(56*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-128"] = [(128*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-256"] = [(256*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-512"] = [(512*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-768"] = [(768*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-1024"] =[(1024*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-1536"] =[(1536*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-2048"] =[(2048*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-2520"] =[(2520*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-5670"] =[(5670*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_BLACKMAGIC+"-8505"] =[(8505*1024)/8,0,1920,1080,25];
			//	FMLE,16:9 ratio				     [Bandwidth,Quality,Width,Height,FPS]
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-28"] = [(28*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-56"] = [(56*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-128"] = [(128*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-256"] = [(256*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-512"] = [(512*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-768"] = [(768*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-1024"] =[(1024*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-1536"] =[(1536*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-2048"] =[(2048*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-2520"] =[(2520*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-5670"] =[(5670*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["16:9-"+Constants.CAM_TYPE_FMLE+"-8505"] =[(8505*1024)/8,0,1920,1080,15];
			// Webcam,4:3 ratio
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-28"] = [(28*1024)/8,0,160,120,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-56"] = [(56*1024)/8,0,320,240,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-128"] = [(128*1024)/8,0,320,240,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-256"] = [(256*1024)/8,0,320,240,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-512"] = [(512*1024)/8,0,640,480,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-768"] = [(768*1024)/8,0,640,480,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-1024"] =[(1024*1024)/8,0,640,480,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-1536"] =[(1536*1024)/8,0,768,432,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-2048"] =[(2048*1024)/8,0,768,432,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-2520"] =[(2520*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-5670"] =[(5670*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-8505"] =[(8505*1024)/8,0,1280,720,15];
			// HDWebcam,4:3 ratio
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-28"] = [(28*1024)/8,0,160,120,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-56"] = [(56*1024)/8,0,320,240,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-128"] = [(128*1024)/8,0,320,240,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-256"] = [(256*1024)/8,0,320,240,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-512"] = [(512*1024)/8,0,640,480,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-768"] = [(768*1024)/8,0,640,480,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-1024"] =[(1024*1024)/8,0,640,480,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-1536"] =[(1536*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-2048"] =[(2048*1024)/8,0,1280,720,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-2520"] =[(2520*1024)/8,0,1536,864,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-5670"] =[(5670*1024)/8,0,1536,864,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-8505"] =[(8505*1024)/8,0,1920,1080,15];
			// EasyCap,4:3 ratio
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-28"] = [(28*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-56"] = [(56*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-128"] = [(128*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-256"] = [(256*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-512"] = [(512*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-768"] = [(768*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-1024"] =[(1024*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-1536"] =[(1536*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-2048"] =[(2048*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-2520"] =[(2520*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-5670"] =[(5670*1024)/8,0,720,576,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-8505"] =[(8505*1024)/8,0,720,576,15];
			// Blackmagic,4:3 ratio
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-28"] = [(28*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-56"] = [(56*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-128"] = [(128*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-256"] = [(256*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-512"] = [(512*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-768"] = [(768*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-1024"] =[(1024*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-1536"] =[(1536*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-2048"] =[(2048*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-2520"] =[(2520*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-5670"] =[(5670*1024)/8,0,1920,1080,25];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-8505"] =[(8505*1024)/8,0,1920,1080,25];
			// FMLE,4:3 ratio
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-28"] = [(28*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-56"] = [(56*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-128"] = [(128*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-256"] = [(256*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-512"] = [(512*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-768"] = [(768*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-1024"] =[(1024*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-1536"] =[(1536*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-2048"] =[(2048*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-2520"] =[(2520*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-5670"] =[(5670*1024)/8,0,1920,1080,15];
			bwAdobeCodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-8505"] =[(8505*1024)/8,0,1920,1080,15];
			
			//VP6 supports only 4:3 ratio video
			//	Webcam devices	[Width,Height,audioBitrat,videoBitrate]
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-28"] = [320,240,12,8];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-56"] = [320,240,18,38];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-128"] = [320,240,20,108];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-256"] = [320,240,32,180];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-512"] = [320,240,64,440];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-768"] = [320,240,64,700];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_WEBCAM+"-1024"] =[640,480,64,900];
			//	HD Webcam devices	[Width,Height,audioBitrat,videoBitrate]
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-28"] = [320,240,12,8];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-56"] = [320,240,18,38];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-128"] = [320,240,20,108];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-256"] = [320,240,32,180];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-512"] = [320,240,64,440];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-768"] = [320,240,64,700];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_HD_WEBCAM+"-1024"] =[640,480,64,900];
			//	Easycap device				 [Width,Height,audioBitrat,videoBitrate]
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-28"] = [720,540,12,8];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-56"] = [720,540,18,38];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-128"] = [720,540,20,108];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-256"] = [720,540,32,180];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-512"] = [720,540,64,440];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-768"] = [720,540,64,700];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_EASYCAP+"-1024"] = [720,540,64,900];
			//	Blackmagic device				 [Width,Height,audioBitrat,videoBitrate]
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-28"] = [1920,1080,12,8];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-56"] = [1920,1080,18,38];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-128"] = [1920,1080,20,108];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-256"] = [1920,1080,32,180];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-512"] = [1920,1080,64,440];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-768"] = [1920,1080,64,700];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_BLACKMAGIC+"-1024"] = [1920,1080,64,900];
			//	FMLE	[Width,Height,audioBitrat,videoBitrate]
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-28"] = [320,240,12,8];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-56"] = [320,240,18,38];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-128"] = [320,240,20,108];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-256"] = [320,240,32,180];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-512"] = [320,240,64,440];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-768"] = [320,240,64,700];
			bwVP6CodecParams["4:3-"+Constants.CAM_TYPE_FMLE+"-1024"] =[640,480,64,900];
			
		}
		
		
		public function AVParameters(audioDeviceDrive:String,videoDeviceDrive:String,selectedBandwidth:int,outputFileWrite:int,streamName:String,ip:String,userStatus:int,
									 deskTopSharing:int,videoCodec:String,socketPortNo:int,microPhoneIndex:int,cameraIndex:int,serverType:String,connectionIndex:int,isAudioOnlyMode:Boolean,streamNumber:int,cameraType:String,keyFrames:int)
		{
			
			
			if(Log.isInfo()) log.info("Setting AVParameters:"+audioDeviceDrive+":"+videoDeviceDrive+":"+selectedBandwidth+":"
				+outputFileWrite+":"+streamName+":"+ip+":"+userStatus+":"+deskTopSharing+":"+videoCodec+":"+socketPortNo+":"+microPhoneIndex+":"+cameraIndex+":"+serverType+":"+connectionIndex+":"+isAudioOnlyMode+":"+streamNumber);
			this.streamNumber = streamNumber;
			this.streamingOption=isAudioOnlyMode;
			this.connectionIndex=connectionIndex; 
			this.serverType=serverType;
			this.microPhoneIndex=microPhoneIndex;
			this.cameraIndex=cameraIndex;
			this.socketPortNo=socketPortNo;
			this.videoCodec=videoCodec;
			this.deskTopSharing=deskTopSharing;
			this.audioDeviceDrive=audioDeviceDrive;
			this.videoDeviceDrive=videoDeviceDrive;
			this.selectedBandWidth=selectedBandwidth;
			this.outputFileWrite=outputFileWrite;
			this.streamName=streamName;
			this.ipFMS=ip;
			this.keyFrames=keyFrames;
			//this.nc=nc;
			this.userStatus=userStatus;
			if(!this.streamingOption)
			{
				var selectedCamera:Camera=Camera.getCamera(this.cameraIndex.toString());
				var factor1:int=Math.floor(selectedCamera.width/16);
				var factor2:int=Math.floor(selectedCamera.height/9);
				var videoSize:String="16:9";
				
				this.cameraType=cameraType;
				
				
				
				if(videoCodec!=VideoConnection.CODEC_VP6 &&( factor1>0 && factor1>=(factor2-2) && factor1<(factor2+2)))
				{
					is4By3 = false;
					videoSize="16:9";
				}
				else if(videoCodec==VideoConnection.CODEC_VP6)
				{
					videoSize="4:3";
					is4By3 = true;
				}
				if(videoCodec==VideoConnection.CODEC_VP6)
				{
					//setVP6Parameters(selectedBandWidth,videoSize);
					setVP6CodecParams(selectedBandwidth);
					if(Log.isInfo()) log.info("Set VP6 Parameters: audioBitrate:"+audioBitrate+": videoBitrate:"+videoBitrate+": videoCaptureHeight:"+videoCaptureHeight+": videoCaptureWidth:"+videoCaptureWidth+":");
				}
				else if(videoCodec==VideoConnection.CODEC_SORENSON)
				{
					//setSorensonParameters(selectedBandWidth,videoSize);
					setAdobeCodecParameters(selectedBandwidth,videoSize);
					if(Log.isInfo()) log.info("Set Sorenson Parameters: sorensonBandwidth:"+bandwidth+": sorensonQuality:"+quality+": videoCaptureHeight:"+videoCaptureHeight+": videoCaptureWidth:"+videoCaptureWidth+": sorensonFPS:"+fps);
				}
				else if(videoCodec==VideoConnection.CODEC_H264)
				{
					//setH264Parameters(selectedBandWidth,videoSize);
					setAdobeCodecParameters(selectedBandwidth,videoSize);
					if(Log.isInfo()) log.info("Set H.264 Parameters: h264Bandwidth:"+bandwidth+": h264Quality:"+quality+": videoCaptureHeight:"+videoCaptureHeight+": videoCaptureWidth:"+videoCaptureWidth+": h264FPS:"+fps);
				}
			}
			this.className=ClassroomContext.aviewClass.className;
		}
		
		
		
		public function setAdvancedParameters(cameraResolution:String, cameraVideoQuality:int, FPS:int, h264Profile:String, h264ProfileValue:int):void
		{
			var arrResolutionValue:Array = cameraResolution.split(" x ");
			this.videoCaptureWidth = arrResolutionValue[0];
			this.videoCaptureHeight = arrResolutionValue[1];
			this.quality = cameraVideoQuality;
			this.fps = FPS;
			this.h264Profile =h264Profile;
			this.h264ProfileValue = h264ProfileValue;
		}
		
		private function setAdobeCodecParameters(selectedBandwidth:int,videoSize:String):void
		{
			var bwAdobeCodecParamsArray:Array=getPublishingParams(selectedBandwidth,cameraType,true,((videoSize=="4:3")?true:false));
			// bwAdobeCodecParamsArray[Bandwidth,Quality,Width,Height,FPS]
			//bandwidth=bwAdobeCodecParamsArray[0];
			bandwidth=(selectedBandwidth*1024)/8;
			quality=bwAdobeCodecParamsArray[1];
			if(ClassroomContext.aviewClass.isMultiBitrate == "Y")
			{
				videoCaptureWidth=bwAdobeCodecParamsArray[2];
				videoCaptureHeight=bwAdobeCodecParamsArray[3];
				fps=bwAdobeCodecParamsArray[4];
			}
			if(Log.isInfo()) log.info("setAdobeCodecParameters: h264Bandwidth:"+selectedBandwidth+": h264Quality:"+quality+": videoCaptureHeight:"+videoCaptureHeight+": videoCaptureWidth:"+videoCaptureWidth+": h264FPS:"+fps);
		}
		private function setVP6CodecParams(selectedBandwidth:int):void
		{
			var bwVP6CodecParamsArray:Array=getPublishingParams(selectedBandwidth,cameraType,false,true);
			// bwVP6CodecParamsArray[Width,Height,audioBitrate,videoBitrate]
			videoCaptureWidth=bwVP6CodecParamsArray[0];
			videoCaptureHeight=bwVP6CodecParamsArray[1];
			audioBitrate=bwVP6CodecParamsArray[2];
			videoBitrate=bwVP6CodecParamsArray[3];
		}
	}
}