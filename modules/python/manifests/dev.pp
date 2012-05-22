class python::dev($ensure=present, $version=latest) {

  $python = $version ? {
    'latest' => "python",
    default => "python${version}",
  }

  # python-dev packages depends on the correct python package in Debian:
  package { "${python}-devel":
    ensure => $ensure,
  }
  
  package { "${python}":
    ensure => $ensure,
  }
  
  package { "system-release" :
    ensure => 'latest',
    before => [ Package['python-devel'], Package[$python], Package['python-virtualenv'] ]
  }
  
}
