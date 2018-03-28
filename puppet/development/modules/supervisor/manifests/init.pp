# vagrant/puppet/modules/gearman/manifests/init.pp

class supervisor {

    package { 'supervisor' :
        ensure => present,
        require => Package['php-gearman'],
    }

    file { '/etc/supervisor/supervisord.conf' :
        ensure => present,
        owner => 'vagrant',
        group => 'vagrant',
        source => 'puppet:///modules/supervisor/supervisord.conf',
        require => Package['supervisor']
    }

    exec { 'supervisorctl_reread':
        command => "/usr/bin/sudo /usr/bin/supervisorctl reread",
        require => File['/etc/supervisor/supervisord.conf']
    }

    exec { 'supervisorctl_update':
        command => "/usr/bin/sudo /usr/bin/supervisorctl update",
        require => Exec['supervisorctl_reread']
    }

    exec { 'supervisorctl_restart':
        command => "/usr/bin/sudo /usr/bin/supervisorctl restart all",
        require => Exec['supervisorctl_update']
    }

}