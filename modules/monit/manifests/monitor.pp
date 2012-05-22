define monit::monitor($pidfile,
                      $ensure=present,
                      $ip_port=0,
                      $socket="",
                      $checks=[]) {

  file { "/etc/monit.d/$name.conf":
    ensure => $ensure,
    content => template("monit/process.conf.erb"),
    notify => Service["monit"],
    require => Package["monit"],
  }
}
