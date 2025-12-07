1️⃣ Sur le serveur DHCP (SRV-DC1)

Lister les baux DHCP actifs pour un scope donné :
Get-DhcpServerv4Lease -ScopeId 192.168.100.0 | Select-Object IPAddress, ClientId, HostName, AddressState, LeaseExpiryTime

Vérifier la durée du bail :
Get-DhcpServerv4Scope -ScopeId 192.168.100.0 | Select-Object Name, LeaseDuration

Sur le client: 
ipconfig /all -> vérifier que l'ip est bien dans le pool dhcp

2️⃣ DNS

Test de résolution directe depuis le client:
ping SRV-DC1
ping SRV-FS1

Test de résolution inverse :
nslookup 192.168.100.10
nslookup 192.168.100.20

Créer les dossiers personnels pour les élèves :
New-Item -Path "C:\Partages\Eleves\eleve1" -ItemType Directory
New-Item -Path "C:\Partages\Eleves\eleve2" -ItemType Directory
(ça s'applique aussi pour administration et profs)


1️⃣ Script PowerShell pour créer des fichiers de test
# 🔹 Dossier de test
$baseFolder = "C:\Partages\Profs\prof1"

# 🔹 Taille du fichier en Mo
$fileSizeMB = 500

# 🔹 Nombre de fichiers à créer
$fileCount = 12  # 12 x 500 Mo = 6 Go > 5 Go quota

# 🔹 Création des fichiers
for ($i = 1; $i -le $fileCount; $i++) {
    $filePath = Join-Path $baseFolder ("testfile_$i.bin")
    Write-Host "Création de $filePath ($fileSizeMB Mo)"
    
    # Générer un fichier de $fileSizeMB Mo rempli de zéros
    $bytes = New-Object byte[] (1MB)
    $fs = [System.IO.File]::Create($filePath)
    for ($j = 1; $j -le $fileSizeMB; $j++) {
        $fs.Write($bytes, 0, $bytes.Length)
    }
    $fs.Close()
}

1️⃣ Vérifier que le lecteur H: est monté
net use

Supprimer le mapping existant (même déconnecté) :
net use H: /delete

Reconnecter le lecteur :
net use H: \\SRV-FS1\Administration /persistent:yes

2️⃣ Vérifier que la GPO a été appliquée
gpresult /r


Pour simuler une connexion interdite, j'ai modifié les bytes et j'ai tenté de me connecter à un moment où c'est interdit avec comme retour accès refusé.

