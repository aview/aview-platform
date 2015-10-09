/**
 * use cases:
 * 1) windows xp java
 * 2) windows 32 java
 * 3) windows 64 java
 * 4) windows server java
 * 5) mac java
 * 6) linux java
 **/
package edu.amrita.aview.core.login.syscheck.worker {
	import edu.amrita.aview.core.login.syscheck.worker.Utils;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import mx.utils.StringUtil;

	public class Java {
		public var operatingSystemName:String=Capabilities.os.toLowerCase();
		private var missingInstallers:Array=new Array();
		private var javaInstallationCheckProcess:NativeProcess;
		private static var STR:Object={ wintxt: 'win', mactxt: 'mac', jretxt: "Java Runtime Environment", winjaw: 'javaw.exe', sys32java: '/windows/system32/javaw.exe', sys64java: '/windows/syswow64/javaw.exe', binjava: '/usr/bin/java', whereis: '/usr/bin/whereis', macjava: '/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java', altjava: '/etc/alternatives/java' };
		private var sysCheckUtil:Utils;

		public function Java() {
			sysCheckUtil=new Utils;
		}

		/**
		 * ashwini: TODO
		 */
		private function _findJava():Boolean {
			var osType:String=sysCheckUtil.findOSType();
			var javaFound:Boolean=false;
			if (osType == "windows")
				javaFound=_findJavaWin();
			else if (osType == "mac")
				javaFound=_findJavaMac();
			else if (osType == "lin")
				javaFound=_findJavaLin();
			return javaFound;
		}

		// ashwini: TODO: implement function
		private function _findJavaWin():Boolean {
			return true;
		}

		// ashwini: todo: implement function
		private function _findJavaMac():Boolean {
			return true;
		}

		// ashwini: todo: implement function
		private function _findJavaLin():Boolean {
			return true;
		}

		/**
		 * @private
		 * The function for finding whether JRE is installed or not.
		 *
		 *
		 * @return void
		 */
		public function findJavaInstallationPath():void {
			var java:File;
			if (operatingSystemName.indexOf(STR.wintxt) > -1) {
				var directoryListing:Array=File.getRootDirectories();
				var isJavaInstalled:Boolean=false;
				for (var i:uint=0; i < directoryListing.length; i++) {
					// AKCR: Here we should be checking for the JAVA_HOME variable. The following
					// AKCR: code breaks in the scenario in which a user already has a JAVA installation
					// AKCR: and he skips java-install as a part of a-view install
					//For 32 bit OS
					java=new File(directoryListing[i].name + STR.sys32java); //'/windows/system32/javaw.exe');
					if (!java.exists) {
						//For 64 bit OS
						java=new File(directoryListing[i].name + STR.sys64java); //'/windows/syswow64/javaw.exe');
					}
					if (java.exists) {
						isJavaInstalled=true;
						break;
					}
				}
				if (!isJavaInstalled) {
					missingInstallers.push(STR.jretxt);
				}
			} else {
				java=new File(STR.binjava); //'/usr/bin/java');
				if (!java.exists) {
					java=new File(operatingSystemName.indexOf(STR.mactxt) > -1 ? STR.macjava : STR.altjava);
						//'/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java' : '/etc/alternatives/java');
				}
			}
			if (!java.exists) {
				//For Linus & MAC
				if (operatingSystemName.indexOf('win') < 0) {
					var args:Vector.<String>=new Vector.<String>;
					args.push('java');
					findJavaInstallationNative(new File(STR.whereis), args); //'/usr/bin/whereis'), args);
				}
			}
		}

		/**
		 * @private
		 * The function for finding whether JRE is installed or not in Linux & MAC operating systems.
		 *
		 * @param file of type File.
		 * @param args of type Vector.
		 * @return void
		 */
		private function findJavaInstallationNative(file:File, args:Vector.<String>=null):void {
			var findJavaInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
			findJavaInfo.executable=file;
			findJavaInfo.workingDirectory=File.applicationDirectory;
			findJavaInfo.arguments=args;
			javaInstallationCheckProcess=new NativeProcess();
			javaInstallationCheckProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, findJavaInstallationNativeOutputHandler);
			javaInstallationCheckProcess.start(findJavaInfo);
		}

		/**
		 * @private
		 * This function is the STANDARD_OUTPUT_DATA handler for findJavaProcess NativeProcess.
		 *
		 * @param event of type ProgressEvent.
		 * @return void
		 */
		private function findJavaInstallationNativeOutputHandler(event:ProgressEvent):void {
			var java:File=new File(StringUtil.trim(javaInstallationCheckProcess.standardOutput.readUTFBytes(javaInstallationCheckProcess.standardOutput.bytesAvailable)));
			if (operatingSystemName.indexOf('win') > -1) {
				java=java.resolvePath('bin').resolvePath(STR.winjaw); //'javaw.exe');
			}
			if (javaInstallationCheckProcess.running) {
				javaInstallationCheckProcess.exit();
			}
			javaInstallationCheckProcess=null;
			if (!java.exists) {
				missingInstallers.push(STR.jretxt); //"Java Runtime Environment");
			}
		}
	}
}
