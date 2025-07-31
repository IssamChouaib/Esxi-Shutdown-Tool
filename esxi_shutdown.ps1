Add-Type -AssemblyName System.Windows.Forms

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$plinkPath = Join-Path -Path $scriptDir -ChildPath "plink.exe"
$historyFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ips_history.txt")
$logFile = Join-Path $scriptDir "esxi_manager.log"

function Write-Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "$timestamp`t$msg"
}

function Get-ESXiFingerprint {
    param([string]$plinkExe, [string]$user, [string]$pass, [string]$ip)
    $cmd = "`"$plinkExe`" -ssh -batch -pw `"$pass`" $user@$ip exit"
    Write-Log "Detecting fingerprint: $cmd"
    $output = cmd /c $cmd 2>&1
    $outStr = $output -join "`n"
    Write-Log "Fingerprint command output:`n$outStr"
    foreach ($line in $output) {
        if ($line -match 'SHA256:[A-Za-z0-9+/=]+') {
            Write-Log "Fingerprint detected: $($matches[0])"
            return $matches[0]
        }
    }
    Write-Log "WARNING: No fingerprint found!"
    return $null
}

function Invoke-ESXiSSH {
    param(
        [string]$cmd, [string]$user, [string]$pass, [string]$ip, [string]$hostkey = $null
    )
    if ($hostkey) {
        $plinkCmd = "`"$plinkPath`" -ssh -batch -pw `"$pass`" -hostkey `"$hostkey`" $user@$ip $cmd"
        Write-Log "Executing (with hostkey): $plinkCmd"
    } else {
        $plinkCmd = "`"$plinkPath`" -ssh -batch -pw `"$pass`" $user@$ip $cmd"
        Write-Log "Executing (no hostkey): $plinkCmd"
    }
    $output = cmd /c $plinkCmd 2>&1
    $outStr = $output -join "`n"
    Write-Log "Output:`n$outStr"
    return $output
}

function Test-ESXiCredentials {
    param([string]$user, [string]$pass, [string]$ip, [string]$hostkey = $null)
    $testCmd = "uname -a"
    $result = Invoke-ESXiSSH $testCmd $user $pass $ip $hostkey
    $outStr = $result -join "`n"
    Write-Log "Credential test result:`n$outStr"
    if ($outStr -match "Access denied" -or $outStr -match "authentication failed" -or -not ($outStr -match "Linux|VMkernel")) {
        Write-Log "ERROR: Credentials not valid or not ESXi"
        return $false
    }
    return $true
}

# Load IP history
$ipHistory = @()
if (Test-Path $historyFile) {
    $ipHistory = Get-Content $historyFile | Where-Object { $_ -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' }
}

# Hide console
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
    [Win32]::ShowWindow($consolePtr, 0)
}

# GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "Automated ESXi Management"
$form.Size = New-Object System.Drawing.Size(440,430)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false

$menuStrip = New-Object System.Windows.Forms.MenuStrip
$aboutMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$aboutMenu.Text = "About"
$menuStrip.Items.Add($aboutMenu)
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)
$aboutMenu.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "ESXi Automated Shutdown Tool`r`nAuthor: Issam Chouaib`r`nLicensed for free distribution.",
        "About",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information
    )
})

$lblIP = New-Object System.Windows.Forms.Label
$lblIP.Text = "ESXi server IP:"
$lblIP.Location = New-Object System.Drawing.Point(20,25)
$form.Controls.Add($lblIP)

$comboIP = New-Object System.Windows.Forms.ComboBox
$comboIP.Location = New-Object System.Drawing.Point(160,23)
$comboIP.Width = 190
$comboIP.DropDownStyle = "DropDown"
$comboIP.Items.AddRange($ipHistory)
$form.Controls.Add($comboIP)

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

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Execute"
$btnRun.Location = New-Object System.Drawing.Point(160,230)
$form.Controls.Add($btnRun)

$txtStatus = New-Object System.Windows.Forms.TextBox
$txtStatus.Multiline = $true
$txtStatus.ScrollBars = "Vertical"
$txtStatus.ReadOnly = $true
$txtStatus.Location = New-Object System.Drawing.Point(20,270)
$txtStatus.Width = 380
$txtStatus.Height = 120
$form.Controls.Add($txtStatus)

