class webapp::python($ensure=present,
                     $owner="www-data",
                     $group="www-data",
                     $src_root="/usr/local/src",
                     $venv_root="/usr/local/venv",
                     $nginx_workers=1,
                     $monit_admin="",
                     $monit_interval=60) {     
                     
  package { "mysql": }

  package { "mysql-devel": 
    require => Package["mysql"],
  }

  class { "nginx":
    ensure => $ensure,
    workers => $nginx_workers,
    user => $owner,
  }

  class { "python::dev":
    ensure => $ensure,
    require => Package["mysql-devel"],
  }

  class { "python::venv":
    ensure => $ensure,
    owner => $owner,
    group => $group
  }

  class { "python::gunicorn":
    ensure => $ensure,
    owner => $owner,
    group => $group
  }

  class { monit:
    ensure => $ensure,
    admin => $monit_admin,
    interval => $monit_interval
  }

}

