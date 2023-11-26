write-output "Running Docker reg change script"
$RegKey = "HKLM:\\SYSTEM\CurrentControlSet\Services\docker"
if (-Not(Test-Path "$RegKey")) {
New-Item -Path "$($RegKey.TrimEnd($RegKey.Split('\')[-1]))" -Name "$($RegKey.Split('\')[-1])" -Force | Out-Null
}
Set-ItemProperty -Path "$RegKey" -Name "ImagePath" -Type ExpandString -Value "C:\Program Files\Docker\dockerd.exe --run-service"

Write-Output "restart docker service"

restart-service docker

get-service docker
