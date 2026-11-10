# Project template

Šablóna pre architektonický / konceptuálny projekt dokumentovaný v Antore.

## Čo táto šablóna obsahuje

- **Antora single-component repo** — jeden komponent `concept`, jedna úvodná stránka. Ďalšie členenie si pridáš podľa konkrétneho projektu.
- **Zdrojové diagramy** v `docs/img/` — súbory `.drawio` v podadresároch s číselným prefixom (`01-Concept`, `10-Business` …). Build ich vyexportuje do PNG.
- **Grafy a diagramy z textu** — Vega-Lite, PlantUML, C4, Structurizr a ďalšie priamo v `.adoc`. Obrázky z nich pri builde generuje lokálny Kroki server.
- **ArchiMate model** v `docs/model/` (otvárať v Archi).
- **Build skripty** v `scripts/` — HTML site (`antora/antora`), PDF (`asciidoctor/docker-asciidoctor`), export draw.io (`convoj`), Kroki server (`yuzutech/kroki`).
- **Šablóny .adoc dokumentov** v `templates/` — koncept, HLD, LLD, ADR, požiadavky.

## Štruktúra

```text
.
├── antora-playbook.yml              # Antora playbook (číta build/docs/concept)
├── package.json, package-lock.json  # rozšírenie Antory asciidoctor-kroki
├── docs/
│   ├── concept/                     # Antora komponent (name: concept, version: '0.1')
│   │   ├── antora.yml
│   │   └── modules/ROOT/
│   │       ├── nav.adoc             # navigácia
│   │       ├── concept_pdf.adoc     # PDF manifest s include::pages/...
│   │       ├── pages/index.adoc     # úvodná stránka
│   │       ├── attachments/         # prílohy stiahnuteľné z webu
│   │       └── partials/            # opakovane vkladané fragmenty (_attributes.adoc)
│   ├── img/                         # zdrojové .drawio (mimo obsahu Antory)
│   │   ├── 01-Concept/  02-Strategy/  03-Motivation/
│   │   └── 10-Business/  11-Application/  12-Technology/
│   └── model/                       # ArchiMate model (project.archimate)
├── templates/                       # AsciiDoc šablóny dokumentov
│   ├── _attributes.adoc
│   └── concept.adoc  hld.adoc  lld.adoc  adr.adoc  requirements.adoc
├── scripts/
│   ├── build_all.sh                 # export draw.io + web
│   ├── build_images.sh              # *.drawio → PNG v build/img_png (convoj)
│   ├── build_site.sh                # zostaví build/docs/concept a spustí Antoru
│   ├── build_pdf.sh                 # PDF z build/docs/concept (po build_site.sh)
│   ├── kroki_start.sh               # lokálny Kroki server (kontajner + sieť "kroki")
│   ├── serve_docs.sh                # náhľad build/site na http://localhost:8001
│   ├── sync-adoc.rules              # čo nekopírovať z docs/concept
│   └── sync-images.rules            # čo nekopírovať z build/img_png
└── build/                           # všetky výstupy (nie je v gite)
```

Prázdne adresáre drží v gite súbor `.gitkeep`.

## Prvé použitie

1. **Vytvor projekt zo šablóny:** `git clone` a zmeň `git remote`, alebo skopíruj súbory,
   spusti `git init` a urob prvý commit. Antora číta obsah z git repozitára a v repozitári
   bez commitu nenájde žiadnu stránku (web ostane prázdny).
2. V `antora-playbook.yml` uprav `site.title`.
3. V `docs/concept/antora.yml` uprav `name`, `title`, `version`. Ak chceš iný názov
   komponentu, premenuj aj adresár `docs/concept` a názov zmeň všade, kde sa opakuje
   (`start_path` a `start_page` v playbooku, cesty v `build_site.sh` a `build_pdf.sh`).
   Všetky výskyty nájdeš cez `grep -rn concept antora-playbook.yml scripts/`.
4. Píš do `docs/concept/modules/ROOT/pages/`. Novú stránku pridaj do `nav.adoc` a cez
   `include::` aj do `concept_pdf.adoc`, aby bola aj v PDF.

## Build dokumentácie

Predpoklady:

- **Docker** (Docker Desktop s integráciou do WSL),
- skripty sa spúšťajú vo **WSL** (bash, `rsync`, `curl`),
- nástroj **`convoj`** v PATH na export draw.io (beží v Docker obraze `convoj`).

