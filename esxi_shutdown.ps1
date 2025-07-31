Add-Type -AssemblyName System.Windows.Forms

$plinkPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "plink.exe"
$historyFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ips_history.txt")

# Load IP history
$ipHistory = @()
if (Test-Path $historyFile) {
    $ipHistory = Get-Content $historyFile | Where-Object { $_ -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' }
}

# Ocultar la ventana de consola que ejecuta este script
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
$consolePtr = [Win32]::GetConsoleWindow()
if ($consolePtr -ne [IntPtr]::Zero) {
    # 0 = SW_HIDE (ocultar)
    [Win32]::ShowWindow($consolePtr, 0)
}

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Automated ESXi Management"
$form.Size = New-Object System.Drawing.Size(440,430)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false    # Disables maximize button

# Menú "About" arriba a la derecha
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$aboutMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$aboutMenu.Text = "About"
$menuStrip.Items.Add($aboutMenu)
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)

$aboutMenu.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "ESXi Automated Shutdown Tool`r`n" +
        "Author: Issam Chouaib`r`n" +
        "Licensed for free distribution.",
        "About",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
})

# Labels and input fields
$lblIP = New-Object System.Windows.Forms.Label
$lblIP.Text = "ESXi server IP:"
$lblIP.Location = New-Object System.Drawing.Point(20,25)
$form.Controls.Add($lblIP)

# ComboBox for IP with history
$comboIP = New-Object System.Windows.Forms.ComboBox
$comboIP.Location = New-Object System.Drawing.Point(160,23)
$comboIP.Width = 190
$comboIP.DropDownStyle = "DropDown"
$comboIP.Items.AddRange($ipHistory)
$form.Controls.Add($comboIP)

# Button to clear IP history
$btnClearHistory = New-Object System.Windows.Forms.Button
$btnClearHistory.Text = "Clear H"
$btnClearHistory.Location = New-Object System.Drawing.Point(355,22)
$btnClearHistory.Width = 50
$form.Controls.Add($btnClearHistory)

$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = "Username:"
$lblUser.Location = New-Object System.Drawing.Point(20,70)
$form.Controls.Add($lblUser)
$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = New-Object System.Drawing.Point(160,68)
$txtUser.Width = 240
$txtUser.Text = "root"
$form.Controls.Add($txtUser)

$lblPass = New-Object System.Windows.Forms.Label
$lblPass.Text = "Password:"
$lblPass.Location = New-Object System.Drawing.Point(20,115)
$form.Controls.Add($lblPass)
$txtPass = New-Object System.Windows.Forms.MaskedTextBox
$txtPass.UseSystemPasswordChar = $true
$txtPass.Location = New-Object System.Drawing.Point(160,113)
$txtPass.Width = 240
$form.Controls.Add($txtPass)

# Vertical RadioButtons for host action
$lblOpcion = New-Object System.Windows.Forms.Label
$lblOpcion.Text = "Host action:"
$lblOpcion.Location = New-Object System.Drawing.Point(20,160)
$form.Controls.Add($lblOpcion)
$rbShutdown = New-Object System.Windows.Forms.RadioButton
$rbShutdown.Text = "Shutdown"
$rbShutdown.Location = New-Object System.Drawing.Point(160,160)
$rbShutdown.Checked = $true
$form.Controls.Add($rbShutdown)
$rbReboot = New-Object System.Windows.Forms.RadioButton
$rbReboot.Text = "Reboot"
$rbReboot.Location = New-Object System.Drawing.Point(160,185)
$form.Controls.Add($rbReboot)

# Execute button
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Execute"
$btnRun.Location = New-Object System.Drawing.Point(160,230)
$form.Controls.Add($btnRun)

# Status box with increased bottom margin
$txtStatus = New-Object System.Windows.Forms.TextBox
$txtStatus.Multiline = $true
$txtStatus.ScrollBars = "Vertical"
$txtStatus.ReadOnly = $true
$txtStatus.Location = New-Object System.Drawing.Point(20,270)
$txtStatus.Width = 380
$txtStatus.Height = 120
$form.Controls.Add($txtStatus)

# Functions

function Save-IPHistory {
    param([string[]]$history)
    $history | Set-Content -Encoding UTF8 $historyFile
}

function Test-HostAlive {
    param([string]$ip)
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue
    return $ping
}

function Invoke-ESXiSSH {
    param([string]$cmd, [string]$user, [string]$pass, [string]$ip)
    & "$plinkPath" -ssh -batch -pw $pass "$user@$ip" "$cmd"
}

function Test-ESXiCredentials {
    param([string]$user, [string]$pass, [string]$ip)
    $result = & "$plinkPath" -ssh -batch -pw $pass "$user@$ip" "uname -a" 2>&1
    if ($result -match "Access denied" -or $result -match "authentication failed" -or -not ($result -match "Linux|VMkernel")) {
        return $false
    }
    return $true
}

# Button: Clear IP history
$btnClearHistory.Add_Click({
    $comboIP.Items.Clear()
    if (Test-Path $historyFile) { Remove-Item $historyFile -Force }
    $txtStatus.Text = "IP history cleared."
})

