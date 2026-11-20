# Veröffentlichen im Connect IQ Store

Anleitung für den kostenlosen Store-Release. Die Listing-Texte unten sind fertig zum
Einfügen, in neun Sprachen.

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
bei der App als neue Version hochladen; die Versionsnummer (z. B. 1.1.0) fragt das
Upload-Formular ab. Für eine neue Sprache im Listing-Editor die Sprache hinzufügen und
Titel, Beschreibung und Neuigkeiten aus dem passenden Abschnitt unten einfügen.

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

**What's new (1.1.0):** New languages: French, Spanish, Italian, Dutch, Czech, Polish and Portuguese. Now also on fēnix 9, Forerunner 70 and 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 and Explore 3, and on the GPSMAP 67 / H1, Montana 7 and eTrex Touch handhelds.

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

**Neuigkeiten (1.1.0):** Neue Sprachen: Französisch, Spanisch, Italienisch, Niederländisch, Tschechisch, Polnisch und Portugiesisch. Läuft jetzt auch auf fēnix 9, Forerunner 70 und 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 und Explore 3 sowie auf den Handgeräten GPSMAP 67 / H1, Montana 7 und eTrex Touch.

### Français

**Titre :** Beers Earned

**Description :**

> Transforme ton entraînement en bières ! Beers Earned convertit les calories brûlées en
> bières et affiche un verre qui se remplit jusqu'à la prochaine, avec mousse et bulles qui
> montent. Chaque bière entière gagnée déclenche un pop-up « Santé ! ».
>
> • Chope, verre à Weizen, pinte ou bouteille
> • Pils, blanche (Weizen), ambrée/lager, rousse (Red Ale) ou stout
> • S'adapte à toutes les pages de données, de 1 à 8 champs, sur écrans ronds et
>   rectangulaires
> • Fond automatique, noir ou blanc
> • Vibration et son en option pour chaque bière
> • Calories par bière réglables (150 kcal par défaut), plus des bières au départ
> • Compte en bières entières, arrondi ou avec une décimale
> • Enregistré avec ton activité : Garmin Connect affiche un graphique des bières, le total
>   dans le résumé et les bières par circuit
> • Réglages dans l'application Connect IQ ou directement sur la montre
>
> Suite gratuite de l'idée du « Beers Earned Plus », qui n'est plus disponible.
> Juste pour le plaisir : les calories sont des estimations. À consommer avec modération.

**Nouveautés (1.1.0) :** Nouvelles langues : français, espagnol, italien, néerlandais, tchèque, polonais et portugais. Compatible avec fēnix 9, Forerunner 70 et 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 et Explore 3, ainsi qu'avec les GPS portables GPSMAP 67 / H1, Montana 7 et eTrex Touch.

### Español

**Título:** Beers Earned

**Descripción:**

> ¡Convierte tu entrenamiento en cervezas! Beers Earned convierte las calorías que quemas
> en cervezas y muestra un vaso que se llena hasta la siguiente, con espuma y burbujas que
> suben. Cada cerveza entera ganada trae un aviso de «¡Salud!».
>
> • Jarra, vaso de trigo, pinta o botella
> • Pilsner, trigo (Weizen), ámbar/lager, roja (Red Ale) o stout
> • Se adapta a cualquier pantalla de datos, de 1 a 8 campos, en pantallas redondas y
>   rectangulares
> • Fondo automático, negro o blanco
> • Vibración y tono opcionales con cada cerveza
> • Calorías por cerveza ajustables (150 kcal por defecto), más cervezas al inicio
> • Cuenta cervezas enteras, redondeadas o con un decimal
> • Se guarda con tu actividad: Garmin Connect muestra un gráfico de cervezas, el total en
>   el resumen y las cervezas por vuelta
> • Ajustes en la app Connect IQ o directamente en el reloj
>
> Continuación gratuita de la idea del ya retirado «Beers Earned Plus».
> Solo por diversión: las calorías son estimaciones. Bebe con moderación.

**Novedades (1.1.0):** Nuevos idiomas: francés, español, italiano, neerlandés, checo, polaco y portugués. Compatible con fēnix 9, Forerunner 70 y 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 y Explore 3, y con los GPS de mano GPSMAP 67 / H1, Montana 7 y eTrex Touch.

### Italiano

**Titolo:** Beers Earned

**Descrizione:**

