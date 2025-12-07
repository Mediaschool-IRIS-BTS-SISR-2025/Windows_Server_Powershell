Horaires appliquées aux élèves :
[byte[]]$Heures = @(0,0,0,0,255,192,0,255,192,0,255,192,0,255,192,0,255,192,0,0,0)

Get-ADUser -SearchBase "OU=Eleves,OU=ECOLE,DC=mediaschool,DC=local" -Filter * | 
ForEach-Object { 
    Set-ADUser -Identity $_ -Replace @{logonhours = $Heures} -Server "SRV-DC1.mediaschool.local"
    Write-Host "✅ Horaires appliqués à $($_.SamAccountName)"
}

Horaires appliquées à l’administration :
[byte[]]$Heures = @(0,0,0,128,255,224,128,255,224,128,255,224,128,255,224,128,255,224,0,0,0)

Get-ADUser -SearchBase "OU=Administration,OU=ECOLE,DC=mediaschool,DC=local" -Filter * | 
ForEach-Object { 
    Set-ADUser -Identity $_ -Replace @{logonhours = $Heures} -Server "SRV-DC1.mediaschool.local"
    Write-Host "✅ Horaires appliqués à $($_.SamAccountName)"
}

Horaires appliquées aux profs :
[byte[]]$Heures = @(0,0,0,128,255,240,128,255,240,128,255,240,128,255,240,128,255,240,0,240,0)

Get-ADUser -SearchBase "OU=Profs,OU=ECOLE,DC=mediaschool,DC=local" -Filter * | 
ForEach-Object { 
    Set-ADUser -Identity $_ -Replace @{logonhours = $Heures} -Server "SRV-DC1.mediaschool.local"
    Write-Host "✅ Horaires appliqués à $($_.SamAccountName)"
}
