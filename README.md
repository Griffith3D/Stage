# Vagrant-Puppet-Docker environment

This folder helps you create your own development environment in a simple way, thanks to **Vagrant** for managing virtual machines, **Puppet** to install and configure apps, and **Docker** to run containerized applications.

The only files you will need to edit by yourself are `config.yaml` and `.env` in order to pick the _number of VMs and their assets_, how many _Elasticsearch nodes_ you want, ... The `.env`file is used to specify every additional configuration your application needs to know, such as ports, host IP, passwords, ... See more below.

# Summary

- [Global configuration] (#configuration)
	- [config.yaml] (#config)
	- [.env] (#env)
- [Installation] (#installation)
- [Create your environment] (#create-your-environment)
- [Next step: configure your VMs] (#next-step)
- [Gearman Workers] (#gearman-workers)

## Configuration

To configure you environment properly, you will have to edit two files. One in this folder, and the other one in the laravel folder.

### config

To begin with, copy example config:
```
$ cp config.yaml.example config.yaml
```
Then, you will need to edit the **config.yaml** as you want :

The **example** is configured as _one virtual machine_ with a _cluster of two Elasticnodes_ containers.

1. Customize the RAM and the CPU% (base 50, up to 100) if you need to.
2. You will need to paste your own **Gitlab private token** (get it on your gitlab account).
3. Edit the *laravel_folder* with your laravel folder path.
4. Chose the number of Elasticsearch nodes you want in your cluster
5. Chose the amount of memory you want for your Elasticsearch nodes. _Syntax: '1g', '1024m', '2048m'_
6. You may want to edit ports for apps if you're using more than two **Elasticsearch** nodes. **One node = one port**, simply add +1 to the last port for each additional node.

**If you want to add more VMs**, copy the first "- name: 'dev'" entry, but keep in mind the _correct indentation_, _add +1 to the box IP address and to the ports_.


### .env

Now, head into your laravel folder, and edit the **.env** file.
What you're looking for is the **ELASTICSEARCH**, **REDIS** and **DB** configuration. Edit this, using **config.yaml for the ports**, to :

```
ELASTICSEARCH_HOST=192.168.33.1
ELASTICSEARCH_PORT=port

REDIS_HOST=192.168.33.1
REDIS_PORT=port

DB_CONNECTION=mysql
DB_HOST=192.168.33.1
DB_DATABASE=homestead
DB_USERNAME=root
DB_PASSWORD=secret
DB_PORT=port
```

**If you're running a multi-node environment, you need to edit the ELASTICSEARCH according to the number 
of nodes. Example for a dual node cluster :** 
```
ELASTICSEARCH_PROTOCOLS=http,http
ELASTICSEARCH_HOSTS=192.168.33.1,192.168.33.1
ELASTICSEARCH_PORTS=9200,9201
ELASTICSEARCH_INDEX=mon_avocat
```

**Take note that:** every application which is dockerized must have 192.168.33.1 as his IP. You don't want to use the physical container IP to connect to an app, you have to use the bridged interface. 


## Installation

**Add Docker repository** in your _sources.list_ using the following command :

```
$ echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" | tee -a /etc/apt/sources.list
```
**Update your apt** with `apt update`.

 **Install the following dependencies:** docker, docker-ce and get docker-compose  

/** Don't use apt to get docker-compose **/

```
$ sudo apt install docker docker-ce -y
$ sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

 **Install php7.2 & php-yaml extension** :

If not done yet, add Sury's repository for PHP :
```
sudo apt-get install apt-transport-https lsb-release ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
```

Then proceed with the installation :
```
$ apt install php7.2 php-yaml
```


## Create your environment

Once every step is done, you can start creating your environment.
For this purpose, there is a **script** in this folder named **igor.sh**. Igor will help you, not only to create your VMs, but also to manage it.

Remember that containers must be started BEFORE Vagrant. If you want to destroy and create new containers, begin with `./igor.sh stop`.

```
./igor.sh help
```
* `init` : purging the temporary folder, then creating your containers and VMs. This is the first command you need to use.
* `restart` : restarts the containers and VMs. Use it on reboot or if your environment is stopped.
* `stop` : stops all containers and shutdown all VMs.
* `status` : display status of containers and VMs in the terminal.
* `dockercreate` : updates configuration and creates new containers.
* `dockerdestroy` : destroy containers. Use **init** or **dockercreate** to recreate them.
* `help` : displays all commands for Igor.


_When starting Vagrant's VMs, make sure you're logged as the user who created the VMs in the first place_

## Next step

To configure your environment in the Virtual Machine, look for the **README.md** in the **laravel folder**.

**Before running `php artisan happyseeder`, you must create the homestead database :**

To connect to the database directly and create the homestead :
```
mysql -u root -p -h 192.168.33.1 -P 3306 -e "CREATE DATABASE homestead;"
```

_If using a different port in config.yaml, keep the original 3306 in the .env, but use `-P yourport` in t
he command line_


## Gearman Workers

**Work in progress**

______
When your environment is set up, you can setup workers using Igor. 

**WARNING**: **Make sure you got workers configuration, if you don't, follow the steps at http://books.tools.mon-avocat.fr/books/d%C3%A9veloppement/page/gearman-%28-supervisor%29 first.**

Once you're done with php artisan configuration, simply run :
```
./igor.sh workers
```
It will create all workers containers from your configuration.

If you ever need to delete some workers, type `docker ps -a`, look for the workers you want to destroy then run `docker stop workername` and `docker rm workername`.
______

# Todo

Fix the Websocket worker
Dockerize PHP-FPM and NGINX.
