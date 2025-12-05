# MultiZip - Estrattore ZIP Avanzato per Windows

MultiZip è uno **script PowerShell con interfaccia grafica (GUI)** per estrarre facilmente file ZIP su Windows.  
Permette di selezionare una cartella sorgente e una destinazione, gestire più ZIP contemporaneamente, e offre opzioni avanzate come mantenere la struttura delle sottocartelle, sovrascrivere file esistenti o eliminare gli ZIP originali dopo l’estrazione.

---

## 📌 Caratteristiche principali

- Selezione grafica di **cartella sorgente** e **cartella destinazione**  
- Estrazione di **più file ZIP** presenti nella cartella sorgente  
- Opzioni configurabili:
  - Sovrascrivere file esistenti
  - Eliminare ZIP dopo l’estrazione
  - Cercare ZIP anche nelle sottocartelle
  - Mantenere la struttura delle sottocartelle  
- **Progress bar globale** per monitorare l’avanzamento  
- Log in tempo reale delle operazioni eseguite  
- Interfaccia utente semplice e intuitiva, con pulsanti per aprire la destinazione

---

## 💻 Requisiti

- Windows 10 o Windows 11  
- PowerShell 5.1 o superiore  
- Nessuna libreria esterna richiesta (usa solo **System.Windows.Forms** e **System.Drawing**)  

---

## 🚀 Installazione

Scarica o clona il repository GitHub:

```bash
git clone https://github.com/USERNAME/MultiZip.git

Apri la cartella contenente MultiZip.ps1.

Per eseguire lo script:

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\MultiZip.ps1


Nota: se l’esecuzione di script è bloccata, è necessario modificare la politica di esecuzione come sopra.

📝 Utilizzo

Seleziona la cartella sorgente: dove si trovano i file ZIP.

Seleziona la cartella destinazione: dove verranno estratti i file.

Spunta le opzioni desiderate:

Sovrascrivi file esistenti → i file già presenti verranno sovrascritti senza chiedere conferma

Elimina ZIP dopo estrazione → rimuove i file ZIP originali

Cerca ZIP anche nelle sottocartelle → ricerca ricorsiva di ZIP

Mantieni struttura delle sottocartelle → conserva la gerarchia delle cartelle del ZIP

Premi ESTRAI ZIP per avviare l’estrazione.

Il log mostrerà i file estratti e eventuali errori.

Alla fine, un messaggio confermerà il completamento.

⚙️ Funzionamento della progress bar

La progress bar mostra l’avanzamento globale dell’estrazione, basata sul numero totale di file da tutti i ZIP.

Il log viene aggiornato in tempo reale per ogni file estratto.

Lo script usa Start-Sleep -Milliseconds 50 per rendere la barra più fluida durante l’estrazione di file piccoli.

🔧 Note tecniche

Lo script utilizza il componente COM Shell.Application per gestire l’estrazione dei file ZIP, sfruttando l’infrastruttura nativa di Windows.

Se il flag Sovrascrivi file esistenti non è selezionato, la GUI di Windows chiederà conferma in caso di conflitto sui file già presenti.

Tutti i file vengono estratti direttamente nella cartella di destinazione o, se selezionato, nella sottocartella corrispondente al percorso interno del ZIP.

📸 Screenshot

<img width="1123" height="830" alt="image" src="https://github.com/user-attachments/assets/5ac9bd10-0453-4079-92e5-1b781f7ee62f" />



📝 Licenza

Questo progetto è rilasciato sotto la MIT License.
Puoi modificare e distribuire liberamente lo script.
