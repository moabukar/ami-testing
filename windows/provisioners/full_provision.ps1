# Start of disk creation Script #
# Check for all the new RAW data disks and assign the correct labels into a variable, this example is for Two disks #

Write-host "Adding Windows Disks"
$newdisk = @(get-disk | Where-Object partitionstyle -eq 'raw')
$Labels = @('IMAGES','LOGS')

for($i = 0; $i -lt $newdisk.Count ; $i++)
{

   $disknum = $newdisk[$i].Number
    $dl = get-Disk $disknum |
       Initialize-Disk -PartitionStyle GPT -PassThru |
          New-Partition -AssignDriveLetter -UseMaximumSize
    Format-Volume -driveletter $dl.Driveletter -FileSystem NTFS -NewFileSystemLabel $Labels[$i] -Confirm:$false

}
Write-host "Windows Disks Adding"
##################################################################################################################


write-output "Installing Windows AWS CLI software"
write-host "(host) Installing Windows AWS CLI software"A

# Download and invoke the AWS CLI install file.
Try {
    Write-host "Downloading AWS CLI Software"
    Invoke-WebRequest https://s3.amazonaws.com/aws-cli/AWSCLI64.msi  -OutFile 'C:\Windows\temp\AWSCLI64.msi' -UseBasicParsing
    Invoke-WebRequest https://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi -OutFile 'C:\Windows\temp\AWSToolsAndSDKForNet.msi' -UseBasicParsing
    Write-host "Download complete"
    $Exitcode = 0
    }
    Catch {
          Write-Host "Error in download of AWS CLI"
          write-warning "Error in download of AWS CLI"
          $Exitcode = 1
          Exit $Exitcode
          }
    try {
        Write-host "Installing AWS CLI"
        Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Windows\temp\AWSCLI64.msi /quiet'
        Start-Sleep -seconds 60
        Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Windows\temp\AWSToolsAndSDKForNet.msi /quiet'
        Start-Sleep -s 40
        Write-host "AWS CLI now installed"
        $Exitcode = 0
        }
    Catch
    {
     Write-host "Error in install of AWS CLI"
     write-warning "Error in install of AWS CLI"
     $Exitcode = 1
     Exit $Exitcode
    }
# Restart
# Restart-Computer


##################################################################################################################

write-output "Installing Windows fluentd software"
write-host "(host) Installing Windows fluentd software"

# Download and invoke the fluentd MSI file.
Try {
    Write-host "Downloading td-agent"
    Invoke-WebRequest http://packages.treasuredata.com.s3.amazonaws.com/3/windows/td-agent-3.1.1-0-x64.msi -OutFile 'C:\Windows\temp\fluentd.msi' -UseBasicParsing
    Write-host "Download complete"
    $Exitcode = 0
    }
    Catch {
          Write-Host "Error in download of td-agent"
          write-warning "Error in download of td-agent"
          $Exitcode = 1
          Exit $Exitcode
          }
    try {
        Write-host "Installing td-agent"
        Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Windows\temp\fluentd.msi /quiet'
        Write-host "td-agent now installed"
        $Exitcode = 0
        }
    Catch
    {
     Write-host "Error in install of td-agent"
     write-warning "Error in install of td-agent"
     $Exitcode = 1
     Exit $Exitcode
    }

# Install and confiure fluentd
Copy-Item -path 'C:\Windows\temp\td-agent.conf' -Destination 'C:\opt\td-agent\etc\td-agent\td-agent.conf'
# Vars
$ServiceName = "fluentdwinsvc"
$ServiceDispayName = "Fluentd Windows Service-test"
$ServiceDescription = "Fluentd is an event collector system."

Write-host "Service Name: $ServiceName"
Write-host "Service Displayname: $ServiceDispayName"
Write-Host "Service Discription: $ServiceDescription"

# Create Service
try {
    Write-host "Creating $ServiceName Service"
    New-Service -Name $ServiceName -DisplayName $ServiceDispayName -Description $ServiceDescription -BinaryPathName '"C:/opt/td-agent/embedded/bin/ruby.exe" -C "C:/opt/td-agent/embedded/lib/ruby/gems/2.4.0/gems/fluentd-1.0.2/lib/fluent/command/.."  winsvc.rb --service-name fluentdwinsvc' -StartupType Automatic -ErrorAction Stop
    Write-host "$ServiceName Created!"
    $Exitcode = 0
    }
    catch {
        Write-Warning "Failed to create $ServiceName!"
        $Exitcode = 1
         Exit $Exitcode
        }
        try {
        write-host "Create Fluentdopt regkey"
        New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name "fluentdopt" -Value "-c C:/opt/td-agent/etc/td-agent/td-agent.conf -o C:/opt/td-agent/td-agent.log"-PropertyType String -force
        write-host "Regkey created!"
        $Exitcode = 0
         }
         Catch {
         Write-warning "Failed to add regkey and value!"
         $Exitcode = 1
         Exit $Exitcode
         }
