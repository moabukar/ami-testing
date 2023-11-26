<powershell>


write-output "Running base provisioner Script"
write-host "(host) Running User Data Script"

Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
$ErrorActionPreference = "stop"

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# setup WinRM client and server service
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'

$RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
if (-Not(Test-Path "$RegKey")) {
New-Item -Path "$($RegKey.TrimEnd($RegKey.Split('\')[-1]))" -Name "$($RegKey.Split('\')[-1])" -Force | Out-Null
}
Set-ItemProperty -Path "$RegKey" -Name "AllowUnencryptedTraffic" -Type Dword -Value "1"
Set-ItemProperty -Path "$RegKey" -Name "AllowBasic" -Type Dword -Value "1"

$RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
if (-Not(Test-Path "$RegKey")) {
New-Item -Path "$($RegKey.TrimEnd($RegKey.Split('\')[-1]))" -Name "$($RegKey.Split('\')[-1])" -Force | Out-Null
}
Set-ItemProperty -Path "$RegKey" -Name "AllowUnencryptedTraffic" -Type Dword -Value "1"
Set-ItemProperty -Path "$RegKey" -Name "AllowBasic" -Type Dword -Value "1"

cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"packer`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm

# Create the Administrative user with default password.
$SecurePw = (ConvertTo-SecureString -AsPlainText -Force "w4eXFIwUKv)omz6@Om=zeajSG5Gx=bp;")

New-Localuser -name “PlatformManager” -Description “LocalAdmin” -FullName “Local Admin by Powershell” -Password $SecurePw -PasswordNeverExpires
Add-LocalGroupMember -group ‘Administrators’ -Member 'PlatformManager'

</powershell>