> Trasforma il tuo allenamento in birre! Beers Earned converte le calorie bruciate in birre
> e mostra un bicchiere che si riempie fino alla prossima, con schiuma e bollicine che
> salgono. Ogni birra intera guadagnata fa comparire un pop-up «Cin cin!».
>
> • Boccale, bicchiere da Weizen, pinta o bottiglia
> • Pils, Weizen, ambrata/lager, rossa (Red Ale) o stout
> • Si adatta a ogni pagina dati, da 1 a 8 campi, su schermi rotondi e rettangolari
> • Sfondo automatico, nero o bianco
> • Vibrazione e tono opzionali per ogni birra
> • Calorie per birra regolabili (150 kcal predefinite), più birre all'inizio
> • Conta birre intere, arrotondate o con un decimale
> • Salvato con l'attività: Garmin Connect mostra un grafico delle birre, il totale nel
>   riepilogo e le birre per giro
> • Impostazioni nell'app Connect IQ o direttamente sull'orologio
>
> Continuazione gratuita dell'idea alla base di «Beers Earned Plus», non più disponibile.
> Solo per divertimento: le calorie sono stime. Bevi responsabilmente.

**Novità (1.1.0):** Nuove lingue: francese, spagnolo, italiano, olandese, ceco, polacco e portoghese. Compatibile con fēnix 9, Forerunner 70 e 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 ed Explore 3 e con i palmari GPSMAP 67 / H1, Montana 7 ed eTrex Touch.

### Nederlands

**Titel:** Beers Earned

**Beschrijving:**

> Maak van je training bier! Beers Earned rekent de verbrande calorieën om in bier en toont
> een glas dat volloopt tot het volgende, met schuimkraag en opstijgende belletjes. Elk vol
> bier dat je verdient levert een "Proost!"-pop-up op.
>
> • Bierpul, weizenglas, pintglas of fles
> • Pils, weizen, amber/lager, rood (Red Ale) of stout
> • Past in elke datapagina, van 1 tot 8 velden, op ronde en rechthoekige schermen
> • Achtergrond automatisch, zwart of wit
> • Optioneel trillen en een toon bij elk bier
> • Calorieën per bier instelbaar (standaard 150 kcal), plus bieren bij de start
> • Tel hele bieren, afgerond of met één decimaal
> • Opgeslagen bij je activiteit: Garmin Connect toont een biergrafiek, het totaal in de
>   samenvatting en de bieren per ronde
> • Instellingen in de Connect IQ-app of direct op het horloge
>
> Gratis voortzetting van het idee achter het niet meer beschikbare "Beers Earned Plus".
> Alleen voor de lol: calorieën zijn schattingen. Geniet, maar drink met mate.

**Nieuw (1.1.0):** Nieuwe talen: Frans, Spaans, Italiaans, Nederlands, Tsjechisch, Pools en Portugees. Werkt nu ook op fēnix 9, Forerunner 70 en 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 en Explore 3, en op de handhelds GPSMAP 67 / H1, Montana 7 en eTrex Touch.

### Čeština

**Název:** Beers Earned

**Popis:**

> Proměň svůj trénink v pivo! Beers Earned převádí spálené kalorie na piva a ukazuje
> sklenici, která se plní k dalšímu pivu, s pěnou a stoupajícími bublinkami. Za každé celé
> vydělané pivo vyskočí okno „Na zdraví!“.
>
> • Korbel, sklenice na weizen, pinta nebo láhev
> • Světlý ležák, pšeničné, polotmavé/amber, červené (Red Ale) nebo stout
> • Hodí se do každého rozvržení datové obrazovky, od 1 do 8 polí, na kulatých
>   i obdélníkových displejích
> • Pozadí automatické, černé nebo bílé
> • Volitelně vibrace a tón za každé pivo
> • Nastavitelné kalorie na pivo (výchozí 150 kcal) a piva na začátku
> • Počítání celých piv, zaokrouhleně nebo s jedním desetinným místem
> • Ukládá se s aktivitou: Garmin Connect zobrazí graf piv, součet v přehledu a piva za
>   okruh
> • Nastavení v aplikaci Connect IQ nebo přímo v hodinkách
>
> Bezplatné pokračování nápadu, na kterém stála již nedostupná aplikace „Beers Earned Plus“.
> Jen pro zábavu: hodnoty kalorií jsou odhady. Pijte zodpovědně.

