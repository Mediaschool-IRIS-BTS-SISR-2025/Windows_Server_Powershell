Sur SRV-DC1:

# Créer l'OU racine
New-ADOrganizationalUnit -Name "ECOLE" -Path "DC=mediaschool,DC=local"

# Créer les sous-OUs
New-ADOrganizationalUnit -Name "Comptes-Utilisateurs" -Path "OU=ECOLE,DC=mediaschool,DC=local"
New-ADOrganizationalUnit -Name "Comptes-Ordinateurs" -Path "OU=ECOLE,DC=mediaschool,DC=local"

# Créer les sous-OUs pour les utilisateurs
New-ADOrganizationalUnit -Name "Administration" -Path "OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local"
New-ADOrganizationalUnit -Name "Profs" -Path "OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local"
New-ADOrganizationalUnit -Name "Eleves" -Path "OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local"

# Créer les groupes dans l'OU ECOLE
New-ADGroup -Name "MS-Administration" -GroupScope Global -GroupCategory Security -Path "OU=ECOLE,DC=mediaschool,DC=local"
New-ADGroup -Name "MS-Profs" -GroupScope Global -GroupCategory Security -Path "OU=ECOLE,DC=mediaschool,DC=local"
New-ADGroup -Name "MS-Eleves" -GroupScope Global -GroupCategory Security -Path "OU=ECOLE,DC=mediaschool,DC=local"

# Définir les utilisateurs à créer
$users = @(
    @{SamAccountName="admin1"; Name="Administrateur 1"; OU="Administration"; Group="MS-Administration"; Password="Passw0rd1"},
    @{SamAccountName="admin2"; Name="Administrateur 2"; OU="Administration"; Group="MS-Administration"; Password="Passw0rd2"},
    @{SamAccountName="prof1"; Name="Professeur 1"; OU="Profs"; Group="MS-Profs"; Password="Passw0rd3"},
    @{SamAccountName="prof2"; Name="Professeur 2"; OU="Profs"; Group="MS-Profs"; Password="Passw0rd4"},
    @{SamAccountName="eleve1"; Name="Elève 1"; OU="Eleves"; Group="MS-Eleves"; Password="Passw0rd5"},
    @{SamAccountName="eleve2"; Name="Elève 2"; OU="Eleves"; Group="MS-Eleves"; Password="Passw0rd6"}
)

# Boucle pour créer les utilisateurs et les ajouter aux groupes
foreach ($u in $users) {
    $securePass = ConvertTo-SecureString $u.Password -AsPlainText -Force
    New-ADUser `
        -SamAccountName $u.SamAccountName `
        -Name $u.Name `
        -AccountPassword $securePass `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -Path "OU=$($u.OU),OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local"

    # Ajouter l'utilisateur au groupe correspondant
    Add-ADGroupMember -Identity $u.Group -Members $u.SamAccountName
}


Pour vérifier:
# Lister les OUs sous ECOLE
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=ECOLE,DC=mediaschool,DC=local" | Format-Table Name, DistinguishedName

# Lister les groupes dans le domaine
Get-ADGroup -Filter * | Format-Table Name, GroupScope, DistinguishedName

# Lister tous les utilisateurs dans une OU
Get-ADUser -Filter * -SearchBase "OU=Administration,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" | Format-Table Name, SamAccountName

Get-ADUser -Filter * -SearchBase "OU=Profs,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" | Format-Table Name, SamAccountName

Get-ADUser -Filter * -SearchBase "OU=Eleves,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" | Format-Table Name, SamAccountName

Get-ADGroupMember -Identity MS-Administration | Format-Table Name, SamAccountName
Get-ADGroupMember -Identity MS-Profs | Format-Table Name, SamAccountName
Get-ADGroupMember -Identity MS-Eleves | Format-Table Name, SamAccountName

Rejoindre le domaine: 
Add-Computer -DomainName "mediaschool.local" -Credential mediaschool\Administrateur -Restart

Pour vérifier:
# Affiche le nom du domaine de la machine
(Get-WmiObject Win32_ComputerSystem).Domain
