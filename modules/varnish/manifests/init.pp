class varnish( 
    $port=80, 
    $size="1G",
    $backend_port=8080,
    $backend_server="127.0.0.1",
    $media_url="^/m/"
) {

  package { 'varnish':
    ensure => present,
  }

  file { '/etc/init.d/varnish' :
    ensure => file,
    mode => 700,
    content => template('varnish/varnish.init.erb'),
    require => Package['varnish'],
    before => Service["varnish"],
  }

  file { '/etc/varnish/default.vcl' :
    ensure => file,
    mode => 644,
    owner => varnish,
    group => varnish,
    content => template('varnish/default.vcl.erb'),
    require => Package['varnish'],
    before => Service["varnish"],
  }

  service { 'varnish' :
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package['varnish'],
    subscribe => [File['/etc/init.d/varnish'],File['/etc/varnish/default.vcl']],
  }

  service { 'varnishncsa' :
  	ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Service['varnish'],
  }  
  
  monit::monitor { "varnish":
    pidfile => "/var/run/varnish.pid",
    require => Service["varnish"],
  }
}
