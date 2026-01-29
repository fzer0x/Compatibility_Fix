Compatibility_Fix.ps1

PowerShell script to reset Windows AppCompat settings, disable the Program Compatibility Assistant (PCA), and fix compatibility issues.

What it does

Backs up all relevant AppCompat registry keys

Removes stored compatibility and PCA entries

Disables the Program Compatibility Assistant

Stops and disables the PCA Windows service

Backup

Before making any changes, all registry entries are backed up to:

C:\Temp\AppCompat_Backup_YYYYMMDD_HHMMSS

How to run

Open PowerShell as Administrator

Run:

.\Compatibility_Fix.ps1


Restart Windows when finished

Requirements

Windows 10 or 11

Administrator privileges

Disclaimer

This script modifies system registry and services. Use at your own risk.
Backups are created automatically.