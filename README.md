# MultiZip - Estrattore ZIP Avanzato per Windows

MultiZip è uno **script PowerShell con interfaccia grafica (GUI)** per estrarre facilmente file ZIP e altri formati di archivio su Windows.  
Permette di selezionare una cartella sorgente e una destinazione, gestire più archivi contemporaneamente, e offre opzioni avanzate come il supporto alle password, il mantenimento della struttura delle sottocartelle e l'integrazione con 7-Zip.

---

## 📌 Caratteristiche principali

- Selezione grafica di **cartella sorgente** e **cartella destinazione**  
- Supporto per **Password** per estrarre archivi protetti.
- Estrazione di **più file ZIP/archivi** presenti nella cartella sorgente.
- Supporto esteso ai formati (7z, rar, tar, iso, ecc.) tramite integrazione con **7-Zip**.
- Opzioni configurabili:
  - Sovrascrivere file esistenti.
  - Eliminare l'archivio dopo l’estrazione.
  - Cercare archivi anche nelle sottocartelle.
  - Mantenere la struttura delle sottocartelle.  
- **Progress bar globale** per monitorare l’avanzamento.  
- Log in tempo reale con dettaglio degli errori (es. password errata).
- Interfaccia utente semplice e intuitiva, con pulsanti per aprire la destinazione.

---

## 💻 Requisiti

- Windows 10 o Windows 11  
- PowerShell 5.1 o superiore  
- **7-Zip (Consigliato):** Necessario per il supporto alle password e per formati diversi dallo .zip standard. Lo script lo cercherà automaticamente in tutto il sistema al primo avvio.

---

## 🚀 Installazione

Scarica o clona il repository GitHub:

```bash
git clone https://github.com/USERNAME/MultiZip.git
```

Apri la cartella contenente `MultiZip.ps1`.

Per eseguire lo script:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\MultiZip.ps1
```

---

## ⚙️ Configurazione (MultiZipConfig.json)

Al primo avvio, se 7-Zip non è già configurato, lo script effettuerà una ricerca automatica in tutti i dischi fissi per localizzare `7z.exe`. I risultati vengono salvati in un file chiamato `MultiZipConfig.json` nella stessa cartella dello script.

```json
{
  "Path7Zip": "C:\\Program Files\\7-Zip\\7z.exe"
}
```

- **Path7Zip:** Il percorso completo all'eseguibile di 7-Zip.
- Se vuoi forzare lo script a NON usare 7-Zip, puoi impostare il valore a stringa vuota (`""`). In questo caso verrà usata la modalità nativa di Windows (limitata ai soli file .zip senza password).

---

## 📝 Utilizzo

1. **Seleziona la cartella sorgente:** dove si trovano i file da estrarre.
2. **Seleziona la cartella destinazione:** dove verranno salvati i file estratti.
3. **Inserisci la Password (opzionale):** se gli archivi sono protetti.
4. **Spunta le opzioni desiderate:**
   - *Sovrascrivi file esistenti* → i file già presenti verranno sostituiti.
   - *Elimina ZIP dopo estrazione* → rimuove i file originali dopo il successo.
   - *Cerca ZIP anche nelle sottocartelle* → ricerca ricorsiva.
   - *Mantieni struttura delle sottocartelle* → conserva la gerarchia originale.
5. Premi **ESTRAI ZIP** per avviare l’estrazione.

---

## 🔧 Note tecniche

- **Integrazione 7-Zip:** Lo script utilizza 7-Zip come motore principale se disponibile, permettendo la gestione di archivi protetti e formati complessi.
- **Fallback Nativo:** Se 7-Zip non è installato, lo script usa il componente COM `Shell.Application` nativo di Windows (supporta solo .zip non criptati).
- **Gestione Errori:** In caso di errore (es. password errata), il log mostrerà il messaggio specifico restituito dal motore di estrazione.

---

## 📸 Screenshot

<img width="1123" height="830" alt="image" src="https://github.com/user-attachments/assets/5ac9bd10-0453-4079-92e5-1b781f7ee62f" />

---

## 📝 Licenza

Questo progetto è rilasciato sotto la MIT License.
Puoi modificare e distribuire liberamente lo script.
