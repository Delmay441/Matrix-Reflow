<#
  uninstall.ps1 — remove Matrix Reflow as the current user's screen saver and
  restore whatever was set before. Removes the per-user copy. No admin needed.
  (If you also ran install-systemwide.ps1, delete %WINDIR%\System32\MatrixReflow.scr
   from an elevated prompt to fully remove it.)
#>
$ErrorActionPreference = 'Stop'
$key = 'HKCU:\Control Panel\Desktop'
$prev = (Get-ItemProperty -Path $key -Name 'MatrixReflowPrevSaver' -ErrorAction SilentlyContinue).'MatrixReflowPrevSaver'
if ($prev) {
    Set-ItemProperty -Path $key -Name 'SCRNSAVE.EXE' -Value $prev
    Remove-ItemProperty -Path $key -Name 'MatrixReflowPrevSaver' -ErrorAction SilentlyContinue
} else {
    Set-ItemProperty -Path $key -Name 'SCRNSAVE.EXE' -Value ''
    Set-ItemProperty -Path $key -Name 'ScreenSaveActive' -Value '0'
}
rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True

$destDir = Join-Path $env:LOCALAPPDATA 'MatrixReflow'
if (Test-Path $destDir) { Remove-Item -Recurse -Force $destDir }

Write-Host "Uninstalled Matrix Reflow screen saver." -ForegroundColor Green
