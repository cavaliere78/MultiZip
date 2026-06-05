Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Helper per normalizzare i percorsi
function Get-NormalPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    try {
        $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
        return $resolved.Path
    } catch {
        # Se non risolvibile (p.es. non esiste ancora), prova a costruire percorso assoluto
        try { return [System.IO.Path]::GetFullPath($Path) } catch { return $Path }
    }
}

### ===== GESTIONE CONFIGURAZIONE E RILEVAMENTO 7-ZIP ===== ###
$configFile = Join-Path $PSScriptRoot "MultiZipConfig.json"
$config = @{}

if (Test-Path $configFile) {
    try {
        $json = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($json) {
            foreach ($prop in $json.PSObject.Properties) {
                $config[$prop.Name] = $prop.Value
            }
        }
    } catch {
        Write-Host "Errore nel caricamento del file di configurazione. Verrà ricreato."
    }
}

$exe7z = ""
$has7z = $false

if ($config.ContainsKey("Path7Zip") -and $config["Path7Zip"] -ne $null) {
    $exe7z = $config["Path7Zip"]
} else {
    # Ricerca 7-Zip
    $searchPaths = @(
        (Join-Path $PSScriptRoot "7z.exe"),
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe"
    )
    
    foreach ($p in $searchPaths) { if (Test-Path $p) { $exe7z = $p; break } }

    if ([string]::IsNullOrWhiteSpace($exe7z)) {
        # Ricerca profonda in tutti i dischi fissi
        Write-Host "7-Zip non trovato nei percorsi standard. Ricerca nel sistema in corso (potrebbe richiedere tempo)..."
        
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -match ":" -or $_.Root -match ":" }
        foreach ($d in $drives) {
            $found = Get-ChildItem -Path $d.Root -Filter "7z.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { $exe7z = $found.FullName; break }
        }
    }

    # Salva nel JSON
    $config["Path7Zip"] = $exe7z
    $config | ConvertTo-Json | Set-Content $configFile
}

if (-not [string]::IsNullOrWhiteSpace($exe7z) -and (Test-Path $exe7z)) {
    $has7z = $true
}

### ===== FORM PRINCIPALE ===== ###
$form = New-Object System.Windows.Forms.Form
$form.Text = "Estrattore ZIP Avanzato"
$form.Size = New-Object System.Drawing.Size(750,580)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI",10)
$form.AutoScroll = $true

### ------ LABELS E INPUT ------ ###
# Sorgente
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "Cartella sorgente:"
$lblSource.Location = "10,20"
$lblSource.AutoSize = $true
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = "150,18"
$txtSource.Size = "450,25"
$form.Controls.Add($txtSource)

$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Sfoglia"
$btnSource.Location = "610,17"
$btnSource.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if($dialog.ShowDialog() -eq "OK"){ $txtSource.Text = $dialog.SelectedPath }
})
$form.Controls.Add($btnSource)

# Destinazione
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "Cartella destinazione:"
$lblDest.Location = "10,60"
$lblDest.AutoSize = $true
$form.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = "150,58"
$txtDest.Size = "450,25"
$form.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Sfoglia"
$btnDest.Location = "610,57"
$btnDest.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if($dialog.ShowDialog() -eq "OK"){ $txtDest.Text = $dialog.SelectedPath }
})
$form.Controls.Add($btnDest)

# Apri destinazione
$btnApriDest = New-Object System.Windows.Forms.Button
$btnApriDest.Text = "Apri destinazione"
$btnApriDest.Location = "610,90"
$btnApriDest.Size = "120,25"
$btnApriDest.Add_Click({
    if(Test-Path -LiteralPath $txtDest.Text){
        Start-Process $txtDest.Text
    }
})
$form.Controls.Add($btnApriDest)

### ------ OPZIONI ------ ###
$chkDelete = New-Object System.Windows.Forms.CheckBox
$chkDelete.Text = "Elimina ZIP dopo estrazione"
$chkDelete.Location = "10,100"
$chkDelete.AutoSize = $false
$chkDelete.Size = New-Object System.Drawing.Size(300,25)
$form.Controls.Add($chkDelete)

$chkOverwrite = New-Object System.Windows.Forms.CheckBox
$chkOverwrite.Text = "Sovrascrivi file esistenti"
$chkOverwrite.Location = "10,130"
$chkOverwrite.AutoSize = $false
$chkOverwrite.Size = New-Object System.Drawing.Size(300,25)
$form.Controls.Add($chkOverwrite)

