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
