Sur SRV-DC1:
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.100.10 -PrefixLength 24 -DefaultGateway 192.168.100.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.100.10

Rename-Computer -NewName "SRV-DC1" -Restart

Sur SRV-FS1:
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.100.20 -PrefixLength 24 -DefaultGateway 192.168.100.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.100.10

Rename-Computer -NewName "SRV-FS1" -Restart

Installer AD DS: 
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Vérifier que le module est disponible:
Import-Module ADDSDeployment

Promouvoir SRV-DC1 en contrôleur de domaine:
Install-ADDSForest `
 -DomainName "mediaschool.local" `
 -CreateDNSDelegation:$false `
 -DatabasePath "C:\Windows\NTDS" `
 -DomainMode "Default" `
 -ForestMode "Default" `
 -InstallDNS:$true `
 -LogPath "C:\Windows\NTDS" `
 -SysvolPath "C:\Windows\SYSVOL" `
 -Force:$true


Vérification:
Get-WindowsFeature AD-Domain-Services
Get-ADDomain
Get-ADForest

Création de la zone reverse:
Add-DnsServerPrimaryZone `
 -NetworkId "192.168.100.0/24" `
 -ReplicationScope "Domain" `
 -DynamicUpdate "Secure"

Vérification: 
Resolve-DnsName 192.168.100.10 -Type PTR

Rejoindre le domaine: 
Add-Computer -DomainName "mediaschool.local" -Credential mediaschool\Administrateur -Restart

Vérifier que SRV-FS1 a un enregistrement DNS: 
# Sur DC1
Get-DnsServerResourceRecord -ZoneName "mediaschool.local" | Where-Object {$_.HostName -eq "SRV-FS1"}

Vérification des enregistrements DNS:
# Sur DC1
Get-DnsServerResourceRecord -ZoneName "mediaschool.local" | Format-Table HostName, RecordType, RecordData

Tester la zone reverse:
Resolve-DnsName 192.168.100.10 -Type PTR
Resolve-DnsName 192.168.100.20 -Type PTR

ping de FS1 vers DC1:
ping 192.168.100.10
ping srv-dc1.mediaschool.local

Sur FS1:
# Vérifie les interfaces réseau et leur état
Get-NetAdapter | Format-Table Name, Status, InterfaceDescription

# Vérifie les IP configurées sur chaque interface
Get-NetIPAddress | Format-Table InterfaceAlias, IPAddress, PrefixLength, AddressState

Problème de restriction du firewall pour le ping sur FS1:
# Autoriser ICMP echo sur toutes les interfaces (test seulement)
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow

ping de DC1 vers FS1:
ping 192.168.100.20
ping SRV-FS1.mediaschool.local



