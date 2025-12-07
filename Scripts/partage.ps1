# Créer le dossier 
New-Item -Path "C:\Partages" -ItemType Directory

# Créer le dossier New-Item -Path "C:\Partages" -ItemType Directory
New-Item -Path "C:\Partages\Administration" -ItemType Directory
New-Item -Path "C:\Partages\Profs" -ItemType Directory
New-Item -Path "C:\Partages\Eleves" -ItemType Directory

# Partage les dossiers avec des noms simples
New-SmbShare -Name "Administration" -Path "C:\Partages\Administration" -FullAccess "mediaschool\MS-Administration"
New-SmbShare -Name "Profs" -Path "C:\Partages\Profs" -FullAccess "mediaschool\MS-Profs"
New-SmbShare -Name "Eleves" -Path "C:\Partages\Eleves" -FullAccess "mediaschool\MS-Eleves"

Get-SmbShare

# Lister les partages du serveur
Get-SmbShare -CimSession SRV-FS1

# Ou mapper un lecteur réseau pour tester
New-PSDrive -Name "H" -PSProvider FileSystem -Root "\\SRV-FS1\Eleves" -Persist

# =========================================
# Script : partages.ps1
# Objectif : Créer et sécuriser les partages réseau
# =========================================

# 🔹 Variables de base
$basePath = "C:\Partages"

# Créer les dossiers s'ils n'existent pas
$dossiers = @("Administration", "Profs", "Eleves")

foreach ($d in $dossiers) {
    $path = Join-Path $basePath $d
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Host "Dossier créé : $path"
    }
}

# 🔹 Créer les partages SMB (si non existants)
$partages = @(
    @{Nom="Administration"; Chemin="$basePath\Administration"; Groupe="MS-Administration"},
    @{Nom="Profs"; Chemin="$basePath\Profs"; Groupe="MS-Profs"},
    @{Nom="Eleves"; Chemin="$basePath\Eleves"; Groupe="MS-Eleves"}
)

foreach ($p in $partages) {
    if (-not (Get-SmbShare -Name $p.Nom -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $p.Nom -Path $p.Chemin -FullAccess "mediaschool\$($p.Groupe)" -Description "Partage $($p.Nom)"
        Write-Host "Partage créé : $($p.Nom)"
    } else {
        Write-Host "Partage déjà existant : $($p.Nom)"
    }
}

# 🔹 Définir les permissions NTFS
foreach ($p in $partages) {
    $acl = Get-Acl $p.Chemin
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("mediaschool\$($p.Groupe)", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRuleProtection($true, $false)  # Supprime l’héritage
    $acl.ResetAccessRule($rule)
    Set-Acl -Path $p.Chemin -AclObject $acl
    Write-Host "Permissions NTFS appliquées sur : $($p.Chemin)"
}

Write-Host "✅ Configuration des partages terminée avec succès."

1️⃣ Installer FSRM (si ce n’est pas déjà fait)
Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools
Import-Module FileServerResourceManager


2️⃣ Créer des quotas par groupe
# Définir les quotas par groupe
$quotas = @{
    "Administration" = 10GB
    "Profs"         = 5GB
    "Eleves"        = 1GB
}

foreach ($dossier in $quotas.Keys) {
    $chemin = Join-Path $basePath $dossier
    # Vérifie si un quota existe déjà
    if (-not (Get-FsrmQuota -Path $chemin -ErrorAction SilentlyContinue)) {
        New-FsrmQuota -Path $chemin -Size $quotas[$dossier] -Description "Quota pour $dossier"
        Write-Host "Quota créé pour $dossier : $($quotas[$dossier])"
    } else {
        Write-Host "Quota déjà existant pour $dossier"
    }
}

3️⃣ Vérifier les quotas et partages
# Lister tous les quotas FSRM
Get-FsrmQuota

# Vérifier les partages SMB
Get-SmbShare

