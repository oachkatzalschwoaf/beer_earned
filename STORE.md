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
> • Eight drinks, each with its own look: mug, Pilsner, wheat beer, bottled beer, stout,
>   cola, Spezi or herbal soda
> • Fits any data screen layout, from 1 to 8 fields, on round and rectangular screens
> • Automatic, black or white background
> • Optional vibration and tone for each beer
> • Calories per drink preset for each one and adjustable on a number pad
> • Count with one decimal, in whole drinks or rounded
> • Saved with your activity: Garmin Connect shows a beers chart, the total in the summary,
>   and beers per lap
> • Settings in the Connect IQ app or right on the watch
>
> A free continuation of the idea behind the discontinued "Beers Earned Plus".
> Just for fun: calorie values are estimates. Please drink responsibly.

**What's new (1.2.0):** Beer and glass are now one "Drink" setting, and cola, Spezi and herbal soda are new. Each drink brings its calories; type your own on the new number pad. The count shows one decimal by default and every activity starts at zero.

### Deutsch

**Titel:** Beers Earned

**Beschreibung:**

> Mach aus deinem Training Bier! Beers Earned rechnet die verbrannten Kalorien in Biere um
> und zeigt ein Glas, das sich bis zum nächsten Bier füllt, mit Schaumkrone und
> aufsteigenden Bläschen. Für jedes volle Bier gibt es ein „Prost!"-Pop-up.
>
> • Acht Getränke mit eigenem Aussehen: Krug, Pils, Weizen, Flaschenbier, Stout, Cola,
>   Spezi oder Kräuterlimo
> • Passt in jedes Datenseiten-Layout, von 1 bis 8 Feldern, auf runden und eckigen Displays
> • Hintergrund automatisch, schwarz oder weiß
> • Auf Wunsch Vibration und Ton bei jedem Bier
> • Kalorien je Getränk voreingestellt und über ein Tastenfeld änderbar
> • Zählweise mit einer Nachkommastelle, in ganzen Getränken oder gerundet
> • Wird mit der Aktivität gespeichert: Garmin Connect zeigt ein Bier-Diagramm, die Summe
>   in der Zusammenfassung und die Biere pro Runde
> • Einstellungen in der Connect-IQ-App oder direkt auf der Uhr
>
> Kostenlose Fortsetzung der Idee hinter dem eingestellten „Beers Earned Plus".
> Nur zum Spaß: Kalorienwerte sind Schätzungen. Bitte verantwortungsvoll genießen.

**Neuigkeiten (1.2.0):** Bier und Glas sind jetzt eine Einstellung „Getränk“, neu sind Cola, Spezi und Kräuterlimo. Jedes Getränk bringt seine Kalorien mit; eigene Werte gibst du über das neue Tastenfeld ein. Gezählt wird standardmäßig mit einer Nachkommastelle, und jede Aktivität startet bei null.

### Français

**Titre :** Beers Earned

**Description :**

> Transforme ton entraînement en bières ! Beers Earned convertit les calories brûlées en
> bières et affiche un verre qui se remplit jusqu'à la prochaine, avec mousse et bulles qui
> montent. Chaque bière entière gagnée déclenche un pop-up « Santé ! ».
>
> • Huit boissons, chacune avec son style : chope, pils, blanche, bière en bouteille,
>   stout, cola, Spezi ou soda aux herbes
> • S'adapte à toutes les pages de données, de 1 à 8 champs, sur écrans ronds et
>   rectangulaires
> • Fond automatique, noir ou blanc
> • Vibration et son en option pour chaque bière
> • Calories préréglées pour chaque boisson, modifiables sur un pavé numérique
> • Compte avec une décimale, en boissons entières ou arrondi
> • Enregistré avec ton activité : Garmin Connect affiche un graphique des bières, le total
>   dans le résumé et les bières par circuit
> • Réglages dans l'application Connect IQ ou directement sur la montre
>
> Suite gratuite de l'idée du « Beers Earned Plus », qui n'est plus disponible.
> Juste pour le plaisir : les calories sont des estimations. À consommer avec modération.

**Nouveautés (1.2.0) :** Bière et verre forment un seul réglage « Boisson », avec en plus cola, Spezi et soda aux herbes. Chaque boisson apporte ses calories ; saisis les tiennes sur le nouveau pavé numérique. Une décimale par défaut, et chaque activité commence à zéro.

### Español

**Título:** Beers Earned

**Descripción:**

