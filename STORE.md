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

## Adressen

- Upload: <https://apps.garmin.com/en-US/developer/upload>
- Dashboard (eigene Apps, Updates): <https://apps.garmin.com/developer/dashboard>,
  oder auf apps.garmin.com oben rechts **Developer**
- Richtlinien: <https://developer.garmin.com/connect-iq/app-review-guidelines/> und für
  Bilder <https://developer.garmin.com/brand-guidelines/connect-iq/>

## 1. Optional: privat als Beta testen

Eine Beta kann nur dein Konto installieren. Damit lassen sich die Einstellungen in der
Connect-IQ-App und die Diagramme in Garmin Connect prüfen. Sideloadete `.prg`-Dateien können
beides nicht.

1. Eine per USB installierte `.prg` aus `GARMIN\Apps\` löschen, sonst ist das Feld doppelt
   auf der Uhr.
2. In `manifest.xml` die `id` vorübergehend auf die Beta-ID setzen:
   `d6b7b203-5652-4231-9b24-8026f0f21b43`
3. *Monkey C: Export Project* ausführen. Im Assistenten reicht **Finish**. Das erzeugt eine
   `.iq`-Datei.
4. Auf der Upload-Seite die `.iq` wählen und auf derselben ersten Seite **Beta App**
   anhaken.
5. Mit demselben Garmin-Konto über die Connect-IQ-App auf die Uhr installieren. Eine
   Aktivität aufzeichnen und speichern, dann in Garmin Connect prüfen: das Diagramm „Beers
   Earned", die Summe in der Zusammenfassung und die Biere pro Runde.
6. Danach die `id` in `manifest.xml` wieder auf `f1c3eaf0-6044-4f43-9e94-b4e38eb170b0`
   zurücksetzen.

Eine Beta lässt sich nicht in eine normale App umwandeln. Sie bleibt eine eigene App mit
eigener ID und kann im Dashboard gelöscht werden.

## 2. Release

1. `.iq` mit der richtigen App-ID (`f1c3eaf0-…`) exportieren: in VS Code *Monkey C: Export
   Project*, oder über die Kommandozeile
   `monkeyc -e -r -f monkey.jungle -o bin/BeersEarned.iq -y <developer_key>`.
2. Auf der Upload-Seite die `.iq` hochladen, **ohne** Beta-Haken. Beim ersten Mal das
   Developer Agreement akzeptieren. Garmin prüft das Paket; die Geräteliste kommt aus dem
   Manifest.
3. Danach öffnet sich der Editor für die App-Details:
   - **Titel, Beschreibung, Neuigkeiten** je Sprache mit den Texten unten
   - **Icon:** `store/store_icon_500.png`
   - **Screenshots:** höchstens 5, also `store/screenshots/1_…` bis `5_…`
   - **Cover Image & Icons**, optional: Hero-Bild `store/hero_1440x720.png`. Unter **Yes**
     die On-Device-Icons: `store/ondevice_icon_amoled_128.png` für Farbgeräte wie epix und
     Venu, `store/ondevice_icon_mip_128.png` für 64-Farben-Geräte wie fēnix. Das MIP-Icon
     muss eine indizierte PNG sein. Haben beide Icons dieselbe Größe und Pixeltiefe, lehnt
     Garmin das zweite ab („existing app icon … pixel size“).
   - **Activity Types:** die Sportarten, zu denen das Feld passt, z. B. Laufen, Radfahren,
     Wandern
   - **Preis:** kostenlos, also nicht als zahlungspflichtig markieren
4. Absenden. Neben „Verified" zeigt die Upload-Seite beim ersten Upload eventuell
   „Signature check failed". Das ist ein bekannter Store-Fehler (CIQQA-4716) und blockiert
   nicht. Die App steht dann auf *pending*: Du kannst sie schon selbst laden, öffentlich
   ist sie noch nicht. Garmin prüft sie laut SDK-Doku meist innerhalb von 72 Stunden. Das
   Ergebnis kommt per E-Mail, bei Ablehnung mit Begründung.

Für Updates: dieselbe App-ID, derselbe Schlüssel. Neue `.iq` exportieren und im Dashboard
bei der App als neue Version hochladen.

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

Die Maße folgen Garmins Brand Guidelines.

| Datei | Inhalt |
|---|---|
| `store/store_icon_500.png` | Store-Icon 500×500, sRGB, opaker Hintergrund, über 10 px Rand. Quelle: `store/store_icon.svg` |
| `store/hero_1440x720.png` | Hero- bzw. Cover-Bild 1440×720, ohne Text, gilt also für alle Sprachen |
| `store/ondevice_icon_amoled_128.png` | On-Device-Store-Icon 128×128 für Farbdisplays |
| `store/ondevice_icon_mip_128.png` | dasselbe auf die 64-Farben-Palette der MIP-Displays reduziert, als indizierte PNG |
| `store/screenshots/` | Simulator-Screenshots (fēnix 8 47 mm und fēnix 8 Solar 51 mm) |