$chkRecursive = New-Object System.Windows.Forms.CheckBox
$chkRecursive.Text = "Cerca ZIP anche nelle sottocartelle"
$chkRecursive.Location = "10,160"
$chkRecursive.AutoSize = $false
$chkRecursive.Size = New-Object System.Drawing.Size(350,25)
$form.Controls.Add($chkRecursive)

$chkKeepStructure = New-Object System.Windows.Forms.CheckBox
$chkKeepStructure.Text = "Mantieni la struttura delle sottocartelle"
$chkKeepStructure.Location = "10,190"
$chkKeepStructure.AutoSize = $false
$chkKeepStructure.Size = New-Object System.Drawing.Size(380,25)
$form.Controls.Add($chkKeepStructure)

# Password
$lblPass = New-Object System.Windows.Forms.Label
$lblPass.Text = "Password (opzionale):"
$lblPass.Location = "10,220"
$lblPass.AutoSize = $true
$form.Controls.Add($lblPass)

$txtPass = New-Object System.Windows.Forms.TextBox
$txtPass.Location = "150,218"
$txtPass.Size = "200,25"
$txtPass.PasswordChar = '*'
$form.Controls.Add($txtPass)

### ------ LOG ------ ###
$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text = "Log operazioni:"
$lblLog.Location = "10,255"
$lblLog.AutoSize = $true
$form.Controls.Add($lblLog)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = "10,280"
$txtLog.Size = "680,140"
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$form.Controls.Add($txtLog)

### ------ PROGRESS BAR ------ ###
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = "10,430"
$progress.Size = "680,20"
$form.Controls.Add($progress)

### ------ BOTTONE ESEGUI ------ ###
$btnExtract = New-Object System.Windows.Forms.Button
$btnExtract.Text = "ESTRAI ZIP"
$btnExtract.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$btnExtract.Location = "280,455"
$btnExtract.Size = "150,35"

