# Windows AppCompat & PCA Reset Script

PowerShell script to reset Windows AppCompat settings, disable the Program Compatibility Assistant (PCA), and resolve common compatibility issues caused by corrupted or stuck compatibility flags.

- What this script does

The script performs a complete cleanup and reset of Windows compatibility data:

- Backs up all relevant AppCompat registry keys

- Removes stored compatibility and PCA entries

- Disables the Program Compatibility Assistant

- Stops and disables the PCA Windows service

This is useful when:

Programs always run in compatibility mode

Windows shows wrong compatibility warnings

Old app flags break modern software

PCA keeps interfering with installers or games like GTA V / RageMP

- Backup

Before making any changes, all affected registry keys are automatically backed up to:

C:\Temp\AppCompat_Backup_YYYYMMDD_HHMMSS


Each run creates a new timestamped backup folder, so you can always restore previous settings if needed.

# How to run

Open PowerShell as Administrator

Run:

.\Compatibility_Fix.ps1


Restart Windows after the script finishes

- Requirements

Windows 10 or Windows 11

PowerShell

Administrator privileges

⚠ Disclaimer

This script modifies Windows system registry and services.

Use at your own risk.
While automatic backups are created, improper use may still lead to system instability.

You are responsible for any changes made by this script.

- License

Use, modify, and distribute freely.
No warranty provided.
