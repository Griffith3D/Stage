# vagrant/puppet/modules/mailhog/manifests/init.pp
class mailhog {

    # create mailhog directory
    file { '/opt/mailhog':
        path => '/opt/mailhog/',
        owner => 'root',
        group => 'root',
        ensure => directory,
        notify => File['/opt/mailhog/mailhog_linux_amd64']
    }

    # get mailhog executable on image
    file { '/opt/mailhog/mailhog_linux_amd64':
        ensure => present,
        owner => 'root',
        group => 'root',
        mode => 'a+rx',
        source => 'puppet:///modules/mailhog/mailhog_linux_amd64',
        require => File['/opt/mailhog']
    }

    # make it runnable from everywhere
    file { '/usr/local/bin/mailhog':
        ensure => 'link',
        source => '/opt/mailhog/mailhog_linux_amd64',
        require => File['/opt/mailhog/mailhog_linux_amd64']
    }

    # get mailhog start script on image
    file { '/opt/mailhog/mailhog_start.sh':
        ensure => present,
        owner => 'root',
        group => 'root',
        mode => 'a+x',
        source => 'puppet:///modules/mailhog/mailhog_start.sh',
        require => File['/opt/mailhog']
    }

    # get mailhog init script on image
    file { '/etc/init/mailhog.conf':
        ensure => present,
        owner => 'root',
        group => 'root',
        source => 'puppet:///modules/mailhog/mailhog.conf'
    }

}