# vagrant/puppet/modules/openjdk/manifests/init.pp
class openjdk {

  # Install the libcups2
  package { 'libcups2':
    ensure => present,
    require => Exec['apt-get update'],
  }

  # Install the openjdk-8 Java runtime environment
  package { 'openjdk-8-jre-headless':
    ensure => present,
    require => Package['libcups2'],
  }
}
