<#
.SCOPE
Questo script estrae i servizi disabilitati sulla postazione e salva l'elenco in un file CSV.
Crea anche un file di log contenente data e ora di esecuzione insieme al numero totale di servizi disabilitati.

.DESCRIPTION
Questo script recupera l'elenco dei servizi disabilitati utilizzando il cmdlet Get-WmiObject e li filtra in base alla proprietà StartMode.
L'elenco dei servizi disabilitati viene quindi salvato in un file CSV specificato dalla variabile $CSVPath.
Se il file CSV esiste già, viene spostato nella cartella di archivio e rinominato con un timestamp.
Lo script genera anche un file di log specificato dalla variabile $LogPath.

.NOTES
- Lo script può anche richiede privilegi amministrativi per recuperare le informazioni sui servizi.
- E' possibile modificare le variabili $CSVPath e $LogPath per impostare i percorsi dei file desiderati.
- Lo script viene avviato automaticamente tramite il CMD all'avvio.
#>

# Imposta il percorso per il file CSV
$CSVPath = "C:\Windows\Temp\servizi_disabilitati.csv"

# Imposta il percorso per il file di log
$LogPath = "C:\Windows\Temp\serviziTTF.log"

try {
    # Recupera l'elenco dei servizi disabilitati
    $serviziDisabilitati = Get-WmiObject -Class Win32_Service | Where-Object { $_.StartMode -eq 'Disabled' }
    
    if ($serviziDisabilitati) {
        # Salva l'elenco dei servizi disabilitati in un file CSV
        if (Test-Path $CSVPath) {
            $percorsoArchivio = "C:\Windows\Temp\Archivio"
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $nuovoNomeCSV = "servizi_disabilitati_$timestamp.csv"
    
            if (!(Test-Path $percorsoArchivio)) {
                New-Item -ItemType Directory -Path $percorsoArchivio | Out-Null
            }
    
            Move-Item -Path $CSVPath -Destination "$percorsoArchivio\$nuovoNomeCSV"
        }
    
        $serviziDisabilitati | Export-Csv -Path $CSVPath -NoTypeInformation
    
        # Salva il log di esecuzione
        $numeroTotaleDisabilitati = $serviziDisabilitati.Count
        $oraEsecuzione = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
        "$oraEsecuzione - Numero totale di servizi disabilitati: $numeroTotaleDisabilitati" | Out-File -FilePath $LogPath -Append
    }
    else {
        # Nessun servizio disabilitato trovato
        Write-Output "Nessun servizio disabilitato trovato."
    }
}
catch {
    # Gestione degli errori
    $errore = $_.Exception.Message
    Write-Error "Si è verificato un errore durante l'esecuzione dello script: $errore"
}
