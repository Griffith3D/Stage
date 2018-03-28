DOCKER PROJECT
=============


# Needs

* Standardize, simplify, accelerate the set up and the modulation of the dev environment.
* Scalable on demand
* Easy to use :
	- **Configuration input in `config.yaml`** -> Collected by a PHP script which creates the `docker-compose.yaml` file, the Dockerfile(s), and eventually some configurations related to the variables.
	- **Creation of a bash script** -> Manages the installation procedure and a few supervising commands. `./igor.sh cmd`
	- **README.md clear and accurate** -> Maintained all along the project to help the user.

# Applications migrated to this day

### Ready
* **REDIS**
* **ELASTICSEARCH** _cluster size, memory_
* **MYSQL** _MariaDB_

### In progress
* **GEARMAN SERVER**
* **WORKERS PHP + SUPERVISOR**

### Coming
* **PHP**
* **NGINX**
* **PHP-FPM**

# Key files

### docker-compose.php

* One container per VM : Redis, Gearmand, MariaDB
* Cluster of $var Elasticsearch nodes
* Workers configuration
* Basic Docker images are used where no specific configurations are required, or if so : use of volumes.

### Dockerfile

**Workerfile :** created from a Debian 9 image, builds default PHP workers, installing dependencies, and starts Supervisord. Worker-specific configurations are mounted from the PHP file.

### Vagrantfile

Manages the installation and configuration of the Virtual Machines.

### Puppet

Manages the old environment, VMs and apps, by installing and configuring all required apps.
