# ESXi Automated Management Tool

This utility provides a graphical user interface (GUI) for the automated management of VMware ESXi hosts, allowing controlled or forced shutdown/reboot of the server and all running virtual machines. The solution is delivered as a self-extracting executable (SFX) for maximum ease of deployment.

## Self-Extracting Executable (SFX)

The distribution is packaged as an **auto-extractable executable** containing:

- `plink.exe` (required for SSH communication with ESXi)
- `esxi_shutdown.ps1` (the PowerShell script with the full logic and GUI)
- `start.bat` (a batch file that is automatically executed and launches the PowerShell script)

Upon execution, the SFX automatically extracts all required files to a temporary directory and runs `start.bat`, which initiates the management utility. This ensures a seamless and user-friendly experience, even for non-technical users.

## Features

- Automatic, controlled shutdown or forced power-off of all running VMs.
- Reboot or shutdown the ESXi host after handling all VMs.
- SSH host fingerprint detection and management.
- Execution and error logging to `esxi_manager.log`.
- Persistent history of ESXi host IPs for fast access.
- Native Windows GUI, no external dependencies except for `plink.exe`.

## Requirements

- Windows with PowerShell 5.1 or higher.
- No need for prior installation—simply execute the auto-extractable file.
- Network connectivity to the ESXi host(s) via SSH (TCP/22).
- Appropriate credentials with shutdown/reboot privileges on the ESXi host.

## Usage

1. Download and run the self-extractable executable.
2. Enter the ESXi host's IP, username, and password. Select **Shutdown** or **Reboot**.
3. Click **Execute**.
4. The script will manage all VMs and the host accordingly. Review `esxi_manager.log` for details.

## Security & Notes

- Credentials are never logged in clear text; only masked or not stored at all.
- All operations are logged for audit purposes.
- It is highly recommended to review and test in a controlled environment before production deployment.
- The script is distributed free for use and modification.

## Author

Issam Chouaib  
Licensed for free distribution.
