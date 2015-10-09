package edu.amrita.aview.core.login.syscheck {
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	public class SysCheckCommand {
		private var thirdPartySoftwareDetailsProcess:NativeProcess;
		public var thirdPartySoftwareDetails:Array=new Array();
		
		public function SysCheckCommand() {
		}
		
		public function get3ptSWDetails():void{
			this._getThirdPartySoftwareDetails();
		}
		
		public function checkJava():void{
			
		}
		
		public function checkScreenCamera():void{
			
		}
		
		public function downloScreenCamera():void{
			
		}
		
		public function getOS():String{
			return "win";
		}
		
		/**
		 * @internal
		 * The function for reading third party software (JRE,Screencamera) details from windows registry.
		 *
		 *
		 * @return void
		 */
		internal function _getThirdPartySoftwareDetails():void {
			var file:File=File.applicationDirectory;  
			file=file.resolvePath("NativeApps");
			file=file.resolvePath("Windows/bin/thirdPartySoftwareDetails.exe");
			var nativeProcessStartupInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable=file;
			thirdPartySoftwareDetailsProcess=new NativeProcess();
			thirdPartySoftwareDetailsProcess.start(nativeProcessStartupInfo);
			thirdPartySoftwareDetailsProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, thirdPartySoftwareDetailsProcessOutputDataHandler);
		}
		
		/**
		 * @public
		 * This function is the STANDARD_OUTPUT_DATA handler for processThirdPartySoftwareDetails NativeProcess.
		 *
		 * @param event of type ProgressEvent.
		 * @return void
		 */
		internal function thirdPartySoftwareDetailsProcessOutputDataHandler(event:ProgressEvent):void {
			var result:String=thirdPartySoftwareDetailsProcess.standardOutput.readUTFBytes(thirdPartySoftwareDetailsProcess.standardOutput.bytesAvailable);
			thirdPartySoftwareDetails=result.split(',');
		}
		
	}
}
