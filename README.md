# ESXi Automated Management Tool

This tool provides a graphical interface (GUI) for automated management of VMware ESXi hosts, including the controlled shutdown or reboot of the server and all running virtual machines. The tool leverages `plink.exe` for SSH connections and is designed to simplify mass operations while maintaining traceability and security.

## Features

- Automatic, controlled shutdown or forced power-off of all running VMs.
- Reboot or shutdown the ESXi host after handling all VMs.
- SSH host fingerprint detection and management.
- Credentials and execution log generation for full traceability.
- Persistent history of ESXi host IPs for fast access.
- Native GUI with .NET Windows Forms (no external dependencies except `plink.exe`).

## Requirements

- Windows with PowerShell 5.1 or higher.
- `plink.exe` (from PuTTY suite) must be in the same directory as the script.
- Network connectivity to the ESXi host(s) via SSH (TCP/22).
- Appropriate credentials with shutdown/reboot privileges on the ESXi host.

## How It Works

1. **SSH Key Management**: The script attempts to detect and use the ESXi host's SSH fingerprint. If not detected, it assumes the fingerprint is already trusted on the system.
2. **Credential Verification**: User credentials are tested against the host before performing any action.
3. **Virtual Machine Handling**: All running VMs are shut down gracefully. If a VM does not respond, a forced power-off is executed.
4. **Host Action**: Depending on the user's choice, the ESXi host will be gracefully shut down or rebooted.
5. **Logging**: All actions, errors, and outputs are logged to `esxi_manager.log` in the script directory.
6. **IP History**: Previous host IPs are saved for quick future access.

## Usage

1. Copy `plink.exe` and the script to the same directory.
2. Run the PowerShell script (`.ps1` file) with sufficient privileges.
3. Enter the ESXi host's IP, username, and password. Select **Shutdown** or **Reboot**.
4. Click **Execute**. You will be prompted for confirmation before any action is taken.
5. The script will manage all VMs and the host accordingly. Review `esxi_manager.log` for details.

## Security & Notes

- Credentials are never logged in clear text; only masked or not stored at all.
- All operations are logged for audit purposes.
- It is highly recommended to review and test in a controlled environment before production deployment.
- The script is distributed free for use and modification.

## Author

Issam Chouaib  
Licensed for free distribution.
