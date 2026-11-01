# Archype: Windows settings for a VM used over RDP and WinApps. firstlogon.ps1 runs it once, as the
# archype user with admin rights; it can also be run by hand in an admin PowerShell. Per-user settings
# go to the current user. Most take effect at the next sign-in.
# Each step logs and carries on when it fails.

function Set-Reg($Path, $Name, $Value, $Type = 'DWord') {
  # New-Item -Force would empty an existing key, so only for missing ones
  if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
  New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

function Step($Title, [scriptblock]$Action) {
  Write-Output "== $Title"
  try { & $Action } catch { Write-Output "   failed: $_" }
}

$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$content = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'

Step 'Less telemetry and ads' {
  Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' AllowTelemetry 1
  Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' DisabledByGroupPolicy 1
  Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' TailoredExperiencesWithDiagnosticDataEnabled 0
  # Suggested and silently installed apps, tips, lock screen and Settings suggestions
  foreach ($name in 'ContentDeliveryAllowed', 'OemPreInstalledAppsEnabled', 'PreInstalledAppsEnabled',
    'SilentInstalledAppsEnabled', 'SoftLandingEnabled', 'SystemPaneSuggestionsEnabled',
    'SubscribedContent-310093Enabled', 'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled',
    'SubscribedContent-338393Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled') {
    Set-Reg $content $name 0
  }
  Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' ScoobeSystemSettingEnabled 0
  Set-Reg $advanced Start_IrisRecommendations 0
  Set-Reg $advanced Start_AccountNotifications 0
  Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' DisableSearchBoxSuggestions 1
}

Step 'Remove preinstalled apps' {
  $apps = 'Clipchamp.Clipchamp', 'Microsoft.BingNews', 'Microsoft.BingSearch', 'Microsoft.BingWeather',
    'Microsoft.Copilot', 'Microsoft.GamingApp', 'Microsoft.GetHelp', 'Microsoft.Getstarted',
    'Microsoft.MicrosoftOfficeHub', 'Microsoft.MicrosoftSolitaireCollection', 'Microsoft.OutlookForWindows',
    'Microsoft.PowerAutomateDesktop', 'Microsoft.Todos', 'Microsoft.Windows.DevHome',
    'Microsoft.WindowsFeedbackHub', 'Microsoft.Xbox.TCUI', 'Microsoft.XboxGamingOverlay',
    'Microsoft.XboxIdentityProvider', 'Microsoft.XboxSpeechToTextOverlay', 'Microsoft.YourPhone',
    'Microsoft.ZuneMusic', 'MSTeams'
  foreach ($app in $apps) {
    # Provisioned: the copy in the image that new users would get
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app |
      Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
    $installed = Get-AppxPackage -Name $app
    if ($installed) {
      $installed | Remove-AppxPackage -ErrorAction SilentlyContinue
      Write-Output "   removed $app"
    }
  }
}

Step 'Show file extensions and hidden files' {
  Set-Reg $advanced HideFileExt 0
  Set-Reg $advanced Hidden 1
}

Step 'No System Restore or reserved storage' {
  Disable-ComputerRestore -Drive 'C:\'
  DISM.exe /Online /Set-ReservedStorageState /State:Disabled /Quiet
  Write-Output "   DISM exit code: $LASTEXITCODE"
}

Step 'Search indexing off' {
  Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
  Set-Service -Name WSearch -StartupType Disabled
}

Step 'Animations off' {
  # Visual effects "custom" with animations, fades and shadows off; smooth fonts stay on
  Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' VisualFXSetting 3
  Set-Reg 'HKCU:\Control Panel\Desktop' UserPreferencesMask ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00)) Binary
  Set-Reg 'HKCU:\Control Panel\Desktop\WindowMetrics' MinAnimate '0' String
  Set-Reg $advanced TaskbarAnimations 0
  Set-Reg $advanced ListviewShadow 0
}

Step 'Dark mode' {
  $personalize = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
  Set-Reg $personalize AppsUseLightTheme 0
  Set-Reg $personalize SystemUsesLightTheme 0
}

Step 'Classic context menu' {
  # An empty default value in InprocServer32 for this class turns off the Windows 11 menu
  $key = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
  if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
  Set-ItemProperty -Path $key -Name '(Default)' -Value ''
}

Step 'Tidy taskbar' {
  Set-Reg $advanced TaskbarAl 0
  Set-Reg $advanced ShowTaskViewButton 0
  Set-Reg $advanced ShowCopilotButton 0
  Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' SearchboxTaskbarMode 0
}

Step 'Copilot, Recall and widgets off' {
  Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' TurnOffWindowsCopilot 1
  Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' DisableAIDataAnalysis 1
  Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' AllowRecallEnablement 0
  # Widgets: 24H2 blocks writing TaskbarDa, the policy works
  Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' AllowNewsAndInterests 0
}

Step 'Remove OneDrive' {
  Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
  $setups = "$env:SystemRoot\System32\OneDriveSetup.exe", "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
  $setups += Get-ChildItem "$env:LOCALAPPDATA\Microsoft\OneDrive\*\OneDriveSetup.exe" -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName
  foreach ($setup in $setups) {
    if (Test-Path $setup) {
      Start-Process -FilePath $setup -ArgumentList '/uninstall' -PassThru | ForEach-Object { $_.WaitForExit() }
      Write-Output "   ran $setup /uninstall"
    }
  }
  # Keeps it from coming back
  Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' DisableFileSyncNGSC 1
  Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name OneDrive -ErrorAction SilentlyContinue
}

Step 'Edge without nags' {
  $edge = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
  Set-Reg $edge HideFirstRunExperience 1
  Set-Reg $edge DefaultBrowserSettingEnabled 0
  Set-Reg $edge StartupBoostEnabled 0
  Set-Reg $edge BackgroundModeEnabled 0
  Set-Reg $edge ShowRecommendationsEnabled 0
  Set-Reg $edge PersonalizationReportingEnabled 0
}
