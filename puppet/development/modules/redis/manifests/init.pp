# vagrant/puppet/modules/redis/manifests/init.pp
class redis {

    # Install the php*-fpm and php*-cli packages
    package { ['redis-server']:
        ensure => present,
        require => Exec['apt-get update'],
    }

}