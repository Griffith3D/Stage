define mysql_db( $user, $password ) {
    exec { "create-${name}-db":
        unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -p$mysql_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
        require => Service["mysql"],
    }
}

define artisan() {
    exec {
        "artisan-${name}" :
        command => "php /home/vagrant/www/artisan ${name}",
        timeout => 0,
        path => ['/usr/bin',],
        require => Package['php7.2-cli']
    }
}

class avocatbox {

    #mysql_db {
    #    'homestead' :
    #    user => 'root',
    #    password => 'secret'
    #}

    #artisan {
    #    'migrate' :
    #    require => Mysql_db['homestead']
    #}
    #artisan {
    #    'db:seed' :
    #    require => Artisan['migrate']
    #}

    #artisan {
    #    'worker:config' :
    #}

}