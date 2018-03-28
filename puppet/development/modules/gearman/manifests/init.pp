# vagrant/puppet/modules/gearman/manifests/init.pp
class gearman {

    package { [ 'gearman-job-server',
                'libgearman-dev']:
        ensure => present,
        require => Exec['apt-get update'],
    }

    package { 'php-gearman':
        ensure => present,
        require => Package['php7.2-cli'],
    }

}