function Save-IPHistory {
    param([string[]]$history)
    $history | Set-Content -Encoding UTF8 $historyFile
}

$btnClearHistory.Add_Click({
    $comboIP.Items.Clear()
    if (Test-Path $historyFile) { Remove-Item $historyFile -Force }
    $txtStatus.Text = "IP history cleared."
    Write-Log "IP history cleared by user."
})

$btnRun.Add_Click({
    $txtStatus.Text = ""
    $ip = $comboIP.Text.Trim()
    $user = $txtUser.Text.Trim()
    $pass = $txtPass.Text
    $action = if ($rbShutdown.Checked) { "SHUTDOWN" } else { "REBOOT" }

    Write-Log "------ OPERATION START ------"
    Write-Log "IP: $ip | USER: $user | ACTION: $action"

    if (-not $ip -or -not $user -or -not $pass) {
        $txtStatus.Text = "Please fill in all fields."
        Write-Log "ERROR: Required fields missing."
        return
    }

    if (($comboIP.Items -notcontains $ip) -and ($ip -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')) {
        $comboIP.Items.Add($ip)
        $comboIP.Refresh()
        $newHistory = @($comboIP.Items | ForEach-Object { $_.ToString() }) | Where-Object { $_ }
        Save-IPHistory $newHistory
    }

    $txtStatus.Text = "Checking connectivity to $ip ..."
    $form.Refresh()
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue
    Write-Log "Ping $ip result: $ping"
    if (-not $ping) {
        $txtStatus.Text = "ERROR: Host $ip is not responding. Aborting operation."
        Write-Log "ERROR: Host not responding."
        return
    }

    # DESCUBRE Y USA FINGERPRINT (O NO)
    $txtStatus.Text = "Checking SSH fingerprint for $ip ..."
    $form.Refresh()
    $hostkey = Get-ESXiFingerprint -plinkExe $plinkPath -user $user -pass $pass -ip $ip
    if (-not $hostkey) {
        $txtStatus.Text += "`r`nNo fingerprint detected. Trying without hostkey param (hostkey assumed cached)."
        Write-Log "No fingerprint detected, proceeding without hostkey param."
        $hostkey = $null
    } else {
        $txtStatus.Text += "`r`nDetected fingerprint: $hostkey"
    }
    $form.Refresh()

    $txtStatus.Text += "`r`nVerifying credentials..."
    $form.Refresh()
    $credTest = Test-ESXiCredentials $user $pass $ip $hostkey
    if (-not $credTest) {
        $txtStatus.Text = "ERROR: Invalid username or password. Please check your credentials and try again."
        Write-Log "ERROR: Invalid credentials."
        return
    }
    $txtStatus.Text += "`r`nCredentials validated.`r`nRetrieving VM status..."
    $form.Refresh()

    # VM List
    $allVMsOutput = Invoke-ESXiSSH "vim-cmd vmsvc/getallvms" $user $pass $ip $hostkey
    if (-not $allVMsOutput) {
        $txtStatus.Text = "Unable to retrieve VM list. Check SSH user permissions."
        Write-Log "ERROR: Cannot retrieve VM list."
        return
    }
    $lines = $allVMsOutput -split "`n" | Where-Object { $_.Trim() -ne "" }
    if ($lines.Count -le 1) {
        $txtStatus.Text = "No VMs found by ESXi."
        Write-Log "No VMs found."
        return
    }
    $vmList = @()
    foreach ($line in $lines[1..($lines.Count-1)]) {
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
        $state = Invoke-ESXiSSH "vim-cmd vmsvc/power.getstate $vmid" $user $pass $ip $hostkey | Select-String "Powered on"
        if ($state) { $poweredOnVMs += ,@($vmid, $vmname) }
    }

    if ($poweredOnVMs.Count -gt 0) {
        $txtStatus.Text = "Shutting down running VMs:`r`n" + (
            ($poweredOnVMs | ForEach-Object { "VM $($_[0]) ($($_[1]))" }) -join ", "
        )
        Write-Log "Powering off running VMs: $($poweredOnVMs | ForEach-Object { "$($_[0]) ($($_[1]))" } | Out-String)"
        $form.Refresh()
        $timeoutShutdown = 12
        foreach ($tuple in $poweredOnVMs) {
            $vmid = $tuple[0]
            $vmname = $tuple[1]
            Invoke-ESXiSSH "vim-cmd vmsvc/power.shutdown $vmid" $user $pass $ip $hostkey
            $txtStatus.Text += "`r`nGraceful shutdown sent to VM $vmid ($vmname)..."
            $form.Refresh()
            $shutdownCounter = 0
            while ($shutdownCounter -lt $timeoutShutdown) {
                Start-Sleep -Seconds 5
                $state = Invoke-ESXiSSH "vim-cmd vmsvc/power.getstate $vmid" $user $pass $ip $hostkey | Select-String "Powered on"
                if (-not $state) {
                    $txtStatus.Text += "`r`nVM $vmid ($vmname) powered off gracefully."
                    Write-Log "VM $vmid ($vmname) powered off gracefully."
                    $form.Refresh()
                    break
                }
                $shutdownCounter++
            }
            if ($shutdownCounter -eq $timeoutShutdown) {
                $txtStatus.Text += "`r`nGraceful shutdown failed for VM $vmid ($vmname). Forcing power off..."
                Write-Log "Graceful shutdown failed for VM $vmid ($vmname), forcing power off."
                $form.Refresh()
                Invoke-ESXiSSH "vim-cmd vmsvc/power.off $vmid" $user $pass $ip $hostkey
                Start-Sleep -Seconds 5
                $state = Invoke-ESXiSSH "vim-cmd vmsvc/power.getstate $vmid" $user $pass $ip $hostkey | Select-String "Powered on"
                if (-not $state) {
                    $txtStatus.Text += "`r`nVM $vmid ($vmname) powered off forcibly."
                    Write-Log "VM $vmid ($vmname) powered off forcibly."
                } else {
                    $txtStatus.Text += "`r`nWARNING: VM $vmid ($vmname) could not be powered off. Please check manually."
                    Write-Log "WARNING: VM $vmid ($vmname) could not be powered off. Please check manually."
                }
                $form.Refresh()
            }
        }
    } else {
        $txtStatus.Text = "No VMs are running."
        Write-Log "No running VMs."
    }
    $form.Refresh()

    # Shutdown or reboot host
    if ($action -eq "SHUTDOWN") {
        $txtStatus.Text += "`r`nShutting down ESXi host..."
        Write-Log "Shutting down host."
        $form.Refresh()
        # Shutdown: primero script oficial, luego comando directo
        Invoke-ESXiSSH "/sbin/shutdown.sh" $user $pass $ip $hostkey
        Invoke-ESXiSSH "poweroff" $user $pass $ip $hostkey
    } else {
        $txtStatus.Text += "`r`nRebooting ESXi host..."
        Write-Log "Rebooting host."
        $form.Refresh()
        Invoke-ESXiSSH "/sbin/shutdown.sh" $user $pass $ip $hostkey
        Invoke-ESXiSSH "reboot" $user $pass $ip $hostkey
    }

    Start-Sleep -Seconds 20
    $txtStatus.Text += "`r`nChecking host status..."
    Write-Log "Checking ping after operation."
    $form.Refresh()
    $timeout = 24
    $counter = 0
    while ($counter -lt $timeout) {
        if (-not (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
            $txtStatus.Text += "`r`nESXi host is no longer responding. Operation completed successfully."
            Write-Log "Host is no longer responding. Success."
            break
        }
        Start-Sleep -Seconds 5
        $counter++
    }
    if ($counter -eq $timeout) {
        $txtStatus.Text += "`r`nThe host is still responding to ping. Please check manually."
        Write-Log "Timeout: host still responds to ping."
    }
    Write-Log "------ OPERATION END ------"
    $form.Refresh()
})

$form.TopMost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
