# Veröffentlichen im Connect IQ Store

Anleitung für den kostenlosen Store-Release. Die Listing-Texte unten sind fertig zum
Einfügen, auf Englisch und Deutsch.

## Vorher wissen

- **Developer Key sichern.** Jede spätere Version muss mit demselben Schlüssel signiert
  sein (`W:\Code\coding\ConnectIQDevKEy\developer_key`). Geht er verloren, gibt es kein
  Update mehr unter derselben App. Lege eine Kopie außerhalb des Rechners ab. Der Schlüssel
  gehört nicht ins Repo.
- **App-ID.** Sie steht in `manifest.xml` (`f1c3eaf0-…`) und ist ab dem ersten Upload
  dauerhaft die Identität im Store. Nicht mehr ändern.
- **FIT-Felder** (`beers`, `total_beers`, `lap_beers`, IDs 0–2): nach dem Release nie
  umnummerieren und keinen anderen Typ geben, sonst passen alte Aktivitäten nicht mehr.
- **Review-Richtlinien.** Garmin lehnt Apps ab, die übermäßigen Alkoholkonsum fördern.
  Die Texte sind deshalb als Spaß formuliert und enthalten „Bitte verantwortungsvoll
  genießen". Diese Zeile drin lassen.

## 1. Optional: privat als Beta testen

Mit einer Beta-App kann man Einstellungen in der Connect-IQ-App und die Diagramme in
Garmin Connect testen, ohne öffentlich zu releasen.

1. In `manifest.xml` die `id` vorübergehend auf die Beta-ID setzen:
   `d6b7b203-5652-4231-9b24-8026f0f21b43`
2. *Monkey C: Export Project* ausführen. Das erzeugt eine `.iq`-Datei.
3. Im Developer-Portal hochladen und dabei **„Beta App"** anhaken. Die App ist nur für
   dein Konto sichtbar.
4. Über die Connect-IQ-App auf die Uhr laden, eine Aktivität aufzeichnen und speichern.
   Dann in Garmin Connect prüfen: das Diagramm „Beers Earned", die Summe in der
   Zusammenfassung und die Biere pro Runde.
5. Danach die `id` wieder auf `f1c3eaf0-6044-4f43-9e94-b4e38eb170b0` zurücksetzen.

Vorher eine per USB installierte `.prg` aus `GARMIN\Apps\` löschen, sonst ist das Feld
doppelt auf der Uhr.

## 2. Release

1. Garmin-Developer-Konto: <https://developer.garmin.com/connect-iq/> → Anmelden →
   Developer Agreement akzeptieren.
2. `.iq` exportieren: VS Code → *Monkey C: Export Project*. Alternativ über die
   Kommandozeile:
   `monkeyc -e -r -f monkey.jungle -o BeersEarned.iq -y <developer_key>`
3. Im Developer-Bereich des Stores (apps.garmin.com → Developer → *Submit an App*) die
   `.iq` hochladen. Die Geräteliste kommt automatisch aus dem Manifest.
4. Formular ausfüllen:
   - **Titel, Beschreibung, Neuigkeiten** je Sprache mit den Texten unten
   - **Preis:** kostenlos
   - **Icon**, falls verlangt: `store/store_icon_512.png`
   - **Screenshots:** `store/screenshots/*.png`
   - **Version**, falls gefragt: `1.0.0`
5. Absenden. Das Review dauert laut Garmin meist bis zu 72 Stunden; das Ergebnis kommt
   per E-Mail.

Für Updates: dieselbe App-ID, derselbe Schlüssel, höhere Versionsnummer, *Upload new
version*.

## Listing-Texte

### English

**Title:** Beers Earned

**Description:**

> Turn your workout into beers! Beers Earned converts the calories you burn into beers and
> shows a glass filling up toward your next one, with foam and rising bubbles. Every whole
> beer earned gets a "Cheers!" pop-up.
>
> • Mug, wheat-beer glass, pint glass or bottle
> • Pilsner, Hefeweizen, Amber/Lager, Red Ale or Stout
> • Fits any data screen layout, from 1 to 8 fields, on round and rectangular screens
> • Automatic, black or white background
> • Optional vibration and tone for each beer
> • Calories per beer adjustable (default 150 kcal), plus beers at start
> • Count whole beers, rounded, or with one decimal
> • Saved with your activity: Garmin Connect shows a beers chart, the total in the summary,
>   and beers per lap
> • Settings in the Connect IQ app or right on the watch
>
> A free continuation of the idea behind the discontinued "Beers Earned Plus".
> Just for fun: calorie values are estimates. Please drink responsibly.

**What's new (1.0.0):** First release.

### Deutsch

**Titel:** Beers Earned

**Beschreibung:**

> Mach aus deinem Training Bier! Beers Earned rechnet die verbrannten Kalorien in Biere um
> und zeigt ein Glas, das sich bis zum nächsten Bier füllt, mit Schaumkrone und
> aufsteigenden Bläschen. Für jedes volle Bier gibt es ein „Prost!"-Pop-up.
>
> • Bierkrug, Weißbierglas, Pintglas oder Flasche
> • Pils, Hefeweizen, Märzen/Amber, Rotbier oder Stout
> • Passt in jedes Datenseiten-Layout, von 1 bis 8 Feldern, auf runden und eckigen Displays
> • Hintergrund automatisch, schwarz oder weiß
> • Auf Wunsch Vibration und Ton bei jedem Bier
> • Kalorien pro Bier einstellbar (Standard 150 kcal), dazu Biere zu Beginn
> • Zählweise ganze Biere, gerundet oder mit einer Nachkommastelle
> • Wird mit der Aktivität gespeichert: Garmin Connect zeigt ein Bier-Diagramm, die Summe
>   in der Zusammenfassung und die Biere pro Runde
> • Einstellungen in der Connect-IQ-App oder direkt auf der Uhr
>
> Kostenlose Fortsetzung der Idee hinter dem eingestellten „Beers Earned Plus".
> Nur zum Spaß: Kalorienwerte sind Schätzungen. Bitte verantwortungsvoll genießen.

**Neuigkeiten (1.0.0):** Erste Version.

## Store-Material

| Datei | Inhalt |
|---|---|
| `store/store_icon_512.png` | Store-Icon 512×512, aus `store/store_icon.svg` |
| `store/screenshots/` | Screenshots aus dem Simulator (fēnix 8 47 mm und 51 mm Solar) |