# Button: Main logic
$btnRun.Add_Click({
    $txtStatus.Text = ""
    $ip = $comboIP.Text.Trim()
    $user = $txtUser.Text.Trim()
    $pass = $txtPass.Text
    $action = if ($rbShutdown.Checked) { "SHUTDOWN" } else { "REBOOT" }

    if (-not $ip -or -not $user -or -not $pass) {
        $txtStatus.Text = "Please fill in all fields."
        return
    }

    # Save IP to history if not already present
    if (($comboIP.Items -notcontains $ip) -and ($ip -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')) {
        $comboIP.Items.Add($ip)
        $comboIP.Refresh()
        $newHistory = @($comboIP.Items | ForEach-Object { $_.ToString() }) | Where-Object { $_ }
        Save-IPHistory $newHistory
    }

    $txtStatus.Text = "Checking connectivity to $ip ..."
    $form.Refresh()
    if (-not (Test-HostAlive $ip)) {
        $txtStatus.Text = "ERROR: Host $ip is not responding. Aborting operation."
        return
    }

    $txtStatus.Text = "Verifying credentials..."
    $form.Refresh()
    if (-not (Test-ESXiCredentials $user $pass $ip)) {
        $txtStatus.Text = "ERROR: Invalid username or password. Please check your credentials and try again."
        return
    }

    $txtStatus.Text = "Credentials validated.`r`nRetrieving VM status..."
    $form.Refresh()

    # Retrieve VM list and robustly extract ID and NAME (handles spaces in names)
    $allVMsOutput = Invoke-ESXiSSH "vim-cmd vmsvc/getallvms" $user $pass $ip
    if (-not $allVMsOutput) {
        $txtStatus.Text = "Unable to retrieve VM list. Check SSH user permissions."
        return
    }
    $lines = $allVMsOutput -split "`n" | Where-Object { $_.Trim() -ne "" }
    if ($lines.Count -le 1) {
        $txtStatus.Text = "No VMs found by ESXi."
        return
    }
    $vmList = @()
    foreach ($line in $lines[1..($lines.Count-1)]) {
        # VMID and NAME: get first number as ID, then all until '[' (start of VMX path)
        if ($line -match '^\s*(\d+)\s+(.+?)\s+\[(.+)$') {
            $vmid = $matches[1]
            $vmname = $matches[2].Trim()
            $vmList += ,@($vmid, $vmname)
        }
    }

    # Check running VMs
    $poweredOnVMs = @()
    foreach ($tuple in $vmList) {
        $vmid = $tuple[0]
        $vmname = $tuple[1]
        $state = Invoke-ESXiSSH "vim-cmd vmsvc/power.getstate $vmid" $user $pass $ip | Select-String "Powered on"
        if ($state) { $poweredOnVMs += ,@($vmid, $vmname) }
    }

    if ($poweredOnVMs.Count -gt 0) {
        $txtStatus.Text = "Shutting down running VMs:`r`n" + (
            ($poweredOnVMs | ForEach-Object { "VM $($_[0]) ($($_[1]))" }) -join ", "
        )
        $form.Refresh()

        $timeoutShutdown = 12    # 1 minute total, 12 cycles of 5 seconds
        foreach ($tuple in $poweredOnVMs) {
            $vmid = $tuple[0]
            $vmname = $tuple[1]

            # 1. Attempt graceful shutdown
            Invoke-ESXiSSH "vim-cmd vmsvc/power.shutdown $vmid" $user $pass $ip
            $txtStatus.Text += "`r`nGraceful shutdown sent to VM $vmid ($vmname)..."
            $form.Refresh()

            # 2. Wait for shutdown
            $shutdownCounter = 0
            while ($shutdownCounter -lt $timeoutShutdown) {
                Start-Sleep -Seconds 5
                $state = Invoke-ESXiSSH "vim-cmd vmsvc/power.getstate $vmid" $user $pass $ip | Select-String "Powered on"
                if (-not $state) {
                    $txtStatus.Text += "`r`nVM $vmid ($vmname) powered off gracefully."
                    $form.Refresh()
                    break
                }
                $shutdownCounter++
            }

            # 3. If still on, force power off
            if ($shutdownCounter -eq $timeoutShutdown) {
                $txtStatus.Text += "`r`nGraceful shutdown failed for VM $vmid ($vmname). Forcing power off..."
                $form.Refresh()
                Invoke-ESXiSSH "vim-cmd vmsvc/power.off $vmid" $user $pass $ip

                # Confirm forced shutdown
                Start-Sleep -Seconds 5
                $state = Invoke-ESXiSSH "vim-cmd vmsvc/power.getstate $vmid" $user $pass $ip | Select-String "Powered on"
                if (-not $state) {
                    $txtStatus.Text += "`r`nVM $vmid ($vmname) powered off forcibly."
                } else {
                    $txtStatus.Text += "`r`nWARNING: VM $vmid ($vmname) could not be powered off. Please check manually."
                }
                $form.Refresh()
            }
        }
    } else {
        $txtStatus.Text = "No VMs are running."
    }
    $form.Refresh()

    # Shutdown or reboot host
    if ($action -eq "SHUTDOWN") {
        $txtStatus.Text += "`r`nShutting down ESXi host..."
        $form.Refresh()
        Invoke-ESXiSSH "/sbin/shutdown.sh && /sbin/poweroff" $user $pass $ip
    } else {
        $txtStatus.Text += "`r`nRebooting ESXi host..."
        $form.Refresh()
        Invoke-ESXiSSH "/sbin/shutdown.sh && /sbin/reboot" $user $pass $ip
    }

    # Wait a few seconds for the shutdown/reboot process to begin
    Start-Sleep -Seconds 20
    $txtStatus.Text += "`r`nChecking host status..."
    $form.Refresh()

    # Wait up to 2 minutes for the host to stop responding to ping
    $timeout = 24
    $counter = 0
    while ($counter -lt $timeout) {
        if (-not (Test-HostAlive $ip)) {
            $txtStatus.Text += "`r`nESXi host is no longer responding. Operation completed successfully."
            break
        }
        Start-Sleep -Seconds 5
        $counter++
    }
    if ($counter -eq $timeout) {
        $txtStatus.Text += "`r`nThe host is still responding to ping. Please check manually."
    }
    $form.Refresh()
})
$form.TopMost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
