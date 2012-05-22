define webapp::python::instance($domain,
                                $ensure=present,
                                $aliases=[],
                                $mediaroot="",
                                $mediaprefix="",
                                $wsgi_module="",
                                $django=false,
                                $django_settings="",
                                $django_syncdb=false,
                                $requirements=false,
                                $pythonpath=[],
                                $workers=1,
                                $listen_port=80,
                                $timeout_seconds=30,
                                $monit_memory_limit=300,
                                $default_vhost=false,
                                $monit_cpu_limit=50) {

  $venv = "${webapp::python::venv_root}/$name"
  $src = "${webapp::python::src_root}/$name"

  $pidfile = "${python::gunicorn::rundir}/${name}.pid"
  $socket = "${python::gunicorn::rundir}/${name}.sock"

  $owner = $webapp::python::owner
  $group = $webapp::python::group

  file { $src:
    ensure => directory,
    owner => $owner,
    group => $group,
  }

  nginx::site { $name:
    ensure => $ensure,
    domain => $domain,
    aliases => $aliases,
    root => "/var/www/$name",
    mediaroot => $mediaroot,
    mediaprefix => $mediaprefix,
    upstreams => ["unix:${socket}"],
    owner => $owner,
    group => $group,
    listen_port => $listen_port,
    require => Python::Gunicorn::Instance[$name],
    default_vhost => $default_vhost,
  }

  python::venv::isolate { $venv:
    ensure => $ensure,
    requirements => $requirements ? {
      true => "$src/requirements.txt",
      false => undef,
      default => "$src/$requirements",
    },
  }
  
  if $django_syncdb {
    exec { "python::syncdb $name":
      command => "$venv/bin/python manage.py syncdb --noinput",
      require => Python::Venv::Isolate[$venv],
      before => Python::Gunicorn::Instance[$name],
      cwd => $src,
      user => $owner,
      group => $group,
    }
  }

  python::gunicorn::instance { $name:
    ensure => $ensure,
    venv => $venv,
    src => $src,
    wsgi_module => $wsgi_module,
    django => $django,
    django_settings => $django_settings,
    pythonpath => $pythonpath,
    workers => $workers,
    timeout_seconds => $timeout_seconds,
    require => $ensure ? {
      'present' => Python::Venv::Isolate[$venv],
      default => undef,
    },
    before => $ensure ? {
      'absent' => Python::Venv::Isolate[$venv],
      default => undef,
    },
  }

  $reload = "/etc/init.d/gunicorn-$name reload"

  monit::monitor { "gunicorn-$name":
    ensure => $ensure,
    pidfile => $pidfile,
    socket => $socket,
    checks => ["if totalmem > $monit_memory_limit MB for 2 cycles then exec \"$reload\"",
               "if totalmem > $monit_memory_limit MB for 3 cycles then restart",
               "if cpu > ${monit_cpu_limit}% for 2 cycles then alert"],
    require => $ensure ? {
      'present' => Python::Gunicorn::Instance[$name],
      default => undef,
    },
    before => $ensure ? {
      'absent' => Python::Gunicorn::Instance[$name],
      default => undef,
    },
  }
}
