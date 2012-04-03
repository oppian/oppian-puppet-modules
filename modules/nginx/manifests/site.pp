define nginx::site($domain,
                   $root,
                   $ensure=present,
                   $owner=undef,
                   $group=undef,
                   $mediaroot="",
                   $mediaprefix="",
                   $default_vhost=false,
                   $autoindex=false,
                   $rewrite_missing_html_extension=false,
                   $listen_port=80,
                   $upstreams=[],
                   $aliases=[],
                   $ssl=false,
                   $ssl_certificate="",
                   $ssl_certificate_key="") {

  $absolute_mediaroot = inline_template("<%= File.expand_path(mediaroot, root) %>")

  if $ensure == 'present' {
    # Parent directory of root directory. /var/www for /var/www/blog
    $root_parent = inline_template("<%= root.match(%r!(.+)/.+!)[1] %>")

    if !defined(File[$root_parent]) {
      file { $root_parent:
        ensure => directory,
        owner => $owner,
        group => $group,
      }
    }

    file { $root:
      ensure => directory,
      owner => $owner,
      group => $group,
      require => File[$root_parent],
    }

  } elsif $ensure == 'absent' {

    file { $root:
      ensure => $ensure,
      owner => $owner,
      group => $group,
      recurse => true,
      purge => true,
      force => true,
    }
  }

  file {
    "/etc/nginx/conf.d/${name}.conf":
      ensure => $ensure,
      content => template("nginx/site.conf.erb"),
      require => [File[$root],
                  Package[nginx]],
      notify => Service[nginx];
  }
}
