

; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppName=A-VIEW
AppVerName=A-VIEW Version [VERSION]
AppPublisher=Amrita E-Learning Research Lab
AppPublisherURL=http://aview.in/
DefaultDirName={pf}\A-VIEW
;DisableDirPage=yes
;DefaultGroupName=A-VIEW
;DisableProgramGroupPage=yes
OutputBaseFilename=A-VIEW_WithThirdPartySoftware-[VERSION]
OutputDir=.\bin-release
Compression=lzma
SolidCompression=true
;DisableFinishedPage=true
;DisableReadyPage=true
UninstallFilesDir={win}
AllowCancelDuringInstall=false
CreateAppDir=false
Uninstallable=false
DisableProgramGroupPage=true
ShowComponentSizes=false
UsePreviousSetupType=false
AlwaysShowDirOnReadyPage=true
AlwaysShowGroupOnReadyPage=true
SetupIconFile=aview_classroom_logo-48x48.ico
AlwaysShowComponentsList=false
FlatComponentsList=false

[Run]
Filename: {tmp}\SC.exe; Parameters: " /SILENT "; Check: ShouldInstallSCUpdate
Filename: {tmp}\AdobeAIRInstaller.exe; Check: ShouldInstallAIRUpdate
Filename: {tmp}\jre-7u7-windows-i586.exe; Parameters: " /s" ; Check: ShouldInstallJREUpdate
Filename: {tmp}\A-VIEW_NativeInstaller-[VERSION].exe
;Parameters: " -silent -desktopShortcut -eulaAccepted -allowDownload -location ""\""{pf}""\"""

; Filename: regsvr32.exe; Parameters: " /S ""{pf}\A-VIEW\amritapublisher.dll"""

[Files]
Source: SC.exe; DestDir: {tmp}; Flags: deleteafterinstall ignoreversion
Source: ..\bin-release\A-VIEW_NativeInstaller-[VERSION].exe; DestDir: {tmp}; Flags: deleteafterinstall ignoreversion
Source: jre-7u7-windows-i586.exe; DestDir: {tmp}; Flags: deleteafterinstall
Source: AdobeAIRInstaller.exe; DestDir: {tmp}; Flags: deleteafterinstall

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Code]
function InitializeSetupProject(): Boolean;
var
 ErrorCode: Integer;
 JavaInstalled : Boolean;
 Result1 : Boolean;
 Versions: TArrayOfString;
 I: Integer;
begin

 if RegGetSubkeyNames(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', Versions) then
 begin
  for I := 0 to GetArrayLength(Versions)-1 do
   if JavaInstalled = true then
   begin
    //do nothing
   end else
   begin
    if ( Versions[I][2]='.' ) and ( ( StrToInt(Versions[I][1]) > 1 ) or ( ( StrToInt(Versions[I][1]) = 1 ) and ( StrToInt(Versions[I][3]) >= 6 ) ) ) then
    begin
     JavaInstalled := true;
    end else
    begin
     JavaInstalled := false;
    end;
   end;
 end else
 begin
  JavaInstalled := false;
 end;


 //JavaInstalled := RegKeyExists(HKLM,'SOFTWARE\JavaSoft\Java Runtime Environment\1.9');
 if JavaInstalled then
 begin
  Result := true;
 end else
    begin
  Result1 := MsgBox('This tool requires Java Runtime Environment version 1.6 or newer to run. Please download and install the JRE and run this setup again. Do you want to download it now?',
   mbConfirmation, MB_YESNO) = idYes;
  if Result1 = false then
  begin
   Result:=false;
  end else
  begin
   Result:=false;
   ShellExec('open',
    'http://www.java.com/getjava/',
    '','',SW_SHOWNORMAL,ewNoWait,ErrorCode);
  end;
    end;
end;

function ShouldInstallSCUpdate: Boolean;
begin
  // Only install if the existing comctl32.dll is < 5.80
  Result := False;
  if Not RegKeyExists(HKLM, 'SOFTWARE\PCWinSoft\ScrCam') then
    Result := True;
end;

function ShouldInstallAIRUpdate: Boolean;
begin
  // Only install if the existing comctl32.dll is < 5.80
  Result := False;
  if Not RegKeyExists(HKLM, 'SOFTWARE\Adobe\Adobe AIR\FileTypeRegistration') then
    Result := True;
end;

function ShouldInstallJREUpdate: Boolean;
begin
  // Only install if the existing comctl32.dll is < 5.80
  Result := False;
  if Not RegKeyExists(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment\1.6') then
    Result := True;
end;

end.
