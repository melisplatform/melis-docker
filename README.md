# Melis Platform Dockerfiles

This repository contains Dockerfiles to be used for [Melis Platform](https://www.melistechnology.com/).

## Getting Started

> **Important:** This repository should be cloned within your Melis Project root directory.

### Clone project
```bash
git clone https://github.com/melisplatform/melis-docker.git
```

### Build Components

#### Configuration
Change PHP version in **app/latest/.env** default tag **dev-apache-7.2**

Available tags: [View on Docker Hub](https://hub.docker.com/repository/docker/melisplatform/melis-docker)
* dev-apache-7.4
* dev-apache-7.3
* dev-apache-7.2
* dev-apache-7.1
* dev-apache-7.0
* dev-apache-8.1
* dev-apache-8.2
* dev-apache-8.3

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

## Contributing

Please note that this project is released with a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/2/0/).

By participating in this project you agree to abide by its terms.

Feel free to fork the project, create a feature branch, and send us a pull request!

## Authors

* **Melis Technology** - [www.melistechnology.com](https://www.melistechnology.com/)

See also the list of [contributors](https://github.com/melisplatform/melis-docker/contributors) who participated in this project.

## License

This project is licensed under the OSL-3.0 License - see the [LICENSE](LICENSE) file for details