$btnExtract.Add_Click({

    $source = Get-NormalPath $txtSource.Text
    $dest   = Get-NormalPath $txtDest.Text
    $pass   = $txtPass.Text

    $txtLog.AppendText("=== Avvio estrazione ===`r`n")

    if([string]::IsNullOrWhiteSpace($source) -or -not (Test-Path -LiteralPath $source)){
        [System.Windows.Forms.MessageBox]::Show("La cartella sorgente non esiste o è vuota.","Errore")
        return
    }

    if([string]::IsNullOrWhiteSpace($dest)){
        [System.Windows.Forms.MessageBox]::Show("La cartella destinazione non è valida.","Errore")
        return
    }

    # Crea la destinazione principale (se non esiste)
    [void][System.IO.Directory]::CreateDirectory($dest)

    # Cerca Archivi
    $zipFiles = Get-ChildItem -LiteralPath $source -Recurse:$chkRecursive.Checked -File | Where-Object {
        if ($has7z) {
            $_.Extension -match "\.(zip|7z|rar|tar|gz|tgz|bz2|tbz2|xz|txz|iso|cab|wim|vhd|vmdk|rar|arj)$"
        } else {
            $_.Extension -eq ".zip"
        }
    }

    if(-not $zipFiles -or $zipFiles.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Nessun archivio trovato.","Info")
        return
    }

    # Shell COM
    $shell = New-Object -ComObject Shell.Application

    # Calcola numero totale di file in tutti gli ZIP
    $totalItems = 0
    foreach ($zip in $zipFiles) {
        if ($has7z) {
            if ((& $exe7z l $zip.FullName "-p$pass" | Out-String) -match "(\d+)\s+files") { 
                $totalItems += [int]$matches[1] 
            }
        } else {
            $zipFolder = $shell.NameSpace($zip.FullName)
            if ($zipFolder -ne $null) { $totalItems += $zipFolder.Items().Count }
        }
    }

    if ($totalItems -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Nessun file da estrarre.","Info")
        return
    }

    # Imposta progress bar globale
    $progress.Minimum = 0
    $progress.Maximum = $totalItems
    $progress.Value = 0

    # Determina flag per CopyHere
    $copyFlags = 0x04   # non mostra UI
    if ($chkOverwrite.Checked) {
		$copyFlags =  0x04 + 0x10   # non mostra UI
    }

    foreach ($zip in $zipFiles) {

        $txtLog.AppendText("Apro ZIP: $($zip.FullName)`r`n")
        [System.Windows.Forms.Application]::DoEvents()
        
        # Determina la destinazione
        if($chkKeepStructure.Checked){
            $relativePath = $zip.DirectoryName.Substring($source.Length).TrimStart('\')
            $extractPath  = Join-Path $dest $relativePath
        } else {
            $extractPath  = $dest
        }

        # Normalizza/crea la cartella di estrazione
        [void][System.IO.Directory]::CreateDirectory($extractPath)

        # Risolvi il percorso per la Shell
        $extractPathResolved = Get-NormalPath $extractPath

        try {
            if ($has7z) {
                $txtLog.AppendText("Estrazione con 7-Zip: $($zip.Name)...`r`n")
                $ovr = if ($chkOverwrite.Checked) { "-y" } else { "-aos" }
                $args = @("x", "$($zip.FullName)", "-o$extractPathResolved", "-p$pass", $ovr)
                
                # Esegue e cattura l'output (stdout + stderr)
                $output = & $exe7z $args 2>&1
                
                if ($LASTEXITCODE -ne 0) {
                    if ($LASTEXITCODE -eq 1) {
                        $txtLog.AppendText("AVVISO 7-Zip (Codice 1 - Archivio con problemi minori):`r`n")
                    } else {
                        $txtLog.AppendText("ERRORE 7-Zip (Codice $LASTEXITCODE):`r`n")
                    }
                    
                    # Cerca righe di errore significative
                    $relevantError = $output | Where-Object { 
                        $_ -match "Error:" -or 
                        $_ -match "ERROR:" -or 
                        $_ -match "ERRORS:" -or
                        $_ -match "Unexpected end of archive" -or
                        $_ -match "Wrong password" -or
                        $_ -match "Data error"
                    }
                    
                    if ($relevantError) {
                        foreach($err in $relevantError) { 
                            $cleanErr = $err.ToString().Trim()
                            if ($cleanErr) { $txtLog.AppendText("  $cleanErr`r`n") }
                        }
                    } else {
                        $txtLog.AppendText("  Dettagli non rilevati. Controlla l'integrità dell'archivio.`r`n")
                    }
                }
                
                # Se l'estrazione è comunque avvenuta (es. codice 1) o ha avuto successo (codice 0)
                if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
                    # Aggiorna progress bar per i file in questo zip
                    if ((& $exe7z l $zip.FullName "-p$pass" | Out-String) -match "(\d+)\s+files") { 
                        $progress.Value += [int]$matches[1] 
                    }
                }
                [System.Windows.Forms.Application]::DoEvents()
            } else {
                # Fallback nativo (solo per .zip)
                $zipFolder  = $shell.NameSpace($zip.FullName)
                $destFolder = $shell.NameSpace($extractPathResolved)

                if ($zipFolder -eq $null){
                    $txtLog.AppendText("ERRORE: Il file ZIP è corrotto o non accessibile.`r`n")
                    continue
                }
                if ($destFolder -eq $null){
                    $txtLog.AppendText("ERRORE: Impossibile aprire cartella di destinazione: $extractPathResolved`r`n")
                    continue
                }

                $items = $zipFolder.Items()
                $totalEntries = $items.Count
                if ($totalEntries -eq 0) {
                    $txtLog.AppendText("ZIP vuoto: $($zip.Name)`r`n")
                    continue
                }

                foreach ($item in $items) {

                    # Aggiorna progress bar globale
                    $progress.Value++
                    [System.Windows.Forms.Application]::DoEvents()

                    # Log
                    $txtLog.AppendText("Estrazione: $($item.Name)`r`n")
                    [System.Windows.Forms.Application]::DoEvents()

                    # Estrazione con flag
                    $destFolder.CopyHere($item, $copyFlags)

                    Start-Sleep -Milliseconds 50
                }
            }

            if ($chkDelete.Checked){
                Remove-Item -LiteralPath $zip.FullName -Force
                $txtLog.AppendText("ZIP eliminato.`r`n")
            }

        } catch {
            $txtLog.AppendText("ERRORE durante l'estrazione: $($_.Exception.Message)`r`n")
        }
    }
    # Assicura progress bar a 100% a fine processo
    $progress.Value = $progress.Maximum
    [System.Windows.Forms.Application]::DoEvents()

    [System.Windows.Forms.MessageBox]::Show("Estrazione completata!","Fatto")
    $txtLog.AppendText("=== Completato ===`r`n")
})

$form.Controls.Add($btnExtract)

### ------ MOSTRA FORM ------ ###
$form.ShowDialog()