> ¡Convierte tu entrenamiento en cervezas! Beers Earned convierte las calorías que quemas
> en cervezas y muestra un vaso que se llena hasta la siguiente, con espuma y burbujas que
> suben. Cada cerveza entera ganada trae un aviso de «¡Salud!».
>
> • Ocho bebidas, cada una con su aspecto: jarra, pilsner, trigo, botellín, stout, cola,
>   Spezi o refresco de hierbas
> • Se adapta a cualquier pantalla de datos, de 1 a 8 campos, en pantallas redondas y
>   rectangulares
> • Fondo automático, negro o blanco
> • Vibración y tono opcionales con cada cerveza
> • Calorías preajustadas para cada bebida y modificables con un teclado numérico
> • Cuenta con un decimal, en bebidas enteras o redondeadas
> • Se guarda con tu actividad: Garmin Connect muestra un gráfico de cervezas, el total en
>   el resumen y las cervezas por vuelta
> • Ajustes en la app Connect IQ o directamente en el reloj
>
> Continuación gratuita de la idea del ya retirado «Beers Earned Plus».
> Solo por diversión: las calorías son estimaciones. Bebe con moderación.

**Novedades (1.2.0):** Cerveza y vaso son ahora un solo ajuste «Bebida», con cola, Spezi y refresco de hierbas como novedades. Cada bebida trae sus calorías; escribe las tuyas en el nuevo teclado numérico. Por defecto un decimal, y cada actividad empieza en cero.

### Italiano

**Titolo:** Beers Earned

**Descrizione:**

> Trasforma il tuo allenamento in birre! Beers Earned converte le calorie bruciate in birre
> e mostra un bicchiere che si riempie fino alla prossima, con schiuma e bollicine che
> salgono. Ogni birra intera guadagnata fa comparire un pop-up «Cin cin!».
>
> • Otto bevande, ognuna con il suo aspetto: boccale, pils, weizen, birra in bottiglia,
>   stout, cola, Spezi o bibita alle erbe
> • Si adatta a ogni pagina dati, da 1 a 8 campi, su schermi rotondi e rettangolari
> • Sfondo automatico, nero o bianco
> • Vibrazione e tono opzionali per ogni birra
> • Calorie preimpostate per ogni bevanda e modificabili con un tastierino
> • Conta con un decimale, in bevande intere o arrotondate
> • Salvato con l'attività: Garmin Connect mostra un grafico delle birre, il totale nel
>   riepilogo e le birre per giro
> • Impostazioni nell'app Connect IQ o direttamente sull'orologio
>
> Continuazione gratuita dell'idea alla base di «Beers Earned Plus», non più disponibile.
> Solo per divertimento: le calorie sono stime. Bevi responsabilmente.

**Novità (1.2.0):** Birra e bicchiere sono ora un'unica impostazione «Bevanda», con in più cola, Spezi e bibita alle erbe. Ogni bevanda ha le sue calorie; inserisci le tue con il nuovo tastierino. Un decimale come predefinito, e ogni attività parte da zero.

### Nederlands

**Titel:** Beers Earned

**Beschrijving:**

> Maak van je training bier! Beers Earned rekent de verbrande calorieën om in bier en toont
> een glas dat volloopt tot het volgende, met schuimkraag en opstijgende belletjes. Elk vol
> bier dat je verdient levert een "Proost!"-pop-up op.
>
> • Acht drankjes met elk een eigen uiterlijk: bierpul, pils, weizen, flesje bier, stout,
>   cola, Spezi of kruidenfris
> • Past in elke datapagina, van 1 tot 8 velden, op ronde en rechthoekige schermen
> • Achtergrond automatisch, zwart of wit
> • Optioneel trillen en een toon bij elk bier
> • Calorieën per drankje vooraf ingesteld en aan te passen met een cijferblok
> • Tel met één decimaal, in hele drankjes of afgerond
> • Opgeslagen bij je activiteit: Garmin Connect toont een biergrafiek, het totaal in de
>   samenvatting en de bieren per ronde
> • Instellingen in de Connect IQ-app of direct op het horloge
>
> Gratis voortzetting van het idee achter het niet meer beschikbare "Beers Earned Plus".
> Alleen voor de lol: calorieën zijn schattingen. Geniet, maar drink met mate.

**Nieuw (1.2.0):** Bier en glas zijn nu één instelling "Drank", nieuw zijn cola, Spezi en kruidenfris. Elk drankje heeft zijn eigen calorieën; voer eigen waarden in met het nieuwe cijferblok. Standaard één decimaal, en elke activiteit begint bij nul.

### Čeština

**Název:** Beers Earned

**Popis:**

> Proměň svůj trénink v pivo! Beers Earned převádí spálené kalorie na piva a ukazuje
> sklenici, která se plní k dalšímu pivu, s pěnou a stoupajícími bublinkami. Za každé celé
> vydělané pivo vyskočí okno „Na zdraví!“.
>
> • Osm nápojů, každý s vlastním vzhledem: korbel, pils, pšeničné, lahvové pivo, stout,
>   cola, Spezi nebo bylinná limonáda
> • Hodí se do každého rozvržení datové obrazovky, od 1 do 8 polí, na kulatých
>   i obdélníkových displejích
> • Pozadí automatické, černé nebo bílé
> • Volitelně vibrace a tón za každé pivo
> • Kalorie přednastavené pro každý nápoj a upravitelné na číselné klávesnici
> • Počítání s jedním desetinným místem, v celých nápojích nebo zaokrouhleně
> • Ukládá se s aktivitou: Garmin Connect zobrazí graf piv, součet v přehledu a piva za
>   okruh
> • Nastavení v aplikaci Connect IQ nebo přímo v hodinkách
>
> Bezplatné pokračování nápadu, na kterém stála již nedostupná aplikace „Beers Earned Plus“.
> Jen pro zábavu: hodnoty kalorií jsou odhady. Pijte zodpovědně.

