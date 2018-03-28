# vagrant/puppet/modules/v8js/manifests/init.pp
class v8js {

  file { 'libv8':
    path => '/home/vagrant/libv8.zip',
    ensure => file,
    require => Package['unzip'],
    source => 'puppet:///modules/v8js/libv8.zip',
  }
  file { 'v8js':
    path => '/home/vagrant/v8js.zip',
    ensure => file,
    require => Package['unzip'],
    source => 'puppet:///modules/v8js/v8js.zip',
  }

  exec { 'unzip-libv8':
    command => "/usr/bin/sudo /usr/bin/unzip /home/vagrant/libv8.zip -d /opt/",
    require => File['libv8']
  }
  exec { 'copy-libv8':
    command => "/usr/bin/sudo /bin/cp /opt/v8/lib/lib*.so /usr/lib/x86_64-linux-gnu/",
    require => Exec['unzip-libv8']
  }
  exec { 'unzip-v8js':
    command => "/usr/bin/sudo /usr/bin/unzip /home/vagrant/v8js.zip -d /usr/lib/php/20170718/",
    require => File['v8js']
  }

  # php extension loading template
  file { 'mod-v8js':
    path => '/etc/php/7.2/mods-available/v8js.ini',
    ensure => file,
    source => 'puppet:///modules/v8js/v8js.ini',
  }
  # php extension loading
  file { 'cli-v8js':
    path => '/etc/php/7.2/cli/conf.d/20-v8js.ini',
    ensure => link,
    source => '/etc/php/7.2/mods-available/v8js.ini',
    require => File['mod-v8js']
  }
  file { 'fpm-v8js':
    path => '/etc/php/7.2/fpm/conf.d/20-v8js.ini',
    ensure => link,
    source => '/etc/php/7.2/mods-available/v8js.ini',
    require => File['mod-v8js'],
#    notify => Service['php7.2-fpm']
  }

}
