write-output "Installing Windows Docker EE"
write-host "(host) Installing Windows Docker EE" 

# Download and invoke the Docker EE install file.
Try {
    Write-host "Downloading Docker EE Software"
    #Invoke-WebRequest https://download.docker.com/components/engine/windows-server/17.06/docker-17.06.2-ee-16.zip  -Outfile 'C:\Windows\temp\docker-17.06.2-ee-16.zip' -UseBasicParsing
    #Invoke-WebRequest https://download.docker.com/components/engine/windows-server/18.09/docker-18.09.9.zip  -Outfile 'C:\Windows\temp\docker-18.09.9.zip' -UseBasicParsing
    #Invoke-WebRequest http://10.102.80.204/dockeree/docker-18-09-0.zip  -Outfile docker-18-09-0.zip -UseBasicParsing
    Install-Module DockerMsftProvider -Force
    Install-Package Docker -ProviderName DockerMsftProvider -Force
    Write-host "Docker Installed"
    $Exitcode = 0
    }
    Catch {
          Write-Host "Error in download of Docker EE"
          write-warning "Error in download of Docker EE"
          $Exitcode = 1
          Exit $Exitcode
          }
    try {
        #Write-host "Installing Docker EE"
        #Expand-Archive docker-18-09-0.zip -DestinationPath $Env:ProgramFiles -Force
        #Write-Host " Clean up the zip file."
        #Remove-Item -Force docker-18-09-0.zip
        #Write-Host " Install Docker. This requires rebooting."
        #$null = Install-WindowsFeature containers
        #Write-Host "Add Docker to the path for the current session."
        $env:path += ";$env:ProgramFiles\docker"
        Write-Host "Optionally, modify PATH to persist across sessions."
        $newPath = "$env:ProgramFiles\docker;" +
        [Environment]::GetEnvironmentVariable("PATH",
        [EnvironmentVariableTarget]::Machine)
        [Environment]::SetEnvironmentVariable("PATH", $newPath,
        [EnvironmentVariableTarget]::Machine)
        #Write-Host "Register the Docker daemon as a service."
        #dockerd --register-service
        #Write-Output "Create docker directory in programdata if it does not exsist"
        #$path = "C:\ProgramData\docker\config"
        #If(!(test-path $path))
        #{
        #New-Item -ItemType Directory -Force -Path $path
        #}
#        Write-Host "Start the Docker service."
#        Start-Service docker
        Write-host "Docker EE now installed"
        $Exitcode = 0
        }
    Catch
    {
     Write-host "Error in install of Docker EE"
     write-warning "Error in install of Docker EE"
     $Exitcode = 1
     Exit $Exitcode
    }
# Restart
# Restart-Computer
