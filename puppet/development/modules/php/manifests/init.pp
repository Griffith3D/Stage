# vagrant/puppet/modules/php/manifests/init.pp
class php {

  # Install the php*-fpm and php*-cli packages
  package { ['php7.2-cli',
             'php7.2-fpm',
             'php7.2-mbstring',
             'php7.2-mysql',
             'php7.2-xml',
             'php7.2-curl',
             'php7.2-zip',
             'php7.2-dev',
             'php-imagick',
             'php-pear']:
    ensure => present,
    require => Exec['apt-get update'],
    notify => Service['php7.2-fpm']
  }

  package { ['libsodium-dev', 'libsodium18']:
       ensure => present,
       require => Package['php-pear']
  }

  exec { 'pecl-sodium':
    command => 'sudo pecl install libsodium',
    user => 'vagrant',
    path => ['/usr/local/bin', '/usr/bin', '/bin'],
    require => [Package['php7.2-dev'], Package['libsodium-dev']]
  }

  package { 'php-sodium':
    ensure => present,
    require => Exec['pecl-sodium']
  }

   Make sure php7.2-fpm is running
  service { 'php7.2-fpm':
    ensure => running,
    require => Package['php7.2-fpm'],
    enable => true,
    hasrestart => true,
    restart => '/etc/init.d/php7.2-fpm reload'
  }
}
