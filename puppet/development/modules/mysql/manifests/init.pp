# vagrant/puppet/modules/mysql/manifests/avocatbox.pp
class mysql {

  # Install mysql
  package { ['mariadb-client']:
    ensure => present,
    require => Exec['apt-get update'],
    notify => Service['mysql']
  }

  # Run mysql
  service { 'mysql':
    ensure  => running,
    require => Package['mariadb-client']
  }

  # We set the root password here & authorize login on root
  exec { 'set-mysql-password':
    command => "sudo mysql -u root -e 'SET PASSWORD = PASSWORD('\"'\"'secret'\"'\"');' mysql ; sudo mysql -u root -e 'UPDATE user SET plugin = '\"'\"'mysql_native_password'\"'\"'; FLUSH PRIVILEGES;' mysql",
    path    => ['/bin', '/usr/bin'],
    require => Service['mysql'];
  }
}
