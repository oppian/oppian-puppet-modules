class varnish( 
    $port=80, 
    $size="1G",
    $backend_port=8080,
    $backend_server="127.0.0.1",
) {

  package { 'varnish':
    ensure => present,
    before => [File['/etc/init.d/varnish'],File['/etc/varnish/default.vcl']],
  }

  file { '/etc/init.d/varnish' :
    ensure => file,
    mode => 700,
    content => template('varnish/varnish.init.erb'),
  }

  file { '/etc/varnish/default.vcl' :
    ensure => file,
    mode => 644,
    owner => varnish,
    group => varnish,
    content => template('varnish/default.vcl.erb'),
  }


  service { 'varnish' :
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package['varnish'],
    subscribe => [File['/etc/init.d/varnish'],File['/etc/varnish/default.vcl']],
  }
}