**Novinky (1.1.0):** Nové jazyky: francouzština, španělština, italština, nizozemština, čeština, polština a portugalština. Nově podporuje fēnix 9, Forerunner 70 a 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 a Explore 3 a ruční navigace GPSMAP 67 / H1, Montana 7 a eTrex Touch.

### Polski

**Tytuł:** Beers Earned

**Opis:**

> Zamień trening na piwo! Beers Earned przelicza spalone kalorie na piwa i pokazuje
> szklankę, która napełnia się do następnego piwa, z pianą i unoszącymi się bąbelkami. Za
> każde pełne zarobione piwo pojawia się okienko „Na zdrowie!”.
>
> • Kufel, szklanka do weizena, pinta lub butelka
> • Pils/jasne, pszeniczne, bursztynowe/lager, czerwone (Red Ale) lub stout
> • Pasuje do każdego układu ekranu danych, od 1 do 8 pól, na okrągłych i prostokątnych
>   ekranach
> • Tło automatyczne, czarne lub białe
> • Opcjonalnie wibracja i dźwięk przy każdym piwie
> • Regulowana liczba kalorii na piwo (domyślnie 150 kcal) oraz piwa na starcie
> • Liczenie całych piw, z zaokrągleniem lub z jednym miejscem po przecinku
> • Zapisywane z aktywnością: Garmin Connect pokazuje wykres piw, sumę w podsumowaniu
>   i piwa na okrążenie
> • Ustawienia w aplikacji Connect IQ lub bezpośrednio na zegarku
>
> Darmowa kontynuacja pomysłu wycofanej aplikacji „Beers Earned Plus”.
> Tylko dla zabawy: wartości kalorii są szacunkowe. Pij odpowiedzialnie.

**Nowości (1.1.0):** Nowe języki: francuski, hiszpański, włoski, niderlandzki, czeski, polski i portugalski. Obsługa fēnix 9, Forerunner 70 i 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 i Explore 3 oraz nawigacji ręcznych GPSMAP 67 / H1, Montana 7 i eTrex Touch.

### Português

**Título:** Beers Earned

**Descrição:**

> Transforme seu treino em cerveja! O Beers Earned converte as calorias queimadas em
> cervejas e mostra um copo que se enche até a próxima, com espuma e bolhas subindo. Cada
> cerveja inteira conquistada traz um pop-up de "Saúde!".
>
> • Caneca, copo de trigo, copo pint ou garrafa
> • Pilsen, trigo (Weizen), âmbar/lager, red ale ou stout
> • Cabe em qualquer layout de tela de dados, de 1 a 8 campos, em telas redondas e
>   retangulares
> • Fundo automático, preto ou branco
> • Vibração e som opcionais a cada cerveja
> • Calorias por cerveja ajustáveis (padrão 150 kcal), além de cervejas no início
> • Conte cervejas inteiras, arredondadas ou com uma casa decimal
> • Salvo com a atividade: o Garmin Connect mostra um gráfico de cervejas, o total no
>   resumo e as cervejas por volta
> • Configurações no app Connect IQ ou direto no relógio
>
> Continuação gratuita da ideia por trás do descontinuado "Beers Earned Plus".
> Só por diversão: as calorias são estimativas. Beba com moderação.

**Novidades (1.1.0):** Novos idiomas: francês, espanhol, italiano, holandês, tcheco, polonês e português. Agora compatível com fēnix 9, Forerunner 70 e 170, Enduro 4, MARQ (Gen 3), Approach S72, D2 Mach 2 Pro, Edge 1060 e Explore 3, e com os GPS portáteis GPSMAP 67 / H1, Montana 7 e eTrex Touch.

## Store-Material

Die Maße folgen Garmins Brand Guidelines.

| Datei | Inhalt |
|---|---|
| `store/store_icon_500.png` | Store-Icon 500×500, sRGB, opaker Hintergrund, über 10 px Rand. Quelle: `store/store_icon.svg` |
| `store/hero_1440x720.png` | Hero- bzw. Cover-Bild 1440×720, ohne Text, gilt also für alle Sprachen |
| `store/ondevice_icon_amoled_128.png` | On-Device-Store-Icon 128×128 für Farbdisplays |
| `store/ondevice_icon_mip_128.png` | dasselbe auf die 64-Farben-Palette der MIP-Displays reduziert, als indizierte PNG |
| `store/screenshots/` | Simulator-Screenshots (fēnix 8 47 mm und fēnix 8 Solar 51 mm) |