**Novinky (1.2.0):** Pivo a sklenice jsou nyní jedno nastavení „Nápoj“, nově je tu cola, Spezi a bylinná limonáda. Každý nápoj má své kalorie; vlastní hodnotu zadáte na nové číselné klávesnici. Výchozí je jedno desetinné místo a každá aktivita začíná od nuly.

### Polski

**Tytuł:** Beers Earned

**Opis:**

> Zamień trening na piwo! Beers Earned przelicza spalone kalorie na piwa i pokazuje
> szklankę, która napełnia się do następnego piwa, z pianą i unoszącymi się bąbelkami. Za
> każde pełne zarobione piwo pojawia się okienko „Na zdrowie!”.
>
> • Osiem napojów, każdy z własnym wyglądem: kufel, pils, pszeniczne, piwo butelkowe,
>   stout, cola, Spezi lub napój ziołowy
> • Pasuje do każdego układu ekranu danych, od 1 do 8 pól, na okrągłych i prostokątnych
>   ekranach
> • Tło automatyczne, czarne lub białe
> • Opcjonalnie wibracja i dźwięk przy każdym piwie
> • Kalorie ustawione dla każdego napoju, do zmiany na klawiaturze numerycznej
> • Liczenie z jednym miejscem po przecinku, w całych napojach lub z zaokrągleniem
> • Zapisywane z aktywnością: Garmin Connect pokazuje wykres piw, sumę w podsumowaniu
>   i piwa na okrążenie
> • Ustawienia w aplikacji Connect IQ lub bezpośrednio na zegarku
>
> Darmowa kontynuacja pomysłu wycofanej aplikacji „Beers Earned Plus”.
> Tylko dla zabawy: wartości kalorii są szacunkowe. Pij odpowiedzialnie.

**Nowości (1.2.0):** Piwo i szklanka to teraz jedno ustawienie „Napój”, nowe są cola, Spezi i napój ziołowy. Każdy napój ma swoje kalorie; własne wpiszesz na nowej klawiaturze numerycznej. Domyślnie jedno miejsce po przecinku, a każda aktywność zaczyna od zera.

### Português

**Título:** Beers Earned

**Descrição:**

> Transforme seu treino em cerveja! O Beers Earned converte as calorias queimadas em
> cervejas e mostra um copo que se enche até a próxima, com espuma e bolhas subindo. Cada
> cerveja inteira conquistada traz um pop-up de "Saúde!".
>
> • Oito bebidas, cada uma com seu visual: caneca, pilsen, trigo, cerveja de garrafa,
>   stout, cola, Spezi ou refrigerante de ervas
> • Cabe em qualquer layout de tela de dados, de 1 a 8 campos, em telas redondas e
>   retangulares
> • Fundo automático, preto ou branco
> • Vibração e som opcionais a cada cerveja
> • Calorias predefinidas para cada bebida e ajustáveis em um teclado numérico
> • Conte com uma casa decimal, em bebidas inteiras ou arredondadas
> • Salvo com a atividade: o Garmin Connect mostra um gráfico de cervejas, o total no
>   resumo e as cervejas por volta
> • Configurações no app Connect IQ ou direto no relógio
>
> Continuação gratuita da ideia por trás do descontinuado "Beers Earned Plus".
> Só por diversão: as calorias são estimativas. Beba com moderação.

**Novidades (1.2.0):** Cerveja e copo agora são um só ajuste "Bebida", com cola, Spezi e refrigerante de ervas como novidades. Cada bebida traz suas calorias; digite as suas no novo teclado numérico. O padrão é uma casa decimal, e cada atividade começa do zero.

## Store-Material

Die Maße folgen Garmins Brand Guidelines.

| Datei | Inhalt |
|---|---|
| `store/store_icon_500.png` | Store-Icon 500×500, sRGB, opaker Hintergrund, über 10 px Rand. Quelle: `store/store_icon.svg` |
| `store/hero_1440x720.png` | Hero- bzw. Cover-Bild 1440×720, ohne Text, gilt also für alle Sprachen |
| `store/ondevice_icon_amoled_128.png` | On-Device-Store-Icon 128×128 für Farbdisplays |
| `store/ondevice_icon_mip_128.png` | dasselbe auf die 64-Farben-Palette der MIP-Displays reduziert, als indizierte PNG |
| `store/screenshots/` | Simulator-Screenshots: `1_` bis `5_` für den Store (fēnix 8 47 mm). Reserve: drei Felder auf der fēnix 8 Solar 51 mm und alle Getränke im Edge-1040-Rahmen |
