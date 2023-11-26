write-output "Start docker service to pick up Deeamon.json changes and registry changes"

Start-Service docker

get-service docker

Write-Output "Start the Fluentd service"

Start-service fluentdwinsvc

Get-Service fluentdwinsvc

write-output "Test Docker EE installation"

docker --version

Write-Output "Pulling the UCP images from the docker hub"

docker image pull docker/ucp-agent-win:3.0.4
Write-Output "UCP Agent Complete"

docker image pull docker/ucp-dsinfo-win:3.0.4
Write-Output "UCP DSInfo Complete"

docker image pull mcr.microsoft.com/windows/servercore:ltsc2016
#docker image pull mcr.microsoft.com/dotnet/framework/aspnet:ltsc2019
docker image pull mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2016

$script = [ScriptBlock]::Create((docker run --rm docker/ucp-agent-win:3.0.4 windows-script | Out-String))
Invoke-Command $script

#docker pull microsoft/windowsservercore
#docker pull mcr.microsoft.com/windows/servercore:ltsc2016
#docker pull microsoft/nanoserver
