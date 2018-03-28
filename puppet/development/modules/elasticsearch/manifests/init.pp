# vagrant/puppet/modules/elasticsearch/manifests/init.pp
class elasticsearch (
  $es_node_ip,
  $jvm_memory_heap,
  $es_cluster_name,
  $es_cluster_nodes_ips
) {

  # Install elasticsearch
  package { 'elasticsearch':
    ensure => 'present',
    require => Exec['apt-get update'],
  }

  file { '/etc/elasticsearch/elasticsearch.yml':
    ensure => file,
    content => template('elasticsearch/elasticsearch.erb'),
    require => Package['elasticsearch'],
  }

  file { '/etc/elasticsearch/jvm.options':
    ensure => file,
    content => template('elasticsearch/jvm.erb'),
    require => Package['elasticsearch'],
  }

  # Make sure elasticsearch is running
  service { 'elasticsearch':
    ensure => running,
    require => File['/etc/elasticsearch/jvm.options', '/etc/elasticsearch/elasticsearch.yml'],
    enable => true,
    hasrestart => true,
    restart => '/etc/init.d/elasticsearch reload'
  }
}