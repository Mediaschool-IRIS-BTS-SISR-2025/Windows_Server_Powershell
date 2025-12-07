Connexion admin1 (compte mediaschool sur VM client)

Dans PowerShell en mode normal:
gpupdate /force

net use

H n'apparaissant pas:
dir \\SRV-DC1\netlogon

gpresult /r
-> on voit la GPO-ADM-Poste

\\SRV-DC1\netlogon\MapH_GPO-ADM-Poste.bat

Start-Process "\\SRV-DC1\netlogon\MapH_GPO-ADM-Poste.bat"

net use
-> on voit le lecteur H