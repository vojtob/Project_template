# Project template

Šablóna pre architektonický / konceptuálny projekt v Asseco CE.
Vychádza zo zvyklostí repozitárov **SIA**, **SIA_JVP** a **SIA_EKP**.

## Čo táto šablóna obsahuje

- **Antora single-component repo** — jeden komponent `concept`, jedna úvodná stránka. Ďalšie členenie si pridáš podľa konkrétneho projektu.
- **Zdrojové diagramy** v `docs/img/<ArchiMate-vrstva>/` — Strategy / Business / Application / Technology / Motivation. Pre `.drawio` (Draw.io) a `.puml` (PlantUML).
- **ArchiMate model** v `docs/model/` (otvárať v Archi).
- **Build skripty** v `scripts/` — HTML site (`antora/antora`), PDF (`asciidoctor/docker-asciidoctor`), export diagramov (`rlespinasse/drawio-export`, `plantuml/plantuml`).
- **Šablóny .adoc dokumentov** v `templates/` — koncept, HLD, LLD, ADR, požiadavky.

## Štruktúra

```
.
├── antora-playbook.yml              # Antora playbook
├── docs/
│   ├── concept/                     # Antora component (name: concept, version: '0.1')
│   │   ├── antora.yml
│   │   └── modules/ROOT/
│   │       ├── nav.adoc             # navigácia (zatiaľ len index)
│   │       ├── concept_pdf.adoc     # PDF "manifest" s include::pages/...
│   │       ├── pages/index.adoc     # úvodná stránka
│   │       ├── images/              # generované PNG (cieľ sync-images.sh)
│   │       ├── attachments/         # prílohy stiahnuteľné z Antora site
│   │       └── partials/            # opakovane vkladané fragmenty
│   ├── img/                         # zdrojové diagramy (mimo Antora content)
│   │   ├── Strategy/  Business/  Application/  Technology/  Motivation/
│   └── model/
│       └── (project.archimate)      # ArchiMate model
├── templates/                       # AsciiDoc šablóny dokumentov
│   ├── _attributes.adoc
│   ├── concept.adoc
│   ├── hld.adoc
│   ├── lld.adoc
│   ├── adr.adoc
│   └── requirements.adoc
├── scripts/
│   ├── build_site.sh                # antora HTML build
│   ├── build_pdf.sh                 # asciidoctor-pdf z concept_pdf.adoc
│   ├── build_all.sh                 # export → sync → site → pdf
│   ├── serve.sh                     # python3 -m http.server nad build/site
│   ├── drawio_export.sh             # *.drawio → PNG
│   ├── plantuml_export.sh           # *.puml → PNG
│   ├── sync-images.sh               # rsync z build/img_png do modules/ROOT/images
│   └── sync-images.rules
└── utils/                           # voliteľné Windows .bat wrappery (afy/ify/docool/ic)
```

## Prvé použitie

1. **Skopíruj túto šablónu** do nového adresára (alebo `git clone` a prerob `git remote`).
2. V `antora-playbook.yml` uprav `site.title`.
3. V `docs/concept/antora.yml` uprav `name`, `title`, `version` (ak chceš iný názov komponentu, premenuj aj adresár `docs/concept` a `start_path` v playbooku).
4. Začni písať v `docs/concept/modules/ROOT/pages/index.adoc`. Nové stránky pridávaj do `pages/` a referencuj v `nav.adoc`. Upravovať treba aj `docs/concept/modules/ROOT/concept_pdf.adoc` aby sa stránky zobrazili aj v pdf.

## Build dokumentácie

Predpoklad: nainštalovaný **Docker** (Docker Desktop na Windows). Skripty sú bash (Git Bash / WSL).

```bash
./scripts/build_site.sh   # → ./build/site/index.html
./scripts/build_pdf.sh    # → ./build/pdf/Project.pdf
./scripts/serve.sh        # http://localhost:8000
./scripts/build_all.sh    # všetko (export diagramov + sync + site + pdf)
```

## Diagramy → obrázky

```bash
./scripts/drawio_export.sh    # *.drawio v docs/img/ → build/img_png/
./scripts/plantuml_export.sh  # *.puml v docs/img/  → vedľa zdroja
./scripts/sync-images.sh      # presun PNG do docs/concept/modules/ROOT/images/
```

## Nové dokumenty zo šablóny

```bash
cp templates/hld.adoc docs/concept/modules/ROOT/pages/hld-payment.adoc
# potom ho pridaj do nav.adoc:  ** xref:hld-payment.adoc[HLD – Payment]
```

## Konvencie

- **Jazyk**: slovenčina (atribút `:lang: sk` v playbooku).
- **Page-level attributes**: `ifndef::imagesdir[:imagesdir: ../images]` na začiatku každej stránky, ktorá vkladá obrázky cez `image::...` — drží konzistentné cesty pre Antora aj asciidoctor-pdf.
- **Dual site/PDF render**: `ifdef::pdf-mode[]` / `ifndef::pdf-mode[]` pre alternatívne cesty alebo bloky pri PDF builde.
- **Diagramy**: zdrojový `.drawio` v `docs/img/<vrstva>/`, generovaný `.png` po `build_all.sh` v `docs/concept/modules/ROOT/images/`.
- **Diff-friendly binárky**: `.gitattributes` označuje `.drawio/.archimate/.puml` ako text (aby sa diffovali) a `.png/.svg/.pdf` ako binary.

## Inšpiračné repozitáre

- `https://git.asseco-ce.com/vojtech.balint/sia` — najbohatší vzor, ArchiMate model + diagramy členené po doménach.
- `https://git.asseco-ce.com/vojtech.balint/sia_jvp` — multi-component (jvp_docs + jvp2). Ak budeš chcieť pridať druhý komponent, pozri si `antora-playbook-jvp_docs.yml` + `antora-playbook-jvp2.yml`.
- `https://git.asseco-ce.com/vojtech.balint/sia_ekp` — single-component vzor s podrobnejšou navigáciou.
