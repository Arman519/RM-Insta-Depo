; ============================================================================
; RM-Insta-Depo Installer Script
; For use with Inno Setup (https://jrsoftware.org/isinfo.php)
; ============================================================================

#define MyAppName "RM Insta Depo"
#define MyAppVersion "6.2"
#define MyAppPublisher "RM Insta Depo Team"
#define MyAppURL "https://github.com/Arman519/RM-Insta-Depo"
#define MyAppExeName "RM-Insta-Depo.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
AppId={{RM-INSTA-DEPO-6.2}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE
InfoBeforeFile=STANDALONE_README.txt
OutputDir=.\Installer
OutputBaseFilename=RM-Insta-Depo-Setup-v{#MyAppVersion}
SetupIconFile=RM-Insta-Depo.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
; Main executable (you need to compile this first!)
Source: "RM-Insta-Depo.exe"; DestDir: "{app}"; Flags: ignoreversion

; Documentation
Source: "STANDALONE_README.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "UI_MODERNIZATION_SUMMARY.md"; DestDir: "{app}\docs"; Flags: ignoreversion
Source: "MODERNIZATION_ROADMAP.md"; DestDir: "{app}\docs"; Flags: ignoreversion
Source: "BUILD_INSTRUCTIONS.md"; DestDir: "{app}\docs"; Flags: ignoreversion

; License (create a LICENSE file if you don't have one)
; Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Start Menu shortcuts
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Quick Start Guide"; Filename: "{app}\STANDALONE_README.txt"
Name: "{group}\Documentation"; Filename: "{app}\docs"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

; Desktop shortcut (optional, user decides during install)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

; Quick Launch shortcut (optional, for older Windows)
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
; Option to launch the app after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
procedure InitializeWizard;
begin
  // Custom welcome message
  WizardForm.WelcomeLabel2.Caption :=
    'This will install RM Insta Depo version 6.2 with modernized UI on your computer.' + #13#10#13#10 +
    'Features:' + #13#10 +
    '• Modern Material Design interface' + #13#10 +
    '• Full DPI awareness for 4K displays' + #13#10 +
    '• Recipe search with 500+ items' + #13#10 +
    '• Auto-click functionality' + #13#10 +
    '• Support for 4K, QHD, and Full HD resolutions' + #13#10#13#10 +
    'Click Next to continue, or Cancel to exit Setup.';
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Any post-installation tasks go here
    // For example, creating config files, setting permissions, etc.
  end;
end;

function InitializeUninstall(): Boolean;
begin
  Result := MsgBox('Are you sure you want to remove RM Insta Depo?', mbConfirmation, MB_YESNO) = IDYES;
end;
