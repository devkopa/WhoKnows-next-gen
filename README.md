<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">

  <h3 align="center">WhoKnows README</h3>

<p align="center">
    <br />
    <a href="https://github.com/devkopa/WhoKnows-next-gen"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/devkopa/WhoKnows-next-gen">View Demo</a>
    &middot;
    <a href="https://github.com/devkopa/WhoKnows-next-gen/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/devkopa/WhoKnows-next-gen/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product screenshot missing][product-screenshot]](https://localhost:3000)

# Modernized WhoKnows Search Engine

This project is a migrated and improved version of the legacy WhoKnows search engine.

## Features

- **Search**
  - Fast search across indexed content.

- **Weather**
  - Integrated Weather API that shows the weather for the searched city.
    
- **Monitoring**
  - Monitoring with Prometheus and PostgreSQL visualized in Grafana.
  - Tracked metrics:
    - Uptime (%) and uptime (weeks)
    - User logins and user registrations
    - Weather API requests
    - Search requests and search match rate
    - CPU usage (%) and per-CPU idle rate (average idle per instant, %)
    - Memory usage (%)
    - Disk usage (%) per mount
    - Network traffic (bytes/s) in vs out
    - Load average (1m / 5m / 15m)
    
- **Authentication**
  - Users can sign up and sign in.
  - Session cookies are used for authenticated requests.

## Purpose

This solution helps to:  

- Showcase a legacy application in a modern stack.  
- Reduce errors and slow responses.  
- Monitor the environment and how users interact with the app.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

This section highlights the main frameworks and libraries used in the project:

* [![Ruby][Ruby-on-Rails]][Ruby-url]
* [![Prometheus][Prometheus]][Prometheus-url]
* [![Grafana][Grafana]][Grafana-url]
* [![Tailwind][TailwindCSS]][TailwindCSS-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

To run the project you need:

- Latest version of **Docker**
- Latest version of **Docker Compose**

---

### Installation

1. Clone the repository
   ```sh
   git clone https://github.com/devkopa/WhoKnows-next-gen.git
   ```
2. Configure environment variables
   - Request the `.env` from the team
   - Update the values in `.env` with your configuration
   - Get OpenWeather API key from https://openweathermap.org/api
   
3. Update the git remote to avoid pushing to the base project
   ```sh
   git remote set-url origin github_username/repo_name
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Run the project

1. Start the application with Docker
   ```sh
   docker compose up
   ```
   The app will be available on the configured port.

<!-- USAGE EXAMPLES -->
## Usage

Once the application is running:

1. **Access the application**
   - Navigate to `http://localhost:3000` (or your configured port)

2. **Perform searches**
   - Use the search functionality to query indexed content
   - View search results with match rate tracking

3. **Check weather**
   - Search for a city to see current weather information via the integrated Weather API

4. **Register and login (optional)**
   - Create an account and sign in if desired

5. **Monitor metrics**
   - Access Grafana dashboard at `http://localhost:5000`
   - Prometheus metrics at `http://localhost:3000/metrics`
   - Health checks at `http://localhost:3000/health`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Maintenance & Operations

### Security Features (Latest Updates)
- ✅ Enhanced password validation (minimum 8 characters)
- ✅ Secure session management with httponly cookies
- ✅ Email validation with RFC compliance
- ✅ CSRF protection enabled
- ✅ Force SSL in production
- ✅ Zero security vulnerabilities (Brakeman scan)

### Performance Optimizations
- ✅ Database query optimization with selective field loading
- ✅ Result limiting (100 max per request)
- ✅ GIN indexes for full-text search
- ✅ Connection pooling configured

### Monitoring & Health Checks
- `/health` - Basic health check
- `/health/ready` - Readiness probe (checks dependencies)
- `/health/live` - Liveness probe
- `/health/metrics` - Application metrics summary

### Backup & Restore

**Create Backup (Windows):**
```powershell
.\scripts\backup_database.ps1
```

**Restore Backup (Windows):**
```powershell
.\scripts\restore_database.ps1 -BackupFile ".\backups\whoknows_backup_20251213_120000.sql.gz"
```

**Verify Backup:**
```powershell
.\scripts\verify_backup.ps1
```

**Setup Automated Backups:**
```powershell
# Run as Administrator
.\scripts\setup_backup_schedule.ps1 -Schedule Daily -Time "02:00"
```

### Documentation
- [API Documentation](./docs/API.md) - Complete API reference
- [Maintenance Guide](./docs/MAINTENANCE.md) - Operational procedures
- [OpenAPI Specification](./Mandatory%20I/openapispecification.yaml) - API specification

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [x] CRUD for transactions
- [x] Test algorithms on real data

See [open issues](https://github.com/TheOriginalJiozx/TrustBank/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions make the open source community a fantastic place to learn, inspire, and create. Any contribution is appreciated.

If you have an improvement idea, fork the repo and create a pull request. You can also open an issue with the "enhancement" tag.  
And please give the project a star! Thank you!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Top contributors:

<a href="https://github.com/devkopa/WhoKnows-next-gen/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=devkopa/WhoKnows-next-gen&nocache=1" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Omar Al-Ali - [TheOriginalJiozx](https://github.com/TheOriginalJiozx)<p />
Yasin Dhalin - [Dhalinn](https://github.com/Dhalinn) <p />
Maksym Yuzefovych - [maksyuze456](https://github.com/maksyuze456)

Project Link: [[https://github.com/devkopa/WhoKnows-next-gen](https://github.com/devkopa/WhoKnows-next-gen)]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Img Shields](https://shields.io)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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
[product-screenshot]: readme_images/devkopa.png
[Ruby-on-Rails]: https://img.shields.io/badge/Ruby_on_Rails-CC0000?logo=ruby-on-rails&logoColor=white
[Ruby-url]: https://rubyonrails.org/
[Prometheus]: https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white
[Prometheus-url]: https://prometheus.io/
[Grafana]: https://img.shields.io/badge/Grafana-F2F4F9?style=for-the-badge&logo=grafana&logoColor=orange&labelColor=F2F4F9
[Grafana-url]: https://grafana.com/
[TailwindCSS]: https://img.shields.io/badge/Tailwind_CSS-black?style=for-the-badge&logo=tailwind-css
[TailwindCSS-url]: https://tailwindcss.com/

