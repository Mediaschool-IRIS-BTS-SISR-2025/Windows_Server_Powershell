Installer le rôle DHCP:
Install-WindowsFeature -Name DHCP -IncludeManagementTools

Autoriser le serveur DHCP dans AD:
Add-DhcpServerInDC -DnsName "SRV-DC1.mediaschool.local" -IPAddress 192.168.100.10

Créer un scope:
Add-DhcpServerv4Scope -Name "SCOPE-SALLE-INFO" -StartRange 192.168.100.50 -EndRange 192.168.100.200 -SubnetMask 255.255.255.0 -LeaseDuration 06:00:00

Exclusions:
Add-DhcpServerv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.100.10 -EndRange 192.168.100.20

Configurer les options du scope:
-Router: Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -Router 192.168.100.1
-DNS Servers: Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsServer 192.168.100.10
-DNS Domain Name: Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsDomain "mediaschool.local"

Activer les mises à jour dynamiques DNS:
Set-DhcpServerv4DnsSetting -DynamicUpdates "Always"

Vérifier l'IP client: 
ipconfig /all