```bash
./scripts/build_all.sh    # export draw.io + web   → ./build/site/index.html
./scripts/build_pdf.sh    # PDF (až po build_all)  → ./build/pdf/Project.pdf
./scripts/serve_docs.sh   # náhľad webu            → http://localhost:8001
```

Tok súborov:

```text
docs/concept/  (texty)            docs/img/  (*.drawio)
      │                                 │  build_images.sh (convoj)
      │                                 ▼
      │                           build/img_png/  (*.png)
      └───────────────┬─────────────────┘
                      │  build_site.sh (rsync)
                      ▼
            build/docs/concept/           ← zostavená kópia: texty + obrázky
              │                  │
              │ Antora           │ asciidoctor-pdf
              │ (build_site.sh)  │ (build_pdf.sh)
              ▼                  ▼
        build/site/        build/pdf/Project.pdf
```

- **Antora aj PDF čítajú iba zostavenú kópiu** `build/docs/concept/`. Zmena v `docs/` sa
  prejaví až po `build_site.sh` (alebo `build_all.sh`).
- **Prvý build** nainštaluje rozšírenie Antory do `node_modules/` (cez obraz Antory,
  Node netreba) a stiahne obraz Kroki servera.
- **Antora pred buildom vymaže `build/site`** (`output.clean`), staré stránky v ňom neostanú.
- Antora beží s `CI=true`, preto sa pri lokálnom builde nezobrazuje nefunkčný odkaz
  „Edit this Page“.

## Obrázky z draw.io

```bash
./scripts/build_images.sh                                 # len zmenené súbory
./scripts/build_images.sh -a                              # všetky súbory
./scripts/build_images.sh -f 10-Business/procesy.drawio   # jeden súbor (cesta od docs/img)
```

Exportujú sa iba súbory `.drawio`. Cesta obrázka na stránke zodpovedá ceste v `docs/img/`:

```asciidoc
// zdroj: docs/img/10-Business/procesy.drawio
image::10-Business/procesy.png[Hlavné procesy]
```

- Obrázky patria iba do `docs/img/`. Adresár `modules/ROOT/images/` v `docs/concept`
  nezakladaj, build ho v kópii prepíše obsahom `build/img_png`.
- Hotové obrázky (PNG, screenshoty) `build_images.sh` zatiaľ nekopíruje.
- PlantUML, C4 a podobné diagramy píš priamo do `.adoc` (pozri Kroki nižšie).

## Grafy a diagramy z textu (Kroki)

