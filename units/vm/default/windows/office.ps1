# Archype: installs Office Home 2024 (Word, Excel, PowerPoint) with Microsoft's Office Deployment Tool.
# On the answer CD only with `archype-vm create --office`; firstlogon.ps1 runs it. Office stays
# unactivated, and doesn't update itself (like Windows Update here: you start updates).

$dir = 'C:\Windows\Temp\archype-office'
New-Item -ItemType Directory -Path $dir -Force | Out-Null

@'
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="Home2024Retail">
      <Language ID="MatchOS" Fallback="en-us" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="OneNote" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="OutlookForWindows" />
      <ExcludeApp ID="Teams" />
    </Product>
    <!-- Turkish spell check and grammar -->
    <Product ID="ProofingTools">
      <Language ID="tr-tr" />
    </Product>
  </Add>
  <Updates Enabled="FALSE" />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
'@ | Set-Content -Path "$dir\configuration.xml" -Encoding UTF8

Write-Output '== Office'
try {
  # The Office Deployment Tool; it downloads Office itself (~3GB)
  $ProgressPreference = 'SilentlyContinue'
  Invoke-WebRequest -Uri 'https://officecdn.microsoft.com/pr/wsus/setup.exe' -OutFile "$dir\setup.exe" -UseBasicParsing
  $setup = Start-Process -FilePath "$dir\setup.exe" -ArgumentList '/configure', "$dir\configuration.xml" -WorkingDirectory $dir -PassThru
  $setup.WaitForExit()
  Write-Output "   Office Deployment Tool exit code: $($setup.ExitCode)"
} catch {
  Write-Output "   failed: $_"
}

# Office follows Windows' dark mode by default, which turns Word's page dark too. 0: the light
# "Colorful" theme (3 dark gray, 4 black, 5 white, 6 follow Windows).
$common = 'HKCU:\Software\Microsoft\Office\16.0\Common'
if (-not (Test-Path $common)) { New-Item -Path $common -Force | Out-Null }
New-ItemProperty -Path $common -Name 'UI Theme' -Value 0 -PropertyType DWord -Force | Out-Null

# No "Upgrade your plan" button (Microsoft 365 upsell): an override of Office's remote feature flag
$overrides = "$common\ExperimentConfigs\ExternalFeatureOverrides"
foreach ($app in 'word', 'excel', 'powerpoint') {
  if (-not (Test-Path "$overrides\$app")) { New-Item -Path "$overrides\$app" -Force | Out-Null }
  New-ItemProperty -Path "$overrides\$app" -Name 'Microsoft.Office.Licensing.ShowPerpetualUpgrade' -Value 'false' -PropertyType String -Force | Out-Null
}

# Privacy policies, 2 = off: experiences that analyse your content, that download online content,
# and the optional connected ones. Editing and proofing work without them.
$privacy = 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy'
if (-not (Test-Path $privacy)) { New-Item -Path $privacy -Force | Out-Null }
foreach ($name in 'usercontentdisabled', 'downloadcontentdisabled', 'controllerconnectedservicesenabled') {
  New-ItemProperty -Path $privacy -Name $name -Value 2 -PropertyType DWord -Force | Out-Null
}

# No sign-in, so no Sign in button either (3: no account allowed). No OneDrive/SharePoint saving.
$signIn = 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common\SignIn'
if (-not (Test-Path $signIn)) { New-Item -Path $signIn -Force | Out-Null }
New-ItemProperty -Path $signIn -Name SignInOptions -Value 3 -PropertyType DWord -Force | Out-Null
