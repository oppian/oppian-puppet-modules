class nginx($workers=1, $ensure=present, $user="www-user") {
  $is_present = $ensure == "present"

  package { nginx:
    ensure => $ensure,
  }

  file {
    "/etc/nginx/nginx.conf":
      ensure => $ensure,
      content => template("nginx/nginx.conf.erb"),
      before => Service[nginx],
      require => Package[nginx];

    "/etc/nginx/mime.types":
      ensure => $ensure,
      source => "puppet:///modules/nginx/mime.types",
      require => File["/etc/nginx/nginx.conf"];

    "/etc/logrotate.d/nginx":
      ensure => $ensure,
      source => "puppet:///modules/nginx/nginx.logrotate",
      require => File["/etc/nginx/nginx.conf"];

    "/etc/nginx/conf.d/default.conf":
      ensure => absent,
      require => File["/etc/nginx/nginx.conf"];
  }

  service { nginx:
    ensure => $is_present,
    enable => $is_present,
    hasstatus => $is_present,
    hasrestart => $is_present,
    subscribe => $ensure ? {
      'present' => File["/etc/nginx/nginx.conf"],
      default => undef,
    },
    require => $ensure ? {
      'present' => File["/etc/nginx/nginx.conf"],
      default => undef,
    },
    before => $ensure ? {
      'absent' => File["/etc/nginx/nginx.conf"],
      default => undef,
    },
  }
}