# Add key
try {
    #Start Service
    Write-Host "Starting $ServiceName"
    Start-Service $ServiceName
    $Exitcode = 0
    }
    catch {
    Write-Warning "Error starting $ServiceName"
    $Exitcode = 1
    Exit $Exitcode
    }
#Stop-Service $ServiceName
# Restart
# Restart-Computer
##########################################################################################################################################################

write-output "Installing winlogbeat software"
write-host "(host) Installing winlogbeat software"b

# Download and invoke the winlogbeat MSI file.
Try {
    Write-host "Downloading winlogbeat"
    # Invoke-WebRequest https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-6.4.2-windows-x86_64.zip -OutFile 'C:\Windows\temp\winlogbeat-6.3.0-windows-x86_64.zip' -UseBasicParsing
    Write-host "Download complete"
    $Exitcode = 0
    }
    Catch {
          Write-Host "Error in download of winlogbeat"
          write-warning "Error in download of winlogbeat"
          $Exitcode = 1
          Exit $Exitcode
          }
    try {
        Write-host "Installing winlogbeat"
        Write-Output "Extracting winlogbeats EE Install Media to Program files x86"
        Expand-Archive -LiteralPath 'C:\Windows\temp\winlogbeat-6.4.2-windows-x86_64.zip' -DestinationPath $Env:ProgramFiles
        Write-Output "Removing Winlog beats zip file"
        Remove-Item -LiteralPath 'C:\Windows\temp\winlogbeat-6.4.2-windows-x86_64.zip' -Force
        Write-Output "Renaming the winlogbeats folder"
        Rename-Item -path 'C:\Program Files\winlogbeat-6.4.2-windows-x86_64' -newName 'winlogbeat'
        Copy-Item -path 'C:\Windows\temp\winlogbeats\winlogbeat.yml' -Destination 'C:\Program Files\winlogbeat\winlogbeat.yml'
        Write-Output "Create winlogbeats service and change the winlogbeats application logs from default location to E:\winlogbeats\logs"
        if (Get-Service winlogbeat -ErrorAction SilentlyContinue) {
              $service = Get-WmiObject -Class Win32_Service -Filter "name='winlogbeat'"
              $service.StopService()
              Start-Sleep -s 1
              $service.delete()
            }

            $workdir = 'C:\Program Files\winlogbeat'

            New-Service -name winlogbeat `
              -displayName winlogbeat `
              -StartupType Automatic  `
              -binaryPathName "`"$workdir\winlogbeat.exe`" -c `"$workdir\winlogbeat.yml`" -path.home `"$workdir`" -path.data `"C:\ProgramData\winlogbeat`" -path.logs `"E:\winlogbeat\logs`""

              start-service winlogbeat
              get-service winlogbeat

        Write-host "winlogbeat now installed"
        $Exitcode = 0
        }
    Catch
    {
     Write-host "Error in install of winlogbeat"
     write-warning "Error in install of winlogbeat"
     $Exitcode = 1
     Exit $Exitcode
    }

Stop-Service winlogbeat



write-output "Installing filebeat software"
write-host "(host) Installing filebeat software"b

# Download and invoke the winlogbeat MSI file.
Try {
        Write-host "Installing filebeat"
        Write-Output "Extracting filebeats EE Install Media to Program files x86"
        Expand-Archive -LiteralPath 'C:\Windows\temp\filebeat\filebeat-5.6.16-windows-x86_64.zip' -DestinationPath $Env:ProgramFiles
        #Write-Output "Removing filebeats zip file"
        #Remove-Item -LiteralPath 'C:\Windows\temp\filebeat-5.6.16-windows-x86_64.zip' -Force
        #& "C:\Program Files\filebeat-5.1.1-windows-x86_64\install-service-filebeat.ps1"
        #start-service filebeat

        Write-host "filebeat now installed"
        $Exitcode = 0
        }
    Catch
    {
     Write-host "Error in install of filebeat"
     write-warning "Error in install of filebeat"
     $Exitcode = 1
     Exit $Exitcode
    }

Stop-Service filebeat






######################################################################################################################################################################
write-output "Installing Windows WMI Exporter"
write-host "(host) Installing Windows WMI Exporter"

# Download and invoke the WMI Exporter install file.
Try {
    Write-host "Downloading WMI Exporter Software"
    Write-host "Download complete"
    $Exitcode = 0
    }
    Catch {
          Write-Host "Error in download of WMI Exporter"
          write-warning "Error in download of WMI Exporter"
          $Exitcode = 1
          Exit $Exitcode
          }
    try {
        Write-host "Installing WMI Exporter"
        Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Windows\temp\wmi_exporter-0.4.3-amd64.msi LISTEN_PORT=5000 /quiet'
        Start-Sleep -seconds 30
        Write-host "WMI Exporter now installed"
        $Exitcode = 0
        }
    Catch
    {
     Write-host "Error in install of WMI Exporter"
     write-warning "Error in install of WMI Exporter"
     $Exitcode = 1
     Exit $Exitcode
    }
# Restart
# Restart-Computer

$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

$newpath = "$oldpath;C:\Program Files\Amazon\AWSCLI"

Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
