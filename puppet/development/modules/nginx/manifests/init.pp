# vagrant/puppet/modules/nginx/manifests/init.pp
class nginx {

  # Install the nginx package. This relies on apt-get update
  package { 'nginx':
    ensure => 'present',
    require => Exec['apt-get update'],
  }

  # Make sure that the nginx service is running
  service { 'nginx':
    ensure => running,
    enable => true,
    hasrestart => true,
    require => [
        File['/etc/nginx/nginx.conf'],
        File['/etc/nginx/ssl/avocatbox.crt'],
        File['/etc/nginx/ssl/avocatbox.key'],
        File['/etc/nginx/ssl/avocatbox.csr'],
    ],
    restart => '/etc/init.d/nginx reload'
  }

  # cert files for SSL
  file { '/etc/nginx/ssl':
    path => '/etc/nginx/ssl/',
    owner => 'root',
    group => 'root',
    ensure => directory
  }
  file { '/etc/nginx/ssl/avocatbox.crt':
    ensure => 'file',
    owner => 'root',
    group => 'root',
    require => File['/etc/nginx/ssl'],
    source => 'puppet:///modules/nginx/avocatbox.crt'
  }
  file { '/etc/nginx/ssl/avocatbox.key':
    ensure => 'file',
    owner => 'root',
    group => 'root',
    require => File['/etc/nginx/ssl'],
    source => 'puppet:///modules/nginx/avocatbox.key'
  }
  file { '/etc/nginx/ssl/avocatbox.csr':
    ensure => 'file',
    owner => 'root',
    group => 'root',
    require => File['/etc/nginx/ssl'],
    source => 'puppet:///modules/nginx/avocatbox.csr'
  }

  # modify nginx config file
  file { '/etc/nginx/nginx.conf':
    ensure => 'file',
    owner => 'root',
    group => 'root',
    notify => Service['nginx'],
    require => Package['nginx'],
    source => 'puppet:///modules/nginx/nginx.conf'
  }

  # Add a vhost template
  file { '/etc/nginx/sites-available':
    path => '/etc/nginx/sites-available/',
    owner => 'root',
    group => 'root',
    ensure => directory
  }
  file { 'vagrant-nginx':
    path => '/etc/nginx/sites-available/localhost',
    ensure => file,
    require => [Package['nginx'], File['/etc/nginx/sites-available']],
    source => 'puppet:///modules/nginx/localhost',
  }

  # Disable the default nginx vhost
  file { 'default-nginx-disable':
    path => '/etc/nginx/sites-enabled/default',
    ensure => absent,
    require => Package['nginx'],
  }

  # Symlink our vhost in sites-enabled to enable it
  file { '/etc/nginx/sites-enabled':
    path => '/etc/nginx/sites-enabled/',
    owner => 'root',
    group => 'root',
    ensure => directory
  }
  file { 'vagrant-nginx-enable':
    path => '/etc/nginx/sites-enabled/localhost',
    target => '/etc/nginx/sites-available/localhost',
    ensure => link,
    notify => Service['nginx'],
    require => [
      File['vagrant-nginx'],
      File['default-nginx-disable'],
      File['/etc/nginx/sites-enabled']
    ],
  }
}