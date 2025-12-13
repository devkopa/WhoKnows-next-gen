<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<!-- PROJEKT LOGO -->
<br />
<div align="center">

  <h3 align="center">WhoKnows README</h3>

<p align="center">
    <br />
    <a href="https://github.com/devkopa/WhoKnows-next-gen"><strong>Udforsk dokumentationen »</strong></a>
    <br />
    <br />
    <a href="https://github.com/devkopa/WhoKnows-next-gen">Se Demo</a>
    &middot;
    <a href="https://github.com/devkopa/WhoKnows-next-gen/issues/new?labels=bug&template=bug-report---.md">Rapporter fejl</a>
    &middot;
    <a href="https://github.com/devkopa/WhoKnows-next-gen/issues/new?labels=enhancement&template=feature-request---.md">Anmod om funktion</a>
  </p>
</div>

<!-- INDHOLDSFORTEGNELSE -->
<details>
  <summary>Indholdsfortegnelse</summary>
  <ol>
    <li>
      <a href="#about-the-project">Om Projektet</a>
      <ul>
        <li><a href="#built-with">Bygget Med</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Kom Godt I Gang</a>
      <ul>
        <li><a href="#prerequisites">Forudsætninger</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Brug</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Bidrag</a></li>
    <li><a href="#contact">Kontakt</a></li>
    <li><a href="#acknowledgments">Tak</a></li>
  </ol>
</details>

<!-- OM PROJEKTET -->
## Om Projektet

[![Produkt Skærmbillede mangler][product-screenshot]](https://localhost:3000)

# Intelligent Virksomhedskategorisering for Banktransaktioner

Dette projekt har til formål at være en migreret og forbedret version af legacy WhoKnows. En søgemaskine.

## Funktioner

- **Søgning**

- **Vejr**
  - Integreret Weather API, viser vejret for den søgte by.
    
- **Monitoring**
  - Monitoring med Prometheus, PostgreSQL på en Grafana grænseoverflade.
  - Monitorer antal API-kald, user registrations, CPU-forbrug.
    
- **Authentication**
  - Brugerne kan oprette en bruger og logge ind.

## Formål

Denne løsning hjælper med at:  

- Vise en legacy applikation i en modern stack.  
- Reducere fejl og langsom respons.  
- Monitorere miljøjet og hvordan brugerne interagerer med appen.

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

### Bygget Med

Dette afsnit viser de vigtigste frameworks/biblioteker brugt til at starte projektet. Eventuelle ekstra plugins kan nævnes under tak. Her er nogle eksempler:

* [![Ruby][Ruby-on-Rails]][Ruby-url]
* [![Prometheus][Prometheus]][Prometheus-url]
* [![Grafana][Grafana]][Grafana-url]
* [![Tailwind][TailwindCSS]][TailwindCSS-url]

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

## Kom Godt I Gang

### Forudsætninger

Følgende er påkrævet for at køre projektet:

- Seneste version af **Docker**
- Seneste version af **Docker Compose** (inkluderet i Docker Desktop)

---

### Installation

1. Klon repositoriet
   ```sh
   git clone https://github.com/devkopa/WhoKnows-next-gen.git
   ```
2. Tilføj environment-fil
   - Opret en ``.env`` fil i projektets rodmappe.
   - Anmod ``.env`` filen hos teamet.
   
3. Skift git remote url for at undgå uheldige pushes til base project
   ```sh
   git remote set-url origin github_username/repo_name
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

### Kør projektet

1. Start applikationen med Docker
   ```sh
   docker-compose up
   ```
   Applikationen vil herefter være tilgængelig via den konfigurerede port.

<!-- BRUGSEKSEMPLER -->
## Brug

Brug dette afsnit til at vise nyttige eksempler på, hvordan projektet kan anvendes. Skærmbilleder, kodeeksempler og demoer fungerer godt her. Du kan også linke til yderligere ressourcer.

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [x] CRUD for transaktioner
- [x] Test algoritmerne på rigtig data

Se [åbne issues](https://github.com/TheOriginalJiozx/TrustBank/issues) for en komplet liste over foreslåede funktioner (og kendte problemer).

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

<!-- BIDRAG -->
## Bidrag

Bidrag er det, der gør open source-community så fantastisk at lære, inspirere og skabe. Enhver form for bidrag er meget værdsat.

Hvis du har en idé til forbedringer, kan du fork repoen og lave en pull request. Du kan også blot oprette en issue med tagget "enhancement".  
Glem ikke at give projektet en stjerne! Tak!

1. Fork projektet
2. Opret din feature-branch (`git checkout -b feature/AmazingFeature`)
3. Commit dine ændringer (`git commit -m 'Tilføj AmazingFeature'`)
4. Push til branchen (`git push origin feature/AmazingFeature`)
5. Lav en Pull Request

### Top contributors:

<a href="https://github.com/devkopa/WhoKnows-next-gen/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=devkopa/WhoKnows-next-gen&nocache=1" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

<!-- KONTAKT -->
## Kontakt

Omar Al-Ali - [TheOriginalJiozx](https://github.com/TheOriginalJiozx)<p />
Yasin Dhalin - [Dhalinn](https://github.com/Dhalinn) <p />
Maksym Yuzefovych - [maksyuze456](https://github.com/maksyuze456)

Projekt Link: [[https://github.com/devkopa/WhoKnows-next-gen](https://github.com/devkopa/WhoKnows-next-gen)]

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

<!-- SPECIELT TAK TIL -->
## Specielt tak til

* [Img Shields](https://shields.io)

<p align="right">(<a href="#readme-top">til toppen</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/devkopa/WhoKnows-next-gen.svg?style=for-the-badge
[contributors-url]: https://github.com/devkopa/WhoKnows-next-gen/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/devkopa/WhoKnows-next-gen.svg?style=for-the-badge
[forks-url]: https://github.com/devkopa/WhoKnows-next-gen/network/members
[stars-shield]: https://img.shields.io/github/stars/devkopa/WhoKnows-next-gen.svg?style=for-the-badge
[stars-url]: https://github.com/devkopa/WhoKnows-next-gen/stargazers
[issues-shield]: https://img.shields.io/github/issues/devkopa/WhoKnows-next-gen.svg?style=for-the-badge
[issues-url]: https://github.com/devkopa/WhoKnows-next-gen/issues&nocache=1
[product-screenshot]: readme_images/screenshot.png
[Ruby-on-Rails]: https://img.shields.io/badge/Ruby_on_Rails-CC0000?logo=ruby-on-rails&logoColor=white
[Ruby-url]: https://rubyonrails.org/
[Prometheus]: https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white
[Prometheus-url]: https://prometheus.io/
[Grafana]: https://img.shields.io/badge/Grafana-F2F4F9?style=for-the-badge&logo=grafana&logoColor=orange&labelColor=F2F4F9
[Grafana-url]: https://grafana.com/
[TailwindCSS]: https://img.shields.io/badge/Tailwind_CSS-black?style=for-the-badge&logo=tailwind-css
[TailwindCSS-url]: https://tailwindcss.com/

