# Archype: runs once, at the first logon of an unattended install (autounattend.xml). It ends by
# shutting Windows down: archype-vm waits for that to remove the install CDs.
# Log: C:\Windows\Temp\archype-firstlogon.log

Start-Transcript -Path C:\Windows\Temp\archype-firstlogon.log

# The archype account is for RDP and WinApps: its password must not expire
Set-LocalUser -Name archype -PasswordNeverExpires $true

# A sleeping VM drops RDP. Hibernation off also turns off Fast Startup, so shutdowns are real ones
# (needed before snapshots and copies).
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /hibernate off

# virtio drivers, QEMU guest agent and SPICE agent, from the virtio-win CD
$tools = Get-PSDrive -PSProvider FileSystem |
  ForEach-Object { Join-Path $_.Root 'virtio-win-guest-tools.exe' } |
  Where-Object { Test-Path $_ } |
  Select-Object -First 1
if ($tools) {
  # Waits for the installer process itself. Start-Process -Wait failed here with "The pipeline has
  # been stopped" and let the script go on to the shutdown, which could cut the install short.
  $installer = Start-Process -FilePath $tools -ArgumentList '/install', '/quiet', '/norestart' -PassThru
  $installer.WaitForExit()
  Write-Output "virtio-win-guest-tools exit code: $($installer.ExitCode)"
} else {
  Write-Output 'virtio-win-guest-tools.exe not found on any drive'
}
# Proof in the log that the install got through: the guest agent is its last part
if (Get-Service -Name QEMU-GA -ErrorAction SilentlyContinue) {
  Write-Output 'QEMU guest agent service: installed'
} else {
  Write-Output 'QEMU guest agent service: missing'
}

# Archype's Windows settings, from the same CD
& (Join-Path $PSScriptRoot 'tweaks.ps1')

Stop-Transcript
Stop-Computer -Force
