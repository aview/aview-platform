

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
OutputBaseFilename=A-VIEW_Full-[VERSION]
OutputDir=.\bin-release
Compression=lzma
SolidCompression=true
;DisableFinishedPage=true
;DisableReadyPage=true
UninstallFilesDir={app}
AllowCancelDuringInstall=false
;CreateAppDir=false
;Uninstallable=false
DisableProgramGroupPage=true
ShowComponentSizes=false
UsePreviousSetupType=false
AlwaysShowDirOnReadyPage=true
AlwaysShowGroupOnReadyPage=true
SetupIconFile=aview_classroom_logo-48x48.ico
AlwaysShowComponentsList=false
FlatComponentsList=false


[Run]
Filename: {tmp}\SC.exe; Parameters: " /SILENT ";
;Check: ShouldInstallSCUpdate
Filename: {tmp}\AdobeAIRInstaller.exe;
;Check: ShouldInstallAIRUpdate
Filename: {tmp}\jre-7u7-windows-i586.exe; Parameters: " /s" ;
;Check: ShouldInstallJREUpdate
Filename: "{app}\A-VIEW.exe"; Flags: nowait postinstall

[Files]
Source: SC.exe; DestDir: {tmp}; Flags: deleteafterinstall ignoreversion; BeforeInstall: MyBeforeInstall
;Source: amritapublisher.dll; DestDir: {app}; Flags: regserver ignoreversion
Source: A-VIEW\*.*; DestDir: {app}; Flags: recursesubdirs ignoreversion
Source: misc/jre-7u7-windows-i586.exe; DestDir: {tmp}; Flags: deleteafterinstall
Source: misc/AdobeAIRInstaller.exe; DestDir: {tmp}; Flags: deleteafterinstall
Source: aview_classroom_logo-48x48.ico; DestDir: {app}

[Icons]
Name: {commondesktop}\A-VIEW; Filename: {app}\A-VIEW.exe; IconFilename: {app}\aview_classroom_logo-48x48.ico; HotKey: ctrl+alt+a; WorkingDir: {app}; AppUserModelID: "AVIEW.AVIEWClassroom"

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Code]
procedure MyBeforeInstall();
var
  ResultCode: integer;
begin
    Exec(ExpandConstant('{app}\NativeApps\Windows\bin\taskkill.exe'), ' /F /IM callSC.exe*', ExpandConstant('{app}\NativeApps\Windows\bin'), SW_HIDE, ewWaitUntilTerminated, ResultCode)
    Exec(ExpandConstant('{app}\NativeApps\Windows\bin\taskkill.exe'), ' /F /IM ScrCam.exe*', ExpandConstant('{app}\NativeApps\Windows\bin'), SW_HIDE, ewWaitUntilTerminated, ResultCode)
    Exec(ExpandConstant('{app}\NativeApps\Windows\bin\taskkill.exe'), ' /F /IM akr.exe*', ExpandConstant('{app}\NativeApps\Windows\bin'), SW_HIDE, ewWaitUntilTerminated, ResultCode)
    Exec(ExpandConstant('{app}\NativeApps\Windows\bin\taskkill.exe'), ' /F /IM "A-VIEW.exe*"', ExpandConstant('{app}\NativeApps\Windows\bin'), SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;
end.