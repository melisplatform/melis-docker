# Melis Platform Dockerfiles

This repository contains Dockerfiles to be used for [Melis Platform](https://www.melistechnology.com/).

## Install Melis with Docker — choose your path

| Path | For whom | Folder |
|------|----------|--------|
| **Pre-built image** — pull a ready-to-run Melis (no build) + DB, finish via the web installer | Fastest evaluation / "just run it" | [`prebuilt/`](prebuilt/) |
| **Turnkey build** — builds a fresh Melis skeleton on your host, editable code in `./melis` | Developers who want the code locally | [`install/`](install/) |
| **Dev images (legacy)** — mount an existing Melis project, pick a PHP tag | Existing projects | [`app/latest/`](app/latest/) — see *Getting Started* below |

> All paths finish the same way: the **native Melis web installer** at
> http://localhost:8080 sets up the DB schema, admin user and the optional demo site.

## Getting Started

> **Important:** This repository should be cloned within your Melis Project root directory.

### Clone project
```bash
git clone https://github.com/melisplatform/melis-docker.git
```

> **Note:** Make sure that port 8080 is not used on your host. You can change it in the *.env* file if needed.

### Build and Run

#### Windows Users
You can use the provided batch file to start Docker:
```bash
start-docker.bat
```

#### Manual Build
```bash
cd melis-docker/app/latest && docker-compose up --build
```

### Start Stack
```bash
docker-compose up -d
```

### Access the Platform
Open your favorite browser and navigate to: http://localhost:8080

### Shutdown Stack
```bash
docker-compose down -v
```

### Build Components

#### Configuration
Change PHP version in **app/latest/.env** default tag **dev-apache-8.2**

Available tags (PHP versions shipped in [`dev/`](dev/)) — [View on Docker Hub](https://hub.docker.com/repository/docker/melisplatform/melis-docker):
* dev-apache-8.3  ← recommended (latest version supported by Melis 5.3.x)
* dev-apache-8.2
* dev-apache-8.1
* dev-apache-7.4
* dev-apache-7.3
* dev-apache-7.2
* dev-apache-7.1
* dev-apache-7.0

> Melis Platform 5.3.x requires **PHP 8.1 – 8.3**. Use a PHP 8.x tag for a current
> install; the PHP 7.x tags are kept only for legacy projects.


## Contributing

Please note that this project is released with a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/2/0/).

By participating in this project you agree to abide by its terms.

Feel free to fork the project, create a feature branch, and send us a pull request!

## Authors

* **Melis Technology** - [www.melistechnology.com](https://www.melistechnology.com/)

See also the list of [contributors](https://github.com/melisplatform/melis-docker/contributors) who participated in this project.

## License

This project is licensed under the OSL-3.0 License - see the [LICENSE](LICENSE) file for details