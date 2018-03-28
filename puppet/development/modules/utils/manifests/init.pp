# vagrant/puppet/modules/utils/manifests/init.pp
define composer() {
    exec { 'composer-download':
        command => 'wget https://getcomposer.org/download/1.5.1/composer.phar',
        cwd => '/home/vagrant/',
        user => 'vagrant',
        path => ['/usr/local/bin', '/usr/bin', '/bin']
    }

    file { '/usr/local/bin/composer':
        ensure => present,
        owner => 'root',
        group => 'root',
        mode => 'a+x',
        source => '/home/vagrant/composer.phar',
        require => Exec['composer-download'],
    }

    exec { 'composer-post-setup':
        command => 'rm composer.phar',
        cwd => '/home/vagrant/',
        user => 'vagrant',
        path => ['/usr/local/bin', '/usr/bin', '/bin'],
        require => File['/usr/local/bin/composer']
    }

}

define nodejs() {
    exec { 'nodejs-setup':
        command => '/usr/bin/curl -sL https://deb.nodesource.com/setup_8.x | /usr/bin/sudo -E bash -',
    }

    exec { 'npm':
    command => '/usr/bin/sudo /usr/bin/npm install -g npm',
    require => Package['nodejs']
    }

    package { 'nodejs':
        ensure => present,
        require => Exec['nodejs-setup']
    }
}

define yarn() {
    exec { 'yarn-repos':
        command => '/usr/bin/curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | /usr/bin/sudo apt-key add - ; echo "deb https://dl.yarnpkg.com/debian/ stable main" | /usr/bin/sudo tee /etc/apt/sources.list.d/yarn.list',
        require => Package['curl']
    }

    exec { 'yarn-install':
    command => '/usr/bin/sudo apt-get update && /usr/bin/sudo apt-get install yarn',
    require => Exec['yarn-repos']
    }
}

class utils {

    # install curl, git, zip & unzip package
    package { ['curl', 'git', 'zip', 'unzip', 'build-essential'] :
      ensure => present,
    }

    # composer
    composer { 'composer':
    }

    # nodejs
    nodejs { 'npm':
    }

    # gulp
    exec { 'gulp':
        command => '/usr/bin/sudo /usr/bin/npm install gulp-cli -g',
        require => Nodejs['npm']
    }

    # bower
    exec { 'bower':
        command => '/usr/bin/sudo /usr/bin/npm install bower -g',
        require => Nodejs['npm']
    }

    # yarn
    yarn { 'yarn-repos':
    }

}