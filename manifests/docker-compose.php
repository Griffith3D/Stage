<?php

    // loading config
    $path = __DIR__. '/../config.yaml';
    $config = yaml_parse_file($path);

    // get boxes configs
    $boxes = $config['config']['boxes'];

    // generate /docker-compose.yaml
    $docker = <<<JAMBON
version: "2.1"
services:
JAMBON;

    foreach($boxes as $box) {
        // init ...
        $name = $box['name'];
        $ports = $box['ports'];
        $es_nodes = $box['elastic_nodes'];
	$ip = $box['container_ip'];
        // generating redis part
        $docker .= <<<JAMBON
    
  {$name}_redis:
    image: redis
    container_name: igor_{$name}_redis
    restart: unless-stopped
    ports: 
      - {$ports['redis']}:6379
    networks:
      igor:
        ipv4_address: {$ip['redis']}
  {$name}_mariadb:
    build:
      context: .
      dockerfile: Mariadbfile
    container_name: igor_{$name}_mariadb
    restart: unless-stopped
    volumes:
      - ./tmp/my.cnf:/etc/mysql/my.cnf
      - /var/lib/data/igor_db:/var/lib/mysql
    environment:
      - MYSQL_USER=mysql
      - MYSQL_PASSWORD=secret
      - MYSQL_ROOT_PASSWORD=secret
    ports:
      - {$ports['mariadb']}:3306
    networks:
      igor:
        ipv4_address: {$ip['mariadb']}
  {$name}_samba:
    image: dperson/samba
    container_name: igor_{$name}_samba*
    restart: unless-stopped
    volumes:
      - /usr/bin/share/samba_persist:/etc/samba
    environment:
      - wip
    ports:
      - {$ports['samba']}:139
    networks:
      igor:
        ipv4_address: 192.168.33.107
   {$name}_dhcp-service:
   
JAMBON;

	if($es_nodes==1) {
		$docker .= <<<JAMBON

  {$name}_elasticsearch:
    image: elasticsearch:5.5.1
    container_name: igor_{$name}_elasticsearch
    ports:
      - {$ports['elastic'][0]}:9200
    restart: unless-stopped
    environment:
      - "ES_JAVA_OPTS=-Xms{$box['elastic_memory']} -Xmx{$box['elastic_memory']}"
    networks:
      igor:
        ipv4_address: {$ip['elastic'][0]}
JAMBON;
	}
	else 
	for($i = 0; $i < $es_nodes; ++$i) {

            // generating ES part (for each nodes)
            $docker .= <<<JAMBON

  {$name}_elasticsearch_{$i}:
    image: elasticsearch:5.5.1
    container_name: igor_{$name}_elasticsearch_{$i}
    ports:
      - {$ports['elastic'][$i]}:9200
    volumes:
      - ./tmp/{$name}/es_{$i}/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
    restart: unless-stopped
    environment:
      - "ES_JAVA_OPTS=-Xms{$box['elastic_memory']} -Xmx{$box['elastic_memory']}"
    networks:
      igor:
        ipv4_address: {$ip['elastic'][$i]}
JAMBON;

            // listing all nodes except current one
            $nodes_hosts = [];
            $nodes_to_link = range(0, ($es_nodes - 1));
            foreach ($nodes_to_link as $node) {
                if($node !== $i) {
                    $nodes_hosts[] = $name. '_elasticsearch_' .$node;
                }
            }
            $nodes_hosts = implode(', ', $nodes_hosts);

            // generating ES cluster configuration (for each nodes)
            $elastic_cluster = <<<JAMBON
cluster.name: "{$name}_es_cluster"
network.host: 192.168.33.1
discovery.zen.minimum_master_nodes: 2
discovery.zen.ping.unicast.hosts: {$nodes_hosts}
cluster.routing.allocation.disk.threshold_enabled : false
JAMBON;

            // saving /tmp/{vm_name}/es_{$i}/elasticsearch.yml
            if(!file_exists(__DIR__. '/../tmp/' .$name. '/es_' .$i)) {
                mkdir(__DIR__. '/../tmp/' .$name. '/es_' .$i. '/', 0777, true);
            }
	
            $output = __DIR__. '/../tmp/' .$name. '/es_' .$i. '/elasticsearch.yml';
            file_put_contents($output, $elastic_cluster);
        }
	}

	$docker .= <<<JAMBON

networks:
  igor:
    external:
      name: igor
JAMBON;

    // saving /docker-compose.yaml
    $output = __DIR__. '/../docker-compose.yaml';
    file_put_contents($output, $docker);
    

$mysql = <<<EOF
[client]
port		= {$ports['mariadb']}
socket		= /var/run/mysqld/mysqld.sock

[mysqld_safe]
socket		= /var/run/mysqld/mysqld.sock
nice		= 0

[mysqld]
user		= root
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
port		= 3306
basedir		= /usr
datadir		= /var/lib/mysql
tmpdir		= /tmp
lc_messages_dir	= /usr/share/mysql
lc_messages	= en_US
skip-external-locking
bind-address		= 192.168.33.0
max_connections		= 100
connect_timeout		= 5
wait_timeout		= 1200
max_allowed_packet	= 16M
thread_cache_size       = 128
sort_buffer_size	= 4M
bulk_insert_buffer_size	= 16M
tmp_table_size		= 32M
max_heap_table_size	= 32M
myisam_recover_options = BACKUP
key_buffer_size		= 128M
table_open_cache	= 400
myisam_sort_buffer_size	= 512M
concurrent_insert	= 2
read_buffer_size	= 2M
read_rnd_buffer_size	= 1M
query_cache_limit		= 128K
query_cache_size		= 64M
slow_query_log_file	= /var/log/mysql/mariadb-slow.log
long_query_time = 10
expire_logs_days	= 10
max_binlog_size         = 100M
default_storage_engine	= InnoDB
innodb_buffer_pool_size	= 256M
innodb_log_buffer_size	= 8M
innodb_file_per_table	= 1
innodb_open_files	= 400
innodb_io_capacity	= 400
innodb_flush_method	= O_DIRECT

[galera]

[mysqldump]
quick
quote-names
max_allowed_packet	= 16M

[mysql]

[isamchk]
key_buffer		= 16M

!includedir /etc/mysql/conf.d/
EOF;

// saving my.cnf
$output = __DIR__. '/../tmp/my.cnf';
file_put_contents($output, $mysql);
