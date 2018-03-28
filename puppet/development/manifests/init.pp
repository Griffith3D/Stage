class common {
    exec { 'apt-get update':
      path => '/usr/bin',
    }

    package { 'vim':
      ensure => present,
    }

    # server utils
    include utils
}

class webserver {
    require common

    # base box
    include nginx, php, mysql, mailhog
	# redis
}

class java {
    require common

    include openjdk
}

class hostmonavocat {
    require webserver

    # gearman managment
    include gearman, supervisor, v8js

    # mon-avocat specific module
    include avocatbox
}

class esnode {
    require java

    include elasticsearch
}

class elasticmonavocat {
    require esnode
}

node /^avocatbox-(.*?)$/ {
    require hostmonavocat
}
node /^box-(.*?)$/ {
    require webserver
}

node /^elasticsearch[0-9]\.avocatbox\.(.*?)$/ {
    require elasticmonavocat
}
