# =========================================
# Script : GPO_DriveMap_Fait.ps1
# Objectif : Créer GPO et mapper H: pour les OU existantes
# =========================================

Import-Module GroupPolicy
Import-Module ActiveDirectory

# 🔹 Définir les GPO et OU
$gpoInfos = @(
    @{NomGPO="GPO-ADM-Poste"; OU="OU=Administration,OU=ECOLE,DC=mediaschool,DC=local"; Partage="\\SRV-FS1\Administration"},
    @{NomGPO="GPO-PROF-Poste"; OU="OU=Profs,OU=ECOLE,DC=mediaschool,DC=local"; Partage="\\SRV-FS1\Profs"},
    @{NomGPO="GPO-ELEVE-Poste"; OU="OU=Eleves,OU=ECOLE,DC=mediaschool,DC=local"; Partage="\\SRV-FS1\Eleves"}
)

$netlogonShare = "\\SRV-DC1\NETLOGON"
if (-not (Test-Path $netlogonShare)) {
    Write-Warning "Le dossier NETLOGON n'existe pas. Vérifiez le partage SYSVOL."
}

foreach ($info in $gpoInfos) {

    # 1️⃣ Créer la GPO si elle n'existe pas
    $gpo = Get-GPO -Name $info.NomGPO -ErrorAction SilentlyContinue
    if (-not $gpo) {
        $gpo = New-GPO -Name $info.NomGPO -Comment "Montage H: pour $($info.NomGPO)"
        Write-Host "GPO créée : $($info.NomGPO)"
    } else {
        Write-Host "GPO déjà existante : $($info.NomGPO)"
    }

    # 2️⃣ Lier la GPO à l'OU
    try {
        New-GPLink -Name $info.NomGPO -Target $info.OU -LinkEnabled Yes
        Write-Host "GPO $($info.NomGPO) liée à $($info.OU)"
    } catch {
        Write-Warning "Impossible de lier $($info.NomGPO) à $($info.OU) : $_"
    }

    # 3️⃣ Créer le script de logon pour mapper H:
    $scriptContent = "net use H: $($info.Partage) /persistent:yes"
    $scriptPath = Join-Path $netlogonShare "MapH_$($info.NomGPO).bat"
    $scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII
    Write-Host "Script de mapping H: créé : $scriptPath"
}

Write-Host "✅ Toutes les GPO et scripts de logon (ce qui fonctionne) ont été configurés."