Graf alebo diagram sa dá zapísať priamo do `.adoc` ako text. Obrázok z neho pri builde
vygeneruje [Kroki](https://kroki.io) a vloží ho do webu aj do PDF. Hodí sa to na grafy
z údajov a na diagramy, ktoré sa často menia. Obrázky, ktoré treba ručne rozložiť,
ostávajú v draw.io.

Kroki beží ako vlastný lokálny kontajner, zdroje diagramov preto neodchádzajú
na verejný `kroki.io`.

Príklad stĺpcového grafu (Vega-Lite):

```asciidoc
.Priemerný počet poistencov
[vegalite,poistenci-vyvoj,svg]
----
{
  "$schema": "https://vega.github.io/schema/vega-lite/v6.json",
  "data": {"values": [
    {"rok": "2024", "pocet": 2789383},
    {"rok": "2025", "pocet": 2738458}
  ]},
  "mark": {"type": "bar", "cornerRadiusEnd": 4},
  "encoding": {
    "x": {"field": "rok", "type": "ordinal", "title": null},
    "y": {"field": "pocet", "type": "quantitative", "title": null, "stack": null}
  }
}
----
```

Atribúty bloku sú typ diagramu, názov súboru a formát (`svg`). Rovnako fungujú napr.
`[plantuml]`, `[c4plantuml]`, `[structurizr]` alebo `[graphviz]`. Obraz `yuzutech/kroki`
ich zvláda sám. Mermaid, BPMN a Excalidraw potrebujú ďalšie kontajnery
(`yuzutech/kroki-mermaid` a pod.).

### Ako je to zapojené

- **`scripts/kroki_start.sh`** vytvorí Docker sieť `kroki`, spustí kontajner `kroki`
  (obraz `yuzutech/kroki`) s portom len na `127.0.0.1:8000` a počká, kým odpovie.
  Volajú ho `build_site.sh` aj `build_pdf.sh`. Kontajner ostáva bežať, zastavíš ho
  príkazom `docker stop kroki`. Obraz má lokálne asi 4 GB, sťahuje sa raz na počítač.
- **`package.json`** obsahuje rozšírenie `asciidoctor-kroki` vo verzii **0.18.x**. Je to
  posledná verzia, ktorá funguje s Antorou 3.1 (obraz `antora/antora`: Node 16,
  Asciidoctor.js 2.2). Verzie 1.x a 2.x vyžadujú Asciidoctor.js 4 a Node 22.
  Inštaláciu robí `build_site.sh`, keď chýba `node_modules/asciidoctor-kroki`.
- **`antora-playbook.yml`** rozšírenie zapína (`extensions`) a nastavuje
  `kroki-server-url: http://kroki:8000` a `kroki-fetch-diagram: true`. Obrázky sa tak
  stiahnu pri builde a uložia do webu, pri prezeraní Kroki netreba.
- **Kontajnery Antory a PDF** bežia s `--network kroki`, server preto nájdu pod menom
  `kroki`. PDF používa `asciidoctor-kroki` z obrazu `docker-asciidoctor`
  (`-r asciidoctor-kroki`). Jeho `imagesoutdir` musí ukazovať na adresár `images` vedľa
  PDF manifestu, inak PDF stiahnuté obrázky nenájde.

### Tipy

- **Stĺpcové grafy v PDF:** osi y daj `"stack": null` a zaoblenie rob cez `cornerRadiusEnd`.
  Inak Vega-Lite použije orezávanie (`clip-path`), ktoré PDF renderer nepodporuje:
  vypíše varovanie a graf sa nemusí vykresliť správne.
- **Slovenský formát čísel:** do špecifikácie grafu pridaj
  `"config": {"locale": {"number": {"decimal": ",", "thousands": " ", "grouping": [3], "currency": ["", " €"]}}}`.
- **Rýchly test bez buildu:**
  `curl -s -H 'Content-Type: text/plain' --data-binary @graf.json http://127.0.0.1:8000/vegalite/svg > graf.svg`.
  Pri `Content-Type: application/json` Kroki očakáva obálku `{"diagram_source": …}`.
- **Verzia servera:** `kroki_start.sh` používa `yuzutech/kroki` bez pevnej verzie (`latest`).
  Ak treba reprodukovateľný build, zafixuj ju v skripte.
- **Prechod na novšiu Antoru** (3.2 a vyššie) bude vyžadovať aj novšiu verziu
  `asciidoctor-kroki` v `package.json`.

## Nové dokumenty zo šablóny

```bash
cp templates/hld.adoc docs/concept/modules/ROOT/pages/hld-payment.adoc
# potom ho pridaj do nav.adoc:  ** xref:hld-payment.adoc[HLD – Payment]
# a do concept_pdf.adoc:        include::pages/hld-payment.adoc[leveloffset=+1]
```

## Konvencie

- **Jazyk**: slovenčina (`lang: sk` v playbooku aj v `concept_pdf.adoc`, spolu so slovenskými popismi tabuliek, obrázkov a poznámok).
- **Page-level attributes**: `ifndef::imagesdir[:imagesdir: ../images]` na začiatku každej stránky, ktorá vkladá obrázky cez `image::...` — drží konzistentné cesty pre Antora aj asciidoctor-pdf.
- **Dual site/PDF render**: `ifdef::pdf-mode[]` / `ifndef::pdf-mode[]` pre alternatívne cesty alebo bloky pri PDF builde.
- **Diagramy**: zdrojový `.drawio` v `docs/img/<prefix-časť>/`, vygenerované PNG iba v `build/` (nie sú v gite).
- **Diff-friendly binárky**: `.gitattributes` označuje `.drawio/.archimate/.puml` ako text (aby sa diffovali) a `.png/.svg/.pdf` ako binary.

## Inšpiračné repozitáre

- `https://git.asseco-ce.com/vojtech.balint/vszp` — rovnaký build ako táto šablóna (zostavená kópia v `build/`, Kroki), graf z údajov vo Vega-Lite, adresáre stránok aj obrázkov s číselnými prefixmi.
- `https://git.asseco-ce.com/vojtech.balint/sia` — najbohatší vzor, ArchiMate model + diagramy členené po doménach.
- `https://git.asseco-ce.com/vojtech.balint/sia_jvp` — multi-component (jvp_docs + jvp2). Ak budeš chcieť pridať druhý komponent, pozri si `antora-playbook-jvp_docs.yml` + `antora-playbook-jvp2.yml`.
- `https://git.asseco-ce.com/vojtech.balint/sia_ekp` — single-component vzor s podrobnejšou navigáciou.
